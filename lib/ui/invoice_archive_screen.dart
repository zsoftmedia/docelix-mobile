import 'package:docelix_mobileapp/controllers/invoice_archive_controller.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceArchiveScreen extends StatefulWidget {
  const InvoiceArchiveScreen({super.key});

  @override
  State<InvoiceArchiveScreen> createState() => _InvoiceArchiveScreenState();
}

class _InvoiceArchiveScreenState extends State<InvoiceArchiveScreen> {
  final InvoiceArchiveController controller =
      Get.put(InvoiceArchiveController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() {
          final bool searching = controller.isSearching.value;
          return IconButton(
            onPressed: () {
              if (searching) {
                controller.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: width * 0.05,
            ),
          );
        }),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: width * 0.04,
              ),
              decoration: const InputDecoration(
                hintText: 'Search supplier, email, invoice #...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Invoice Archive',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) return const SizedBox.shrink();

            return IconButton(
              onPressed: controller.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: width * 0.065,
              ),
            );
          }),
          SizedBox(width: width * 0.02),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // STATUS FILTER BAR
            // ======================================================

            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.010,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: controller.statusOptions.map((status) {
                    return Obx(() {
                      final bool isSelected =
                          controller.selectedStatus.value == status;

                      return GestureDetector(
                        onTap: () => controller.filterByStatus(status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: width * 0.02),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.038,
                            vertical: height * 0.009,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorsList.primaryBlue
                                : colorsList.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : colorsList.secondaryText,
                              fontSize: width * 0.031,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5EAF0)),

            // ======================================================
            // HEADER BAR (TOTAL INVOICES)
            // ======================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.045,
                vertical: height * 0.012,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Archived Invoices',
                    style: TextStyle(
                      color: colorsList.textColor,
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4EAF1)),
                      ),
                      child: Text(
                        '${controller.totalInvoices.value} Invoices',
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // LIST VIEW
            // ======================================================

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.filteredInvoices.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshArchive,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: height * 0.15),
                        Center(
                          child: Text(
                            controller.searchQuery.value.isNotEmpty
                                ? 'No matching archived invoices.'
                                : 'No archived invoices available.',
                            style: const TextStyle(
                              color: colorsList.textHintColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshArchive,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.045,
                      right: width * 0.045,
                      bottom: height * 0.05,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredInvoices[index];
                      return _buildArchiveCard(
                        item: item,
                        width: width,
                        height: height,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ARCHIVE CARD ITEM
  // ================================================================

  Widget _buildArchiveCard({
    required PurchaseInvoicesModel item,
    required double width,
    required double height,
  }) {
    final String suppName = item.supplierName?.isNotEmpty == true
        ? item.supplierName!
        : 'Unknown Supplier';

    final String invNum = item.invoiceNumber?.isNotEmpty == true
        ? item.invoiceNumber!
        : '—';

    final String dateStr = _formatDate(item.invoiceDate);

    final String status = item.status.toLowerCase().trim();
    final bool isPaid = status == 'paid';
    final Color statusColor = isPaid
        ? const Color(0xFF12A150)
        : const Color(0xFFF39C12);

    final String displayStatus = isPaid ? 'Paid' : 'Not paid';

    final String totalFormatted =
        controller.formatCurrency(item.totalAmount, item.currency);

    final String category = item.expenseCategory?.isNotEmpty == true
        ? (item.expenseCategory![0].toUpperCase() + item.expenseCategory!.substring(1))
        : 'Other';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              '/PurchaseInvoicesDetailsScreen',
              arguments: item,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW: SUPPLIER NAME & STATUS BADGE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width * 0.11,
                      height: width * 0.11,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.fileType == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : Icons.receipt_long_outlined,
                        color: item.fileType == 'pdf'
                            ? const Color(0xFFD64545)
                            : colorsList.iconColor,
                        size: width * 0.06,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suppName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.w700,
                              color: colorsList.textColor,
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            'Inv #: $invNum',
                            style: TextStyle(
                              fontSize: width * 0.030,
                              color: colorsList.textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: width * 0.027,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.012),
                const Divider(height: 1, color: Color(0xFFF0F4F8)),
                SizedBox(height: height * 0.010),

                // DETAILS ROW: DATE | CATEGORY | VAT % | TOTAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardStat('Date', dateStr, width),
                    _cardStat('Category', category, width),
                    _cardStat('VAT %', item.vatRatePercent != null ? '${item.vatRatePercent}%' : '—', width),
                    _cardStat('Total', totalFormatted, width, isBold: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardStat(String label, String value, double width, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.025,
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.030,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? const Color(0xFF063C70) : colorsList.textColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}