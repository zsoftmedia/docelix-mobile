import 'dart:io';
import 'package:docelix_mobileapp/controllers/create_incoming_invoice_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateIncomingInvoicesScreen extends StatefulWidget {
  const CreateIncomingInvoicesScreen({super.key});
  @override
  State<CreateIncomingInvoicesScreen> createState() =>
      _CreateIncomingInvoicesScreenState();
}

class _CreateIncomingInvoicesScreenState
    extends State<CreateIncomingInvoicesScreen> {
  final CreateIncomingInvoiceController incomingInvoiceController =
      Get.put(CreateIncomingInvoiceController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
            size: width * 0.05,
          ),
        ),
        title: Text(
          "Create Incoming Invoice",
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: width * 0.055,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================================
            // MAIN CONTENT
            // ==========================================================
            Obx(
              () => SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),
                    const Text(
                      'Capture an incoming invoice using your camera or select an image or PDF file.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorsList.textHintColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ==================================================
                    // DOCUMENT PREVIEW
                    // ==================================================
                    _buildDocumentPreview(height: height),
                    const SizedBox(height: 20),

                    // ==================================================
                    // CAMERA & SELECT FILE BUTTONS
                    // ==================================================
                    Row(
                      children: [
                        // CAMERA BUTTON
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed:
                                  incomingInvoiceController.isLoading.value
                                      ? null
                                      : incomingInvoiceController
                                          .captureFromCamera,
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 21,
                              ),
                              label: const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorsList.colorButton,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // SELECT FILE BUTTON
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed:
                                  incomingInvoiceController.isLoading.value
                                      ? null
                                      : incomingInvoiceController.pickFile,
                              icon: const Icon(
                                Icons.attach_file_outlined,
                                size: 21,
                              ),
                              label: const Text(
                                'Select File',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorsList.colorButton,
                                side: const BorderSide(
                                  color: colorsList.colorButton,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ==================================================
                    // SELECTED FILE INFORMATION
                    // ==================================================
                    if (incomingInvoiceController
                        .filePath.value.isNotEmpty)
                      _buildSelectedFileInfo(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ==========================================================
            // UPLOADING PROGRESS OVERLAY
            // ==========================================================
            Obx(() {
              if (!incomingInvoiceController.isLoading.value) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: colorsList.colorButton,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Uploading invoice...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorsList.textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please wait a moment',
                          style: TextStyle(
                            fontSize: 12,
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

  // ================================================================
  // DOCUMENT PREVIEW
  // ================================================================

  Widget _buildDocumentPreview({required double height}) {
    if (incomingInvoiceController.filePath.value.isEmpty) {
      return Container(
        width: double.infinity,
        height: height * 0.28,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 60,
              color: colorsList.iconColor,
            ),
            SizedBox(height: 12),
            Text(
              'No document selected',
              style: TextStyle(
                fontSize: 15,
                color: colorsList.textHintColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Use Camera or Select File',
              style: TextStyle(
                fontSize: 13,
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
        constraints: BoxConstraints(maxHeight: height * 0.38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorsList.borderColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
        height: height * 0.28,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              size: 65,
              color: colorsList.red,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                incomingInvoiceController.fileName.value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'PDF document',
              style: TextStyle(
                fontSize: 13,
                color: colorsList.textHintColor,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  // ================================================================
  // SELECTED FILE INFORMATION
  // ================================================================

  Widget _buildSelectedFileInfo() {
    final bool isPdf = incomingInvoiceController.fileType.value == 'pdf';

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            size: 24,
            color: isPdf ? const Color(0xFFD32F2F) : const Color(0xFF063C70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              incomingInvoiceController.fileName.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorsList.textColor,
              ),
            ),
          ),
          IconButton(
            onPressed: incomingInvoiceController.clearFile,
            icon: const Icon(Icons.close, size: 20),
            color: colorsList.iconColor,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}