class AppConstants {
  static const String appName = 'Hotel Manager';

  // Hotel hari mulai jam 04:00 pagi
  static const int dayChangeHour = 4;

  // Batas checkout tanpa denda jam 12:00 siang
  static const int checkoutDeadlineHour = 12;

  // Tipe kamar
  static const List<String> roomTypes = [
    'Superior',
    'Deluxe',
    'Economy',
    'Standard',
  ];

  // Status kamar
  static const String statusAvailable = 'available';
  static const String statusOutOfService = 'out_of_service';

  // Status kebersihan
  static const String cleanBersih = 'bersih';
  static const String cleanKotor = 'kotor';

  // Koleksi Firestore
  static const String collectionRooms = 'rooms';
  static const String collectionLogs = 'logs';
}
