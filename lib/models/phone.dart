enum PhoneStatus { inStock, onService, sold }

class Phone {
  final int? id;
  final String model;
  final String imei;
  final DateTime purchaseDate;
  final double purchasePrice;
  String? notes;
  PhoneStatus status;

  // Sale information
  String? buyerName;
  String? buyerPhone;
  DateTime? saleDate;
  double? salePrice;

  Phone({
    this.id,
    required this.model,
    required this.imei,
    required this.purchaseDate,
    required this.purchasePrice,
    this.notes,
    this.status = PhoneStatus.inStock,
    this.buyerName,
    this.buyerPhone,
    this.saleDate,
    this.salePrice,
  });

  // Calculate profit
  double? getProfit() {
    if (status == PhoneStatus.sold && salePrice != null) {
      return salePrice! - purchasePrice;
    }
    return null;
  }

  // Convert Phone object to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'imei': imei,
      'purchase_date': purchaseDate.millisecondsSinceEpoch,
      'purchase_price': purchasePrice,
      'notes': notes,
      'status': status.index,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'sale_date': saleDate?.millisecondsSinceEpoch,
      'sale_price': salePrice,
    };
  }

  // Create a Phone object from a map (from database)
  factory Phone.fromMap(Map<String, dynamic> map) {
    return Phone(
      id: map['id'],
      model: map['model'],
      imei: map['imei'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchase_date']),
      purchasePrice: map['purchase_price'],
      notes: map['notes'],
      status: PhoneStatus.values[map['status']],
      buyerName: map['buyer_name'],
      buyerPhone: map['buyer_phone'],
      saleDate: map['sale_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sale_date'])
          : null,
      salePrice: map['sale_price'],
    );
  }
}
