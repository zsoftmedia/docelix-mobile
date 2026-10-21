import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_quotation_controller.dart';
import 'package:docelix_mobileapp/controllers/quotation_controller.dart';
import 'package:docelix_mobileapp/controllers/quotation_details_controller.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EditQuotationController extends CreateQuotationController {
  final Rxn<QuotationModel> quotation = Rxn<QuotationModel>();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is QuotationModel) {
      quotation.value = Get.arguments as QuotationModel;
      _populateFormFromQuotation(quotation.value!);
    }
  }

  void _populateFormFromQuotation(QuotationModel model) {
    autoGenerate.value = false;
    invoiceNumberController.text = model.offerNumber;

    if (model.issueDate.isNotEmpty) {
      invoiceDateController.text = _formatApiDateToUI(model.issueDate);
    }

    if ((model.schlusstext ?? '').isNotEmpty) {
      closingTextController.text = model.schlusstext!;
    }

    // Populate line items
    if (model.items.isNotEmpty) {
      lineItems.clear();
      for (final item in model.items) {
        final netAmount = item.quantity * item.unitPrice;
        final grossAmount = netAmount + (netAmount * item.vatRate / 100);

        lineItems.add({
          'item_desc': item.description,
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'vat_rate': item.vatRate,
          'discount_percent': item.discountPercent,
          'gross_amount': grossAmount,
          'total': grossAmount,
        });
      }
    }

    // Match client when clients list finishes loading
    ever(clients, (_) {
      if (model.clientId > 0 && selectedClient.value == null) {
        final found = clients.firstWhereOrNull((c) => c.id == model.clientId);
        if (found != null) {
          selectClientByModel(found);
        }
      }
    });

    // Match company when companies list finishes loading
    ever(companies, (_) {
      if (model.companyId > 0 && selectedCompany.value == null) {
        final found = companies.firstWhereOrNull((c) => c.id == model.companyId);
        if (found != null) {
          selectCompany(found, loadDashboard: false);
        }
      }
    });
  }

  String _formatApiDateToUI(String value) {
    try {
      final parsed = DateTime.parse(value);
      return '${parsed.day.toString().padLeft(2, '0')}.'
          '${parsed.month.toString().padLeft(2, '0')}.'
          '${parsed.year}';
    } catch (_) {
      return value;
    }
  }

  @override
  Future<void> saveData() async {
    if (isLoading.value) return;

    final currentOffer = quotation.value;
    if (currentOffer == null || currentOffer.id <= 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No quotation selected for update.',
      );
      return;
    }

    if (selectedCompany.value == null) {
      AppSnackbar.error(title: 'Required', message: 'Please select a sender.');
      return;
    }

    if (selectedClient.value == null) {
      AppSnackbar.error(title: 'Required', message: 'Please select a client.');
      return;
    }

    if (invoiceDateController.text.trim().isEmpty) {
      AppSnackbar.error(title: 'Required', message: 'Please select offer date.');
      return;
    }

    if (lineItems.isEmpty) {
      AppSnackbar.error(title: 'Required', message: 'Please add at least one line item.');
      return;
    }

    final accessToken = SessionManager.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.error(title: 'Error', message: 'Access token is not available.');
      return;
    }

    final companyId = selectedCompany.value!.id;
    final clientId = selectedClient.value!.id;

    final issueDate = _formatInvoiceDateForApiLocal(invoiceDateController.text);
    if (issueDate == null) {
      AppSnackbar.error(title: 'Invalid date', message: 'Please select a valid offer date.');
      return;
    }

    final offerNumber = invoiceNumberController.text.trim();

    try {
      isLoading.value = true;

      final List<Map<String, dynamic>> items = lineItems.map((item) {
        final map = <String, dynamic>{
          'item_desc': item['item_desc']?.toString() ?? item['description']?.toString() ?? '',
          'catalog_item_id': item['catalog_item_id'],
          'quantity': (item['quantity'] as num?)?.toDouble() ?? 1,
          'unit_price': (item['unit_price'] as num?)?.toDouble() ?? 0,
          'vat_rate': (item['vat_rate'] as num?)?.toDouble() ?? 0,
          'discount_percent': (item['discount_percent'] as num?)?.toDouble() ?? 0,
        };
        return map;
      }).toList();

      final String companyNameStr = selectedCompany.value?.name ?? 'Company';
      final String clientEmailStr = selectedClient.value?.email ?? emailController.text.trim();
      final String clientPhoneStr = selectedClient.value?.phone ?? phoneController.text.trim();

      final String vortextStr =
          "Dear Sir or Madam,\nthank you for your interest. As discussed, we are pleased to offer you the following items:";

      final String schlusstextStr = closingTextController.text.trim().isNotEmpty
          ? closingTextController.text.trim()
          : "For further information or custom adjustments, please feel free to contact us.";

      final Map<String, dynamic> payload = {
        'company_id': companyId,
        'client_id': clientId,
        'offer_number': offerNumber,
        'issue_date': issueDate,
        'company_name': companyNameStr,
        'email': clientEmailStr,
        'phone': clientPhoneStr,
        'vortext': vortextStr,
        'vortext_pages': [vortextStr],
        'schlusstext': schlusstextStr,
        'schlusstext_pages': [schlusstextStr],
        'layout_order': ['pretext', 'items', 'posttext'],
        'items': items,
      };

      debugPrint('Updating Offer Payload for ID ${currentOffer.id}: $payload');

      final response = await dioClient.updateOffer(
        offerId: currentOffer.id,
        accessToken: accessToken,
        data: payload,
      );

      debugPrint('Update Offer Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearForm();

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Quotation updated successfully.',
        );

        if (Get.isRegistered<QuotationController>()) {
          Get.find<QuotationController>().refreshQuotations();
        }

        if (Get.isRegistered<QuotationDetailsController>()) {
          Get.find<QuotationDetailsController>().getOfferItems();
        }
      } else {
        AppSnackbar.error(
          title: 'Update Failed',
          message: 'Unable to update quotation.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Update Offer Dio Error: ${e.message}');
      String message = 'Unable to update quotation.';

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
      debugPrint('Update Offer Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while updating quotation.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? _formatInvoiceDateForApiLocal(String value) {
    if (value.trim().isEmpty) return null;
    try {
      final parts = value.trim().split('.');
      if (parts.length != 3) return value;
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    } catch (_) {
      return value;
    }
  }
}