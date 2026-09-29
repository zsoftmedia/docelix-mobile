import 'package:docelix_mobileapp/controllers/invoices_controller.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {

  final InvoicesController invoicesController = Get.put(InvoicesController());

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: Obx(() {
          final bool searching =
              invoicesController.isSearching.value;

          return IconButton(
            onPressed: () {
              if (searching) {
                invoicesController.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching
                  ? Icons.close_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0A2342),
              size: width * 0.05,
            ),
          );
        }),

        title: Obx(() {
          if (invoicesController.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: invoicesController.searchInvoices,
              style: TextStyle(
                color: const Color(0xFF172A46),
                fontSize: width * 0.04,
              ),
              decoration: const InputDecoration(
                hintText: 'Search invoices...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            "Invoices",
            style: TextStyle(
              color: const Color(0xFF0A2342),
              fontSize: width * 0.055,
              fontWeight: FontWeight.w700,
            ),
          );
        }),

        centerTitle: false,

        actions: [
          Obx(() {
            if (invoicesController.isSearching.value) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: invoicesController.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF0A2342),
                size: width * 0.065,
              ),
            );
          }),

          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: Column(
          children: [

            // --------------------------------------------------------
            // HEADER
            // --------------------------------------------------------

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "All Invoices",
                    style: TextStyle(
                      color: const Color(0xFF172A46),
                      fontSize: width * 0.045,
                    //  fontWeight: FontWeight.w700,
                    ),
                  ),

                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                        vertical: height * 0.008,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FB),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child:Obx((){
                        return Text(
                          "${invoicesController.invoices.length} Invoices",
                          style: TextStyle(
                            color: const Color(0xFF063C70),
                            fontSize: width * 0.032,
                          //  fontWeight: FontWeight.w600,
                          ),
                        );})
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // INVOICE LIST
            // --------------------------------------------------------

            Expanded(
              child: Obx(() {
                // ==========================================================
                // LOADING
                // ==========================================================

                if (invoicesController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // ==========================================================
                // NO SEARCH RESULTS / NO INVOICES
                // ==========================================================

                if (invoicesController.filteredInvoices.isEmpty) {
                  final bool hasSearch =
                      invoicesController.searchQuery.value
                          .trim()
                          .isNotEmpty;

                  return RefreshIndicator(
                    onRefresh: invoicesController.refreshInvoices,
                    child: ListView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 150),

                        Center(
                          child: Text(
                            hasSearch
                                ? 'No invoices found.'
                                : 'No invoices found.',
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ==========================================================
                // INVOICE LIST
                // ==========================================================

                return RefreshIndicator(
                  onRefresh: invoicesController.refreshInvoices,

                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: height * 0.005,
                      bottom: height * 0.12,
                    ),

                    physics:
                    const AlwaysScrollableScrollPhysics(),

                    itemCount:
                    invoicesController.filteredInvoices.length,

                    itemBuilder: (context, index) {
                      final InvoicesModel invoice =
                      invoicesController.filteredInvoices[index];

                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            '/InvoicesDetailsScreen',
                            arguments: invoice,
                          );
                        },

                        child: Column(
                          children: [
                            _invoiceCard(
                              context: context,
                              invoice: invoice,
                              width: width,
                              height: height,
                            ),

                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE9EDF3),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      // ============================================================
      // ADD INVOICE BUTTON
      // ============================================================

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          // ----------------------------------------------------------
          // OPEN ADD INVOICE PAGE
          // ----------------------------------------------------------

          /*Get.toNamed(
            '/VoiceRecognitionScreen',
            arguments: 'Voice Recognition Invoices Screen',);*/
          Get.toNamed(
            '/CreateInvoiceScreen',
            arguments: 'Create Invoices Screen',);

          // Get.to(
          //   () => const AddInvoiceScreen(),
          // );

          // Temporary action
          /*Get.snackbar(
            "Add Invoice",
            "Add Invoice page will open here.",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
            backgroundColor: const Color(0xFF063C70),
            colorText: Colors.white,
          );*/
        },

        backgroundColor: const Color(0xFF063C70),
        foregroundColor: Colors.white,

        elevation: 4,

        icon: const Icon(
          Icons.add_rounded,
        ),

        label: Text(
          "Add Invoice",
          style: TextStyle(
            fontSize: width * 0.038,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // INVOICE CARD
  // ================================================================

  Widget _invoiceCard({
    required BuildContext context,
    required InvoicesModel invoice,
    required double width,
    required double height,
  })
  {
    final String status = invoice.status.toLowerCase();

    Color statusColor;

    if (status == "paid") {
      statusColor = const Color(0xFF00B894);
    } else if (status == "pending" || status == "unpaid") {
      statusColor = const Color(0xFFF39C12);
    } else if (status == "overdue") {
      statusColor = Colors.red;
    } else {
      statusColor = const Color(0xFF71829A);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : "Unknown";

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.045,
        vertical: height * 0.018,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Invoice icon
          Container(
            width: width * 0.115,
            height: width * 0.115,
            decoration: BoxDecoration(
            //  color: const Color(0xFFEAF3FB),
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: const Color(0xFF063C70),
              size: width * 0.09,
            ),
          ),

          SizedBox(width: width * 0.035),

          // Invoice information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber ?? 'No Invoice Number',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF172A46),
                    fontSize: width * 0.04,
                   // fontWeight: FontWeight.w700, // Bold
                  ),
                ),

                SizedBox(height: height * 0.006),

                Text(
                  invoice.issueDate ?? 'N/A',
                  style: TextStyle(
                    color: const Color(0xFF71829A),
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: width * 0.02),

          // Right side: status + amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: width * 0.03,
                   // fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: height * 0.006),

              Text(
                '${invoice.currencyCode ?? ''} ${invoice.paidAmount ?? 0}',
                style: TextStyle(
                  color: const Color(0xFF172A46),
                  fontSize: width * 0.043,
                  //fontWeight: FontWeight.w800, // Bold amount
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}