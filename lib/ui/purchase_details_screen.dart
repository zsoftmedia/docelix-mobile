import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/purchase_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  const PurchaseDetailsScreen({super.key});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final PurchaseDetailsController controller =
      Get.put(PurchaseDetailsController());

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
            controller.purchase.value != null
                ? 'Purchase #${controller.purchase.value!.purchaseNumber}'
                : 'Purchase Details',
            style: TextStyle(
              fontSize: rs.sp(17),
              fontWeight: FontWeight.bold,
              color: _navyText,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final item = controller.purchase.value;

        if (item == null) {
          return const Center(
            child: Text(
              'Purchase information not available.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 15,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final currentId = controller.purchase.value?.id;
            if (currentId != null && currentId > 0) {
              await controller.fetchPurchaseDetails(currentId);
            }
          },
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
                  // ====================================================
                  // 1. TOTAL PURCHASE SUMMARY CARD (TOP CARD)
                  // ====================================================
                  _buildTotalPurchaseCard(context, item),

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
                            Expanded(child: _buildPurchaseInfoCard(context, item)),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildSupplierCard(context, item),
                          const SizedBox(height: 16),
                          _buildPurchaseInfoCard(context, item),
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
                  // 4. TAX & TOTALS SUMMARY CARD
                  // ====================================================
                  _buildTotalsCard(context, item),

                  const SizedBox(height: 16),

                  // ====================================================
                  // 5. PAYMENTS & HISTORY CARDS
                  // ====================================================
                  _buildPaymentsCard(context, item),

                  const SizedBox(height: 16),

                  _buildHistoryCard(context, item),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. TOTAL PURCHASE SUMMARY CARD
  // ================================================================
  Widget _buildTotalPurchaseCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final String statusStr = item.status.toLowerCase().trim();
    final String payStatusStr = item.paymentStatus?.toLowerCase().trim() ??
        (statusStr == 'posted' ? 'paid' : 'unpaid');

    Color statusBg = const Color(0xFFECFDF5);
    Color statusBorder = const Color(0xFFA7F3D0);
    Color statusText = const Color(0xFF059669);
    String statusLabel = 'Paid';

    if (payStatusStr == 'paid' || statusStr == 'posted') {
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
      statusText = const Color(0xFF059669);
      statusLabel = 'Paid';
    } else if (payStatusStr == 'unpaid' || statusStr == 'draft') {
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
      statusText = const Color(0xFFD97706);
      statusLabel = statusStr == 'draft' ? 'Draft' : 'Unpaid';
    } else if (statusStr == 'overdue' || statusStr == 'rejected') {
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusText = const Color(0xFFDC2626);
      statusLabel = 'Overdue';
    }

    final formattedIssue = _formatDate(item.purchaseDate);
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
              controller.formatCurrency(item.total, item.currency),
              style: TextStyle(
                fontSize: rs.isPhone ? 24 : 30,
                fontWeight: FontWeight.bold,
                color: _navyText,
              ),
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
            'Issued on $formattedIssue  ·  Due date: $formattedDue',
            style: TextStyle(
              fontSize: rs.isPhone ? 11.5 : 12,
              color: _secondaryText,
            ),
          ),

          //const SizedBox(height: 18),

          // 3 ACTION BUTTONS ROW (Share, Download, Duplicate)
          /*Row(
            children: [
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.upload_outlined,
                  label: 'Share',
                  onTap: () {
                    AppSnackbar.info(
                      title: 'Share',
                      message: 'Share feature is coming soon.',
                    );
                  },
                ),
              ),
              SizedBox(width: rs.isPhone ? 8 : 10),
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.download_outlined,
                  label: 'Download',
                  onTap: () {
                    AppSnackbar.info(
                      title: 'Download',
                      message: 'Download document feature is being prepared.',
                    );
                  },
                ),
              ),
              SizedBox(width: rs.isPhone ? 8 : 10),
              Expanded(
                child: _actionBoxButton(
                  context: context,
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
          ),*/
        ],
      ),
    );
  }

  Widget _actionBoxButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
            Icon(icon, size: rs.isPhone ? 18 : 20, color: _navyText),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: rs.isPhone ? 11.5 : 12,
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
  // 2A. SUPPLIER CARD
  // ================================================================
  Widget _buildSupplierCard(BuildContext context, PurchaseDetailsModel item) {
    final supplierName = item.supplier?.name.isNotEmpty == true
        ? item.supplier!.name
        : (item.supplierName ?? 'Supplier Zohaib');
    final initials = _getSupplierInitials(supplierName);
    final email = item.supplier?.email ?? 'zohaib@berrinex.com';
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
                  if (item.supplier != null) {
                    Get.toNamed('/SupplierDetailsScreen', arguments: item.supplier);
                  } else {
                    Get.toNamed('/SuppliersScreen');
                  }
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
                      supplierName,
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
  // 2B. PURCHASE INFORMATION CARD
  // ================================================================
  Widget _buildPurchaseInfoCard(BuildContext context, PurchaseDetailsModel item) {
    final formattedIssue = _formatDate(item.purchaseDate);
    final formattedDue = _formatDate(item.dueDate);
    final String statusStr = item.status.toLowerCase().trim();

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

          _infoRow('Purchase number', '#${item.purchaseNumber}', isBold: true),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _infoRow('Supplier inv number', item.supplierInvoiceNumber ?? '—'),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusStr == 'posted' || item.paymentStatus == 'paid'
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusStr == 'posted' || item.paymentStatus == 'paid'
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: statusStr == 'posted' || item.paymentStatus == 'paid'
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusStr == 'posted' || item.paymentStatus == 'paid'
                          ? 'Fully paid'
                          : (statusStr.isEmpty ? 'Draft' : statusStr.capitalizeFirst!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusStr == 'posted' || item.paymentStatus == 'paid'
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
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
  Widget _buildLineItemsCard(BuildContext context, PurchaseDetailsModel item) {
    final lines = item.lines;
    final currency = item.currency;

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
                child: Text(
                  lines.length == 1 ? '1 item' : '${lines.length} items',
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

          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No items added.',
                style: TextStyle(color: _secondaryText, fontSize: 13),
              ),
            )
          else
            Column(
              children: List.generate(lines.length, (index) {
                final line = lines[index];

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
                                  line.description.isNotEmpty ? line.description : 'Item #${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _navyText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${line.accountCode} · ${line.accountName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatNum(line.quantity)} × ${controller.formatCurrency(line.unitPrice, currency)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            controller.formatCurrency(line.totalAmount, currency),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _navyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < lines.length - 1)
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // 4. TAX & TOTALS CARD
  // ================================================================
  Widget _buildTotalsCard(BuildContext context, PurchaseDetailsModel item) {
    final currency = item.currency;

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

          _totalRow('Subtotal', controller.formatCurrency(item.subtotal, currency)),
          const SizedBox(height: 8),
          _totalRow('Tax', controller.formatCurrency(item.taxTotal, currency)),
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
                controller.formatCurrency(item.total, currency),
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
  // 5. PAYMENTS CARD
  // ================================================================
  Widget _buildPaymentsCard(BuildContext context, PurchaseDetailsModel item) {
    final currency = item.currency;

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
                  item.amountPaid >= item.total ? 'Fully paid' : 'Unpaid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: item.amountPaid >= item.total ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (item.payments.isEmpty)
            const Text(
              'No individual payment recorded.',
              style: TextStyle(color: _secondaryText, fontSize: 13),
            )
          else
            Column(
              children: List.generate(item.payments.length, (index) {
                final payment = item.payments[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(payment.paymentDate),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _navyText),
                        ),
                      ),
                      Text(
                        controller.formatCurrency(payment.amount, currency),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // HISTORY CARD
  // ================================================================
  Widget _buildHistoryCard(BuildContext context, PurchaseDetailsModel item) {
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
          _historyRow('Created', _formatDate(item.createdAt)),
          _historyRow('Approved', _formatDate(item.approvedAt)),
          _historyRow('Posted to ledger', _formatDate(item.postedAt)),
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

  String _getSupplierAddress(PurchaseDetailsModel item) {
    final supplier = item.supplier;
    if (supplier == null) return 'Austria, Vienna, 50000, Austria';
    final parts = [
      supplier.addressLine1,
      supplier.city,
      supplier.country,
    ].where((e) => e != null && e.trim().isNotEmpty).map((e) => e!).toList();

    if (parts.isEmpty) return 'Austria, Vienna, 50000, Austria';
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

  String _formatNum(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2);
  }
}