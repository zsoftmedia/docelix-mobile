import 'package:docelix_mobileapp/controllers/create_adjust_stock_controller.dart';
import 'package:docelix_mobileapp/models/inventory_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAdjustStockScreen extends StatefulWidget {
  const CreateAdjustStockScreen({super.key});

  @override
  State<CreateAdjustStockScreen> createState() => _CreateAdjustStockScreenState();
}

class _CreateAdjustStockScreenState extends State<CreateAdjustStockScreen> {
  final CreateAdjustStockController controller = Get.put(CreateAdjustStockController());

  String _formatNum(double num) {
    if (num % 1 == 0) return num.toInt().toString();
    return num.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Adjust stock',
          style: TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF64748B),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. PRODUCT DROPDOWN
              // ======================================================
              const _FieldLabel(text: 'Product *', required: true),
              const SizedBox(height: 6),
              Obx(() {
                final rawList = controller.items;
                final Map<int, InventoryItem> uniqueMap = {};
                for (final it in rawList) {
                  uniqueMap[it.id] = it;
                }
                final itemsList = uniqueMap.values.toList();
                final selectedId = controller.selectedItemId.value;

                if (controller.isLoadingItems.value) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorsList.borderColor),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Loading products...', style: TextStyle(fontSize: 13, color: colorsList.secondaryText)),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorsList.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: itemsList.any((it) => it.id == selectedId) ? selectedId : null,
                      isExpanded: true,
                      hint: const Text('Search product or SKU...'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: itemsList.map((item) {
                        return DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(
                            item.articleName,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final matched = itemsList.firstWhereOrNull((it) => it.id == val);
                          if (matched != null) {
                            controller.selectItem(matched);
                          }
                        }
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 18),

              // ======================================================
              // 2. WHAT DO YOU WANT TO DO? (3 TABS)
              // ======================================================
              const _FieldLabel(text: 'What do you want to do?'),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildActionTab(
                        index: 0,
                        icon: Icons.add_rounded,
                        label: 'Add stock',
                        isSelected: controller.selectedActionIndex.value == 0,
                      ),
                      _buildActionTab(
                        index: 1,
                        icon: Icons.remove_rounded,
                        label: 'Remove stock',
                        isSelected: controller.selectedActionIndex.value == 1,
                      ),
                      _buildActionTab(
                        index: 2,
                        icon: Icons.assignment_outlined,
                        label: 'Set count',
                        isSelected: controller.selectedActionIndex.value == 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ======================================================
              // 3. REASON DROPDOWN
              // ======================================================
              const _FieldLabel(text: 'Reason'),
              const SizedBox(height: 6),
              Obx(() {
                final reasonsRaw = controller.currentReasons;
                final Map<String, AdjustmentReasonOption> uniqueReasons = {};
                for (final r in reasonsRaw) {
                  uniqueReasons[r.key] = r;
                }
                final reasons = uniqueReasons.values.toList();
                final selectedKey = controller.selectedReasonKey.value;
                final selectedOption = controller.currentSelectedReasonOption;

                final matchedKey = reasons.any((r) => r.key == selectedKey)
                    ? selectedKey
                    : (reasons.isNotEmpty ? reasons.first.key : null);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: matchedKey,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: reasons.map((reason) {
                            return DropdownMenuItem<String>(
                              value: reason.key,
                              child: Text(
                                reason.label,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedReasonKey.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedOption != null && selectedOption.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedOption.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                );
              }),

              const SizedBox(height: 18),

              // ======================================================
              // 4. QUANTITY INPUT FIELD
              // ======================================================
              Obx(() => _FieldLabel(text: controller.quantityFieldLabel)),
              const SizedBox(height: 6),
              Obx(() {
                final item = controller.selectedItem;
                final unit = item?.unitCode ?? '';
                final isExceeding = controller.isExceedingAvailableStock;

                return TextFormField(
                  controller: controller.quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 14,
                    color: isExceeding ? const Color(0xFFDC2626) : const Color(0xFF0A2342),
                    fontWeight: isExceeding ? FontWeight.w600 : FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    suffixIcon: unit.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Text(
                              unit,
                              style: TextStyle(
                                fontSize: 13,
                                color: isExceeding ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                              ),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isExceeding ? const Color(0xFFDC2626) : colorsList.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isExceeding ? const Color(0xFFDC2626) : colorsList.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isExceeding ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                        width: 1.2,
                      ),
                    ),
                  ),
                );
              }),

              Obx(() {
                if (controller.isExceedingAvailableStock) {
                  final unit = controller.selectedItem?.unitCode ?? '';
                  final avail = _formatNum(controller.currentStock);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Cannot exceed available stock ($avail $unit available).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                if (controller.selectedItem == null) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Choose a product first.',
                      style: TextStyle(fontSize: 11, color: colorsList.textHintColor),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 14),

              // ======================================================
              // 5. LIVE STOCK PREVIEW BOX (REACTIVE OBX)
              // ======================================================
              Obx(() {
                final item = controller.selectedItem;
                if (item == null) return const SizedBox.shrink();

                final double currentQty = controller.currentStock;
                final double newQty = controller.calculatedNewStock;
                final String changeSignStr = controller.stockChangeSignText;
                final String unit = item.unitCode ?? '';
                final double calcValue = controller.calculatedPurchaseValue;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'On hand',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Value at purchase price',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text.rich(
                                TextSpan(
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                                  children: [
                                    TextSpan(text: '${_formatNum(currentQty)} $unit → '),
                                    TextSpan(
                                      text: '${_formatNum(newQty)} $unit ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: changeSignStr,
                                      style: const TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '€${calcValue.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 18),

              // ======================================================
              // 6. ADJUSTMENT DATE
              // ======================================================
              const _FieldLabel(text: 'Adjustment date'),
              const SizedBox(height: 6),
              Obx(
                () => InkWell(
                  onTap: () => controller.selectDate(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorsList.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd.MM.yyyy').format(controller.adjustmentDate.value),
                          style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                        ),
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ======================================================
              // 7. NOTE (OPTIONAL)
              // ======================================================
              const _FieldLabel(text: 'Note (optional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '',
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: colorsList.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: colorsList.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // 8. BOTTOM ACTION BUTTONS
              // ======================================================
              Obx(() {
                final isSubmitting = controller.isSubmitting.value;

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: OutlinedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => controller.submitAdjustment(saveAndNext: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save & next'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () => controller.submitAdjustment(saveAndNext: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF709BBF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                controller.actionButtonLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setActionTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? const Color(0xFF0A2342) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0A2342) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
        ],
      ),
    );
  }
}