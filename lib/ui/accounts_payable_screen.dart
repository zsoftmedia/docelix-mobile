import 'package:docelix_mobileapp/controllers/accounts_payable_controller.dart';
import 'package:docelix_mobileapp/models/accounts_payable_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsPayableScreen extends StatefulWidget {
  const AccountsPayableScreen({super.key});

  @override
  State<AccountsPayableScreen> createState() => _AccountsPayableScreenState();
}

class _AccountsPayableScreenState extends State<AccountsPayableScreen> {
  final AccountsPayableController billsController = Get.put(
    AccountsPayableController(),
  );

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,

        elevation: 0,

        leading: Obx(() {
          final bool searching = billsController.isSearching.value;

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

              color: colorsList.iconColor,

              size: rs.s(19.5),
            ),
          );
        }),

        title: Obx(() {
          if (billsController.isSearching.value) {
            return TextField(
              autofocus: true,

              onChanged: billsController.searchPayableBills,

              style: TextStyle(
                color: colorsList.textColor,
                fontSize: rs.sp(15.5),
              ),

              decoration: const InputDecoration(
                hintText: 'Search payable bills...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Accounts Payable',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: rs.sp(21.5),
              fontWeight: FontWeight.normal,
            ),
          );
        }),

        actions: [
          Obx(() {
            if (billsController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: billsController.openSearch,

              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: rs.s(25.5),
              ),
            );
          }),

          SizedBox(width: rs.s(8)),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ======================================================
              // HEADER
              // ======================================================

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(17),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Payable Bills',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: rs.sp(17.5),
                        // fontWeight: FontWeight.w600,
                      ),
                    ),

                    Obx(() {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(13.5),
                          vertical: rs.s(7),
                        ),

                        decoration: BoxDecoration(
                          color: colorsList.colorBoxDecoration,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          '${billsController.totalPayableBills.value} Bills',
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: rs.sp(12.5),
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (billsController.filteredPayableBills.isEmpty) {
                    final bool hasSearch = billsController.searchQuery.value
                        .trim()
                        .isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: billsController.refreshPayableBills,

                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),

                        children: [
                          SizedBox(height: rs.s(150)),

                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  hasSearch
                                      ? Icons.search_off_rounded
                                      : Icons.receipt_long_rounded,

                                  color: colorsList.textHintColor,

                                  size: rs.s(50.5),
                                ),

                                SizedBox(height: rs.s(12.5)),

                                Text(
                                  hasSearch
                                      ? 'No payable bills found.'
                                      : 'No payable bills available.',

                                  style: TextStyle(
                                    color: colorsList.textHintColor,
                                    fontSize: rs.sp(14.5),
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

                  final bills = billsController.filteredPayableBills;
                  final int cols = rs.listColumns;

                  return RefreshIndicator(
                    onRefresh: billsController.refreshPayableBills,

                    child: cols <= 1
                        ? ListView.builder(
                            padding: EdgeInsets.only(
                              top: rs.s(4),
                              bottom: rs.s(34),
                            ),

                            physics: const AlwaysScrollableScrollPhysics(),

                            itemCount: bills.length,

                            itemBuilder: (context, index) {
                              final AccountsPayableModel bill = bills[index];

                              return Column(
                                children: [
                                  _billCard(
                                    bill: bill,
                                    rs: rs,
                                    asGridTile: false,
                                  ),

                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFE9EDF3),
                                  ),
                                ],
                              );
                            },
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(
                              left: rs.pagePaddingH,
                              right: rs.pagePaddingH,
                              top: rs.s(4),
                              bottom: rs.s(34),
                            ),

                            physics: const AlwaysScrollableScrollPhysics(),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: rs.s(12),
                                  mainAxisSpacing: rs.s(12),
                                  mainAxisExtent: rs.s(215),
                                ),

                            itemCount: bills.length,

                            itemBuilder: (context, index) {
                              return _billCard(
                                bill: bills[index],
                                rs: rs,
                                asGridTile: true,
                              );
                            },
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // BILL CARD
  // ==============================================================

  Widget _billCard({
    required AccountsPayableModel bill,
    required ResponsiveMetrics rs,
    required bool asGridTile,
  }) {
    // ============================================================
    // STATUS
    // ============================================================

    final String status = bill.status?.trim().toLowerCase() ?? '';

    Color statusColor;

    switch (status) {
      case 'paid':
        statusColor = const Color(0xFF00B894);
        break;

      case 'pending':
      case 'unpaid':
        statusColor = const Color(0xFF71829A);
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
    // DATE FORMAT
    // ============================================================

    String formatDate(String? date, {bool includeOverdueDays = false}) {
      if (date == null || date.trim().isEmpty) {
        return '—';
      }

      try {
        final DateTime parsed = DateTime.parse(date).toLocal();

        final String formatted =
            '${parsed.day.toString().padLeft(2, '0')}.'
            '${parsed.month.toString().padLeft(2, '0')}.'
            '${parsed.year}';

        if (includeOverdueDays && (bill.daysOverdue ?? 0) > 0) {
          return '$formatted (${bill.daysOverdue}d)';
        }

        return formatted;
      } catch (_) {
        return date;
      }
    }

    final String billNumber = bill.invoiceNumber?.trim().isNotEmpty == true
        ? bill.invoiceNumber!
        : 'No Bill Number';

    final String supplier = bill.supplierName?.trim().isNotEmpty == true
        ? bill.supplierName!
        : '—';

    final String issueDate = formatDate(bill.invoiceDate);

    final String dueDate = formatDate(bill.dueDate, includeOverdueDays: true);

    final bool isOverdue = (bill.daysOverdue ?? 0) > 0 || status == 'overdue';

    // ============================================================
    // CARD
    // ============================================================

    return Container(
      decoration: BoxDecoration(
        color: colorsList.colorWhite,
        borderRadius: asGridTile ? BorderRadius.circular(rs.s(14)) : null,
        border: asGridTile ? Border.all(color: const Color(0xFFE9EDF3)) : null,
      ),

      padding: EdgeInsets.symmetric(horizontal: rs.s(17.5), vertical: rs.s(15)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ======================================================
          // TOP ROW
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              // --------------------------------------------------
              // ICON
              // --------------------------------------------------

              Container(
                width: rs.s(41),

                height: rs.s(41),

                decoration: BoxDecoration(
                  color: colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(rs.s(10)),
                ),

                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorsList.iconColor,
                  size: rs.s(25.5),
                ),
              ),

              SizedBox(width: rs.s(11.5)),

              // --------------------------------------------------
              // BILL NUMBER + SUPPLIER
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      billNumber,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: rs.sp(15),
                        //fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: rs.s(3.5)),

                    Text(
                      supplier,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: colorsList.textHintColor,
                        fontSize: rs.sp(12.5),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: rs.s(8)),

              // --------------------------------------------------
              // STATUS
              // --------------------------------------------------
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.s(10),
                  vertical: rs.s(4),
                ),

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),

                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  displayStatus,

                  style: TextStyle(
                    color: statusColor,
                    fontSize: rs.sp(11.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: rs.s(15)),

          // ======================================================
          // DATES
          // ======================================================
          Row(
            children: [
              Expanded(
                child: _infoColumn(
                  rs: rs,
                  label: 'Issue Date',
                  value: issueDate,
                ),
              ),

              Expanded(
                child: _infoColumn(
                  rs: rs,
                  label: 'Due Date',
                  value: dueDate,
                  valueColor: isOverdue ? Colors.red : null,
                ),
              ),
            ],
          ),

          SizedBox(height: rs.s(12.5)),

          // ======================================================
          // TOTAL + BALANCE
          // ======================================================
          Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: rs.s(10),
              vertical: rs.s(10),
            ),

            decoration: BoxDecoration(
              color: colorsList.colorBoxDecoration,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Row(
              children: [
                // ------------------------------------------------
                // TOTAL
                // ------------------------------------------------

                Expanded(
                  child: _amountColumn(
                    rs: rs,
                    label: 'Total',
                    amount: bill.totalAmount,
                    currencyCode: bill.currency,
                  ),
                ),

                Container(
                  width: 1,
                  height: rs.s(38),
                  color: const Color(0xFFDDE2E8),
                ),

                // ------------------------------------------------
                // BALANCE
                // ------------------------------------------------
                Expanded(
                  child: _amountColumn(
                    rs: rs,
                    label: 'Balance',
                    amount: bill.remainingAmount,
                    currencyCode: bill.currency,
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
    required ResponsiveMetrics rs,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.textHintColor,
            fontSize: rs.sp(11.5),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            color: valueColor ?? colorsList.textColor,
            fontSize: rs.sp(13.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // AMOUNT COLUMN
  // ==============================================================

  Widget _amountColumn({
    required ResponsiveMetrics rs,
    required String label,
    required num? amount,
    required String? currencyCode,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs.s(8)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: rs.sp(11.5),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            billsController.formatCurrency(amount, currencyCode),

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              color: colorsList.textColor,
              fontSize: rs.sp(14),
              //fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
