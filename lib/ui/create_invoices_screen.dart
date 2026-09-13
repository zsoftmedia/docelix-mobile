import 'dart:io';
import 'package:docelix_mobileapp/controllers/ocr_controller.dart';
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoicesScreen extends StatefulWidget {
  @override
  State<CreateInvoicesScreen> createState() => _CreateInvoicesScreenState();
}

class _CreateInvoicesScreenState extends State<CreateInvoicesScreen> {
  // var loginPage_Controller = Get.put(LoginPage_Ctrl());
  // final _formKey = GlobalKey<FormState>(); // GlobalKey to manage form state

  final OcrController controller = Get.put(OcrController());

  bool checkLoginProgressbar = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack(
          children: [

            // ----------------------------------------------------------
            // TOP RIGHT DECORATION
            // ----------------------------------------------------------
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

            // ----------------------------------------------------------
            // MAIN CONTENT
            // ----------------------------------------------------------
            Obx(
                  () => SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ----------------------------------------------------
                    // TITLE
                    // ----------------------------------------------------
                    const SizedBox(height: 15),

                    const Text(
                      'Scan Document',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Take a photo or select an image to extract text.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667085),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ----------------------------------------------------
                    // IMAGE PREVIEW
                    // ----------------------------------------------------
                    if (controller.imagePath.value.isNotEmpty)
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: height * 0.38,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE4E7EC),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(controller.imagePath.value),
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      Container(
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
                              color: Color(0xFF98A2B3),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No document selected',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ----------------------------------------------------
                    // CAMERA & GALLERY BUTTONS
                    // ----------------------------------------------------
                    Row(
                      children: [

                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.captureFromCamera,
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

                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.pickFromGallery,
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 21,
                              ),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                                side: const BorderSide(
                                  color: Color(0xFF1976D2),
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

                    const SizedBox(height: 25),

                    // ----------------------------------------------------
                    // LOADING
                    // ----------------------------------------------------
                    if (controller.isLoading.value)
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Extracting text...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ----------------------------------------------------
                    // OCR RESULT
                    // ----------------------------------------------------
                    if (!controller.isLoading.value &&
                        controller.extractedText.value.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE4E7EC),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            const Row(
                              children: [
                                Icon(
                                  Icons.text_snippet_outlined,
                                  size: 20,
                                  color: Color(0xFF1976D2),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Extracted Text',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D2939),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            SelectableText(
                              controller.extractedText.value,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ----------------------------------------------------
                    // EMPTY STATE
                    // ----------------------------------------------------
                    if (!controller.isLoading.value &&
                        controller.imagePath.value.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 30,
                        ),
                        child: Text(
                          'Choose Camera or Gallery to start OCR.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                      ),

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

}