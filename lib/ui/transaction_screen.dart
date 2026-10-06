import 'package:docelix_mobileapp/controllers/transation_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransationScreen extends StatefulWidget {
  const TransationScreen({
    super.key,
  });

  @override
  State<TransationScreen> createState() => _TransationScreenState();
}

class _TransationScreenState extends State<TransationScreen> {
  final TransactionController transactionController =
      Get.put(TransactionController());

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
        backgroundColor: colorsList.colorWhite,
        elevation: 0,

        leading: Obx(() {
          final bool searching = transactionController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                transactionController.closeSearch();
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
          if (transactionController.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: transactionController.searchTransactions,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: width * 0.04,
              ),
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Transactions',
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
            if (transactionController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: transactionController.openSearch,
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

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // DATE FILTER
            // ======================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.015,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      return _dateDropdown(
                        width: width,
                        icon: Icons.calendar_today_outlined,
                        text: transactionController.fromDateText,
                        onTap: transactionController.selectFromDate,
                      );
                    }),
                  ),
                  SizedBox(
                    width: width * 0.025,
                  ),
                  Expanded(
                    child: Obx(() {
                      return _dateDropdown(
                        width: width,
                        icon: Icons.calendar_today_outlined,
                        text: transactionController.toDateText,
                        onTap: transactionController.selectToDate,
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ======================================================
            // HEADER
            // ======================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Transactions',
                    style: TextStyle(
                      color: colorsList.textColor,
                      fontSize: width * 0.045,
                    ),
                  ),
                  Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: colorsList.colorBoxDecoration,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${transactionController.totalTransactions.value} Transactions',
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.032,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ======================================================
            // TOTALS
            // ======================================================

            Obx(() {
              final totals = transactionController.ledger.value.totals;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.008,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: 'Debit',
                        value: transactionController.formatCurrency(
                          totals.debit,
                          null,
                        ),
                        width: width,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.025,
                    ),
                    Expanded(
                      child: _summaryCard(
                        title: 'Credit',
                        value: transactionController.formatCurrency(
                          totals.credit,
                          null,
                        ),
                        width: width,
                      ),
                    ),
                    SizedBox(
                      width: width * 0.025,
                    ),
                    Expanded(
                      child: _summaryCard(
                        title: 'Balance',
                        value: transactionController.formatCurrency(
                          totals.closingBalance,
                          null,
                        ),
                        width: width,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ======================================================
            // TRANSACTION LIST (EXPANDABLE CARDS)
            // ======================================================

            Expanded(
              child: Obx(() {
                if (transactionController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (transactionController.filteredGroups.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: transactionController.refreshTransactions,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(
                          height: 120,
                        ),
                        Center(
                          child: Text(
                            transactionController.searchQuery.value
                                    .trim()
                                    .isNotEmpty
                                ? 'No transactions found.'
                                : 'No transactions found for selected dates.',
                            style: TextStyle(
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
                  onRefresh: transactionController.refreshTransactions,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: height * 0.005,
                      bottom: height * 0.12,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: transactionController.filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group =
                          transactionController.filteredGroups[index];

                      return _expandableJournalCard(
                        group: group,
                        width: width,
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
  // DATE DROPDOWN
  // ================================================================

  Widget _dateDropdown({
    required double width,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: width * 0.025,
        ),
        decoration: BoxDecoration(
          color: colorsList.colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE8EDF3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: width * 0.045,
              color: colorsList.iconColor,
            ),
            SizedBox(
              width: width * 0.02,
            ),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: width * 0.032,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SUMMARY CARD
  // ================================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required double width,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.025,
      ),
      decoration: BoxDecoration(
        color: colorsList.colorWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: width * 0.028,
            ),
          ),
          SizedBox(
            height: width * 0.01,
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: width * 0.032,
             // fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // EXPANDABLE JOURNAL CARD (MATCHES WEB DESIGN)
  // ================================================================

  Widget _expandableJournalCard({
    required JournalGroupModel group,
    required double width,
  }) {
    final dateParts = transactionController.parseDateParts(group.entryDate);

    return Obx(() {
      final bool expanded = group.isExpanded.value;

      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: expanded ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
            width: expanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // CARD HEADER ROW
            // ======================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // DATE BLOCK
                // --------------------------------------------------
                SizedBox(
                  width: width * 0.11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dateParts['day']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateParts['month']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colorsList.focusedBorderColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        dateParts['year']!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // --------------------------------------------------
                // TITLE & SUBTITLE & BADGES
                // --------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          //fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reference #${group.sourceId} • Journal #${group.journalEntryId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (group.sourceType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                group.sourceType,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              group.status.toLowerCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                               // fontWeight: FontWeight.w600,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // --------------------------------------------------
                // AMOUNT & EXPAND/COLLAPSE TOGGLE
                // --------------------------------------------------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transactionController.formatCurrency(
                        group.displayAmount,
                        null,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                      //  fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        group.isExpanded.value = !group.isExpanded.value;
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              expanded ? 'Collapse Details' : 'Expand Details',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF2563EB),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ======================================================
            // EXPANDED JOURNAL DETAILS TABLE
            // ======================================================
            if (expanded) ...[
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                color: Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 12),

              // TABLE HEADER
              Row(
                children: const [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 12,
                      //  fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 78,
                    child: Text(
                      'Debit',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 78,
                    child: Text(
                      'Credit',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // JOURNAL LINES
              ...group.lines.map((line) {
                final accountText =
                    '${line.account.code} ${line.account.name}'.trim();
                final lineDesc = line.lineDescription.isNotEmpty
                    ? line.lineDescription
                    : line.description;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          accountText.isNotEmpty ? accountText : 'Account',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          lineDesc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 78,
                        child: Text(
                          line.debit > 0
                              ? transactionController.formatCurrency(
                                  line.debit, null)
                              : '—',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 78,
                        child: Text(
                          line.credit > 0
                              ? transactionController.formatCurrency(
                                  line.credit, null)
                              : '—',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              const Divider(
                height: 1,
                color: Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 8),

              // TOTAL ROW
              Row(
                children: [
                  const Expanded(
                    flex: 9,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 78,
                    child: Text(
                      transactionController.formatCurrency(
                        group.totalDebit,
                        null,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorsList.textColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 78,
                    child: Text(
                      transactionController.formatCurrency(
                        group.totalCredit,
                        null,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorsList.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}