import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String roomNumber;
  final String roomType;
  final int bedCount;
  final String status; // 'available' | 'out_of_service'
  final String cleanStatus; // 'bersih' | 'kotor'
  final bool isOccupied;
  final String? guestName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime; // Estimasi checkout
  final bool isDayUse;
  final String? keterangan;
  final String? previousRoom; // Set saat pindah kamar
  final List<Map<String, dynamic>> extendHistory;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.bedCount,
    required this.status,
    required this.cleanStatus,
    required this.isOccupied,
    this.guestName,
    this.checkInTime,
    this.checkOutTime,
    this.isDayUse = false,
    this.keterangan,
    this.previousRoom,
    this.extendHistory = const [],
  });

  factory RoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomModel(
      id: doc.id,
      roomNumber: data['roomNumber'] ?? '',
      roomType: data['roomType'] ?? 'Standard',
      bedCount: (data['bedCount'] ?? 1) as int,
      status: data['status'] ?? 'available',
      cleanStatus: data['cleanStatus'] ?? 'bersih',
      isOccupied: data['isOccupied'] ?? false,
      guestName: data['guestName'] as String?,
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      isDayUse: data['isDayUse'] ?? false,
      keterangan: data['keterangan'] as String?,
      previousRoom: data['previousRoom'] as String?,
      extendHistory: List<Map<String, dynamic>>.from(
        (data['extendHistory'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomNumber': roomNumber,
      'roomType': roomType,
      'bedCount': bedCount,
      'status': status,
      'cleanStatus': cleanStatus,
      'isOccupied': isOccupied,
      'guestName': guestName,
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'isDayUse': isDayUse,
      'keterangan': keterangan,
      'previousRoom': previousRoom,
      'extendHistory': extendHistory,
    };
  }

  /// CopyWith untuk update field tertentu
  RoomModel copyWith({
    String? id,
    String? roomNumber,
    String? roomType,
    int? bedCount,
    String? status,
    String? cleanStatus,
    bool? isOccupied,
    Object? guestName = _sentinel,
    Object? checkInTime = _sentinel,
    Object? checkOutTime = _sentinel,
    bool? isDayUse,
    Object? keterangan = _sentinel,
    Object? previousRoom = _sentinel,
    List<Map<String, dynamic>>? extendHistory,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      roomType: roomType ?? this.roomType,
      bedCount: bedCount ?? this.bedCount,
      status: status ?? this.status,
      cleanStatus: cleanStatus ?? this.cleanStatus,
      isOccupied: isOccupied ?? this.isOccupied,
      guestName: guestName == _sentinel ? this.guestName : guestName as String?,
      checkInTime: checkInTime == _sentinel ? this.checkInTime : checkInTime as DateTime?,
      checkOutTime: checkOutTime == _sentinel ? this.checkOutTime : checkOutTime as DateTime?,
      isDayUse: isDayUse ?? this.isDayUse,
      keterangan: keterangan == _sentinel ? this.keterangan : keterangan as String?,
      previousRoom: previousRoom == _sentinel ? this.previousRoom : previousRoom as String?,
      extendHistory: extendHistory ?? this.extendHistory,
    );
  }

  /// Reset kamar setelah checkout
  RoomModel afterCheckout() {
    return RoomModel(
      id: id,
      roomNumber: roomNumber,
      roomType: roomType,
      bedCount: bedCount,
      status: status,
      cleanStatus: 'kotor',
      isOccupied: false,
      isDayUse: false,
      extendHistory: const [],
    );
  }
}

// Sentinel untuk membedakan null yang disengaja vs tidak diset
const _sentinel = Object();
