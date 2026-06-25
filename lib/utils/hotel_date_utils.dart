import 'package:intl/intl.dart';
import 'constants.dart';

class HotelDateUtils {
  /// Mengembalikan "hari hotel" dari suatu DateTime.
  /// Hari hotel dimulai pukul 04:00 pagi.
  /// Misal: jam 02:00 tanggal 26 → masih "hari hotel" tanggal 25.
  static DateTime getHotelDay(DateTime dt) {
    if (dt.hour < AppConstants.dayChangeHour) {
      return DateTime(dt.year, dt.month, dt.day - 1);
    }
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Mengembalikan awal hari hotel (jam 04:00)
  static DateTime getHotelDayStart(DateTime dt) {
    final day = getHotelDay(dt);
    return DateTime(day.year, day.month, day.day, AppConstants.dayChangeHour, 0, 0);
  }

  /// Mengembalikan akhir hari hotel (hari berikutnya jam 04:00)
  static DateTime getHotelDayEnd(DateTime dt) {
    final start = getHotelDayStart(dt);
    return start.add(const Duration(hours: 24));
  }

  /// Mengecek apakah dua DateTime berada di hari hotel yang sama
  static bool isSameHotelDay(DateTime a, DateTime b) {
    final dayA = getHotelDay(a);
    final dayB = getHotelDay(b);
    return dayA.year == dayB.year &&
        dayA.month == dayB.month &&
        dayA.day == dayB.day;
  }

  /// Mengecek apakah suatu datetime masuk dalam hari hotel yang sama dengan sekarang
  static bool isHotelToday(DateTime dt) {
    final now = DateTime.now();
    final todayHotel = getHotelDay(now);
    final dtHotel = getHotelDay(dt);
    return todayHotel.year == dtHotel.year &&
        todayHotel.month == dtHotel.month &&
        todayHotel.day == dtHotel.day;
  }

  /// Mengecek apakah kamar sudah melewati batas checkout (jam 12 siang)
  static bool isLateCheckout(DateTime? checkOutTime) {
    if (checkOutTime == null) return false;
    return DateTime.now().isAfter(checkOutTime);
  }

  /// Tanggal hari ini dalam konteks hotel
  static String getHotelTodayLabel() {
    final now = DateTime.now();
    final hotelDay = getHotelDay(now);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(hotelDay);
  }

  static String formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
  }

  static String formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  static String formatTime(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('HH:mm', 'id_ID').format(dt);
  }

  static String formatDateShort(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('dd/MM/yy HH:mm', 'id_ID').format(dt);
  }

  /// Mengembalikan range datetime untuk filter "Minggu Ini" (7 hari terakhir)
  static DateTime getWeekStart() {
    final now = DateTime.now();
    final hotelNow = getHotelDayStart(now);
    return hotelNow.subtract(const Duration(days: 6));
  }

  /// Mengembalikan range datetime untuk filter "Bulan Ini"
  static DateTime getMonthStart() {
    final now = DateTime.now();
    final hotelDay = getHotelDay(now);
    return DateTime(hotelDay.year, hotelDay.month, 1, AppConstants.dayChangeHour);
  }
}
