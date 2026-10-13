import 'package:docelix_mobileapp/controllers/invoices_details_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesDetailsScreen extends StatelessWidget {
  InvoicesDetailsScreen({super.key});

  final InvoicesDetailsController controller = Get.put(
    InvoicesDetailsController(),
  );

 // static const Color _background = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFFFFFFF);
 // static const Color _border = Color(0xFFE8EAED);
  static const Color _heading = Color(0xFF30343B);
 // static const Color _secondary = Color(0xFF777E87);
  static const double _radius = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: _heading,
          ),
        ),
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: _heading,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.invoice.value == null) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (controller.invoice.value == null) {
          return const Center(
            child: Text(
              'Invoice not found.',
              style: TextStyle(fontSize: 14, color: colorsList.secondaryTextColor),
            ),
          );
        }

        final invoice = controller.invoice.value!;

        return RefreshIndicator(
          onRefresh: controller.refreshInvoice,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _invoiceHeader(
                  invoice.invoiceNumber,
                  invoice.status,
                  invoice.currencyCode,
                  invoice.paidAmount,
                ),

                const SizedBox(height: 24),

                _sectionTitle('Invoice information'),
                const SizedBox(height: 12),

                _outlinedSection(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              'Issue date',
                              _formatDate(invoice.issueDate),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoItem(
                              'Due date',
                              invoice.dueDate == null ||
                                  invoice.dueDate!.isEmpty
                                  ? '—'
                                  : _formatDate(invoice.dueDate!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _infoItem(
                              'Total amount',
                              controller.formatCurrency(
                                invoice.paidAmount,
                                invoice.currencyCode,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoItem(
                              'Currency',
                              invoice.currencyCode,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle('Client'),
                const SizedBox(height: 12),
                _clientCard(),

                const SizedBox(height: 24),

                _sectionTitle('Items'),
                const SizedBox(height: 12),
                _itemsCard(),

                if ((invoice.notes ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle('Notes'),
                  const SizedBox(height: 12),
                  _outlinedSection(
                    child: Text(
                      invoice.notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.invoice.value == null) {
          return const SizedBox.shrink();
        }

        return _bottomActions();
      }),
    );
  }

  // Invoice header

  Widget _invoiceHeader(
      String invoiceNumber,
      String status,
      String currency,
      double amount,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: colorsList.borderColor),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: colorsList.secondaryTextColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice number',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      invoiceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: _heading,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: colorsList.dividerColor),
          ),
          const Text(
            'Total amount',
            style: TextStyle(fontSize: 13, color: colorsList.secondaryTextColor),
          ),
          const SizedBox(height: 7),
          Text(
            _amount(currency, amount),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.normal,
              color: _heading,
            ),
          ),
        ],
      ),
    );
  }

  // Section heading

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: _heading,
      ),
    );
  }

  // Shared outlined container

  Widget _outlinedSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: colorsList.borderColor),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: child,
    );
  }

  // Invoice information item

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: colorsList.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: _heading,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Client details

  Widget _clientCard() {
    return Obx(() {
      if (controller.client.value == null &&
          controller.isLoading.value) {
        return _outlinedSection(
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (controller.client.value == null) {
        return _outlinedSection(
          child: Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: colorsList.secondaryTextColor,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Client ID: ${controller.invoice.value?.clientId ?? '—'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: colorsList.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final client = controller.client.value!;

      return _outlinedSection(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 22,
                color: colorsList.secondaryTextColor,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name.isEmpty ? 'Client' : client.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: _heading,
                    ),
                  ),
                  if ((client.email ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _clientDetail(
                      Icons.email_outlined,
                      client.email!,
                    ),
                  ],
                  if ((client.phone ?? '').isNotEmpty) ...[
                    const SizedBox(height: 7),
                    _clientDetail(
                      Icons.phone_outlined,
                      client.phone!,
                    ),
                  ],
                  if ((client.addressLine1 ?? '').isNotEmpty) ...[
                    const SizedBox(height: 7),
                    _clientDetail(
                      Icons.location_on_outlined,
                      client.addressLine1!,
                    ),
                  ],
                  if ((client.city ?? '').isNotEmpty ||
                      (client.country ?? '').isNotEmpty) ...[
                    const SizedBox(height: 7),
                    _clientDetail(
                      Icons.public_outlined,
                      [
                        if ((client.city ?? '').isNotEmpty)
                          client.city!,
                        if ((client.country ?? '').isNotEmpty)
                          client.country!,
                      ].join(', '),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _clientDetail(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: colorsList.secondaryTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: colorsList.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // Invoice items

  Widget _itemsCard() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.invoiceItems.isEmpty) {
        return _outlinedSection(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (controller.invoiceItems.isEmpty) {
        return _outlinedSection(
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 28,
                    color: colorsList.secondaryTextColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No items found',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorsList.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final items = controller.invoiceItems;
      final currency = controller.invoice.value!.currencyCode;

      final double itemsTotal = items.fold(
        0.0,
            (sum, item) => sum + item.grossAmount,
      );

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: colorsList.borderColor),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          children: [
            // Table heading
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radius),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      'Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Amount',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: colorsList.dividerColor),

            // Product rows
            ...List.generate(items.length, (index) {
              final item = items[index];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            item.itemDesc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.normal,
                              color: _heading,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            _formatNumber(item.quantity),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: colorsList.secondaryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _amount(currency, item.grossAmount),
                            textAlign: TextAlign.end,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _heading,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: colorsList.dividerColor,
                    ),
                ],
              );
            }),

            const Divider(height: 1, color: colorsList.dividerColor),

            // Items total
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Items total',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorsList.secondaryTextColor,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _amount(currency, itemsTotal),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: _heading,
                      ),
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

  // Invoice status

  Widget _statusBadge(String status) {
    final String label = status.isEmpty
        ? 'Pending'
        : status.capitalizeFirst ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: colorsList.secondaryTextColor,
        ),
      ),
    );
  }

  // Bottom action bar

  Widget _bottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: colorsList.colorBoxDecoration,
        border: Border(
          top: BorderSide(color: colorsList.borderColor),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Obx(
                    () => OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.downloadInvoicePdf,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.download_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    'Download PDF',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _heading,
                    side: const BorderSide(color: colorsList.borderColor),
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: OutlinedButton.icon(
                onPressed: controller.showSendInvoiceDialog,
                icon: const Icon(Icons.send_outlined, size: 17),
                label: const Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _heading,
                  side: const BorderSide(color: colorsList.borderColor),
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 46,
              height: 46,
              child: OutlinedButton(
                onPressed: _showMoreActions,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _heading,
                  side: const BorderSide(color: colorsList.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // More actions

  void _showMoreActions() {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              _bottomSheetAction(
                icon: Icons.code_outlined,
                title: 'Download XML',
                onTap: () {
                  Get.back();
                  controller.downloadEInvoice();
                },
              ),
              _bottomSheetAction(
                icon: Icons.delete_outline,
                title: 'Delete invoice',
                onTap: () {
                  Get.back();
                  controller.showDeleteConfirmation();
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _bottomSheetAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(
          icon,
          size: 21,
          color: colorsList.secondaryTextColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: _heading,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Date formatting

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

  // Currency formatting

  String _amount(String currency, double amount) {
    return controller.formatCurrency(amount, currency);
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}