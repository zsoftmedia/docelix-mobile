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
          "Invoices",
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
                // Loading
                if (invoicesController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Empty
                if (invoicesController.invoices.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: invoicesController.refreshInvoices,
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
                  onRefresh: invoicesController.refreshInvoices,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: height * 0.005,
                      bottom: height * 0.12,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: invoicesController.invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoicesController.invoices[index];

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

                            // Thin divider — no card border
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE9EDF3),
                              indent: 0,
                              endIndent: 0,
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

          Get.toNamed(
            '/CreateInvoicesScreen',
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
    required InvoicesModel invoice,
    required double width,
    required double height,
  }) {
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

  /*Widget _invoiceCard({
    required BuildContext context,
    required InvoicesModel invoice,
    required double width,
    required double height,
  })
  {

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
                      invoice.invoiceNumber ?? 'Unknown Client',
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
                    invoice.issueDate ?? 'N/A',
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
                '${invoice.currencyCode ?? ''} ${invoice.paidAmount ?? 0}',
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
  }*/

}