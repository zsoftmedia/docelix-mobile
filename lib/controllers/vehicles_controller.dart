import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehiclesController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingDashboard = false.obs;

  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  final RxList<VehicleModel> filteredVehicles = <VehicleModel>[].obs;
  final Rxn<VehicleDashboard> dashboard = Rxn<VehicleDashboard>();

  final RxString searchQuery = ''.obs;

  int _listRequestId = 0;
  Worker? _searchWorker;

  String get currencyCode {
    return SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs ';
      default:
        return '$currencyCode ';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadVehicles(showLoader: false),
      time: const Duration(milliseconds: 350),
    );
    searchController.addListener(_onSearchTextChanged);
    loadVehicles();
  }

  void _onSearchTextChanged() {
    final text = searchController.text;
    if (searchQuery.value == text) return;
    searchQuery.value = text;
  }

  Future<void> loadVehicles({bool showLoader = true}) async {
    final requestId = ++_listRequestId;
    final query = searchQuery.value.trim();

    try {
      if (showLoader) {
        isLoading.value = true;
      } else {
        isSearching.value = true;
      }

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      if (companyId == null || companyId == 0) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final response = await _dioClient.getVehicles(
        companyId: companyId,
        accessToken: accessToken,
        search: query.isEmpty ? null : query,
      );

      if (requestId != _listRequestId) return;

      if (response.statusCode == 200) {
        final rawList = _extractList(response.data);
        var loaded = rawList
            .whereType<Map>()
            .map(
              (item) => VehicleModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        if (query.isNotEmpty) {
          final lower = query.toLowerCase();
          loaded = loaded.where((vehicle) {
            return vehicle.name.toLowerCase().contains(lower) ||
                (vehicle.plateNumber?.toLowerCase().contains(lower) ?? false) ||
                (vehicle.brand?.toLowerCase().contains(lower) ?? false) ||
                (vehicle.model?.toLowerCase().contains(lower) ?? false) ||
                vehicle.typeLabel.toLowerCase().contains(lower);
          }).toList();
        }

        vehicles
          ..clear()
          ..addAll(loaded);
        filteredVehicles
          ..clear()
          ..addAll(loaded);
        vehicles.refresh();
        filteredVehicles.refresh();
      } else {
        vehicles.clear();
        filteredVehicles.clear();
      }
    } on DioException catch (e) {
      if (requestId != _listRequestId) return;
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to load vehicles.',
      );
    } catch (e) {
      if (requestId != _listRequestId) return;
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      if (requestId == _listRequestId) {
        isLoading.value = false;
        isSearching.value = false;
      }
    }
  }

  Future<void> loadDashboard() async {
    try {
      isLoadingDashboard.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null ||
          accessToken.isEmpty ||
          companyId == null ||
          companyId == 0) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Session is not available.',
        );
        return;
      }

      final response = await _dioClient.getVehiclesDashboard(
        companyId: companyId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 && response.data is Map) {
        dashboard.value = VehicleDashboard.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to load fleet dashboard.',
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<bool> createVehicle({
    required String name,
    required String plateNumber,
    required String vehicleType,
    String? brand,
    String? model,
    int? year,
    String? vin,
    double currentKm = 0,
    bool isInsured = false,
    String status = 'active',
  }) async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null ||
        accessToken.isEmpty ||
        companyId == null ||
        companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Session is not available.',
      );
      return false;
    }

    final body = <String, dynamic>{
      'name': name.trim(),
      'plate_number': plateNumber.trim(),
      'vehicle_type': vehicleType,
      'status': status,
      'current_km': currentKm,
      'is_insured': isInsured,
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
      if (year != null) 'year': year,
      if (vin != null && vin.trim().isNotEmpty) 'vin': vin.trim(),
    };

    try {
      isSubmitting.value = true;
      final response = await _dioClient.createVehicle(
        body: body,
        accessToken: accessToken,
        companyId: companyId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Vehicle created successfully.',
        );
        await loadVehicles(showLoader: false);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Unable to create vehicle.',
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to create vehicle.',
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadVehicles(showLoader: false);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is List) return map['data'] as List;
      if (map['items'] is List) return map['items'] as List;
      if (map['vehicles'] is List) return map['vehicles'] as List;
    }
    return const [];
  }

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol ${formatter.format(value)}';
  }

  String formatKm(num value) {
    final formatter = NumberFormat('#,##0');
    return '${formatter.format(value)} km';
  }

  Future<void> refreshVehicles() => loadVehicles();

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }
}
