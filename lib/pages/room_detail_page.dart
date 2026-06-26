import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/room_model.dart';
import '../providers/room_provider.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../utils/hotel_date_utils.dart';
import '../widgets/date_time_picker_tile.dart';
import '../widgets/room_card.dart';
import 'room_form_page.dart';

class RoomDetailPage extends StatefulWidget {
  final RoomModel room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  // Ambil data terbaru dari provider
  RoomModel _getLatestRoom(RoomProvider prov) {
    return prov.rooms.firstWhere(
      (r) => r.id == widget.room.id,
      orElse: () => widget.room,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RoomProvider>();
    final room = _getLatestRoom(prov);
    final color = RoomColorUtils.getRoomColor(room);
    final statusLabel = RoomColorUtils.getRoomStatusLabel(room);
    final isLate = room.isOccupied &&
        room.checkOutTime != null &&
        DateTime.now().isAfter(room.checkOutTime!);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: CustomScrollView(
        slivers: [
          // ─── App Bar / Header ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0A0F1E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoomFormPage(room: room),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.7),
                      color.withOpacity(0.3),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Kamar ${room.roomNumber}',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.white30),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${room.roomType} • ${room.bedCount} Kasur',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Warning: Terlambat checkout
                if (isLate) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TERLAMBAT CHECKOUT',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                'Batas checkout jam 12:00 telah lewat.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.red.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Informasi Tamu
                if (room.isOccupied) ...[
                  _SectionCard(
                    title: 'Informasi Tamu',
                    icon: Icons.person,
                    iconColor: const Color(0xFF2980B9),
                    action: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showEditGuestInfoDialog(context, room);
                      },
                    ),
                    children: [
                      _DetailRow('Nama Tamu', room.guestName ?? '-'),
                      _DetailRow(
                          'Check-in',
                          HotelDateUtils.formatDateTime(room.checkInTime)),
                      if (room.checkInTime != null && room.checkOutTime != null)
                        _DetailRow(
                          'Lama Menginap',
                          () {
                            final inDay = DateTime(
                              room.checkInTime!.year,
                              room.checkInTime!.month,
                              room.checkInTime!.day,
                            );
                            final outDay = DateTime(
                              room.checkOutTime!.year,
                              room.checkOutTime!.month,
                              room.checkOutTime!.day,
                            );
                            final nights = outDay.difference(inDay).inDays;
                            return '$nights Malam';
                          }(),
                        ),
                      if (room.keterangan != null && room.keterangan!.isNotEmpty)
                        _DetailRow('Keterangan', room.keterangan!),
                      if (room.previousRoom != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, size: 13, color: Colors.blueAccent.shade100),
                              const SizedBox(width: 6),
                              Text(
                                'Pindah dari kamar ${room.previousRoom}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.blueAccent.shade100,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Informasi Kamar
                _SectionCard(
                  title: 'Detail Kamar',
                  icon: Icons.hotel,
                  iconColor: const Color(0xFFD4A853),
                  children: [
                    _DetailRow('Nomor Kamar', room.roomNumber),
                    _DetailRow('Tipe Kamar', room.roomType),
                    _DetailRow('Jumlah Kasur', '${room.bedCount} Kasur'),
                    _DetailRow(
                      'Status Operasional',
                      room.status == AppConstants.statusAvailable
                          ? 'Tersedia'
                          : 'Out of Service',
                      valueColor:
                          room.status == AppConstants.statusAvailable
                              ? Colors.green
                              : Colors.red,
                    ),
                    _DetailRow(
                      'Kebersihan',
                      room.cleanStatus == AppConstants.cleanBersih
                          ? 'Bersih'
                          : 'Kotor',
                      valueColor:
                          room.cleanStatus == AppConstants.cleanBersih
                              ? Colors.green
                              : Colors.orange,
                    ),
                  ],
                ),

                // Riwayat Perpanjangan
                if (room.extendHistory.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Riwayat Perpanjangan',
                    icon: Icons.history,
                    iconColor: const Color(0xFF9B59B6),
                    children: room.extendHistory.asMap().entries.map((e) {
                      final idx = e.key + 1;
                      final ext = e.value;
                      final extAt = (ext['extendedAt'] as dynamic)?.toDate?.call();
                      final newCO = (ext['newCheckOut'] as dynamic)?.toDate?.call();
                      return _DetailRow(
                        'Perpanjangan #$idx',
                        HotelDateUtils.formatDateTime(newCO) +
                            (ext['note'] != null && ext['note'].toString().isNotEmpty
                                ? '\n${ext['note']}'
                                : ''),
                        subtitle: 'Dilakukan: ${HotelDateUtils.formatDateTime(extAt)}',
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // ─── Action Buttons ────────────────────────────────
                _buildActionButtons(context, room),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RoomModel room) {
    final prov = context.read<RoomProvider>();

    if (room.status == AppConstants.statusOutOfService) {
      return _ActionButton(
        label: 'Tandai Aktif / Tersedia',
        icon: Icons.check_circle_outline,
        color: Colors.green,
        onPressed: () async {
          await prov.toggleRoomStatus(
              room.id, AppConstants.statusAvailable);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Kamar ditandai Tersedia'),
                  backgroundColor: Colors.green),
            );
          }
        },
      );
    }

    if (!room.isOccupied) {
      // Kamar tersedia — bisa check in
      return Column(
        children: [
          _ActionButton(
            label: 'Check In Tamu',
            icon: Icons.login,
            color: const Color(0xFF2980B9),
            onPressed: () => _showCheckInDialog(context, room),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: room.cleanStatus == AppConstants.cleanBersih
                      ? 'Tandai Kotor'
                      : 'Tandai Bersih',
                  icon: Icons.cleaning_services,
                  color: room.cleanStatus == AppConstants.cleanBersih
                      ? Colors.orange
                      : Colors.green,
                  onPressed: () async {
                    final newStatus =
                        room.cleanStatus == AppConstants.cleanBersih
                            ? AppConstants.cleanKotor
                            : AppConstants.cleanBersih;
                    await prov.toggleCleanStatus(room.id, newStatus);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Out of Service',
                  icon: Icons.construction,
                  color: Colors.red,
                  onPressed: () async {
                    await prov.toggleRoomStatus(
                        room.id, AppConstants.statusOutOfService);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Kamar terisi — bisa checkout atau perpanjang
    return Column(
      children: [
        _ActionButton(
          label: 'Check Out Tamu',
          icon: Icons.logout,
          color: Colors.green,
          onPressed: () => _showCheckOutDialog(context, room),
        ),
        const SizedBox(height: 10),
        Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Perpanjang',
                  icon: Icons.more_time,
                  color: const Color(0xFF9B59B6),
                  onPressed: () => _showExtendDialog(context, room),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Pindah Kamar',
                  icon: Icons.swap_horiz,
                  color: Colors.blue,
                  onPressed: () => _showMoveRoomBottomSheet(context, room),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ─── Dialog Check In ──────────────────────────────────────────────
  void _showCheckInDialog(BuildContext context, RoomModel room) {
    final guestNameCtrl = TextEditingController();
    final keteranganCtrl = TextEditingController();
    final lengthOfStayCtrl = TextEditingController(text: '1');
    DateTime checkIn = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2D45),
          title: Text(
            'Check In — Kamar ${room.roomNumber}',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogTextField(
                  controller: guestNameCtrl,
                  label: 'Nama Tamu',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                DateTimePickerTile(
                  label: 'Waktu Check In',
                  value: checkIn,
                  onPicked: (dt) => setDialogState(() => checkIn = dt),
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: lengthOfStayCtrl,
                  label: 'Lama Menginap (Malam)',
                  icon: Icons.nightlight_round,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: keteranganCtrl,
                  label: 'Keterangan (opsional)',
                  icon: Icons.notes,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2980B9)),
              onPressed: () async {
                if (guestNameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await context.read<RoomProvider>().checkIn(
                      roomId: room.id,
                      guestName: guestNameCtrl.text.trim(),
                      checkInTime: checkIn,
                      keterangan: keteranganCtrl.text.trim().isEmpty
                          ? null
                          : keteranganCtrl.text.trim(),
                      lengthOfStay: int.tryParse(lengthOfStayCtrl.text.trim()) ?? 1,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Check in ${guestNameCtrl.text.trim()} berhasil!'),
                      backgroundColor: const Color(0xFF2980B9),
                    ),
                  );
                }
              },
              child: Text('Check In',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog Check Out ─────────────────────────────────────────────
  void _showCheckOutDialog(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text(
          'Check Out — Kamar ${room.roomNumber}',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tamu: ${room.guestName ?? "-"}',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Check In: ${HotelDateUtils.formatDateTime(room.checkInTime)}',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Checkout sekarang: ${HotelDateUtils.formatDateTime(DateTime.now())}',
              style: GoogleFonts.poppins(
                  color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'Setelah checkout, kamar akan ditandai KOTOR dan log akan tersimpan.',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RoomProvider>().checkOut(room);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check out berhasil! Log tersimpan.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // kembali ke list
              }
            },
            child: Text('Konfirmasi Checkout',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Dialog Perpanjang ────────────────────────────────────────────
  void _showExtendDialog(BuildContext context, RoomModel room) {
    final noteCtrl = TextEditingController();
    DateTime newCheckOut = room.checkOutTime?.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(hours: 24));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2D45),
          title: Text(
            'Perpanjang Menginap — ${room.roomNumber}',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (room.checkOutTime != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule,
                          color: Colors.white38, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Checkout sebelumnya:\n${HotelDateUtils.formatDateTime(room.checkOutTime)}',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              DateTimePickerTile(
                label: 'Checkout Baru',
                value: newCheckOut,
                onPicked: (dt) => setDialogState(() => newCheckOut = dt),
              ),
              const SizedBox(height: 12),
              _DialogTextField(
                controller: noteCtrl,
                label: 'Catatan Perpanjangan',
                icon: Icons.notes,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B59B6)),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<RoomProvider>().extendStay(
                      room: room,
                      newCheckOut: newCheckOut,
                      note: noteCtrl.text.trim(),
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perpanjangan berhasil disimpan!'),
                      backgroundColor: Color(0xFF9B59B6),
                    ),
                  );
                }
              },
              child: Text('Perpanjang',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog Edit Informasi Tamu ───────────────────────────────────
  void _showEditGuestInfoDialog(BuildContext context, RoomModel room) {
    final nameCtrl = TextEditingController(text: room.guestName);
    final keteranganCtrl = TextEditingController(text: room.keterangan ?? '');
    DateTime newCheckIn = room.checkInTime ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E2D45),
          title: Text(
            'Edit Informasi Tamu',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogTextField(
                  controller: nameCtrl,
                  label: 'Nama Tamu',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                DateTimePickerTile(
                  label: 'Check-in',
                  value: newCheckIn,
                  onPicked: (dt) => setDialogState(() => newCheckIn = dt),
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: keteranganCtrl,
                  label: 'Keterangan (Opsional)',
                  icon: Icons.notes,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A853),
                  foregroundColor: Colors.black),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                
                await context.read<RoomProvider>().updateGuestInfo(
                  room.id,
                  nameCtrl.text.trim(),
                  newCheckIn,
                  keteranganCtrl.text.trim().isEmpty ? null : keteranganCtrl.text.trim(),
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informasi tamu berhasil diperbarui'),
                      backgroundColor: Color(0xFFD4A853),
                    ),
                  );
                }
              },
              child: Text('Simpan',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog Pindah Kamar ──────────────────────────────────────────────────
  void _showMoveRoomBottomSheet(BuildContext context, RoomModel currentRoom) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2D45),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            final rooms = context.watch<RoomProvider>().rooms;
            final availableRooms = rooms
                .where((r) =>
                    !r.isOccupied && r.status == AppConstants.statusAvailable)
                .toList();

            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih Kamar Tujuan',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: availableRooms.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada kamar kosong tersedia',
                            style: GoogleFonts.poppins(color: Colors.white54),
                          ),
                        )
                      : GridView.builder(
                          controller: controller,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: availableRooms.length,
                          itemBuilder: (gridCtx, index) {
                            final targetRoom = availableRooms[index];
                            return RoomCard(
                              room: targetRoom,
                              onTap: () {
                                Navigator.pop(ctx);
                                _confirmMoveRoom(context, currentRoom, targetRoom);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmMoveRoom(
      BuildContext context, RoomModel currentRoom, RoomModel targetRoom) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text(
          'Konfirmasi Pindah Kamar',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: Text(
          'Pindahkan tamu ${currentRoom.guestName} dari Kamar ${currentRoom.roomNumber} ke Kamar ${targetRoom.roomNumber}?',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RoomProvider>().moveRoom(
                    currentRoom: currentRoom,
                    targetRoom: targetRoom,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Tamu berhasil dipindah ke Kamar ${targetRoom.roomNumber}'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: Text('Ya, Pindahkan',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Component Helpers ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;

  const _DetailRow(this.label, this.value, {this.valueColor, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: valueColor ?? Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white38,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.4)),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        onPressed: onPressed,
      ),
    );
  }
}

// ─── Dialog Text Field ────────────────────────────────────────────────
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4A853)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
