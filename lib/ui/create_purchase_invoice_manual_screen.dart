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
              // 2. TABS HEADER BAR (MATCHING SCREENSHOT)
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
  // TAB 1: INVOICE
  // ================================================================

  Widget _buildInvoiceTab(BuildContext context) {
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
            Text(
              'Purchase Invoice Details',
              style: TextStyle(
                fontSize: rs.sp(16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A2342),
              ),
            ),
            SizedBox(height: rs.s(4)),
            Text(
              'Enter purchase invoice details manually.',
              style: TextStyle(
                fontSize: rs.sp(12),
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: rs.s(16)),
          ],
        ),
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
            Text(
              'Receipt Details',
              style: TextStyle(
                fontSize: rs.sp(16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A2342),
              ),
            ),
            SizedBox(height: rs.s(4)),
            Text(
              'Enter receipt details manually.',
              style: TextStyle(
                fontSize: rs.sp(12),
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: rs.s(16)),
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
            Text(
              'Credit Note Details',
              style: TextStyle(
                fontSize: rs.sp(16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A2342),
              ),
            ),
            SizedBox(height: rs.s(4)),
            Text(
              'Enter credit note details manually.',
              style: TextStyle(
                fontSize: rs.sp(12),
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: rs.s(16)),
          ],
        ),
      ),
    );
  }
}