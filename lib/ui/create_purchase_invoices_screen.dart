import 'dart:io';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePurchaseInvoicesScreen extends StatefulWidget {
  const CreatePurchaseInvoicesScreen({super.key});
  @override
  State<CreatePurchaseInvoicesScreen> createState() =>
      _CreatePurchaseInvoicesScreenState();
}

class _CreatePurchaseInvoicesScreenState
    extends State<CreatePurchaseInvoicesScreen> {
  final CreatePurchaseInvoiceController incomingInvoiceController =
      Get.put(CreatePurchaseInvoiceController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.colorBackArrow,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Create Purchase Invoice',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(20),
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Obx(
              () => ResponsivePage(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.isPhone ? rs.wp(0.06) : rs.s(24),
                  vertical: rs.s(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: rs.s(15)),
                      Text(
                        'Capture a purchase invoice using your camera or select an image or PDF file.',
                        style: TextStyle(
                          fontSize: rs.sp(14),
                          color: colorsList.textHintColor,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: rs.s(25)),
                      _buildDocumentPreview(rs),
                      SizedBox(height: rs.s(20)),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: rs.s(52),
                              child: ElevatedButton.icon(
                                onPressed:
                                    incomingInvoiceController.isLoading.value
                                        ? null
                                        : incomingInvoiceController
                                            .captureFromCamera,
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  size: rs.s(21),
                                ),
                                label: Text(
                                  'Camera',
                                  style: TextStyle(
                                    fontSize: rs.sp(15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorsList.colorButton,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(rs.s(12)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: rs.s(12)),
                          Expanded(
                            child: SizedBox(
                              height: rs.s(52),
                              child: OutlinedButton.icon(
                                onPressed:
                                    incomingInvoiceController.isLoading.value
                                        ? null
                                        : incomingInvoiceController.pickFile,
                                icon: Icon(
                                  Icons.attach_file_outlined,
                                  size: rs.s(21),
                                ),
                                label: Text(
                                  'Select File',
                                  style: TextStyle(
                                    fontSize: rs.sp(15),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorsList.colorButton,
                                  side: const BorderSide(
                                    color: colorsList.colorButton,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(rs.s(12)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (incomingInvoiceController
                          .filePath.value.isNotEmpty)
                        _buildSelectedFileInfo(rs),
                      SizedBox(height: rs.s(30)),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              if (!incomingInvoiceController.isLoading.value) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs.s(28),
                      vertical: rs.s(24),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rs.s(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: colorsList.colorButton,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: rs.s(16)),
                        Text(
                          'Uploading invoice...',
                          style: TextStyle(
                            fontSize: rs.sp(15),
                            fontWeight: FontWeight.w600,
                            color: colorsList.textColor,
                          ),
                        ),
                        SizedBox(height: rs.s(4)),
                        Text(
                          'Please wait a moment',
                          style: TextStyle(
                            fontSize: rs.sp(12),
                            color: colorsList.textHintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(ResponsiveMetrics rs) {
    if (incomingInvoiceController.filePath.value.isEmpty) {
      return Container(
        width: double.infinity,
        height: rs.s(220),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(rs.s(16)),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: rs.s(60),
              color: colorsList.iconColor,
            ),
            SizedBox(height: rs.s(12)),
            Text(
              'No document selected',
              style: TextStyle(
                fontSize: rs.sp(15),
                color: colorsList.textHintColor,
              ),
            ),
            SizedBox(height: rs.s(5)),
            Text(
              'Use Camera or Select File',
              style: TextStyle(
                fontSize: rs.sp(13),
                color: colorsList.textHintColor,
              ),
            ),
          ],
        ),
      );
    }

    if (incomingInvoiceController.fileType.value == 'image') {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: rs.s(300)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs.s(16)),
          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rs.s(16)),
          child: Image.file(
            File(incomingInvoiceController.filePath.value),
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (incomingInvoiceController.fileType.value == 'pdf') {
      return Container(
        width: double.infinity,
        height: rs.s(220),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(rs.s(16)),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: rs.s(65),
              color: colorsList.red,
            ),
            SizedBox(height: rs.s(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs.s(20)),
              child: Text(
                incomingInvoiceController.fileName.value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: rs.sp(15),
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
            ),
            SizedBox(height: rs.s(6)),
            Text(
              'PDF document',
              style: TextStyle(
                fontSize: rs.sp(13),
                color: colorsList.textHintColor,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildSelectedFileInfo(ResponsiveMetrics rs) {
    final bool isPdf = incomingInvoiceController.fileType.value == 'pdf';

    return Container(
      margin: EdgeInsets.only(top: rs.s(18)),
      padding: EdgeInsets.symmetric(
        horizontal: rs.s(14),
        vertical: rs.s(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(rs.s(12)),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            size: rs.s(24),
            color: isPdf ? const Color(0xFFD32F2F) : const Color(0xFF063C70),
          ),
          SizedBox(width: rs.s(10)),
          Expanded(
            child: Text(
              incomingInvoiceController.fileName.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: rs.sp(14),
                fontWeight: FontWeight.w500,
                color: colorsList.textColor,
              ),
            ),
          ),
          IconButton(
            onPressed: incomingInvoiceController.clearFile,
            icon: Icon(Icons.close, size: rs.s(20)),
            color: colorsList.iconColor,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
