import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/models/dispute_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisputesPage extends StatefulWidget {
  const DisputesPage({super.key});

  @override
  State<DisputesPage> createState() => _DisputesPageState();
}

class _DisputesPageState extends State<DisputesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dispute Resolution Center", style: AppTextStyles.heading),
          const SizedBox(height: 10),
          Text(
            "Handle reported issues and conflicts between buyers and sellers.",
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('disputes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading disputes"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No open disputes"));
                }

                final disputes = snapshot.data!.docs
                    .map(
                      (doc) => DisputeModel.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList();

                return ListView.separated(
                  itemCount: disputes.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final dispute = disputes[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ref: ${dispute.disputeId}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                _buildStatusBadge(dispute.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dispute.reason,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Order ID: ${dispute.orderId}"),
                            Text(
                              "Reporter: ${dispute.reporterId} vs Accused: ${dispute.reportedUserId}",
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    // Navigate to chat logs or show evidence
                                    _showEvidenceDialog(dispute);
                                  },
                                  child: const Text("View Evidence"),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: dispute.status == "open"
                                      ? () => _showResolutionDialog(dispute)
                                      : null,
                                  child: const Text("Resolve Dispute"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "resolved"
        ? Colors.green
        : (status == "open" ? Colors.red : Colors.grey);
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

  void _showEvidenceDialog(DisputeModel dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Evidence"),
        content: dispute.evidenceImageUrls.isEmpty
            ? const Text("No Usage images provided.")
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dispute.evidenceImageUrls.length,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(dispute.evidenceImageUrls[i]),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showResolutionDialog(DisputeModel dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Resolve Dispute"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Choose an outcome:"),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Mark Resolved (Favor Reporter)"),
              subtitle: const Text("Close case & take action"),
              onTap: () {
                _resolveDispute(dispute.disputeId, "resolved");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text("Reject Claim"),
              subtitle: const Text("Mark as Rejected"),
              onTap: () {
                _resolveDispute(dispute.disputeId, "rejected");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolveDispute(String id, String status) async {
    await FirebaseFirestore.instance.collection('disputes').doc(id).update({
      'status': status,
    });
  }
}
