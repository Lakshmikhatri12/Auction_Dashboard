import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String auctionId;
  final String buyerId;
  final String sellerId;
  final double price;
  final String paymentStatus; // paid, pending
  final String orderStatus; // placed, shipped, delivered
  final DateTime createdAt;
  final Map<String, dynamic> shippingAddress;

  OrderModel({
    required this.orderId,
    required this.auctionId,
    required this.buyerId,
    required this.sellerId,
    required this.price,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
    required this.shippingAddress,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return OrderModel(
      orderId: id,
      auctionId: map['auctionId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      orderStatus: map['orderStatus'] ?? 'placed',
      createdAt: parseDate(map['createdAt']),
      shippingAddress: Map<String, dynamic>.from(map['shippingAddress'] ?? {}),
    );
  }
}
