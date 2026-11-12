import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_manual_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePurchaseInvoiceManualScreen extends StatefulWidget {
  const CreatePurchaseInvoiceManualScreen({super.key});

  @override
  State<CreatePurchaseInvoiceManualScreen> createState() =>
      _CreatePurchaseInvoiceManualScreenState();
}

class _CreatePurchaseInvoiceManualScreenState
    extends State<CreatePurchaseInvoiceManualScreen> {
  final CreatePurchaseInvoiceManualController controller =
      Get.put(CreatePurchaseInvoiceManualController());

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
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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

  void _showCorrectsInvoiceSearchSheet(BuildContext context) {
    controller.correctsInvoiceSearchQuery.value = '';
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
                        'Corrects invoice',
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
                    onChanged: (val) => controller.correctsInvoiceSearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search purchase or invoice number...',
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
                              controller.correctsInvoiceSearchQuery.value = '';
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
                    if (controller.isLoadingSupplierInvoices.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final list = controller.filteredSupplierInvoices;

                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          'No invoices found for this supplier.',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final invoiceItem = list[index];
                        final isSelected = controller.selectedCorrectsInvoice.value?.id == invoiceItem.id;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            invoiceItem.displayText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                            ),
                          ),
                          subtitle: Text(
                            'Date: ${invoiceItem.purchaseDate} · Status: ${invoiceItem.status}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                              : null,
                          onTap: () {
                            controller.selectCorrectsInvoice(invoiceItem);
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
                        'Select Catalog Item',
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
                      hintText: 'Search catalog item name, code...',
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
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final catalog = list[index];
                        final titleStr = catalog.articleName ?? 'Unnamed Item';
                        final priceStr = controller.formatCurrency((catalog.unitPriceNet ?? 0).toDouble());

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            titleStr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0A2342),
                            ),
                          ),
                          subtitle: Text(
                            'Code: ${catalog.articleNumber ?? '—'} · Price: $priceStr',
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
              // 1. TOP HEADER BAR
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF063C70),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Enter Manually',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),

              SizedBox(height: rs.s(8)),

              // ======================================================
              // 2. MAIN TABS HEADER BAR (INVOICE, RECEIPT, CREDIT NOTE)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Obx(() {
                    final selectedIndex = controller.selectedTabIndex.value;

                    return Row(
                      children: List.generate(
                        CreatePurchaseInvoiceManualController.tabs.length,
                        (index) {
                          final isSelected = selectedIndex == index;
                          final tabLabel =
                              CreatePurchaseInvoiceManualController.tabs[index];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorsList.colorButton
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tabLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontSize: rs.sp(13),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: rs.s(16)),

              // ======================================================
              // 3. TAB CONTENT
              // ======================================================
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      return _buildInvoiceTab(context);
                    case 1:
                      return _buildReceiptTab(context);
                    case 2:
                      return _buildCreditNoteTab(context);
                    default:
                      return _buildInvoiceTab(context);
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
  // TAB 1: INVOICE WITH STEPPER
  // ================================================================

  Widget _buildInvoiceTab(BuildContext context) {
    final rs = context.rs;

    return Column(
      children: [
        // STEPPER HEADER FOR INVOICE TAB
        Obx(() {
          final currentStep = controller.currentInvoiceStep.value;

          return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: rs.s(10), horizontal: rs.s(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(CreatePurchaseInvoiceManualController.invoiceSteps.length, (index) {
                  final isCurrent = currentStep == index;
                  final isCompleted = currentStep > index;
                  final label = CreatePurchaseInvoiceManualController.invoiceSteps[index];

                  return GestureDetector(
                    onTap: () => controller.goToInvoiceStep(index),
                    child: Row(
                      children: [
                        Container(
                          width: rs.s(24),
                          height: rs.s(24),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? colorsList.colorButton
                                : (isCurrent ? colorsList.colorButton : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isCompleted
                              ? Icon(Icons.check_rounded, color: Colors.white, size: rs.s(14))
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                    fontSize: rs.sp(11),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(width: rs.s(6)),
                        Text(
                          label,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFF0A2342) : const Color(0xFF64748B),
                            fontSize: rs.sp(12),
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (index < CreatePurchaseInvoiceManualController.invoiceSteps.length - 1)
                          Container(
                            width: rs.s(20),
                            height: 1,
                            margin: EdgeInsets.symmetric(horizontal: rs.s(8)),
                            color: isCompleted ? colorsList.colorButton : const Color(0xFFE2E8F0),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        }),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // STEP CONTENT
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(rs.pagePaddingH, rs.s(14), rs.pagePaddingH, rs.s(40)),
            child: Obx(() {
              switch (controller.currentInvoiceStep.value) {
                case 0:
                  return _buildSupplierDetailsStep(context);
                case 1:
                  return _buildPurchasedItemsStep(context);
                case 2:
                  return _buildPaymentDetailsStep(context);
                case 3:
                  return _buildInternalNotesStep(context);
                default:
                  return _buildSupplierDetailsStep(context);
              }
            }),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // STEP 1: SUPPLIER DETAILS (MATCHING SCREENSHOT 100%)
  // ================================================================

  Widget _buildSupplierDetailsStep(BuildContext context) {
    final rs = context.rs;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.s(16)),
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
          // ROW 1: SUPPLIER*, SUPPLIER INVOICE DATE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: 'Supplier', required: true),
                    const SizedBox(height: 6),
                    Obx(() {
                      final selected = controller.selectedSupplier.value;

                      return InkWell(
                        onTap: () => _showSupplierSearchSheet(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                  selected != null ? selected.name : 'Select supplier',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selected != null ? const Color(0xFF0A2342) : const Color(0xFF94A3B8),
                                    fontWeight: selected != null ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: 'Supplier invoice date'),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                controller.supplierInvoiceDateController.text,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                              ),
                            ),
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // FULL WIDTH SELECTED SUPPLIER DETAILS CARD (MATCHING SCREENSHOT)
          Obx(() {
            final selected = controller.selectedSupplier.value;
            if (selected == null) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF059669)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          selected.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      if (selected.paymentTermsDays != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Text(
                            '${selected.paymentTermsDays} days payment terms',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  if ((selected.email ?? '').isNotEmpty || (selected.phone ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      [selected.email, selected.phone].where((e) => (e ?? '').trim().isNotEmpty).join(' · '),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
                    ),
                  ],
                  if ((selected.city ?? '').isNotEmpty || (selected.country ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      [selected.addressLine1, selected.city, selected.country].where((e) => (e ?? '').trim().isNotEmpty).join(', '),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
                    ),
                  ],
                  if ((selected.vatId ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'VAT ID: ${selected.vatId}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF047857)),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          // SUPPLIER INVOICE / CREDIT NOTE NUMBER & REFERENCE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => _FieldLabel(
                  text: controller.selectedTabIndex.value == 2 ? 'Credit note number' : 'Supplier invoice number',
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.selectedTabIndex.value == 2
                    ? controller.creditNoteNumberController
                    : controller.supplierInvoiceNumberController,
                decoration: _inputDecoration(''),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final noNum = controller.hasNoDocumentNumber.value;
                final currentCtrl = controller.selectedTabIndex.value == 2
                    ? controller.creditNoteNumberController
                    : controller.supplierInvoiceNumberController;
                final hasNum = currentCtrl.text.trim().isNotEmpty;

                if (!hasNum && !noNum) {
                  return const Text(
                    'Missing — enter it from the document, or confirm there is none.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFD97706)),
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(
                () => CheckboxListTile(
                  value: controller.hasNoDocumentNumber.value,
                  onChanged: (val) => controller.hasNoDocumentNumber.value = val ?? false,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF063C70),
                  dense: true,
                  title: const Text(
                    'The document has no number',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'Reference'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.referenceController,
                decoration: _inputDecoration(''),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ROW 2: PURCHASE DATE, DUE DATE, CURRENCY
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;

              final purchaseDateWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Purchase date'),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                              controller.purchaseDateController.text,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                            ),
                          ),
                          const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              final dueDateWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Due date'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.dueDateController.text =
                            '${picked.day.toString().padLeft(2, '0')}.'
                            '${picked.month.toString().padLeft(2, '0')}.'
                            '${picked.year}';
                        setState(() {});
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                              controller.dueDateController.text,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                            ),
                          ),
                          const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              final currencyWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(text: 'Currency'),
                  const SizedBox(height: 6),
                  Obx(
                    () => InkWell(
                      onTap: () => _showCurrencySearchSheet(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: purchaseDateWidget),
                    const SizedBox(width: 10),
                    Expanded(child: dueDateWidget),
                    const SizedBox(width: 10),
                    Expanded(child: currencyWidget),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: purchaseDateWidget),
                      const SizedBox(width: 10),
                      Expanded(child: dueDateWidget),
                    ],
                  ),
                  const SizedBox(height: 12),
                  currencyWidget,
                ],
              );
            },
          ),

          // CORRECTS INVOICE (ONLY FOR CREDIT NOTE TAB - SCREENSHOT)
          Obx(() {
            if (controller.selectedTabIndex.value != 2) return const SizedBox.shrink();

            final selectedSupplier = controller.selectedSupplier.value;
            final selectedInv = controller.selectedCorrectsInvoice.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const _FieldLabel(text: 'Corrects invoice'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: selectedSupplier != null
                      ? () {
                          controller.fetchSupplierInvoices(selectedSupplier.id);
                          _showCorrectsInvoiceSearchSheet(context);
                        }
                      : () {
                          AppSnackbar.info(
                            title: 'Select Supplier',
                            message: 'Please select a supplier first to view invoices.',
                          );
                        },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: selectedSupplier != null ? Colors.white : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorsList.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            selectedInv != null
                                ? selectedInv.displayText
                                : (selectedSupplier != null ? 'Choose the invoice (optional)' : 'Select a supplier first'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: selectedInv != null
                                  ? const Color(0xFF0A2342)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'When posted, the credit is applied to this invoice.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // ROW 3: IBAN, DELIVERY NOTE, ORDER REFERENCE IN VERTICAL COLUMN
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'IBAN on the document'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.ibanController,
                decoration: _inputDecoration(''),
              ),
              const SizedBox(height: 4),
              const Text(
                'As printed. Checked against the supplier\'s verified accounts — never trusted by itself.',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
              ),

              const SizedBox(height: 14),

              const _FieldLabel(text: 'Delivery note'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.deliveryNoteController,
                decoration: _inputDecoration(''),
              ),

              const SizedBox(height: 14),

              const _FieldLabel(text: 'Order reference'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.orderReferenceController,
                decoration: _inputDecoration(''),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ROW 4: SERVICE FROM & SERVICE TO (PROFESSIONAL DESIGN)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: 'Service from'),
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
                          controller.serviceFromDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}.'
                              '${picked.month.toString().padLeft(2, '0')}.'
                              '${picked.year}';
                          setState(() {});
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                controller.serviceFromDateController.text.isNotEmpty
                                    ? controller.serviceFromDateController.text
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: controller.serviceFromDateController.text.isNotEmpty
                                      ? const Color(0xFF0A2342)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel(text: 'Service to'),
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
                          controller.serviceToDateController.text =
                              '${picked.day.toString().padLeft(2, '0')}.'
                              '${picked.month.toString().padLeft(2, '0')}.'
                              '${picked.year}';
                          setState(() {});
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                controller.serviceToDateController.text.isNotEmpty
                                    ? controller.serviceToDateController.text
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: controller.serviceToDateController.text.isNotEmpty
                                      ? const Color(0xFF0A2342)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // STEPPER CONTROLS FOR INVOICE STEP 1
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF063C70),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 2: PURCHASED ITEMS / SERVICES (MATCHING SCREENSHOTS 1 & 2 100%)
  // ================================================================

  Widget _buildPurchasedItemsStep(BuildContext context) {
    final rs = context.rs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MAIN CARD CONTAINER
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(rs.s(16)),
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
              // TITLE & PRICES ENTERED (NET / GROSS TOGGLE) & SHOW ACCOUNT CODES
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 480;

                  final toggleWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Prices entered',
                        style: TextStyle(
                          fontSize: rs.sp(12),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // NET / GROSS SEGMENT TOGGLE
                      Container(
                        height: 34,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Obx(() {
                          final currentMode = controller.priceMode.value;

                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.setPriceMode('Net'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: currentMode == 'Net' ? const Color(0xFF063C70) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Net',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: currentMode == 'Net' ? FontWeight.bold : FontWeight.normal,
                                      color: currentMode == 'Net' ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.setPriceMode('Gross'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: currentMode == 'Gross' ? const Color(0xFF063C70) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Gross',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: currentMode == 'Gross' ? FontWeight.bold : FontWeight.normal,
                                      color: currentMode == 'Gross' ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  );

                  final checkboxWidget = Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: controller.showAccountCodes.value,
                          onChanged: (val) => controller.showAccountCodes.value = val ?? false,
                          activeColor: const Color(0xFF063C70),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Show account codes',
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        toggleWidget,
                        checkboxWidget,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      toggleWidget,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: checkboxWidget),
                    ],
                  );
                },
              ),

              // HELPER NOTE WHEN GROSS MODE IS SELECTED (SCREENSHOT 2)
              Obx(() {
                if (controller.priceMode.value != 'Gross') return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Enter prices including VAT — net and VAT are calculated from them.',
                    style: TextStyle(fontSize: rs.sp(11), color: const Color(0xFF64748B)),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // LINE ITEMS LIST
              Obx(() {
                final items = controller.purchaseLineItems;

                if (items.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF94A3B8)),
                        SizedBox(height: 8),
                        Text(
                          'No items added yet',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Click "+ Add line" below to add purchased items or services.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                }

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
                          // ITEM HEADER ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Item #${index + 1}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                              ),
                              IconButton(
                                onPressed: () => controller.removeLineItem(index),
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ITEM / SERVICE & DESCRIPTION
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Item / service'),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () => _showCatalogItemSearchSheet(context, index),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                                item.itemController.text.isNotEmpty
                                                    ? item.itemController.text
                                                    : 'Select item',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: item.itemController.text.isNotEmpty
                                                      ? const Color(0xFF0A2342)
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Description'),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: item.descriptionController,
                                      decoration: _inputDecoration('Description'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // QTY, UNIT PRICE (NET / GROSS), DISC %, TAX %
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Qty'),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: item.qtyController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration('1'),
                                      onChanged: (_) => controller.purchaseLineItems.refresh(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => _FieldLabel(
                                        text: 'Unit price (${controller.priceMode.value.toLowerCase()})',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: item.unitPriceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: _inputDecoration('0'),
                                      onChanged: (_) => controller.purchaseLineItems.refresh(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Disc. %'),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: item.discountController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration('0'),
                                      onChanged: (_) => controller.purchaseLineItems.refresh(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Tax %'),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      controller: item.taxRateController,
                                      keyboardType: TextInputType.number,
                                      decoration: _inputDecoration('20'),
                                      onChanged: (_) => controller.purchaseLineItems.refresh(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // PURCHASE CATEGORY & LINE TOTAL
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(text: 'Purchase category'),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: colorsList.borderColor),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: item.category.value,
                                            isExpanded: true,
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                            items: CreatePurchaseInvoiceManualController.purchaseCategoryOptions.map((cat) {
                                              return DropdownMenuItem<String>(
                                                value: cat,
                                                child: Text(cat, style: const TextStyle(fontSize: 12, color: Color(0xFF0A2342))),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val != null) item.category.value = val;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Line total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                    const SizedBox(height: 4),
                                    Obx(() {
                                      final qty = double.tryParse(item.qtyController.text) ?? 1;
                                      final price = double.tryParse(item.unitPriceController.text) ?? 0;
                                      final disc = double.tryParse(item.discountController.text) ?? 0;
                                      final taxRate = double.tryParse(item.taxRateController.text) ?? 20;

                                      final isGross = controller.priceMode.value == 'Gross';

                                      double lineTotal = 0;
                                      double lineVat = 0;

                                      if (!isGross) {
                                        final net = qty * price * (1 - disc / 100);
                                        lineVat = net * (taxRate / 100);
                                        lineTotal = net + lineVat;
                                      } else {
                                        lineTotal = qty * price * (1 - disc / 100);
                                        final net = lineTotal / (1 + taxRate / 100);
                                        lineVat = lineTotal - net;
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            controller.formatCurrency(lineTotal),
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                                          ),
                                          if (isGross) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              '· VAT ${controller.formatCurrency(lineVat)}',
                                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ],
                                      );
                                    }),
                                  ],
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

              const SizedBox(height: 12),

              // + ADD LINE BUTTON & HINT
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: controller.addLineItem,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0A2342),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add line', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Enter: next line · ↑/↓: move between lines',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TAX & TOTALS SUMMARY CARD (MATCHING SCREENSHOTS 1 & 2)
        Obx(() {
          return Container(
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
                  'Tax & totals',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      controller.formatCurrency(controller.calculatedSubtotal),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      controller.formatCurrency(controller.calculatedTaxTotal),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand total',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                    Text(
                      controller.formatCurrency(controller.calculatedGrandTotal),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount paid', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      controller.formatCurrency(controller.amountPaid),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Outstanding balance', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      controller.formatCurrency(controller.outstandingBalance),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // STEPPER CONTROLS (BACK & CONTINUE)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063C70),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // STEP 3: PAYMENT DETAILS & SUPPORTING DOCUMENT (MATCHING SCREENSHOT 100%)
  // ================================================================

  Widget _buildPaymentDetailsStep(BuildContext context) {
    final rs = context.rs;

    final paymentCard = Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.s(16)),
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
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF063C70),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Payment details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // PAYMENT STATUS & CONDITIONAL FIELDS
          Obx(() {
            final status = controller.paymentStatus.value;

            final statusDropdown = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(text: 'Payment status'),
                const SizedBox(height: 6),
                Container(
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
                      items: CreatePurchaseInvoiceManualController.paymentStatusOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt, style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.setPaymentStatus(val);
                      },
                    ),
                  ),
                ),
                if (status == 'Paid in full') ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Payment recorded when posted',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ],
            );

            final paidFromDropdown = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(text: 'Paid from (bank or cash)'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorsList.borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.paidFrom.value.contains('bank') && controller.paidFrom.value != 'Bank' && controller.paidFrom.value != 'Cash'
                          ? null
                          : controller.paidFrom.value,
                      hint: Text(
                        controller.paidFrom.value,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: CreatePurchaseInvoiceManualController.paidFromOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt, style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) controller.setPaidFrom(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Required for a paid purchase.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            );

            final amountPaidWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(text: 'Amount paid'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.amountPaidController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('0.00'),
                ),
              ],
            );

            final paymentDateWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(text: 'Payment date'),
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
                      controller.paymentDateController.text =
                          '${picked.day.toString().padLeft(2, '0')}.'
                          '${picked.month.toString().padLeft(2, '0')}.'
                          '${picked.year}';
                      setState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                            controller.paymentDateController.text.isNotEmpty
                                ? controller.paymentDateController.text
                                : 'Same as purchase date',
                            style: TextStyle(
                              fontSize: 13,
                              color: controller.paymentDateController.text.isNotEmpty
                                  ? const Color(0xFF0A2342)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ],
            );

            final referenceWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel(text: 'Reference (optional)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.paymentReferenceController,
                  decoration: _inputDecoration('e.g. bank transfer ID'),
                ),
              ],
            );

            if (status == 'Unpaid') {
              return statusDropdown;
            }

            if (status == 'Partially paid') {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: statusDropdown),
                      const SizedBox(width: 10),
                      Expanded(child: amountPaidWidget),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: paidFromDropdown),
                      const SizedBox(width: 10),
                      Expanded(child: paymentDateWidget),
                    ],
                  ),
                  const SizedBox(height: 14),
                  referenceWidget,
                ],
              );
            }

            // PAID IN FULL (MATCHING SCREENSHOT 100%)
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: statusDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: paidFromDropdown),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: paymentDateWidget),
                    const SizedBox(width: 10),
                    Expanded(child: referenceWidget),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );

    final supportingDocumentCard = Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.s(16)),
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
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF063C70),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('4', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Supporting document',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DASHED ATTACHMENT UPLOAD BOX OR ATTACHED FILE CARD
          Obx(() {
            final fileName = controller.attachedDocumentName.value;

            if (fileName != null && fileName.isNotEmpty) {
              final ext = fileName.split('.').last.toLowerCase();
              IconData iconData = Icons.insert_drive_file_rounded;
              Color iconColor = const Color(0xFF2563EB);

              if (ext == 'pdf') {
                iconData = Icons.picture_as_pdf_rounded;
                iconColor = const Color(0xFFDC2626);
              } else if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
                iconData = Icons.image_rounded;
                iconColor = const Color(0xFF059669);
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Document attached successfully',
                            style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: controller.removeSupportingDocument,
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    ),
                  ],
                ),
              );
            }

            return InkWell(
              onTap: controller.pickSupportingDocument,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file_rounded, size: 28, color: Color(0xFF0A2342)),
                    SizedBox(height: 8),
                    Text(
                      'Attach or scan document',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PDF, JPG or PNG of the supplier invoice or receipt (max 15 MB).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        paymentCard,
        const SizedBox(height: 16),
        supportingDocumentCard,
        const SizedBox(height: 24),

        // STEPPER CONTROLS (BACK & CONTINUE)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: controller.previousStep,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF063C70),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // STEP 4: INTERNAL NOTES (MATCHING SCREENSHOT 100%)
  // ================================================================

  Widget _buildInternalNotesStep(BuildContext context) {
    final rs = context.rs;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.s(16)),
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
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF063C70),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '5',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Internal notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: controller.internalNotesController,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
            decoration: InputDecoration(
              hintText: 'Internal notes (not shown to the supplier)',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              isDense: true,
              contentPadding: const EdgeInsets.all(16),
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

          const SizedBox(height: 24),

          // STEPPER CONTROLS (BACK & SAVE PURCHASE INVOICE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back'),
              ),
              Obx(() {
                final isSubmitting = controller.isSubmittingInvoice.value;

                return ElevatedButton(
                  onPressed: isSubmitting ? null : controller.submitPurchaseInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF063C70),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Purchase Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TAB 2: RECEIPT WITH STEPPER (SAME AS INVOICE TAB)
  // ================================================================

  Widget _buildReceiptTab(BuildContext context) {
    final rs = context.rs;

    return Column(
      children: [
        // STEPPER HEADER FOR RECEIPT TAB
        Obx(() {
          final currentStep = controller.currentReceiptStep.value;

          return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: rs.s(10), horizontal: rs.s(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(CreatePurchaseInvoiceManualController.receiptSteps.length, (index) {
                  final isCurrent = currentStep == index;
                  final isCompleted = currentStep > index;
                  final label = CreatePurchaseInvoiceManualController.receiptSteps[index];

                  return GestureDetector(
                    onTap: () => controller.goToReceiptStep(index),
                    child: Row(
                      children: [
                        Container(
                          width: rs.s(24),
                          height: rs.s(24),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? colorsList.colorButton
                                : (isCurrent ? colorsList.colorButton : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isCompleted
                              ? Icon(Icons.check_rounded, color: Colors.white, size: rs.s(14))
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                    fontSize: rs.sp(11),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(width: rs.s(6)),
                        Text(
                          label,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFF0A2342) : const Color(0xFF64748B),
                            fontSize: rs.sp(12),
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (index < CreatePurchaseInvoiceManualController.receiptSteps.length - 1)
                          Container(
                            width: rs.s(20),
                            height: 1,
                            margin: EdgeInsets.symmetric(horizontal: rs.s(8)),
                            color: isCompleted ? colorsList.colorButton : const Color(0xFFE2E8F0),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        }),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // STEP CONTENT FOR RECEIPT
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(rs.pagePaddingH, rs.s(14), rs.pagePaddingH, rs.s(40)),
            child: Obx(() {
              switch (controller.currentReceiptStep.value) {
                case 0:
                  return _buildSupplierDetailsStep(context);
                case 1:
                  return _buildPurchasedItemsStep(context);
                case 2:
                  return _buildPaymentDetailsStep(context);
                case 3:
                  return _buildInternalNotesStep(context);
                default:
                  return _buildSupplierDetailsStep(context);
              }
            }),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // TAB 3: CREDIT NOTE WITH STEPPER (MATCHING SCREENSHOT 100%)
  // ================================================================

  Widget _buildCreditNoteTab(BuildContext context) {
    final rs = context.rs;

    return Column(
      children: [
        // STEPPER HEADER FOR CREDIT NOTE TAB
        Obx(() {
          final currentStep = controller.currentCreditNoteStep.value;

          return Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: rs.s(10), horizontal: rs.s(12)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(CreatePurchaseInvoiceManualController.creditNoteSteps.length, (index) {
                  final isCurrent = currentStep == index;
                  final isCompleted = currentStep > index;
                  final label = CreatePurchaseInvoiceManualController.creditNoteSteps[index];

                  return GestureDetector(
                    onTap: () => controller.goToCreditNoteStep(index),
                    child: Row(
                      children: [
                        Container(
                          width: rs.s(24),
                          height: rs.s(24),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? colorsList.colorButton
                                : (isCurrent ? colorsList.colorButton : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isCompleted
                              ? Icon(Icons.check_rounded, color: Colors.white, size: rs.s(14))
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                    fontSize: rs.sp(11),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(width: rs.s(6)),
                        Text(
                          label,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFF0A2342) : const Color(0xFF64748B),
                            fontSize: rs.sp(12),
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (index < CreatePurchaseInvoiceManualController.creditNoteSteps.length - 1)
                          Container(
                            width: rs.s(20),
                            height: 1,
                            margin: EdgeInsets.symmetric(horizontal: rs.s(8)),
                            color: isCompleted ? colorsList.colorButton : const Color(0xFFE2E8F0),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        }),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // STEP CONTENT FOR CREDIT NOTE
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(rs.pagePaddingH, rs.s(14), rs.pagePaddingH, rs.s(40)),
            child: Obx(() {
              switch (controller.currentCreditNoteStep.value) {
                case 0:
                  return _buildSupplierDetailsStep(context);
                case 1:
                  return _buildPurchasedItemsStep(context);
                case 2:
                  return _buildPaymentDetailsStep(context);
                case 3:
                  return _buildInternalNotesStep(context);
                default:
                  return _buildSupplierDetailsStep(context);
              }
            }),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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