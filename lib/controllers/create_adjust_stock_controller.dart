import 'dart:math';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/stock_adjustment_controller.dart';
import 'package:docelix_mobileapp/models/inventory_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdjustmentReasonOption {
  final String key;
  final String label;
  final String description;

  const AdjustmentReasonOption({
    required this.key,
    required this.label,
    required this.description,
  });
}

class CreateAdjustStockController extends GetxController {
  final DioClient _dioClient = DioClient();

  final RxList<InventoryItem> items = <InventoryItem>[].obs;
  final RxnInt selectedItemId = RxnInt();
  final RxString quantityText = ''.obs;
  final RxString productSearchQuery = ''.obs;

  final RxBool isLoadingItems = false.obs;
  final RxBool isSubmitting = false.obs;

  List<InventoryItem> get filteredItems {
    final query = productSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      final name = item.articleName.toLowerCase();
      final sku = (item.articleNumber ?? '').toLowerCase();
      final category = (item.groupCode ?? '').toLowerCase();
      return name.contains(query) || sku.contains(query) || category.contains(query);
    }).toList();
  }

  // Tabs: 0 -> Add stock ("increase"), 1 -> Remove stock ("decrease"), 2 -> Set count ("set")
  final RxInt selectedActionIndex = 0.obs;

  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  final Rx<DateTime> adjustmentDate = DateTime.now().obs;

  // Selected Reason Key
  final RxString selectedReasonKey = 'received'.obs;

  InventoryItem? get selectedItem {
    final id = selectedItemId.value;
    if (id == null) return null;
    return items.firstWhereOrNull((it) => it.id == id);
  }

  double get inputQuantity {
    return double.tryParse(quantityText.value.trim()) ?? 0.0;
  }

  double get currentStock {
    final item = selectedItem;
    if (item == null) return 0.0;
    return item.currentStock;
  }

  double get calculatedNewStock {
    final current = currentStock;
    final qty = inputQuantity;

    switch (selectedActionIndex.value) {
      case 0: // Add
        return current + qty;
      case 1: // Remove
        return current - qty;
      case 2: // Set
        return qty;
      default:
        return current + qty;
    }
  }

  String get stockChangeSignText {
    final qty = inputQuantity;
    switch (selectedActionIndex.value) {
      case 0: // Add
        return '(+${_formatNum(qty)})';
      case 1: // Remove
        return '(-${_formatNum(qty)})';
      case 2: // Set
        final diff = qty - currentStock;
        return '(${diff >= 0 ? '+' : ''}${_formatNum(diff)})';
      default:
        return '(+${_formatNum(qty)})';
    }
  }

  double get calculatedPurchaseValue {
    final item = selectedItem;
    if (item == null) return 0.0;
    return inputQuantity * (item.purchasePriceNet ?? 0.0);
  }

  String _formatNum(double num) {
    if (num % 1 == 0) return num.toInt().toString();
    return num.toStringAsFixed(2);
  }

  // Reasons per tab
  static const addReasons = <AdjustmentReasonOption>[
    AdjustmentReasonOption(
      key: 'received',
      label: 'Received without purchase',
      description: 'Sample, gift or return without a document',
    ),
    AdjustmentReasonOption(
      key: 'correction',
      label: 'Other correction',
      description: 'Manual stock adjustment',
    ),
  ];

  static const removeReasons = <AdjustmentReasonOption>[
    AdjustmentReasonOption(
      key: 'damaged',
      label: 'Damaged',
      description: 'Damaged stock',
    ),
    AdjustmentReasonOption(
      key: 'expired',
      label: 'Expired',
      description: 'Expired stock',
    ),
    AdjustmentReasonOption(
      key: 'stolen',
      label: 'Lost or stolen',
      description: 'Missing or stolen inventory',
    ),
    AdjustmentReasonOption(
      key: 'correction',
      label: 'Other correction',
      description: 'Manual stock adjustment',
    ),
  ];

  static const setReasons = <AdjustmentReasonOption>[
    AdjustmentReasonOption(
      key: 'count',
      label: 'Physical count',
      description: 'Stocktaking or inventory count',
    ),
    AdjustmentReasonOption(
      key: 'correction',
      label: 'Other correction',
      description: 'Manual stock adjustment',
    ),
  ];

  List<AdjustmentReasonOption> get currentReasons {
    switch (selectedActionIndex.value) {
      case 0:
        return addReasons;
      case 1:
        return removeReasons;
      case 2:
        return setReasons;
      default:
        return addReasons;
    }
  }

  AdjustmentReasonOption? get currentSelectedReasonOption {
    return currentReasons.firstWhereOrNull((r) => r.key == selectedReasonKey.value) ??
        currentReasons.first;
  }

  void setActionTab(int index) {
    selectedActionIndex.value = index;
    final reasons = currentReasons;
    if (reasons.isNotEmpty) {
      selectedReasonKey.value = reasons.first.key;
    }
  }

  void resetForm() {
    selectedItemId.value = null;
    quantityController.clear();
    quantityText.value = '';
    notesController.clear();
    adjustmentDate.value = DateTime.now();
    selectedReasonKey.value = 'received';
    selectedActionIndex.value = 0;
  }

  @override
  void onInit() {
    super.onInit();
    quantityController.addListener(() {
      quantityText.value = quantityController.text;
    });
    loadProducts();
  }

  Future<void> loadProducts() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingItems.value = true;
      final response = await _dioClient.getInventoryItems(
        companyId: companyId,
        accessToken: token,
        page: 1,
        limit: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> bodyMap = Map<String, dynamic>.from(response.data as Map);
        final dynamic dataField = bodyMap['data'];
        List<dynamic> rawList = [];

        if (dataField is Map) {
          rawList = (dataField['items'] as List?) ?? [];
        } else if (dataField is List) {
          rawList = dataField;
        }

        final parsed = rawList
            .whereType<Map>()
            .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        items.assignAll(parsed);
      }
    } catch (e) {
      debugPrint('[CreateAdjustStockController] loadProducts Error: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void selectItem(InventoryItem item) {
    selectedItemId.value = item.id;
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: adjustmentDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      adjustmentDate.value = picked;
    }
  }

  String get actionButtonLabel {
    switch (selectedActionIndex.value) {
      case 0:
        return 'Add to stock';
      case 1:
        return 'Remove from stock';
      case 2:
        return 'Set count';
      default:
        return 'Add to stock';
    }
  }

  String get quantityFieldLabel {
    switch (selectedActionIndex.value) {
      case 0:
        return 'Quantity to add';
      case 1:
        return 'Quantity to remove';
      case 2:
        return 'Counted quantity';
      default:
        return 'Quantity to add';
    }
  }

  bool get isExceedingAvailableStock {
    if (selectedActionIndex.value == 1) { // Remove stock
      return inputQuantity > currentStock;
    }
    return false;
  }

  Map<String, dynamic> computeAdjustmentPayload() {
    final item = selectedItem!;
    final qty = inputQuantity;
    final current = currentStock;

    String kind;
    double adjustedQty;

    switch (selectedActionIndex.value) {
      case 0: // Add stock
        kind = 'increase';
        adjustedQty = qty;
        break;

      case 1: // Remove stock
        kind = 'decrease';
        adjustedQty = qty;
        break;

      case 2: // Set count
        if (qty >= current) {
          kind = 'increase';
          adjustedQty = qty - current;
        } else {
          kind = 'decrease';
          adjustedQty = current - qty;
        }
        break;

      default:
        kind = 'increase';
        adjustedQty = qty;
    }

    String reason = selectedReasonKey.value;
    if (reason == 'count') {
      reason = 'correction';
    }

    return {
      'item_id': item.id,
      'kind': kind,
      'quantity': adjustedQty,
      'date': DateFormat('yyyy-MM-dd').format(adjustmentDate.value),
      'reason': reason,
      'notes': notesController.text.trim(),
      'idempotency_key': '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}',
    };
  }

  Future<bool> submitAdjustment({bool saveAndNext = false}) async {
    final item = selectedItem;
    if (item == null) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please select a product first.',
      );
      return false;
    }

    final qtyStr = quantityController.text.trim();
    final qty = double.tryParse(qtyStr);

    if (qtyStr.isEmpty || qty == null || qty < 0) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter a valid quantity.',
      );
      return false;
    }

    // Validation for Remove Stock (cannot remove more than available stock)
    if (selectedActionIndex.value == 1 && qty > currentStock) {
      final unitStr = item.unitCode?.trim().isNotEmpty == true ? ' ${item.unitCode!.trim()}' : '';
      final availableStr = _formatNum(currentStock);
      AppSnackbar.error(
        title: 'Insufficient Stock',
        message: 'Cannot remove ${_formatNum(qty)}$unitStr. Only $availableStr$unitStr available in stock.',
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

      final body = computeAdjustmentPayload();

      final response = await _dioClient.createInventoryAdjustment(
        body: body,
        companyId: companyId,
        accessToken: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Stock adjustment saved successfully.',
        );

        if (Get.isRegistered<StockAdjustmentController>()) {
          Get.find<StockAdjustmentController>().refreshAdjustments();
        }

        if (saveAndNext) {
          resetForm();
          loadProducts();
        } else {
          resetForm();
          Get.back(result: true);
        }
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: response.data?['message']?.toString() ?? 'Unable to adjust stock.',
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _extractErrorMessage(e),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    debugPrint('[CreateAdjustStockController] DioError Data: $data');
    if (data is Map) {
      final msg = data['message'] ?? data['detail'] ?? data['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
      if (data['errors'] is Map) {
        final errors = Map<String, dynamic>.from(data['errors'] as Map);
        final firstError = errors.values.firstWhere((v) => v != null, orElse: () => null);
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        if (firstError != null) {
          return firstError.toString();
        }
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return e.message ?? 'Unable to adjust stock.';
  }

  @override
  void onClose() {
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }
}