import 'package:cloud_firestore/cloud_firestore.dart';

class BidModel {
  final String bidId;
  final String auctionId;
  final String bidderId;
  // Optional: denormalized data for display efficiency
  final String bidderName;
  final String auctionTitle;

  final double amount;
  final DateTime timestamp;

  BidModel({
    required this.bidId,
    required this.auctionId,
    required this.bidderId,
    this.bidderName = '',
    this.auctionTitle = '',
    required this.amount,
    required this.timestamp,
  });

  factory BidModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return BidModel(
      bidId: id,
      auctionId: map['auctionId'] ?? '',
      bidderId: map['bidderId'] ?? map['userId'] ?? '', // Fallback
      bidderName: map['bidderName'] ?? map['userName'] ?? '',
      auctionTitle: map['auctionTitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      timestamp: parseDate(map['createdAt'] ?? map['timestamp']),
    );
  }
}
