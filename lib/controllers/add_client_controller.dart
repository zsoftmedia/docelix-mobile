import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
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

    final email = emailController.text.trim();

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validation',
        'Please enter a valid email address.',
      );
      return;
    }

    // ----------------------------------------------------------
    // GET SESSION DATA
    // ----------------------------------------------------------

    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Authentication token not found.',
      );
      return;
    }

    if (companyId == null) {
      Get.snackbar(
        'Error',
        'Company ID not found.',
      );
      return;
    }

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    isLoading.value = true;

    try {
      // --------------------------------------------------------
      // PREPARE API DATA
      // --------------------------------------------------------

      final Map<String, dynamic> clientData = {
        'name': nameController.text.trim(),

        'email': email.isEmpty ? null : email,

        'phone': phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),

        'address_line1': address1Controller.text.trim().isEmpty
            ? null
            : address1Controller.text.trim(),

        'address_line2': address2Controller.text.trim().isEmpty
            ? null
            : address2Controller.text.trim(),

        'postal_code': zipController.text.trim().isEmpty
            ? null
            : zipController.text.trim(),

        'city': cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),

        'country': selectedCountry.value,

        'vat_id': vatIdController.text.trim().isEmpty
            ? null
            : vatIdController.text.trim(),
      };

      debugPrint('CREATE CLIENT DATA: $clientData');

      // --------------------------------------------------------
      // CALL API
      // --------------------------------------------------------

      final response = await DioClient().createClient(
        companyId: companyId,
        accessToken: accessToken,
        data: clientData,
      );

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        debugPrint('CREATE CLIENT RESPONSE: ${response.data}');

        Get.back();

        AppSnackbar.success(
          title: 'Success',
          message: 'Client created successfully.',
        );

        Get.back(result: true);
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to create client.',
        );

      }
    } on DioException catch (e) {
      debugPrint('CREATE CLIENT ERROR: ${e.response?.data}');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');

      AppSnackbar.success(
        title: 'Erro',
        message: e.response?.data?['detail']?.toString() ??
            'Unable to create client. Please try again.',
      );

    } catch (e) {
      debugPrint('CREATE CLIENT ERROR: $e');

      AppSnackbar.error(
        title: 'Error',
        message:'Unable to create client. Please try again.',
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