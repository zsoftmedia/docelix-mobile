
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedTab = 0;

  final List<String> tabs = [
    "Overview",
    "Analytics",
    "Transactions",
  ];

  // ================================================================
  // LIGHT THEME COLORS
  // ================================================================

  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color cardColor = Colors.white;

  static const Color primaryText = Color(0xFF0A2342);
  static const Color secondaryText = Color(0xFF71829A);
  static const Color lightText = Color(0xFF52657D);

  static const Color borderColor = Color(0xFFE1E7EF);
  static const Color progressBackground = Color(0xFFE9EEF4);

  static const Color primaryBlue = Color(0xFF0B4380);
  static const Color lightBlue = Color(0xFFEAF3FB);

  static const Color green = Color(0xFF12B886);
  static const Color red = Color(0xFFE5484D);
  static const Color blue = Color(0xFF4E9FFF);
  static const Color cyan = Color(0xFF25BEEB);
  static const Color purple = Color(0xFF9B5DE5);
  static const Color orange = Color(0xFFFFB52E);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04,
            vertical: height * 0.012,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================================================
              // TOP HEADER
              // =========================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "SEP 2026  ·  FINANCIAL",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: width * 0.027,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),

                        SizedBox(height: height * 0.003),

                        Text(
                          "Overview",
                          style: TextStyle(
                            color: primaryText,
                            fontSize: width * 0.065,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.018),

              // =========================================================
              // NET PROFIT MAIN CARD
              // =========================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.055),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
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

                    // Decorative circle
                    Positioned(
                      right: -width * 0.08,
                      top: -width * 0.12,
                      child: Container(
                        width: width * 0.34,
                        height: width * 0.34,
                        decoration: const BoxDecoration(
                          color: lightBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "NET PROFIT - SEP 2026",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: width * 0.027,
                            letterSpacing: 1.2,
                          ),
                        ),

                        SizedBox(height: height * 0.008),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Text(
                              "\$59,600",
                              style: TextStyle(
                                color: primaryText,
                                fontSize: width * 0.085,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(width: width * 0.025),

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
                                "+44.4%",
                                style: TextStyle(
                                  color: green,
                                  fontSize: width * 0.028,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.003),

                        Text(
                          "44.4% profit margin · best quarter on record",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: width * 0.028,
                          ),
                        ),

                        SizedBox(height: height * 0.025),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              "Rev  \$134.2k",
                              style: TextStyle(
                                color: green,
                                fontSize: width * 0.029,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              "Exp  \$74.6k",
                              style: TextStyle(
                                color: red,
                                fontSize: width * 0.029,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.008),

                        Stack(
                          children: [

                            Container(
                              height: 5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: progressBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            FractionallySizedBox(
                              widthFactor: 0.60,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: cyan,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.018),

              // =========================================================
              // TABS
              // =========================================================

              SizedBox(
                height: height * 0.045,
                child: Row(
                  children: List.generate(
                    tabs.length,
                        (index) {
                      final isSelected = selectedTab == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = index;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: width * 0.02,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.045,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : secondaryText,
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
              ),

              SizedBox(height: height * 0.018),

              // =========================================================
              // REVENUE / EXPENSES
              // =========================================================

              Row(
                children: [

                  Expanded(
                    child: _financialCard(
                      width: width,
                      height: height,
                      title: "REVENUE",
                      value: "\$134,200",
                      percentage: "+23.2%",
                      subtitle: "vs last month",
                      icon: Icons.attach_money_rounded,
                      iconColor: green,
                    ),
                  ),

                  SizedBox(width: width * 0.025),

                  Expanded(
                    child: _financialCard(
                      width: width,
                      height: height,
                      title: "EXPENSES",
                      value: "\$74,600",
                      percentage: "+4.8%",
                      subtitle: "vs last month",
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: red,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.02),

              // =========================================================
              // NET PROFIT / CASH BALANCE
              // =========================================================

              Row(
                children: [

                  Expanded(
                    child: _financialCard(
                      width: width,
                      height: height,
                      title: "NET PROFIT",
                      value: "\$59,600",
                      percentage: "+44.4%",
                      subtitle: "44.4% margin",
                      icon: Icons.trending_up_rounded,
                      iconColor: blue,
                    ),
                  ),

                  SizedBox(width: width * 0.025),

                  Expanded(
                    child: _financialCard(
                      width: width,
                      height: height,
                      title: "CASH BALANCE",
                      value: "\$335,000",
                      percentage: "+21.6%",
                      subtitle: "all accounts",
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: orange,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.02),

              // =========================================================
              // TAX RETURN
              // =========================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.045),
                decoration: BoxDecoration(
                  color: cardColor,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: purple,
                            size: width * 0.055,
                          ),
                        ),

                        SizedBox(width: width * 0.035),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                "TAX RETURN",
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: width * 0.026,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              SizedBox(height: height * 0.004),

                              Text(
                                "\$14,320",
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: width * 0.055,
                                  fontWeight: FontWeight.w800,
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "FY 2025",
                                style: TextStyle(
                                  color: purple,
                                  fontSize: width * 0.027,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            SizedBox(height: height * 0.008),

                            Text(
                              "refund pending",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: width * 0.024,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.02),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          "Filing status",
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: width * 0.026,
                          ),
                        ),

                        Text(
                          "72% processed",
                          style: TextStyle(
                            color: purple,
                            fontSize: width * 0.027,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.008),

                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: progressBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.72,
                        child: Container(
                          decoration: BoxDecoration(
                            color: purple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // =========================================================
              // MONTH SUMMARY
              // =========================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.045),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor,
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
                        color: secondaryText,
                        fontSize: width * 0.026,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: height * 0.018),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          "Gross Revenue",
                          style: TextStyle(
                            color: lightText,
                            fontSize: width * 0.029,
                          ),
                        ),

                        Text(
                          "\$134,200",
                          style: TextStyle(
                            color: primaryText,
                            fontSize: width * 0.030,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.01),

                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: progressBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.95,
                        child: Container(
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
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
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
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
                  color: secondaryText,
                  fontSize: width * 0.024,
                  letterSpacing: 0.8,
                ),
              ),

              Container(
                width: width * 0.075,
                height: width * 0.075,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: width * 0.042,
                ),
              ),
            ],
          ),

          SizedBox(height: height * 0.012),

          Text(
            value,
            style: TextStyle(
              color: primaryText,
              fontSize: width * 0.043,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: height * 0.005),

          Row(
            children: [

              Text(
                percentage,
                style: TextStyle(
                  color: iconColor,
                  fontSize: width * 0.025,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(width: width * 0.012),

              Expanded(
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryText,
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
}