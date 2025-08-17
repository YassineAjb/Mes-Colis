// lib/models/order_model.dart
class Order {
  final int orderId;
  final String? barcode;
  final String? recipientName;
  final String? recipientPhone;
  final String? address;
  final String? status;
  final String? createdAt;
  final String? scheduledDate;
  final double? amount;
  final String? notes;

  Order({
    required this.orderId,
    this.barcode,
    this.recipientName,
    this.recipientPhone,
    this.address,
    this.status,
    this.createdAt,
    this.scheduledDate,
    this.amount,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] ?? 0,
      barcode: json['barcode']?.toString(),
      recipientName: json['recipient_name']?.toString(),
      recipientPhone: json['recipient_phone']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      scheduledDate: json['scheduled_date']?.toString(),
      amount: json['amount']?.toDouble(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'barcode': barcode,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'address': address,
      'status': status,
      'created_at': createdAt,
      'scheduled_date': scheduledDate,
      'amount': amount,
      'notes': notes,
    };
  }
}
