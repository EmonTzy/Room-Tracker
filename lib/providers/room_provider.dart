import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../utils/hotel_date_utils.dart';
import '../utils/constants.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _service = RoomService();

  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<RoomModel>>? _subscription;

  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Analitik ────────────────────────────────────────────────────
  int get occupiedCount => _rooms.where((r) => r.isOccupied).length;

  int get availableCount => _rooms
      .where((r) => !r.isOccupied && r.status == AppConstants.statusAvailable)
      .length;

  int get dirtyCount =>
      _rooms.where((r) => r.cleanStatus == AppConstants.cleanKotor).length;

  int get outOfServiceCount =>
      _rooms.where((r) => r.status == AppConstants.statusOutOfService).length;

  int get totalRooms => _rooms.length;

  /// Kamar Day Use yang check-in hari ini (konteks hotel)
  int get dayUseTodayCount => _rooms
      .where((r) =>
          r.isOccupied &&
          r.isDayUse &&
          r.checkInTime != null &&
          HotelDateUtils.isHotelToday(r.checkInTime!))
      .length;

  /// Kamar terisi yang check-in hari ini (untuk "terjual hari ini" bagian occupied)
  int get occupiedCheckedInTodayCount => _rooms
      .where((r) =>
          r.isOccupied &&
          r.checkInTime != null &&
          HotelDateUtils.isHotelToday(r.checkInTime!))
      .length;

  // ─── Mulai dengarkan stream Firestore ─────────────────────────────
  void initialize() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _service.getRoomsStream().listen(
      (rooms) {
        _rooms = rooms;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ─── CRUD ─────────────────────────────────────────────────────────
  Future<void> addRoom(RoomModel room) async {
    await _service.addRoom(room);
  }

  Future<void> updateRoom(RoomModel room) async {
    await _service.updateRoom(room);
  }

  Future<void> deleteRoom(String roomId) async {
    await _service.deleteRoom(roomId);
  }

  Future<void> checkIn({
    required String roomId,
    required String guestName,
    required DateTime checkInTime,
    String? keterangan,
    int lengthOfStay = 1,
  }) async {
    await _service.checkIn(
      roomId: roomId,
      guestName: guestName,
      checkInTime: checkInTime,
      keterangan: keterangan,
      lengthOfStay: lengthOfStay,
    );
  }

  Future<void> checkOut(RoomModel room) async {
    await _service.checkOut(room);
  }

  Future<void> extendStay({
    required RoomModel room,
    required DateTime newCheckOut,
    String? note,
  }) async {
    await _service.extendStay(
      room: room,
      newCheckOut: newCheckOut,
      note: note,
    );
  }

  Future<void> moveRoom({
    required RoomModel currentRoom,
    required RoomModel targetRoom,
  }) async {
    await _service.moveRoom(
      currentRoom: currentRoom,
      targetRoom: targetRoom,
    );
  }

  Future<void> toggleCleanStatus(String roomId, String newStatus) async {
    await _service.toggleCleanStatus(roomId, newStatus);
  }

  Future<void> toggleRoomStatus(String roomId, String newStatus) async {
    await _service.toggleRoomStatus(roomId, newStatus);
  }

  Future<void> updateGuestInfo(
    String roomId,
    String guestName,
    DateTime checkInTime,
    String? keterangan,
  ) async {
    await _service.updateGuestInfo(roomId, guestName, checkInTime, keterangan);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
