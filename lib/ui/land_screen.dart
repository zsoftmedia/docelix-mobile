import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/profile_controller.dart';
import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
import 'package:docelix_mobileapp/ui/profile_screen.dart';
import 'package:docelix_mobileapp/ui/scan_qr_screen.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandScreen extends StatefulWidget {
  const LandScreen({super.key});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  bool checkLoginProgressbar = false;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  int _selectedIndex = 0;

  // Main bottom navigation pages
  final List<Widget> _pages = [
    const DashboardScreen(),

    const SizedBox(),

    const SizedBox(),

    const Center(
      child: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const SizedBox(),
  ];

  // ============================================================
  // BOTTOM NAVIGATION CHANGE
  // ============================================================

  void _onItemTapped(int index) {
    // MORE
    if (index == 4) {
      _showMoreMenu();
      return;
    }

    // INVOICES
    if (index == 1) {
      Get.toNamed(
        '/InvoicesScreen',
        arguments: 'Invoices Screen',
      );
      return;
    }

    // SCAN
    if (index == 2) {
      _openScan();
      return;
    }

    // ============================================================
    // INCOMING INVOICES
    // ============================================================

    if (index == 3) {
      Get.toNamed(
        '/IncomingInvoicesScreen',
        arguments: 'Incoming Invoices Screen',
      );

      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // SCAN
  // ============================================================

  void _openScan() async {
    final result = await Get.to(
          () => const ScanQrScreen(),
    );

    if (result == null) {
      return;
    }

    final qrData = result.toString();

    debugPrint("QR DATA: $qrData");

    AppSnackbar.success(
      title: "QR Code Scanned",
      message: qrData,
    );
  }

  // ============================================================
  // MORE MENU
  // ============================================================

  void _showMoreMenu() {
    final width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              width * 0.05,
              width * 0.025,
              width * 0.05,
              width * 0.04,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // HANDLE
                // ------------------------------------------------

                Container(
                  width: width * 0.10,
                  height: 4,
                  margin: EdgeInsets.only(
                    bottom: width * 0.035,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DDE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "More",
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorsList.secondaryText,
                        size: width * 0.055,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: width * 0.015),

                // ------------------------------------------------
                // EXTRA MENU
                // ------------------------------------------------

                _moreMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: "Items",
                  subtitle: "Manage your products and services",
                  iconColor: colorsList.blue,
                  onTap: () {
                    Navigator.pop(context);

                    Get.toNamed(
                      '/CatalogsScreen',
                      arguments: 'Catalogs Screen',
                    );
                  },
                ),

                _moreMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: "Clients",
                  subtitle: "Manage your clients",
                  iconColor: colorsList.green,
                  onTap: () {
                    Navigator.pop(context);

                    Get.toNamed(
                      '/ClientsScreen',
                      arguments: 'Clients Screen',
                    );
                  },
                ),

                _moreMenuItem(
                  icon: Icons.factory_outlined,
                  title: "Company",
                  subtitle: "Manage company information",
                  iconColor: colorsList.cyan,
                  onTap: () {
                    Navigator.pop(context);

                    AppSnackbar.info(
                      title: 'Company',
                      message: 'Company management coming soon',
                    );
                  },
                ),


                _moreMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: "Profile",
                  subtitle: "Manage your profile",
                  iconColor: colorsList.cyan,
                  onTap: () {

                    Get.toNamed(
                      '/ProfileScreen',
                      arguments: 'Profile Screen',
                    );

                    /*GetPage(
                      name: '/ProfileScreen',
                      page: () => const ProfileScreen(),
                      binding: BindingsBuilder(() {
                        Get.lazyPut<ProfileController>(
                              () => ProfileController(),
                        );
                      }),
                    );*/

                    /*AppSnackbar.info(
                      title: 'Profile',
                      message: 'Profile management coming soon',
                    );*/
                  },
                ),

                SizedBox(height: width * 0.015),

                Divider(
                  color: colorsList.borderColor,
                  height: 1,
                ),

                SizedBox(height: width * 0.015),

                // ------------------------------------------------
                // LOGOUT
                // ------------------------------------------------

                _moreMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  subtitle: "Sign out from your account",
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);

                    _logout();
                  },
                ),

                SizedBox(height: width * 0.015),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MORE MENU ITEM
  // ============================================================

  Widget _moreMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width * 0.025,
          ),
          child: Row(
            children: [
              // ------------------------------------------------
              // ICON
              // ------------------------------------------------

              Container(
                width: width * 0.105,
                height: width * 0.105,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.050,
                ),
              ),

              SizedBox(width: width * 0.030),

              // ------------------------------------------------
              // TEXT
              // ------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color:
                        textColor ?? colorsList.primaryText,
                        fontSize: width * 0.031,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: width * 0.006),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.022,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: width * 0.050,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void _logout() {
    // Put your existing logout logic here.

    AppSnackbar.info(
      title: 'Logout',
      message: 'Logout functionality',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      /*appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // ----------------------------------------------------------
        // NO DRAWER / NO HAMBURGER
        // ----------------------------------------------------------

        automaticallyImplyLeading: false,

        title: Text(
          '${SessionManager.accessCompanyname}',
          style: TextStyle(
            color: colorsList.colorGray_800,
            fontSize: width * 0.050,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: false,

        actions: [
          IconButton(
            onPressed: () {
              AppSnackbar.info(
                title: 'Coming Soon',
                message: 'List of Companies',
              );
            },
            icon: Icon(
              Icons.factory_outlined,
              color: const Color(0xFF0A2342),
              size: width * 0.060,
            ),
          ),

          SizedBox(
            width: width * 0.015,
          ),
        ],
      ),*/

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: _pages[_selectedIndex],
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================

      bottomNavigationBar: _buildBottomNavigation(
        width: width,
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation({
    required double width,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: width * 0.18,
          child: Row(
            children: [
              // ==================================================
              // HOME
              // ==================================================

              Expanded(
                child: _bottomNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: "Home",
                ),
              ),

              // ==================================================
              // INVOICES
              // ==================================================

              Expanded(
                child: _bottomNavItem(
                  index: 1,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: "Invoices",
                ),
              ),

              // ==================================================
              // SCAN - CENTER BUTTON
              // ==================================================

              Expanded(
                child: _scanBottomButton(),
              ),

              // ==================================================
              // NOTIFICATIONS
              // ==================================================

              Expanded(
                child: _bottomNavItem(
                  index: 3,
                  icon: Icons.upcoming_outlined,
                  activeIcon: Icons.upcoming_rounded,
                  label: "Incoming",
                  showBadge: true,
                ),
              ),

              // ==================================================
              // MORE
              // ==================================================

              Expanded(
                child: _bottomNavItem(
                  index: 4,
                  icon: Icons.more_horiz_rounded,
                  activeIcon: Icons.more_horiz_rounded,
                  label: "More",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL BOTTOM NAV ITEM
  // ============================================================

  Widget _bottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool showBadge = false,
  }) {
    final width = MediaQuery.of(context).size.width;

    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        _onItemTapped(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? colorsList.green
                    : const Color(0xFF71829A),
                size: width * 0.060,
              ),

              if (showBadge)
                Positioned(
                  right: -width * 0.010,
                  top: -width * 0.015,
                  child: Container(
                    width: width * 0.038,
                    height: width * 0.038,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorsList.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.018,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(
            height: width * 0.008,
          ),

          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorsList.green
                  : const Color(0xFF71829A),
              fontSize: width * 0.022,
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),

          if (isSelected)
            Container(
              margin: EdgeInsets.only(
                top: width * 0.008,
              ),
              width: width * 0.065,
              height: 2,
              decoration: BoxDecoration(
                color: colorsList.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // CENTER SCAN BUTTON
  // ============================================================

  Widget _scanBottomButton() {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: _openScan,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.125,
            height: width * 0.125,
            transform: Matrix4.translationValues(
              0,
              -width * 0.035,
              0,
            ),
            decoration: BoxDecoration(
              color: colorsList.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorsList.green.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              color: Colors.white,
              size: width * 0.060,
            ),
          ),

          Transform.translate(
            offset: Offset(
              0,
              -width * 0.030,
            ),
            child: Text(
              "Scan",
              style: TextStyle(
                color: const Color(0xFF71829A),
                fontSize: width * 0.022,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}