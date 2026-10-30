import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/accounts_payable_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/accounts_payable_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsPayableDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<AccountsPayableModel> bill = Rxn<AccountsPayableModel>();

  final RxBool isDeleting = false.obs;
  final RxBool isPaying = false.obs;
  final RxString selectedPaymentMethod = 'Bank Transfer'.obs;

  static const paymentMethodOptions = <String>[
    'Bank Transfer',
    'Cash',
  ];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is AccountsPayableModel) {
      bill.value = Get.arguments as AccountsPayableModel;
    }
  }

  Future<void> deleteBill() async {
    final currentBill = bill.value;
    if (currentBill == null || currentBill.id == null || currentBill.id! <= 0) return;

    final bool? confirmed = await Get.dialog<bool>(
      ResponsiveDialogBody(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Bill',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A2342),
            ),
          ),
          content: Text(
            'Are you sure you want to delete bill #${currentBill.invoiceNumber ?? currentBill.id}? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF60728D),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF60728D))),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await _performDelete(currentBill.id!);
  }

  Future<void> _performDelete(int billId) async {
    try {
      isDeleting.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token missing.',
        );
        return;
      }

      debugPrint('Deleting payable bill ID $billId');

      final response = await dioClient.deleteIncomingInvoice(
        invoiceId: billId,
        accessToken: accessToken,
      );

      debugPrint('Delete Payable Bill Response Status: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Payable bill deleted successfully.',
        );

        if (Get.isRegistered<AccountsPayableController>()) {
          Get.find<AccountsPayableController>().refreshPayableBills();
        }
      } else {
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete payable bill.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete Payable Bill Dio Error: ${e.message}');
      String message = 'Unable to delete payable bill.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Delete Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Delete Payable Bill Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while deleting payable bill.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> confirmPayBill() async {
    final currentBill = bill.value;
    if (currentBill == null || currentBill.id == null || currentBill.id! <= 0) return;

    try {
      isPaying.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token missing.',
        );
        return;
      }

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID missing.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());
      final String methodKey = selectedPaymentMethod.value.toLowerCase().contains('bank')
          ? 'bank_transfer'
          : 'cash';

      debugPrint('Paying bill ID ${currentBill.id} with method $methodKey');

      final response = await dioClient.payBill(
        invoiceId: currentBill.id!,
        companyId: companyIdInt,
        paymentMethod: methodKey,
        accessToken: accessToken,
      );

      debugPrint('Pay Bill Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedBill = currentBill.copyWith(
          status: 'paid',
          remainingAmount: 0.0,
          paidDate: DateTime.now().toIso8601String(),
        );
        bill.value = updatedBill;

        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        AppSnackbar.success(
          title: 'Success',
          message: 'Payment recorded successfully.',
        );

        if (Get.isRegistered<AccountsPayableController>()) {
          Get.find<AccountsPayableController>().refreshPayableBills();
        }
      } else {
        AppSnackbar.error(
          title: 'Payment Failed',
          message: 'Unable to record payment.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Pay Bill Dio Error: ${e.message}');
      String message = 'Unable to record payment.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Payment Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Pay Bill Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while recording payment.',
      );
    } finally {
      isPaying.value = false;
    }
  }

  String getCurrencySymbol(String? code) {
    final String rawCode = (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (bill.value?.currency?.trim().toUpperCase() ??
            SessionManager.accessCorrencycode?.trim().toUpperCase() ??
            'EUR');

    switch (rawCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'PKR':
        return 'Rs.';
      default:
        return rawCode;
    }
  }

  String formatCurrency(num? amount, [String? currencyCode]) {
    final double value = (amount ?? 0).toDouble();
    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$symbol $formattedInteger.$decimalPart';
  }
}