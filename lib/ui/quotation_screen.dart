import 'package:docelix_mobileapp/controllers/quotation_controller.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final QuotationController controller = Get.put(QuotationController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() {
          final bool searching = controller.isSearching.value;
          return IconButton(
            onPressed: () {
              if (searching) {
                controller.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: width * 0.05,
            ),
          );
        }),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: width * 0.04,
              ),
              decoration: const InputDecoration(
                hintText: 'Search quotation # or client...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Quotations',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) return const SizedBox.shrink();

            return Row(
              children: [
                IconButton(
                  onPressed: controller.openSearch,
                  icon: Icon(
                    Icons.search_rounded,
                    color: colorsList.iconColor,
                    size: width * 0.065,
                  ),
                ),
                /*IconButton(
                  onPressed: () async {
                    final result = await Get.toNamed('/CreateQuotationScreen');
                    if (result == true) {
                      controller.refreshQuotations();
                    }
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: colorsList.primaryBlue,
                    size: 24,
                  ),
                ),*/
              ],
            );
          }),
          SizedBox(width: width * 0.02),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/CreateQuotationScreen');
          if (result == true) {
            controller.refreshQuotations();
          }
        },
        backgroundColor: colorsList.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Offer',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER BAR
            // ======================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.045,
                vertical: height * 0.012,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Offers',
                    style: TextStyle(
                      color: colorsList.textColor,
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4EAF1)),
                      ),
                      child: Text(
                        '${controller.filteredQuotations.length} Offers',
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // QUOTATION LIST
            // ======================================================

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.filteredQuotations.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshQuotations,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: height * 0.15),
                        Center(
                          child: Text(
                            controller.searchQuery.value.isNotEmpty
                                ? 'No matching quotations found.'
                                : 'No quotations available.',
                            style: const TextStyle(
                              color: colorsList.textHintColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshQuotations,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.045,
                      right: width * 0.045,
                      bottom: height * 0.05,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredQuotations.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredQuotations[index];
                      return _buildQuotationCard(
                        item: item,
                        width: width,
                        height: height,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // QUOTATION CARD WIDGET
  // ================================================================

  Widget _buildQuotationCard({
    required QuotationModel item,
    required double width,
    required double height,
  }) {
    final String statusStr = item.status.toLowerCase().trim();
    Color statusColor;

    if (statusStr == 'accepted') {
      statusColor = const Color(0xFF12A150);
    } else if (statusStr == 'sent') {
      statusColor = colorsList.primaryBlue;
    } else if (statusStr == 'rejected') {
      statusColor = const Color(0xFFD64545);
    } else {
      statusColor = const Color(0xFF71829A);
    }

    final String displayStatus =
        statusStr.isNotEmpty ? statusStr[0].toUpperCase() + statusStr.substring(1) : 'Draft';

    final String dateStr = _formatDate(item.issueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              '/QuotationDetailsScreen',
              arguments: item,
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW: OFFER NUMBER & STATUS BADGE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width * 0.11,
                      height: width * 0.11,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.request_quote_outlined,
                        color: colorsList.iconColor,
                        size: width * 0.06,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.offerNumber.isNotEmpty ? item.offerNumber : 'OFFER',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.038,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF063C70),
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            item.clientName ?? 'Customer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: width * 0.030,
                              color: colorsList.textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: width * 0.027,
                          fontWeight: FontWeight.normal,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.012),
                const Divider(height: 1, color: Color(0xFFF0F4F8)),
                SizedBox(height: height * 0.010),

                // DETAILS ROW: DATE | VALID UNTIL | ACCEPTED
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardStat('Date', dateStr, width),
                    _cardStat('Valid Until', '—', width),
                    _cardStat('Accepted', '—', width),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardStat(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.025,
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.030,
            fontWeight: FontWeight.w500,
            color: colorsList.textColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}