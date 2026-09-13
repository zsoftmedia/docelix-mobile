import 'package:docelix_mobileapp/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class OcrController extends GetxController {
  final OcrService _ocrService = OcrService();
  final ImagePicker _imagePicker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxString extractedText = ''.obs;
  final RxString imagePath = ''.obs;

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return;

      await processImage(image.path);
    } catch (e) {
      Get.snackbar(
        'OCR Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Capture image using camera
  Future<void> captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) return;

      await processImage(image.path);
    } catch (e) {
      Get.snackbar(
        'OCR Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Process selected image
  Future<void> processImage(String path) async {
    try {
      isLoading.value = true;
      imagePath.value = path;

      final String text = await _ocrService.extractText(path);

      extractedText.value = text;
    } catch (e) {
      extractedText.value = '';

      Get.snackbar(
        'OCR Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    imagePath.value = '';
    extractedText.value = '';
  }

  @override
  void onClose() {
    _ocrService.dispose();
    super.onClose();
  }
}