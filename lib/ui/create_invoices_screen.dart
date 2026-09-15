import 'dart:io';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/controllers/ocr_controller.dart';
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CreateInvoicesScreen extends StatefulWidget {
  const CreateInvoicesScreen({super.key});
  @override
  State<CreateInvoicesScreen> createState() => _CreateInvoicesScreenState();
}
class _CreateInvoicesScreenState extends State<CreateInvoicesScreen>{
  final CreateInvoiceController controller = Get.put(CreateInvoiceController());
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
        // ==========================================================
        // TOP RIGHT DECORATION
        // ==========================================================

            Positioned(
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: TopCurveClipper(),
                child: Container(
                  width: width * 0.70,
                  height: height * 0.28,
                  color: const Color(0xFFEAF3FB),
                ),
              ),
            ),
          // ==========================================================
          // MAIN CONTENT
          // ==========================================================

            Obx( () => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 15),
                // ==========================================================
                // TITLE
                // ==========================================================

                  const Text(
                    'Create Invoice',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text( 'Capture an invoice using your camera or select an image or PDF file.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // ==================================================
                  // DOCUMENT PREVIEW
                  // ==================================================

                  _buildDocumentPreview( height: height, ),
                  const SizedBox(height: 20),

                // ==================================================
                // CAMERA & SELECT FILE
                // ==================================================
                  Row(
                    children: [
                  // ------------------------------------------------
                  // CAMERA BUTTON
                  // ------------------------------------------------

                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: controller.captureFromCamera,
                            icon: const Icon( Icons.camera_alt_outlined, size: 21, ),
                            label: const Text( 'Camera',
                              style: TextStyle( fontSize: 15, fontWeight: FontWeight.w600, ), ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
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

                      // ------------------------------------------------
                      // SELECT FILE BUTTON
                      // ------------------------------------------------

                      Expanded(
                        child: SizedBox( height: 52,
                          child: OutlinedButton.icon(
                            onPressed: controller.pickFile,
                            icon: const Icon(
                              Icons.attach_file_outlined,
                              size: 21, ),
                            label: const Text( 'Select File',
                              style: TextStyle( fontSize: 15,
                                fontWeight: FontWeight.w600, ), ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1976D2),
                              side: const BorderSide( color: Color(0xFF1976D2), ),
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

                  if (controller.filePath.value.isNotEmpty) _buildSelectedFileInfo(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

    // ================================================================
    // DOCUMENT PREVIEW
    // ================================================================

  Widget _buildDocumentPreview({ required double height, }) {

    // ---------------------------------------------------------------
    // NO FILE
    // ---------------------------------------------------------------

    if (controller.filePath.value.isEmpty){
      return Container(
        width: double.infinity,
        height: height * 0.28,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all( color: const Color(0xFFE4E7EC),
          ),
        ),
        child: const Column( mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon( Icons.document_scanner_outlined,
              size: 60,
              color: Color(0xFF98A2B3), ),
            SizedBox(height: 12),
            Text( 'No document selected',
              style: TextStyle( fontSize: 15, color: Color(0xFF667085),
              ), ),
            SizedBox(height: 5),
            Text( 'Use Camera or Select File',
              style: TextStyle( fontSize: 13, color: Color(0xFF98A2B3),
              ),
            ),
          ],
        ),
      );
    }

      // ---------------------------------------------------------------
      // IMAGE
      // ---------------------------------------------------------------

    if (controller.fileType.value == 'image') {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints( maxHeight: height * 0.38, ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC), ), ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(controller.filePath.value),
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

      // ---------------------------------------------------------------
      // PDF
      // ---------------------------------------------------------------

    if (controller.fileType.value == 'pdf') {
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
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric( horizontal: 20, ),
              child: Text( controller.fileName.value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text( 'PDF document',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
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
    final bool isPdf = controller.fileType.value == 'pdf';
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
          Icon( isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            size: 24,
            color: isPdf ? const Color(0xFFD32F2F) : const Color(0xFF1976D2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              controller.fileName.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
            ),
          ),
          IconButton(
            onPressed: controller.clearFile,
            icon: const Icon( Icons.close, size: 20, ),
            color: const Color(0xFF667085),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}