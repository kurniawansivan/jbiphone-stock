import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class StatsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Map<String, dynamic> _dailyStats = {
    'phonesCount': 0,
    'totalProfit': 0.0,
    'totalRevenue': 0.0,
    'totalCost': 0.0,
  };

  Map<String, dynamic> _monthlyStats = {
    'phonesCount': 0,
    'totalProfit': 0.0,
    'totalRevenue': 0.0,
    'totalCost': 0.0,
  };

  Map<String, dynamic> _yearlyStats = {
    'phonesCount': 0,
    'totalProfit': 0.0,
    'totalRevenue': 0.0,
    'totalCost': 0.0,
  };

  Map<String, dynamic> _inventoryStats = {
    'phonesCount': 0,
    'totalCost': 0.0,
  };

  // Getters
  Map<String, dynamic> get dailyStats => _dailyStats;
  Map<String, dynamic> get monthlyStats => _monthlyStats;
  Map<String, dynamic> get yearlyStats => _yearlyStats;
  Map<String, dynamic> get inventoryStats => _inventoryStats;

  // Load daily stats
  Future<void> loadDailyStats(DateTime date) async {
    _dailyStats = await _databaseHelper.getDailyStats(date);
    notifyListeners();
  }

  // Load monthly stats
  Future<void> loadMonthlyStats(int year, int month) async {
    _monthlyStats = await _databaseHelper.getMonthlyStats(year, month);
    notifyListeners();
  }

  // Load yearly stats
  Future<void> loadYearlyStats(int year) async {
    _yearlyStats = await _databaseHelper.getYearlyStats(year);
    notifyListeners();
  }

  // Load inventory stats
  Future<void> loadInventoryStats() async {
    _inventoryStats = await _databaseHelper.getCurrentInventoryStats();
    notifyListeners();
  }

  // Load all stats for current date
  Future<void> loadAllCurrentStats() async {
    final now = DateTime.now();
    await loadDailyStats(now);
    await loadMonthlyStats(now.year, now.month);
    await loadYearlyStats(now.year);
    await loadInventoryStats();
  }
}
