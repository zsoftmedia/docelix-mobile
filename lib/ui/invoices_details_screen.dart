import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/invoices_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InvoicesDetailsScreen extends StatelessWidget {
  InvoicesDetailsScreen({super.key});

  final InvoicesDetailsController controller = Get.put(InvoicesDetailsController());

  static const Color _navyText = Color(0xFF0A2342);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

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
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: _navyText,
            ),
          ),
        ),
        title: Obx(
          () => Text(
            controller.invoice.value != null
                ? 'Invoice #${controller.invoice.value!.invoiceNumber}'
                : 'Invoice Details',
            style: TextStyle(
              fontSize: rs.sp(17),
              fontWeight: FontWeight.bold,
              color: _navyText,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.invoice.value == null) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (controller.invoice.value == null) {
          return Center(
            child: Text(
              'Invoice not found.',
              style: TextStyle(
                fontSize: rs.sp(14),
                color: _secondaryText,
              ),
            ),
          );
        }

        final invoice = controller.invoice.value!;
        final client = controller.client.value;

        return RefreshIndicator(
          onRefresh: controller.refreshInvoice,
          child: ResponsivePage(
            maxWidth: rs.isPhone ? null : double.infinity,
            padding: EdgeInsets.fromLTRB(
              rs.isPhone ? rs.pagePaddingH : 16.0,
              rs.s(8),
              rs.isPhone ? rs.pagePaddingH : 16.0,
              rs.s(32),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // 1. TOTAL INVOICE SUMMARY CARD (TOP CARD)
                  // ==================================================
                  _buildTotalInvoiceCard(context, invoice),

                  const SizedBox(height: 16),

                  // ==================================================
                  // 2. CUSTOMER & INVOICE INFORMATION CARDS
                  // ==================================================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 580;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCustomerCard(context, client, invoice)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInvoiceInfoCard(context, invoice)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildCustomerCard(context, client, invoice),
                          const SizedBox(height: 16),
                          _buildInvoiceInfoCard(context, invoice),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // 3. ITEMS CARD
                  // ==================================================
                  _buildItemsCard(context, invoice),

                  const SizedBox(height: 16),

                  // ==================================================
                  // 4. PAYMENT RECORD CARD
                  // ==================================================
                  _buildPaymentRecordCard(context, invoice),

                  if ((invoice.notes ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNotesCard(context, invoice.notes!),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      }),

      // ======================================================
      // STICKY BOTTOM ACTION BAR (MATCHING SCREENSHOT)
      // ======================================================
      bottomNavigationBar: Obx(() {
        if (controller.invoice.value == null) {
          return const SizedBox.shrink();
        }

        return _buildStickyBottomActionBar(context);
      }),
    );
  }

  // ================================================================
  // 1. TOTAL INVOICE SUMMARY CARD
  // ================================================================
  Widget _buildTotalInvoiceCard(BuildContext context, InvoicesModel invoice) {
    final rs = context.rs;
    final String statusStr = invoice.status.toLowerCase().trim();

    Color statusBg = const Color(0xFFECFDF5);
    Color statusBorder = const Color(0xFFA7F3D0);
    Color statusText = const Color(0xFF059669);
    String statusLabel = 'Paid in Full';

    if (statusStr == 'paid') {
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
      statusText = const Color(0xFF059669);
      statusLabel = 'Paid in Full';
    } else if (statusStr == 'pending' || statusStr == 'unpaid' || statusStr == 'draft') {
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
      statusText = const Color(0xFFD97706);
      statusLabel = statusStr.isEmpty ? 'Draft' : statusStr.capitalizeFirst!;
    } else if (statusStr == 'overdue') {
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusText = const Color(0xFFDC2626);
      statusLabel = 'Overdue';
    }

    final formattedDate = _formatDate(invoice.issueDate);
    final formattedDue = invoice.dueDate != null && invoice.dueDate!.isNotEmpty
        ? _formatDate(invoice.dueDate!)
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'TOTAL INVOICE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.formatCurrency(invoice.grossAmount, invoice.currencyCode),
            style: TextStyle(
              fontSize: rs.isPhone ? 26 : 30,
              fontWeight: FontWeight.bold,
              color: _navyText,
            ),
          ),
          const SizedBox(height: 8),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Issued on $formattedDate  ·  Due date: $formattedDue',
            style: const TextStyle(
              fontSize: 12,
              color: _secondaryText,
            ),
          ),

          const SizedBox(height: 20),

          // 3 ACTION BUTTONS ROW (Share, Download, Duplicate)
          Row(
            children: [
              Expanded(
                child: _actionBoxButton(
                  icon: Icons.upload_outlined,
                  label: 'Share',
                  onTap: controller.downloadEInvoice,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBoxButton(
                  icon: Icons.download_outlined,
                  label: 'Download',
                  onTap: controller.downloadInvoicePdf,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBoxButton(
                  icon: Icons.copy_rounded,
                  label: 'Duplicate',
                  onTap: () {
                    AppSnackbar.info(
                      title: 'Duplicate',
                      message: 'Duplicate feature is coming soon.',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBoxButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _navyText),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _navyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // 2A. CUSTOMER CARD
  // ================================================================
  Widget _buildCustomerCard(
    BuildContext context,
    ClientModel? client,
    InvoicesModel invoice,
  ) {
    final clientName = client?.name ?? 'no9r';
    final clientEmail = client?.email ?? 'test@gmail.com';
    final initials = _getClientInitials(clientName);
    final addressText = _getFormattedAddress(client);

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
                'CUSTOMER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed('/CustomersScreen');
                },
                child: const Row(
                  children: [
                    Text(
                      'Client profile',
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
                  color: Color(0xFFFDE68A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
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
                      clientEmail,
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
  Widget _buildInvoiceInfoCard(BuildContext context, InvoicesModel invoice) {
    final formattedIssue = _formatDate(invoice.issueDate);
    final formattedDue = invoice.dueDate != null && invoice.dueDate!.isNotEmpty
        ? _formatDate(invoice.dueDate!)
        : '—';
    final String statusStr = invoice.status.toLowerCase().trim();

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
            'INVOICE INFORMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          _infoRow('Invoice number', '#${invoice.invoiceNumber}', isBold: true),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Issue date', formattedIssue),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Due date', formattedDue),
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
              InkWell(
                onTap: controller.showStatusSelectionSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusStr == 'paid'
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusStr == 'paid'
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: statusStr == 'paid'
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusStr == 'paid'
                            ? 'Fully paid'
                            : (statusStr.isEmpty ? 'Draft' : statusStr.capitalizeFirst!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusStr == 'paid'
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
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
  // 3. ITEMS CARD
  // ================================================================
  Widget _buildItemsCard(BuildContext context, InvoicesModel invoice) {
    final items = controller.invoiceItems;
    final currency = invoice.currencyCode;

    final double itemsSubtotal = items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );

    final double vatTotal = items.fold(
      0.0,
      (sum, item) => sum + (item.grossAmount - (item.quantity * item.unitPrice)),
    );

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
                'ITEMS',
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
                child: Text(
                  items.length == 1 ? '1 item' : '${items.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (controller.isLoading.value && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _navyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Standard unit',
                        style: TextStyle(fontSize: 12, color: _secondaryText),
                      ),
                    ],
                  ),
                  Text(
                    controller.formatCurrency(invoice.grossAmount, currency),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _navyText,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemDesc.isNotEmpty
                                      ? item.itemDesc
                                      : 'Item #${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _navyText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Standard hardware unit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity.toInt()} × ${controller.formatCurrency(item.unitPrice > 0 ? item.unitPrice : item.grossAmount, currency)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            controller.formatCurrency(item.grossAmount, currency),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _navyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < items.length - 1)
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),
            ),

          const SizedBox(height: 14),

          // TOTALS SUMMARY CONTAINER INSIDE CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _totalsRow('Subtotal', controller.formatCurrency(itemsSubtotal > 0 ? itemsSubtotal : invoice.grossAmount, currency)),
                const SizedBox(height: 8),
                _totalsRow('VAT (0%)', controller.formatCurrency(vatTotal, currency)),
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
                      controller.formatCurrency(invoice.grossAmount, currency),
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
          ),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, String val) {
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
  // 4. PAYMENT RECORD CARD
  // ================================================================
  Widget _buildPaymentRecordCard(BuildContext context, InvoicesModel invoice) {
    final String statusStr = invoice.status.toLowerCase().trim();
    final bool isPaid = statusStr == 'paid';
    final double paidVal = invoice.paidAmount > 0 ? invoice.paidAmount : (isPaid ? invoice.grossAmount : 0.0);
    final double progressVal = invoice.grossAmount > 0 ? (paidVal / invoice.grossAmount).clamp(0.0, 1.0) : (isPaid ? 1.0 : 0.0);
    final int percentInt = (progressVal * 100).toInt();

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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
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
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Paid ',
                      style: TextStyle(
                        fontSize: 13,
                        color: _navyText,
                      ),
                    ),
                    TextSpan(
                      text: controller.formatCurrency(paidVal, invoice.currencyCode),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentInt%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: _secondaryText,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Marked as paid — no individual payment was recorded.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NOTES CARD
  // ================================================================
  Widget _buildNotesCard(BuildContext context, String notes) {
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
            'NOTES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: _secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STICKY BOTTOM ACTION BAR (MATCHING SCREENSHOT)
  // ================================================================
  Widget _buildStickyBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
            // MAIN ACTION BUTTON: SEND INVOICE
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.showStatusSelectionSheet();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2342),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text(
                  'Send Invoice',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // CIRCULAR EDIT BUTTON
            _circularActionButton(
              icon: Icons.edit_outlined,
              iconColor: _navyText,
              bgColor: const Color(0xFFF1F5F9),
              onTap: controller.showStatusSelectionSheet,
            ),

            const SizedBox(width: 8),

            // CIRCULAR DOWNLOAD BUTTON
            _circularActionButton(
              icon: Icons.download_outlined,
              iconColor: _navyText,
              bgColor: const Color(0xFFF1F5F9),
              onTap: controller.downloadInvoicePdf,
            ),

            const SizedBox(width: 8),

            // CIRCULAR DELETE BUTTON
            _circularActionButton(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEF2F2),
              onTap: controller.showDeleteConfirmation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularActionButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================
  String _getClientInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'CL';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _getFormattedAddress(ClientModel? client) {
    if (client == null) return 'test, test, 2522 Peshawar, Pakistan';
    final parts = [
      client.addressLine1,
      client.addressLine2,
      client.city,
      client.country,
    ].where((e) => (e ?? '').trim().isNotEmpty).toList();

    if (parts.isEmpty) return 'test, test, 2522 Peshawar, Pakistan';
    return parts.join(', ');
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '—';
    try {
      final parsed = DateTime.parse(date);
      return '${parsed.day.toString().padLeft(2, '0')}.'
          '${parsed.month.toString().padLeft(2, '0')}.'
          '${parsed.year}';
    } catch (_) {
      return date;
    }
  }
}