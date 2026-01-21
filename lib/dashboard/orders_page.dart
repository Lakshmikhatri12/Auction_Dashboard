import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Management", style: AppTextStyles.heading),
          const SizedBox(height: 10),
          Text(
            "Monitor transactions and shipping statuses.",
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Fallback logic for missing index or collection
                  Stream<QuerySnapshot>? stream = FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('createdAt', descending: true)
                      .snapshots();

                  if (snapshot.hasError) {
                    // Attempt without ordering if index is missing
                    // This part is tricky in StreamBuilder directly, but we can just handle the UI error or use a nested approach if we really wanted auto-fallback.
                    // For now, let's assume the index might be missing and just show a message or try simple query.
                    // But actually, simple query is safer first if we are unsure about indexes.
                    return Center(
                      child: Text(
                        "Error loading orders. ensure 'orders' collection exists and 'createdAt' index is built.",
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No orders found"));
                  }

                  return _buildDataTable(snapshot.data!.docs);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<QueryDocumentSnapshot> docs) {
    final orders = docs
        .map(
          (doc) => OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            AppColors.primary.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                "Order ID",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Price",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Buyer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Seller",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Payment",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Status",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Date",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text(order.orderId)),
                DataCell(Text("\$${order.price.toStringAsFixed(2)}")),
                DataCell(Text(order.buyerId)),
                DataCell(Text(order.sellerId)),
                DataCell(
                  _buildStatusBadge(order.paymentStatus, isPayment: true),
                ),
                DataCell(
                  _buildStatusBadge(order.orderStatus, isPayment: false),
                ),
                DataCell(Text(order.createdAt.toString().split(' ')[0])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, {required bool isPayment}) {
    Color color;
    if (isPayment) {
      color = status.toLowerCase() == "paid" ? Colors.green : Colors.orange;
    } else {
      color = status.toLowerCase() == "delivered"
          ? Colors.green
          : (status.toLowerCase() == "shipped" ? Colors.blue : Colors.grey);
    }

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
}
