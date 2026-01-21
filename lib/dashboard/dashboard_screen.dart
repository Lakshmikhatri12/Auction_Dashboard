// import 'package:auctify_dashboard/constants.dart';
// import 'package:auctify_dashboard/dashboard/auctions_page.dart';
// import 'package:auctify_dashboard/dashboard/bids_page.dart';
// import 'package:auctify_dashboard/dashboard/disputes_page.dart';
// import 'package:auctify_dashboard/dashboard/users_page.dart';
// import 'package:flutter/material.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int selectedIndex = 0;

//   final pages = [
//     const UsersPage(),
//     const AuctionsPage(),
//     const BidsPage(),
//     // const OrdersPage(),
//     const DisputesPage(),
//   ];

//   final pageTitles = ["Users", "Auctions", "Bids", "Disputes"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 250,
//             color: AppColors.primary,
//             child: Column(
//               children: [
//                 const SizedBox(height: 50),
//                 const Text(
//                   "Auctify Admin",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 navItem("Users", 0),
//                 navItem("Auctions", 1),
//                 navItem("Bids", 2),
//                 //navItem("Orders", 3),
//                 navItem("Disputes", 3),
//               ],
//             ),
//           ),

//           // Main Content
//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   height: 60,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   color: AppColors.cardBg,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     pageTitles[selectedIndex],
//                     style: AppTextStyles.heading,
//                   ),
//                 ),
//                 Expanded(child: pages[selectedIndex]),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget navItem(String title, int index) {
//     return InkWell(
//       onTap: () => setState(() => selectedIndex = index),
//       child: Container(
//         color: selectedIndex == index
//             ? AppColors.secondary
//             : Colors.transparent,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         child: Text(
//           title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:auctify_dashboard/constants.dart';
import 'package:auctify_dashboard/dashboard/auctions_page.dart';
import 'package:auctify_dashboard/dashboard/bids_page.dart';
import 'package:auctify_dashboard/dashboard/disputes_page.dart';
import 'package:auctify_dashboard/dashboard/orders_page.dart';
import 'package:auctify_dashboard/dashboard/users_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  // Define pages and their metadata together to keep things in sync
  final List<_NavItem> _navItems = [
    _NavItem(
      title: "Users",
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt,
      page: const UsersPage(),
    ),
    _NavItem(
      title: "Auctions",
      icon: Icons.gavel_outlined,
      selectedIcon: Icons.gavel_rounded,
      page: const AuctionsPage(),
    ),
    _NavItem(
      title: "Bids",
      icon: Icons.monetization_on_outlined,
      selectedIcon: Icons.monetization_on,
      page: const BidsPage(),
    ),
    _NavItem(
      title: "Orders",
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag,
      page: const OrdersPage(),
    ),
    _NavItem(
      title: "Disputes",
      icon: Icons.warning_amber_rounded,
      selectedIcon: Icons.warning_rounded,
      page: const DisputesPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Row(
        children: [
          // ================== SIDEBAR ==================
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Brand Logo Area
                Container(
                  height: 100,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_moon,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Auctify",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _navItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => selectedIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (isSelected) ...[
                                const Spacer(),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Admin Profile / Logout Area
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Admin User",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "admin@auctify.com",
                              style: GoogleFonts.inter(
                                color: AppColors.textLight,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Logout logic
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================== MAIN CONTENT ==================
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _navItems[selectedIndex].title,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "Overview and management",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Page Content with Transition
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey<int>(selectedIndex),
                      child: _navItems[selectedIndex].page,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  _NavItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}
