import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/controllers/create_asset_controller.dart';
import 'package:docelix_mobileapp/controllers/fixed_assets_controller.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Phone: real screen width. Tablet+: design width scaled (keeps proportions
/// consistent instead of stretching with the viewport).
double _designWidth(BuildContext context) {
  final rs = context.rs;
  return rs.isPhone ? rs.width : ResponsiveBreakpoints.designWidth * rs.scale;
}

class FixedAssetsScreen extends StatelessWidget {
  const FixedAssetsScreen({super.key});

  Future<void> _openCreateAsset(FixedAssetsController controller) async {
    final created = await Get.toNamed('/CreateAssetScreen');

    // GetX completes this future when the route *starts* closing, while the
    // exit transition (and Form fields) are still mounted. Wait it out before
    // disposing TextEditingControllers — otherwise we get used-after-dispose
    // and the red screen.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (Get.isRegistered<CreateAssetController>()) {
      Get.delete<CreateAssetController>(force: true);
    }

    if (created != true) return;

    await controller.refreshAssets();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSnackbar.success(
        title: 'Success',
        message: 'Asset created successfully.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixedAssetsController());
    final rs = context.rs;
    final width = _designWidth(context);
    final columns = rs.listColumns;
    final gap = width * 0.03;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Text(
          'Assets',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width.fontSizeW(0.055),
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        actions: [
          // Export Button

          /*TextButton.icon(
            onPressed: () {
              AppSnackbar.info(
                title: 'Coming soon',
                message: 'Export will be available in a later update.',
              );
            },
            icon: Icon(
              Icons.download_outlined,
              size: width * 0.045,
              color: colorsList.iconColor,
            ),
            label: Text(
              'Export',
              style: TextStyle(
                color: colorsList.primaryText,
                fontWeight: FontWeight.normal,
                fontSize: width.fontSizeW(0.032),
              ),
            ),
          ),
          const SizedBox(width: 4),*/
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateAsset(controller),
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Asset',
          style: TextStyle(
              fontWeight: FontWeight.normal),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value && controller.assets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: controller.refreshAssets,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.045,
                      width * 0.03,
                      width * 0.045,
                      0,
                    ),
                    child: Column(
                      children: [
                        _SearchAndFilterBar(controller: controller),
                        SizedBox(height: width * 0.03),
                        _KpiGrid(controller: controller),
                      ],
                    ),
                  ),
                ),
                if (controller.filteredAssets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      hasFilters: controller.hasActiveFilters,
                      onAdd: () => _openCreateAsset(controller),
                      onClearFilters: controller.clearFilters,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.045,
                      width * 0.02,
                      width * 0.045,
                      width * 0.28,
                    ),
                    sliver: SliverList.separated(
                      itemCount: (controller.filteredAssets.length / columns)
                          .ceil(),
                      separatorBuilder: (_, _) => SizedBox(height: gap),
                      itemBuilder: (context, rowIndex) {
                        final start = rowIndex * columns;
                        Widget cardAt(int index) {
                          final asset = controller.filteredAssets[index];
                          return _AssetCard(
                            asset: asset,
                            money: controller.formatMoney,
                            onTap: () {
                              Get.toNamed(
                                '/AssetDetailsScreen',
                                arguments: asset,
                              );
                            },
                          );
                        }

                        if (columns == 1) return cardAt(start);

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var c = 0; c < columns; c++) ...[
                                if (c > 0) SizedBox(width: gap),
                                Expanded(
                                  child:
                                      start + c <
                                          controller.filteredAssets.length
                                      ? cardAt(start + c)
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({required this.controller});

  final FixedAssetsController controller;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorsList.borderColor),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'Search by name or number',
                hintStyle: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width.fontSizeW(0.033),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorsList.secondaryText,
                  size: width * 0.05,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: width * 0.035),
              ),
            ),
          ),
        ),
        SizedBox(width: width * 0.025),
        Material(
          color: colorsList.colorButton,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _openFilters(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.035,
                vertical: width * 0.035,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: width * 0.045,
                  ),
                  SizedBox(width: width * 0.015),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.032),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) {
        final width = _designWidth(context);
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: EdgeInsets.fromLTRB(
              width * 0.05,
              width * 0.04,
              width * 0.05,
              width * 0.05 + bottomInset,
            ),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7DDE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.04),
                    Text(
                      'Filters',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width.fontSizeW(0.045),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: width * 0.04),
                    Text(
                      'Category',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    DropdownButtonFormField<int?>(
                      key: ValueKey(
                        'category_${controller.selectedCategoryId.value}',
                      ),
                      initialValue: controller.selectedCategoryId.value,
                      isExpanded: true,
                      decoration: _dropdownDecoration(),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...controller.categories.map(
                          (category) => DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: controller.setCategoryFilter,
                    ),
                    SizedBox(height: width * 0.035),
                    Text(
                      'Status',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'status_${controller.selectedStatus.value}',
                      ),
                      initialValue: controller.selectedStatus.value,
                      isExpanded: true,
                      decoration: _dropdownDecoration(),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Filter by Status'),
                        ),
                        ...controller.availableStatuses.map(
                          (status) => DropdownMenuItem<String?>(
                            value: status,
                            child: Text(status),
                          ),
                        ),
                      ],
                      onChanged: controller.setStatusFilter,
                    ),
                    SizedBox(height: width * 0.035),
                    Text(
                      'Account',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    DropdownButtonFormField<int?>(
                      key: ValueKey(
                        'account_${controller.selectedAccountId.value}',
                      ),
                      initialValue: controller.selectedAccountId.value,
                      isExpanded: true,
                      decoration: _dropdownDecoration(),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All Accounts'),
                        ),
                        ...controller.accounts.map(
                          (account) => DropdownMenuItem<int?>(
                            value: account.id,
                            child: Text(
                              account.displayLabel,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: controller.setAccountFilter,
                    ),
                    SizedBox(height: width * 0.05),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearFilters();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              side: const BorderSide(
                                color: colorsList.borderColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorsList.colorButton,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: colorsList.colorBoxDecoration,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.controller});

  final FixedAssetsController controller;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    final columns = context.rs.kpiColumns;
    final gap = width * 0.025;

    return Obx(() {
      // Read observables here — LayoutBuilder's builder runs outside Obx tracking.
      controller.assets.length;
      final totalAssets = '${controller.totalAssetsCount}';
      final bookValue = controller.formatMoney(controller.totalBookValue);
      final annualDep = controller.formatMoney(controller.annualDepreciation);
      final nearEol = '${controller.nearEndOfLifeCount}';

      return LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          final itemHeight = itemWidth / 1.55;
          final cards = <Widget>[
            _KpiCard(
              title: 'Total Assets',
              value: totalAssets,
              subtitle: 'All active assets',
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF3B82F6),
            ),
            _KpiCard(
              title: 'Current Book Value',
              value: bookValue,
              subtitle: 'Total depreciated value',
              icon: Icons.payments_outlined,
              iconColor: const Color(0xFF12B886),
            ),
            _KpiCard(
              title: 'Annual Depreciation',
              value: annualDep,
              subtitle: 'This year',
              icon: Icons.pie_chart_outline_rounded,
              iconColor: const Color(0xFFF59E0B),
            ),
            _KpiCard(
              title: 'Near End of Life',
              value: nearEol,
              subtitle: 'In next 12 months',
              icon: Icons.warning_amber_rounded,
              iconColor: const Color(0xFF8B5CF6),
            ),
          ];

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final card in cards)
                SizedBox(width: itemWidth, height: itemHeight, child: card),
            ],
          );
        },
      );
    });
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.028,
        vertical: width * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.065,
                height: width * 0.065,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: width * 0.034),
              ),
              SizedBox(width: width * 0.012),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width.fontSizeW(0.025),
                    fontWeight: FontWeight.normal,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width.fontSizeW(0.038),
              fontWeight: FontWeight.normal,
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width.fontSizeW(0.022),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.money,
    required this.onTap,
  });

  final AssetModel asset;
  final String Function(num value) money;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);
    final statusColor = _statusColor(asset.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorsList.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width.fontSizeW(0.04),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: width * 0.008),
                        Text(
                          asset.assetNumber ?? 'No asset number',
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width.fontSizeW(0.028),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.025,
                          vertical: width * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          asset.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: width.fontSizeW(0.026),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(height: width * 0.012),
                      Text(
                        asset.usefulLifeYears == null
                            ? 'Life —'
                            : 'Life ${asset.usefulLifeYears} yrs',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.026),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: width * 0.025),
              Wrap(
                spacing: width * 0.015,
                runSpacing: width * 0.015,
                children: [
                  _MetaChip(
                    icon: Icons.category_outlined,
                    label: asset.categoryName,
                  ),
                  if (asset.location != null && asset.location!.isNotEmpty)
                    _MetaChip(
                      icon: Icons.place_outlined,
                      label: asset.location!,
                    ),
                  if (asset.ownershipType != null)
                    _MetaChip(
                      icon: Icons.handshake_outlined,
                      label: asset.ownershipType!,
                    ),
                ],
              ),
              SizedBox(height: width * 0.03),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: width * 0.025,
                ),
                decoration: BoxDecoration(
                  color: colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ValueBlock(
                            label: 'Cost',
                            value: money(asset.purchasePrice),
                          ),
                        ),
                        Expanded(
                          child: _ValueBlock(
                            label: 'Accum. Depreciation',
                            value: money(asset.accumulatedDepreciation),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: width * 0.02),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: colorsList.borderColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _ValueBlock(
                            label: 'Book Value',
                            value: money(asset.currentBookValue),
                            emphasize: true,
                          ),
                        ),
                        Expanded(
                          child: _ValueBlock(
                            label: 'Annual Depr.',
                            value: money(asset.estimatedAnnualDepreciation),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF12B886);
      case 'under repair':
        return const Color(0xFFF59E0B);
      case 'sold':
      case 'scrapped':
      case 'archived':
        return const Color(0xFF64748B);
      case 'lost':
      case 'stolen':
        return colorsList.red;
      default:
        return colorsList.secondaryText;
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.022,
        vertical: width * 0.012,
      ),
      decoration: BoxDecoration(
        color: colorsList.colorBoxDecoration,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: width * 0.032, color: colorsList.secondaryText),
          SizedBox(width: width * 0.01),
          Text(
            label,
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width.fontSizeW(0.026),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBlock extends StatelessWidget {
  const _ValueBlock({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorsList.mutedTextColor,
            fontSize: width.fontSizeW(0.024),
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: width * 0.006),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: emphasize ? width * 0.034 : width * 0.031,
            fontWeight: emphasize ? FontWeight.normal : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilters,
    required this.onAdd,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.computer_rounded,
              size: width * 0.16,
              color: const Color(0xFFCBD5E1),
            ),
            SizedBox(height: width * 0.045),
            Text(
              'No assets found',
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width.fontSizeW(0.045),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: width * 0.02),
            Text(
              hasFilters ? 'No assets match your current filters.' : "You haven't added any assets yet, or none match your filters.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width.fontSizeW(0.033),
                height: 1.4,
              ),
            ),
            SizedBox(height: width * 0.05),
            if (hasFilters)
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  side: const BorderSide(color: colorsList.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add First Asset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorsList.colorButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
