import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClientController extends GetxController {
  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final vatIdController = TextEditingController();
  final endpointIdController = TextEditingController();

  final ibanController = TextEditingController();
  final accountHolderController = TextEditingController();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();

  // ============================================================
  // DROPDOWN VALUES
  // ============================================================

  final RxnString selectedSchemeId = RxnString();
  final RxnString selectedCountry = RxnString();

  // ============================================================
  // LOADING
  // ============================================================

  final RxBool isLoading = false.obs;

  // ============================================================
  // DROPDOWN DATA
  // ============================================================

  final List<String> schemeIds = const [
    '0088 - GLN',
    '0096 - DUNS',
    '9914 - Austrian VAT',
    '9915 - Austrian tax number',
    '9930 - Austrian business register',
    '9948 - VAT identification number',
  ];

  final List<String> countries = const [
    'Austria',
    'Germany',
    'Switzerland',
    'France',
    'Italy',
    'Netherlands',
    'Belgium',
    'United Kingdom',
    'United States',
    'Pakistan',
  ];

  // ============================================================
  // FORM KEY
  // ============================================================

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ============================================================
  // DROPDOWN METHODS
  // ============================================================

  void selectSchemeId(String? value) {
    selectedSchemeId.value = value;
  }

  void selectCountry(String? value) {
    selectedCountry.value = value;
  }

  // ============================================================
  // SAVE CLIENT
  // ============================================================

  Future<void> saveClient() async {
    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter client name.',
      );
      return;
    }

    if (emailController.text.trim().isNotEmpty &&
        !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Validation',
        'Please enter a valid email address.',
      );
      return;
    }

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    isLoading.value = true;

    try {
      // --------------------------------------------------------
      // PREPARE DATA
      // --------------------------------------------------------

      final Map<String, dynamic> clientData = {
        'name': nameController.text.trim(),
        'vat_id': vatIdController.text.trim(),

        'scheme_id': selectedSchemeId.value,
        'endpoint_id': endpointIdController.text.trim(),

        'iban': ibanController.text.trim(),
        'account_holder': accountHolderController.text.trim(),

        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),

        'address1': address1Controller.text.trim(),
        'address2': address2Controller.text.trim(),
        'zip': zipController.text.trim(),
        'city': cityController.text.trim(),
        'country': selectedCountry.value,
      };

      debugPrint('CLIENT DATA: $clientData');

      // --------------------------------------------------------
      // TODO:
      // CALL YOUR API HERE
      // --------------------------------------------------------

      /*
      final response = await clientRepository.createClient(
        clientData,
      );
      */

      // Temporary delay for testing
      await Future.delayed(const Duration(seconds: 1));

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      Get.snackbar(
        'Success',
        'Client created successfully.',
      );

      Get.back(result: true);
    } catch (e) {
      // --------------------------------------------------------
      // ERROR
      // --------------------------------------------------------

      debugPrint('Save Client Error: $e');

      Get.snackbar(
        'Error',
        'Unable to create client. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CLEAR FORM
  // ============================================================

  void clearForm() {
    nameController.clear();
    vatIdController.clear();
    endpointIdController.clear();

    ibanController.clear();
    accountHolderController.clear();

    emailController.clear();
    phoneController.clear();

    address1Controller.clear();
    address2Controller.clear();
    zipController.clear();
    cityController.clear();

    selectedSchemeId.value = null;
    selectedCountry.value = null;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    nameController.dispose();
    vatIdController.dispose();
    endpointIdController.dispose();

    ibanController.dispose();
    accountHolderController.dispose();

    emailController.dispose();
    phoneController.dispose();

    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    cityController.dispose();

    super.onClose();
  }
}