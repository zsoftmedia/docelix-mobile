import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_controller.dart';
import 'package:docelix_mobileapp/controllers/profile_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/ui/dashboard_screen.dart';
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
  final CreatePurchaseInvoiceController incomingInvoiceController = Get.put(
    CreatePurchaseInvoiceController(),
  );

  int _selectedIndex = 0;
  bool _assetsExpanded = false;
  bool _inventoryExpanded = false;

  final List<Widget> _pages = const [
    DashboardScreen(),
    SizedBox.shrink(),
    SizedBox.shrink(),
    SizedBox.shrink(),
    SizedBox.shrink(),
  ];

  void _onItemTapped(int index) {
    switch (index) {
      case 1:
        _showSalesMenu();
        return;
      case 2:
        _openScan();
        return;
      case 3:
        _showPurchaseMenu();

        return;
      case 4:
        _showMoreMenu();
        return;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  void _showSalesMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (sheetContext) {
        final width = MediaQuery.of(sheetContext).size.width;
        final bottomInset = MediaQuery.of(sheetContext).padding.bottom;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            width * 0.05,
            width * 0.03,
            width * 0.05,
            width * 0.045 + bottomInset,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DDE5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: width * 0.035),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sales',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.048,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.secondaryText,
                      size: width * 0.055,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.01),
              _MoreMenuItem(
                icon: Icons.receipt_long_rounded,
                title: 'Invoices',
                subtitle: 'View and manage all sales invoices',
                iconColor: colorsList.blue,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed('/InvoicesScreen');
                },
              ),
              _MoreMenuItem(
                icon: Icons.request_quote_outlined,
                title: 'Quotation',
                subtitle: 'Create and manage sales quotes & offers',
                iconColor: colorsList.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed('/QuotationScreen');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPurchaseMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (sheetContext) {
        final width = MediaQuery.of(sheetContext).size.width;
        final bottomInset = MediaQuery.of(sheetContext).padding.bottom;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            width * 0.05,
            width * 0.03,
            width * 0.05,
            width * 0.045 + bottomInset,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DDE5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: width * 0.035),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Purchases',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.048,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.secondaryText,
                      size: width * 0.055,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.01),
              _MoreMenuItem(
                icon: Icons.request_quote_outlined,
                title: 'Purchase Invoices',
                subtitle: 'Upload and manage supplier invoices, receipts, and credit notes.',
                iconColor: colorsList.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed('/IncomingInvoicesScreen');

                },
              ),
              _MoreMenuItem(
                icon: Icons.request_quote_outlined,
                title: 'Suppliers',
                subtitle: 'Who you buy from, what you have purchased and what is still open.',
                iconColor: colorsList.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed('/SuppliersScreen');
                },
              ),

              /*_MoreMenuItem(
                icon: Icons.inventory_2_rounded,
                title: 'Invoice Archive',
                subtitle: 'View and manage all incoming invoices',
                iconColor: colorsList.blue,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed('/InvoiceArchiveScreen');
                },
              ),

              _MoreMenuItem(
                icon: Icons.request_quote_outlined,
                title: 'Quotation',
                subtitle: 'Create and manage sales quotes & offers',
                iconColor: colorsList.orange,
                onTap: () {
                  Navigator.pop(sheetContext);
                  AppSnackbar.info(
                    title: 'Coming Soon',
                    message: 'Quotation feature is coming soon.',
                  );
                },
              ),*/

            ],
          ),
        );
      },
    );
  }

  Future<void> _openScan() async {
    final result = await Get.to(() => const ScanQrScreen());
    if (result == null) return;

    AppSnackbar.success(title: 'QR Code Scanned', message: result.toString());
  }

  Future<void> _logout() async {
    await SessionManager.logout();
  }

  void _openAssetRoute(String route) {
    Navigator.pop(context);
    Get.toNamed(route);
  }

  void _showMoreMenu() {
    _assetsExpanded = false;
    _inventoryExpanded = false;

    ProfileController? profileController;
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    } else {
      try {
        profileController = Get.put(ProfileController());
      } catch (_) {}
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final rs = context.rs;
            final bottomInset = MediaQuery.of(context).padding.bottom;

            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: rs.sheetMaxWidth,
                  maxHeight: rs.height * 0.90,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7DDE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            rs.s(16),
                            rs.s(4),
                            rs.s(16),
                            rs.s(20) + bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. User Profile Header Card
                              Obx(() {
                                final name = profileController
                                                ?.profileName.value.isNotEmpty ==
                                            true
                                    ? profileController!.profileName.value
                                    : (SessionManager.username?.isNotEmpty ==
                                            true
                                        ? SessionManager.username!
                                        : 'Anees Irshad');

                                final email = profileController
                                                ?.profileEmail.value.isNotEmpty ==
                                            true
                                    ? profileController!.profileEmail.value
                                    : (SessionManager.email?.isNotEmpty == true
                                        ? SessionManager.email!
                                        : 'anees.irshad@berrinex.com');

                                final plan =
                                    profileController?.profilePlan.value ??
                                        'Standard Plan';
                                final imageUrl =
                                    profileController?.profileImageUrl.value ??
                                        '';

                                return _UserProfileCard(
                                  name: name,
                                  email: email,
                                  plan: plan,
                                  imageUrl: imageUrl,
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.toNamed('/ProfileScreen');
                                  },
                                );
                              }),

                              SizedBox(height: rs.s(16)),

                              // 2. Section: BUSINESS OPERATIONS
                              const _MoreSectionHeader(
                                  title: 'BUSINESS OPERATIONS'),
                              _MoreGroupCard(
                                children: [
                                  // Inventory
                                  _MoreMenuItem(
                                    icon: Icons.grid_view_rounded,
                                    title: 'Inventory',
                                    subtitle:
                                        'Stock addition, adjustments & reports',
                                    iconBgColor: const Color(0xFFE0F2FE),
                                    iconColor: const Color(0xFF0284C7),
                                    isTop: true,
                                    trailing: AnimatedRotation(
                                      turns: _inventoryExpanded ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 220),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 24,
                                      ),
                                    ),
                                    onTap: () {
                                      setSheetState(() {
                                        _inventoryExpanded =
                                            !_inventoryExpanded;
                                      });
                                    },
                                  ),
                                  _ExpandableSubMenu(
                                    expanded: _inventoryExpanded,
                                    items: [
                                      _SubMenuItem(
                                        icon: Icons.add_box_outlined,
                                        title: 'Products',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.toNamed('/CatalogsScreen');
                                        },
                                      ),
                                      _SubMenuItem(
                                        icon: Icons.tune_rounded,
                                        title: 'Stock Adjustment',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.toNamed('/StockAdjustmentScreen');
                                        },
                                      ),
                                      _SubMenuItem(
                                        icon: Icons.assessment_outlined,
                                        title: 'Stock Reports',
                                        onTap: () {
                                          Navigator.pop(context);
                                          Get.toNamed('/StockReportScreen');
                                        },
                                      ),
                                    ],
                                  ),

                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9)),

                                  // Customers
                                  _MoreMenuItem(
                                    icon: Icons.people_rounded,
                                    title: 'Customers',
                                    subtitle: 'Manage your customers',
                                    iconBgColor: const Color(0xFFDCFCE7),
                                    iconColor: const Color(0xFF16A34A),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.toNamed('/CustomersScreen');
                                    },
                                  ),

                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9)),

                                  // Assets
                                  _MoreMenuItem(
                                    icon: Icons.verified_outlined,
                                    title: 'Assets',
                                    subtitle:
                                        'Fixed assets, inventory & vehicles',
                                    iconBgColor: const Color(0xFFF3E8FF),
                                    iconColor: const Color(0xFF7C3AED),
                                    isBottom: !_assetsExpanded,
                                    trailing: AnimatedRotation(
                                      turns: _assetsExpanded ? 0.5 : 0,
                                      duration:
                                          const Duration(milliseconds: 220),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 24,
                                      ),
                                    ),
                                    onTap: () {
                                      setSheetState(() {
                                        _assetsExpanded = !_assetsExpanded;
                                      });
                                    },
                                  ),
                                  _ExpandableSubMenu(
                                    expanded: _assetsExpanded,
                                    items: [
                                      _SubMenuItem(
                                        icon: Icons.computer_rounded,
                                        title: 'Fixed Assets',
                                        onTap: () => _openAssetRoute(
                                            '/FixedAssetsScreen'),
                                      ),
                                      _SubMenuItem(
                                        icon: Icons.directions_car_outlined,
                                        title: 'Vehicles & Logbook',
                                        onTap: () => _openAssetRoute(
                                            '/VehiclesLogbookScreen'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: rs.s(16)),

                              // 3. Section: ACCOUNT & PREFERENCES
                              const _MoreSectionHeader(
                                  title: 'ACCOUNT & PREFERENCES'),
                              _MoreGroupCard(
                                children: [
                                  // Profile
                                  _MoreMenuItem(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Profile',
                                    subtitle: 'Manage your profile',
                                    iconBgColor: const Color(0xFFE0F2FE),
                                    iconColor: const Color(0xFF0284C7),
                                    isTop: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.toNamed('/ProfileScreen');
                                    },
                                  ),

                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: Color(0xFFF1F5F9)),

                                  // Settings & Security
                                  _MoreMenuItem(
                                    icon: Icons.settings_outlined,
                                    title: 'Settings & Security',
                                    subtitle:
                                        'App preferences, currency & security',
                                    iconBgColor: const Color(0xFFF1F5F9),
                                    iconColor: const Color(0xFF475569),
                                    isBottom: true,
                                    onTap: () {
                                      Navigator.pop(context);
                                      Get.toNamed('/ProfileScreen');
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: rs.s(14)),

                              // 4. Logout Card
                              _LogoutCard(
                                onTap: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                              ),

                              SizedBox(height: rs.s(20)),

                              // 5. Footer Info
                              const _MoreFooter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_selectedIndex],
            Obx(() {
              if (!incomingInvoiceController.isLoading.value) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: colorsList.colorButton,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Uploading invoice...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorsList.textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please wait a moment',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorsList.textHintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final rs = context.rs;
    return Container(
      decoration: BoxDecoration(
        color: colorsList.bottomsheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            rs.s(6),
            rs.s(8),
            rs.s(6),
            rs.s(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _BottomNavItem(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  icon: Icons.show_chart_rounded,
                  activeIcon: Icons.show_chart_rounded,
                  label: 'Sales',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(child: _ScanBottomButton()),
              Expanded(
                child: _BottomNavItem(
                  index: 3,
                  selectedIndex: _selectedIndex,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'Purchases',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  index: 4,
                  selectedIndex: _selectedIndex,
                  icon: Icons.grid_view_rounded,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'More',
                  onTap: _onItemTapped,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({
    required this.name,
    required this.email,
    required this.plan,
    required this.imageUrl,
    required this.onTap,
  });

  final String name;
  final String email;
  final String plan;
  final String imageUrl;
  final VoidCallback onTap;

  String _getInitials(String input) {
    if (input.trim().isEmpty) return 'AI';
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'AI';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isNotEmpty ? name.trim() : 'Anees Irshad';
    final displayEmail =
        email.trim().isNotEmpty ? email.trim() : 'anees.irshad@berrinex.com';
    final displayPlan = plan.trim().isNotEmpty && plan.trim() != 'Free'
        ? plan.trim()
        : 'Standard Plan';
    final initials = _getInitials(displayName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar Stack
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B365D),
                      borderRadius: BorderRadius.circular(14),
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: imageUrl.isEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // User Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFFF97316),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Client Portal',
                            style: TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            displayPlan,
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreSectionHeader extends StatelessWidget {
  const _MoreSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8A94A6),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MoreGroupCard extends StatelessWidget {
  const _MoreGroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.iconBgColor,
    this.textColor,
    this.trailing,
    this.isTop = false,
    this.isBottom = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;
  final bool isTop;
  final bool isBottom;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? colorsList.blue;
    final effectiveIconBgColor =
        iconBgColor ?? effectiveIconColor.withValues(alpha: 0.12);

    BorderRadius borderRadius = BorderRadius.zero;
    if (isTop && isBottom) {
      borderRadius = BorderRadius.circular(16);
    } else if (isTop) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(16));
    } else if (isBottom) {
      borderRadius = const BorderRadius.vertical(bottom: Radius.circular(16));
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor ?? const Color(0xFF1E293B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandableSubMenu extends StatelessWidget {
  const _ExpandableSubMenu({
    required this.expanded,
    required this.items,
  });

  final bool expanded;
  final List<_SubMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.only(left: 20, right: 12, top: 4, bottom: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2.5,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: items,
                ),
              ),
            ],
          ),
        ),
      ),
      crossFadeState:
          expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 220),
    );
  }
}

class _SubMenuItem extends StatelessWidget {
  const _SubMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFEE2E2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sign out from your account',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFCA5A5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'DocElix Cloud Sync Active',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'DocElix Mobile Suite - v2.4.1 (Build 890)',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isSelected = selectedIndex == index;
    final activeColor = colorsList.colorButton;
    final inactiveColor = const Color(0xFF556578);

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? activeColor : inactiveColor,
            size: rs.s(22),
          ),
          SizedBox(height: rs.s(4)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: rs.sp(11),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: rs.s(4)),
          if (isSelected)
            Container(
              width: rs.s(24),
              height: 3,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          else
            SizedBox(height: rs.s(3)),
        ],
      ),
    );
  }
}

class _ScanBottomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final controller = Get.find<CreatePurchaseInvoiceController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return InkWell(
        onTap: isLoading ? null : controller.captureFromCamera,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, -rs.s(16)),
              child: Container(
                width: rs.s(54),
                height: rs.s(54),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : colorsList.colorButton,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5EDF6),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorsList.colorButton.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(rs.s(12)),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: rs.s(24),
                      ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -rs.s(12)),
              child: Text(
                isLoading ? 'Uploading...' : 'Scan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF556578),
                  fontSize: rs.sp(11),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}