import 'package:docelix_mobileapp/controllers/profit_loss_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final ProfitLossController controller = Get.put(ProfitLossController());

  bool isRevenueExpanded = true;
  bool isExpensesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Obx(() {
            if (controller.isLoading.value && controller.reportData.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: rs.s(40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // 1. TOP HEADER BAR
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs.pagePaddingH,
                      vertical: rs.s(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2ECF8),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF063C70),
                              size: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Profit & Loss',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF0A2342),
                              fontSize: rs.sp(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => controller.fetchReport(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF475569)),
                          label: const Text('Refresh', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),

                  // ======================================================
                  // 2. PAGE TITLE & COMPANY PERIOD SUBTITLE
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profit & Loss',
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: rs.s(2)),
                        Text(
                          'Income, expenses and profitability for the selected period.',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: rs.sp(12),
                          ),
                        ),
                        SizedBox(height: rs.s(4)),
                        Obx(
                          () => Text(
                            '${controller.companyName} · ${controller.periodHeaderLabel}',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: rs.sp(11),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: rs.s(16)),

                  // ======================================================
                  // 3. FILTERS CONTROL CONTAINER
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: _buildFilterControlCard(context),
                  ),

                  SizedBox(height: rs.s(16)),

                  // ======================================================
                  // 4. METRIC CARDS (REVENUE, EXPENSES, NET PROFIT, NET MARGIN)
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: _buildMetricCards(context),
                  ),

                  SizedBox(height: rs.s(16)),

                  // ======================================================
                  // 5. GRAPH & PROFITABILITY SECTION
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: _buildChartAndProfitabilitySection(context),
                  ),

                  SizedBox(height: rs.s(16)),

                  // ======================================================
                  // 6. PROFIT & LOSS STATEMENT CARD
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: _buildStatementCard(context),
                  ),

                  SizedBox(height: rs.s(16)),

                  // ======================================================
                  // 7. EXPENSE BREAKDOWN CARD
                  // ======================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                    child: _buildExpenseBreakdownCard(context),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================================================================
  // FILTERS CONTROL CARD
  // ================================================================

  Widget _buildFilterControlCard(BuildContext context) {
    final rs = context.rs;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // PERIOD DROPDOWN
              Expanded(
                flex: 4,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: Obx(
                      () => DropdownButton<String>(
                        value: controller.selectedPeriod.value,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        items: ProfitLossController.periodOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt.key,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF475569)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    opt.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF0A2342)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectPeriod(val);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // FROM DATE
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => controller.selectFromDate(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            controller.fromDateText,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0A2342)),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // TO DATE
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => controller.selectToDate(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            controller.toDateText,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF0A2342)),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // COMPARE TOGGLE & RESET
          Row(
            children: [
              Obx(
                () => Switch.adaptive(
                  value: controller.compareLastYear.value,
                  activeColor: const Color(0xFF063C70),
                  onChanged: controller.toggleCompareLastYear,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Compare with same period last year',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ),
              TextButton.icon(
                onPressed: controller.resetFilters,
                icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF64748B)),
                label: const Text('Reset', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 4 METRIC CARDS
  // ================================================================

  Widget _buildMetricCards(BuildContext context) {
    final rs = context.rs;
    final isCompare = controller.compareLastYear.value;

    final revAccountsCount = controller.reportData.value?.revenue.accounts.length ?? 0;
    final expAccountsCount = controller.reportData.value?.expenses.accounts.length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = rs.isPhone ? 2 : 4;
        final gap = 12.0;
        final itemW = (constraints.maxWidth - gap * (cols - 1)) / cols;

        final cards = [
          _metricCard(
            title: 'TOTAL REVENUE',
            value: controller.formatCurrency(controller.totalRevenue),
            subtitle: isCompare ? 'No comparable figure last year' : '$revAccountsCount revenue account${revAccountsCount == 1 ? '' : 's'}',
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFF059669),
          ),
          _metricCard(
            title: 'TOTAL EXPENSES',
            value: controller.formatCurrency(controller.totalExpenses),
            subtitle: isCompare ? 'No comparable figure last year' : '$expAccountsCount expense account${expAccountsCount == 1 ? '' : 's'}',
            icon: Icons.subtitles_outlined,
            iconColor: const Color(0xFF64748B),
          ),
          _metricCard(
            title: 'NET PROFIT',
            value: controller.formatCurrency(controller.netProfit),
            valueColor: const Color(0xFF059669),
            subtitle: isCompare ? 'No comparable figure last year' : 'Revenue - expenses',
            icon: Icons.balance_rounded,
            iconColor: const Color(0xFF059669),
          ),
          _metricCard(
            title: 'NET MARGIN',
            value: '${controller.netMargin.toStringAsFixed(0)}%',
            subtitle: isCompare ? 'No comparable figure last year' : 'Net profit ÷ revenue',
            icon: Icons.percent_rounded,
            iconColor: const Color(0xFF063C70),
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards.map((c) => SizedBox(width: itemW, child: c)).toList(),
        );
      },
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0A2342),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 5. GRAPH & PROFITABILITY SECTION
  // ================================================================

  Widget _buildChartAndProfitabilitySection(BuildContext context) {
    return Column(
      children: [
        // CHART CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue vs expenses',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Posted amounts per period',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('Monthly', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text('Quarterly', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // DYNAMIC BAR & LINE CHART
              SizedBox(
                height: 180,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _RevenueExpensesChartPainter(
                    revenue: controller.totalRevenue,
                    expenses: controller.totalExpenses,
                    netResult: controller.netProfit,
                    symbol: controller.currencySymbol,
                    periodLabel: DateFormat('MMM yy').format(controller.fromDate.value),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // LEGEND
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ChartLegendDot(color: Color(0xFF94A3B8), label: 'Expenses'),
                  SizedBox(width: 16),
                  _ChartLegendDot(color: Color(0xFFE46025), label: 'Net result'),
                  SizedBox(width: 16),
                  _ChartLegendDot(color: Color(0xFF063C70), label: 'Revenue'),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'A single period has no trend; choose a longer range to compare periods.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // PROFITABILITY CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profitability',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
              ),
              const SizedBox(height: 2),
              const Text(
                'What this period\'s result means',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              // GREEN NET PROFIT BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NET PROFIT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669), letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.formatCurrency(controller.netProfit),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Revenue exceeded expenses by ${controller.formatCurrency(controller.netProfit)}.',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net margin', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  Text('${controller.netMargin.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                ],
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expense ratio', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                      Text('Expenses ÷ revenue', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                  Text('${controller.expenseRatio.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // 6. PROFIT & LOSS STATEMENT CARD
  // ================================================================

  Widget _buildStatementCard(BuildContext context) {
    final revenueObj = controller.reportData.value?.revenue;
    final expensesObj = controller.reportData.value?.expenses;

    final revAccounts = revenueObj?.accounts ?? [];
    final expAccounts = expensesObj?.accounts ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profit & Loss statement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Posted entries only · click an account to see its ledger',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    Text('Amount', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // REVENUE SECTION
          InkWell(
            onTap: () => setState(() => isRevenueExpanded = !isRevenueExpanded),
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(isRevenueExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, size: 18, color: const Color(0xFF475569)),
                  const SizedBox(width: 6),
                  Text(
                    'REVENUE  ${revAccounts.length} account${revAccounts.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),

          if (isRevenueExpanded)
            ...revAccounts.map((acc) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${acc.code}  ${acc.name}', style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                    Text(controller.formatCurrency(acc.balance), style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                  ],
                ),
              );
            }),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Revenue', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                Text(controller.formatCurrency(controller.totalRevenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // EXPENSES SECTION
          InkWell(
            onTap: () => setState(() => isExpensesExpanded = !isExpensesExpanded),
            child: Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(isExpensesExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded, size: 18, color: const Color(0xFF475569)),
                  const SizedBox(width: 6),
                  Text(
                    'EXPENSES  ${expAccounts.length} account${expAccounts.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),

          if (isExpensesExpanded)
            if (expAccounts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('No expenses posted in this period.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF94A3B8))),
              )
            else
              ...expAccounts.map((acc) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${acc.code}  ${acc.name}', style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                      Text(controller.formatCurrency(acc.balance), style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342))),
                    ],
                  ),
                );
              }),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
                Text(controller.formatCurrency(controller.totalExpenses), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A2342))),
              ],
            ),
          ),

          // NET PROFIT ROW
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDF4),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Profit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    SizedBox(height: 2),
                    Text('Total revenue - total expenses', style: TextStyle(fontSize: 11, color: Color(0xFF047857))),
                  ],
                ),
                Text(
                  controller.formatCurrency(controller.netProfit),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 7. EXPENSE BREAKDOWN CARD
  // ================================================================

  Widget _buildExpenseBreakdownCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Largest expense accounts by share of total expenses',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 24),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No expenses posted in this period.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _RevenueExpensesChartPainter extends CustomPainter {
  final double revenue;
  final double expenses;
  final double netResult;
  final String symbol;
  final String periodLabel;

  _RevenueExpensesChartPainter({
    required this.revenue,
    required this.expenses,
    required this.netResult,
    required this.symbol,
    required this.periodLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = (revenue > 0 || expenses > 0) ? ([revenue, expenses].reduce((a, b) => a > b ? a : b)) : 300.0;
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(fontSize: 10, color: Color(0xFF94A3B8));

    // Draw Grid Lines & Y-Labels
    final int steps = 4;
    for (int i = 0; i <= steps; i++) {
      final y = size.height * 0.8 - (i * (size.height * 0.75 / steps));
      final val = (maxVal / steps) * i;

      canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '$symbol${val.toInt()}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(35 - tp.width, y - tp.height / 2));
    }

    // X-Axis Label
    final xPos = size.width * 0.45;
    final textPainterX = TextPainter(
      text: TextSpan(text: periodLabel, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(canvas, Offset(xPos - textPainterX.width / 2, size.height * 0.86));

    // Draw Revenue Bar
    final barW = 28.0;
    final revHeight = (revenue / maxVal) * (size.height * 0.75);
    final revBarY = (size.height * 0.8) - revHeight;

    final revPaint = Paint()
      ..color = const Color(0xFF063C70)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(xPos - barW / 2, revBarY, barW, revHeight),
        const Radius.circular(4),
      ),
      revPaint,
    );

    // Draw Expenses Bar (if any)
    if (expenses > 0) {
      final expHeight = (expenses / maxVal) * (size.height * 0.75);
      final expBarY = (size.height * 0.8) - expHeight;

      final expPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(xPos - barW * 1.6, expBarY, barW, expHeight),
          const Radius.circular(4),
        ),
        expPaint,
      );
    }

    // Draw Net Result Dot
    final netHeight = (netResult / maxVal) * (size.height * 0.75);
    final netY = (size.height * 0.8) - netHeight;

    final dotPaint = Paint()
      ..color = const Color(0xFFE46025)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(xPos + barW * 1.5, netY), 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RevenueExpensesChartPainter oldDelegate) {
    return oldDelegate.revenue != revenue || oldDelegate.expenses != expenses || oldDelegate.netResult != netResult;
  }
}