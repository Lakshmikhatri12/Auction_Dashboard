import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/models/auction_model.dart';
import 'package:auctify_dashboard/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BidsPage extends StatelessWidget {
  const BidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Live Auction Bidding", style: AppTextStyles.heading),
                  Text(
                    "Manage bidding for English auctions. Monitor activity and winners.",
                    style: AppTextStyles.body.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query for English auctions.
              // Note: Case sensitivity matters in Firestore clauses if exact match.
              // Using whereIn to cover common variations.
              stream: FirebaseFirestore.instance
                  .collection('auctions')
                  .where(
                    'type',
                    whereIn: ['English', 'english', 'English Auction'],
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading auctions: ${snapshot.error}"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Sort locally by createdAt if backend index is missing for filtered query
                final docs = snapshot.data!.docs;
                // docs.sort((a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));

                return _buildAuctionList(context, docs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "No English Auctions Found",
            style: AppTextStyles.heading.copyWith(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionList(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    // Convert to models
    final auctions = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Ensure ID is passed if model expects it
      return AuctionModel.fromFirestore(data, doc.id);
    }).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisExtent: 250,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        return _buildAuctionCard(context, auctions[index]);
      },
    );
  }

  Widget _buildAuctionCard(BuildContext context, AuctionModel auction) {
    final bool isActive = auction.status.toLowerCase() == 'active';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    image: auction.imageUrls.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(auction.imageUrls.first),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: auction.imageUrls.isEmpty
                      ? const Icon(Icons.image, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? "ACTIVE" : "ENDED",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // Bid Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Bid",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "\$${(auction.currentBid ?? auction.startingBid).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.cyan,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Winner",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    _AuctionLeaderDisplay(
                      auctionId: auction.auctionId,
                      winnerId: auction.winnerId,
                      isActive: isActive,
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.history_edu),
                label: const Text("Manage Bidders"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showBidHistory(context, auction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBidHistory(BuildContext context, AuctionModel auction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Bid History: ${auction.title}",
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bids')
                      .where('auctionId', isEqualTo: auction.auctionId)
                      .orderBy('amount', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Fallback for missing index on filtered query
                    if (snapshot.hasError) {
                      return Center(child: Text("Err: ${snapshot.error}"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text("No bids placed for this auction."),
                          ],
                        ),
                      );
                    }

                    final bids = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // Add ID if missing in fromMap
                      return BidModel.fromFirestore(data, doc.id);
                    }).toList();

                    final uniqueBidders = bids
                        .map((b) => b.bidderId)
                        .toSet()
                        .length;

                    return Column(
                      children: [
                        // Analytics Cards
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              _buildStatCard(
                                "Total Bids",
                                "${bids.length}",
                                Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Bidders",
                                "$uniqueBidders",
                                Colors.purple,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                "Highest",
                                "\$${bids.first.amount.toStringAsFixed(0)}",
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        //bidders info
                        // List
                        Expanded(
                          child: ListView.separated(
                            controller:
                                controller, // For draggable sheet scroll
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            itemCount: bids.length,
                            separatorBuilder: (c, i) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final bid = bids[index];
                              final isWinner = index == 0;

                              return _BidderListTile(
                                bid: bid,
                                isWinner: isWinner,
                                onDelete: () => _deleteBid(context, bid.bidId),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> _deleteBid(BuildContext context, String bidId) async {
    try {
      await FirebaseFirestore.instance.collection('bids').doc(bidId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Bid removed")));
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}

class _BidderListTile extends StatelessWidget {
  final BidModel bid;
  final bool isWinner;
  final VoidCallback onDelete;

  const _BidderListTile({
    required this.bid,
    required this.isWinner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(bid.bidderId)
          .get(),
      builder: (context, snapshot) {
        String name = bid.bidderName.isNotEmpty ? bid.bidderName : "Bidder";
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          // Prefer fetched name if available, otherwise fallback
          if (data['name'] != null && data['name'].toString().isNotEmpty) {
            name = data['name'];
          } else if (data['email'] != null) {
            name = data['email'];
          }
          photoUrl = data['profileImageUrl'];
        } else if (name == "Bidder") {
          name = "User: ${bid.bidderId.substring(0, 4)}..";
        }

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: isWinner ? Colors.amber : Colors.grey[200],
            foregroundColor: isWinner ? Colors.white : Colors.grey[700],
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Icon(isWinner ? Icons.emoji_events : Icons.person)
                : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${bid.timestamp.toString().split('.')[0]} • ID: ${bid.bidderId.substring(0, 4)}...",
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "\$${bid.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green : Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BidderInfo extends StatelessWidget {
  final String name;
  final String uid;

  const _BidderInfo({required this.name, required this.uid});

  @override
  Widget build(BuildContext context) {
    if (name.isNotEmpty) {
      return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            "Loading...",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 12,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fetchedName = data['name'] ?? data['email'] ?? 'Unknown User';
          return Text(
            fetchedName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }

        return Text(
          "User: ${uid.substring(0, 5)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

class _AuctionLeaderDisplay extends StatelessWidget {
  final String auctionId;
  final String? winnerId;
  final bool isActive;

  const _AuctionLeaderDisplay({
    required this.auctionId,
    required this.winnerId,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (winnerId != null && winnerId!.isNotEmpty) {
      return _UserFetcher(uid: winnerId!);
    }

    if (isActive) {
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('bids')
            .where('auctionId', isEqualTo: auctionId)
            .orderBy('amount', descending: true)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 60,
              height: 10,
              child: LinearProgressIndicator(minHeight: 2),
            );
          }
          if (snapshot.hasError) {
            return const Text(
              "Err",
              style: TextStyle(color: Colors.red, fontSize: 10),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text(
              "-",
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          }

          final topBid = snapshot.data!.docs.first;
          final data = topBid.data() as Map<String, dynamic>?;
          if (data == null) return const Text("-");

          final bidderId = (data['bidderId'] ?? data['userId'])?.toString();

          if (bidderId == null) {
            return const Text("Unknown");
          }

          return _UserFetcher(uid: bidderId);
        },
      );
    }

    return const Text("None", style: TextStyle(fontWeight: FontWeight.bold));
  }
}

class _UserFetcher extends StatelessWidget {
  final String uid;

  const _UserFetcher({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...", style: TextStyle(fontSize: 10));
        }

        String name = "Unknown";
        String? photoUrl;

        if (snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? data['email'] ?? "User";
          photoUrl = data['profileImageUrl'];
        } else {
          name = "User: ${uid.substring(0, 4)}";
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
