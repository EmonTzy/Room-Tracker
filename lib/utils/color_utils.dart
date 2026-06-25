import 'package:flutter/material.dart';
import '../models/room_model.dart';
import 'constants.dart';

class RoomColorUtils {
  /// Warna utama kamar berdasarkan status
  static Color getRoomColor(RoomModel room) {
    if (room.status == AppConstants.statusOutOfService) {
      return const Color(0xFFE74C3C); // Merah - Out of Service
    }
    if (room.isOccupied) {
      return const Color(0xFF2980B9); // Biru - Terisi
    }
    if (room.cleanStatus == AppConstants.cleanKotor) {
      return const Color(0xFFE67E22); // Kuning/Orange - Kotor
    }
    return const Color(0xFF27AE60); // Hijau - Tersedia & Bersih
  }

  /// Gradient warna untuk card kamar
  static LinearGradient getRoomGradient(RoomModel room) {
    final baseColor = getRoomColor(room);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        baseColor.withOpacity(0.75),
      ],
    );
  }

  /// Label status kamar dalam Bahasa Indonesia
  static String getRoomStatusLabel(RoomModel room) {
    if (room.status == AppConstants.statusOutOfService) return 'Rusak/OOO';
    if (room.isOccupied) return 'Terisi';
    if (room.cleanStatus == AppConstants.cleanKotor) return 'Kotor';
    return 'Tersedia';
  }

  /// Ikon untuk status kamar
  static IconData getRoomStatusIcon(RoomModel room) {
    if (room.status == AppConstants.statusOutOfService) return Icons.construction;
    if (room.isOccupied) return Icons.hotel;
    if (room.cleanStatus == AppConstants.cleanKotor) return Icons.cleaning_services;
    return Icons.check_circle;
  }

  /// Warna untuk status availability
  static Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusOutOfService:
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF27AE60);
    }
  }

  static const Color colorAvailable = Color(0xFF27AE60);
  static const Color colorOccupied = Color(0xFF2980B9);
  static const Color colorDirty = Color(0xFFE67E22);
  static const Color colorOutOfService = Color(0xFFE74C3C);
}
