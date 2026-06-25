import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LogModel {
  final String id;
  final String roomNumber;
  final String guestName;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final bool isDayUse;
  final String? keterangan;
  final DateTime logDate; // Hari hotel check-in (untuk filter harian)

  const LogModel({
    required this.id,
    required this.roomNumber,
    required this.guestName,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isDayUse,
    required this.logDate,
    this.keterangan,
  });

  factory LogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogModel(
      id: doc.id,
      roomNumber: data['roomNumber'] ?? '',
      guestName: data['guestName'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp).toDate(),
      isDayUse: data['isDayUse'] ?? false,
      keterangan: data['keterangan'] as String?,
      logDate: (data['logDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomNumber': roomNumber,
      'guestName': guestName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': Timestamp.fromDate(checkOutTime),
      'isDayUse': isDayUse,
      'keterangan': keterangan,
      'logDate': Timestamp.fromDate(logDate),
    };
  }

  /// Factory untuk membuat log dari data checkout kamar
  factory LogModel.fromCheckout({
    required String roomNumber,
    required String guestName,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    required bool isDayUse,
    String? keterangan,
    required DateTime logDate,
  }) {
    return LogModel(
      id: const Uuid().v4(),
      roomNumber: roomNumber,
      guestName: guestName,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      isDayUse: isDayUse,
      keterangan: keterangan,
      logDate: logDate,
    );
  }

  LogModel copyWith({
    String? id,
    String? roomNumber,
    String? guestName,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? isDayUse,
    Object? keterangan = _logSentinel,
    DateTime? logDate,
  }) {
    return LogModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      guestName: guestName ?? this.guestName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isDayUse: isDayUse ?? this.isDayUse,
      keterangan: keterangan == _logSentinel ? this.keterangan : keterangan as String?,
      logDate: logDate ?? this.logDate,
    );
  }
}

const _logSentinel = Object();
