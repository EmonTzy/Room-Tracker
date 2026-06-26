import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_model.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = RoomColorUtils.getRoomColor(room);

    bool isCheckoutToday = false;
    bool isLate = false;

    if (room.isOccupied && room.checkOutTime != null) {
      final now = DateTime.now();
      final checkOut = room.checkOutTime!;

      // Hotel day of checkout (the calendar date of 12PM checkout)
      final checkOutDay = DateTime(checkOut.year, checkOut.month, checkOut.day);

      // Current hotel day (shifts at 4AM — before 4AM still counts as previous day)
      final hotelNow = now.hour < 4
          ? DateTime(now.year, now.month, now.day - 1)
          : DateTime(now.year, now.month, now.day);

      // "CO Hari Ini" window: from 4AM on checkout day until the checkout time (12PM)
      isCheckoutToday = hotelNow == checkOutDay && now.isBefore(checkOut);

      // "TELAT": past the 12PM checkout deadline on checkout day or later
      isLate = now.isAfter(checkOut) && !hotelNow.isBefore(checkOutDay);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: RoomColorUtils.getRoomGradient(room),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                RoomColorUtils.getRoomStatusIcon(room),
                size: 55,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room number
                  Text(
                    room.roomNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Room type
                  Text(
                    room.roomType,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Checkout status badge
                  if (isLate)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'TELAT',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else if (isCheckoutToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CO Hari Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Jumlah kasur badge
                  Row(
                    children: [
                      if (room.bedCount == 2)
                        _badge('2K', Colors.white.withValues(alpha: 0.7)),
                      if (room.bedCount == 1)
                        _badge('1K', Colors.white.withValues(alpha: 0.7)),
                    ],
                  ),
                ],
              ),
            ),

            // OOO overlay
            if (room.status == AppConstants.statusOutOfService)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
