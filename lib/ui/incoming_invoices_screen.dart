import 'package:docelix_mobileapp/controllers/incoming_invoices_controller.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomingInvoicesScreen extends StatefulWidget {
  const IncomingInvoicesScreen({super.key});

  @override
  State<IncomingInvoicesScreen> createState() => _IncomingInvoicesScreenState();
}

class _IncomingInvoicesScreenState extends State<IncomingInvoicesScreen> {

  final IncomingInvoicesController incomingInvoicesController = Get.put(IncomingInvoicesController());

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

        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF0A2342),
            size: width * 0.05,
          ),
        ),

        title: Text(
          "Incoming Invoices",
          style: TextStyle(
            color: const Color(0xFF0A2342),
            fontSize: width * 0.055,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,

        actions: [
          IconButton(
            onPressed: () {
              // Search action
            },
            icon: Icon(
              Icons.search_rounded,
              color: const Color(0xFF0A2342),
              size: width * 0.065,
            ),
          ),

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
                      fontWeight: FontWeight.w700,
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
                      "${incomingInvoicesController.invoices.length} Invoices",
                      style: TextStyle(
                        color: const Color(0xFF063C70),
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w600,
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
                // Loading
                if (incomingInvoicesController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Empty
                if (incomingInvoicesController.invoices.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: incomingInvoicesController.refreshInvoices,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(
                          child: Text(
                            'No invoices found.',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Invoice list
                return RefreshIndicator(
                  onRefresh: incomingInvoicesController.refreshInvoices,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.04,
                      right: width * 0.04,
                      bottom: height * 0.12,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: incomingInvoicesController.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice =
                      incomingInvoicesController.invoices[index];

                      // Invoice Card Clickable
                      return InkWell(
                        onTap: () {
                          print('Invoice ID: ${invoice.id}');
                          print('Invoice Number: ${invoice.invoiceNumber}');

                          // Navigate to details
                          Get.toNamed('/IncomingInvoicesDetailsScreen', arguments: invoice,);
                        },
                        child: _invoiceCard(
                          context: context,
                          invoice: invoice,
                          width: width,
                          height: height,
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

          Get.toNamed(
            '/CreateIncomingInvoicesScreen',
            arguments: 'Create Incoming Invoices Screen',);

          // Get.to(
          //   () => const AddInvoiceScreen(),
          // );

          // Temporary action
          Get.snackbar(
            "Add Invoice",
            "Add Invoice page will open here.",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(15),
            backgroundColor: const Color(0xFF063C70),
            colorText: Colors.white,
          );
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
    required IncomingInvoicesModel invoice,
    required double width,
    required double height,
  }) {

    // ----------------------------------------------------------
    // STATUS
    // ----------------------------------------------------------

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

    // Display status with first letter uppercase
    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : "Unknown";

    return Container(
      margin: EdgeInsets.only(
        bottom: height * 0.015,
      ),
      padding: EdgeInsets.all(
        width * 0.045,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          width * 0.045,
        ),
        border: Border.all(
          color: const Color(0xFFE1E7EF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ----------------------------------------------------------
          // TOP ROW
          // ----------------------------------------------------------

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Icon
              Container(
                width: width * 0.115,
                height: width * 0.115,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FB),
                  borderRadius: BorderRadius.circular(
                    width * 0.03,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: const Color(0xFF063C70),
                  size: width * 0.06,
                ),
              ),

              SizedBox(
                width: width * 0.035,
              ),

              // ----------------------------------------------------------
              // INVOICE INFORMATION
              // ----------------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber ?? 'No Invoice Number',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: width * 0.04,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(
                      height: height * 0.005,
                    ),

                    Text(
                      invoice.supplierName ?? 'Unknown Supplier',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF60728D),
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: width * 0.02,
              ),

              // ----------------------------------------------------------
              // STATUS
              // ----------------------------------------------------------

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: height * 0.006,
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: height * 0.018,
          ),

          const Divider(
            height: 1,
            color: Color(0xFFE9EDF3),
          ),

          SizedBox(
            height: height * 0.015,
          ),

          // ----------------------------------------------------------
          // BOTTOM ROW
          // ----------------------------------------------------------

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ----------------------------------------------------------
              // DATE
              // ----------------------------------------------------------

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: const Color(0xFF71829A),
                    size: width * 0.04,
                  ),

                  SizedBox(
                    width: width * 0.018,
                  ),

                  Text(
                    invoice.invoiceDate ?? 'N/A',
                    style: TextStyle(
                      color: const Color(0xFF71829A),
                      fontSize: width * 0.033,
                    ),
                  ),
                ],
              ),

              // ----------------------------------------------------------
              // AMOUNT
              // ----------------------------------------------------------

              Text(
                '${invoice.currency ?? ''} ${invoice.totalAmount ?? 0}',
                style: TextStyle(
                  color: const Color(0xFF0A2342),
                  fontSize: width * 0.043,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}