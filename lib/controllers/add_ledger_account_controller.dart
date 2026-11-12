import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/ledger_controller.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddLedgerAccountController extends GetxController {
  final DioClient _dioClient = DioClient();

  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final germanNameController = TextEditingController();
  final arabicNameController = TextEditingController();
  final currencyController = TextEditingController(text: 'EUR');

  final RxString selectedAccountType = 'Asset'.obs;
  final RxString selectedNormalSide = 'Debit'.obs;
  final RxBool isActive = true.obs;
  final RxBool isSubmitting = false.obs;

  static const accountTypeOptions = <String>[
    'Asset',
    'Liability',
    'Equity',
    'Revenue',
    'Expense',
  ];

  static const normalSideOptions = <String>[
    'Debit',
    'Credit',
  ];

  void selectAccountType(String type) {
    selectedAccountType.value = type;
  }

  void selectNormalSide(String side) {
    selectedNormalSide.value = side;
  }

  void clearForm() {
    codeController.clear();
    nameController.clear();
    germanNameController.clear();
    arabicNameController.clear();
    currencyController.text = 'EUR';
    selectedAccountType.value = 'Asset';
    selectedNormalSide.value = 'Debit';
    isActive.value = true;
  }

  Future<bool> createAccount() async {
    final code = codeController.text.trim();
    final name = nameController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Code and Account Name are required.',
      );
      return false;
    }

    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Session Error',
        message: 'Missing session or company ID.',
      );
      return false;
    }

    try {
      isSubmitting.value = true;

      final germanName = germanNameController.text.trim();
      final arabicName = arabicNameController.text.trim();

      final body = <String, dynamic>{
        'code': code,
        'name': name,
        'name_de': germanName.isNotEmpty ? germanName : null,
        'name_ar': arabicName.isNotEmpty ? arabicName : null,
        'account_type': selectedAccountType.value.toLowerCase(),
        'normal_side': selectedNormalSide.value.toLowerCase(),
        'currency': currencyController.text.trim().toUpperCase(),
        'is_active': isActive.value,
      };

      final response = await _dioClient.createLedgerAccount(
        body: body,
        companyId: companyId,
        accessToken: token,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.data is Map && response.data['ok'] == true)) {
        clearForm();

        if (Get.isRegistered<LedgerController>()) {
          Get.find<LedgerController>().refreshAccounts();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Account created successfully.',
        );

        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: response.data?['message']?.toString() ?? 'Unable to create account.',
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Unable to create account.',
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    nameController.dispose();
    germanNameController.dispose();
    arabicNameController.dispose();
    currencyController.dispose();
    super.onClose();
  }
}