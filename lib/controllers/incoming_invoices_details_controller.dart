import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomingInvoicesDetailsController extends GetxController {
  // ----------------------------------------------------------
  // INVOICE
  // ----------------------------------------------------------

  late IncomingInvoicesModel invoice;

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
  // STATUS / CATEGORY
  // ----------------------------------------------------------

  final RxString status = ''.obs;
  final RxString expenseCategory = ''.obs;

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

    status.value = data.status;

    expenseCategory.value =
        data.expenseCategory ?? 'other';
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
          (value) =>
      value != null &&
          value.trim().isNotEmpty,
    )
        .join(', ');
  }

  // ----------------------------------------------------------
  // DISPLAY STATUS
  // ----------------------------------------------------------

  String get displayStatus {
    if (status.value.isEmpty) {
      return 'Unknown';
    }

    final value = status.value.toLowerCase();

    return value[0].toUpperCase() +
        value.substring(1);
  }

  // ----------------------------------------------------------
  // STATUS COLOR
  // ----------------------------------------------------------

  Color get statusColor {
    switch (status.value.toLowerCase()) {
      case 'paid':
        return const Color(0xFF00B894);

      case 'pending':
      case 'unpaid':
        return const Color(0xFFF39C12);

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
          (word) =>
      word.isNotEmpty
          ? word[0].toUpperCase() +
          word.substring(1)
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