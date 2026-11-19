import 'package:docelix_mobileapp/controllers/journal_entries_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/general_ledger_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JournalEntriesScreen extends StatelessWidget {
  const JournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JournalEntriesController());
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: rs.s(12)),

              // ======================================================
              // 1. TITLE & TOTAL COUNT BADGE
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journal Entries',
                            style: TextStyle(
                              color: const Color(0xFF0A2342),
                              fontSize: rs.sp(22),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: rs.s(2)),
                          Text(
                            'View, review, and balance your ledger journal entries.',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: rs.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(12),
                          vertical: rs.s(6),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          '${controller.totalJournalEntriesCount.value > 0 ? controller.totalJournalEntriesCount.value : controller.journalEntries.length} entries',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontSize: rs.sp(11),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 2. SEARCH BAR (MATCHING REQUESTED UI DESIGN)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44),
                  padding: EdgeInsets.symmetric(horizontal: rs.s(14)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: colorsList.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      SizedBox(width: rs.s(10)),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(13),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: controller.clearSearch,
                          );
                        }
                        return const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 3. JOURNAL ENTRIES LIST / GRID
              // ======================================================
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.filteredJournalEntries.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.filteredJournalEntries.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: controller.fetchJournalEntries,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rs.s(120)),
                          Center(
                            child: Text(
                              controller.searchQuery.value.isNotEmpty
                                  ? 'No matching journal entries found.'
                                  : 'No journal entries available.',
                              style: TextStyle(
                                color: colorsList.textHintColor,
                                fontSize: rs.sp(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cols = rs.listColumns;
                  final entries = controller.filteredJournalEntries;

                  if (cols <= 1) {
                    return RefreshIndicator(
                      onRefresh: controller.fetchJournalEntries,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: rs.pagePaddingH,
                          right: rs.pagePaddingH,
                          top: rs.s(4),
                          bottom: rs.s(16),
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return _buildJournalEntryCard(
                            context: context,
                            entry: entries[index],
                            controller: controller,
                            asGridTile: false,
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchJournalEntries,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        left: rs.pagePaddingH,
                        right: rs.pagePaddingH,
                        top: rs.s(4),
                        bottom: rs.s(16),
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: rs.s(12),
                        mainAxisSpacing: rs.s(12),
                        childAspectRatio: rs.isTablet
                            ? (rs.isLandscape ? 1.40 : 1.02)
                            : (rs.isLandscape ? 2.40 : 1.50),
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return _buildJournalEntryCard(
                          context: context,
                          entry: entries[index],
                          controller: controller,
                          asGridTile: true,
                        );
                      },
                    ),
                  );
                }),
              ),

              // ======================================================
              // 4. BOTTOM TOTALS SUMMARY BAR (MATCHES WEB 100%)
              // ======================================================
              Obx(() {
                if (controller.filteredJournalEntries.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.pagePaddingH,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Total (this page)',
                        style: TextStyle(
                          fontSize: isTab ? 13 : rs.sp(13),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A2342),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: controller.isBalanced
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.isBalanced
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Text(
                          controller.isBalanced ? 'Balanced' : 'Unbalanced',
                          style: TextStyle(
                            fontSize: isTab ? 11 : rs.sp(11),
                            fontWeight: FontWeight.bold,
                            color: controller.isBalanced
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.formatMoney(controller.totalPageDebit),
                            style: TextStyle(
                              fontSize: isTab ? 14 : rs.sp(14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A2342),
                            ),
                          ),
                          Text(
                            'Debit / Credit',
                            style: TextStyle(
                              fontSize: isTab ? 10 : rs.sp(10),
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // JOURNAL ENTRY CARD WIDGET (MATCHES WEB TABLE 100%)
  // ================================================================

  Widget _buildJournalEntryCard({
    required BuildContext context,
    required JournalEntryItem entry,
    required JournalEntriesController controller,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String paymentStatus = entry.paymentStatusLabel;
    Color payBg;
    Color payText;

    if (paymentStatus == 'Paid') {
      payBg = const Color(0xFFECFDF5);
      payText = const Color(0xFF059669);
    } else if (paymentStatus == 'Unpaid') {
      payBg = const Color(0xFFFEF2F2);
      payText = const Color(0xFFDC2626);
    } else if (paymentStatus == 'Settlement') {
      payBg = const Color(0xFFEFF6FF);
      payText = const Color(0xFF2563EB);
    } else {
      payBg = const Color(0xFFF1F5F9);
      payText = const Color(0xFF64748B);
    }

    final reconStatus = entry.reconciliation?.displayStatus ?? '—';
    final bool isNotReconciled = entry.reconciliation?.status == 'not_reconciled';

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          /*onTap: () {
            Get.toNamed('/JournalEntryDetailsScreen', arguments: entry);
          },*/
          child: Padding(
            padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER ROW (DATE + PAYMENT BADGE + RECONCILIATION BADGE)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.entryDate.isNotEmpty ? entry.entryDate : '—',
                        style: TextStyle(
                          fontSize: isTab ? 13 : rs.sp(13),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    if (paymentStatus != '—') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: payBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          paymentStatus,
                          style: TextStyle(
                            fontSize: isTab ? 11 : rs.sp(11),
                            fontWeight: FontWeight.w600,
                            color: payText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (reconStatus != '—') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isNotReconciled ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isNotReconciled ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          reconStatus,
                          style: TextStyle(
                            fontSize: isTab ? 11 : rs.sp(11),
                            fontWeight: FontWeight.w600,
                            color: isNotReconciled ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 10),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 2. PARTICULARS / DESCRIPTION
                Text(
                  entry.description.isNotEmpty ? entry.description : 'Journal Entry #${entry.id}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTab ? 14 : rs.sp(15),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0A2342),
                  ),
                ),

                const SizedBox(height: 8),

                // 3. ACCOUNT LINES BREAKDOWN (MATCHING WEB SCREENSHOT COLUMNS)
                ...() {
                  final linesToDisplay = asGridTile && entry.lines.length > 2
                      ? entry.lines.take(2).toList()
                      : entry.lines;
                  final remainingCount = entry.lines.length - linesToDisplay.length;

                  return [
                    ...linesToDisplay.map((line) {
                      final bool isDebit = line.debit > 0;
                      final accountLabel = line.account?.displayLabel ?? 'Account';
                      final amountText = isDebit
                          ? controller.formatMoney(line.debit)
                          : controller.formatMoney(line.credit);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDebit ? accountLabel : 'to $accountLabel',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isTab ? 12 : rs.sp(12),
                                      fontWeight: isDebit ? FontWeight.bold : FontWeight.normal,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  if (line.description.isNotEmpty)
                                    Text(
                                      line.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: isTab ? 10.5 : rs.sp(10.5),
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              amountText,
                              style: TextStyle(
                                fontSize: isTab ? 12 : rs.sp(12),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0A2342),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (remainingCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 4),
                        child: Text(
                          '+ $remainingCount more lines',
                          style: TextStyle(
                            fontSize: isTab ? 11 : rs.sp(11),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                  ];
                }(),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 10),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 4. BOTTOM AMOUNTS & ACTION ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL DEBIT / CREDIT',
                          style: TextStyle(
                            fontSize: isTab ? 9.5 : rs.sp(10),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.formatMoney(entry.totalDebit),
                          style: TextStyle(
                            fontSize: isTab ? 13.5 : rs.sp(14),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A2342),
                          ),
                        ),
                      ],
                    ),

                    /*if (isNotReconciled)
                      OutlinedButton(
                        onPressed: () {
                          // Action button matching web table
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reconcile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      )
                    else
                      Text(
                        'Entry #${entry.id}',
                        style: TextStyle(
                          fontSize: isTab ? 11 : rs.sp(11),
                          color: const Color(0xFF94A3B8),
                        ),
                      ),*/
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}