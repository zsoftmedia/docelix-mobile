import 'package:docelix_mobileapp/controllers/create_purchase_invoice_manual_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
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

          // SUPPLIER INVOICE NUMBER & REFERENCE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(text: 'Supplier invoice number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.supplierInvoiceNumberController,
                decoration: _inputDecoration(''),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final noNum = controller.hasNoDocumentNumber.value;
                final hasNum = controller.supplierInvoiceNumberController.text.trim().isNotEmpty;

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
                onPressed: controller.nextInvoiceStep,
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
  // STEP 2: PURCHASED ITEMS / SERVICES (PLACEHOLDER FOR NEXT STEP)
  // ================================================================

  Widget _buildPurchasedItemsStep(BuildContext context) {
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
          const Text('Purchased Items / Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousInvoiceStep,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: controller.nextInvoiceStep,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF063C70), foregroundColor: Colors.white),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 3: PAYMENT DETAILS (PLACEHOLDER FOR NEXT STEP)
  // ================================================================

  Widget _buildPaymentDetailsStep(BuildContext context) {
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
          const Text('Payment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousInvoiceStep,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: controller.nextInvoiceStep,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF063C70), foregroundColor: Colors.white),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STEP 4: INTERNAL NOTES (PLACEHOLDER FOR NEXT STEP)
  // ================================================================

  Widget _buildInternalNotesStep(BuildContext context) {
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
          const Text('Internal Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: controller.previousInvoiceStep,
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: controller.submitPurchaseInvoice,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF063C70), foregroundColor: Colors.white),
                child: const Text('Save Purchase Invoice'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TAB 2: RECEIPT
  // ================================================================

  Widget _buildReceiptTab(BuildContext context) {
    final rs = context.rs;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(rs.s(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2342),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Enter receipt details manually.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TAB 3: CREDIT NOTE
  // ================================================================

  Widget _buildCreditNoteTab(BuildContext context) {
    final rs = context.rs;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(rs.s(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credit Note Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2342),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Enter credit note details manually.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
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