import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_incoming_invoice_controller.dart';
import 'package:docelix_mobileapp/controllers/dashboard_controller.dart';
import 'package:docelix_mobileapp/models/company_model.dart';
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
  final CreateIncomingInvoiceController incomingInvoiceController = Get.put(CreateIncomingInvoiceController());

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

  // ================================================================
// BUILD
// ================================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;
    final height = size.height;

    return Container(
      color: colorsList.backgroundColor,
      child: SafeArea(
        child: Obx(() {
          if (dashboardController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.055,
              vertical: height * 0.012,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================================
                // HEADER
                // ======================================================

                _buildHeader(
                  width: width,
                  height: height,
                ),

                SizedBox(height: height * 0.018),

                // ======================================================
                // NET PROFIT
                // ======================================================

                _buildNetProfitMainCard(
                  width: width,
                  height: height,
                ),

                SizedBox(height: height * 0.018),

                // ======================================================
                // TABS
                // ======================================================

                _buildTabs(
                  width: width,
                  height: height,
                ),

                SizedBox(height: height * 0.018),

                // ======================================================
                // SELECTED TAB
                // ======================================================

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
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
        }),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------------
        // LOGO + NOTIFICATION
        // ------------------------------------------------------------

        Row(
          children: [
            Expanded(
              child: Text(
                "Docelix",
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: width * 0.065,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                // Notification click functionality
                Get.toNamed('/NotificationScreen',
                  arguments: 'Notification Screen',);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: colorsList.primaryText,
                    size: width * 0.065,
                  ),

                  Positioned(
                    right: -2,
                    top: -4,
                    child: Container(
                      width: width * 0.042,
                      height: width * 0.042,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorsList.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.020,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /*Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: colorsList.primaryText,
                  size: width * 0.065,
                ),

                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    width: width * 0.042,
                    height: width * 0.042,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorsList.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.020,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),*/
          ],
        ),

        SizedBox(height: height * 0.018),

        // ------------------------------------------------------------
        // COMPANY + MONTH
        // ------------------------------------------------------------

        Row(
          children: [
            /*Expanded(
              child: _headerDropdown(
                width: width,
                icon: Icons.business_outlined,
                text: "Berrinex FlexKapG",
              ),
            ),*/

            Expanded(
              child: _companyDropdown(
                width: width,
              ),
            ),

            SizedBox(width: width * 0.025),

            /*Expanded(
              child: _headerDropdown(
                width: width,
                icon: Icons.calendar_today_outlined,
                text: "September 2026",
              ),
            ),*/

            Expanded(
              child: Obx(
                    () => _headerDropdown(
                  width: width,
                  icon: Icons.calendar_today_outlined,
                  text: dashboardController.selectedMonthText,
                  onTap: dashboardController.selectMonth,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


// ================================================================
// HEADER DROPDOWN
// ================================================================

  Widget _headerDropdown({
    required double width,
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: width * 0.105,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.030,
        ),
        decoration: BoxDecoration(
          color: colorsList.cardColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: width * 0.045,
              color: colorsList.primaryText,
            ),

            SizedBox(width: width * 0.025),

            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.027,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: width * 0.045,
              color: colorsList.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _companyDropdown({
    required double width,
  }) {
    return Obx(() {

      final controller = dashboardController;

      final selectedCompany =
          controller.selectedCompany.value;

      return Container(
        height: width * 0.105,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.030,
        ),
        decoration: BoxDecoration(
          color: colorsList.cardColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<CompanyModel>(
            value: selectedCompany,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: width * 0.045,
              color: colorsList.secondaryText,
            ),
            dropdownColor: colorsList.cardColor,

            hint: Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: width * 0.045,
                  color: colorsList.primaryText,
                ),
                SizedBox(width: width * 0.025),
                Text(
                  "Select company",
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.027,
                  ),
                ),
              ],
            ),

            selectedItemBuilder: (context) {
              return controller.companies.map(
                    (company) {
                  return Row(
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: width * 0.045,
                        color: colorsList.primaryText,
                      ),

                      SizedBox(width: width * 0.025),

                      Expanded(
                        child: Text(
                          company.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width * 0.027,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList();
            },

            items: controller.companies.map(
                  (company) {
                return DropdownMenuItem<CompanyModel>(
                  value: company,
                  child: Text(
                    company.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.027,
                    ),
                  ),
                );
              },
            ).toList(),

            onChanged: controller.isCompaniesLoading.value
                ? null
                : (CompanyModel? company) {

              if (company == null) return;

              controller.selectCompany(company);
            },
          ),
        ),
      );
    });
  }


// ================================================================
// NET PROFIT MAIN CARD
// ================================================================

  Widget _buildNetProfitMainCard({
    required double width,
    required double height,
  })
  {
    final netProfit =
        dashboardController.dashboardData.value?.kpis?.netResult?.value ?? 0;

    final revenue =
        dashboardController.dashboardData.value?.kpis?.revenue?.value ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.040),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colorsList.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // TITLE
          // ----------------------------------------------------------

          Text(
            "FINANCIAL OVERVIEW",
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width * 0.023,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.1,
            ),
          ),

          SizedBox(height: height * 0.010),

          Text(
            "Net profit",
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.032,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: height * 0.002),

          // ----------------------------------------------------------
          // VALUE + CHART
          // ----------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCurrency(netProfit),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.062,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: height * 0.009),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.020,
                            vertical: height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: colorsList.green.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "↑ ${dashboardController.dashboardData.value?.kpis?.revenue?.changePercent ?? 0}%",
                            style: TextStyle(
                              color: colorsList.green,
                              fontSize: width * 0.023,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(width: width * 0.018),

                        Flexible(
                          child: Text(
                            "${dashboardController.dashboardData.value?.kpis?.revenue?.changePercent ?? 0}% profit margin",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorsList.secondaryText,
                              fontSize: width * 0.022,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: width * 0.025),

              // Graph just hide due to unavailable data in APi.

              /*Expanded(
                flex: 4,
                child: SizedBox(
                  height: width * 0.17,
                  child: _buildProfitChart(
                    width: width,
                    height: height,
                  ),
                ),
              ),*/
            ],
          ),
        ],
      ),
    );
  }


// ================================================================
// PROFIT CHART
// ================================================================

  Widget _buildProfitChart({
    required double width,
    required double height,
  })
  {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ProfitChartPainter(
              lineColor: colorsList.green,
            ),
          ),
        ),

        SizedBox(height: height * 0.004),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _chartMonth("Apr", width),
            _chartMonth("May", width),
            _chartMonth("Jun", width),
            _chartMonth("Jul", width),
            _chartMonth("Aug", width),
            _chartMonth("Sep", width),
          ],
        ),
      ],
    );
  }


  Widget _chartMonth(
      String text,
      double width,
      )
  {
    return Text(
      text,
      style: TextStyle(
        color: colorsList.secondaryText,
        fontSize: width * 0.017,
      ),
    );
  }


// ================================================================
// TABS
// ================================================================

  Widget _buildTabs({
    required double width,
    required double height,
  })
  {
    return Container(
      height: width * 0.105,
      padding: EdgeInsets.all(width * 0.010),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
              (index) {
            final bool isSelected = selectedTab == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorsList.colorGray_1100
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : colorsList.secondaryText,
                      fontSize: width * 0.027,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
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
  })
  {
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
  })
  {
    final revenue =
        dashboardController.dashboardData.value?.kpis?.revenue?.value ?? 0;
    final revenuePercent =
        dashboardController.dashboardData.value?.kpis?.revenue?.changePercent ?? 0;

    final expenses =
        dashboardController.dashboardData.value?.kpis?.expenses?.value ?? 0;

    final expensesPercent =
        dashboardController.dashboardData.value?.kpis?.expenses?.changePercent ?? 0.0;

    final cashBalance =
        dashboardController.dashboardData.value?.kpis?.cashBalance?.value ?? 0;
    final cashBalancePercent =
        dashboardController.dashboardData.value?.kpis?.cashBalance?.changePercent ?? 0;

    final netProfit =
        dashboardController.dashboardData.value?.kpis?.netResult?.value ?? 0;
    final netProfitPercent =
        dashboardController.dashboardData.value?.kpis?.netResult?.changePercent ?? 0;

    return Column(
      key: const ValueKey("overview_tab"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // FINANCIAL CARDS
        // ==========================================================

        Row(
          children: [
            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "Revenue",
                value: _formatCurrency(revenue),
                percentage: _formatCurrency(revenuePercent),
                subtitle: "vs last month",
                icon: Icons.bar_chart_rounded,
                iconColor: colorsList.green,
              ),
            ),

            SizedBox(width: width * 0.025),

            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "Expenses",
                value: _formatCurrency(expenses),
                percentage: _formatCurrency(expensesPercent),
                subtitle: "vs last month",
                icon: Icons.wallet_outlined,
                iconColor: colorsList.red,
              ),
            ),
          ],
        ),

        SizedBox(height: height * 0.014),

        Row(
          children: [
            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "Cash balance",
                value: _formatCurrency(cashBalance),
                percentage: _formatCurrency(cashBalancePercent),
                subtitle: "vs last month your balance",
                icon: Icons.account_balance_outlined,
                iconColor: colorsList.orange,
              ),
            ),

            SizedBox(width: width * 0.025),

            Expanded(
              child: _financialCard(
                width: width,
                height: height,
                title: "Outstanding",
                value: _formatCurrency(netProfit),
                percentage: _formatCurrency(netProfitPercent),
                subtitle: "vs last month",
                icon: Icons.receipt_long_outlined,
                iconColor: colorsList.purple,
              ),
            ),
          ],
        ),

        SizedBox(height: height * 0.018),

        // ==========================================================
        // QUICK ACTIONS
        // ==========================================================

        _buildQuickActions(
          width: width,
          height: height,
        ),

        SizedBox(height: height * 0.018),

        // ==========================================================
        // OUTSTANDING AMOUNT
        // ==========================================================

        Obx(
              () => _buildOutStandingAmount(
            width: width,
            height: height,
          ),
        ),

        SizedBox(height: height * 0.018),

        // ==========================================================
        // RECENT TRANSACTION
        // ==========================================================

        /*_buildRecentTransactions(
          width: width,
          height: height,
        ),

        SizedBox(height: height * 0.018),*/

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
  })
  {
    return Container(
      constraints: BoxConstraints(
        minHeight: width * 0.225,
      ),
      padding: EdgeInsets.all(width * 0.032),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorsList.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.075,
                height: width * 0.075,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.040,
                ),
              ),

              SizedBox(width: width * 0.020),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.024,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.008),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.034,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: height * 0.003),

          if (percentage.isNotEmpty)
            Row(
              children: [
                Text(
                  percentage.startsWith("-")
                      ? "↓ $percentage"
                      : "↑ $percentage",
                  style: TextStyle(
                    color: percentage.startsWith("-")
                        ? colorsList.red
                        : iconColor,
                    fontSize: width * 0.020,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(width: width * 0.012),

                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorsList.secondaryText,
                      fontSize: width * 0.019,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width * 0.019,
              ),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // QUICK ACTIONS
  // ================================================================

  Widget _buildQuickActions({
    required double width,
    required double height,
  })
  {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.030),
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Quick actions",
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.037,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  // Open your complete quick actions screen here.
                },
                child: Row(
                  children: [
                    Text(
                      "See all",
                      style: TextStyle(
                        color: colorsList.green,
                        fontSize: width * 0.023,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorsList.green,
                      size: width * 0.045,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.012),

          Row(
            children: [
              Expanded(
                child: _quickActionItem(
                  width: width,
                  icon: Icons.note_add_outlined,
                  title: "Create invoice",
                  backgroundColor: colorsList.green.withOpacity(0.08),
                  iconColor: colorsList.green,
                  onTap: () {
                    // Get.toNamed('/CreateInvoiceScreen');

                    Get.toNamed(
                      '/CreateInvoiceScreen',
                      arguments: 'Create Invoices Screen',);
                  },
                ),
              ),

              SizedBox(width: width * 0.020),

              Expanded(
                child: _quickActionItem(
                  width: width,
                  icon: Icons.camera_alt_outlined,
                  title: "Capture invoice",
                  backgroundColor: colorsList.blue.withOpacity(0.08),
                  iconColor: colorsList.blue,
                  onTap: () {

                    Get.toNamed(
                      '/CreateIncomingInvoicesScreen',
                      arguments: 'Create Incoming Invoices Screen',
                    );

                  },
                ),
              ),

              SizedBox(width: width * 0.020),

              Expanded(
                child: _quickActionItem(
                  width: width,
                  icon: Icons.add_circle_outline_rounded,
                  title: "Add expense",
                  backgroundColor: colorsList.purple.withOpacity(0.08),
                  iconColor: colorsList.purple,
                  onTap: () {
                    // Get.toNamed('/AddExpenseScreen');

                    Get.toNamed('/IncomingInvoicesScreen',
                      arguments: 'Incoming Invoices Screen',
                    );

                   /* AppSnackbar.info(
                        title: 'Coming Soon',
                        message: 'Add Expenses coming soon.');*/
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // QUICK ACTION ITEM
  // ================================================================

  Widget _quickActionItem({
    required double width,
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: width * 0.155,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: width * 0.050,
              ),

              SizedBox(height: width * 0.012),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.020,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // OUTSTANDING AMOUNT
  // ================================================================

  Widget _buildOutStandingAmount({
    required double width,
    required double height,
  })
  {
    final dashboard = dashboardController.dashboardData.value;

    final overdueInvoices =
        dashboard?.outstanding?.overdueInvoices;

    final overdueCount =
        overdueInvoices?.count ?? 0;

    final overdueAmount =
        overdueInvoices?.amount ?? 0;

    final recievableInvoices =
        dashboard?.outstanding?.receivables;

    final recievableCount =
        recievableInvoices?.count ?? 0;

    final recievableAmount =
        recievableInvoices?.count ?? 0;

    final payableInvoices =
        dashboard?.outstanding?.payables;

    final payableCount =
        payableInvoices?.count ?? 0;

    final payableAmount =
        payableInvoices?.count ?? 0;


    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorsList.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.030,
              width * 0.030,
              width * 0.020,
              width * 0.020,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Outstanding Amount",
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.037,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // See All

                /*Row(
                  children: [
                    Text(
                      "See all",
                      style: TextStyle(
                        color: colorsList.green,
                        fontSize: width * 0.023,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorsList.green,
                      size: width * 0.045,
                    ),
                  ],
                ),*/
              ],
            ),
          ),

          // ==============================
          // RECEIVABLES INVOICES
          // ==============================

          _attentionItem(
            width: width,
            icon: Icons.arrow_downward,
            iconColor: colorsList.green,
            title: "$recievableCount receivables invoices",
            subtitle:
            "Total receivables amount € ${recievableAmount.toStringAsFixed(2)}",
            showDivider: true,
          ),

          // ==============================
          // PAYABLES
          // ==============================

          _attentionItem(
            width: width,
            icon: Icons.arrow_upward_rounded,
            iconColor: colorsList.red,
            title: "$payableCount payables invoices",
            subtitle:
            "Total payables amount € ${payableAmount.toStringAsFixed(2)}",
            showDivider: true,
          ),

          // ==============================
          // OVERDUE INVOICES
          // ==============================

          _attentionItem(
            width: width,
            icon: Icons.priority_high_rounded,
            iconColor: colorsList.orange,
            title: "$overdueCount overdue invoices",
            subtitle:
            "Total amount € ${overdueAmount.toStringAsFixed(2)}",
            showDivider: false,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // RECENT TRANSACTIONS
  // ================================================================

  Widget _buildRecentTransactions({
    required double width,
    required double height,
  })
  {
    return Obx(() {
      final transactions =
          dashboardController.dashboardData.value?.recentTransactions ?? [];

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorsList.cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.030,
                width * 0.030,
                width * 0.020,
                width * 0.020,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Recent transactions",
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.037,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        "See all",
                        style: TextStyle(
                          color: colorsList.green,
                          fontSize: width * 0.023,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorsList.green,
                        size: width * 0.045,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transactions
            if (transactions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: width * 0.06,
                ),
                child: Text(
                  "No recent transactions",
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.024,
                  ),
                ),
              )
            else
              ...List.generate(
                transactions.length,
                    (index) {
                  final transaction = transactions[index];

                  return _recentTransactionItem(
                    width: width,
                    transaction: transaction,
                    showDivider: index != transactions.length - 1,
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  // ================================================================
  // ATTENTION ITEM
  // ================================================================

  Widget _attentionItem({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
  })
  {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.030,
            vertical: width * 0.025,
          ),
          child: Row(
            children: [
              Container(
                width: width * 0.085,
                height: width * 0.085,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.045,
                ),
              ),

              SizedBox(width: width * 0.025),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.026,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: width * 0.006),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.022,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colorsList.secondaryText,
                size: width * 0.050,
              ),
            ],
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            color: colorsList.borderColor,
            indent: width * 0.14,
          ),
      ],
    );
  }

  // ================================================================
  // RECENT TRANSACTION ITEM
  // ================================================================

  Widget _recentTransactionItem({
    required double width,
    required RecentTransactionModel transaction,
    required bool showDivider,
  })
  {
    final type = transaction.type?.toLowerCase() ?? '';

    final bool isIncome =
        type == 'income' ||
            type == 'credit' ||
            type == 'received';

    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    final iconColor = isIncome
        ? colorsList.green
        : colorsList.red;

    final amount = transaction.amount ?? 0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.030,
            vertical: width * 0.025,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: width * 0.085,
                height: width * 0.085,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.045,
                ),
              ),

              SizedBox(width: width * 0.025),

              // Description + account
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description?.trim().isNotEmpty == true
                          ? transaction.description!
                          : "Transaction",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.026,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: width * 0.006),

                    Text(
                      _recentTransactionSubtitle(transaction),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.022,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: width * 0.015),

              // Amount
              Text(
                "${isIncome ? '+' : '-'} € ${amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  color: iconColor,
                  fontSize: width * 0.024,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Divider
        if (showDivider)
          Divider(
            height: 1,
            color: colorsList.borderColor,
            indent: width * 0.14,
          ),
      ],
    );
  }

  // ================================================================
  // CURRENCY FORMAT
  // ================================================================

  String _formatCurrency(dynamic value) {
    double amount = 0;

    if (value is num) {
      amount = value.toDouble();
    } else {
      amount = double.tryParse(
        value?.toString().replaceAll(',', '') ?? '',
      ) ??
          0;
    }

    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '€ $formattedInteger.$decimalPart';
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

  String _recentTransactionSubtitle(
      RecentTransactionModel transaction,
      )
  {
    final parts = <String>[];

    if (transaction.date?.trim().isNotEmpty == true) {
      parts.add(transaction.date!.trim());
    }

    if (transaction.account?.trim().isNotEmpty == true) {
      parts.add(transaction.account!.trim());
    }

    if (transaction.status?.trim().isNotEmpty == true) {
      parts.add(transaction.status!.trim());
    }

    return parts.isEmpty
        ? "Recent transaction"
        : parts.join(" • ");
  }
}

  // ================================================================
  // PROFIT CHART PAINTER
  // ================================================================

  class _ProfitChartPainter extends CustomPainter {
  final Color lineColor;

  _ProfitChartPainter({
    required this.lineColor,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final points = [
      Offset(size.width * 0.00, size.height * 0.82),
      Offset(size.width * 0.12, size.height * 0.6),
      Offset(size.width * 0.23, size.height * 0.2),
      Offset(size.width * 0.34, size.height * 0.43),
      Offset(size.width * 0.46, size.height * 0.52),
      Offset(size.width * 0.58, size.height * 0.22),
      Offset(size.width * 0.69, size.height * 0.42),
      Offset(size.width * 0.80, size.height * 0.25),
      Offset(size.width * 0.91, size.height * 0.33),
      Offset(size.width * 1.00, size.height * 0.08),
    ];

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final controlPoint1 = Offset(
        previous.dx + (current.dx - previous.dx) * 0.5,
        previous.dy,
      );

      final controlPoint2 = Offset(
        previous.dx + (current.dx - previous.dx) * 0.5,
        current.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    canvas.drawPath(
      path,
      paint,
    );

    // --------------------------------------------------------------
    // END POINT
    // --------------------------------------------------------------

    final endPoint = points.last;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      endPoint,
      3.5,
      dotPaint,
    );

    // --------------------------------------------------------------
    // VALUE LABEL
    // --------------------------------------------------------------

    final labelPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.58,
        0,
        size.width * 0.40,
        size.height * 0.25,
      ),
      const Radius.circular(5),
    );

    canvas.drawRRect(
      labelRect,
      labelPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _ProfitChartPainter oldDelegate,
      ) {
    return oldDelegate.lineColor != lineColor;
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