import 'package:docelix_mobileapp/controllers/dashboard_controller.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // ============================================================
  // CONTROLLER
  // ============================================================

  final DashboardController dashboardController = Get.put(DashboardController());

  // ============================================================
  // TAB
  // ============================================================

  int selectedTab = 0;

  final List<String> tabs = [
    "Overview",
    "Transactions",
   // "Analytics",
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Container(
      color: colorsList.backgroundColor,
      child: SafeArea(
        child: Obx(
              () {
            // ====================================================
            // LOADING
            // ====================================================

            if (dashboardController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ====================================================
            // CONTENT
            // ====================================================

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.012,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TOP HEADER
                  // ==================================================

                  _buildHeader(
                    width: width,
                    height: height,
                  ),

                  SizedBox(height: height * 0.018),

                  // ==================================================
                  // NET PROFIT MAIN CARD
                  // ==================================================

                  _buildNetProfitMainCard(
                    width: width,
                    height: height,
                  ),

                  SizedBox(height: height * 0.018),

                  // ==================================================
                  // TABS
                  // ==================================================

                  _buildTabs(
                    width: width,
                    height: height,
                  ),

                  SizedBox(height: height * 0.018),

                  // ==================================================
                  // SELECTED TAB CONTENT
                  // ==================================================

                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 300,
                    ),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildSelectedTab(
                      width: width,
                      height: height,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader({
    required double width,
    required double height,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SEP 2026  ·  FINANCIAL",
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.027,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(
                height: height * 0.003,
              ),

              Text(
                "Dashboard",
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.065,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // NET PROFIT MAIN CARD
  // ================================================================

  Widget _buildNetProfitMainCard({
    required double width,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        width * 0.055,
      ),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorsList.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ========================================================
          // DECORATIVE CIRCLE
          // ========================================================

          Positioned(
            right: -width * 0.08,
            top: -width * 0.12,
            child: Container(
              width: width * 0.34,
              height: width * 0.34,
              decoration: const BoxDecoration(
                color: colorsList.lightBlue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NET PROFIT - SEP 2026",
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.027,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(
                height: height * 0.008,
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${dashboardController.dashboardData.value?.kpis?.netResult?.value ?? 0}",
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.085,
                    ),
                  ),

                  SizedBox(
                    width: width * 0.025,
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.025,
                      vertical: height * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F8F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "44.4 %",
                      style: TextStyle(
                        color: colorsList.green,
                        fontSize: width * 0.028,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: height * 0.003,
              ),

              Text(
                "44.4% profit margin · best quarter on record",
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.028,
                ),
              ),

              SizedBox(
                height: height * 0.025,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rev  ${dashboardController.dashboardData.value?.kpis?.revenue?.value ?? 0}",
                    style: TextStyle(
                      color: colorsList.green,
                      fontSize: width * 0.029,
                    ),
                  ),

                  Text(
                    "Exp  ${dashboardController.dashboardData.value?.kpis?.expenses?.value ?? 0}",
                    style: TextStyle(
                      color: colorsList.red,
                      fontSize: width * 0.029,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: height * 0.008,
              ),

              Stack(
                children: [
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorsList.progressBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  FractionallySizedBox(
                    widthFactor: 0.30,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorsList.cyan,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
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
  // TABS
  // ================================================================

  Widget _buildTabs({
    required double width,
    required double height,
  }) {
    return SizedBox(
      height: height * 0.045,
      child: Row(
        children: List.generate(
          tabs.length,
              (index) {
            final bool isSelected =
                selectedTab == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                margin: EdgeInsets.only(
                  right: width * 0.02,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.045,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorsList.green
                      : Colors.transparent,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : colorsList.secondaryText,
                    fontSize: width * 0.028,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================================================================
  // SELECTED TAB
  // ================================================================

  Widget _buildSelectedTab({
    required double width,
    required double height,
  }) {
    switch (selectedTab) {
      case 0:
        return _buildOverviewTab(
          width: width,
          height: height,
        );

      case 1:
        return _buildTransactionsTab(
          width: width,
          height: height,
        );

      /*case 2:
        return _buildAnalyticsTab(
          width: width,
          height: height,
        );*/

      default:
        return _buildOverviewTab(
          width: width,
          height: height,
        );
    }
  }

  // ================================================================
  // OVERVIEW TAB
  // ================================================================

  Widget _buildOverviewTab({
    required double width,
    required double height,
  }) {
    return Column(
      key: const ValueKey(
        "overview_tab",
      ),
      children: [
        // ==========================================================
        // REVENUE / EXPENSES
        // ==========================================================

        Row(
          children: [
            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "REVENUE",
                value:
                "${dashboardController.dashboardData.value?.kpis?.revenue?.value ?? 0}",
                percentage: "+23.2%",
                subtitle: "vs last month",
                icon: Icons.attach_money_rounded,
                iconColor: colorsList.green,
              ),
            ),

            SizedBox(
              width: width * 0.025,
            ),

            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "EXPENSES",
                value:
                "${dashboardController.dashboardData.value?.kpis?.expenses?.value ?? 0}",
                percentage: "+4.8%",
                subtitle: "vs last month",
                icon:
                Icons.account_balance_wallet_outlined,
                iconColor: colorsList.red,
              ),
            ),
          ],
        ),

        SizedBox(
          height: height * 0.02,
        ),

        // ==========================================================
        // NET PROFIT / CASH BALANCE
        // ==========================================================

        Row(
          children: [
            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "NET PROFIT",
                value:
                "${dashboardController.dashboardData.value?.kpis?.netResult?.value ?? 0}",
                percentage: "+44.4%",
                subtitle: "44.4% margin",
                icon: Icons.trending_up_rounded,
                iconColor: colorsList.blue,
              ),
            ),

            SizedBox(
              width: width * 0.025,
            ),

            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "CASH BALANCE",
                value:
                "${dashboardController.dashboardData.value?.kpis?.cashBalance?.value ?? 0}",
                percentage: "+21.6%",
                subtitle: "all accounts",
                icon:
                Icons.account_balance_wallet_outlined,
                iconColor: colorsList.orange,
              ),
            ),
          ],
        ),

        SizedBox(
          height: height * 0.02,
        ),

        // ==========================================================
        // TAX RETURN
        // ==========================================================

        _buildTaxReturn(
          width: width,
          height: height,
        ),

        SizedBox(
          height: height * 0.02,
        ),

        // ==========================================================
        // MONTH SUMMARY
        // ==========================================================

        _buildMonthSummary(
          width: width,
          height: height,
        ),
      ],
    );
  }

  // ================================================================
  // TAX RETURN
  // ================================================================

  Widget _buildTaxReturn({
    required double width,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        width * 0.045,
      ),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5DDF0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                width: width * 0.11,
                height: width * 0.11,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EAFF),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: colorsList.purple,
                  size: width * 0.055,
                ),
              ),

              SizedBox(
                width: width * 0.035,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TAX RETURN",
                      style: TextStyle(
                        color:
                        colorsList.secondaryText,
                        fontSize: width * 0.026,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(
                      height: height * 0.004,
                    ),

                    Text(
                      "\$14,320",
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.055,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.025,
                      vertical: height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EAFF),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    child: Text(
                      "FY 2025",
                      style: TextStyle(
                        color: colorsList.purple,
                        fontSize: width * 0.027,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: height * 0.008,
                  ),

                  Text(
                    "refund pending",
                    style: TextStyle(
                      color:
                      colorsList.secondaryText,
                      fontSize: width * 0.024,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(
            height: height * 0.02,
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filing status",
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.026,
                ),
              ),

              Text(
                "72% processed",
                style: TextStyle(
                  color: colorsList.purple,
                  fontSize: width * 0.027,
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.008,
          ),

          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorsList.progressBackground,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.72,
              child: Container(
                decoration: BoxDecoration(
                  color: colorsList.purple,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // MONTH SUMMARY
  // ================================================================

  Widget _buildMonthSummary({
    required double width,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        width * 0.045,
      ),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorsList.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            "MONTH SUMMARY",
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width * 0.026,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(
            height: height * 0.018,
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Gross Revenue",
                style: TextStyle(
                  color: colorsList.lightText,
                  fontSize: width * 0.029,
                ),
              ),

              Text(
                "\$134,200",
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.030,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.01,
          ),

          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorsList.progressBackground,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.95,
              child: Container(
                decoration: BoxDecoration(
                  color: colorsList.green,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TRANSACTIONS TAB
  // ================================================================
  
  Widget _buildTransactionsTab({
    required double width,
    required double height,
  })
  {
    final transactions =
        dashboardController
            .dashboardData
            .value
            ?.recentTransactions ??
            [];

    return Column(
      key: const ValueKey("transactions_tab"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // TITLE
        // ==========================================================

        Text(
          "RECENT TRANSACTIONS",
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width * 0.027,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),

        SizedBox(
          height: height * 0.012,
        ),

        // ==========================================================
        // EMPTY STATE
        // ==========================================================

        if (transactions.isEmpty)
          _buildEmptyTransactions(
            width: width,
            height: height,
          ),

        // ==========================================================
        // TRANSACTION LIST
        // ==========================================================

        if (transactions.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.008,
            ),
            decoration: BoxDecoration(
              color: colorsList.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorsList.borderColor,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  color: colorsList.borderColor,
                );
              },
              itemBuilder: (context, index) {
                final transaction =
                transactions[index];

                return _buildTransactionItem(
                  transaction: transaction,
                  width: width,
                  height: height,
                );
              },
            ),
          ),
      ],
    );
  }

  // ================================================================
  // FINANCIAL CARD
  // ================================================================

  Widget _financialCard({
    required double width,
    required double height,
    required String title,
    required String value,
    required String percentage,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(
        width * 0.04,
      ),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: colorsList.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color:
                  colorsList.secondaryText,
                  fontSize: width * 0.024,
                  letterSpacing: 0.8,
                ),
              ),

              Container(
                width: width * 0.075,
                height: width * 0.075,
                decoration: BoxDecoration(
                  color:
                  iconColor.withOpacity(0.10),
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.042,
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.012,
          ),

          Text(
            value,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.043,
            ),
          ),

          SizedBox(
            height: height * 0.005,
          ),

          Row(
            children: [
              Text(
                percentage,
                style: TextStyle(
                  color: iconColor,
                  fontSize: width * 0.025,
                ),
              ),

              SizedBox(
                width: width * 0.012,
              ),

              Expanded(
                child: Text(
                  subtitle,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                    colorsList.secondaryText,
                    fontSize: width * 0.023,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // EMPTY TRANSACTIONS
  // ================================================================

  Widget _buildEmptyTransactions({
    required double width,
    required double height,
  })
  {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: height * 0.07,
        horizontal: width * 0.05,
      ),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: width * 0.16,
            height: width * 0.16,
            decoration: BoxDecoration(
              color: colorsList.green.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colorsList.green,
              size: width * 0.075,
            ),
          ),

          SizedBox(
            height: height * 0.018,
          ),

          Text(
            "No transactions found",
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.035,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(
            height: height * 0.006,
          ),

          Text(
            "There are no recent transactions for this period.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width * 0.026,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TRANSACTION ITEM
  // ================================================================

  Widget _buildTransactionItem({
    required RecentTransactionModel transaction,
    required double width,
    required double height,
  })
  {
    final bool isIncome =
    _isIncomeTransaction(transaction.type);

    final Color transactionColor =
    isIncome
        ? colorsList.green
        : colorsList.red;

    final IconData transactionIcon =
    _getTransactionIcon(transaction.type);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.018,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: width * 0.105,
            height: width * 0.105,
            decoration: BoxDecoration(
              color: transactionColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transactionIcon,
              color: transactionColor,
              size: width * 0.050,
            ),
          ),

          SizedBox(
            width: width * 0.030,
          ),

          // ========================================================
          // DESCRIPTION + TYPE + DATE
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // DESCRIPTION
                // --------------------------------------------------

                Text(
                  transaction.description ??
                      "Transaction",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.032,
                   // fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(
                  height: height * 0.004,
                ),

                // --------------------------------------------------
                // TYPE + DATE
                // --------------------------------------------------

                Row(
                  children: [
                    Text(
                      _formatTransactionType(
                        transaction.type,
                      ),
                      style: TextStyle(
                        color: transactionColor,
                        fontSize: width * 0.024,
                       // fontWeight: FontWeight.w600,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                      ),
                      child: Text(
                        "•",
                        style: TextStyle(
                          color:
                          colorsList.secondaryText,
                          fontSize: width * 0.022,
                        ),
                      ),
                    ),

                    Flexible(
                      child: Text(
                        _formatTransactionDate(
                          transaction.date,
                        ),
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                          colorsList.secondaryText,
                          fontSize: width * 0.024,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(
            width: width * 0.02,
          ),

          // ========================================================
          // AMOUNT
          // ========================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncome ? '+' : '-'}${_formatAmount(transaction.amount)}",
                style: TextStyle(
                  color: transactionColor,
                  fontSize: width * 0.031,
                //  fontWeight: FontWeight.w700,
                ),
              ),

              /*SizedBox(
                height: height * 0.004,
              ),

              Text(
                "ID: ${transaction.id ?? '-'}",
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.021,
                ),
              ),*/
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FORMAT AMOUNT
  // ================================================================

  String _formatAmount(num? amount) {
    if (amount == null) {
      return "0.00";
    }

    return amount.toStringAsFixed(2);
  }

  // ================================================================
  // TRANSACTION TYPE
  // ================================================================

  bool _isIncomeTransaction(String? type) {
    final transactionType =
    (type ?? '').toLowerCase().trim();

    return transactionType == 'income' ||
        transactionType == 'sale' ||
        transactionType == 'sales' ||
        transactionType == 'revenue' ||
        transactionType == 'credit' ||
        transactionType == 'deposit';
  }

  // ================================================================
  // FORMAT DATE
  // ================================================================

  String _formatTransactionDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return "";
    }

    try {
      final parsedDate = DateTime.parse(date);

      return DateFormat(
        'dd MMM yyyy',
      ).format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  // ================================================================
  // TRANSACTION ICON
  // ================================================================

  IconData _getTransactionIcon(String? type) {
    final transactionType =
    (type ?? '').toLowerCase().trim();

    if (transactionType == 'income' ||
        transactionType == 'sale' ||
        transactionType == 'sales' ||
        transactionType == 'revenue') {
      return Icons.arrow_upward_rounded;
    }

    if (transactionType == 'expense' ||
        transactionType == 'expenses') {
      return Icons.arrow_downward_rounded;
    }

    if (transactionType == 'purchase' ||
        transactionType == 'purchases') {
      return Icons.shopping_cart_outlined;
    }

    if (transactionType == 'payment' ||
        transactionType == 'payments') {
      return Icons.payments_outlined;
    }

    if (transactionType == 'bank') {
      return Icons.account_balance_outlined;
    }

    return Icons.receipt_long_outlined;
  }
}

  // ================================================================
  // FORMAT TRANSACTION TYPE
  // ================================================================

  String _formatTransactionType(String? type) {
    if (type == null || type.trim().isEmpty) {
      return "Transaction";
    }

    final value = type.trim();

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? ''
          : word[0].toUpperCase() +
          word.substring(1).toLowerCase(),
    )
        .join(' ');
  }