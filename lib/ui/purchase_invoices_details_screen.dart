import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/controllers/purchase_invoices_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PurchaseInvoicesDetailsScreen extends StatefulWidget {
  final PurchaseInvoicesModel invoice;

  const PurchaseInvoicesDetailsScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<PurchaseInvoicesDetailsScreen> createState() =>
      _InvoicesDetailsScreenState();
}

class _InvoicesDetailsScreenState extends State<PurchaseInvoicesDetailsScreen> {
  late PurchaseInvoicesDetailsController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      PurchaseInvoicesDetailsController(),
    );

    controller.initialize(widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final width = rs.isPhone
        ? rs.width
        : ResponsiveBreakpoints.designWidth * rs.scale;
    final height = rs.isPhone
        ? rs.height
        : ResponsiveBreakpoints.designHeight * rs.scale;

    final item = widget.invoice;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: rs.s(20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase Invoice Details',
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: rs.sp(18),
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '#${item.supplierInvoiceNumber ?? item.invoiceNumber ?? item.id}',
              style: TextStyle(
                color: colorsList.textHintColor,
                fontSize: rs.sp(12),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ResponsivePage(
                padding: EdgeInsets.fromLTRB(
                  rs.pagePaddingH,
                  rs.s(16),
                  rs.pagePaddingH,
                  rs.s(96),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // 1. TOP HEADER & STATUS BADGE CARD
                      // ------------------------------------------------
                      _buildHeaderCard(item, width),

                      SizedBox(height: height * 0.018),

                      // ------------------------------------------------
                      // 2. SUPPLIER & DOCUMENT INFO CARD
                      // ------------------------------------------------
                      _buildSupplierAndDocCard(item, width),

                      SizedBox(height: height * 0.018),

                      // ------------------------------------------------
                      // 3. TAX & TOTALS CARD
                      // ------------------------------------------------
                      _buildTotalsCard(item, width),

                      SizedBox(height: height * 0.018),

                      // ------------------------------------------------
                      // 4. HISTORY CARD
                      // ------------------------------------------------
                      _buildHistoryCard(item, width),

                      SizedBox(height: height * 0.022),

                      // ------------------------------------------------
                      // 5. INVOICE DOCUMENT PREVIEW CARD
                      // ------------------------------------------------
                      _buildDocumentCard(item, width, height, context),

                      SizedBox(height: height * 0.025),
                    ],
                  ),
                ),
              ),
            ),

            // --------------------------------------------------------
            // BOTTOM ACTIONS BAR
            // --------------------------------------------------------

            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: rs.contentMaxWidth),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    rs.s(16),
                    rs.s(12),
                    rs.s(16),
                    rs.s(16),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => AppButton(
                            text: controller.isDeleting.value
                                ? 'Deleting...'
                                : 'Delete',
                            icon: Icons.delete_outline_rounded,
                            height: rs.s(48),
                            backgroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFD64545),
                            borderColor: const Color(0xFFD64545),
                            loadingColor: const Color(0xFFD64545),
                            borderRadius: 12,
                            isLoading: controller.isDeleting.value,
                            onPressed: controller.deleteInvoice,
                          ),
                        ),
                      ),
                      SizedBox(width: rs.s(12)),
                      Expanded(
                        child: Obx(
                          () => AppButton(
                            text: controller.isUpdatingStatus.value
                                ? 'Updating...'
                                : 'Change Status',
                            icon: Icons.swap_horiz_rounded,
                            height: rs.s(48),
                            backgroundColor: colorsList.colorButton,
                            foregroundColor: Colors.white,
                            borderRadius: 12,
                            isLoading: controller.isUpdatingStatus.value,
                            onPressed: () {
                              controller.showStatusSelectionSheet();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // 1. TOP HEADER & STATUS CARD
  // ================================================================

  Widget _buildHeaderCard(PurchaseInvoicesModel item, double width) {
    final String invNo =
        item.supplierInvoiceNumber ?? item.invoiceNumber ?? 'PURCHASE';
    final String suppName = item.supplierName ?? 'Supplier';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invNo,
                  style: TextStyle(
                    fontSize: width * 0.050,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF063C70),
                  ),
                ),
              ),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: controller.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        controller.displayStatus,
                        style: TextStyle(
                          fontSize: width * 0.028,
                          color: controller.statusColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            suppName,
            style: TextStyle(
              fontSize: width * 0.032,
              color: colorsList.secondaryText,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2. SUPPLIER & DOCUMENT INFORMATION CARD
  // ================================================================

  Widget _buildSupplierAndDocCard(PurchaseInvoicesModel item, double width) {
    final suppName = item.supplierName ?? '—';
    final invNo = item.supplierInvoiceNumber ?? item.invoiceNumber ?? '—';
    final invDate = _formatDate(item.invoiceDate);
    final dueDate = _formatDate(item.dueDate);
    final docType = item.fileType.isNotEmpty
        ? (item.fileType == 'pdf' ? 'PDF Invoice' : 'Image Invoice')
        : 'Invoice';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: _gridItem('Supplier', suppName, width, isItalic: true)),
              Expanded(child: _gridItem('Document', docType, width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _gridItem('Supplier invoice number', invNo, width)),
              Expanded(
                  child: _gridItem('Supplier invoice date', invDate, width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _gridItem('Purchase date', invDate, width)),
              Expanded(child: _gridItem('Due date', dueDate, width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _gridItem(
                      'Purchase type', controller.displayCategory, width)),
              Expanded(child: _gridItem('Payment method', '—', width)),
            ],
          ),
          const SizedBox(height: 14),
          _gridItem('Reference', '—', width),
        ],
      ),
    );
  }

  // ================================================================
  // 3. TAX & TOTALS CARD
  // ================================================================

  Widget _buildTotalsCard(PurchaseInvoicesModel item, double width) {
    final currency = item.currency ?? 'EUR';
    final amount = item.totalAmount ?? 0;
    final formattedAmt = '$currency ${amount.toStringAsFixed(2)}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tax & totals',
            style: TextStyle(
              fontSize: width * 0.040,
              fontWeight: FontWeight.normal,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _totalRow('Subtotal', formattedAmt, width),
          _totalRow('Tax', '$currency 0.00', width),
          const Divider(height: 16, color: Color(0xFFF0F4F8)),
          _totalRow('Grand total', formattedAmt, width),
        ],
      ),
    );
  }

  // ================================================================
  // 4. HISTORY CARD
  // ================================================================

  Widget _buildHistoryCard(PurchaseInvoicesModel item, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History',
            style: TextStyle(
              fontSize: width * 0.040,
              fontWeight: FontWeight.normal,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _historyRow('Created', _formatDate(item.uploadedAt), width),
        ],
      ),
    );
  }

  // ================================================================
  // 5. INVOICE DOCUMENT PREVIEW CARD
  // ================================================================

  Widget _buildDocumentCard(
    PurchaseInvoicesModel item,
    double width,
    double height,
    BuildContext context,
  ) {
    final previewUrl = item.previewUrl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Document',
            style: TextStyle(
              fontSize: width * 0.040,
              fontWeight: FontWeight.normal,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
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
                fileType: item.fileType,
                mimeType: item.mimeType,
              );
            },
            child: Container(
              width: double.infinity,
              height: height * 0.22,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E6ED)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.fileType == 'pdf'
                          ? Icons.picture_as_pdf_rounded
                          : Icons.image_outlined,
                      color: item.fileType == 'pdf'
                          ? const Color(0xFFD64545)
                          : colorsList.iconColor,
                      size: width * 0.15,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.fileName.isNotEmpty
                                ? item.fileName
                                : 'Attachment Document',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF0A2342),
                              fontSize: width * 0.031,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: const Color(0xFF063C70),
                              fontSize: width * 0.028,
                              fontWeight: FontWeight.normal,
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
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _gridItem(String label, String value, double width,
      {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.027,
            color: colorsList.textHintColor,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: width * 0.034,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            fontWeight: FontWeight.normal,
            color: colorsList.textColor,
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.033,
              fontWeight: FontWeight.normal,
              color: colorsList.textHintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.033,
              fontWeight: FontWeight.normal,
              color: colorsList.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.030,
              color: colorsList.textHintColor,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.030,
              color: colorsList.textColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

void showInvoiceDocumentDialog({
  required BuildContext context,
  required String fileUrl,
  required String fileType,
  required String mimeType,
}) {
  final rs = context.rs;
  final double width = rs.isPhone
      ? rs.width
      : ResponsiveBreakpoints.designWidth * rs.scale;
  final double height = rs.isPhone
      ? rs.height
      : ResponsiveBreakpoints.designHeight * rs.scale;

  final bool isPdf = fileType.toLowerCase() == 'pdf' ||
      mimeType.toLowerCase() == 'application/pdf';

  final bool isImage = mimeType.toLowerCase().startsWith('image/') ||
      [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ].contains(fileType.toLowerCase());

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.70),
    builder: (context) {
      return ResponsiveDialogBody(
        maxWidth: rs.sheetMaxWidth + 80,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: rs.isPhone ? rs.wp(0.04) : rs.s(48),
            vertical: rs.isPhone ? rs.hp(0.06) : rs.s(40),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: rs.height * 0.82,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.018,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: colorsList.borderColor,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_outlined,
                          color: isPdf
                              ? colorsList.colorRed
                              : colorsList.textColor,
                          size: width * 0.055,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Document',
                              style: TextStyle(
                                color: colorsList.textColor,
                                fontSize: width.fontSizeW(0.040),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: height * 0.004),
                            Text(
                              isPdf ? 'PDF Document' : 'Image Document',
                              style: TextStyle(
                                color: colorsList.textColor,
                                fontSize: width.fontSizeW(0.028),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFFF3F5F8),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.022),
                            child: Icon(
                              Icons.close_rounded,
                              color: colorsList.iconColor,
                              size: width * 0.055,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: colorsList.colorBoxDecoration,
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
        ),
      );
    },
  );
}

Widget _buildDocumentPreview({
  required String fileUrl,
  required bool isPdf,
  required bool isImage,
}) {
  if (isPdf) {
    return SfPdfViewer.network(fileUrl);
  }

  if (isImage) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: colorsList.textColor),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 50,
                  color: colorsList.iconColor,
                ),
                SizedBox(height: 12),
                Text(
                  'Unable to load document.',
                  style: TextStyle(color: colorsList.textHintColor),
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
      style: TextStyle(color: colorsList.textHintColor),
    ),
  );
}