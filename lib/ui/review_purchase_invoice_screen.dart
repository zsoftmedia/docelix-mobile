import 'package:docelix_mobileapp/controllers/review_purchase_invoice_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewPurchaseInvoiceScreen extends StatefulWidget {
  const ReviewPurchaseInvoiceScreen({super.key});

  @override
  State<ReviewPurchaseInvoiceScreen> createState() =>
      _ReviewPurchaseInvoiceScreenState();
}

class _ReviewPurchaseInvoiceScreenState
    extends State<ReviewPurchaseInvoiceScreen> {
  final ReviewPurchaseInvoiceController controller =
      Get.put(ReviewPurchaseInvoiceController());

  // ================================================================
  // SUPPLIER SEARCH BOTTOM SHEET
  // ================================================================
  void _showSupplierSearchSheet(BuildContext context) {
    controller.supplierSearchQuery.value = '';
    final searchInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height;
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            height: height * 0.70,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Supplier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchInputController,
                    autofocus: true,
                    onChanged: (val) => controller.supplierSearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search supplier name, email, phone...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchInputController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              searchInputController.clear();
                              controller.supplierSearchQuery.value = '';
                            },
                          );
                        },
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingSuppliers.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = controller.filteredSuppliers;

                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No suppliers found.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final supplier = list[index];
                        final isSelected = controller.selectedSupplier.value?.id == supplier.id;

                        final subtitleStr = [supplier.email, supplier.phone, supplier.city]
                            .where((e) => (e ?? '').trim().isNotEmpty)
                            .join(' · ');

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            supplier.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                            ),
                          ),
                          subtitle: subtitleStr.isNotEmpty
                              ? Text(subtitleStr, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                              : null,
                          onTap: () {
                            controller.selectSupplier(supplier);
                            Navigator.of(ctx).pop();
                          },
                        );
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

  // ================================================================
  // CURRENCY SEARCH BOTTOM SHEET
  // ================================================================
  void _showCurrencySearchSheet(BuildContext context) {
    controller.currencySearchQuery.value = '';
    final searchInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height;
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            height: height * 0.65,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchInputController,
                    autofocus: true,
                    onChanged: (val) => controller.currencySearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search currency code...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchInputController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              searchInputController.clear();
                              controller.currencySearchQuery.value = '';
                            },
                          );
                        },
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: Obx(() {
                    final list = controller.filteredCurrencies;
                    final selected = controller.selectedCurrency.value;

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final currency = list[index];
                        final isSelected = selected == currency;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            currency,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                              : null,
                          onTap: () {
                            controller.selectCurrency(currency);
                            Navigator.of(ctx).pop();
                          },
                        );
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

  // ================================================================
  // CATALOG ITEM SEARCH BOTTOM SHEET
  // ================================================================
  void _showCatalogItemSearchSheet(BuildContext context, int lineIndex) {
    controller.catalogSearchQuery.value = '';
    final searchInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height;
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            height: height * 0.70,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Article / Item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchInputController,
                    autofocus: true,
                    onChanged: (val) => controller.catalogSearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search article name or code...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchInputController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              searchInputController.clear();
                              controller.catalogSearchQuery.value = '';
                            },
                          );
                        },
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingCatalog.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = controller.filteredCatalogItems;

                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No catalog items found.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                      itemCount: list.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final catalog = list[index];
                        final name = catalog.articleName ?? 'Item';
                        final code = catalog.articleNumber ?? '';
                        final price = catalog.unitPriceNet ?? catalog.purchasePriceNet ?? 0.0;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0A2342),
                            ),
                          ),
                          subtitle: Text(
                            'Code: $code · Net: €${price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          onTap: () {
                            controller.selectCatalogItemForLine(lineIndex, catalog);
                            Navigator.of(ctx).pop();
                          },
                        );
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

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. TOP HEADER BAR WITH TITLE & CLOSE BUTTON
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF063C70),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.purchaseNumber.value.isNotEmpty
                              ? 'Review ${controller.purchaseNumber.value}'
                              : 'Review Purchase Invoice',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // 2. STEPPER HEADER PROGRESS INDICATOR
              // ======================================================
              _buildStepperHeader(context),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // ======================================================
              // 3. STEP CONTENT BODY
              // ======================================================
              Expanded(
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:
                      return _buildReviewOverviewTab(context);
                    case 1:
                      return _buildSupplierDetailsTab(context);
                    case 2:
                      return _buildPurchasedItemsTab(context);
                    case 3:
                      return _buildTaxAndTotalsTab(context);
                    case 4:
                      return _buildPaymentDetailsTab(context);
                    case 5:
                      return _buildInternalNotesTab(context);
                    default:
                      return _buildReviewOverviewTab(context);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // STEPPER HEADER
  // ================================================================
  Widget _buildStepperHeader(BuildContext context) {
    final rs = context.rs;

    return Obx(() {
      final current = controller.currentStep.value;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
            vertical: rs.s(10), horizontal: rs.s(12)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
                ReviewPurchaseInvoiceController.steps.length, (index) {
              final isCurrent = current == index;
              final isCompleted = current > index;
              String label = ReviewPurchaseInvoiceController.steps[index];
              if (index == 0 && controller.purchaseNumber.value.isNotEmpty) {
                label = 'Review ${controller.purchaseNumber.value}';
              }

              return GestureDetector(
                onTap: () => controller.goToStep(index),
                child: Row(
                  children: [
                    Container(
                      width: rs.s(24),
                      height: rs.s(24),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? colorsList.colorButton
                            : (isCurrent
                                ? colorsList.colorButton
                                : const Color(0xFFF1F5F9)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? Icon(Icons.check_rounded,
                              color: Colors.white, size: rs.s(14))
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontSize: rs.sp(11),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    SizedBox(width: rs.s(6)),
                    Text(
                      label,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFF0A2342)
                            : const Color(0xFF64748B),
                        fontSize: rs.sp(12),
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (index < ReviewPurchaseInvoiceController.steps.length - 1)
                      Container(
                        width: rs.s(20),
                        height: 1,
                        margin: EdgeInsets.symmetric(horizontal: rs.s(8)),
                        color: isCompleted
                            ? colorsList.colorButton
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  // ================================================================
  // STEP BOTTOM NAVIGATION CONTROLS (BACK, SAVE DRAFT & CONTINUE)
  // ================================================================
  Widget _buildStepBottomControls({
    required bool isFirst,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment:
            isFirst ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirst)
            OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back'),
            ),
          Row(
            children: [
              // SAVE DRAFT BUTTON (ONLY SHOWN ON LAST STEP)
              if (isLast) ...[
                Obx(() {
                  final isDrafting = controller.isSavingDraft.value;

                  return OutlinedButton.icon(
                    onPressed: isDrafting ? null : controller.saveDraft,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: isDrafting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF0284C7)),
                          )
                        : const Icon(Icons.bookmark_outline_rounded, size: 16),
                    label: const Text(
                      'Save draft',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  );
                }),
                const SizedBox(width: 8),
              ],

              // CONTINUE / APPROVE & SAVE BUTTON
              Obx(() {
                final isSubmitting = controller.isApproving.value;

                return ElevatedButton(
                  onPressed: isSubmitting ? null : controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF063C70),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isLast ? 'Approve & Save' : 'Continue',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 1: REVIEW OVERVIEW (SCREENSHOTS 1, 2, 3 MATCHED 100%)
  // ================================================================
  Widget _buildReviewOverviewTab(BuildContext context) {
    final rs = context.rs;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CARD 1: READ FROM UPLOADED DOCUMENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Read from the uploaded document',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        '100% confident',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detected document',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                controller.documentType.value.capitalizeFirst ??
                                    'Invoice',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2342),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '"Invoices"',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Suggested classification',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Inventory',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0A2342),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' — ${controller.classificationReason.value}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.formatCurrency(controller.grandTotal.value)} matches the lines',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),

                // WARNING BOX FOR MISSING SUPPLIER
                Obx(() {
                  if (controller.selectedSupplier.value != null) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No matching supplier yet — choose one or create it from the document.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 2: CHECK AGAINST THE DOCUMENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check against the document',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 14),

                _checkRow(
                  label: 'Supplier',
                  val: controller.selectedSupplier.value?.name ?? '—',
                  src: null,
                  badge: controller.selectedSupplier.value != null
                      ? '100%'
                      : 'Not found',
                  isNotFound: controller.selectedSupplier.value == null,
                ),
                _checkRow(
                  label: 'Supplier invoice number',
                  val: controller.supplierInvoiceNumber.value.isNotEmpty
                      ? controller.supplierInvoiceNumber.value
                      : '—',
                  src: '"${controller.supplierInvoiceNumber.value}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'Supplier invoice date',
                  val: controller.supplierInvoiceDate.value.isNotEmpty
                      ? controller.supplierInvoiceDate.value
                      : '—',
                  src: '"${controller.supplierInvoiceDate.value}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'Currency',
                  val: controller.selectedCurrency.value,
                  src: '"${controller.selectedCurrency.value}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'Net total',
                  val: controller.formatCurrency(controller.netTotal.value),
                  src:
                      '"${controller.formatCurrency(controller.netTotal.value)}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'VAT total',
                  val: controller.formatCurrency(controller.taxTotal.value),
                  src:
                      '"${controller.formatCurrency(controller.taxTotal.value)}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'Total on the document',
                  val: controller.formatCurrency(controller.grandTotal.value),
                  src:
                      '"${controller.formatCurrency(controller.grandTotal.value)}"',
                  badge: '100%',
                ),
                _checkRow(
                  label: 'Document',
                  val: controller.documentType.value.capitalizeFirst ??
                      'Invoice',
                  src: '"Invoices"',
                  badge: '100%',
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 3: SUGGESTED ACCOUNTS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Suggested accounts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        '1 to check',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2342),
                            ),
                          ),
                          Text(
                            'Inventory / stores   55%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          children: [
                            const TextSpan(
                                text: 'Read from the item description · '),
                            TextSpan(
                              text:
                                  'Please choose the right account if this is not it.',
                              style: TextStyle(color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 4: HOW WAS THIS PAID?
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How was this paid?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The document says: "Paid". Nothing is recorded as paid until you confirm it here or match the bank transaction in Banking.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),

                Obx(() {
                  final sel = controller.paymentMethodOption.value;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _paymentOptBtn(
                          label: 'Paid by bank or card',
                          isSelected: sel == 'Paid by bank or card',
                          onTap: () => controller.paymentMethodOption.value =
                              'Paid by bank or card',
                        ),
                        const SizedBox(width: 8),
                        _paymentOptBtn(
                          label: 'Paid in cash',
                          isSelected: sel == 'Paid in cash',
                          onTap: () => controller.paymentMethodOption.value =
                              'Paid in cash',
                        ),
                        const SizedBox(width: 8),
                        _paymentOptBtn(
                          label: 'Not paid yet / match the bank transaction later',
                          isSelected: sel ==
                              'Not paid yet / match the bank transaction later',
                          onTap: () => controller.paymentMethodOption.value =
                              'Not paid yet / match the bank transaction later',
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 5: CONFIRM BEFORE APPROVING
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm before approving',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 10),

                Obx(
                  () => CheckboxListTile(
                    value: controller.isDocumentInvoiceChecked.value,
                    onChanged: (val) => controller
                        .isDocumentInvoiceChecked.value = val ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF063C70),
                    dense: true,
                    title: const Text(
                      'This document is a Invoice',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ),
                ),
                Obx(
                  () => CheckboxListTile(
                    value: controller.isCheckedAccountLinesChecked.value,
                    onChanged: (val) => controller
                        .isCheckedAccountLinesChecked.value = val ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF063C70),
                    dense: true,
                    title: const Text(
                      'I checked the account of every line',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Payment confirmed above.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // CARD 6: INVOICE VERIFICATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'Invoice verification',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2342),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Text(
                              'Verification incomplete',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text(
                        'Check again',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _metricCol('Critical / high', '0'),
                    _metricCol('Warnings', '0'),
                    _metricCol('Checks completed', '1/4'),
                    _metricCol('Last checked', '19/11/2026, 13:54'),
                  ],
                ),

                const Divider(height: 20, color: Color(0xFFF1F5F9)),

                _verifyRow('Supplier identity', 'Unavailable'),
                _verifyRow('Bank account', 'Not on the document'),
                _verifyRow('Duplicate invoice', 'Unavailable'),
                _verifyRow('Duplicate line items', 'Unavailable'),
                _verifyRow('Document integrity', 'Not assessed', isLast: true),

                const SizedBox(height: 10),

                const Text(
                  'These checks point out what to look at — they do not prove an invoice genuine or fraudulent.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // BOTTOM CONTROLS FOR STEP 1
          _buildStepBottomControls(isFirst: true, isLast: false),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 2: SUPPLIER DETAILS (FULLY EDITABLE WITH SUPPLIER LIST API)
  // ================================================================
  Widget _buildSupplierDetailsTab(BuildContext context) {
    final rs = context.rs;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supplier details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 14),

                // Supplier Picker Dropdown Button
                const Text(
                  'Supplier *',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final sel = controller.selectedSupplier.value;

                  return InkWell(
                    onTap: () => _showSupplierSearchSheet(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sel != null ? sel.name : 'Select supplier',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: sel != null
                                    ? const Color(0xFF0A2342)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                const Text(
                  'Supplier invoice number *',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.supplierInvoiceNumberController,
                  decoration: _inputDecoration(''),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Supplier invoice date',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.supplierInvoiceDateController.text =
                                    '${picked.day.toString().padLeft(2, '0')}.'
                                    '${picked.month.toString().padLeft(2, '0')}.'
                                    '${picked.year}';
                                setState(() {});
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colorsList.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.supplierInvoiceDateController
                                              .text.isNotEmpty
                                          ? controller
                                              .supplierInvoiceDateController.text
                                          : 'Select date',
                                      style: const TextStyle(
                                          fontSize: 13, color: Color(0xFF0A2342)),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined,
                                      size: 16, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Purchase date',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.purchaseDateController.text =
                                    '${picked.day.toString().padLeft(2, '0')}.'
                                    '${picked.month.toString().padLeft(2, '0')}.'
                                    '${picked.year}';
                                setState(() {});
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colorsList.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.purchaseDateController.text
                                              .isNotEmpty
                                          ? controller
                                              .purchaseDateController.text
                                          : 'Select date',
                                      style: const TextStyle(
                                          fontSize: 13, color: Color(0xFF0A2342)),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month_outlined,
                                      size: 16, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Currency selector
                const Text('Currency',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Obx(
                  () => InkWell(
                    onTap: () => _showCurrencySearchSheet(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.selectedCurrency.value,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2342)),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM CONTROLS FOR STEP 2
          _buildStepBottomControls(isFirst: false, isLast: false),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 3: PURCHASED ITEMS / SERVICES (FULLY EDITABLE WITH CATALOG API)
  // ================================================================
  Widget _buildPurchasedItemsTab(BuildContext context) {
    final rs = context.rs;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Purchased items / services',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: controller.addLineItem,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add line',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Obx(() {
                  final items = controller.purchaseLineItems;

                  return Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Item #${index + 1}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64748B)),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      controller.removeLineItem(index),
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Color(0xFFDC2626), size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () =>
                                  _showCatalogItemSearchSheet(context, index),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: colorsList.borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.itemController.text.isNotEmpty
                                            ? item.itemController.text
                                            : 'Select article from catalog',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: item
                                                  .itemController.text.isNotEmpty
                                              ? const Color(0xFF0A2342)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Color(0xFF64748B)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: item.descriptionController,
                              decoration: _inputDecoration('Description'),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: item.qtyController,
                                    decoration: _inputDecoration('Qty'),
                                    onChanged: (_) =>
                                        controller.purchaseLineItems.refresh(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: item.unitPriceController,
                                    decoration: _inputDecoration('Price'),
                                    onChanged: (_) =>
                                        controller.purchaseLineItems.refresh(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),

          // BOTTOM CONTROLS FOR STEP 3
          _buildStepBottomControls(isFirst: false, isLast: false),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 4: TAX & TOTALS
  // ================================================================
  Widget _buildTaxAndTotalsTab(BuildContext context) {
    final rs = context.rs;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        children: [
          Obx(() {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tax & totals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text(
                        controller.formatCurrency(controller.calculatedSubtotal),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tax',
                          style:
                              TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text(
                        controller.formatCurrency(controller.calculatedTaxTotal),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342)),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: Color(0xFFF1F5F9)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand total',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342)),
                      ),
                      Text(
                        controller.formatCurrency(controller.calculatedGrandTotal),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // BOTTOM CONTROLS FOR STEP 4
          _buildStepBottomControls(isFirst: false, isLast: false),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 5: PAYMENT DETAILS (EDITABLE)
  // ================================================================
  Widget _buildPaymentDetailsTab(BuildContext context) {
    final rs = context.rs;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Payment status *',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Obx(() {
                  final status = controller.paymentStatus.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorsList.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: ReviewPurchaseInvoiceController
                            .paymentStatusOptions
                            .map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF0A2342))),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.setPaymentStatus(val);
                        },
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),

                const Text('Paid from (bank or cash)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                const SizedBox(height: 6),
                Obx(() {
                  final paid = controller.paidFrom.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorsList.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: paid.contains('Choose') ? null : paid,
                        hint: Text(paid,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF94A3B8))),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: ReviewPurchaseInvoiceController.paidFromOptions
                            .map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF0A2342))),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.setPaidFrom(val);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // BOTTOM CONTROLS FOR STEP 5
          _buildStepBottomControls(isFirst: false, isLast: false),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 6: INTERNAL NOTES (EDITABLE)
  // ================================================================
  Widget _buildInternalNotesTab(BuildContext context) {
    final rs = context.rs;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs.pagePaddingH,
        rs.s(12),
        rs.pagePaddingH,
        rs.s(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Internal notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: controller.internalNotesController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: _inputDecoration(
                      'Internal notes (not shown to the supplier)'),
                ),
              ],
            ),
          ),

          // BOTTOM CONTROLS FOR STEP 6 (LAST STEP: APPROVE & SAVE)
          _buildStepBottomControls(isFirst: false, isLast: true),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================
  Widget _checkRow({
    required String label,
    required String val,
    required String? src,
    required String badge,
    bool isNotFound = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  val,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2342),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  src ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isNotFound
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isNotFound
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isNotFound
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
          ),
      ],
    );
  }

  Widget _paymentOptBtn({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _metricCol(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2342),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyRow(String label, String badge, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
    );
  }
}