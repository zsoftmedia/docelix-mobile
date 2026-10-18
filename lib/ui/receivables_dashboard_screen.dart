import 'package:docelix_mobileapp/controllers/receivables_dashboard_controller.dart';
import 'package:docelix_mobileapp/models/receivables_dashboard_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceivablesDashboardScreen extends StatelessWidget {
  ReceivablesDashboardScreen({super.key});

  final ReceivablesDashboardController dashboardController = Get.put(
    ReceivablesDashboardController(),
  );

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: context.s(20),
            color: colorsList.textColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),

        title: Text(
          'Receivables',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: context.sp(20),
            fontWeight: FontWeight.normal,
          ),
        ),

        actions: [
          Obx(
            () => IconButton(
              onPressed: dashboardController.isLoading.value
                  ? null
                  : dashboardController.getReceivablesDashboard,
              icon: Icon(Icons.refresh_rounded, color: colorsList.iconColor),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: colorsList.textColor),
          );
        }

        final data = dashboardController.receivablesDashboard.value;

        return RefreshIndicator(
          color: colorsList.textColor,

          onRefresh: dashboardController.getReceivablesDashboard,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            child: ResponsivePage(
              padding: EdgeInsets.symmetric(
                horizontal: rs.pagePaddingH,
                vertical: context.s(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // DATE FILTER
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _headerDropdown(
                            context,
                            icon: Icons.calendar_today_outlined,
                            text:
                                "From: ${dashboardController.fromDateText.value}",
                            onTap: dashboardController.selectFromDate,
                          ),
                        ),
                      ),

                      SizedBox(width: rs.s(10)),

                      Expanded(
                        child: Obx(
                          () => _headerDropdown(
                            context,
                            icon: Icons.calendar_today_outlined,
                            text: "To: ${dashboardController.toDateText.value}",
                            onTap: dashboardController.selectToDate,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.s(20)),

                  // ==================================================
                  // NO DATA
                  // ==================================================
                  if (data == null)
                    _emptyState(context)
                  else ...[
                    // ==============================================
                    // KPI SECTION
                    // ==============================================

                    _sectionTitle(context, 'Receivables Overview'),

                    SizedBox(height: context.s(12)),

                    _buildKpiGrid(context, data),

                    SizedBox(height: context.s(24)),

                    // ==============================================
                    // AGING
                    // ==============================================
                    _sectionTitle(context, 'Receivables Aging'),

                    SizedBox(height: context.s(12)),

                    _buildAging(context, data),

                    SizedBox(height: context.s(24)),

                    // ==============================================
                    // ATTENTION INVOICES
                    // ==============================================
                    _sectionTitle(context, 'Invoices Requiring Attention'),

                    SizedBox(height: context.s(12)),

                    _buildAttentionInvoices(context, data),

                    SizedBox(height: context.s(24)),

                    // ==============================================
                    // COLLECTION PERFORMANCE
                    // ==============================================
                    _sectionTitle(context, 'Collection Performance'),

                    SizedBox(height: context.s(12)),

                    _buildCollectionPerformance(context, data),

                    SizedBox(height: context.s(24)),

                    // ==============================================
                    // COLLECTION RISK
                    // ==============================================
                    _sectionTitle(context, 'Collection Risk'),

                    SizedBox(height: context.s(12)),

                    _buildCollectionRisk(context, data),

                    SizedBox(height: context.s(24)),

                    // ==============================================
                    // RECONCILIATION
                    // ==============================================
                    _sectionTitle(context, 'Reconciliation'),

                    SizedBox(height: context.s(12)),

                    _buildReconciliation(context, data),

                    SizedBox(height: context.s(30)),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ============================================================
  // HEADER DATE DROPDOWN
  // ============================================================

  Widget _headerDropdown(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(10),

      child: Container(
        height: context.s(48),

        padding: EdgeInsets.symmetric(horizontal: context.s(12)),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: colorsList.borderColor),
        ),

        child: Row(
          children: [
            Icon(icon, size: context.s(18), color: colorsList.iconColor),

            SizedBox(width: context.s(8)),

            Expanded(
              child: Text(
                text,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(width: context.s(4)),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: context.s(20),
              color: colorsList.iconColor,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,

      style: TextStyle(
        color: colorsList.textColor,
        fontSize: context.sp(18),
        fontWeight: FontWeight.normal,
      ),
    );
  }

  // ============================================================
  // KPI GRID
  // ============================================================

  Widget _buildKpiGrid(BuildContext context, ReceivablesDashboardModel data) {
    final kpis = data.kpis;

    if (kpis == null) {
      return const SizedBox();
    }

    final cards = <Widget>[
      _kpiCard(
        context,
        title: 'Total Receivables',
        amount: kpis.totalReceivables.amount,
        count: kpis.totalReceivables.count,
        icon: Icons.account_balance_wallet_outlined,
      ),
      _kpiCard(
        context,
        title: 'Overdue',
        amount: kpis.overdueReceivables.amount,
        count: kpis.overdueReceivables.count,
        icon: Icons.warning_amber_rounded,
      ),
      _kpiCard(
        context,
        title: 'Not Due',
        amount: kpis.notDueReceivables.amount,
        count: kpis.notDueReceivables.count,
        icon: Icons.schedule_rounded,
      ),
      _kpiCard(
        context,
        title: 'Customers Past Due',
        amount: kpis.customersPastDue.amount,
        count: kpis.customersPastDue.count,
        icon: Icons.people_outline_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final rs = context.rs;
        final int cols = rs.kpiColumns.clamp(1, cards.length);
        final double gap = context.s(12);
        final double cardWidth =
            ((constraints.maxWidth - gap * (cols - 1)) / cols).floorToDouble();

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  // ============================================================
  // KPI CARD
  // ============================================================

  Widget _kpiCard(
    BuildContext context, {
    required String title,
    required double amount,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(context.s(15)),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: colorsList.borderColor),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textHintColor,
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),

              Icon(icon, size: context.s(21), color: colorsList.iconColor),
            ],
          ),

          SizedBox(height: context.s(12)),

          Text(
            dashboardController.formatAmount(amount),

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              color: colorsList.textColor,
              fontSize: context.sp(18),
              fontWeight: FontWeight.normal,
            ),
          ),

          SizedBox(height: context.s(5)),

          Text(
            '$count invoice${count == 1 ? '' : 's'}',

            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: context.sp(11),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AGING
  // ============================================================

  Widget _buildAging(BuildContext context, ReceivablesDashboardModel data) {
    final aging = data.aging;

    if (aging == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      context,
      child: Column(
        children: [
          _agingRow(context, 'Not Due', aging.notDue),

          _divider(context),

          _agingRow(context, '1 - 30 Days', aging.days1to30),

          _divider(context),

          _agingRow(context, '31 - 60 Days', aging.days31to60),

          _divider(context),

          _agingRow(context, '61 - 90 Days', aging.days61to90),

          _divider(context),

          _agingRow(context, '90+ Days', aging.days90Plus),
        ],
      ),
    );
  }

  Widget _agingRow(BuildContext context, String title, AgingItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.s(8)),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: TextStyle(
                color: colorsList.textColor,
                fontSize: context.sp(13),
              ),
            ),
          ),

          Text(
            dashboardController.formatAmount(item.amount),

            style: TextStyle(
              color: colorsList.textColor,
              fontSize: context.sp(13),
              // fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(width: context.s(12)),

          SizedBox(
            width: context.s(45),

            child: Text(
              '${item.percentage}%',

              textAlign: TextAlign.right,

              style: TextStyle(
                color: colorsList.textHintColor,
                fontSize: context.sp(11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTENTION INVOICES
  // ============================================================

  Widget _buildAttentionInvoices(
    BuildContext context,
    ReceivablesDashboardModel data,
  ) {
    if (data.attentionInvoices.isEmpty) {
      return _emptyBox(context, 'No invoices require attention.');
    }

    return Column(
      children: data.attentionInvoices
          .map(
            (invoice) => Container(
              width: double.infinity,

              margin: EdgeInsets.only(bottom: context.s(10)),

              padding: EdgeInsets.all(context.s(14)),

              decoration: BoxDecoration(
                color: colorsList.colorBoxDecoration,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: colorsList.borderColor),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          invoice.customer,

                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: context.sp(14),
                            // fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Text(
                        dashboardController.formatAmount(invoice.balance),

                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: context.sp(14),
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.s(7)),

                  Text(
                    invoice.invoiceNo,
                    style: TextStyle(
                      color: colorsList.textHintColor,
                      fontSize: context.sp(11),
                    ),
                  ),

                  SizedBox(height: context.s(10)),

                  Row(
                    children: [
                      _statusBadge(context, invoice.status),

                      const Spacer(),

                      Text(
                        '${invoice.daysOverdue} days overdue',

                        style: TextStyle(
                          color: colorsList.textHintColor,
                          fontSize: context.sp(11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // COLLECTION PERFORMANCE
  // ============================================================

  Widget _buildCollectionPerformance(
    BuildContext context,
    ReceivablesDashboardModel data,
  ) {
    final performance = data.collectionPerformance;

    if (performance == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      context,
      child: Column(
        children: [
          _infoRow(
            context,
            'DSO',
            '${performance.dso.toStringAsFixed(0)} days',
          ),

          _divider(context),

          _infoRow(
            context,
            'Average Days Overdue',
            performance.avgDaysOverdue == null
                ? 'N/A'
                : '${performance.avgDaysOverdue!.toStringAsFixed(0)} days',
          ),

          _divider(context),

          _infoRow(
            context,
            'Overdue Share',
            '${performance.overdueShare.toStringAsFixed(1)}%',
          ),

          _divider(context),

          _infoRow(
            context,
            'Period Sales',
            dashboardController.formatAmount(performance.periodSales),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLLECTION RISK
  // ============================================================

  Widget _buildCollectionRisk(
    BuildContext context,
    ReceivablesDashboardModel data,
  ) {
    final risk = data.collectionRisk;

    if (risk == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: context.s(22),
                color: colorsList.iconColor,
              ),

              SizedBox(width: context.s(10)),

              Text(
                'Risk Level',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: context.sp(13),
                ),
              ),

              const Spacer(),

              _riskBadge(context, risk.level),
            ],
          ),

          SizedBox(height: context.s(16)),

          ...risk.reasons.map(
            (reason) => Padding(
              padding: EdgeInsets.only(bottom: context.s(10)),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    reason.tone == 'positive'
                        ? Icons.check_circle_outline
                        : Icons.info_outline,

                    size: context.s(18),

                    color: colorsList.iconColor,
                  ),

                  SizedBox(width: context.s(8)),

                  Expanded(
                    child: Text(
                      reason.text,

                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: context.sp(13),
                      ),
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

  // ============================================================
  // RECONCILIATION
  // ============================================================

  Widget _buildReconciliation(
    BuildContext context,
    ReceivablesDashboardModel data,
  ) {
    final reconciliation = data.reconciliation;

    if (reconciliation == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      context,
      child: Column(
        children: [
          _infoRow(
            context,
            'Subledger',
            dashboardController.formatAmount(reconciliation.subledger),
          ),

          _divider(context),

          _infoRow(
            context,
            'GL 1100',
            dashboardController.formatAmount(reconciliation.gl1100),
          ),

          _divider(context),

          _infoRow(
            context,
            'Difference',
            dashboardController.formatAmount(reconciliation.difference),
          ),

          _divider(context),

          _infoRow(context, 'As Of', reconciliation.asOf),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _sectionContainer(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(context.s(16)),

      decoration: BoxDecoration(
        color: colorsList.colorBoxDecoration,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),

      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(BuildContext context, String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,

            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: context.sp(13),
            ),
          ),
        ),

        Text(
          value,

          style: TextStyle(
            color: colorsList.textColor,
            fontSize: context.sp(13),
            //fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(BuildContext context, String status) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.s(9),
        vertical: context.s(5),
      ),

      decoration: BoxDecoration(
        color: Color(0xFFE9EEF4),

        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        status,

        style: TextStyle(
          color: Color(0xFF063C70),
          fontSize: context.sp(10),
          // fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // RISK BADGE
  // ============================================================

  Widget _riskBadge(BuildContext context, String level) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.s(12),
        vertical: context.s(6),
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        level.toUpperCase(),

        style: TextStyle(
          fontSize: context.sp(10),
          // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider(BuildContext context) {
    return const Divider(height: 1, color: colorsList.dividerColor);
  }

  // ============================================================
  // EMPTY BOX
  // ============================================================

  Widget _emptyBox(BuildContext context, String message) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(context.s(20)),

      decoration: BoxDecoration(
        border: Border.all(color: colorsList.colorBoxDecoration),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Center(
        child: Text(
          message,

          style: TextStyle(
            color: colorsList.textHintColor,
            fontSize: context.sp(13),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(top: context.s(50)),

      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: context.s(50),
            color: Colors.grey,
          ),

          SizedBox(height: context.s(12)),

          Text(
            'No receivables data available.',
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: context.sp(14),
            ),
          ),
        ],
      ),
    );
  }
}
