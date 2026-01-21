import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("User Management", style: AppTextStyles.heading),
          const SizedBox(height: 10),
          Text(
            "Manage user accounts, verification, and roles.",
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
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  final users = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Ensure uid is consistent with doc ID
                    data['uid'] = doc.id;
                    return UserModel.fromMap(data);
                  }).toList();

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
                              "Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Role",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Verified",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Actions",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: users.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundImage:
                                          user.profileImageUrl.isNotEmpty
                                          ? NetworkImage(user.profileImageUrl)
                                          : null,
                                      child: user.profileImageUrl.isEmpty
                                          ? Text(
                                              user.name.isNotEmpty
                                                  ? user.name[0].toUpperCase()
                                                  : "?",
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.role)),
                              DataCell(
                                user.isVerified
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : const Icon(
                                        Icons.cancel,
                                        color: Colors.grey,
                                      ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    if (!user.isVerified)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.verified_user,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () =>
                                            _verifyUser(context, user.uid),
                                        tooltip: "Verify User",
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteUser(context, user.uid),
                                      tooltip: "Ban/Delete User",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
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

  Future<void> _verifyUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isVerified': true,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Verified Successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User Deleted!")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
