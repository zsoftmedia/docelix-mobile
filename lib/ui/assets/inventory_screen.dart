import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/inventory_controller.dart';
import 'package:docelix_mobileapp/models/inventory_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<InventoryController>()) {
      Get.delete<InventoryController>(force: true);
    }
    controller = Get.put(InventoryController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<InventoryController>()) {
      Get.delete<InventoryController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
          'Inventory Management',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(
            () => controller.isSearching.value
                ? const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.045,
              width * 0.03,
              width * 0.045,
              width * 0.02,
            ),
            child: _SearchHeader(controller: controller),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.refreshItems,
                child: controller.filteredItems.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: width * 0.25),
                          _EmptyState(
                            hasSearch: controller.searchQuery.value.isNotEmpty,
                            onClear: controller.clearSearch,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          width * 0.045,
                          0,
                          width * 0.045,
                          width * 0.08,
                        ),
                        itemCount: controller.filteredItems.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: width * 0.03),
                        itemBuilder: (context, index) {
                          final item = controller.filteredItems[index];
                          return _InventoryCard(
                            item: item,
                            onAdjust: () => _openAdjustStockSheet(
                              context,
                              controller,
                              item,
                            ),
                            onLedger: () =>
                                _openLedgerSheet(context, controller, item),
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAdjustStockSheet(
    BuildContext context,
    InventoryController controller,
    InventoryItem item,
  ) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) =>
          _AdjustStockSheet(controller: controller, item: item),
    ).then((logged) async {
      if (logged == true) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Stock movement logged.',
        );
        await controller.loadItems();
      }
    });
  }

  void _openLedgerSheet(
    BuildContext context,
    InventoryController controller,
    InventoryItem item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        final bottomInset = MediaQuery.of(context).padding.bottom;
        final height = MediaQuery.of(context).size.height * 0.72;

        controller.loadMovements(item);

        return SizedBox(
          height: height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.05,
              width * 0.04,
              width * 0.05,
              width * 0.04 + bottomInset,
            ),
            child: Column(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ledger: ${item.articleName}',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorsList.iconColor,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Text(
                    controller.isLoadingMovements.value
                        ? 'Loading movements...'
                        : '${controller.movements.length} movement${controller.movements.length == 1 ? '' : 's'} · Stock ${item.stockLabel}',
                    style: TextStyle(
                      color: item.isNegativeStock
                          ? colorsList.red
                          : colorsList.secondaryText,
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: width * 0.03),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingMovements.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.movements.isEmpty) {
                      return Center(
                        child: Text(
                          'No movements found for this item.',
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width * 0.033,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: controller.movements.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: width * 0.025),
                      itemBuilder: (context, index) {
                        final movement = controller.movements[index];
                        return _MovementTile(movement: movement);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdjustStockSheet extends StatefulWidget {
  const _AdjustStockSheet({required this.controller, required this.item});

  final InventoryController controller;
  final InventoryItem item;

  @override
  State<_AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends State<_AdjustStockSheet> {
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  String _movementType = inventoryMovementTypeOptions.first.value;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _close([bool logged = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    Navigator.of(context).pop(logged);
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final qty = double.tryParse(_quantityController.text.trim());
    if (qty == null || qty == 0) {
      Get.snackbar(
        'Invalid quantity',
        'Please enter a non-zero quantity.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.logMovement(
      item: widget.item,
      movementType: _movementType,
      quantity: qty,
      notes: _notesController.text,
      refreshList: false,
      showSuccessSnackbar: false,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      await _close(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    final item = widget.item;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.05,
        width * 0.04,
        width * 0.05,
        width * 0.05 + bottomInset,
      ),
      child: SingleChildScrollView(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Adjust Stock: ${item.articleName}',
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isSubmitting ? null : () => _close(),
                  icon: Icon(Icons.close_rounded, color: colorsList.iconColor),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(width * 0.035),
              decoration: BoxDecoration(
                color: colorsList.colorBoxDecoration,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Stock:',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.stockLabel,
                        style: TextStyle(
                          color: item.isNegativeStock
                              ? colorsList.red
                              : colorsList.primaryText,
                          fontSize: width * 0.033,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.035),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Movement Type *',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_movementType),
                    initialValue: _movementType,
                    isExpanded: true,
                    decoration: _inventorySheetInputDecoration(),
                    items: inventoryMovementTypeOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _movementType = value);
                          },
                  ),
                  SizedBox(height: width * 0.03),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quantity *',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  TextField(
                    controller: _quantityController,
                    enabled: !_isSubmitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*\.?\d*'),
                      ),
                    ],
                    decoration: _inventorySheetInputDecoration(
                      hint: 'Enter quantity',
                    ),
                  ),
                  SizedBox(height: width * 0.01),
                  Text(
                    'Use positive numbers for additions (e.g. Purchase) and negative numbers for deductions (e.g. Loss).',
                    style: TextStyle(
                      color: colorsList.mutedTextColor,
                      fontSize: width * 0.024,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: width * 0.03),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.015),
                  TextField(
                    controller: _notesController,
                    enabled: !_isSubmitting,
                    maxLines: 3,
                    decoration: _inventorySheetInputDecoration(
                      hint: 'Add a note',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: width * 0.045),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => _close(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: const BorderSide(color: colorsList.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorsList.colorButton,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Log Movement',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inventorySheetInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: colorsList.mutedTextColor,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorsList.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorsList.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorsList.colorButton, width: 1.4),
    ),
  );
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Text(
                  '${controller.filteredItems.length} item${controller.filteredItems.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (controller.searchQuery.value.isNotEmpty)
                  TextButton(
                    onPressed: controller.clearSearch,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          SizedBox(height: width * 0.025),
          Container(
            decoration: BoxDecoration(
              color: colorsList.colorBoxDecoration,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                controller.searchQuery.value = value;
                controller.loadItems(showLoader: false);
              },
              decoration: InputDecoration(
                hintText: 'Search by name or SKU...',
                hintStyle: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.032,
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
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.onAdjust,
    required this.onLedger,
  });

  final InventoryItem item;
  final VoidCallback onAdjust;
  final VoidCallback onLedger;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      item.articleName,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: width * 0.008),
                    Text(
                      'SKU: ${item.skuLabel}',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.012,
                ),
                decoration: BoxDecoration(
                  color: item.isNegativeStock
                      ? colorsList.red.withValues(alpha: 0.1)
                      : item.isLowStock
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                      : const Color(0xFF12B886).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.stockLabel,
                  style: TextStyle(
                    color: item.isNegativeStock
                        ? colorsList.red
                        : item.isLowStock
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF12B886),
                    fontSize: width * 0.028,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.03),
          Row(
            children: [
              Expanded(
                child: _MetaBlock(label: 'Category', value: item.categoryLabel),
              ),
              Expanded(
                child: _MetaBlock(
                  label: 'Current Stock',
                  value: item.stockLabel,
                  valueColor: item.isNegativeStock ? colorsList.red : null,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.035),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdjust,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Adjust Stock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorsList.primaryText,
                    minimumSize: const Size(0, 42),
                    side: const BorderSide(color: colorsList.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.025),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLedger,
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Ledger'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorsList.primaryText,
                    minimumSize: const Size(0, 42),
                    side: const BorderSide(color: colorsList.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.mutedTextColor,
            fontSize: width * 0.024,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: width * 0.006),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colorsList.primaryText,
            fontSize: width * 0.032,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement});

  final InventoryMovement movement;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final qtyColor = movement.isOutbound || movement.quantity < 0
        ? colorsList.red
        : const Color(0xFF15803D);
    final badgeColors = _typeBadgeColors(movement.movementType);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                movement.displayDate,
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.028,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                movement.quantityLabel,
                style: TextStyle(
                  color: qtyColor,
                  fontSize: width * 0.036,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: width * 0.02),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.01,
                ),
                decoration: BoxDecoration(
                  color: badgeColors.$1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  movement.typeBadgeLabel,
                  style: TextStyle(
                    color: badgeColors.$2,
                    fontSize: width * 0.024,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (movement.referenceLabel != null) ...[
                SizedBox(width: width * 0.02),
                Expanded(
                  child: Text(
                    movement.referenceLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorsList.secondaryText,
                      fontSize: width * 0.027,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (movement.notes != null && movement.notes!.trim().isNotEmpty) ...[
            SizedBox(height: width * 0.02),
            Text(
              movement.notes!,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width * 0.03,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color) _typeBadgeColors(String type) {
    switch (type.toUpperCase()) {
      case 'SALE':
      case 'LOSS':
      case 'DAMAGED':
        return (const Color(0xFFFEE2E2), const Color(0xFFB91C1C));
      case 'PURCHASE':
      case 'INITIAL':
      case 'RETURN':
        return (const Color(0xFFDCFCE7), const Color(0xFF15803D));
      case 'ADJUSTMENT':
      case 'TRANSFER':
        return (const Color(0xFFE0E7FF), const Color(0xFF3730A3));
      default:
        return (const Color(0xFFF1F5F9), const Color(0xFF475569));
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onClear});

  final bool hasSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: width * 0.16,
              color: const Color(0xFFCBD5E1),
            ),
            SizedBox(height: width * 0.04),
            Text(
              'No inventory items',
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width * 0.042,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: width * 0.02),
            Text(
              hasSearch
                  ? 'No items match your search.'
                  : 'Stock-tracked catalog items will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width * 0.032,
                height: 1.4,
              ),
            ),
            if (hasSearch) ...[
              SizedBox(height: width * 0.04),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
