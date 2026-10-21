import 'package:docelix_mobileapp/controllers/vehicles_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double _designWidth(BuildContext context) {
  final rs = context.rs;
  return rs.isPhone ? rs.width : ResponsiveBreakpoints.designWidth * rs.scale;
}

class FleetDashboardScreen extends StatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  State<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends State<FleetDashboardScreen> {
  late final VehiclesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VehiclesController>()
        ? Get.find<VehiclesController>()
        : Get.put(VehiclesController());
    controller.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Text(
          'Fleet Dashboard',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width.fontSizeW(0.045),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoadingDashboard.value &&
            controller.dashboard.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dashboard.value ?? const VehicleDashboard();

        return RefreshIndicator(
          onRefresh: controller.loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResponsivePage(
                padding: EdgeInsets.fromLTRB(
                  context.rs.pagePaddingH,
                  width * 0.04,
                  context.rs.pagePaddingH,
                  width * 0.08,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = context.rs.kpiColumns.clamp(2, 4);
                        final gap = width * 0.03;
                        final itemWidth =
                            (constraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        // Tall enough for icon + title + value + subtitle on
                        // small phones; still scales with tile width.
                        final itemHeight = (itemWidth / 1.15).clamp(
                          width * 0.36,
                          width * 0.48,
                        );
                        final cards = <Widget>[
                          _KpiCard(
                            title: 'Total Vehicles',
                            value: '${data.totalVehicles}',
                            subtitle: '${data.activeVehicles} active',
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xFF3B82F6),
                          ),
                          _KpiCard(
                            title: 'Total Mileage',
                            value: controller.formatKm(data.totalMileage),
                            subtitle: ' ',
                            icon: Icons.speed_rounded,
                            iconColor: const Color(0xFF12B886),
                          ),
                          _KpiCard(
                            title: 'Fleet Value',
                            value: controller.formatMoney(data.totalFleetValue),
                            subtitle: ' ',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: const Color(0xFFF59E0B),
                          ),
                          _KpiCard(
                            title: 'Total Expenses',
                            value: controller.formatMoney(data.totalExpenses),
                            subtitle: ' ',
                            icon: Icons.show_chart_rounded,
                            iconColor: const Color(0xFFEF4444),
                          ),
                        ];
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final card in cards)
                              SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: card,
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: width * 0.04),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expense Breakdown',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width.fontSizeW(0.038),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: width * 0.035),
                          _ExpenseRow(
                            label: 'Fuel Costs',
                            value: controller.formatMoney(data.totalFuelCost),
                          ),
                          Divider(
                            height: width * 0.06,
                            color: colorsList.borderColor,
                          ),
                          _ExpenseRow(
                            label: 'Maintenance & Services',
                            value: controller.formatMoney(
                              data.totalServiceCost,
                            ),
                          ),
                          Divider(
                            height: width * 0.06,
                            color: colorsList.borderColor,
                          ),
                          _ExpenseRow(
                            label: 'Insurance Policies',
                            value: controller.formatMoney(
                              data.totalInsuranceCost,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);
    final pad = width * 0.03;
    final iconSize = width * 0.08;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad * 0.9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: iconSize * 0.5),
          ),
          const Spacer(flex: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width.fontSizeW(0.027),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          SizedBox(height: width * 0.008),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width.fontSizeW(0.04),
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
          SizedBox(height: width * 0.005),
          // Reserve one subtitle line on every card for equal layout.
          Text(
            hasSubtitle ? subtitle! : ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: hasSubtitle
                  ? colorsList.mutedTextColor
                  : Colors.transparent,
              fontSize: width.fontSizeW(0.024),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorsList.secondaryText,
              fontSize: width.fontSizeW(0.032),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(width: width * 0.03),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width.fontSizeW(0.033),
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
