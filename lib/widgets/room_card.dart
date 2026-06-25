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
    
    bool isNextDay = false;
    bool isLate = false;
    
    if (room.isOccupied && room.checkInTime != null) {
      final now = DateTime.now();
      final checkIn = room.checkInTime!;
      
      final nowDate = DateTime(now.year, now.month, now.day);
      final checkInDate = DateTime(checkIn.year, checkIn.month, checkIn.day);
      
      isNextDay = nowDate.isAfter(checkInDate);
      
      if (room.checkOutTime != null) {
        isLate = now.isAfter(room.checkOutTime!);
      }
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
              color: color.withOpacity(0.4),
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
                color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Tanda terlambat checkout
                  if (isNextDay)
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
                    else
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Next Day',
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
                        _badge('2K', Colors.white.withOpacity(0.7)),
                      if (room.bedCount == 1)
                        _badge('1K', Colors.white.withOpacity(0.7)),
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
                    color: Colors.black.withOpacity(0.25),
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
        color: Colors.black.withOpacity(0.25),
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
