import 'package:flutter/foundation.dart';
import '../models/phone.dart';
import '../database/database_helper.dart';

class PhoneProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Phone> _phones = [];
  List<Phone> _inStockPhones = [];
  List<Phone> _onServicePhones = [];
  List<Phone> _soldPhones = [];

  // Getters
  List<Phone> get allPhones => _phones;
  List<Phone> get inStockPhones => _inStockPhones;
  List<Phone> get onServicePhones => _onServicePhones;
  List<Phone> get soldPhones => _soldPhones;

  // Load all phones from the database
  Future<void> loadPhones() async {
    _phones = await _databaseHelper.getAllPhones();
    _filterPhonesByStatus();
    notifyListeners();
  }

  // Filter phones by status
  void _filterPhonesByStatus() {
    _inStockPhones =
        _phones.where((phone) => phone.status == PhoneStatus.inStock).toList();
    _onServicePhones = _phones
        .where((phone) => phone.status == PhoneStatus.onService)
        .toList();
    _soldPhones =
        _phones.where((phone) => phone.status == PhoneStatus.sold).toList();
  }

  // Add a new phone
  Future<void> addPhone(Phone phone) async {
    final id = await _databaseHelper.insertPhone(phone);
    final newPhone = Phone(
      id: id,
      model: phone.model,
      imei: phone.imei,
      purchaseDate: phone.purchaseDate,
      purchasePrice: phone.purchasePrice,
      notes: phone.notes,
      status: phone.status,
    );

    _phones.add(newPhone);
    _filterPhonesByStatus();
    notifyListeners();
  }

  // Update phone status
  Future<void> updatePhoneStatus(int phoneId, PhoneStatus newStatus) async {
    final index = _phones.indexWhere((phone) => phone.id == phoneId);
    if (index != -1) {
      final phone = _phones[index];
      phone.status = newStatus;

      await _databaseHelper.updatePhone(phone);
      _filterPhonesByStatus();
      notifyListeners();
    }
  }

  // Mark a phone as sold
  Future<void> markPhoneAsSold(int phoneId, String buyerName, String buyerPhone,
      DateTime saleDate, double salePrice) async {
    final index = _phones.indexWhere((phone) => phone.id == phoneId);
    if (index != -1) {
      final phone = _phones[index];
      phone.status = PhoneStatus.sold;
      phone.buyerName = buyerName;
      phone.buyerPhone = buyerPhone;
      phone.saleDate = saleDate;
      phone.salePrice = salePrice;

      await _databaseHelper.updatePhone(phone);
      _filterPhonesByStatus();
      notifyListeners();
    }
  }

  // Mark a phone as on service
  Future<void> markPhoneAsOnService(int phoneId) async {
    await updatePhoneStatus(phoneId, PhoneStatus.onService);
  }

  // Mark a phone as in stock
  Future<void> markPhoneAsInStock(int phoneId) async {
    await updatePhoneStatus(phoneId, PhoneStatus.inStock);
  }

  // Update phone details
  Future<void> updatePhone(Phone updatedPhone) async {
    final index = _phones.indexWhere((phone) => phone.id == updatedPhone.id);
    if (index != -1) {
      _phones[index] = updatedPhone;
      await _databaseHelper.updatePhone(updatedPhone);
      _filterPhonesByStatus();
      notifyListeners();
    }
  }

  // Delete a phone
  Future<void> deletePhone(int phoneId) async {
    await _databaseHelper.deletePhone(phoneId);
    _phones.removeWhere((phone) => phone.id == phoneId);
    _filterPhonesByStatus();
    notifyListeners();
  }

  // Get a phone by ID
  Phone? getPhoneById(int id) {
    try {
      return _phones.firstWhere((phone) => phone.id == id);
    } catch (e) {
      return null;
    }
  }
}
