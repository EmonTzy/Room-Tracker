import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/hotel_date_utils.dart';

/// Widget pemilih tanggal & waktu, dapat digunakan di mana saja.
class DateTimePickerTile extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onPicked;

  const DateTimePickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
  });

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4A853),
            onPrimary: Colors.black,
            surface: Color(0xFF1E2D45),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4A853),
            onPrimary: Colors.black,
            surface: Color(0xFF1E2D45),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    onPicked(
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.white38, size: 18),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        GoogleFonts.poppins(color: Colors.white38, fontSize: 10)),
                Text(
                  HotelDateUtils.formatDateTime(value),
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}
