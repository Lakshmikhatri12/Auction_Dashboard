import 'package:cloud_firestore/cloud_firestore.dart';

class DisputeModel {
  final String disputeId;
  final String orderId;
  final String reporterId;
  final String reportedUserId;
  final String reason;
  final String status; // open, resolved, rejected
  final DateTime createdAt;
  final List<String> evidenceImageUrls;

  DisputeModel({
    required this.disputeId,
    required this.orderId,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.evidenceImageUrls = const [],
  });

  factory DisputeModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return DisputeModel(
      disputeId: id,
      orderId: map['orderId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      reason: map['reason'] ?? 'Unknown Issue',
      status: map['status'] ?? 'open',
      createdAt: parseDate(map['createdAt']),
      evidenceImageUrls: List<String>.from(map['evidenceImageUrls'] ?? []),
    );
  }
}
