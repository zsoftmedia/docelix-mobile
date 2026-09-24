import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

class CreateIncomingInvoiceController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();

  final dioClient = DioClient();
  final sessionManager = SessionManager();
  final RxBool isLoading = false.obs;

  /// Selected file path
  final RxString filePath = ''.obs;

  /// Selected file name
  final RxString fileName = ''.obs;

  /// Selected file type: image / pdf
  final RxString fileType = ''.obs;

  /// Uploaded invoice response
  final Rxn<Map<String, dynamic>> uploadedInvoice =
  Rxn<Map<String, dynamic>>();

  // ============================================================
  // CAPTURE IMAGE USING CAMERA
  // ============================================================

  Future<void> captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) return;

      filePath.value = image.path;
      fileName.value = image.name;
      fileType.value = 'image';

      // Automatically upload after camera capture
      await uploadInvoice();

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // SELECT IMAGE OR PDF
  // ============================================================

  Future<void> pickFile() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'pdf',
        ],
      );

      if (result.isEmpty) {
        return;
      }

      final PlatformFile selectedFile = result.first;

      if (selectedFile.path == null) {

        AppSnackbar.error(
          title: 'Error',
          message:'Unable to access selected file.',
        );

        return;
      }

      final String? extension =
      selectedFile.extension?.toLowerCase();

      filePath.value = selectedFile.path!;
      fileName.value = selectedFile.name;

      if (extension == 'pdf') {
        fileType.value = 'pdf';
      } else {
        fileType.value = 'image';
      }

      // Automatically upload after file selection
      await uploadInvoice();

    } catch (e) {

      AppSnackbar.error(
        title: 'Error',
        message:'${e.toString()}',
      );

    }
  }

  // ============================================================
  // UPLOAD INVOICE
  // ============================================================

  Future<void> uploadInvoice() async {
    if (filePath.value.isEmpty) {

      AppSnackbar.info(
        title: 'File Required',
        message:'Please select or capture an invoice first.',
      );

      return;
    }

    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {

        AppSnackbar.error(
          title: 'Error',
          message:'Access token is not available.',
        );

        return;
      }

      if (companyId == null) {

        AppSnackbar.error(
          title: 'Error',
          message:'Company ID is not available.',
        );

        return;
      }

      final response = await dioClient.uploadIncomingInvoice(
        companyId: int.parse(companyId.toString()),
        filePath: filePath.value,
        fileName: fileName.value,
        accessToken: accessToken,
        expenseCategory: 'other',
      );

      if (response.data['ok'] == true) {
        final data = response.data['data'];

        /*print('================================');
        print('INVOICE UPLOAD SUCCESS');
        print('Invoice ID: ${data['id']}');
        print('Company ID: ${data['companyId']}');
        print('Status: ${data['status']}');
        print('Supplier: ${data['extracted']?['supplier']?['name']}');
        print('Invoice Number: ${data['extracted']?['invoiceNumber']}');
        print('Invoice Date: ${data['extracted']?['invoiceDate']}');
        print('Currency: ${data['extracted']?['currency']}');
        print('Total: ${data['extracted']?['totalAmount']}');
        print('================================');*/

        AppSnackbar.success(
          title: 'Success',
          message:'Invoice uploaded successfully.',
        );

      } else {

        AppSnackbar.success(
          title: 'Error',
          message:'Invoice upload failed.',
        );

      }
    } on DioException catch (e) {
      /*print('================================');
      print('INVOICE UPLOAD ERROR');
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');
      print('================================');*/

      AppSnackbar.error(
        title: 'Upload Error',
        message:e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to upload invoice.',
      );

    } catch (e) {

      AppSnackbar.error(
        title: 'Error',
        message:e.toString(),
      );

    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CLEAR SELECTED FILE
  // ============================================================

  void clearFile() {
    filePath.value = '';
    fileName.value = '';
    fileType.value = '';
  }
}