// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuctionModel {
//   String auctionId;
//   String category;
//   String title;
//   String description;
//   String sellerId;
//   String sellerName; //////////////////
//   String type; // 'english' | 'fixed'
//   double startingBid;
//   double? currentBid;
//   double? bidIncrement;
//   int? quantity;
//   List<String> imageUrls;
//   int? durationHours;
//   String status;
//   String location;
//   DateTime startTime;
//   DateTime endTime;

//   String? winnerId;
//   String? paymentStatus; // pending | paid
//   Timestamp? soldAt;
//   Timestamp? paidAt;

//   AuctionModel({
//     required this.auctionId,
//     required this.category,
//     required this.title,
//     required this.description,
//     required this.sellerId,
//     required this.sellerName, ///////////////
//     required this.type,
//     required this.startingBid,
//     this.currentBid,
//     this.bidIncrement,
//     this.quantity,
//     required this.imageUrls,
//     this.durationHours,
//     this.status = 'active',
//     required this.location,
//     required this.startTime,
//     required this.endTime,
//     this.winnerId,
//     this.paymentStatus,
//     this.soldAt,
//     this.paidAt,
//   });

//   Map<String, dynamic> toMap() => {
//     'auctionId': auctionId,
//     'category': category,
//     'title': title,
//     'description': description,
//     'sellerId': sellerId,
//     'sellerName': sellerName,
//     'type': type,
//     'startingBid': startingBid,
//     'currentBid': currentBid,
//     'bidIncrement': bidIncrement,
//     'quantity': quantity,
//     'imageUrls': imageUrls,
//     'durationHours': durationHours,
//     'status': status,
//     'location': location,
//     'startTime': startTime.toIso8601String(),
//     'endTime': endTime.toIso8601String(),
//     'winnerId': winnerId,
//     'paymentStatus': paymentStatus,
//     'soldAt': soldAt,
//     'paidAt': paidAt,
//   };

//   factory AuctionModel.fromFirestore(Map<String, dynamic> data, String id) =>
//       AuctionModel(
//         auctionId: data['auctionId'] ?? id,
//         category: data['category'] ?? 'Others',
//         title: data['title'] ?? '',
//         description: data['description'] ?? '',
//         sellerId: data['sellerId'] ?? '',
//         sellerName: data['sellerName'] ?? '', // ✅ read name
//         type: data['type'] ?? 'fixed',
//         startingBid: (data['startingBid'] as num?)?.toDouble() ?? 0,
//         currentBid: data['currentBid'] != null
//             ? (data['currentBid'] as num).toDouble()
//             : null,
//         bidIncrement: data['bidIncrement'] != null
//             ? (data['bidIncrement'] as num).toDouble()
//             : null,
//         quantity: data['quantity'],
//         imageUrls: List<String>.from(data['imageUrls'] ?? []),
//         durationHours: data['durationHours'],
//         status: data['status'] ?? 'active',
//         location: data['location'] ?? '',
//         startTime: DateTime.parse(
//           data['startTime'] ?? DateTime.now().toIso8601String(),
//         ),
//         endTime: DateTime.parse(
//           data['endTime'] ?? DateTime.now().toIso8601String(),
//         ),
//         winnerId: data['winnerId'],
//         paymentStatus: data['paymentStatus'],
//         soldAt: data['soldAt'],
//         paidAt: data['paidAt'],
//       );
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionModel {
  String auctionId;
  String category;
  String title;
  String description;
  String sellerId;
  String sellerName;
  String type; // 'english' | 'fixed'
  double startingBid;
  double? currentBid;
  double? bidIncrement;
  int? quantity;
  List<String> imageUrls;
  int? durationHours;
  String status;
  String location;
  Timestamp startTime; // ✅ use Timestamp
  Timestamp endTime; // ✅ use Timestamp

  String? winnerId;
  String? paymentStatus; // pending | paid
  Timestamp? soldAt;
  Timestamp? paidAt;

  AuctionModel({
    required this.auctionId,
    required this.category,
    required this.title,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    required this.type,
    required this.startingBid,
    this.currentBid,
    this.bidIncrement,
    this.quantity,
    required this.imageUrls,
    this.durationHours,
    this.status = 'active',
    required this.location,
    required this.startTime,
    required this.endTime,
    this.winnerId,
    this.paymentStatus,
    this.soldAt,
    this.paidAt,
  });

  Map<String, dynamic> toMap() => {
    'auctionId': auctionId,
    'category': category,
    'title': title,
    'description': description,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'type': type,
    'startingBid': startingBid,
    'currentBid': currentBid,
    'bidIncrement': bidIncrement,
    'quantity': quantity,
    'imageUrls': imageUrls,
    'durationHours': durationHours,
    'status': status,
    'location': location,
    'startTime': startTime, // ✅ store as Timestamp
    'endTime': endTime, // ✅ store as Timestamp
    'winnerId': winnerId,
    'paymentStatus': paymentStatus,
    'soldAt': soldAt,
    'paidAt': paidAt,
  };

  factory AuctionModel.fromFirestore(Map<String, dynamic> data, String id) {
    Timestamp? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value;
      if (value is String) return Timestamp.fromDate(DateTime.parse(value));
      return null;
    }

    return AuctionModel(
      auctionId: data['auctionId'] ?? id,
      category: data['category'] ?? 'Others',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      type: data['type'] ?? 'fixed',
      startingBid: (data['startingBid'] as num?)?.toDouble() ?? 0,
      currentBid: (data['currentBid'] as num?)?.toDouble(),
      bidIncrement: (data['bidIncrement'] as num?)?.toDouble(),
      quantity: data['quantity'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      durationHours: data['durationHours'],
      status: data['status'] ?? 'active',
      location: data['location'] ?? '',
      startTime: parseTimestamp(data['startTime']) ?? Timestamp.now(),
      endTime: parseTimestamp(data['endTime']) ?? Timestamp.now(),
      winnerId: data['winnerId'],
      paymentStatus: data['paymentStatus'],
      soldAt: parseTimestamp(data['soldAt']),
      paidAt: parseTimestamp(data['paidAt']),
    );
  }
}
