import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import '../models/log_model.dart';
import '../utils/hotel_date_utils.dart';
import '../widgets/date_time_picker_tile.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogProvider>().applyFilter(LogFilter.hariIni);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logProv = context.watch<LogProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B3E),
        elevation: 0,
        title: Text(
          'Log Tamu',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFD4A853).withOpacity(0.3)),
                ),
                child: Text(
                  '${logProv.logs.length} entri',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFD4A853),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Bar ──────────────────────────────────────────
          Container(
            color: const Color(0xFF0D1B3E),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Hari Ini',
                          isSelected:
                              logProv.currentFilter == LogFilter.hariIni,
                          onTap: () =>
                              logProv.applyFilter(LogFilter.hariIni),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Minggu Ini',
                          isSelected:
                              logProv.currentFilter == LogFilter.mingguIni,
                          onTap: () =>
                              logProv.applyFilter(LogFilter.mingguIni),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Bulan Ini',
                          isSelected:
                              logProv.currentFilter == LogFilter.bulanIni,
                          onTap: () =>
                              logProv.applyFilter(LogFilter.bulanIni),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Custom',
                          isSelected:
                              logProv.currentFilter == LogFilter.custom,
                          icon: Icons.date_range,
                          onTap: () => _pickCustomRange(context, logProv),
                        ),
                      ],
                    ),
                  ),
                ),

                // Custom range label
                if (logProv.currentFilter == LogFilter.custom &&
                    logProv.customStart != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${HotelDateUtils.formatDate(logProv.customStart)} — ${HotelDateUtils.formatDate(logProv.customEnd)}',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ),

                const Divider(height: 1, color: Colors.white12),
              ],
            ),
          ),

          // ─── Log List ────────────────────────────────────────────
          Expanded(
            child: logProv.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFD4A853)),
                  )
                : logProv.error != null
                    ? Center(
                        child: Text(
                          'Error: ${logProv.error}',
                          style: GoogleFonts.poppins(color: Colors.white54),
                        ),
                      )
                    : logProv.logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.history,
                                    size: 64, color: Colors.white24),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada log pada periode ini',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white38,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            itemCount: logProv.logs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final log = logProv.logs[index];
                              return _LogCard(log: log);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(
      BuildContext context, LogProvider prov) async {
    final now = DateTime.now();
    final start = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Pilih Tanggal Mulai',
      builder: _darkDatePickerTheme,
    );
    if (start == null || !context.mounted) return;

    final end = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: start,
      lastDate: now,
      helpText: 'Pilih Tanggal Akhir',
      builder: _darkDatePickerTheme,
    );
    if (end == null) return;

    prov.applyFilter(LogFilter.custom,
        customStart: start, customEnd: end);
  }

  Widget Function(BuildContext, Widget?) get _darkDatePickerTheme =>
      (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFD4A853),
                onPrimary: Colors.black,
                surface: Color(0xFF1E2D45),
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
}

// ─── Filter Chip ──────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected
                      ? const Color(0xFF0A0F1E)
                      : Colors.white54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF0A0F1E)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Log Card ─────────────────────────────────────────────────────────
class _LogCard extends StatelessWidget {
  final LogModel log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final duration = log.checkOutTime.difference(log.checkInTime);
    final hours = duration.inHours;
    final durationLabel = hours < 24
        ? '$hours jam'
        : '${duration.inDays} hari';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D45),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: log.isDayUse
                ? Colors.orange
                : const Color(0xFF2980B9),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Kamar ${log.roomNumber}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  log.guestName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (log.isDayUse) ...[                
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Text(
                    'DAY USE',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              if (!log.isDayUse) ...[                
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: Text(
                    'Menginap',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              // Edit button
              InkWell(
                onTap: () => _showEditDialog(context, log),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white38,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Time row
          Row(
            children: [
              _TimeColumn(
                label: 'Check In',
                time: HotelDateUtils.formatDateTime(log.checkInTime),
                icon: Icons.login,
                color: Colors.green,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const Icon(Icons.arrow_forward,
                        color: Colors.white24, size: 16),
                    Text(
                      durationLabel,
                      style: GoogleFonts.poppins(
                          fontSize: 9, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              _TimeColumn(
                label: 'Check Out',
                time: HotelDateUtils.formatDateTime(log.checkOutTime),
                icon: Icons.logout,
                color: Colors.red.shade300,
              ),
            ],
          ),

          if (log.keterangan != null && log.keterangan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes,
                      size: 13, color: Colors.white38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      log.keterangan!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LogModel log) {
    final guestNameCtrl = TextEditingController(text: log.guestName);
    final keteranganCtrl = TextEditingController(text: log.keterangan ?? '');
    DateTime newCheckIn = log.checkInTime;
    DateTime newCheckOut = log.checkOutTime;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Auto-compute Day Use for preview
          final willBeDayUse = HotelDateUtils.isSameHotelDay(newCheckIn, newCheckOut);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E2D45),
            title: Row(
              children: [
                const Icon(Icons.edit, color: Color(0xFFD4A853), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Edit Log — Kamar ${log.roomNumber}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _confirmDeleteLog(context, log);
                  },
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Room number (read-only)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hotel, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Kamar ${log.roomNumber}',
                          style: GoogleFonts.poppins(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Guest name
                  TextField(
                    controller: guestNameCtrl,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Nama Tamu',
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.person,
                          color: Colors.white38, size: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFD4A853)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DateTimePickerTile(
                    label: 'Check In',
                    value: newCheckIn,
                    onPicked: (dt) =>
                        setDialogState(() => newCheckIn = dt),
                  ),
                  const SizedBox(height: 8),
                  DateTimePickerTile(
                    label: 'Check Out',
                    value: newCheckOut,
                    onPicked: (dt) =>
                        setDialogState(() => newCheckOut = dt),
                  ),
                  const SizedBox(height: 12),
                  // Auto Day Use indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: willBeDayUse
                          ? Colors.orange.withOpacity(0.12)
                          : Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: willBeDayUse
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          willBeDayUse
                              ? Icons.wb_sunny
                              : Icons.nights_stay,
                          color: willBeDayUse
                              ? Colors.orange
                              : Colors.blue.shade300,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          willBeDayUse
                              ? 'DAY USE'
                              : 'Reguler (Menginap)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: willBeDayUse
                                ? Colors.orange
                                : Colors.blue.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Keterangan
                  TextField(
                    controller: keteranganCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Keterangan (opsional)',
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 12),
                      prefixIcon: const Icon(Icons.notes,
                          color: Colors.white38, size: 18),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFD4A853)),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal',
                    style:
                        GoogleFonts.poppins(color: Colors.white54)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A853),
                    foregroundColor: Colors.black),
                icon: const Icon(Icons.save, size: 16),
                label: Text('Simpan',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600)),
                onPressed: () async {
                  if (guestNameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  final isDayUse = HotelDateUtils.isSameHotelDay(
                      newCheckIn, newCheckOut);

                  final updated = LogModel(
                    id: log.id,
                    roomNumber: log.roomNumber,
                    guestName: guestNameCtrl.text.trim(),
                    checkInTime: newCheckIn,
                    checkOutTime: newCheckOut,
                    isDayUse: isDayUse,
                    keterangan: keteranganCtrl.text.trim().isEmpty
                        ? null
                        : keteranganCtrl.text.trim(),
                    logDate:
                        HotelDateUtils.getHotelDayStart(newCheckIn),
                  );

                  await context.read<LogProvider>().updateLog(updated);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Log berhasil diperbarui'),
                        backgroundColor: Color(0xFFD4A853),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteLog(BuildContext context, LogModel log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D45),
        title: Text(
          'Hapus Log',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus log untuk tamu ${log.guestName}?',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
              Navigator.pop(context); // tutup modal edit
              await context.read<LogProvider>().deleteLog(log.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Log berhasil dihapus'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
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

class _TimeColumn extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
