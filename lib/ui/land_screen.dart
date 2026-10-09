import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_incoming_invoice_controller.dart';
import 'package:docelix_mobileapp/services/auth_services.dart';
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
  final CreateIncomingInvoiceController incomingInvoiceController = Get.put(
    CreateIncomingInvoiceController(),
  );

  int _selectedIndex = 0;
  bool _assetsExpanded = false;

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
        Get.toNamed('/InvoicesScreen');
        return;
      case 2:
        _openScan();
        return;
      case 3:
        Get.toNamed('/IncomingInvoicesScreen');
        return;
      case 4:
        _showMoreMenu();
        return;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  Future<void> _openScan() async {
    final result = await Get.to(() => const ScanQrScreen());
    if (result == null) return;

    AppSnackbar.success(title: 'QR Code Scanned', message: result.toString());
  }

  Future<void> _logout() async {
    try {
      await AuthServices().signOut();
      await SessionManager.saveAccessToken('');
      await SessionManager.saveEmail('');
      await SessionManager.saveCompanyid(0);
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    Get.offAllNamed('/LoginScreen');
  }

  void _openAssetRoute(String route) {
    Navigator.pop(context);
    Get.toNamed(route);
  }

  void _showMoreMenu() {
    _assetsExpanded = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (sheetContext) {
        final width = MediaQuery.of(sheetContext).size.width;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).padding.bottom;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
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
              child: SingleChildScrollView(
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
                            'More',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width * 0.048,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
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
                      icon: Icons.grid_view_rounded,
                      title: 'Items',
                      subtitle: 'Manage your products and services',
                      iconColor: colorsList.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/CatalogsScreen');
                      },
                    ),
                    _MoreMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: 'Clients',
                      subtitle: 'Manage your clients',
                      iconColor: colorsList.green,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/ClientsScreen');
                      },
                    ),
                    _AssetsExpandableSection(
                      expanded: _assetsExpanded,
                      onToggle: () {
                        setSheetState(() {
                          _assetsExpanded = !_assetsExpanded;
                        });
                      },
                      onFixedAssets: () =>
                          _openAssetRoute('/FixedAssetsScreen'),
                      onInventory: () => _openAssetRoute('/InventoryScreen'),
                      onVehicles: () =>
                          _openAssetRoute('/VehiclesLogbookScreen'),
                    ),
                    _MoreMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: 'Manage your profile',
                      iconColor: colorsList.cyan,
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/ProfileScreen');
                      },
                    ),
                    SizedBox(height: width * 0.02),
                    const Divider(color: colorsList.borderColor, height: 1),
                    SizedBox(height: width * 0.01),
                    _MoreMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from your account',
                      iconColor: colorsList.red,
                      textColor: colorsList.red,
                      onTap: () {
                        Navigator.pop(context);
                        _logout();
                      },
                    ),
                  ],
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
    final width = MediaQuery.of(context).size.width;

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
      bottomNavigationBar: _buildBottomNavigation(width: width),
    );
  }

  Widget _buildBottomNavigation({required double width}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: width * 0.015, bottom: width * 0.01),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _BottomNavItem(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Invoices',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(child: _ScanBottomButton()),
              Expanded(
                child: _BottomNavItem(
                  index: 3,
                  selectedIndex: _selectedIndex,
                  icon: Icons.upcoming_outlined,
                  activeIcon: Icons.upcoming_rounded,
                  label: 'Incoming',
                  onTap: _onItemTapped,
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  index: 4,
                  selectedIndex: _selectedIndex,
                  icon: Icons.more_horiz_rounded,
                  activeIcon: Icons.more_horiz_rounded,
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

class _MoreMenuItem extends StatelessWidget {
  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: width * 0.028),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: width * 0.112,
                height: width * 0.112,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: width * 0.052),
              ),
              SizedBox(width: width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor ?? colorsList.primaryText,
                        fontSize: width * 0.038,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: width * 0.008),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.030,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: width * 0.02),
              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: width * 0.055,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssetsExpandableSection extends StatelessWidget {
  const _AssetsExpandableSection({
    required this.expanded,
    required this.onToggle,
    required this.onFixedAssets,
    required this.onInventory,
    required this.onVehicles,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onFixedAssets;
  final VoidCallback onInventory;
  final VoidCallback onVehicles;

  static const Color _accent = Color(0xFFC47A52);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(vertical: width * 0.028),
              decoration: BoxDecoration(
                color: expanded ? const Color(0xFF1B2A41) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: expanded
                    ? const Border(left: BorderSide(color: _accent, width: 3.5))
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: expanded ? width * 0.02 : 0,
                  right: expanded ? width * 0.02 : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: width * 0.112,
                      height: width * 0.112,
                      decoration: BoxDecoration(
                        color: expanded
                            ? _accent.withValues(alpha: 0.18)
                            : _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_outlined,
                        color: _accent,
                        size: width * 0.052,
                      ),
                    ),
                    SizedBox(width: width * 0.035),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assets',
                            style: TextStyle(
                              color: expanded
                                  ? Colors.white
                                  : colorsList.primaryText,
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: width * 0.008),
                          Text(
                            'Fixed assets, inventory & vehicles',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: expanded
                                  ? Colors.white70
                                  : colorsList.secondaryText,
                              fontSize: width * 0.030,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: width * 0.02),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: expanded
                            ? Colors.white70
                            : colorsList.secondaryText,
                        size: width * 0.055,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: EdgeInsets.only(
              left: width * 0.056,
              top: width * 0.01,
              bottom: width * 0.01,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: width * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEE8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: width * 0.035),
                  Expanded(
                    child: Column(
                      children: [
                        _AssetSubItem(
                          icon: Icons.computer_rounded,
                          title: 'Fixed Assets',
                          onTap: onFixedAssets,
                        ),
                        _AssetSubItem(
                          icon: Icons.inventory_2_outlined,
                          title: 'Inventory',
                          onTap: onInventory,
                        ),
                        _AssetSubItem(
                          icon: Icons.directions_car_outlined,
                          title: 'Vehicles & Logbook',
                          onTap: onVehicles,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}

class _AssetSubItem extends StatelessWidget {
  const _AssetSubItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width * 0.028,
            horizontal: width * 0.01,
          ),
          child: Row(
            children: [
              Icon(icon, size: width * 0.048, color: colorsList.secondaryText),
              SizedBox(width: width * 0.03),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.036,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: width * 0.05,
              ),
            ],
          ),
        ),
      ),
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
    final width = MediaQuery.of(context).size.width;
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? colorsList.green : const Color(0xFF71829A),
            size: width * 0.058,
          ),
          SizedBox(height: width * 0.008),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? colorsList.green : const Color(0xFF71829A),
              fontSize: width * 0.026,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: width * 0.008),
              width: width * 0.065,
              height: 2,
              decoration: BoxDecoration(
                color: colorsList.green,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          else
            SizedBox(height: width * 0.016),
        ],
      ),
    );
  }
}

class _ScanBottomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = Get.find<CreateIncomingInvoiceController>();

    return Obx(() {
      final isLoading = controller.isLoading.value;

      return InkWell(
        onTap: isLoading ? null : controller.captureFromCamera,
        borderRadius: BorderRadius.circular(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, -width * 0.028),
              child: Container(
                width: width * 0.125,
                height: width * 0.125,
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : colorsList.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isLoading ? Colors.grey : colorsList.green)
                          .withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: isLoading
                    ? Padding(
                        padding: EdgeInsets.all(width * 0.032),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: width * 0.06,
                      ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -width * 0.018),
              child: Text(
                isLoading ? 'Uploading...' : 'Scan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF71829A),
                  fontSize: width * 0.026,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
