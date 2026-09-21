import 'package:docelix_mobileapp/controllers/incoming_invoices_details_controller.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class IncomingInvoicesDetailsScreen extends StatefulWidget {
  final IncomingInvoicesModel invoice;
  // const InvoicesDetailsScreen({super.key});

  const IncomingInvoicesDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<IncomingInvoicesDetailsScreen> createState() =>
      _InvoicesDetailsScreenState();
}

class _InvoicesDetailsScreenState extends State<IncomingInvoicesDetailsScreen> {

  late IncomingInvoicesDetailsController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      IncomingInvoicesDetailsController(),
    );

    controller.initialize(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0A2342),
            size: 20,
          ),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incoming Invoice Details',
              style: TextStyle(
                color: const Color(0xFF0A2342),
                fontSize: width * 0.045,
                fontWeight: FontWeight.w700,
              ),
            ),

            Text(
              '#${controller.invoiceNumberController.text}',
              style: TextStyle(
                color: const Color(0xFF71829A),
                fontSize: width * 0.030,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF0A2342),
            ),
          ),
        ],
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.fromLTRB(
                  width * 0.045,
                  height * 0.02,
                  width * 0.045,
                  height * 0.12,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // STATUS + AMOUNT CARD
                    // ------------------------------------------------

                    Obx(
                          () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.03,
                          vertical: height * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: controller.statusColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: controller.statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),

                            SizedBox(
                              width: width * 0.015,
                            ),

                            Text(
                              controller.displayStatus,
                              style: TextStyle(
                                color: controller.statusColor,
                                fontSize: width * 0.032,
                                //fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * 0.022,
                    ),

                    // ------------------------------------------------
                    // INVOICE DETAILS
                    // ------------------------------------------------

                    _sectionTitle(
                      'Invoice Details',
                      width,
                    ),

                    SizedBox(
                      height: height * 0.012,
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        width * 0.045,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          width * 0.04,
                        ),
                        border: Border.all(
                          color: const Color(0xFFE4EAF1),
                        ),
                      ),

                      child: Column(
                        children: [
                          _invoiceTextField(
                            label: 'Invoice Number',
                            controller: controller.invoiceNumberController,
                            icon: Icons.numbers_rounded,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Invoice Date',
                            controller: controller.dateController,
                            icon: Icons.calendar_today_outlined,
                            onTap: controller.selectInvoiceDate,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Currency',
                            controller: controller.currencyController,
                            icon: Icons.currency_exchange_rounded,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Total Amount',
                            controller: controller.totalController,
                            icon: Icons.payments_outlined,
                            width: width,
                            keyboardType: TextInputType.number,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'VAT %',
                            controller: controller.vatController,
                            icon: Icons.percent_rounded,
                            width: width,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: height * 0.022,
                    ),

                    // ------------------------------------------------
                    // SUPPLIER
                    // ------------------------------------------------

                    _sectionTitle(
                      'Supplier',
                      width,
                    ),

                    SizedBox(
                      height: height * 0.012,
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        width * 0.045,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          width * 0.04,
                        ),
                        border: Border.all(
                          color: const Color(0xFFE4EAF1),
                        ),
                      ),

                      child: Column(
                        children: [
                          _invoiceTextField(
                            label: 'Supplier',
                            controller: controller.supplierController,
                            icon: Icons.business_outlined,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Supplier Email',
                            controller: controller.supplierEmailController,
                            icon: Icons.email_outlined,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Supplier Phone',
                            controller: controller.supplierPhoneController,
                            icon: Icons.phone_outlined,
                            width: width,
                          ),

                          SizedBox(height: height * 0.018),

                          _invoiceTextField(
                            label: 'Supplier Address',
                            controller: controller.supplierAddressController,
                            icon: Icons.location_on_outlined,
                            width: width,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: height * 0.022,
                    ),

                    // ------------------------------------------------
                    // CATEGORY
                    // ------------------------------------------------

                    _sectionTitle(
                      'Payment & Category',
                      width,
                    ),

                    SizedBox(
                      height: height * 0.012,
                    ),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        width * 0.045,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          width * 0.04,
                        ),
                        border: Border.all(
                          color: const Color(0xFFE4EAF1),
                        ),
                      ),

                      child: Obx(
                            () => Row(
                          children: [
                            Expanded(
                              child: _smallInfo(
                                'Payment Status',
                                controller.displayStatus,
                                Icons.payments_outlined,
                                width,
                              ),
                            ),

                            Container(
                              height: width * 0.12,
                              width: 1,
                              color: const Color(0xFFE5EAF0),
                            ),

                            Expanded(
                              child: _smallInfo(
                                'Category',
                                controller.displayCategory,
                                Icons.category_outlined,
                                width,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),

                    SizedBox(
                      height: height * 0.022,
                    ),

                    // ------------------------------------------------
                    // DOCUMENT
                    // ------------------------------------------------

                    _sectionTitle(
                      'Invoice Document',
                      width,
                    ),

                    SizedBox(
                      height: height * 0.012,
                    ),

                    GestureDetector(
                      onTap: () {
                        // Open full document

                        final previewUrl = controller.invoice.previewUrl;

                        if (previewUrl == null || previewUrl.isEmpty) {
                          Get.snackbar(
                            'Document',
                            'Document preview is not available.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        showInvoiceDocumentDialog(
                          context: context,
                          fileUrl: previewUrl,
                          fileType: controller.invoice.fileType,
                          mimeType: controller.invoice.mimeType,
                        );
                      },

                      child: Container(
                        width: double.infinity,
                        height: height * 0.24,

                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3F7),
                          borderRadius:
                          BorderRadius.circular(
                            width * 0.04,
                          ),

                          border: Border.all(
                            color: const Color(0xFFE0E6ED),
                          ),
                        ),

                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.picture_as_pdf_rounded,
                                color: const Color(0xFFD64545),
                                size: width * 0.15,
                              ),
                            ),

                            Positioned(
                              bottom: width * 0.035,
                              left: width * 0.04,
                              right: width * 0.04,

                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                                children: [
                                  Text(
                                    'Invoice Document',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF0A2342,
                                      ),
                                      fontSize:
                                      width * 0.034,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  Container(
                                    padding:
                                    EdgeInsets.symmetric(
                                      horizontal:
                                      width * 0.025,
                                      vertical:
                                      height * 0.006,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                    child: Text(
                                      'View',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF063C70,
                                        ),
                                        fontSize:
                                        width * 0.03,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --------------------------------------------------------
                    // SAVE CHANGES BUTTON
                    // --------------------------------------------------------

                    SizedBox(
                      height: height * 0.025,
                    ),

                    Center(
                      child: SizedBox(
                        width: width * 0.55,
                        height: height * 0.058,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Save functionality will be implemented later.
                          },

                          icon: Icon(
                            Icons.save_outlined,
                            size: width * 0.05,
                          ),

                          label: Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF063C70),
                            foregroundColor: Colors.white,
                            elevation: 2,

                            shadowColor: const Color(0xFF063C70)
                                .withOpacity(0.25),

                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                width * 0.035,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * 0.025,
                    ),

                  ],
                ),
              ),
            ),

            // --------------------------------------------------------
            // BOTTOM ACTIONS
            // --------------------------------------------------------

            Container(
              padding: EdgeInsets.fromLTRB(
                width * 0.04,
                height * 0.015,
                width * 0.04,
                height * 0.02,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => OutlinedButton.icon(
                        onPressed: controller.isDeleting.value
                            ? null
                            : controller.deleteInvoice,
                        icon: controller.isDeleting.value
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFD64545),
                          ),
                        )
                            : const Icon(
                          Icons.delete_outline_rounded,
                        ),
                        label: Text(
                          controller.isDeleting.value
                              ? 'Deleting...'
                              : 'Delete',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD64545),
                          disabledForegroundColor:
                          const Color(0xFFD64545),
                          side: const BorderSide(
                            color: Color(0xFFD64545),
                          ),
                          minimumSize: Size(
                            0,
                            height * 0.055,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: width * 0.03,
                  ),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                      ),
                      label: const Text('Mark Paid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF12A150),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(
                          0,
                          height * 0.055,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle(
      String title,
      double width,
      )
  {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF0A2342),
        fontSize: width * 0.038,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ================================================================
  // SMALL INFO
  // ================================================================

  Widget _smallInfo(
      String title,
      String value,
      IconData icon,
      double width,
      )
  {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF063C70),
            size: width * 0.055,
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF71829A),
              fontSize: width * 0.027,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF0A2342),
              fontSize: width * 0.031,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required double width,
    bool readOnly = true,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  })
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF60728D),
            fontSize: width * 0.030,
           // fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(
          height: width * 0.018,
        ),

        TextFormField(
          controller: controller,
          onTap: onTap,
          keyboardType: keyboardType,

          style: TextStyle(
            color: const Color(0xFF0A2342),
            fontSize: width * 0.034,
           // fontWeight: FontWeight.w600,
          ),

          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF71829A),
              size: width * 0.050,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFC),

            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.035,
              vertical: width * 0.035,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                width * 0.03,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFE1E7EF),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                width * 0.03,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFE1E7EF),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                width * 0.03,
              ),
              borderSide: const BorderSide(
                color: Color(0xFF063C70),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void showInvoiceDocumentDialog({
  required BuildContext context,
  required String fileUrl,
  required String fileType,
  required String mimeType,
})
{

  final Size screenSize = MediaQuery.of(context).size;

  final double width = screenSize.width;
  final double height = screenSize.height;

  final bool isPdf =
      fileType.toLowerCase() == 'pdf' ||
          mimeType.toLowerCase() == 'application/pdf';

  final bool isImage =
      mimeType.toLowerCase().startsWith('image/') ||
          [
            'jpg',
            'jpeg',
            'png',
            'webp',
          ].contains(fileType.toLowerCase());

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.70),

    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.06,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        child: SizedBox(
          height: height * 0.82,
          child: Column(
            children: [

              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.018,
                ),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5EAF0),
                    ),
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      width: width * 0.10,
                      height: width * 0.10,

                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4F9),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),

                      child: Icon(
                        isPdf
                            ? Icons.picture_as_pdf_rounded
                            : Icons.image_outlined,
                        color: isPdf
                            ? const Color(0xFFD64545)
                            : const Color(0xFF063C70),
                        size: width * 0.055,
                      ),
                    ),

                    SizedBox(
                      width: width * 0.03,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice Document',
                            style: TextStyle(
                              color:
                              const Color(0xFF0A2342),
                              fontSize: width * 0.040,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(
                            height: height * 0.004,
                          ),

                          Text(
                            isPdf
                                ? 'PDF Document'
                                : 'Image Document',
                            style: TextStyle(
                              color:
                              const Color(0xFF71829A),
                              fontSize: width * 0.028,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------
                    // CLOSE BUTTON
                    // ------------------------------------------------

                    Material(
                      color: const Color(0xFFF3F5F8),
                      shape: const CircleBorder(),

                      child: InkWell(
                        customBorder:
                        const CircleBorder(),

                        onTap: () {
                          Navigator.of(context).pop();
                        },

                        child: Padding(
                          padding: EdgeInsets.all(
                            width * 0.022,
                          ),

                          child: Icon(
                            Icons.close_rounded,
                            color:
                            const Color(0xFF52657A),
                            size: width * 0.055,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // DOCUMENT CONTENT
              // ------------------------------------------------

              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F7FA),

                  child: _buildDocumentPreview(
                    fileUrl: fileUrl,
                    isPdf: isPdf,
                    isImage: isImage,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDocumentPreview({
  required String fileUrl,
  required bool isPdf,
  required bool isImage,
})
{
  if (isPdf) {
    return SfPdfViewer.network(
      fileUrl,
    );
  }

  if (isImage) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,

      child: Center(
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,

          loadingBuilder: (
              context,
              child,
              loadingProgress,
              ) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF063C70),
              ),
            );
          },

          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 50,
                  color: Color(0xFF9AA6B2),
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to load document.',
                  style: TextStyle(
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  return const Center(
    child: Text(
      'Unsupported document format.',
      style: TextStyle(
        color: Color(0xFF667085),
      ),
    ),
  );
}