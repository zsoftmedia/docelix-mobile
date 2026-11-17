import 'package:docelix_mobileapp/controllers/bank_transactions_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/models/bank_transactions_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BankTransactionsScreen extends StatefulWidget {
  const BankTransactionsScreen({super.key});

  @override
  State<BankTransactionsScreen> createState() => _BankTransactionsScreenState();
}

class _BankTransactionsScreenState extends State<BankTransactionsScreen> {
  final BankTransactionsController controller = Get.put(BankTransactionsController());

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: rs.s(12.0)),

              // ======================================================
              // 1. TOP HEADER & TABS BAR (BANK STATEMENTS & TRANSACTIONS)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bank & Cash',
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: rs.sp(22.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs.s(12.0),
                          vertical: rs.s(6.0),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          controller.selectedTabIndex.value == 0
                              ? '${controller.totalStatementsCount.value > 0 ? controller.totalStatementsCount.value : controller.statements.length} Statements'
                              : '${controller.totalTransactionsCount.value > 0 ? controller.totalTransactionsCount.value : controller.transactions.length} Transactions',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontSize: rs.sp(11.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs.s(12.0)),

              // MAIN TABS SEGMENT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Obx(() {
                    final selectedIndex = controller.selectedTabIndex.value;

                    return Row(
                      children: List.generate(
                        BankTransactionsController.tabs.length,
                        (index) {
                          final isSelected = selectedIndex == index;
                          final tabLabel = BankTransactionsController.tabs[index];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorsList.colorButton
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  tabLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontSize: rs.sp(13.0),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: rs.s(14.0)),

              // ======================================================
              // 2. SEARCH BAR (MATCHING REQUESTED UI DESIGN)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44.0),
                  padding: EdgeInsets.symmetric(horizontal: rs.s(14.0)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: colorsList.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 3.0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20.0,
                      ),
                      SizedBox(width: rs.s(10.0)),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(13.0),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.0,
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
                            icon: const Icon(Icons.clear_rounded, size: 18.0, color: Color(0xFF94A3B8)),
                            onPressed: controller.clearSearch,
                          );
                        }
                        return const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18.0,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs.s(14.0)),

              // ======================================================
              // 3. TAB CONTENT
              // ======================================================
              Expanded(
                child: Obx(() {
                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      return _buildStatementsTab(context, controller, rs, isTab);
                    case 1:
                      return _buildTransactionsTab(context, controller, rs, isTab);
                    default:
                      return _buildStatementsTab(context, controller, rs, isTab);
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // TAB 1: BANK STATEMENTS
  // ================================================================

  Widget _buildStatementsTab(
    BuildContext context,
    BankTransactionsController controller,
    dynamic rs,
    bool isTab,
  ) {
    if (controller.isLoadingStatements.value && controller.filteredStatements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.filteredStatements.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.fetchStatements,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: rs.s(120.0)),
            Center(
              child: Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No matching statements found.'
                    : 'No bank statements recorded.',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: rs.sp(15.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final cols = rs.listColumns;
    final statements = controller.filteredStatements;

    if (cols <= 1) {
      return RefreshIndicator(
        onRefresh: controller.fetchStatements,
        child: ListView.builder(
          padding: EdgeInsets.only(
            left: (rs.pagePaddingH as num).toDouble(),
            right: (rs.pagePaddingH as num).toDouble(),
            top: rs.s(4.0),
            bottom: rs.s(96.0),
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: statements.length,
          itemBuilder: (context, index) {
            return _buildStatementCard(
              context: context,
              statement: statements[index],
              controller: controller,
              asGridTile: false,
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchStatements,
      child: GridView.builder(
        padding: EdgeInsets.only(
          left: (rs.pagePaddingH as num).toDouble(),
          right: (rs.pagePaddingH as num).toDouble(),
          top: rs.s(4.0),
          bottom: rs.s(96.0),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: rs.s(12.0),
          mainAxisSpacing: rs.s(12.0),
          childAspectRatio: rs.isTablet
              ? (rs.isLandscape ? 1.75 : 1.35)
              : (rs.isLandscape ? 2.6 : 1.8),
        ),
        itemCount: statements.length,
        itemBuilder: (context, index) {
          return _buildStatementCard(
            context: context,
            statement: statements[index],
            controller: controller,
            asGridTile: true,
          );
        },
      ),
    );
  }

  Widget _buildStatementCard({
    required BuildContext context,
    required BankStatementItem statement,
    required BankTransactionsController controller,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String statusStr = statement.displayStatus;

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTab ? 14.0 : rs.s(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFF2563EB), size: 20.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statement.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTab ? 14.0 : rs.sp(15.0),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A2342),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Period: ${statement.periodText}',
                        style: TextStyle(
                          fontSize: isTab ? 11.5 : rs.sp(11.5),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    statusStr,
                    style: TextStyle(
                      fontSize: isTab ? 11.0 : rs.sp(11.0),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: isTab ? 8.0 : 10.0),
              child: const Divider(height: 1.0, color: Color(0xFFF1F5F9)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Imported: ${controller.formatDateUI(statement.createdAt)}',
                  style: TextStyle(
                    fontSize: isTab ? 11.0 : rs.sp(11.0),
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  'Type: ${statement.fileType ?? 'finapi'}',
                  style: TextStyle(
                    fontSize: isTab ? 11.0 : rs.sp(11.0),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // TAB 2: BANK TRANSACTIONS
  // ================================================================

  Widget _buildTransactionsTab(
    BuildContext context,
    BankTransactionsController controller,
    dynamic rs,
    bool isTab,
  ) {
    if (controller.isLoadingTransactions.value && controller.filteredTransactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.filteredTransactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.fetchTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: rs.s(120.0)),
            Center(
              child: Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No matching transactions found.'
                    : 'No bank transactions recorded.',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: rs.sp(15.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final cols = rs.listColumns;
    final transactions = controller.filteredTransactions;

    if (cols <= 1) {
      return RefreshIndicator(
        onRefresh: controller.fetchTransactions,
        child: ListView.builder(
          padding: EdgeInsets.only(
            left: (rs.pagePaddingH as num).toDouble(),
            right: (rs.pagePaddingH as num).toDouble(),
            top: rs.s(4.0),
            bottom: rs.s(96.0),
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return _buildTransactionCard(
              context: context,
              transaction: transactions[index],
              controller: controller,
              asGridTile: false,
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchTransactions,
      child: GridView.builder(
        padding: EdgeInsets.only(
          left: (rs.pagePaddingH as num).toDouble(),
          right: (rs.pagePaddingH as num).toDouble(),
          top: rs.s(4.0),
          bottom: rs.s(96.0),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: rs.s(12.0),
          mainAxisSpacing: rs.s(12.0),
          childAspectRatio: rs.isTablet
              ? (rs.isLandscape ? 1.65 : 1.25)
              : (rs.isLandscape ? 2.6 : 1.8),
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(
            context: context,
            transaction: transactions[index],
            controller: controller,
            asGridTile: true,
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard({
    required BuildContext context,
    required BankTransactionItem transaction,
    required BankTransactionsController controller,
    required bool asGridTile,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final bool isPos = transaction.isPositive;
    final String statusStr = transaction.displayStatus;

    Color statusBg;
    Color statusText;

    if (statusStr == 'Categorized') {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
    } else {
      statusBg = const Color(0xFFFFFBEB);
      statusText = const Color(0xFFD97706);
    }

    final bankText = transaction.bankAccount != null
        ? transaction.bankAccount!.displayLabel
        : 'Bank Account';

    final counterpartyText = transaction.counterpartyName?.isNotEmpty == true
        ? transaction.counterpartyName!
        : (transaction.reference ?? '—');

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0.0 : 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTab ? 14.0 : rs.s(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. TOP HEADER ROW (BOOKING DATE + STATUS PILL)
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.formatDateUI(transaction.bookingDate),
                    style: TextStyle(
                      fontSize: isTab ? 13.0 : rs.sp(13.0),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(color: statusText, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        statusStr,
                        style: TextStyle(
                          fontSize: isTab ? 11.0 : rs.sp(11.0),
                          fontWeight: FontWeight.w600,
                          color: statusText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: isTab ? 8.0 : 10.0),
              child: const Divider(height: 1.0, color: Color(0xFFF1F5F9)),
            ),

            // 2. BOOKING TEXT & COUNTERPARTY
            Text(
              transaction.bookingText.isNotEmpty ? transaction.bookingText : 'Bank Transaction',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTab ? 14.0 : rs.sp(15.0),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0A2342),
              ),
            ),

            const SizedBox(height: 4.0),

            Text(
              counterpartyText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTab ? 12.0 : rs.sp(12.0),
                color: const Color(0xFF475569),
              ),
            ),

            const SizedBox(height: 2.0),

            Text(
              bankText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTab ? 11.0 : rs.sp(11.0),
                color: const Color(0xFF94A3B8),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: isTab ? 8.0 : 10.0),
              child: const Divider(height: 1.0, color: Color(0xFFF1F5F9)),
            ),

            // 3. BOTTOM AMOUNT & ACTION ROW (AMOUNT | CATEGORIZE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT',
                      style: TextStyle(
                        fontSize: isTab ? 9.5 : rs.sp(10.0),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      controller.formatCurrency(transaction.amount, transaction.currency),
                      style: TextStyle(
                        fontSize: isTab ? 14.0 : rs.sp(15.0),
                        fontWeight: FontWeight.bold,
                        color: isPos ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),

                OutlinedButton(
                  onPressed: () => _showCategorizeBottomSheet(context, transaction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Categorize', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CATEGORIZE / RECONCILE TRANSACTION BOTTOM SHEET (KEYBOARD AWARE)
  // ================================================================

  void _showCategorizeBottomSheet(BuildContext context, BankTransactionItem transaction) {
    if (controller.ledgerAccounts.isEmpty) {
      controller.fetchLedgerAccounts();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0 + bottomInset),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DRAG HANDLE
                  Center(
                    child: Container(
                      width: 38.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // TITLE ROW: Reconcile Transaction & Transaction #ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reconcile Transaction',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      Text(
                        'Transaction #${transaction.id}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14.0),

                  // TRANSACTION DETAILS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Date: ',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              transaction.bookingDate,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF0A2342), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            const Text(
                              'Amount: ',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              controller.formatCurrency(transaction.amount, transaction.currency),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: transaction.isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Text: ',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              child: Text(
                                transaction.bookingText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0A2342)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // COUNTER ACCOUNT DROPDOWN (API: GET /api/ledger/accounts)
                  const Text(
                    'Counter account',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6.0),

                  Obx(() {
                    if (controller.isLoadingAccounts.value && controller.ledgerAccounts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final accounts = controller.ledgerAccounts;

                    return DropdownButtonFormField<LedgerAccount>(
                      initialValue: controller.selectedCounterAccount.value,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                        ),
                      ),
                      items: accounts.map((acc) {
                        return DropdownMenuItem<LedgerAccount>(
                          value: acc,
                          child: Text(
                            acc.displayLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13.0, color: Color(0xFF0A2342)),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedCounterAccount.value = val;
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 14.0),

                  // NOTE (OPTIONAL)
                  const Text(
                    'Note (optional)',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  TextField(
                    controller: controller.memoController,
                    style: const TextStyle(fontSize: 13.0, color: Color(0xFF0A2342)),
                    decoration: InputDecoration(
                      hintText: 'Memo for audit trail',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // POSTING PREVIEW BOX
                  Obx(() {
                    final acc = controller.selectedCounterAccount.value;
                    final accLabel = acc != null ? acc.displayLabel : '0110 · Software and technology licences';
                    final isPos = transaction.isPositive;

                    final previewText = isPos
                        ? 'Debit 1000 Cash at bank / Credit $accLabel'
                        : 'Debit $accLabel / Credit 1000 Cash at bank';

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Posting preview:',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            previewText,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20.0),

                  // ACTION BUTTONS (POST AND MATCH | CLEAR)
                  Row(
                    children: [
                      Obx(() {
                        final isSubmitting = controller.isSubmittingReconcile.value;

                        return ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () => controller.postAndMatchTransaction(transaction, context),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded, size: 18.0),
                          label: Text(
                            isSubmitting ? 'Posting...' : 'Post and match',
                            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12.0),
                      OutlinedButton(
                        onPressed: controller.clearReconcileForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Clear', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}