import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/models/auction_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionsPage extends StatelessWidget {
  const AuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Auction Listings", style: AppTextStyles.heading),
          const SizedBox(height: 10),
          Text(
            "Monitor active, completed, and pending auctions.",
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('auctions')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No auctions found"),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Seed Dummy Auction"),
                            onPressed: () => _seedDummyAuction(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // horizontal scroll
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // vertical scroll
                      child: _buildDataTable(snapshot.data!.docs),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<QueryDocumentSnapshot> docs) {
    final auctions = docs
        .map(
          (doc) => AuctionModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();

    return DataTable(
      headingRowColor: MaterialStateProperty.all(
        AppColors.primary.withOpacity(0.1),
      ),
      columns: const [
        DataColumn(
          label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Seller", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            "End Time",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: auctions.map((auction) {
        return DataRow(
          cells: [
            // Title with image
            DataCell(
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: auction.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(auction.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(auction.title, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),

            // Seller
            DataCell(
              Text(
                auction.sellerName.isNotEmpty
                    ? auction.sellerName
                    : auction.sellerId,
              ),
            ),

            // Current Bid
            DataCell(
              Text(
                "\$${(auction.currentBid ?? auction.startingBid).toStringAsFixed(2)}",
              ),
            ),

            // Type
            DataCell(Text(auction.type)),

            // Status
            DataCell(_buildStatusBadge(auction.status)),

            // End Time
            DataCell(Text(auction.endTime.toDate().toString().split(' ')[0])),

            // Actions
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAuction(auction.auctionId),
                    tooltip: "Delete Auction",
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "active"
        ? Colors.green
        : (status == "completed" ? Colors.blue : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _deleteAuction(String auctionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(auctionId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting auction: $e");
    }
  }

  Future<void> _seedDummyAuction(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('auctions').add({
        'title': 'Vintage Rolex Watch',
        'description': 'A beautiful vintage watch in excellent condition.',
        'sellerId': 'dummy_seller',
        'sellerName': 'John Doe',
        'type': 'English',
        'startingBid': 500.0,
        'currentBid': 500.0,
        'bidIncrement': 50.0,
        'status': 'active',
        'imageUrls': ['https://via.placeholder.com/150'],
        'startTime': Timestamp.now(),
        'endTime': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'createdAt': Timestamp.now(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Dummy Auction Created!")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
