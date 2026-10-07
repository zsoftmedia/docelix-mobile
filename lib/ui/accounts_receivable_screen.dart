import 'package:docelix_mobileapp/controllers/AccountsReceivableController.dart';
import 'package:docelix_mobileapp/models/accounts_receivable_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsReceivableScreen extends StatefulWidget {
  const AccountsReceivableScreen({super.key});

  @override
  State<AccountsReceivableScreen> createState() =>
      _AccountsReceivableScreenState();
}

class _AccountsReceivableScreenState extends State<AccountsReceivableScreen> {

  final AccountsReceivableController invoicesController =
  Get.put(AccountsReceivableController());

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,

        leading: Obx(() {
          final bool searching =
              invoicesController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                invoicesController.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: width * 0.05,
            ),
          );
        }),

        title: Obx(() {
          if (invoicesController.isSearching.value) {
            return TextField(
              autofocus: true,

              onChanged:
              invoicesController.searchReceivableInvoices,

              style: TextStyle(
                color: colorsList.textColor,
                fontSize: width * 0.04,
              ),

              decoration: const InputDecoration(
                hintText: 'Search receivable invoices...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Accounts Receivable',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: width * 0.055,
              fontWeight: FontWeight.w700,
            ),
          );
        }),

        centerTitle: false,

        actions: [
          Obx(() {
            if (invoicesController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed:
              invoicesController.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: width * 0.065,
              ),
            );
          }),

          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: Column(
          children: [

            // ========================================================
            // HEADER
            // ========================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    'Receivable Invoices',
                    style: TextStyle(
                      color: colorsList.textColor,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ------------------------------------------------
                  // TOTAL COUNT
                  // ------------------------------------------------

                  Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: height * 0.008,
                      ),

                      decoration: BoxDecoration(
                        color:
                        colorsList.colorBoxDecoration,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),

                      child: Text(
                        '${invoicesController.totalReceivableInvoices.value} Invoices',
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ========================================================
            // RECEIVABLE INVOICE LIST
            // ========================================================

            Expanded(
              child: Obx(() {

                // ==================================================
                // LOADING
                // ==================================================

                if (invoicesController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ==================================================
                // EMPTY / NO SEARCH RESULT
                // ==================================================

                if (invoicesController
                    .filteredReceivableInvoices
                    .isEmpty) {

                  final bool hasSearch =
                      invoicesController.searchQuery.value
                          .trim()
                          .isNotEmpty;

                  return RefreshIndicator(
                    onRefresh:
                    invoicesController
                        .refreshReceivableInvoices,

                    child: ListView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),

                      children: [

                        const SizedBox(
                          height: 150,
                        ),

                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Icon(
                                hasSearch
                                    ? Icons.search_off_rounded
                                    : Icons.receipt_long_rounded,
                                color:
                                colorsList.textHintColor,
                                size: width * 0.13,
                              ),

                              SizedBox(
                                height: height * 0.015,
                              ),

                              Text(
                                hasSearch
                                    ? 'No receivable invoices found.'
                                    : 'No receivable invoices available.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                  colorsList.textHintColor,
                                  fontSize: width * 0.037,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ==================================================
                // RECEIVABLE INVOICE LIST
                // ==================================================

                return RefreshIndicator(
                  onRefresh:
                  invoicesController
                      .refreshReceivableInvoices,

                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: height * 0.005,
                      bottom: height * 0.04,
                    ),

                    physics:
                    const AlwaysScrollableScrollPhysics(),

                    itemCount:
                    invoicesController
                        .filteredReceivableInvoices
                        .length,

                    itemBuilder: (context, index) {

                      final AccountsReceivableModel invoice =
                      invoicesController
                          .filteredReceivableInvoices[index];

                      return Column(
                        children: [

                          _invoiceCard(
                            context: context,
                            invoice: invoice,
                            width: width,
                            height: height,
                          ),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE9EDF3),
                          ),
                        ],
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
  // RECEIVABLE INVOICE CARD
  // ================================================================

  Widget _invoiceCard({
    required BuildContext context,
    required AccountsReceivableModel invoice,
    required double width,
    required double height,
  }) {

    // ============================================================
    // STATUS
    // ============================================================

    final String status =
        invoice.status?.trim().toLowerCase() ?? '';

    Color statusColor;

    switch (status) {
      case 'paid':
        statusColor = const Color(0xFF00B894);
        break;

      case 'pending':
      case 'unpaid':
      case 'sent':
        statusColor = const Color(0xFFF39C12);
        break;

      case 'overdue':
        statusColor = Colors.red;
        break;

      default:
        statusColor = const Color(0xFF71829A);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Unknown';

    // ============================================================
    // DATE FORMATTER
    // ============================================================

    String formatDate(String? date) {
      if (date == null || date.trim().isEmpty) {
        return '—';
      }

      try {
        final List<String> parts = date.split('-');

        if (parts.length == 3) {
          return '${parts[2]}.${parts[1]}.${parts[0]}';
        }

        return date;
      } catch (_) {
        return date;
      }
    }

    final String invoiceNumber =
    invoice.invoiceNumber?.trim().isNotEmpty == true
        ? invoice.invoiceNumber!
        : 'No Invoice Number';

    final String customer =
    invoice.clientName?.trim().isNotEmpty == true
        ? invoice.clientName!
        : '—';

    final String issueDate =
    formatDate(invoice.issueDate);

    final String dueDate =
    formatDate(invoice.dueDate);

    // ============================================================
    // CARD
    // ============================================================

    return InkWell(
      onTap: () async {

        // If you have an Accounts Receivable details screen,
        // you can navigate here.
        //
        // final result = await Get.toNamed(
        //   '/AccountsReceivableDetailsScreen',
        //   arguments: invoice,
        // );
        //
        // if (result == true) {
        //   await invoicesController
        //       .refreshReceivableInvoices();
        // }

      },

      child: Container(
        color: colorsList.colorWhite,

        padding: EdgeInsets.symmetric(
          horizontal: width * 0.045,
          vertical: height * 0.018,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // ======================================================
            // TOP ROW
            // Invoice Number + Status
            // ======================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,

              children: [

                // ------------------------------------------------
                // INVOICE ICON
                // ------------------------------------------------

                Container(
                  width: width * 0.105,
                  height: width * 0.105,

                  decoration: BoxDecoration(
                    color: colorsList.colorBoxDecoration,
                    borderRadius:
                    BorderRadius.circular(
                      width * 0.025,
                    ),
                  ),

                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colorsList.iconColor,
                    size: width * 0.065,
                  ),
                ),

                SizedBox(
                  width: width * 0.03,
                ),

                // ------------------------------------------------
                // INVOICE NUMBER
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Text(
                        invoiceNumber,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,

                        style: TextStyle(
                          color:
                          colorsList.textColor,
                          fontSize:
                          width * 0.039,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      SizedBox(
                        height: height * 0.004,
                      ),

                      Text(
                        customer,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,

                        style: TextStyle(
                          color:
                          colorsList.textHintColor,
                          fontSize:
                          width * 0.033,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: width * 0.02,
                ),

                // ------------------------------------------------
                // STATUS
                // ------------------------------------------------

                Container(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal:
                    width * 0.025,
                    vertical:
                    height * 0.005,
                  ),

                  decoration: BoxDecoration(
                    color:
                    statusColor.withOpacity(0.10),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize:
                      width * 0.029,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: height * 0.018,
            ),

            // ======================================================
            // DATES
            // ======================================================

            Row(
              children: [

                Expanded(
                  child: _infoColumn(
                    width: width,
                    label: 'Issue Date',
                    value: issueDate,
                  ),
                ),

                Expanded(
                  child: _infoColumn(
                    width: width,
                    label: 'Due Date',
                    value: dueDate,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: height * 0.015,
            ),

            // ======================================================
            // TOTAL + BALANCE
            // ======================================================

            Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(
                horizontal: width * 0.025,
                vertical: height * 0.012,
              ),

              decoration: BoxDecoration(
                color:
                colorsList.colorBoxDecoration,
                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Row(
                children: [

                  // ------------------------------------------------
                  // TOTAL
                  // ------------------------------------------------

                  Expanded(
                    child: _amountColumn(
                      width: width,
                      label: 'Total',
                      amount:
                      invoice.totalAmount,
                      currencyCode:
                      invoice.currencyCode,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: height * 0.045,
                    color: const Color(0xFFDDE2E8),
                  ),

                  // ------------------------------------------------
                  // BALANCE
                  // ------------------------------------------------

                  Expanded(
                    child: _amountColumn(
                      width: width,
                      label: 'Balance',
                      amount:
                      invoice.remainingAmount,
                      currencyCode:
                      invoice.currencyCode,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // INFO COLUMN
  // ================================================================

  Widget _infoColumn({
    required double width,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(
          label,
          style: TextStyle(
            color:
            colorsList.textHintColor,
            fontSize: width * 0.029,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          style: TextStyle(
            color:
            colorsList.textColor,
            fontSize: width * 0.034,
            fontWeight:
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // AMOUNT COLUMN
  // ================================================================

  Widget _amountColumn({
    required double width,
    required String label,
    required num? amount,
    required String? currencyCode,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(
            label,
            style: TextStyle(
              color:
              colorsList.textHintColor,
              fontSize: width * 0.029,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            invoicesController.formatCurrency(
              amount,
              currencyCode,
            ),

            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              color:
              colorsList.textColor,
              fontSize: width * 0.036,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}