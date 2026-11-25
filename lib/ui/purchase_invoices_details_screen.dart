import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/purchase_invoices_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PurchaseInvoicesDetailsScreen extends StatefulWidget {
  final PurchaseInvoicesModel invoice;

  const PurchaseInvoicesDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<PurchaseInvoicesDetailsScreen> createState() =>
      _InvoicesDetailsScreenState();
}

class _InvoicesDetailsScreenState extends State<PurchaseInvoicesDetailsScreen> {
  late PurchaseInvoicesDetailsController controller;

  static const Color _navyText = Color(0xFF0A2342);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      PurchaseInvoicesDetailsController(),
    );

    controller.initialize(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final item = widget.invoice;

    final String purNumberStr = item.purchaseNumber ??
        item.supplierInvoiceNumber ??
        item.invoiceNumber ??
        '${item.id}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: _navyText,
            ),
          ),
        ),
        title: Text(
          'Purchase #$purNumberStr',
          style: TextStyle(
            fontSize: rs.sp(17),
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ResponsivePage(
                maxWidth: rs.isPhone ? null : double.infinity,
                padding: EdgeInsets.fromLTRB(
                  rs.isPhone ? rs.pagePaddingH : 16.0,
                  rs.s(8),
                  rs.isPhone ? rs.pagePaddingH : 16.0,
                  rs.s(32),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====================================================
                      // 1. TOP HEADER & STATUS SUMMARY CARD
                      // ====================================================
                      _buildHeaderCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 2. SUPPLIER & PURCHASE INFORMATION CARDS
                      // ====================================================
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 580;

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildSupplierCard(context, item)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildInvoiceInfoCard(context, item)),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _buildSupplierCard(context, item),
                              const SizedBox(height: 16),
                              _buildInvoiceInfoCard(context, item),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 3. PURCHASED ITEMS / SERVICES CARD
                      // ====================================================
                      _buildLineItemsCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 4. TAX & TOTALS CARD
                      // ====================================================
                      _buildTotalsCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 5. PAYMENT RECORD CARD
                      // ====================================================
                      _buildPaymentRecordCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 6. HISTORY CARD
                      // ====================================================
                      _buildHistoryCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 7. INVOICE DOCUMENT PREVIEW CARD
                      // ====================================================
                      _buildDocumentCard(context, item),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // ========================================================
            // STICKY BOTTOM ACTIONS BAR (DELETE & VIEW DOCUMENT)
            // ========================================================
            Obx(() {
              final String currentStatus =
                  controller.status.value.toLowerCase().trim();
              final bool isDraft = currentStatus == 'draft';

              return Container(
                padding: EdgeInsets.fromLTRB(
                  rs.isPhone ? 16 : 20,
                  12,
                  rs.isPhone ? 16 : 20,
                  16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: _cardBorder),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // VIEW DOCUMENT BUTTON
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final previewUrl = item.previewUrl;
                            if (previewUrl == null || previewUrl.isEmpty) {
                              AppSnackbar.info(
                                title: 'Document',
                                message: 'Document preview is not available.',
                              );
                              return;
                            }

                            showInvoiceDocumentDialog(
                              context: context,
                              fileUrl: previewUrl,
                              fileType: item.fileType,
                              mimeType: item.mimeType,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navyText,
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: EdgeInsets.symmetric(
                                vertical: rs.isPhone ? 12 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                          label: const Text(
                            'View Document',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (isDraft) ...[
                        const SizedBox(width: 12),
                        // DELETE BUTTON
                        Expanded(
                          child: Obx(
                            () => ElevatedButton.icon(
                              onPressed: controller.isDeleting.value
                                  ? null
                                  : controller.deleteInvoice,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                    vertical: rs.isPhone ? 12 : 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: controller.isDeleting.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline_rounded,
                                      size: 18),
                              label: Text(
                                controller.isDeleting.value
                                    ? 'Deleting...'
                                    : 'Delete Invoice',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // 1. TOP HEADER & STATUS SUMMARY CARD
  // ================================================================
  Widget _buildHeaderCard(BuildContext context, PurchaseInvoicesModel item) {
    final rs = context.rs;
    final currency = item.currency ?? 'EUR';
    final amount = item.totalAmount ?? 0;
    final formattedAmt = '$currency ${amount.toStringAsFixed(2)}';

    final formattedIssue = _formatDate(item.invoiceDate);
    final formattedDue = _formatDate(item.dueDate);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.isPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL PURCHASE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formattedAmt,
              style: TextStyle(
                fontSize: rs.isPhone ? 24 : 30,
                fontWeight: FontWeight.bold,
                color: _navyText,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Status Badge Pill
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: controller.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: controller.statusColor.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: controller.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.displayStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: controller.statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Issued on $formattedIssue  ·  Due date: $formattedDue',
            style: TextStyle(
              fontSize: rs.isPhone ? 11.5 : 12,
              color: _secondaryText,
            ),
          ),

          const SizedBox(height: 18),

          // 2 ACTION BUTTONS ROW (View Document, Delete)
          Row(
            children: [
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.remove_red_eye_outlined,
                  label: 'View Document',
                  onTap: () {
                    final docUrl = item.previewUrl;
                    if (docUrl == null || docUrl.isEmpty) {
                      AppSnackbar.info(
                        title: 'Document',
                        message: 'Document preview is not available.',
                      );
                      return;
                    }

                    showInvoiceDocumentDialog(
                      context: context,
                      fileUrl: docUrl,
                      fileType: item.fileType,
                      mimeType: item.mimeType,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFDC2626),
                  label: 'Delete Invoice',
                  onTap: controller.deleteInvoice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBoxButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final rs = context.rs;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs.isPhone ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: rs.isPhone ? 18 : 20, color: iconColor ?? _navyText),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: rs.isPhone ? 11.5 : 12,
                fontWeight: FontWeight.w600,
                color: iconColor ?? _navyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // 2A. SUPPLIER CARD
  // ================================================================
  Widget _buildSupplierCard(BuildContext context, PurchaseInvoicesModel item) {
    final suppName = item.supplierName ?? 'Supplier';
    final initials = _getSupplierInitials(suppName);
    final email = item.supplierEmail ?? 'anees@gmail.com';
    final addressText = _getSupplierAddress(item);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
              const Text(
                'SUPPLIER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed('/SuppliersScreen');
                },
                child: const Row(
                  children: [
                    Text(
                      'Supplier profile',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryText,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: _secondaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF007A55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suppName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Address Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: _secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    addressText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _secondaryText,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: addressText));
                    AppSnackbar.success(
                      title: 'Copied',
                      message: 'Address copied to clipboard.',
                    );
                  },
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2B. INVOICE INFORMATION CARD
  // ================================================================
  Widget _buildInvoiceInfoCard(BuildContext context, PurchaseInvoicesModel item) {
    final invNo = item.supplierInvoiceNumber ?? item.invoiceNumber ?? '—';
    final purNo = item.purchaseNumber ?? '—';
    final invDate = _formatDate(item.invoiceDate);
    final dueDate = _formatDate(item.dueDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
            'PURCHASE INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          _infoRow('Purchase number', purNo, isBold: true),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Supplier inv number', invNo),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Issue date', invDate),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Due date', dueDate),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment status',
                style: TextStyle(
                  fontSize: 13,
                  color: _secondaryText,
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.statusColor.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.displayStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: controller.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: _navyText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // 3. PURCHASED ITEMS / SERVICES CARD
  // ================================================================
  Widget _buildLineItemsCard(BuildContext context, PurchaseInvoicesModel item) {
    final currency = item.currency ?? 'EUR';
    final amount = item.totalAmount ?? 0;
    final formattedAmt = '$currency ${amount.toStringAsFixed(2)}';
    final suppName = item.supplierName ?? 'Peshawar Electric Supply Company';
    final categoryStr = item.expenseAccountCode ?? item.expenseCategory ?? '5000 · Operating expenses';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
              const Text(
                'PURCHASED ITEMS / SERVICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '1 item',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase - $suppName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 × $formattedAmt',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedAmt,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _navyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 4. TAX & TOTALS CARD
  // ================================================================
  Widget _buildTotalsCard(BuildContext context, PurchaseInvoicesModel item) {
    final currency = item.currency ?? 'EUR';
    final amount = item.totalAmount ?? 0;
    final formattedAmt = '$currency ${amount.toStringAsFixed(2)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
            'TAX & TOTALS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          _totalRow('Subtotal', formattedAmt),
          const SizedBox(height: 8),
          _totalRow('Tax', '$currency 0.00'),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _navyText,
                ),
              ),
              Text(
                formattedAmt,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _navyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _secondaryText,
          ),
        ),
        Text(
          val,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _navyText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // 5. PAYMENT RECORD CARD
  // ================================================================
  Widget _buildPaymentRecordCard(BuildContext context, PurchaseInvoicesModel item) {
    final statusStr = item.status.toLowerCase().trim();
    final bool isPaid = statusStr == 'posted' || statusStr == 'paid';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
              const Text(
                'PAYMENT RECORD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPaid ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  isPaid ? 'Fully paid' : 'Unpaid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            'No individual payment recorded.',
            style: TextStyle(
              fontSize: 12.5,
              color: _secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 6. HISTORY CARD
  // ================================================================
  Widget _buildHistoryCard(BuildContext context, PurchaseInvoicesModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HISTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _historyRow('Created', _formatDate(item.uploadedAt)),
          _historyRow('Approved', '—'),
          _historyRow('Posted to ledger', '—'),
        ],
      ),
    );
  }

  // ================================================================
  // 7. INVOICE DOCUMENT PREVIEW CARD
  // ================================================================
  Widget _buildDocumentCard(
    BuildContext context,
    PurchaseInvoicesModel item,
  ) {
    final rs = context.rs;
    final docUrl = item.previewUrl ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
            'INVOICE DOCUMENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () {
              if (docUrl.isEmpty) {
                AppSnackbar.info(
                  title: 'Document',
                  message: 'Document not available for this invoice.',
                );
                return;
              }

              showInvoiceDocumentDialog(
                context: context,
                fileUrl: docUrl,
                fileType: item.fileType,
                mimeType: item.mimeType,
              );
            },
            child: Container(
              width: double.infinity,
              height: rs.isPhone ? 160 : 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.fileType == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_outlined,
                      color: item.fileType == 'pdf'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF063C70),
                      size: 48,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.fileName.isNotEmpty
                                ? item.fileName
                                : 'Attachment Document',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navyText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              color: Color(0xFF063C70),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _secondaryText)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _navyText)),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================
  String _getSupplierInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _getSupplierAddress(PurchaseInvoicesModel item) {
    final parts = [
      item.supplierAddressLine1,
      item.supplierAddressLine2,
      item.supplierCity,
      item.supplierPostal,
      item.supplierCountry,
    ].where((e) => (e ?? '').trim().isNotEmpty).toList();

    if (parts.isEmpty) return 'Peshawar Saddar, Islamabad, Pakistan';
    return parts.join(', ');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      return '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ================================================================
// DOCUMENT PREVIEW DIALOG
// ================================================================
void showInvoiceDocumentDialog({
  required BuildContext context,
  required String fileUrl,
  required String fileType,
  required String mimeType,
}) {
  final rs = context.rs;
  final bool isPdf = fileType.toLowerCase() == 'pdf' ||
      mimeType.toLowerCase() == 'application/pdf';

  final bool isImage = mimeType.toLowerCase().startsWith('image/') ||
      ['jpg', 'jpeg', 'png', 'webp'].contains(fileType.toLowerCase());

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (context) {
      return ResponsiveDialogBody(
        maxWidth: rs.sheetMaxWidth + 80,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: rs.isPhone ? 16 : 48,
            vertical: rs.isPhone ? 24 : 40,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: rs.height * 0.82,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_outlined,
                          color: isPdf
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF063C70),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Invoice Document',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPdf ? 'PDF Document' : 'Image Document',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFFF3F5F8),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    child: _buildDocumentPreview(
                      fileUrl: fileUrl,
                      isPdf: isPdf,
                      isImage: isImage,
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
}

Widget _buildDocumentPreview({
  required String fileUrl,
  required bool isPdf,
  required bool isImage,
}) {
  if (isPdf) {
    return SfPdfViewer.network(fileUrl);
  }

  if (isImage) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 50,
                  color: Color(0xFF64748B),
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to load document.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  return const Center(
    child: Text(
      'Unsupported document format.',
      style: TextStyle(color: Color(0xFF64748B)),
    ),
  );
}