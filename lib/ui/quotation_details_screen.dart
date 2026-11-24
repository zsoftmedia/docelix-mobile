import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/quotation_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationDetailsScreen extends StatefulWidget {
  const QuotationDetailsScreen({super.key});

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  final QuotationDetailsController controller =
      Get.put(QuotationDetailsController());

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
        title: Text(
          'Quotation Details',
          style: TextStyle(
            fontSize: rs.sp(17),
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
      ),
      body: Obx(() {
        final item = controller.quotation.value;

        if (item == null) {
          return const Center(
            child: Text(
              'Quotation information not available.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 14,
              ),
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.getOfferItems,
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
                      // 1. QUOTATION NUMBER SUMMARY CARD (TOP CARD)
                      // ====================================================
                      _buildSummaryCard(context, item),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 2. QUOTATION INFORMATION & CLIENT CARDS
                      // ====================================================
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 580;

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildInfoCard(context, item)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildClientCard(context, item)),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoCard(context, item),
                              const SizedBox(height: 16),
                              _buildClientCard(context, item),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 3. ITEMS CARD
                      // ====================================================
                      _buildItemsCard(context, item),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // DELETING OVERLAY
            if (controller.isDeleting.value)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF063C70),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Deleting quotation...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _navyText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please wait a moment',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),

      // ==========================================================
      // STICKY BOTTOM ACTIONS BAR (MATCHING SCREENSHOT)
      // ==========================================================
      bottomNavigationBar: Obx(() {
        if (controller.quotation.value == null) {
          return const SizedBox.shrink();
        }

        return _buildStickyBottomActionBar(context);
      }),
    );
  }

  // ================================================================
  // 1. QUOTATION NUMBER SUMMARY CARD
  // ================================================================
  Widget _buildSummaryCard(BuildContext context, QuotationModel item) {
    final rs = context.rs;
    final String statusStr = item.status.toLowerCase().trim();

    Color statusBg = const Color(0xFFF1F5F9);
    Color statusBorder = const Color(0xFFE2E8F0);
    Color statusText = const Color(0xFF64748B);

    if (statusStr == 'accepted') {
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
      statusText = const Color(0xFF059669);
    } else if (statusStr == 'sent') {
      statusBg = const Color(0xFFEFF6FF);
      statusBorder = const Color(0xFFBFDBFE);
      statusText = const Color(0xFF2563EB);
    } else if (statusStr == 'rejected') {
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusText = const Color(0xFFDC2626);
    }

    final String displayStatus =
        statusStr.isNotEmpty ? statusStr[0].toUpperCase() + statusStr.substring(1) : 'Draft';

    final offerNumStr = item.offerNumber.isNotEmpty ? item.offerNumber : 'INVM-26110900-6503';
    final acceptedDateStr = item.acceptedAt != null ? _formatDate(item.acceptedAt) : '—';

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF063C70),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUOTATION NUMBER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _secondaryText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offerNumStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    const SizedBox(width: 5),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: statusText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accepted status',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    acceptedDateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navyText,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total amount',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.formatCurrency(controller.totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _navyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2A. QUOTATION INFORMATION CARD
  // ================================================================
  Widget _buildInfoCard(BuildContext context, QuotationModel item) {
    final issueDateStr = _formatDate(item.issueDate);
    final validUntilStr = item.validUntil != null && item.validUntil!.isNotEmpty
        ? _formatDate(item.validUntil)
        : '—';
    final acceptedDateStr = item.acceptedAt != null && item.acceptedAt!.isNotEmpty
        ? _formatDate(item.acceptedAt)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quotation information',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Issue date',
                            style: TextStyle(fontSize: 12, color: _secondaryText)),
                        const SizedBox(height: 4),
                        Text(
                          issueDateStr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _navyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valid until',
                            style: TextStyle(fontSize: 12, color: _secondaryText)),
                        const SizedBox(height: 4),
                        Text(
                          validUntilStr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Accepted',
                            style: TextStyle(fontSize: 12, color: _secondaryText)),
                        const SizedBox(height: 4),
                        Text(
                          acceptedDateStr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total amount',
                            style: TextStyle(fontSize: 12, color: _secondaryText)),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatCurrency(controller.totalAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _navyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // 2B. CLIENT CARD
  // ================================================================
  Widget _buildClientCard(BuildContext context, QuotationModel item) {
    final name = item.clientName ?? 'Ebad';
    final email = item.clientEmail ?? 'and@gmail.com';
    final address = item.clientAddress ?? '3etw, etwte, 333322';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF063C70),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 14, color: _secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: _secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: _secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.public_outlined, size: 14, color: _secondaryText),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'swabi, pakistan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: _secondaryText),
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
      ],
    );
  }

  // ================================================================
  // 3. ITEMS CARD
  // ================================================================
  Widget _buildItemsCard(BuildContext context, QuotationModel item) {
    final items = controller.offerItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
              // TABLE HEADER
              const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _secondaryText,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Amount',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _secondaryText,
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),

              if (controller.isLoadingItems.value && items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laptop',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _navyText,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'VAT 0%',
                              style: TextStyle(fontSize: 12, color: _secondaryText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                        child: Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: _secondaryText),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          controller.formatCurrency(controller.totalAmount),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _navyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: List.generate(items.length, (index) {
                    final line = items[index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      line.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _navyText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'VAT ${_formatNum(line.vatRate)}%',
                                      style: const TextStyle(
                                          fontSize: 12, color: _secondaryText),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  _formatNum(line.quantity),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 13, color: _secondaryText),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  controller.formatCurrency(line.total),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _navyText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < items.length - 1)
                          const Divider(height: 12, color: Color(0xFFF1F5F9)),
                      ],
                    );
                  }),
                ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _secondaryText,
                    ),
                  ),
                  Text(
                    controller.formatCurrency(controller.totalAmount),
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
    );
  }

  // ================================================================
  // STICKY BOTTOM ACTION BAR (MATCHING SCREENSHOT)
  // ================================================================
  Widget _buildStickyBottomActionBar(BuildContext context) {
    final rs = context.rs;

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
            // BUTTON 1: SEND
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppSnackbar.info(
                    title: 'Send Quotation',
                    message: 'Send quotation feature is being prepared.',
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorsList.primaryBlue,
                  side: const BorderSide(color: colorsList.borderColor),
                  padding: EdgeInsets.symmetric(
                    vertical: rs.isPhone ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // BUTTON 2: STATUS
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showMoreMenuSheet(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navyText,
                  side: const BorderSide(color: colorsList.borderColor),
                  padding: EdgeInsets.symmetric(
                    vertical: rs.isPhone ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // BUTTON 3: MORE (...)
            SizedBox(
              width: rs.isPhone ? 46 : 50,
              height: rs.isPhone ? 46 : 48,
              child: OutlinedButton(
                onPressed: () => _showMoreMenuSheet(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _navyText,
                  side: const BorderSide(color: colorsList.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.more_horiz_rounded, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MORE MENU BOTTOM SHEET
  // ================================================================
  void _showMoreMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'More Options',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _moreOptionTile(
                title: 'Download document',
                subtitle: 'View or print quotation document',
                icon: Icons.file_download_outlined,
                iconColor: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.downloadQuotationDocument();
                },
              ),
              const SizedBox(height: 8),
              _moreOptionTile(
                title: 'Edit quotation',
                subtitle: 'Modify quotation details or items',
                icon: Icons.edit_outlined,
                iconColor: colorsList.primaryBlue,
                onTap: () async {
                  Navigator.pop(ctx);
                  final currentOffer = controller.quotation.value;
                  if (currentOffer != null) {
                    final result = await Get.toNamed('/EditQuotationScreen', arguments: currentOffer);
                    if (result == true) {
                      controller.getOfferItems();
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
              _moreOptionTile(
                title: 'Delete quotation',
                subtitle: 'Permanently remove this quotation',
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.deleteQuotation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================
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