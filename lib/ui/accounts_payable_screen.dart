import 'package:docelix_mobileapp/controllers/accounts_payable_controller.dart';
import 'package:docelix_mobileapp/models/accounts_payable_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsPayableScreen extends StatefulWidget {
  const AccountsPayableScreen({super.key});

  @override
  State<AccountsPayableScreen> createState() =>
      _AccountsPayableScreenState();
}

class _AccountsPayableScreenState
    extends State<AccountsPayableScreen> {

  final AccountsPayableController billsController =
  Get.put(AccountsPayableController());

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.of(context).size.width;

    final double height =
        MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
      colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor:
        colorsList.colorWhite,

        elevation: 0,

        leading: Obx(() {
          final bool searching =
              billsController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                billsController.closeSearch();
              } else {
                Get.back();
              }
            },

            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,

              color:
              colorsList.iconColor,

              size: width * 0.05,
            ),
          );
        }),

        title: Obx(() {
          if (billsController.isSearching.value) {
            return TextField(
              autofocus: true,

              onChanged:
              billsController.searchPayableBills,

              style: TextStyle(
                color:
                colorsList.textColor,
                fontSize:
                width * 0.04,
              ),

              decoration:
              const InputDecoration(
                hintText:
                'Search payable bills...',
                border:
                InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Accounts Payable',
            style: TextStyle(
              color:
              colorsList.textColor,
              fontSize:
              width * 0.055,
              fontWeight:
              FontWeight.w700,
            ),
          );
        }),

        actions: [
          Obx(() {
            if (billsController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed:
              billsController.openSearch,

              icon: Icon(
                Icons.search_rounded,
                color:
                colorsList.iconColor,
                size:
                width * 0.065,
              ),
            );
          }),

          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [

            // ======================================================
            // HEADER
            // ======================================================

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
                    'Payable Bills',
                    style: TextStyle(
                      color:
                      colorsList.textColor,
                      fontSize:
                      width * 0.045,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  Obx(() {
                    return Container(
                      padding:
                      EdgeInsets.symmetric(
                        horizontal:
                        width * 0.035,
                        vertical:
                        height * 0.008,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        colorsList.colorBoxDecoration,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),

                      child: Text(
                        '${billsController.totalPayableBills.value} Bills',
                        style: TextStyle(
                          color:
                          colorsList.textColor,
                          fontSize:
                          width * 0.032,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ======================================================
            // LIST
            // ======================================================

            Expanded(
              child: Obx(() {

                // ==================================================
                // LOADING
                // ==================================================

                if (billsController.isLoading.value) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                // ==================================================
                // EMPTY
                // ==================================================

                if (billsController
                    .filteredPayableBills
                    .isEmpty) {

                  final bool hasSearch =
                      billsController
                          .searchQuery
                          .value
                          .trim()
                          .isNotEmpty;

                  return RefreshIndicator(
                    onRefresh:
                    billsController
                        .refreshPayableBills,

                    child: ListView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),

                      children: [

                        const SizedBox(
                          height: 150,
                        ),

                        Center(
                          child: Column(
                            children: [

                              Icon(
                                hasSearch
                                    ? Icons.search_off_rounded
                                    : Icons.receipt_long_rounded,

                                color:
                                colorsList.textHintColor,

                                size:
                                width * 0.13,
                              ),

                              SizedBox(
                                height:
                                height * 0.015,
                              ),

                              Text(
                                hasSearch
                                    ? 'No payable bills found.'
                                    : 'No payable bills available.',

                                style: TextStyle(
                                  color:
                                  colorsList.textHintColor,
                                  fontSize:
                                  width * 0.037,
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
                // BILL LIST
                // ==================================================

                return RefreshIndicator(
                  onRefresh:
                  billsController
                      .refreshPayableBills,

                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: height * 0.005,
                      bottom: height * 0.04,
                    ),

                    physics:
                    const AlwaysScrollableScrollPhysics(),

                    itemCount:
                    billsController
                        .filteredPayableBills
                        .length,

                    itemBuilder:
                        (context, index) {

                      final AccountsPayableModel bill =
                      billsController
                          .filteredPayableBills[index];

                      return Column(
                        children: [

                          _billCard(
                            bill: bill,
                            width: width,
                            height: height,
                          ),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color:
                            Color(0xFFE9EDF3),
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

  // ==============================================================
  // BILL CARD
  // ==============================================================

  Widget _billCard({
    required AccountsPayableModel bill,
    required double width,
    required double height,
  }) {

    // ============================================================
    // STATUS
    // ============================================================

    final String status =
        bill.status
            ?.trim()
            .toLowerCase() ??
            '';

    Color statusColor;

    switch (status) {
      case 'paid':
        statusColor =
        const Color(0xFF00B894);
        break;

      case 'pending':
      case 'unpaid':
        statusColor =
        const Color(0xFF71829A);
        break;

      case 'overdue':
        statusColor =
            Colors.red;
        break;

      default:
        statusColor =
        const Color(0xFF71829A);
    }

    final String displayStatus =
    status.isNotEmpty
        ? status[0].toUpperCase() +
        status.substring(1)
        : 'Unknown';

    // ============================================================
    // DATE FORMAT
    // ============================================================

    String formatDate(
        String? date, {
          bool includeOverdueDays = false,
        }) {
      if (date == null ||
          date.trim().isEmpty) {
        return '—';
      }

      try {
        final DateTime parsed =
        DateTime.parse(date).toLocal();

        final String formatted =
            '${parsed.day.toString().padLeft(2, '0')}.'
            '${parsed.month.toString().padLeft(2, '0')}.'
            '${parsed.year}';

        if (includeOverdueDays &&
            (bill.daysOverdue ?? 0) > 0) {
          return '$formatted (${bill.daysOverdue}d)';
        }

        return formatted;
      } catch (_) {
        return date;
      }
    }

    final String billNumber =
    bill.invoiceNumber
        ?.trim()
        .isNotEmpty ==
        true
        ? bill.invoiceNumber!
        : 'No Bill Number';

    final String supplier =
    bill.supplierName
        ?.trim()
        .isNotEmpty ==
        true
        ? bill.supplierName!
        : '—';

    final String issueDate =
    formatDate(bill.invoiceDate);

    final String dueDate =
    formatDate(
      bill.dueDate,
      includeOverdueDays: true,
    );

    final bool isOverdue =
        (bill.daysOverdue ?? 0) > 0 ||
            status == 'overdue';

    // ============================================================
    // CARD
    // ============================================================

    return Container(
      color:
      colorsList.colorWhite,

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
          // ======================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,

            children: [

              // --------------------------------------------------
              // ICON
              // --------------------------------------------------

              Container(
                width:
                width * 0.105,

                height:
                width * 0.105,

                decoration:
                BoxDecoration(
                  color:
                  colorsList.colorBoxDecoration,
                  borderRadius:
                  BorderRadius.circular(
                    width * 0.025,
                  ),
                ),

                child: Icon(
                  Icons.receipt_long_rounded,
                  color:
                  colorsList.iconColor,
                  size:
                  width * 0.065,
                ),
              ),

              SizedBox(
                width:
                width * 0.03,
              ),

              // --------------------------------------------------
              // BILL NUMBER + SUPPLIER
              // --------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      billNumber,

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
                      height:
                      height * 0.004,
                    ),

                    Text(
                      supplier,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(
                        color:
                        colorsList.textHintColor,
                        fontSize:
                        width * 0.032,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width:
                width * 0.02,
              ),

              // --------------------------------------------------
              // STATUS
              // --------------------------------------------------

              Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  width * 0.025,
                  vertical:
                  height * 0.005,
                ),

                decoration:
                BoxDecoration(
                  color:
                  statusColor.withOpacity(0.10),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Text(
                  displayStatus,

                  style: TextStyle(
                    color:
                    statusColor,
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
            height:
            height * 0.018,
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
                  valueColor:
                  isOverdue
                      ? Colors.red
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(
            height:
            height * 0.015,
          ),

          // ======================================================
          // TOTAL + BALANCE
          // ======================================================

          Container(
            width:
            double.infinity,

            padding:
            EdgeInsets.symmetric(
              horizontal:
              width * 0.025,
              vertical:
              height * 0.012,
            ),

            decoration:
            BoxDecoration(
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
                    bill.totalAmount,
                    currencyCode:
                    bill.currency,
                  ),
                ),

                Container(
                  width: 1,
                  height:
                  height * 0.045,
                  color:
                  const Color(0xFFDDE2E8),
                ),

                // ------------------------------------------------
                // BALANCE
                // ------------------------------------------------

                Expanded(
                  child: _amountColumn(
                    width: width,
                    label: 'Balance',
                    amount:
                    bill.remainingAmount,
                    currencyCode:
                    bill.currency,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INFO COLUMN
  // ==============================================================

  Widget _infoColumn({
    required double width,
    required String label,
    required String value,
    Color? valueColor,
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
            fontSize:
            width * 0.029,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          value,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,

          style: TextStyle(
            color:
            valueColor ??
                colorsList.textColor,
            fontSize:
            width * 0.034,
            fontWeight:
            FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // AMOUNT COLUMN
  // ==============================================================

  Widget _amountColumn({
    required double width,
    required String label,
    required num? amount,
    required String? currencyCode,
  }) {
    return Padding(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        width * 0.02,
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
              fontSize:
              width * 0.029,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            billsController.formatCurrency(
              amount,
              currencyCode,
            ),

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style: TextStyle(
              color:
              colorsList.textColor,
              fontSize:
              width * 0.036,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}