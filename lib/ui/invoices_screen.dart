import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {

  // ============================================================
  // DUMMY INVOICE DATA
  // ============================================================

  final List<Map<String, dynamic>> invoices = [
    {
      "invoiceNo": "INV-2026-001",
      "customer": "ABC Trading Company",
      "date": "08 Sep 2026",
      "amount": "€2,450.00",
      "status": "Paid",
    },
    {
      "invoiceNo": "INV-2026-002",
      "customer": "Global Solutions Ltd.",
      "date": "07 Sep 2026",
      "amount": "€1,850.00",
      "status": "Pending",
    },
    {
      "invoiceNo": "INV-2026-003",
      "customer": "Tech World GmbH",
      "date": "05 Sep 2026",
      "amount": "€3,200.00",
      "status": "Paid",
    },
    {
      "invoiceNo": "INV-2026-004",
      "customer": "Modern Business Ltd.",
      "date": "03 Sep 2026",
      "amount": "€980.00",
      "status": "Overdue",
    },
    {
      "invoiceNo": "INV-2026-005",
      "customer": "Smart Solutions",
      "date": "01 Sep 2026",
      "amount": "€1,250.00",
      "status": "Pending",
    },
    {
      "invoiceNo": "INV-2026-006",
      "customer": "Digital Services GmbH",
      "date": "30 Aug 2026",
      "amount": "€4,100.00",
      "status": "Paid",
    },
  ];

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

                    child: Text(
                      "${invoices.length} Invoices",
                      style: TextStyle(
                        color: const Color(0xFF063C70),
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // INVOICE LIST
            // --------------------------------------------------------

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: width * 0.04,
                  right: width * 0.04,

                  // Space for FloatingActionButton
                  bottom: height * 0.12,
                ),

                physics: const BouncingScrollPhysics(),

                itemCount: invoices.length,

                itemBuilder: (context, index) {

                  final invoice = invoices[index];

                  return _invoiceCard(
                    context: context,
                    invoice: invoice,
                    width: width,
                    height: height,
                  );
                },
              ),
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
            arguments: 'Create Invoices Screen',);

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
    required Map<String, dynamic> invoice,
    required double width,
    required double height,
  }) {

    final String status = invoice["status"];

    Color statusColor;

    if (status == "Paid") {
      statusColor = const Color(0xFF00B894);
    } else if (status == "Pending") {
      statusColor = const Color(0xFFF39C12);
    } else {
      statusColor = Colors.red;
    }

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

              // Invoice information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      invoice["invoiceNo"],
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
                      invoice["customer"],
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

              // Status
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
                  status,
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

              // Date
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
                    invoice["date"],
                    style: TextStyle(
                      color: const Color(0xFF71829A),
                      fontSize: width * 0.033,
                    ),
                  ),
                ],
              ),

              // Amount
              Text(
                invoice["amount"],
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