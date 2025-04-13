enum PhoneStatus { inStock, onService, sold }

class Phone {
  final int? id;
  final String model;
  final String imei;
  final DateTime purchaseDate;
  final double purchasePrice;
  final String color;
  final String capacity;
  final String sellerName;
  final String sellerPhone;
  String? notes;
  PhoneStatus status;

  // Sale information
  String? buyerName;
  String? buyerPhone;
  DateTime? saleDate;
  double? salePrice;

  // Service information
  String? serviceName;
  String? serviceCenterName;
  String? serviceCenterPhone;
  double? servicePrice;

  Phone({
    this.id,
    required this.model,
    required this.imei,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.color,
    required this.capacity,
    required this.sellerName,
    required this.sellerPhone,
    this.notes,
    this.status = PhoneStatus.inStock,
    this.buyerName,
    this.buyerPhone,
    this.saleDate,
    this.salePrice,
    this.serviceName,
    this.serviceCenterName,
    this.serviceCenterPhone,
    this.servicePrice,
  });

  // Calculate profit properly by using total cost (purchase price + service price)
  double? getProfit() {
    if (status == PhoneStatus.sold && salePrice != null) {
      // Use getTotalCost() instead of just purchasePrice
      return salePrice! - getTotalCost();
    }
    return null;
  }

  // Get total cost (purchase price + service price if any)
  double getTotalCost() {
    return purchasePrice + (servicePrice ?? 0);
  }

  // Convert Phone object to a map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'imei': imei,
      'purchase_date': purchaseDate.millisecondsSinceEpoch,
      'purchase_price': purchasePrice,
      'color': color,
      'capacity': capacity,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'notes': notes,
      'status': status.index,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'sale_date': saleDate?.millisecondsSinceEpoch,
      'sale_price': salePrice,
      'service_name': serviceName,
      'service_center_name': serviceCenterName,
      'service_center_phone': serviceCenterPhone,
      'service_price': servicePrice,
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
      color: map['color'] ?? '',
      capacity: map['capacity'] ?? '',
      sellerName: map['seller_name'] ?? '',
      sellerPhone: map['seller_phone'] ?? '',
      notes: map['notes'],
      status: PhoneStatus.values[map['status']],
      buyerName: map['buyer_name'],
      buyerPhone: map['buyer_phone'],
      saleDate: map['sale_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sale_date'])
          : null,
      salePrice: map['sale_price'],
      serviceName: map['service_name'],
      serviceCenterName: map['service_center_name'],
      serviceCenterPhone: map['service_center_phone'],
      servicePrice: map['service_price'],
    );
  }
}
