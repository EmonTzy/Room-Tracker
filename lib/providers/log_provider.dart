import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/log_model.dart';
import '../services/log_service.dart';
import '../utils/hotel_date_utils.dart';

enum LogFilter { hariIni, mingguIni, bulanIni, custom }
enum LogFilterField { checkIn, checkOut }

class LogProvider extends ChangeNotifier {
  final LogService _service = LogService();

  List<LogModel> _logs = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<LogModel>>? _subscription;

  LogFilter _currentFilter = LogFilter.hariIni;
  LogFilterField _currentFilterField = LogFilterField.checkIn;
  DateTime? _customStart;
  DateTime? _customEnd;

  List<LogModel> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LogFilter get currentFilter => _currentFilter;
  LogFilterField get currentFilterField => _currentFilterField;
  DateTime? get customStart => _customStart;
  DateTime? get customEnd => _customEnd;

  /// Jumlah log hari ini (untuk analitik "Terjual Hari Ini" dari checkout)
  int get todayLogCount {
    final start = HotelDateUtils.getHotelDayStart(DateTime.now());
    final end = HotelDateUtils.getHotelDayEnd(DateTime.now());
    return _logs.where((l) {
      return !l.checkInTime.isBefore(start) && l.checkInTime.isBefore(end);
    }).length;
  }

  int get todayDayUseLogCount {
    final start = HotelDateUtils.getHotelDayStart(DateTime.now());
    final end = HotelDateUtils.getHotelDayEnd(DateTime.now());
    return _logs.where((l) {
      return l.isDayUse &&
          !l.checkInTime.isBefore(start) &&
          l.checkInTime.isBefore(end);
    }).length;
  }

  // ─── Inisialisasi dengan filter default ──────────────────────────
  void initialize() {
    applyFilter(LogFilter.hariIni);
  }

  // ─── Apply filter dan re-subscribe ───────────────────────────────
  void setFilterField(LogFilterField field) {
    if (_currentFilterField != field) {
      _currentFilterField = field;
      applyFilter(_currentFilter, customStart: _customStart, customEnd: _customEnd);
    }
  }

  void applyFilter(LogFilter filter, {DateTime? customStart, DateTime? customEnd}) {
    _currentFilter = filter;
    if (filter == LogFilter.custom) {
      _customStart = customStart;
      _customEnd = customEnd;
    }

    DateTime? start;
    DateTime? end;

    switch (filter) {
      case LogFilter.hariIni:
        start = HotelDateUtils.getHotelDayStart(DateTime.now());
        end = HotelDateUtils.getHotelDayEnd(DateTime.now());
        break;
      case LogFilter.mingguIni:
        start = HotelDateUtils.getWeekStart();
        end = HotelDateUtils.getHotelDayEnd(DateTime.now());
        break;
      case LogFilter.bulanIni:
        start = HotelDateUtils.getMonthStart();
        end = HotelDateUtils.getHotelDayEnd(DateTime.now());
        break;
      case LogFilter.custom:
        start = customStart;
        end = customEnd?.add(const Duration(hours: 24));
        break;
    }

    _listenToLogs(start: start, end: end);
    notifyListeners();
  }

  void _listenToLogs({DateTime? start, DateTime? end}) {
    _isLoading = true;
    _subscription?.cancel();
    
    final filterFieldString = _currentFilterField == LogFilterField.checkIn 
        ? 'checkInTime' 
        : 'checkOutTime';

    _subscription = _service.getLogsStream(start: start, end: end, filterField: filterFieldString).listen(
      (logs) {
        _logs = logs;
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

  Future<void> updateLog(LogModel log) async {
    await _service.updateLog(log);
  }

  Future<void> deleteLog(String logId) async {
    await _service.deleteLog(logId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
