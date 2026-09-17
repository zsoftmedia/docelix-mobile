import 'package:docelix_mobileapp/controllers/invoices_details_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesDetailsScreen extends StatelessWidget {
  InvoicesDetailsScreen({super.key});

  final InvoicesDetailsController controller =
  Get.put(InvoicesDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.colorWhite,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF172033),
          ),
        ),

        title: const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF172033),
          ),
        ),

        centerTitle: false,

        actions: [
          IconButton(
            onPressed: () {
              // TODO: More options
            },
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF172033),
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Obx(() {

        if (controller.isLoading.value &&
            controller.invoice.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.invoice.value == null) {
          return const Center(
            child: Text(
              'Invoice not found.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          );
        }

        final invoice = controller.invoice.value!;

        return RefreshIndicator(
          onRefresh: controller.refreshInvoice,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              110,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ==================================================
                // INVOICE HEADER CARD
                // ==================================================

                _invoiceHeader(
                  invoice.invoiceNumber,
                  invoice.status,
                  invoice.currencyCode,
                  invoice.paidAmount,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // INVOICE INFORMATION
                // ==================================================

                _sectionTitle('Invoice Information'),

                const SizedBox(height: 10),

                Row(
                  children: [

                    Expanded(
                      child: _infoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'Issue Date: ',
                        value: _formatDate(
                          invoice.issueDate,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _infoCard(
                        icon: Icons.event_outlined,
                        title: 'Due Date',
                        value: invoice.dueDate == null ||
                            invoice.dueDate!.isEmpty
                            ? '—'
                            : _formatDate(
                          invoice.dueDate!,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    Expanded(
                      child: _infoCard(
                        icon: Icons.euro,
                        title: 'Total',
                        value: controller.client.value?.totalInvoicedAmount.toStringAsFixed(2) ?? '0.00',
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _infoCard(
                        icon: Icons.payments_outlined,
                        title: 'Currency',
                        value: invoice.currencyCode,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // CLIENT
                // ==================================================

                _sectionTitle('Client'),

                const SizedBox(height: 10),

                _clientCard(),

                const SizedBox(height: 20),

                // ==================================================
                // ITEMS
                // ==================================================

                _sectionTitle('Items'),

                const SizedBox(height: 10),

                _itemsCard(),

                const SizedBox(height: 20),

                // ==================================================
                // NOTES
                // ==================================================

                if ((invoice.notes ?? '').isNotEmpty)
                  _notesCard(invoice.notes!),
              ],
            ),
          ),
        );
      }),

      // ==========================================================
      // BOTTOM ACTION BAR
      // ==========================================================

      bottomNavigationBar: Obx(() {

        if (controller.invoice.value == null) {
          return const SizedBox.shrink();
        }

        return _bottomActions();
      }),
    );
  }

  // ==============================================================
  // INVOICE HEADER
  // ==============================================================

  Widget _invoiceHeader(
      String invoiceNumber,
      String status,
      String currency,
      double amount,
      ) {
    final bool isPaid = status.toLowerCase() == 'paid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: Color(0xFF2563EB),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    invoiceNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.w700,
                      color: Color(0xFF172033),
                    ),
                  ),
                ],
              ),
            ),

            _statusBadge(status),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),

            Text(
              _amount(currency, amount),
              style: const TextStyle(
                fontSize: 22,
               // fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xFF172033),
      ),
    );
  }

  // ==============================================================
  // INFO CARD
  // ==============================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF64748B),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
               // fontWeight: FontWeight.w400,
              ),
            ),
          ),

          Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
             // fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CLIENT CARD
  // ==============================================================

  Widget _clientCard() {
    return Obx(() {
      if (controller.client.value == null &&
          controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      }

      if (controller.client.value == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: Color(0xFF64748B),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Client ID: ${controller.invoice.value?.clientId ?? '—'}',
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
        );
      }

      final client = controller.client.value!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: Color(0xFF2563EB),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name.isEmpty
                          ? 'Client'
                          : client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                     //   fontWeight: FontWeight.w700,
                        color: Color(0xFF172033),
                      ),
                    ),

                    if ((client.email ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        client.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    if ((client.phone ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        client.phone!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    if ((client.addressLine1 ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        client.addressLine1!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],

                    if ((client.city ?? '').isNotEmpty ||
                        (client.country ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if ((client.city ?? '').isNotEmpty)
                            client.city!,
                          if ((client.country ?? '').isNotEmpty)
                            client.country!,
                        ].join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(
            height: 1,
            color: Color(0xFFE5E7EB),
          ),
        ],
      );
    });
  }

  // ==============================================================
  // ITEMS CARD
  // ==============================================================

  Widget _itemsCard() {
    return Obx(() {

      // ==========================================================
      // LOADING
      // ==========================================================

      if (controller.isLoading.value &&
          controller.invoiceItems.isEmpty) {
        return Container(
          width: double.infinity,

          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: const Color(0xFFE3E8EF),
            ),
          ),

          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // ==========================================================
      // EMPTY
      // ==========================================================

      if (controller.invoiceItems.isEmpty) {
        return Container(
          width: double.infinity,

          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: const Color(0xFFE3E8EF),
            ),
          ),

          child: Column(
            children: const [

              Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: Color(0xFF94A3B8),
              ),

              SizedBox(height: 10),

              Text(
                'No items found',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        );
      }

      // ==========================================================
      // ITEMS
      // ==========================================================

      final items = controller.invoiceItems;

      // Calculate total from items
      final double itemsTotal = items.fold(
        0.0,
            (sum, item) => sum + item.grossAmount,
      );

      return Container(
        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: colorsList.colorWhite,
          ),
        ),

        child: Column(
          children: [

            // ------------------------------------------------------
            // ITEM LIST
            // ------------------------------------------------------

            ...List.generate(
              items.length,
                  (index) {

                final item = items[index];

                return _itemRow(
                  description: item.itemDesc,
                  quantity: _formatNumber(item.quantity),
                  unit: _amount(
                    controller.invoice.value!.currencyCode,
                    item.unitPrice,
                  ),
                  vat: '${_formatNumber(item.vatRate)}%',
                  total: _amount(
                    controller.invoice.value!.currencyCode,
                    item.grossAmount,
                  ),
                  isLast: false,
                );
              },
            ),

            // ------------------------------------------------------
            // TOTAL
            // ------------------------------------------------------

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),

              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.end,

                children: [

                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Text(
                    _amount(
                      controller.invoice.value!.currencyCode,
                      itemsTotal,
                    ),

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172033),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==============================================================
  // ITEM ROW
  // ==============================================================

  Widget _itemRow({
    required String description,
    required String quantity,
    required String unit,
    required String vat,
    required String total,
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item description
                Expanded(
                  flex: 5,
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      //fontWeight: FontWeight.w500,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Quantity
                SizedBox(
                  width: 36,
                  child: Text(
                    quantity,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Total
                SizedBox(
                  width: 82,
                  child: Text(
                    total,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                  //    fontWeight: FontWeight.w600,
                      color: Color(0xFF172033),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!isLast)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Color(0xFFE5E7EB),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // ITEM DETAIL
  // ==============================================================

  Widget _itemDetail(
      String title,
      String value,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // PAYMENT SUMMARY
  // ==============================================================

  Widget _paymentSummary({
    required String currency,
    required double total,
    required double paidAmount,
    required double? remainingAmount,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE3E8EF),
        ),
      ),

      child: Column(
        children: [

          _summaryRow(
            'Invoice Total',
            _amount(currency, total),
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Paid Amount',
            _amount(currency, paidAmount),
          ),

          const SizedBox(height: 12),

          const Divider(
            color: Color(0xFFE8ECF1),
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Remaining',
            remainingAmount == null
                ? '—'
                : _amount(
              currency,
              remainingAmount,
            ),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SUMMARY ROW
  // ==============================================================

  Widget _summaryRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Row(
      children: [

        Expanded(
          child: Text(
            title,

            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: bold
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),

        Text(
          value,

          style: TextStyle(
            fontSize: bold ? 17 : 14,
            color: const Color(0xFF172033),
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // NOTES
  // ==============================================================

  Widget _notesCard(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          notes,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 12),

        const Divider(
          height: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }

  // ==============================================================
  // STATUS BADGE
  // ==============================================================

  Widget _statusBadge(String status) {
    final bool isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F7EE)
            : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty
            ? 'Pending'
            : status.capitalizeFirst ?? status,
        style: TextStyle(
          fontSize: 11,
        //  fontWeight: FontWeight.w600,
          color: isPaid
              ? const Color(0xFF15803D)
              : const Color(0xFFD97706),
        ),
      ),
    );
  }

  // ==============================================================
  // BOTTOM ACTIONS
  // ==============================================================

  Widget _bottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [

            // ------------------------------------------------------
            // DOWNLOAD
            // ------------------------------------------------------

            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Download
                },

                icon: const Icon(
                  Icons.download_outlined,
                  size: 19,
                ),

                label: const Text(
                  'Download',
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor:
                  const Color(0xFF475569),

                  side: const BorderSide(
                    color: Color(0xFFD5DCE5),
                  ),

                  minimumSize:
                  const Size(0, 48),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ------------------------------------------------------
            // SEND
            // ------------------------------------------------------

            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Send invoice
                },

                icon: const Icon(
                  Icons.send_outlined,
                  size: 18,
                ),

                label: const Text(
                  'Send',
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2563EB),

                  foregroundColor:
                  Colors.white,

                  elevation: 0,

                  minimumSize:
                  const Size(0, 48),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ------------------------------------------------------
            // MORE
            // ------------------------------------------------------

            SizedBox(
              width: 48,
              height: 48,

              child: OutlinedButton(
                onPressed: () {
                  _showMoreActions();
                },

                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,

                  side: const BorderSide(
                    color: Color(0xFFD5DCE5),
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // MORE ACTIONS
  // ==============================================================

  void _showMoreActions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          25,
        ),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Container(
              width: 40,
              height: 4,

              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            _bottomSheetAction(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Download ZUGFeRD PDF',
              onTap: () {
                Get.back();
              },
            ),

            _bottomSheetAction(
              icon: Icons.description_outlined,
              title: 'Download e-invoice',
              onTap: () {
                Get.back();
              },
            ),

            _bottomSheetAction(
              icon: Icons.edit_outlined,
              title: 'Edit Invoice',
              onTap: () {
                Get.back();
              },
            ),

            _bottomSheetAction(
              icon: Icons.delete_outline,
              title: 'Delete Invoice',
              color: const Color(0xFFDC2626),
              onTap: () {
                Get.back();

                controller.showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // BOTTOM SHEET ACTION
  // ==============================================================

  Widget _bottomSheetAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF172033),
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Container(
        width: 40,
        height: 40,

        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),

      title: Text(
        title,

        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),

      onTap: onTap,
    );
  }

  // ==============================================================
  // DATE
  // ==============================================================

  String _formatDate(String date) {
    if (date.isEmpty) {
      return '—';
    }

    try {
      final parsed = DateTime.parse(date);

      return '${parsed.day.toString().padLeft(2, '0')}.'
          '${parsed.month.toString().padLeft(2, '0')}.'
          '${parsed.year}';
    } catch (_) {
      return date;
    }
  }

  // ==============================================================
  // AMOUNT
  // ==============================================================

  String _amount(
      String currency,
      double amount,
      ) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}

// ==============================================================
// NUMBER FORMAT
// ==============================================================

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}
