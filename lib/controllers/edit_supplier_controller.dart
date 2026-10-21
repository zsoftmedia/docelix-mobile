import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/supplier_controller.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditSupplierController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<SupplierModel> supplier = Rxn<SupplierModel>();
  final RxBool isLoading = false.obs;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final vatIdController = TextEditingController();
  final taxIdController = TextEditingController();
  final ibanController = TextEditingController();
  final paymentTermsController = TextEditingController(text: '30');
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is SupplierModel) {
      supplier.value = Get.arguments as SupplierModel;
      _populateForm(supplier.value!);
    }
  }

  void _populateForm(SupplierModel model) {
    nameController.text = model.name;
    contactPersonController.text = model.contactName ?? '';
    emailController.text = model.email ?? '';
    phoneController.text = model.phone ?? '';
    websiteController.text = model.website ?? '';
    addressController.text = model.addressLine1 ?? '';
    postalCodeController.text = model.postalCode ?? '';
    cityController.text = model.city ?? '';
    countryController.text = model.country ?? '';
    vatIdController.text = model.vatId ?? '';
    taxIdController.text = model.taxId ?? '';
    ibanController.text = model.iban ?? '';
    paymentTermsController.text = model.paymentTermsDays?.toString() ?? '30';
    notesController.text = model.notes ?? '';
  }

  // ============================================================
  // UPDATE SUPPLIER
  // ============================================================

  Future<void> saveSupplier() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null || currentSupplier.id <= 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No supplier selected for update.',
      );
      return;
    }

    final name = nameController.text.trim();

    if (name.isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter supplier name.',
      );
      return;
    }

    final email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter a valid email address.',
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
          message: 'Access token is not available.',
        );
        return;
      }

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      final Map<String, dynamic> payload = {
        'name': name,
        'contact_name': contactPersonController.text.trim().isNotEmpty
            ? contactPersonController.text.trim()
            : null,
        'email': email.isNotEmpty ? email : null,
        'phone': phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        'website': websiteController.text.trim().isNotEmpty
            ? websiteController.text.trim()
            : null,
        'address_line1': addressController.text.trim().isNotEmpty
            ? addressController.text.trim()
            : null,
        'address_line2': null,
        'postal_code': postalCodeController.text.trim().isNotEmpty
            ? postalCodeController.text.trim()
            : null,
        'city': cityController.text.trim().isNotEmpty
            ? cityController.text.trim()
            : null,
        'country': countryController.text.trim().isNotEmpty
            ? countryController.text.trim()
            : null,
        'vat_id': vatIdController.text.trim().isNotEmpty
            ? vatIdController.text.trim()
            : null,
        'tax_id': taxIdController.text.trim().isNotEmpty
            ? taxIdController.text.trim()
            : null,
        'iban': ibanController.text.trim().isNotEmpty
            ? ibanController.text.trim()
            : null,
        'payment_terms_days':
            int.tryParse(paymentTermsController.text.trim()) ?? 30,
        'notes': notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      };

      debugPrint('Updating Supplier ID ${currentSupplier.id} for Company ID: $companyIdInt');

      final response = await dioClient.updateSupplier(
        companyId: companyIdInt,
        supplierId: currentSupplier.id,
        data: payload,
        accessToken: accessToken,
      );

      debugPrint('Update Supplier Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        SupplierModel? updatedModel;

        if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          updatedModel = SupplierModel.fromJson(map);
        }

        Get.back(result: updatedModel ?? true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Supplier updated successfully.',
        );

        if (Get.isRegistered<SupplierController>()) {
          Get.find<SupplierController>().refreshSuppliers();
        }
      } else {
        AppSnackbar.error(
          title: 'Update Failed',
          message: 'Unable to update supplier.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Update Supplier Dio Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');

      String message = 'Unable to update supplier.';

      if (e.response?.data is Map) {
        final data = e.response?.data as Map;
        message = data['message']?.toString() ??
            data['detail']?.toString() ??
            data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Update Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Update Supplier Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while updating supplier.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    vatIdController.dispose();
    taxIdController.dispose();
    ibanController.dispose();
    paymentTermsController.dispose();
    notesController.dispose();
    super.onClose();
  }
}