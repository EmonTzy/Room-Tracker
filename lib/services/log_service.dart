import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/log_model.dart';
import '../utils/constants.dart';

class LogService {
  final _db = FirebaseFirestore.instance;
  
  CollectionReference get _logsRef => _db.collection(AppConstants.collectionLogs);

  // ─── Stream log dengan filter tanggal ────────────────────────────
  Stream<List<LogModel>> getLogsStream({DateTime? start, DateTime? end}) {
    Query query = _logsRef.orderBy('checkInTime', descending: true);

    if (start != null) {
      query = query.where(
        'checkInTime',
        isGreaterThanOrEqualTo: Timestamp.fromDate(start),
      );
    }
    if (end != null) {
      query = query.where(
        'checkInTime',
        isLessThan: Timestamp.fromDate(end),
      );
    }

    return query.snapshots().map(
      (snap) => snap.docs.map(LogModel.fromFirestore).toList(),
    );
  }

  // ─── Stream semua log (tanpa filter) ─────────────────────────────
  Stream<List<LogModel>> getAllLogsStream() {
    return _logsRef
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(LogModel.fromFirestore).toList());
  }

  // ─── Tambah log manual ────────────────────────────────────────────
  Future<void> addLog(LogModel log) async {
    await _logsRef.add(log.toFirestore());
  }

  // ─── Edit log ─────────────────────────────────────────────────────
  Future<void> updateLog(LogModel log) async {
    await _logsRef.doc(log.id).update(log.toFirestore());
  }

  // ─── Hapus log ────────────────────────────────────────────────────
  Future<void> deleteLog(String logId) async {
    await _logsRef.doc(logId).delete();
  }

  // ─── Hitung log hari ini (untuk analitik "Terjual") ──────────────
  Future<int> countTodayLogs(DateTime hotelDayStart, DateTime hotelDayEnd) async {
    final snap = await _logsRef
        .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(hotelDayStart))
        .where('checkInTime', isLessThan: Timestamp.fromDate(hotelDayEnd))
        .count()
        .get();
    return snap.count ?? 0;
  }
}
