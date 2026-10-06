import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/incoming_invoices_controller.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomingInvoicesDetailsController extends GetxController {
  // ----------------------------------------------------------
  // INVOICE
  // ----------------------------------------------------------

  late IncomingInvoicesModel invoice;

  // ----------------------------------------------------------
  // STATUS / CATEGORY
  // ----------------------------------------------------------

  final RxString status = ''.obs;
  final RxString expenseCategory = ''.obs;

  // ----------------------------------------------------------
  // DELETE & STATUS & SAVE PROGRESS
  // ----------------------------------------------------------

  final RxBool isDeleting = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxBool isSaving = false.obs;

  // ----------------------------------------------------------
  // TEXT CONTROLLERS
  // ----------------------------------------------------------

  late TextEditingController invoiceNumberController;
  late TextEditingController dateController;
  late TextEditingController currencyController;
  late TextEditingController totalController;
  late TextEditingController vatController;

  late TextEditingController supplierController;
  late TextEditingController supplierEmailController;
  late TextEditingController supplierPhoneController;
  late TextEditingController supplierAddressController;

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------

  void initialize(IncomingInvoicesModel data) {
    invoice = data;

    invoiceNumberController = TextEditingController(
      text: data.invoiceNumber ?? '',
    );

    dateController = TextEditingController(
      text: data.invoiceDate ?? '',
    );

    currencyController = TextEditingController(
      text: data.currency ?? '',
    );

    totalController = TextEditingController(
      text: data.totalAmount?.toString() ?? '',
    );

    vatController = TextEditingController(
      text: data.vatRatePercent?.toString() ?? '0',
    );

    supplierController = TextEditingController(
      text: data.supplierName ?? '',
    );

    supplierEmailController = TextEditingController(
      text: data.supplierEmail ?? '',
    );

    supplierPhoneController = TextEditingController(
      text: data.supplierPhone ?? '',
    );

    supplierAddressController = TextEditingController(
      text: _buildSupplierAddress(data),
    );

    status.value = (data.status.isEmpty) ? 'draft' : data.status;

    expenseCategory.value = data.expenseCategory ?? 'other';
  }

  // ----------------------------------------------------------
  // SELECT DATE
  // ----------------------------------------------------------

  Future<void> selectInvoiceDate() async {
    DateTime initialDate = DateTime.now();

    if (dateController.text.trim().isNotEmpty) {
      try {
        initialDate = DateTime.parse(
          dateController.text.trim(),
        );
      } catch (_) {
        initialDate = DateTime.now();
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF063C70),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0A2342),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateController.text =
          '${pickedDate.year.toString().padLeft(4, '0')}-'
          '${pickedDate.month.toString().padLeft(2, '0')}-'
          '${pickedDate.day.toString().padLeft(2, '0')}';
    }
  }

  // ----------------------------------------------------------
  // SAVE CHANGES (FULL INCOMING INVOICE UPDATE)
  // ----------------------------------------------------------

  Future<void> saveChanges() async {
    final invoiceId = invoice.id;

    if (invoiceNumberController.text.trim().isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter invoice number.',
      );
      return;
    }

    if (dateController.text.trim().isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please select invoice date.',
      );
      return;
    }

    try {
      isSaving.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token is missing.',
        );
        return;
      }

      final String currentStatus =
          status.value.isEmpty ? 'draft' : status.value.toLowerCase().trim();

      final Map<String, dynamic> payload = {
        'status': currentStatus,
        'invoice_number': invoiceNumberController.text.trim(),
        'invoice_date': dateController.text.trim(),
        'currency': currencyController.text.trim().isNotEmpty
            ? currencyController.text.trim().toUpperCase()
            : (invoice.currency ?? 'EUR'),
        'total_amount': double.tryParse(totalController.text.trim()) ??
            (invoice.totalAmount ?? 0),
        'vat_rate_percent': vatController.text.trim().isNotEmpty
            ? vatController.text.trim()
            : '0',
        'expense_category': expenseCategory.value.isEmpty
            ? 'other'
            : expenseCategory.value,
        'supplier_name': supplierController.text.trim(),
        'supplier_email': supplierEmailController.text.trim().isEmpty
            ? null
            : supplierEmailController.text.trim(),
        'supplier_phone': supplierPhoneController.text.trim().isEmpty
            ? null
            : supplierPhoneController.text.trim(),
        'supplier_address_line1': supplierAddressController.text.trim().isEmpty
            ? null
            : supplierAddressController.text.trim(),
        'supplier_address_line2': null,
        'supplier_city': null,
        'supplier_postal': null,
        'supplier_country': null,
        'expense_account_id': null,
        'expense_account_code': null,
      };

      print('Saving Invoice Changes for ID $invoiceId...');

      final response = await DioClient().updateIncomingInvoice(
        invoiceId: invoiceId,
        data: payload,
        accessToken: accessToken,
      );

      print('Save Changes Response: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Invoice changes saved successfully.',
        );

        if (Get.isRegistered<IncomingInvoicesController>()) {
          Get.find<IncomingInvoicesController>().refreshInvoices();
        }
      } else {
        AppSnackbar.error(
          title: 'Save Failed',
          message: 'Unable to save invoice changes.',
        );
      }
    } on DioException catch (e) {
      print('Save Changes Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String message = 'Unable to save invoice changes.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Save Failed',
        message: message,
      );
    } catch (e) {
      print('Save Changes Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while saving invoice changes.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ----------------------------------------------------------
  // UPDATE INVOICE STATUS (Draft | Paid | Unpaid)
  // ----------------------------------------------------------

  Future<void> updateStatus(String newStatus) async {
    final invoiceId = invoice.id;

    try {
      isUpdatingStatus.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token is missing.',
        );
        return;
      }

      final String targetStatus = newStatus.toLowerCase().trim();

      final Map<String, dynamic> payload = {
        'status': targetStatus,
        'invoice_number': invoiceNumberController.text.trim(),
        'invoice_date': dateController.text.trim(),
        'currency': currencyController.text.trim().isNotEmpty
            ? currencyController.text.trim().toUpperCase()
            : (invoice.currency ?? 'EUR'),
        'total_amount': double.tryParse(totalController.text.trim()) ??
            (invoice.totalAmount ?? 0),
        'vat_rate_percent': vatController.text.trim().isNotEmpty
            ? vatController.text.trim()
            : '0',
        'expense_category': expenseCategory.value.isEmpty
            ? 'other'
            : expenseCategory.value,
        'supplier_name': supplierController.text.trim(),
        'supplier_email': supplierEmailController.text.trim().isEmpty
            ? null
            : supplierEmailController.text.trim(),
        'supplier_phone': supplierPhoneController.text.trim().isEmpty
            ? null
            : supplierPhoneController.text.trim(),
        'supplier_address_line1': supplierAddressController.text.trim().isEmpty
            ? null
            : supplierAddressController.text.trim(),
        'supplier_address_line2': null,
        'supplier_city': null,
        'supplier_postal': null,
        'supplier_country': null,
        'expense_account_id': null,
        'expense_account_code': null,
      };

      print('Updating Incoming Invoice ID $invoiceId status to: $targetStatus');

      final response = await DioClient().updateIncomingInvoice(
        invoiceId: invoiceId,
        data: payload,
        accessToken: accessToken,
      );

      print('Update Status Response: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        status.value = targetStatus;

        AppSnackbar.success(
          title: 'Success',
          message: 'Invoice status updated to $displayStatus.',
        );

        if (Get.isRegistered<IncomingInvoicesController>()) {
          Get.find<IncomingInvoicesController>().refreshInvoices();
        }
      } else {
        AppSnackbar.error(
          title: 'Update Failed',
          message: 'Unable to update invoice status.',
        );
      }
    } on DioException catch (e) {
      print('Update Status Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String message = 'Unable to update invoice status.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Update Failed',
        message: message,
      );
    } catch (e) {
      print('Update Status Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while updating invoice status.',
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // ----------------------------------------------------------
  // SHOW STATUS SELECTION SHEET
  // ----------------------------------------------------------

  void showStatusSelectionSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Change Invoice Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A2342),
              ),
            ),
            const SizedBox(height: 14),
            /*_statusOptionTile(
              title: 'Mark Draft',
              statusKey: 'draft',
              icon: Icons.drafts_outlined,
              color: const Color(0xFF71829A),
            ),*/
            _statusOptionTile(
              title: 'Mark Paid',
              statusKey: 'paid',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF12A150),
            ),
            _statusOptionTile(
              title: 'Mark Unpaid',
              statusKey: 'unpaid',
              icon: Icons.pending_actions_rounded,
              color: const Color(0xFFF39C12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusOptionTile({
    required String title,
    required String statusKey,
    required IconData icon,
    required Color color,
  }) {
    final bool isCurrent =
        status.value.toLowerCase() == statusKey.toLowerCase();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF0A2342),
        ),
      ),
      trailing: isCurrent
          ? const Icon(Icons.check_rounded, color: Color(0xFF12A150))
          : null,
      onTap: () {
        Get.back();
        if (!isCurrent) {
          updateStatus(statusKey);
        }
      },
    );
  }

  // ----------------------------------------------------------
  // DELETE INCOMING INVOICE
  // ----------------------------------------------------------

  Future<void> deleteInvoice() async {
    final invoiceId = invoice.id;

    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Invoice',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A2342),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this incoming invoice? '
          'This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFF60728D),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF60728D),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD64545),
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
    );

    if (confirmed != true) {
      return;
    }

    await _performDeleteInvoice(invoiceId);
  }

  Future<void> _performDeleteInvoice(int invoiceId) async {
    try {
      isDeleting.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token is missing.',
        );
        return;
      }

      final response = await DioClient().deleteIncomingInvoice(
        invoiceId: invoiceId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        final data = response.data;

        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: (data is Map && data['message'] != null)
              ? data['message']
              : 'Invoice deleted successfully.',
        );

        if (Get.isRegistered<IncomingInvoicesController>()) {
          Get.find<IncomingInvoicesController>().refreshInvoices();
        }
      } else {
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete invoice.',
        );
      }
    } on DioException catch (e) {
      String message = 'Unable to delete invoice.';

      if (e.response?.data is Map) {
        message = e.response?.data['message'] ??
            e.response?.data['error'] ??
            message;
      }

      AppSnackbar.error(
        title: 'Delete Failed',
        message: message,
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while deleting the invoice.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // ----------------------------------------------------------
  // SUPPLIER ADDRESS
  // ----------------------------------------------------------

  String _buildSupplierAddress(
    IncomingInvoicesModel invoice,
  ) {
    final parts = [
      invoice.supplierAddressLine1,
      invoice.supplierAddressLine2,
      invoice.supplierCity,
      invoice.supplierPostal,
      invoice.supplierCountry,
    ];

    return parts
        .where(
          (value) => value != null && value.trim().isNotEmpty,
        )
        .join(', ');
  }

  // ----------------------------------------------------------
  // DISPLAY STATUS
  // ----------------------------------------------------------

  String get displayStatus {
    if (status.value.trim().isEmpty) {
      return 'Draft';
    }

    final value = status.value.toLowerCase().trim();

    return value[0].toUpperCase() + value.substring(1);
  }

  // ----------------------------------------------------------
  // STATUS COLOR
  // ----------------------------------------------------------

  Color get statusColor {
    switch (status.value.toLowerCase().trim()) {
      case 'paid':
        return const Color(0xFF00B894);

      case 'unpaid':
        return const Color(0xFFF39C12);

      case 'pending':
        return const Color(0xFFE67E22);

      case 'draft':
        return const Color(0xFF71829A);

      case 'overdue':
        return Colors.red;

      default:
        return const Color(0xFF71829A);
    }
  }

  // ----------------------------------------------------------
  // CATEGORY DISPLAY
  // ----------------------------------------------------------

  String get displayCategory {
    if (expenseCategory.value.isEmpty) {
      return 'Other Expense';
    }

    final value = expenseCategory.value;

    return value
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1)
              : word,
        )
        .join(' ');
  }

  // ----------------------------------------------------------
  // TOTAL AMOUNT
  // ----------------------------------------------------------

  String get formattedTotal {
    final currency = invoice.currency ?? '';
    final amount = invoice.totalAmount ?? 0;

    return '$currency $amount';
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void onClose() {
    invoiceNumberController.dispose();
    dateController.dispose();
    currencyController.dispose();
    totalController.dispose();
    vatController.dispose();

    supplierController.dispose();
    supplierEmailController.dispose();
    supplierPhoneController.dispose();
    supplierAddressController.dispose();

    super.onClose();
  }
}