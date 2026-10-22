import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_controller.dart';
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
                  maxHeight: rs.height * 0.85,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    rs.s(20),
                    rs.s(12),
                    rs.s(20),
                    rs.s(18) + bottomInset,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
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
                        SizedBox(height: rs.s(14)),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'More',
                                style: TextStyle(
                                  color: colorsList.primaryText,
                                  fontSize: rs.sp(19),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorsList.secondaryText,
                                size: rs.s(22),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: rs.s(4)),
                        _InventoryExpandableSection(
                          expanded: _inventoryExpanded,
                          onToggle: () {
                            setSheetState(() {
                              _inventoryExpanded = !_inventoryExpanded;
                            });
                          },
                          onStockAddition: () {
                            Navigator.pop(context);
                            Get.toNamed('/CatalogsScreen');
                          },
                          onStockAdjustment: () {
                            Navigator.pop(context);
                            Get.toNamed('/StockAdjustmentScreen');
                          },
                          onStockReports: () {
                            Navigator.pop(context);
                            Get.toNamed('/StockReportScreen');
                          },
                        ),
                        _MoreMenuItem(
                          icon: Icons.people_outline_rounded,
                          title: 'Customers',
                          subtitle: 'Manage your customers',
                          iconColor: colorsList.green,
                          onTap: () {
                            Navigator.pop(context);
                            Get.toNamed('/CustomersScreen');
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
                          onInventory: () =>
                              _openAssetRoute('/InventoryScreen'),
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
                        SizedBox(height: rs.s(8)),
                        const Divider(
                          color: colorsList.borderColor,
                          height: 1,
                        ),
                        SizedBox(height: rs.s(4)),
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
          padding: EdgeInsets.only(top: rs.s(6), bottom: rs.s(4)),
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
                  icon: Icons.auto_graph_outlined,
                  activeIcon: Icons.auto_graph_rounded,
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
    final rs = context.rs;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: rs.s(11)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: rs.s(44),
                height: rs.s(44),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: rs.s(20)),
              ),
              SizedBox(width: rs.s(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor ?? colorsList.primaryText,
                        fontSize: rs.sp(15),
                        fontWeight: FontWeight.normal,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: rs.s(3)),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: rs.sp(12),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: rs.s(8)),
              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: rs.s(22),
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
    final rs = context.rs;

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
              padding: EdgeInsets.symmetric(vertical: rs.s(11)),
              decoration: BoxDecoration(
                color: expanded ? const Color(0xFF1B2A41) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: expanded
                    ? const Border(left: BorderSide(color: _accent, width: 3.5))
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: expanded ? rs.s(8) : 0,
                  right: expanded ? rs.s(8) : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: rs.s(44),
                      height: rs.s(44),
                      decoration: BoxDecoration(
                        color: expanded
                            ? _accent.withValues(alpha: 0.18)
                            : _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_outlined,
                        color: _accent,
                        size: rs.s(20),
                      ),
                    ),
                    SizedBox(width: rs.s(14)),
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
                              fontSize: rs.sp(15),
                              fontWeight: FontWeight.normal,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: rs.s(3)),
                          Text(
                            'Fixed assets, inventory & vehicles',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: expanded
                                  ? Colors.white70
                                  : colorsList.secondaryText,
                              fontSize: rs.sp(12),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: rs.s(8)),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: expanded
                            ? Colors.white70
                            : colorsList.secondaryText,
                        size: rs.s(22),
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
              left: rs.s(22),
              top: rs.s(4),
              bottom: rs.s(4),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: rs.s(4)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEE8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: rs.s(14)),
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
    final rs = context.rs;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: rs.s(11),
            horizontal: rs.s(4),
          ),
          child: Row(
            children: [
              Icon(icon, size: rs.s(19),
                  color: colorsList.secondaryText),
              SizedBox(width: rs.s(12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: rs.sp(14),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: rs.s(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryExpandableSection extends StatelessWidget {
  const _InventoryExpandableSection({
    required this.expanded,
    required this.onToggle,
    required this.onStockAddition,
    required this.onStockAdjustment,
    required this.onStockReports,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onStockAddition;
  final VoidCallback onStockAdjustment;
  final VoidCallback onStockReports;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: rs.s(11)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: rs.s(44),
                    height: rs.s(44),
                    decoration: BoxDecoration(
                      color: expanded
                          ? colorsList.primaryBlue
                          : colorsList.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: expanded ? Colors.white : colorsList.blue,
                      size: rs.s(20),
                    ),
                  ),
                  SizedBox(width: rs.s(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventory',
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: rs.sp(15),
                            fontWeight: FontWeight.normal,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: rs.s(3)),
                        Text(
                          'Stock addition, adjustments & reports',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: rs.sp(12),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: rs.s(8)),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorsList.secondaryText,
                      size: rs.s(22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: EdgeInsets.only(
              left: rs.s(22),
              top: rs.s(4),
              bottom: rs.s(4),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: rs.s(4)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEE8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: rs.s(14)),
                  Expanded(
                    child: Column(
                      children: [
                        _AssetSubItem(
                          icon: Icons.add_box_outlined,
                          title: 'Stock Addition',
                          onTap: onStockAddition,
                        ),
                        _AssetSubItem(
                          icon: Icons.tune_rounded,
                          title: 'Stock Adjustment',
                          onTap: onStockAdjustment,
                        ),
                        _AssetSubItem(
                          icon: Icons.assessment_outlined,
                          title: 'Stock Reports',
                          onTap: onStockReports,
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

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? colorsList.colorButton : const Color(0xFF71829A),
            size: rs.s(22),
          ),
          SizedBox(height: rs.s(3)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? colorsList.colorButton : const Color(0xFF71829A),
              fontSize: rs.sp(10),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: rs.s(3)),
              width: rs.s(26),
              height: 2,
              decoration: BoxDecoration(
                color: colorsList.colorButton,
                borderRadius: BorderRadius.circular(10),
              ),
            )
          else
            SizedBox(height: rs.s(6)),
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
        borderRadius: BorderRadius.circular(50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, -rs.s(11)),
              child: Container(
                width: rs.s(48),
                height: rs.s(48),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : colorsList.colorButton,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isLoading ? Colors.grey : colorsList.colorButton)
                          .withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
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
                        size: rs.s(23),
                      ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -rs.s(7)),
              child: Text(
                isLoading ? 'Uploading...' : 'Scan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF71829A),
                  fontSize: rs.sp(10),
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