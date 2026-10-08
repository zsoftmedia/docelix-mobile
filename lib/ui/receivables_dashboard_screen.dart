import 'package:docelix_mobileapp/controllers/receivables_dashboard_controller.dart';
import 'package:docelix_mobileapp/models/receivables_dashboard_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceivablesDashboardScreen extends StatelessWidget {
  ReceivablesDashboardScreen({super.key});

  final ReceivablesDashboardController
  dashboardController =
  Get.put(
    ReceivablesDashboardController(),
  );

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: colorsList.textColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),

        title: const Text(
          'Receivables',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: 20,
           // fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          Obx(
                () => IconButton(
              onPressed:
              dashboardController.isLoading.value
                  ? null
                  : dashboardController
                  .getReceivablesDashboard,
              icon: const Icon(
                Icons.refresh_rounded,
                color: colorsList.iconColor,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Obx(
            () {
          if (dashboardController
              .isLoading
              .value) {
            return const Center(
              child: CircularProgressIndicator(
                color: colorsList.textColor,
              ),
            );
          }

          final data =
              dashboardController
                  .receivablesDashboard
                  .value;

          return RefreshIndicator(
            color: colorsList.textColor,

            onRefresh:
            dashboardController
                .getReceivablesDashboard,

            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // DATE FILTER
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                              () => _headerDropdown(
                            width: width,
                            icon: Icons
                                .calendar_today_outlined,
                            text:
                            "From: ${dashboardController.fromDateText.value}",
                            onTap:
                            dashboardController
                                .selectFromDate,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: width * 0.025,
                      ),

                      Expanded(
                        child: Obx(
                              () => _headerDropdown(
                            width: width,
                            icon: Icons
                                .calendar_today_outlined,
                            text:
                            "To: ${dashboardController.toDateText.value}",
                            onTap:
                            dashboardController
                                .selectToDate,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // NO DATA
                  // ==================================================

                  if (data == null)
                    _emptyState()
                  else ...[
                    // ==============================================
                    // KPI SECTION
                    // ==============================================

                    _sectionTitle(
                      'Receivables Overview',
                    ),

                    const SizedBox(height: 12),

                    _buildKpiGrid(
                      data,
                      width,
                    ),

                    const SizedBox(height: 24),

                    // ==============================================
                    // AGING
                    // ==============================================

                    _sectionTitle(
                      'Receivables Aging',
                    ),

                    const SizedBox(height: 12),

                    _buildAging(data),

                    const SizedBox(height: 24),

                    // ==============================================
                    // ATTENTION INVOICES
                    // ==============================================

                    _sectionTitle(
                      'Invoices Requiring Attention',
                    ),

                    const SizedBox(height: 12),

                    _buildAttentionInvoices(
                      data,
                    ),

                    const SizedBox(height: 24),

                    // ==============================================
                    // COLLECTION PERFORMANCE
                    // ==============================================

                    _sectionTitle(
                      'Collection Performance',
                    ),

                    const SizedBox(height: 12),

                    _buildCollectionPerformance(
                      data,
                    ),

                    const SizedBox(height: 24),

                    // ==============================================
                    // COLLECTION RISK
                    // ==============================================

                    _sectionTitle(
                      'Collection Risk',
                    ),

                    const SizedBox(height: 12),

                    _buildCollectionRisk(data),

                    const SizedBox(height: 24),

                    // ==============================================
                    // RECONCILIATION
                    // ==============================================

                    _sectionTitle(
                      'Reconciliation',
                    ),

                    const SizedBox(height: 12),

                    _buildReconciliation(data),

                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER DATE DROPDOWN
  // ============================================================

  Widget _headerDropdown({
    required double width,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(10),

      child: Container(
        height: 48,

        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(10),

          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: colorsList.iconColor,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                text,

                maxLines: 1,

                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  color: colorsList.textColor,
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              size: 20,
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

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        color: colorsList.textColor,
        fontSize: 17,
       // fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // KPI GRID
  // ============================================================

  Widget _buildKpiGrid(
      ReceivablesDashboardModel data,
      double width,
      ) {
    final kpis = data.kpis;

    if (kpis == null) {
      return const SizedBox();
    }

    final double cardWidth =
        (width - 44) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,

      children: [
        SizedBox(
          width: cardWidth,
          child: _kpiCard(
            title: 'Total Receivables',
            amount:
            kpis.totalReceivables.amount,
            count:
            kpis.totalReceivables.count,
            icon:
            Icons.account_balance_wallet_outlined,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _kpiCard(
            title: 'Overdue',
            amount:
            kpis.overdueReceivables.amount,
            count:
            kpis.overdueReceivables.count,
            icon:
            Icons.warning_amber_rounded,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _kpiCard(
            title: 'Not Due',
            amount:
            kpis.notDueReceivables.amount,
            count:
            kpis.notDueReceivables.count,
            icon:
            Icons.schedule_rounded,
          ),
        ),

        SizedBox(
          width: cardWidth,
          child: _kpiCard(
            title: 'Customers Past Due',
            amount:
            kpis.customersPastDue.amount,
            count:
            kpis.customersPastDue.count,
            icon:
            Icons.people_outline_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // KPI CARD
  // ============================================================

  Widget _kpiCard({
    required String title,
    required double amount,
    required int count,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: colorsList.borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: colorsList.textHintColor,
                    fontSize: 12,
                  ),
                ),
              ),

              Icon(
                icon,
                size: 21,
                color: colorsList.iconColor,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            dashboardController
                .formatAmount(amount),

            maxLines: 1,

            overflow:
            TextOverflow.ellipsis,

            style: const TextStyle(
              color: colorsList.textColor,
              fontSize: 18,
             // fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$count invoice${count == 1 ? '' : 's'}',

            style: const TextStyle(
              color: colorsList.textHintColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AGING
  // ============================================================

  Widget _buildAging(
      ReceivablesDashboardModel data,
      ) {
    final aging = data.aging;

    if (aging == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      child: Column(
        children: [
          _agingRow(
            'Not Due',
            aging.notDue,
          ),

          _divider(),

          _agingRow(
            '1 - 30 Days',
            aging.days1to30,
          ),

          _divider(),

          _agingRow(
            '31 - 60 Days',
            aging.days31to60,
          ),

          _divider(),

          _agingRow(
            '61 - 90 Days',
            aging.days61to90,
          ),

          _divider(),

          _agingRow(
            '90+ Days',
            aging.days90Plus,
          ),
        ],
      ),
    );
  }

  Widget _agingRow(
      String title,
      AgingItem item,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                color: colorsList.textColor,
                fontSize: 13,
              ),
            ),
          ),

          Text(
            dashboardController
                .formatAmount(
              item.amount,
            ),

            style: const TextStyle(
              color: colorsList.textColor,
              fontSize: 13,
             // fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 45,

            child: Text(
              '${item.percentage}%',

              textAlign: TextAlign.right,

              style: const TextStyle(
                color: colorsList.textHintColor,
                fontSize: 11,
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
      ReceivablesDashboardModel data,
      ) {
    if (data.attentionInvoices.isEmpty) {
      return _emptyBox(
        'No invoices require attention.',
      );
    }

    return Column(
      children: data.attentionInvoices
          .map(
            (invoice) => Container(
          width: double.infinity,

          margin:
          const EdgeInsets.only(
            bottom: 10,
          ),

          padding:
          const EdgeInsets.all(14),

          decoration:
          BoxDecoration(
            color: colorsList.colorBoxDecoration,

            borderRadius:
            BorderRadius.circular(
              12,
            ),

            border: Border.all(
              color: colorsList.borderColor,
            ),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.customer,

                      style:
                      const TextStyle(
                        color: colorsList.textColor,
                        fontSize: 14,
                       // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    dashboardController
                        .formatAmount(
                      invoice.balance,
                    ),

                    style:
                    const TextStyle(
                      color: colorsList.textColor,
                      fontSize: 14,
                     // fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Text(
                invoice.invoiceNo,

                style:
                const TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _statusBadge(
                    invoice.status,
                  ),

                  const Spacer(),

                  Text(
                    '${invoice.daysOverdue} days overdue',

                    style:
                    const TextStyle(
                      color: colorsList.textHintColor,
                      fontSize: 11,
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
      ReceivablesDashboardModel data,
      ) {
    final performance =
        data.collectionPerformance;

    if (performance == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      child: Column(
        children: [
          _infoRow(
            'DSO',
            '${performance.dso.toStringAsFixed(0)} days',
          ),

          _divider(),

          _infoRow(
            'Average Days Overdue',
            performance.avgDaysOverdue == null
                ? 'N/A'
                : '${performance.avgDaysOverdue!.toStringAsFixed(0)} days',
          ),

          _divider(),

          _infoRow(
            'Overdue Share',
            '${performance.overdueShare.toStringAsFixed(1)}%',
          ),

          _divider(),

          _infoRow(
            'Period Sales',
            dashboardController
                .formatAmount(
              performance.periodSales,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLLECTION RISK
  // ============================================================

  Widget _buildCollectionRisk(
      ReceivablesDashboardModel data,
      ) {
    final risk =
        data.collectionRisk;

    if (risk == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 22,
                color: colorsList.iconColor,
              ),

              const SizedBox(width: 10),

              const Text(
                'Risk Level',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              _riskBadge(
                risk.level,
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...risk.reasons.map(
                (reason) => Padding(
              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),

              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Icon(
                    reason.tone ==
                        'positive'
                        ? Icons
                        .check_circle_outline
                        : Icons
                        .info_outline,

                    size: 18,

                    color: colorsList.iconColor,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      reason.text,

                      style:
                      const TextStyle(
                        color: colorsList.textColor,
                        fontSize: 13,
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
      ReceivablesDashboardModel data,
      ) {
    final reconciliation =
        data.reconciliation;

    if (reconciliation == null) {
      return const SizedBox();
    }

    return _sectionContainer(
      child: Column(
        children: [
          _infoRow(
            'Subledger',
            dashboardController
                .formatAmount(
              reconciliation.subledger,
            ),
          ),

          _divider(),

          _infoRow(
            'GL 1100',
            dashboardController
                .formatAmount(
              reconciliation.gl1100,
            ),
          ),

          _divider(),

          _infoRow(
            'Difference',
            dashboardController
                .formatAmount(
              reconciliation.difference,
            ),
          ),

          _divider(),

          _infoRow(
            'As Of',
            reconciliation.asOf,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CONTAINER
  // ============================================================

  Widget _sectionContainer({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colorsList.colorBoxDecoration,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: const Color(
            0xFFE8EDF3,
          ),
        ),
      ),

      child: child,
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
      String title,
      String value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,

            style: const TextStyle(
              color: colorsList.textHintColor,
              fontSize: 13,
            ),
          ),
        ),

        Text(
          value,

          style: const TextStyle(
            color: colorsList.textColor,
            fontSize: 13,
            //fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
      String status,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: Color(0xFFE9EEF4),

        borderRadius:
        BorderRadius.circular(6),
      ),

      child: Text(
        status,

        style: const TextStyle(
          color: Color(0xFF063C70),
          fontSize: 10,
         // fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // RISK BADGE
  // ============================================================

  Widget _riskBadge(
      String level,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: const Color(
          0xFFE8F5E9,
        ),

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        level.toUpperCase(),

        style: const TextStyle(
          fontSize: 10,
         // fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return const Divider(
      height: 1,
      color: colorsList.dividerColor,
    );
  }

  // ============================================================
  // EMPTY BOX
  // ============================================================

  Widget _emptyBox(
      String message,
      ) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        border: Border.all(
          color: colorsList.colorBoxDecoration,
        ),

        borderRadius:
        BorderRadius.circular(12),
      ),

      child: Center(
        child: Text(
          message,

          style: const TextStyle(
            color: colorsList.textHintColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,

      margin:
      const EdgeInsets.only(
        top: 50,
      ),

      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 50,
            color: Colors.grey,
          ),

          SizedBox(height: 12),

          Text(
            'No receivables data available.',
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}