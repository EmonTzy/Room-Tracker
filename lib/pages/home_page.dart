import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/log_provider.dart';
import '../utils/hotel_date_utils.dart';
import '../utils/color_utils.dart';
import '../widgets/stat_card.dart';
import '../widgets/room_card.dart';
import 'room_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final roomProv = context.watch<RoomProvider>();
    final logProv = context.watch<LogProvider>();

    // Terjual hari ini = occupied check-in hari ini + log checkout hari ini
    final soldToday = roomProv.occupiedCheckedInTodayCount + logProv.todayLogCount;
    final dayUseTotal = roomProv.dayUseTodayCount + logProv.todayDayUseLogCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0A0F1E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D1B3E), Color(0xFF162040)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A853).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFFD4A853).withOpacity(0.4)),
                              ),
                              child: const Icon(Icons.hotel,
                                  color: Color(0xFFD4A853), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hotel Manager',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Dashboard Utama',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFFD4A853), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                HotelDateUtils.getHotelTodayLabel(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (roomProv.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFD4A853)),
              ),
            )
          else if (roomProv.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data\n${roomProv.error}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // ─── Stat Cards ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Hari Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          StatCard(
                            title: 'Terisi Sekarang',
                            value: '${roomProv.occupiedCount}',
                            icon: Icons.hotel,
                            color: RoomColorUtils.colorOccupied,
                            subtitle: 'dari ${roomProv.totalRooms} kamar',
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Tersedia',
                            value: '${roomProv.availableCount}',
                            icon: Icons.check_circle_outline,
                            color: RoomColorUtils.colorAvailable,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Terjual Hari Ini',
                            value: '$soldToday',
                            icon: Icons.sell,
                            color: const Color(0xFF9B59B6),
                            subtitle: 'check-in hari ini',
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Day Use Hari Ini',
                            value: '$dayUseTotal',
                            icon: Icons.wb_sunny,
                            color: const Color(0xFFF39C12),
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Perlu Dibersihkan',
                            value: '${roomProv.dirtyCount}',
                            icon: Icons.cleaning_services,
                            color: RoomColorUtils.colorDirty,
                          ),
                          const SizedBox(width: 12),
                          StatCard(
                            title: 'Out of Order',
                            value: '${roomProv.outOfServiceCount}',
                            icon: Icons.construction,
                            color: RoomColorUtils.colorOutOfService,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Legend ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Status Kamar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    _legendDot(RoomColorUtils.colorAvailable, 'Tersedia'),
                    const SizedBox(width: 10),
                    _legendDot(RoomColorUtils.colorOccupied, 'Terisi'),
                    const SizedBox(width: 10),
                    _legendDot(RoomColorUtils.colorDirty, 'Kotor'),
                    const SizedBox(width: 10),
                    _legendDot(RoomColorUtils.colorOutOfService, 'OOO'),
                  ],
                ),
              ),
            ),

            // ─── Room Grid ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = roomProv.rooms[index];
                    return RoomCard(
                      room: room,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoomDetailPage(room: room),
                          ),
                        );
                      },
                    );
                  },
                  childCount: roomProv.rooms.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9, color: Colors.white54),
        ),
      ],
    );
  }
}
