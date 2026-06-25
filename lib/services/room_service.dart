import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';
import '../models/log_model.dart';
import '../utils/constants.dart';
import '../utils/hotel_date_utils.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;
  
  CollectionReference get _roomsRef => _db.collection(AppConstants.collectionRooms);
  CollectionReference get _logsRef => _db.collection(AppConstants.collectionLogs);

  // ─── Stream semua kamar ───────────────────────────────────────────
  Stream<List<RoomModel>> getRoomsStream() {
    return _roomsRef
        .orderBy('roomNumber')
        .snapshots()
        .map((snap) => snap.docs.map(RoomModel.fromFirestore).toList());
  }

  // ─── Tambah kamar baru ────────────────────────────────────────────
  Future<void> addRoom(RoomModel room) async {
    await _roomsRef.add(room.toFirestore());
  }

  // ─── Update data kamar ────────────────────────────────────────────
  Future<void> updateRoom(RoomModel room) async {
    await _roomsRef.doc(room.id).update(room.toFirestore());
  }

  // ─── Hapus kamar ─────────────────────────────────────────────────
  Future<void> deleteRoom(String roomId) async {
    await _roomsRef.doc(roomId).delete();
  }

  // ─── Check-in tamu ───────────────────────────────────────────────
  Future<void> checkIn({
    required String roomId,
    required String guestName,
    required DateTime checkInTime,
    String? keterangan,
  }) async {
    final DateTime nextDay = checkInTime.add(const Duration(days: 1));
    final DateTime checkOutTime =
        DateTime(nextDay.year, nextDay.month, nextDay.day, 12, 0);

    await _roomsRef.doc(roomId).update({
      'isOccupied': true,
      'guestName': guestName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': Timestamp.fromDate(checkOutTime),
      'isDayUse': false,
      'keterangan': keterangan,
      'cleanStatus': AppConstants.cleanBersih,
    });
  }

  // ─── Pindah Kamar ────────────────────────────────────────────────
  Future<void> moveRoom({
    required RoomModel currentRoom,
    required RoomModel targetRoom,
  }) async {
    final batch = _db.batch();

    // 1. Kosongkan kamar lama dan set jadi kotor
    final currentRef = _roomsRef.doc(currentRoom.id);
    batch.update(currentRef, {
      'isOccupied': false,
      'guestName': null,
      'checkInTime': null,
      'checkOutTime': null,
      'isDayUse': false,
      'keterangan': null,
      'cleanStatus': AppConstants.cleanKotor,
    });

    // 2. Pindahkan info ke kamar baru
    final targetRef = _roomsRef.doc(targetRoom.id);
    batch.update(targetRef, {
      'isOccupied': true,
      'guestName': currentRoom.guestName,
      'checkInTime': currentRoom.checkInTime != null
          ? Timestamp.fromDate(currentRoom.checkInTime!)
          : null,
      'checkOutTime': currentRoom.checkOutTime != null
          ? Timestamp.fromDate(currentRoom.checkOutTime!)
          : null,
      'isDayUse': currentRoom.isDayUse,
      'keterangan': currentRoom.keterangan,
      'cleanStatus': AppConstants.cleanBersih,
    });

    await batch.commit();
  }

  // ─── Check-out tamu ──────────────────────────────────────────────
  Future<void> checkOut(RoomModel room) async {
    final now = DateTime.now();

    // Hitung otomatis: Day Use = check-in dan checkout pada hari hotel yang sama
    final isDayUse = room.checkInTime != null &&
        HotelDateUtils.isSameHotelDay(room.checkInTime!, now);

    // Buat log entry
    if (room.guestName != null && room.checkInTime != null) {
      final log = LogModel.fromCheckout(
        roomNumber: room.roomNumber,
        guestName: room.guestName!,
        checkInTime: room.checkInTime!,
        checkOutTime: now,
        isDayUse: isDayUse,
        keterangan: room.keterangan,
        logDate: HotelDateUtils.getHotelDayStart(room.checkInTime!),
      );
      await _logsRef.add(log.toFirestore());
    }

    // Reset data kamar
    await _roomsRef.doc(room.id).update(room.afterCheckout().toFirestore());
  }

  // ─── Perpanjang masa menginap ─────────────────────────────────────
  Future<void> extendStay({
    required RoomModel room,
    required DateTime newCheckOut,
    String? note,
  }) async {
    final extendEntry = {
      'extendedAt': Timestamp.fromDate(DateTime.now()),
      'previousCheckOut': room.checkOutTime != null
          ? Timestamp.fromDate(room.checkOutTime!)
          : null,
      'newCheckOut': Timestamp.fromDate(newCheckOut),
      'note': note ?? '',
    };

    final updatedHistory = [...room.extendHistory, extendEntry];

    await _roomsRef.doc(room.id).update({
      'checkOutTime': Timestamp.fromDate(newCheckOut),
      'extendHistory': updatedHistory,
    });
  }

  // ─── Toggle status kebersihan ─────────────────────────────────────
  Future<void> toggleCleanStatus(String roomId, String newStatus) async {
    await _roomsRef.doc(roomId).update({'cleanStatus': newStatus});
  }

  // ─── Toggle status operasional ────────────────────────────────────
  Future<void> toggleRoomStatus(String roomId, String newStatus) async {
    await _roomsRef.doc(roomId).update({'status': newStatus});
  }

  // ─── Ambil satu kamar (one-time) ─────────────────────────────────
  Future<RoomModel?> getRoomById(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return null;
    return RoomModel.fromFirestore(doc);
  }

  // ─── Edit Informasi Tamu ──────────────────────────────────────────
  Future<void> updateGuestInfo(
    String roomId,
    String guestName,
    DateTime checkInTime,
    String? keterangan,
  ) async {
    final roomRef = _roomsRef.doc(roomId);
    await roomRef.update({
      'guestName': guestName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'keterangan': keterangan,
    });
  }
}
