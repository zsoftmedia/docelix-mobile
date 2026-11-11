import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_controller.dart';
import 'package:docelix_mobileapp/controllers/dashboard_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/company_model.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/ui/ledger_screen.dart';
import 'package:docelix_mobileapp/ui/profit_loss_screen.dart';
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
  final DashboardController dashboardController = Get.put(DashboardController());
  final CreatePurchaseInvoiceController incomingInvoiceController = Get.put(CreatePurchaseInvoiceController());

  int selectedTab = 0;

  final List<String> tabs = [
    "Overview",
    "Transactions",
  ];

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final width = rs.isPhone
        ? rs.width
        : ResponsiveBreakpoints.designWidth * rs.scale;
    final height = rs.isPhone
        ? rs.height
        : ResponsiveBreakpoints.designHeight * rs.scale;

    return Container(
      color: colorsList.backgroundColor,
      child: SafeArea(
        child: Obx(() {
          if (dashboardController.isLoading.value &&
              dashboardController.dashboardData.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ResponsivePage(
            padding: EdgeInsets.symmetric(
              horizontal: rs.isPhone ? width * 0.045 : rs.pagePaddingH,
              vertical: rs.isPhone ? height * 0.012 : rs.s(12),
            ),
            child: RefreshIndicator(
              onRefresh: dashboardController.getDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      width: width,
                      height: height,
                    ),
                    SizedBox(height: height * 0.018),
                    _buildNetProfitMainCard(
                      width: width,
                      height: height,
                    ),
                    SizedBox(height: height * 0.018),
                    _buildTabs(
                      width: width,
                      height: height,
                    ),
                    SizedBox(height: height * 0.018),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
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
                              begin: const Offset(0.02, 0),
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
              ),
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
        // 1. LOGO + NOTIFICATION BELL BUTTON
        Row(
          children: [
            Expanded(
              child: Image.asset(
                'assets/main_logo.png',
                height: width * 0.08,
                alignment: Alignment.centerLeft,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE2ECF8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                 // Get.toNamed('/SearchScreen');
                  AppSnackbar.info(title: 'Inprogress',
                      message: 'Coming Soon');
                },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: colorsList.iconColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: height * 0.02),

        // 2. DATE + DYNAMIC GREETING + SUBTITLE
        Text(
          dashboardController.dateHeaderText,
          style: TextStyle(
            fontSize: width.fontSizeW(0.025),
            fontWeight: FontWeight.normal,
            color: colorsList.secondaryText,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: height * 0.004),
        Text(
          dashboardController.greetingText,
          style: TextStyle(
            fontSize: width.fontSizeW(0.047),
            fontWeight: FontWeight.bold,
            color: colorsList.primaryText,
          ),
        ),
        SizedBox(height: height * 0.003),
        Text(
          "Here's what needs your attention today.",
          style: TextStyle(
            fontSize: width.fontSizeW(0.030),
            color: colorsList.secondaryText,
          ),
        ),

        SizedBox(height: height * 0.02),

        // 3. SEARCH BAR
        Container(
          height: width * 0.12,
          padding: EdgeInsets.symmetric(horizontal: width * 0.035),
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
                color: colorsList.dashboardhintColor,
                size: 20,
              ),
              SizedBox(width: width * 0.025),
              Expanded(
                child: TextField(
                  controller: dashboardController.searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search here',
                    hintStyle: TextStyle(
                      color: colorsList.dashboardhintColor,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      Get.toNamed('/SearchScreen', arguments: query.trim());
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.toNamed('/SearchScreen');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.tune_rounded,
                  color: colorsList.dashboardhintColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: height * 0.015),

        // 4. COMPANY & PERIOD DROPDOWNS (PRESERVED)
        Row(
          children: [
            Expanded(
              child: _companyDropdown(width: width),
            ),
            SizedBox(width: width * 0.025),
            Expanded(
              child: _periodDropdown(width: width),
            ),
          ],
        ),

        Obx(() {
          if (dashboardController.selectedPeriod.value != 'custom') {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              SizedBox(height: height * 0.007),
              Row(
                children: [
                  Expanded(
                    child: _headerDropdown(
                      width: width,
                      icon: Icons.calendar_today_outlined,
                      text: "From: ${dashboardController.fromDateText}",
                      onTap: dashboardController.selectFromDate,
                    ),
                  ),
                  SizedBox(width: width * 0.025),
                  Expanded(
                    child: _headerDropdown(
                      width: width,
                      icon: Icons.calendar_today_outlined,
                      text: "To: ${dashboardController.toDateText}",
                      onTap: dashboardController.selectToDate,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  // ================================================================
  // HEADER DROPDOWNS
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
                  fontSize: width.fontSizeW(0.027),
                  fontWeight: FontWeight.normal,
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

  Widget _periodDropdown({
    required double width,
  }) {
    return Obx(() {
      final controller = dashboardController;

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
          child: DropdownButton<String>(
            value: controller.selectedPeriod.value,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: width * 0.045,
              color: colorsList.secondaryText,
            ),
            dropdownColor: colorsList.cardColor,
            selectedItemBuilder: (context) {
              return DashboardController.periodOptions.map(
                (entry) {
                  return Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: width * 0.045,
                        color: colorsList.primaryText,
                      ),
                      SizedBox(width: width * 0.025),
                      Expanded(
                        child: Text(
                          entry.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width.fontSizeW(0.027),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList();
            },
            items: DashboardController.periodOptions.map(
              (entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width.fontSizeW(0.027),
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: (String? val) {
              if (val != null) {
                controller.selectPeriod(val);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _companyDropdown({
    required double width,
  }) {
    return Obx(() {
      final controller = dashboardController;
      final selectedCompany = controller.selectedCompany.value;

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
                    fontSize: width.fontSizeW(0.027),
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
                            fontSize: width.fontSizeW(0.027),
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
                      fontSize: width.fontSizeW(0.027),
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
  }) {
    final netProfit =
        dashboardController.dashboardData.value?.kpis?.netResult?.value ?? 0;
    final profitPercent =
        dashboardController.dashboardData.value?.kpis?.netResult?.changePercent ?? 0;

    return InkWell(
      onTap: () {
        AppSnackbar.info(
          title: 'Coming Soon',
          message: 'Financial Overview feature is coming soon.',
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          color: colorsList.financialCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorsList.dashboardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Financial Overview",
              style: TextStyle(
                fontSize: width.fontSizeW(0.028),
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: height * 0.006),
            Text(
              "Net Profit",
              style: TextStyle(
                fontSize: width.fontSizeW(0.036),
                fontWeight: FontWeight.normal,
                color: colorsList.primaryText,
              ),
            ),
            SizedBox(height: height * 0.008),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _formatCurrency(netProfit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: width.fontSizeW(0.06),
                      fontWeight: FontWeight.normal,
                      color: colorsList.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.028,
                    vertical: height * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: colorsList.lightGreenPillBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$profitPercent% of profit margin",
                    style: TextStyle(
                      fontSize: width.fontSizeW(0.026),
                      fontWeight: FontWeight.normal,
                      color: colorsList.lightGreenPillText,
                    ),
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
  // TABS
  // ================================================================

  Widget _buildTabs({
    required double width,
    required double height,
  })
  {
    return Container(
      height: width * 0.11,
      padding: EdgeInsets.all(width * 0.010),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorsList.borderColor),
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
                        ? colorsList.colorButton
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : colorsList.secondaryText,
                      fontSize: width.fontSizeW(0.030),
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
        // 2x2 KPI GRID CARDS
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = context.rs.kpiColumns;
            final gap = width * 0.025;
            final itemW =
                (constraints.maxWidth - gap * (cols - 1)) / cols;

            final cards = <Widget>[
              _financialCard(
                width: width,
                height: height,
                title: "Revenue",
                value: _formatCurrency(revenue),
                percentage: "$revenuePercent%",
                subtitle: "vs last month",
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBgColor: const Color(0xFFDCFCE7),
                onTap: () {

                  Get.toNamed(
                    '/ProfitLossScreen',
                    arguments: 'Profit Loss Screen',
                  );

                },
              ),
              _financialCard(
                width: width,
                height: height,
                title: "Expenses",
                value: _formatCurrency(expenses),
                percentage: "$expensesPercent%",
                subtitle: "vs last month",
                icon: Icons.credit_card_outlined,
                iconColor: const Color(0xFFDC2626),
                iconBgColor: const Color(0xFFFEE2E2),
                onTap: () {

                  Get.toNamed(
                    '/ProfitLossScreen',
                    arguments: 'Profit Loss Screen',
                  );

                },
              ),
              _financialCard(
                width: width,
                height: height,
                title: "Cash balance",
                value: _formatCurrency(cashBalance),
                percentage: "$cashBalancePercent%",
                subtitle: "vs last month",
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFEF3C7),
                onTap: () {

                  Get.toNamed(
                    '/LedgerScreen',
                    arguments: 'Ledger Screen',
                  );
                  
                },
              ),
              _financialCard(
                width: width,
                height: height,
                title: "Net Profit",
                value: _formatCurrency(netProfit),
                percentage: "$netProfitPercent%",
                subtitle: "vs last month",
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF),
                onTap: () {

                  Get.toNamed(
                    '/ProfitLossScreen',
                    arguments: 'Profit Loss Screen',
                  );

                },
              ),
            ];

            return Wrap(
              spacing: gap,
              runSpacing: height * 0.014,
              children: cards
                  .map((card) => SizedBox(width: itemW, child: card))
                  .toList(),
            );
          },
        ),

        SizedBox(height: height * 0.018),

        // QUICK ACTIONS
        _buildQuickActions(
          width: width,
          height: height,
        ),

        SizedBox(height: height * 0.018),

        // OUTSTANDING AMOUNT
        Obx(
          () => _buildOutStandingAmount(
            width: width,
            height: height,
          ),
        ),

        SizedBox(height: height * 0.018),
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
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    final bool isNegative = percentage.startsWith("-");

    return InkWell(
      onTap: onTap ??
          () {
            AppSnackbar.info(
              title: 'Coming Soon',
              message: '$title feature is coming soon.',
            );
          },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(width * 0.038),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorsList.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: width * 0.08,
                height: width * 0.08,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.042,
                ),
              ),
              SizedBox(width: width * 0.020),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width.fontSizeW(0.032),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.012),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width.fontSizeW(0.042),
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: height * 0.006),
          Row(
            children: [
              Text(
                isNegative ? "⇣ $percentage" : "⇡ $percentage",
                style: TextStyle(
                  color: isNegative ? colorsList.lightRedPillText : colorsList.lightGreenPillText,
                  fontSize: width.fontSizeW(0.026),
                  fontWeight: FontWeight.normal,
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
                    fontSize: width.fontSizeW(0.025),
                  ),
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
  // QUICK ACTIONS
  // ================================================================

  Widget _buildQuickActions({
    required double width,
    required double height,
  })
  {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.040),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width.fontSizeW(0.038),
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: height * 0.014),
          InkWell(
            onTap: () {
              Get.toNamed(
                '/CreateInvoiceScreen',
                arguments: 'Create Invoices Screen',
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: width * 0.13,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF16A34A),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: width * 0.025),
                  Text(
                    "Create invoice",
                    style: TextStyle(
                      color: const Color(0xFF16A34A),
                      fontSize: width.fontSizeW(0.033),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

    final overdueInvoices = dashboard?.outstanding?.overdueInvoices;
    final overdueCount = overdueInvoices?.count ?? 0;
    final overdueAmount = overdueInvoices?.amount ?? 0;

    final recievableInvoices = dashboard?.outstanding?.receivables;
    final recievableCount = recievableInvoices?.count ?? 0;
    final recievableAmount = recievableInvoices?.amount ?? 0;

    final payableInvoices = dashboard?.outstanding?.payables;
    final payableCount = payableInvoices?.count ?? 0;
    final payableAmount = payableInvoices?.amount ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.040,
              width * 0.035,
              width * 0.040,
              width * 0.020,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Outstanding Amount",
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width.fontSizeW(0.038),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  "3 Categories",
                  style: TextStyle(
                    color: const Color(0xFF16A34A),
                    fontSize: width.fontSizeW(0.028),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // RECEIVABLES INVOICES
          _attentionItem(
            width: width,
            icon: Icons.arrow_downward_rounded,
            iconColor: const Color(0xFF16A34A),
            iconBgColor: const Color(0xFFDCFCE7),
            title: "$recievableCount receivables invoices",
            subtitle: "Total receivables amount ${_formatCurrency(recievableAmount)}",
            showDivider: true,
            onTap: () {
              Get.toNamed(
                '/AccountReceivableScreen',
                arguments: 'Receivable Screen',
              );
            },
          ),

          // PAYABLES INVOICES
          _attentionItem(
            width: width,
            icon: Icons.arrow_upward_rounded,
            iconColor: const Color(0xFFDC2626),
            iconBgColor: const Color(0xFFFEE2E2),
            title: "$payableCount payables invoices",
            subtitle: "Total payables amount ${_formatCurrency(payableAmount)}",
            showDivider: true,
            onTap: () {
              Get.toNamed(
                '/AccountsPayableScreen',
                arguments: 'Receivable Screen',
              );
            },
          ),

          // OVERDUE INVOICES
          _attentionItem(
            width: width,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFD97706),
            iconBgColor: const Color(0xFFFEF3C7),
            title: "$overdueCount overdue invoices",
            subtitle: "Total amount ${_formatCurrency(overdueAmount)}",
            showDivider: false,
            onTap: () {
              Get.toNamed(
                '/ReceivablesDashboardScreen',
                arguments: 'Receivables Invoices Screen',
              );
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ATTENTION ITEM
  // ================================================================

  Widget _attentionItem({
    required double width,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool showDivider,
    VoidCallback? onTap,
  })
  {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.040,
                vertical: width * 0.030,
              ),
              child: Row(
                children: [
                  Container(
                    width: width * 0.085,
                    height: width * 0.085,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: width * 0.045,
                    ),
                  ),
                  SizedBox(width: width * 0.030),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width.fontSizeW(0.034),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(height: width * 0.006),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width.fontSizeW(0.027),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorsList.secondaryText,
                    size: width * 0.045,
                  ),
                ],
              ),
            ),
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
  // TRANSACTIONS TAB
  // ================================================================

  Widget _buildTransactionsTab({
    required double width,
    required double height,
  })
  {
    final transactions =
        dashboardController.dashboardData.value?.recentTransactions ?? [];

    return Column(
      key: const ValueKey("transactions_tab"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "RECENT TRANSACTIONS",
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width.fontSizeW(0.027),
                fontWeight: FontWeight.normal,
                letterSpacing: 1.1,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(
                  '/TransactionScreen',
                  arguments: 'Transaction Screen',
                );
              },
              child: Row(
                children: [
                  Text(
                    "See all",
                    style: TextStyle(
                      color: colorsList.secondaryTextColor,
                      fontSize: width.fontSizeW(0.023),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorsList.secondaryTextColor,
                    size: width * 0.045,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.012),
        if (transactions.isEmpty)
          _buildEmptyTransactions(
            width: width,
            height: height,
          )
        else
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
                  color: Colors.black.withValues(alpha: 0.035),
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
                final transaction = transactions[index];
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
              color: colorsList.green.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colorsList.green,
              size: width * 0.075,
            ),
          ),
          SizedBox(height: height * 0.018),
          Text(
            "No transactions found",
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width.fontSizeW(0.035),
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: height * 0.006),
          Text(
            "There are no recent transactions for this period.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width.fontSizeW(0.026),
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
    final bool isIncome = _isIncomeTransaction(transaction.type);
    final Color transactionColor = isIncome ? colorsList.green : colorsList.red;
    final IconData transactionIcon = _getTransactionIcon(transaction.type);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.018),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width * 0.105,
            height: width * 0.105,
            decoration: BoxDecoration(
              color: transactionColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transactionIcon,
              color: transactionColor,
              size: width * 0.050,
            ),
          ),
          SizedBox(width: width * 0.030),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? "Transaction",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width.fontSizeW(0.032),
                  ),
                ),
                SizedBox(height: height * 0.004),
                Row(
                  children: [
                    Text(
                      _formatTransactionType(transaction.type),
                      style: TextStyle(
                        color: transactionColor,
                        fontSize: width.fontSizeW(0.024),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                      ),
                      child: Text(
                        "•",
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.022),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _formatTransactionDate(transaction.date),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.024),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.02),
          Text(
            "${isIncome ? '+' : '-'} ${_formatAmount(transaction.amount)}",
            style: TextStyle(
              color: transactionColor,
              fontSize: width.fontSizeW(0.031),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FORMAT CURRENCY
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

    final symbol = dashboardController.currencySymbol;
    return '$symbol $formattedInteger.$decimalPart';
  }

  String _formatAmount(num? amount) {
    if (amount == null) return "0.00";
    return amount.toStringAsFixed(2);
  }

  bool _isIncomeTransaction(String? type) {
    final transactionType = (type ?? '').toLowerCase().trim();
    return transactionType == 'income' ||
        transactionType == 'sale' ||
        transactionType == 'sales' ||
        transactionType == 'revenue' ||
        transactionType == 'credit' ||
        transactionType == 'deposit';
  }

  String _formatTransactionDate(String? date) {
    if (date == null || date.trim().isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  IconData _getTransactionIcon(String? type) {
    final transactionType = (type ?? '').toLowerCase().trim();
    if (transactionType == 'income' ||
        transactionType == 'sale' ||
        transactionType == 'sales' ||
        transactionType == 'revenue') {
      return Icons.arrow_upward_rounded;
    }
    if (transactionType == 'expense' || transactionType == 'expenses') {
      return Icons.arrow_downward_rounded;
    }
    if (transactionType == 'purchase' || transactionType == 'purchases') {
      return Icons.shopping_cart_outlined;
    }
    if (transactionType == 'payment' || transactionType == 'payments') {
      return Icons.payments_outlined;
    }
    if (transactionType == 'bank') {
      return Icons.account_balance_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  String _formatTransactionType(String? type) {
    if (type == null || type.trim().isEmpty) return "Transaction";
    final value = type.trim();
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}