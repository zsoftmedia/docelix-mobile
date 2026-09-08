import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandScreen extends StatefulWidget {
  const LandScreen({super.key});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {

  bool checkLoginProgressbar = false;

  // Bottom navigation selected index
  int _selectedIndex = 0;

  // Bottom navigation pages
  final List<Widget> _pages = [
    /*const Center(
      child: Text(
        "Dashboard",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),*/

    const DashboardScreen(),

    const Center(
      child: Text(
        "Services",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const Center(
      child: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const Center(
      child: Text(
        "Profile",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];

  // Bottom navigation change
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: const Color(0xFF0A2342),
                size: width * 0.065,
              ),

              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: Image.asset(
          'assets/main_logo.png',
          width: width * 0.26,
          height: height * 0.5,
          fit: BoxFit.contain,
        ),

        centerTitle: false,

        actions: [

          IconButton(
            onPressed: () {
              // Notification action
            },

            icon: Icon(
              Icons.notifications_none_rounded,
              color: const Color(0xFF0A2342),
              size: width * 0.065,
            ),
          ),

          SizedBox(width: width * 0.02),
        ],
      ),

      // ============================================================
      // NAVIGATION DRAWER
      // ============================================================
      drawer: Drawer(
        backgroundColor: Colors.white,

        child: SafeArea(
          child: Column(
            children: [

              // ==========================================================
              // DRAWER HEADER
              // ==========================================================
              Container(
                width: double.infinity,

                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: height * 0.025,
                ),

                decoration: const BoxDecoration(
                  color: Color(0xFF063C70),

                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Logo
                    Image.asset(
                      'assets/lightlogo.png',
                      width: width * 0.45,
                      height: height * 0.07,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: height * 0.015),

                    Text(
                      "Welcome back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.055,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: height * 0.005),

                    Text(
                      "Manage your account",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: width * 0.037,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.01),

              // ==========================================================
              // SCROLLABLE MENU
              // ==========================================================
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,

                  children: [

                    _drawerItem(
                      context: context,
                      icon: Icons.home_outlined,
                      title: "Dashboard",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.supervised_user_circle_sharp,
                      title: "Team & Access",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.watch_later_outlined,
                      title: "Activity Log",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.file_copy_outlined,
                      title: "Invoices",
                      onTap: () {

                        Get.toNamed(
                          '/InvoicesScreen',
                          arguments: 'Invoices Screen',);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.dashboard_outlined,
                      title: "Items",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.account_box_outlined,
                      title: "Clients",
                      onTap: () {
                        //Navigator.pop(context);

                        Get.toNamed(
                          '/ClientsScreen',
                          arguments: 'Clients Screen',);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.upcoming_rounded,
                      title: "Incoming",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.star_outline_sharp,
                      title: "Docelix AI",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.mail_outline_outlined,
                      title: "Mail",
                      onTap: () {
                        Navigator.pop(context);

                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),

                    const Divider(
                      indent: 20,
                      endIndent: 20,
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.web_asset_sharp,
                      title: "Assets",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.account_balance,
                      title: "Finance",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.percent,
                      title: "Taxes",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    _drawerItem(
                      context: context,
                      icon: Icons.file_copy_outlined,
                      title: "Reports",
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    // Extra bottom padding
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),

              // ==========================================================
              // LOGOUT - ALWAYS AT BOTTOM
              // ==========================================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),

                child: _drawerItem(
                  context: context,
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);

                    // Logout logic
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),

      // ============================================================
      // BOTTOM NAVIGATION BAR
      // ============================================================
      bottomNavigationBar: Container(
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

        child: BottomNavigationBar(

          currentIndex: _selectedIndex,

          onTap: _onItemTapped,

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          elevation: 0,

          selectedItemColor: const Color(0xFF063C70),

          unselectedItemColor: const Color(0xFF71829A),

          selectedFontSize: 12,

          unselectedFontSize: 12,

          showUnselectedLabels: true,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              activeIcon: Icon(
                Icons.home_rounded,
              ),
              label: "Home",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.miscellaneous_services_outlined,
              ),
              activeIcon: Icon(
                Icons.miscellaneous_services_rounded,
              ),
              label: "Services",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_none_rounded,
              ),
              activeIcon: Icon(
                Icons.notifications_rounded,
              ),
              label: "Notifications",
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline_rounded,
              ),
              activeIcon: Icon(
                Icons.person_rounded,
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // DRAWER ITEM WIDGET
  // ==============================================================

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF344E6F),
    Color textColor = const Color(0xFF172A46),
  }) {

    final width = MediaQuery.of(context).size.width;

    return ListTile(

      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.06,
      ),

      leading: Icon(
        icon,
        color: iconColor,
        size: width * 0.060,
      ),

      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: width * 0.040,
          fontWeight: FontWeight.w500,
        ),
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      onTap: onTap,
    );
  }
}