import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room_model.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import 'room_detail_page.dart';
import 'room_form_page.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  String _filterType = 'Semua';
  String _filterStatus = 'Semua';

  static const List<String> _typeFilters = [
    'Semua', 'Superior', 'Deluxe', 'Economy', 'Standard'
  ];
  static const List<String> _statusFilters = [
    'Semua', 'Tersedia', 'Terisi', 'Kotor', 'OOO'
  ];

  List<RoomModel> _applyFilters(List<RoomModel> rooms) {
    return rooms.where((r) {
      bool matchType = _filterType == 'Semua' || r.roomType == _filterType;
      bool matchStatus = true;
      if (_filterStatus == 'Tersedia') {
        matchStatus = !r.isOccupied && r.status == AppConstants.statusAvailable;
      } else if (_filterStatus == 'Terisi') {
        matchStatus = r.isOccupied;
      } else if (_filterStatus == 'Kotor') {
        matchStatus = r.cleanStatus == AppConstants.cleanKotor;
      } else if (_filterStatus == 'OOO') {
        matchStatus = r.status == AppConstants.statusOutOfService;
      }
      return matchType && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final roomProv = context.watch<RoomProvider>();
    final filtered = _applyFilters(roomProv.rooms);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        title: Text(
          'Manajemen Kamar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4A853).withOpacity(0.3)),
                ),
                child: Text(
                  '${filtered.length} kamar',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFD4A853),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFD4A853)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoomFormPage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Bar ──────────────────────────────────────────
          Container(
            color: const Color(0xFF0D1B3E),
            child: Column(
              children: [
                _FilterRow(
                  label: 'Tipe',
                  options: _typeFilters,
                  selected: _filterType,
                  onSelect: (v) => setState(() => _filterType = v),
                ),
                _FilterRow(
                  label: 'Status',
                  options: _statusFilters,
                  selected: _filterStatus,
                  onSelect: (v) => setState(() => _filterStatus = v),
                ),
                const Divider(height: 1, color: Colors.white12),
              ],
            ),
          ),

          // ─── List ────────────────────────────────────────────────
          Expanded(
            child: roomProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4A853)),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bed, size: 64, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada kamar',
                              style: GoogleFonts.poppins(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final room = filtered[index];
                          return _RoomListTile(
                            room: room,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomDetailPage(room: room),
                              ),
                            ),
                            onDelete: () => _confirmDelete(context, room),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text(
          'Hapus Kamar ${room.roomNumber}?',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RoomProvider>().deleteRoom(room.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kamar ${room.roomNumber} dihapus'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Hapus',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Row Widget ───────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          Text(
            '$label:',
            style: GoogleFonts.poppins(
                color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((opt) {
                  final isSelected = selected == opt;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => onSelect(opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4A853)
                              : Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4A853)
                                : Colors.white12,
                          ),
                        ),
                        child: Text(
                          opt,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isSelected
                                ? const Color(0xFF0A0F1E)
                                : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Room List Tile ──────────────────────────────────────────────────
class _RoomListTile extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RoomListTile({
    required this.room,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = RoomColorUtils.getRoomColor(room);
    final statusLabel = RoomColorUtils.getRoomStatusLabel(room);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2D45),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            children: [
              // Room number
              SizedBox(
                width: 48,
                child: Text(
                  room.roomNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          room.roomType,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${room.bedCount} Kasur',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white38,
                          ),
                        ),
                        if (room.isDayUse && room.isOccupied) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.4)),
                            ),
                            child: Text(
                              'DAY USE',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (room.guestName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        room.guestName!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
