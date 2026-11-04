import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';

class VehicleDetailsController extends GetxController {
  VehicleDetailsController({required VehicleModel initialVehicle})
    : vehicle = initialVehicle.obs;

  final DioClient _dioClient = DioClient();

  final Rx<VehicleModel> vehicle;
  final RxList<VehicleTrip> trips = <VehicleTrip>[].obs;
  final RxList<VehicleFuelLog> fuelLogs = <VehicleFuelLog>[].obs;
  final RxList<VehicleServiceLog> services = <VehicleServiceLog>[].obs;
  final RxList<VehicleInsurance> insurancePolicies = <VehicleInsurance>[].obs;
  final RxList<VehicleDocument> documents = <VehicleDocument>[].obs;
  final RxList<VehicleDriver> drivers = <VehicleDriver>[].obs;
  final RxList<VehicleLocation> locations = <VehicleLocation>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingTrips = false.obs;
  final RxBool isLoadingFuel = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool isLoadingInsurance = false.obs;
  final RxBool isLoadingDocuments = false.obs;
  final RxBool isLoadingDrivers = false.obs;
  final RxBool isAssigningDriver = false.obs;
  final RxBool isDeletingAssignment = false.obs;
  final RxBool isCalculatingDistance = false.obs;
  final RxBool isSavingTrip = false.obs;
  final RxBool isDeletingTrip = false.obs;
  final RxBool isSavingFuel = false.obs;
  final RxBool isUploadingFuelReceipt = false.obs;
  final RxBool isSavingService = false.obs;
  final RxBool isSavingInsurance = false.obs;
  final RxBool isSavingDocument = false.obs;

  // ============================================================
  // TRIP FORM CONTROLLERS & REACTIVE STATE
  // ============================================================

  final tripFromController = TextEditingController();
  final tripToController = TextEditingController();
  final tripPurposeController = TextEditingController();
  final tripPassengersController = TextEditingController(text: '0');
  final tripVisitedCustomerController = TextEditingController();
  final tripStartOdometerController = TextEditingController();
  final tripEndOdometerController = TextEditingController();
  final tripNotesController = TextEditingController();

  final RxString tripType = 'Business'.obs; // 'Business' or 'Private'
  final Rxn<DateTime> tripDate = Rxn<DateTime>(DateTime.now());
  final Rxn<DateTime> tripArrivalDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> tripStartTime = Rxn<TimeOfDay>();
  final Rxn<TimeOfDay> tripEndTime = Rxn<TimeOfDay>();
  final RxnInt selectedTripDriverId = RxnInt();
  final Rxn<VehicleDistanceResult> calculatedDistance = Rxn<VehicleDistanceResult>();

  void setTripType(String type) {
    tripType.value = type;
  }

  void resetTripForm() {
    tripFromController.clear();
    tripToController.clear();
    tripPurposeController.clear();
    tripPassengersController.text = '0';
    tripVisitedCustomerController.clear();

    final currentKm = vehicle.value.currentKm;
    tripStartOdometerController.text = currentKm > 0
        ? currentKm.toInt().toString()
        : '200';
    tripEndOdometerController.clear();
    tripNotesController.clear();

    tripType.value = 'Business';
    tripDate.value = DateTime.now();
    tripArrivalDate.value = null;
    tripStartTime.value = null;
    tripEndTime.value = null;
    calculatedDistance.value = null;
    startingAddressSuggestions.clear();
    destinationAddressSuggestions.clear();
    _placeSessionToken = '';

    final primaryDriver = vehicle.value.vehicleDriverAssignments
        .firstWhereOrNull((a) => a.isPrimary);
    selectedTripDriverId.value = primaryDriver?.driverId ??
        (drivers.isNotEmpty ? drivers.first.id : null);
  }

  // ============================================================
  // MAPS PLACE AUTOCOMPLETE
  // ============================================================

  final RxList<PlaceSuggestion> startingAddressSuggestions = <PlaceSuggestion>[].obs;
  final RxList<PlaceSuggestion> destinationAddressSuggestions = <PlaceSuggestion>[].obs;
  final RxBool isSearchingStartPlaces = false.obs;
  final RxBool isSearchingDestPlaces = false.obs;

  String _placeSessionToken = '';

  String get placeSessionToken {
    if (_placeSessionToken.isEmpty) {
      _placeSessionToken = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
    }
    return _placeSessionToken;
  }

  Future<void> searchPlaceAutocomplete({
    required String input,
    required bool isStart,
  }) async {
    final query = input.trim();
    if (query.length < 3) {
      if (isStart) {
        startingAddressSuggestions.clear();
      } else {
        destinationAddressSuggestions.clear();
      }
      return;
    }

    try {
      if (isStart) {
        isSearchingStartPlaces.value = true;
      } else {
        isSearchingDestPlaces.value = true;
      }

      final session = _sessionOrNull();
      if (session == null) return;

      final response = await _dioClient.getPlaceAutocomplete(
        input: query,
        sessionToken: placeSessionToken,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        final List<dynamic> suggestionsRaw = data['suggestions'] as List<dynamic>? ?? [];

        final List<PlaceSuggestion> items = suggestionsRaw
            .whereType<Map>()
            .map((e) => PlaceSuggestion.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (isStart) {
          startingAddressSuggestions.assignAll(items);
        } else {
          destinationAddressSuggestions.assignAll(items);
        }
      } else {
        if (isStart) {
          startingAddressSuggestions.clear();
        } else {
          destinationAddressSuggestions.clear();
        }
      }
    } catch (e) {
      debugPrint('[VehicleDetailsController] searchPlaceAutocomplete Error: $e');
    } finally {
      if (isStart) {
        isSearchingStartPlaces.value = false;
      } else {
        isSearchingDestPlaces.value = false;
      }
    }
  }

  final Rxn<PlaceDetails> startingPlaceDetails = Rxn<PlaceDetails>();
  final Rxn<PlaceDetails> destinationPlaceDetails = Rxn<PlaceDetails>();

  void autoCalculateIfReady() {
    final from = tripFromController.text.trim();
    final to = tripToController.text.trim();
    if (from.isNotEmpty && to.isNotEmpty) {
      calculateDistance(startAddress: from, destination: to);
    }
  }

  Future<void> selectStartingSuggestion(PlaceSuggestion suggestion) async {
    startingAddressSuggestions.clear();
    calculatedDistance.value = null;

    final session = _sessionOrNull();
    if (session != null) {
      try {
        final response = await _dioClient.getPlaceDetails(
          placeId: suggestion.placeId,
          sessionToken: placeSessionToken,
          companyId: session.companyId,
          accessToken: session.token,
        );

        _placeSessionToken = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';

        if (response.statusCode == 200 && response.data != null) {
          final details = PlaceDetails.fromJson(Map<String, dynamic>.from(response.data as Map));
          startingPlaceDetails.value = details;
          if (details.formattedAddress.isNotEmpty) {
            tripFromController.text = details.formattedAddress;
            autoCalculateIfReady();
            return;
          }
        }
      } catch (e) {
        debugPrint('[VehicleDetailsController] getPlaceDetails Error: $e');
      }
    }

    startingPlaceDetails.value = PlaceDetails(
      placeId: suggestion.placeId,
      formattedAddress: suggestion.fullAddress,
    );
    tripFromController.text = suggestion.fullAddress;
    autoCalculateIfReady();
  }

  Future<void> selectDestinationSuggestion(PlaceSuggestion suggestion) async {
    destinationAddressSuggestions.clear();
    calculatedDistance.value = null;

    final session = _sessionOrNull();
    if (session != null) {
      try {
        final response = await _dioClient.getPlaceDetails(
          placeId: suggestion.placeId,
          sessionToken: placeSessionToken,
          companyId: session.companyId,
          accessToken: session.token,
        );

        _placeSessionToken = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';

        if (response.statusCode == 200 && response.data != null) {
          final details = PlaceDetails.fromJson(Map<String, dynamic>.from(response.data as Map));
          destinationPlaceDetails.value = details;
          if (details.formattedAddress.isNotEmpty) {
            tripToController.text = details.formattedAddress;
            autoCalculateIfReady();
            return;
          }
        }
      } catch (e) {
        debugPrint('[VehicleDetailsController] getPlaceDetails Error: $e');
      }
    }

    destinationPlaceDetails.value = PlaceDetails(
      placeId: suggestion.placeId,
      formattedAddress: suggestion.fullAddress,
    );
    tripToController.text = suggestion.fullAddress;
    autoCalculateIfReady();
  }

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
    loadAll();
  }

  Future<void> loadAll() async {
    if (vehicle.value.id <= 0) return;

    final session = _sessionOrNull(showError: true);
    if (session == null) return;

    await Future.wait([
      loadVehicle(),
      loadDrivers(),
      //loadLocations(),
      loadTrips(),
      loadFuelLogs(),
      loadServices(),
      loadInsurance(),
      loadDocuments(),
    ]);
  }

  Future<void> refreshAll() => loadAll();

  ({String token, int companyId})? _sessionOrNull({bool showError = false}) {
    final accessToken = SessionManager.accessToken;

    int? companyId = vehicle.value.companyId > 0
        ? vehicle.value.companyId
        : null;

    if (companyId == null || companyId == 0) {
      final raw = SessionManager.accessCompanyid;
      if (raw != null) {
        companyId = int.tryParse(raw.toString());
      }
    }

    if (accessToken == null ||
        accessToken.isEmpty ||
        companyId == null ||
        companyId == 0) {
      if (showError) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID or Session is missing.',
        );
      }
      return null;
    }

    return (token: accessToken, companyId: companyId);
  }

  Future<void> loadVehicle() async {
    if (vehicle.value.id <= 0) return;
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoading.value = true;
      final response = await _dioClient.getVehicleById(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final raw = _extractMap(response.data);
        if (raw != null) {
          vehicle.value = VehicleModel.fromJson(raw);
        }
      } else {
        debugPrint('[VehicleDetailsController] getVehicleById status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('[VehicleDetailsController] getVehicleById DioError: ${e.message}');
    } catch (e) {
      debugPrint('[VehicleDetailsController] getVehicleById Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTrips() async {
    if (vehicle.value.id <= 0) return;
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingTrips.value = true;
      if (locations.isEmpty) {
        await loadLocations();
      }
      final response = await _dioClient.getVehicleTrips(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );
      final locationById = {
        for (final loc in locations) loc.id: loc,
      };
      final driverById = {
        for (final driver in drivers) driver.id: driver,
      };

      trips
        ..clear()
        ..addAll(
          _extractList(response.data).whereType<Map>().map((e) {
            final trip = VehicleTrip.fromJson(Map<String, dynamic>.from(e));
            final from = locationById[trip.fromLocationId ?? ''];
            final to = locationById[trip.toLocationId ?? ''];
            final driver = driverById[trip.driverId ?? -1];
            return VehicleTrip(
              id: trip.id,
              vehicleId: trip.vehicleId,
              driverId: trip.driverId,
              date: trip.date,
              purpose: trip.purpose,
              fromLocationId: trip.fromLocationId,
              toLocationId: trip.toLocationId,
              startLocation: trip.startLocation ?? from?.displayLabel,
              endLocation: trip.endLocation ?? to?.displayLabel,
              distanceKm: trip.distanceKm,
              durationMinutes: trip.durationMinutes,
              reimbursement: trip.reimbursement,
              notes: trip.notes,
              driverName: trip.driverName ?? driver?.name,
            );
          }),
        );
      trips.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load trips.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingTrips.value = false;
    }
  }

  Future<void> loadLocations() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      final response = await _dioClient.getVehicleLocations(
        companyId: session.companyId,
        accessToken: session.token,
      );
      locations
        ..clear()
        ..addAll(
          _extractList(response.data)
              .whereType<Map>()
              .map(
                (e) => VehicleLocation.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
      locations.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load locations.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    }
  }

  Future<VehicleDistanceResult?> calculateDistance({
    required String startAddress,
    required String destination,
  }) async {
    final session = _sessionOrNull(showError: true);
    if (session == null) return null;

    final from = startAddress.trim();
    final to = destination.trim();
    if (from.isEmpty || to.isEmpty) {
      return null;
    }

    try {
      isCalculatingDistance.value = true;

      // 1. Try POST /api/vehicles/maps/routes first
      final originMap = startingPlaceDetails.value?.toMap() ?? {'address': from};
      final destMap = destinationPlaceDetails.value?.toMap() ?? {'address': to};

      try {
        final routeResponse = await _dioClient.calculateVehicleRoute(
          origin: originMap,
          destination: destMap,
          companyId: session.companyId,
          accessToken: session.token,
        );

        if ((routeResponse.statusCode == 200 || routeResponse.statusCode == 201) &&
            routeResponse.data != null) {
          final map = _extractMap(routeResponse.data) ??
              Map<String, dynamic>.from(routeResponse.data as Map);
          final result = VehicleDistanceResult.fromJson(map);
          calculatedDistance.value = result;
          return result;
        }
      } catch (e) {
        debugPrint('[VehicleDetailsController] calculateVehicleRoute info ($e). Trying legacy distance...');
      }

      // 2. Fallback to POST /api/vehicles/calculate-distance
      final response = await _dioClient.calculateVehicleDistance(
        startAddress: from,
        destination: to,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final map = _extractMap(response.data) ??
            Map<String, dynamic>.from(response.data as Map);
        final result = VehicleDistanceResult.fromJson(map);
        calculatedDistance.value = result;
        return result;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('[VehicleDetailsController] calculateDistance DioError: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[VehicleDetailsController] calculateDistance Exception: $e');
      return null;
    } finally {
      isCalculatingDistance.value = false;
    }
  }

  Future<VehicleLocation?> _ensureLocation(String raw) async
  {
    final session = _sessionOrNull();
    if (session == null) return null;

    final label = raw.trim();
    if (label.isEmpty) return null;

    for (final loc in locations) {
      if (loc.name.toLowerCase() == label.toLowerCase() ||
          loc.address?.toLowerCase() == label.toLowerCase()) {
        return loc;
      }
    }

    final response = await _dioClient.createVehicleLocation(
      name: label,
      address: label,
      companyId: session.companyId,
      accessToken: session.token,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _responseMessage(
            response.data,
            'Unable to create location.',
          ),
      );
    }

    final map = _extractMap(response.data);
    if (map == null) {
      throw Exception('Location created but no data returned.');
    }

    final created = VehicleLocation.fromJson(map);
    final index = locations.indexWhere((loc) => loc.id == created.id);
    if (index >= 0) {
      locations[index] = created;
    } else {
      locations.add(created);
    }
    locations.refresh();
    return created;
  }

  Future<bool> createTrip({
    required DateTime tripDate,
    required String fromAddress,
    required String toAddress,
    required String purpose,
    required VehicleDistanceResult distance,
    int? driverId,
  }) async {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    final resolvedDriverId = driverId ??
        selectedTripDriverId.value ??
        (drivers.isNotEmpty ? drivers.first.id : null) ??
        vehicle.value.vehicleDriverAssignments
            .where((a) => a.isPrimary)
            .map((a) => a.driverId)
            .firstWhere((id) => id != null, orElse: () => null) ??
        vehicle.value.vehicleDriverAssignments
            .map((a) => a.driverId)
            .firstWhere((id) => id != null, orElse: () => null);

    if (resolvedDriverId == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Assign a driver before adding a trip.',
      );
      return false;
    }

    try {
      isSavingTrip.value = true;

      /*final startOdo = double.tryParse(tripStartOdometerController.text.trim()) ?? null;
      final endOdo = double.tryParse(tripEndOdometerController.text.trim()) ?? null;
      final bool hasOdometer = (endOdo > startOdo) && startOdo >= 0;*/

      final double? startOdo =
      double.tryParse(tripStartOdometerController.text.trim());

      final double? endOdo =
      double.tryParse(tripEndOdometerController.text.trim());

      final bool hasOdometer =
          startOdo != null &&
              endOdo != null &&
              endOdo > startOdo &&
              startOdo >= 0;

      final double recordedDistance = hasOdometer
          ? (endOdo - startOdo)
          : (distance.distanceKm > 0 ? distance.distanceKm : 10.0);

      String? startTimeStr;
      if (tripStartTime.value != null) {
        final h = tripStartTime.value!.hour.toString().padLeft(2, '0');
        final m = tripStartTime.value!.minute.toString().padLeft(2, '0');
        startTimeStr = '$h:$m';
      }

      String? endTimeStr;
      if (tripEndTime.value != null) {
        final h = tripEndTime.value!.hour.toString().padLeft(2, '0');
        final m = tripEndTime.value!.minute.toString().padLeft(2, '0');
        endTimeStr = '$h:$m';
      }

      final String? endDateStr = tripArrivalDate.value != null
          ? DateFormat('yyyy-MM-dd').format(tripArrivalDate.value!)
          : null;

      final body = <String, dynamic>{
        'vehicle_id': vehicle.value.id,
        'driver_id': resolvedDriverId,
        'trip_date': DateFormat('yyyy-MM-dd').format(tripDate),
        'end_date': endDateStr,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'trip_type': tripType.value.toLowerCase().trim(),
        'purpose': purpose.trim().isNotEmpty
            ? purpose.trim()
            : (tripType.value.toLowerCase() == 'private' ? 'Private Trip' : 'Business Trip'),
        'passenger_count': int.tryParse(tripPassengersController.text.trim()) ?? 0,
        'partner_name': tripVisitedCustomerController.text.trim().isNotEmpty
            ? tripVisitedCustomerController.text.trim()
            : null,
        'partner_client_id': null,
        'start_address': fromAddress.trim(),
        'start_place_id': startingPlaceDetails.value?.placeId,
        'start_latitude': startingPlaceDetails.value?.latitude,
        'start_longitude': startingPlaceDetails.value?.longitude,
        'destination_address': toAddress.trim(),
        'destination_place_id': destinationPlaceDetails.value?.placeId,
        'destination_latitude': destinationPlaceDetails.value?.latitude,
        'destination_longitude': destinationPlaceDetails.value?.longitude,
        'odometer_start_km': startOdo,
        'odometer_end_km': endOdo,
        'distance_km': recordedDistance,
        'distance_source': hasOdometer ? 'route' : 'automatic',
        'route_distance_km': calculatedDistance.value?.distanceKm ?? distance.distanceKm,
        'duration_minutes': distance.durationMinutes > 0 ? distance.durationMinutes : 15,
        'notes': tripNotesController.text.trim().isNotEmpty
            ? tripNotesController.text.trim()
            : null,
        'client_request_id': const Uuid().v4(),
       // 'client_request_id': '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}',
        'change_reason': null,
      };

      print('Anees_CreateTrip_Body: ${JsonEncoder.withIndent('  ').convert(body)}');
      //debugPrint('Anees_CreateTrip_Body: ${const JsonEncoder.withIndent('  ').convert(body)}');
      final response = await _dioClient.createVehicleTrip(
        body: body,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Trip saved successfully.',
        );
        await Future.wait([loadVehicle(), loadTrips()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(
          response.data,
          'Unable to save trip.',
        ),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to save trip.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSavingTrip.value = false;
    }
  }

  Future<bool> deleteTrip(VehicleTrip trip) async {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    try {
      isDeletingTrip.value = true;
      final response = await _dioClient.deleteVehicleTrip(
        vehicleId: vehicle.value.id,
        tripId: trip.id,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Trip deleted.',
        );
        await Future.wait([loadVehicle(), loadTrips()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(
            response.data,
            'Unable to delete trip.',
          ),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to delete trip.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isDeletingTrip.value = false;
    }
  }

  Future<void> loadFuelLogs() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingFuel.value = true;
      final response = await _dioClient.getVehicleFuelLogs(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );
      fuelLogs
        ..clear()
        ..addAll(
          _extractList(response.data)
              .whereType<Map>()
              .map(
                (e) => VehicleFuelLog.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
      fuelLogs.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load fuel logs.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingFuel.value = false;
    }
  }

  Future<bool> createFuelLog({
    required DateTime date,
    required double liters,
    required double cost,
    required double odometer,
  }) async
  {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    try {
      isSavingFuel.value = true;
      final response = await _dioClient.createVehicleFuelLog(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
        body: {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'amount': liters,
          'cost': cost,
          'odometer': odometer,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Fuel log saved.',
        );
        await Future.wait([loadFuelLogs(), loadVehicle()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(response.data, 'Unable to save fuel log.'),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to save fuel log.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSavingFuel.value = false;
    }
  }

  Future<bool> uploadFuelReceipt({
    required String filePath,
    required String fileName,
  }) async
  {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    try {
      isUploadingFuelReceipt.value = true;
      final response = await _dioClient.uploadVehicleFuelReceipt(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
        filePath: filePath,
        fileName: fileName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Fuel receipt uploaded and logged.',
        );
        await Future.wait([loadFuelLogs(), loadVehicle()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(
          response.data,
          'Unable to upload fuel receipt.',
        ),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to upload fuel receipt.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isUploadingFuelReceipt.value = false;
    }
  }

  Future<void> loadServices() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingServices.value = true;
      final response = await _dioClient.getVehicleServices(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );
      services
        ..clear()
        ..addAll(
          _extractList(response.data)
              .whereType<Map>()
              .map(
                (e) =>
                    VehicleServiceLog.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
      services.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load services.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<bool> createServiceLog({
    required DateTime date,
    required String description,
    required double cost,
    required double odometer,
  }) async
  {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    final desc = description.trim();
    if (desc.isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Description is required.',
      );
      return false;
    }

    try {
      isSavingService.value = true;
      final response = await _dioClient.createVehicleService(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
        body: {
          'date': DateFormat('yyyy-MM-dd').format(date),
          'description': desc,
          'cost': cost,
          'odometer': odometer,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Service log saved.',
        );
        await Future.wait([loadServices(), loadVehicle()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(response.data, 'Unable to save service.'),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to save service.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSavingService.value = false;
    }
  }

  Future<void> loadInsurance() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingInsurance.value = true;
      final response = await _dioClient.getVehicleInsurance(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );

      final data = response.data;
      final items = <VehicleInsurance>[];
      if (data is Map && data['id'] != null) {
        items.add(
          VehicleInsurance.fromJson(Map<String, dynamic>.from(data)),
        );
      } else {
        items.addAll(
          _extractList(data)
              .whereType<Map>()
              .map(
                (e) =>
                    VehicleInsurance.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
      }

      insurancePolicies
        ..clear()
        ..addAll(items);
      insurancePolicies.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load insurance.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingInsurance.value = false;
    }
  }

  Future<void> loadDocuments() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingDocuments.value = true;
      final response = await _dioClient.getVehicleDocuments(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
      );
      documents
        ..clear()
        ..addAll(
          _extractList(response.data)
              .whereType<Map>()
              .map(
                (e) => VehicleDocument.fromJson(Map<String, dynamic>.from(e)),
              ),
        );
      documents.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load documents.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<bool> createInsurancePolicy({
    required String provider,
    String? policyNumber,
    required double cost,
    required DateTime startDate,
    DateTime? endDate,
  }) async
  {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    final providerName = provider.trim();
    if (providerName.isEmpty) {
      AppSnackbar.error(title: 'Error', message: 'Provider is required.');
      return false;
    }

    try {
      isSavingInsurance.value = true;
      final body = <String, dynamic>{
        'provider': providerName,
        'cost': cost,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        if (policyNumber != null && policyNumber.trim().isNotEmpty)
          'policy_number': policyNumber.trim(),
        if (endDate != null)
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      };

      final response = await _dioClient.createVehicleInsurance(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Insurance policy saved.',
        );
        await Future.wait([loadInsurance(), loadVehicle()]);
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(response.data, 'Unable to save insurance.'),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to save insurance.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSavingInsurance.value = false;
    }
  }

  Future<bool> createVehicleDocument({
    required String name,
    required String documentType,
    required String fileUrl,
  }) async {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    final docName = name.trim();
    final url = fileUrl.trim();
    if (docName.isEmpty || url.isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Document name and file URL are required.',
      );
      return false;
    }

    try {
      isSavingDocument.value = true;
      final response = await _dioClient.createVehicleDocument(
        vehicleId: vehicle.value.id,
        companyId: session.companyId,
        accessToken: session.token,
        body: {
          'name': docName,
          'document_type': documentType,
          'file_url': url,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Document saved.',
        );
        await loadDocuments();
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(response.data, 'Unable to save document.'),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to save document.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSavingDocument.value = false;
    }
  }

  Future<void> loadDrivers() async {
    final session = _sessionOrNull();
    if (session == null) return;

    try {
      isLoadingDrivers.value = true;
      final response = await _dioClient.getVehicleDrivers(
        companyId: session.companyId,
        accessToken: session.token,
      );
      drivers
        ..clear()
        ..addAll(
          _extractList(response.data)
              .whereType<Map>()
              .map((e) => VehicleDriver.fromJson(Map<String, dynamic>.from(e))),
        );
      drivers.refresh();
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to load drivers.'),
      );
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoadingDrivers.value = false;
    }
  }

  Future<bool> assignDriver({
    int? existingDriverId,
    String? newDriverName,
    bool isPrimary = true,
  }) async
  {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    final assignedIds = vehicle.value.vehicleDriverAssignments
        .map((a) => a.driverId)
        .whereType<int>()
        .toSet();

    try {
      isAssigningDriver.value = true;

      int driverId;
      if (existingDriverId != null) {
        driverId = existingDriverId;
      } else {
        final name = newDriverName?.trim() ?? '';
        if (name.isEmpty) {
          AppSnackbar.error(
            title: 'Error',
            message: 'Driver name is required.',
          );
          return false;
        }

        final createResponse = await _dioClient.createVehicleDriver(
          name: name,
          companyId: session.companyId,
          accessToken: session.token,
        );

        if (createResponse.statusCode != 200 &&
            createResponse.statusCode != 201) {
          AppSnackbar.error(
            title: 'Error',
            message: createResponse.data?['message']?.toString() ??
                createResponse.data?['error']?.toString() ??
                'Unable to create driver.',
          );
          return false;
        }

        final created = _extractMap(createResponse.data);
        driverId = _asInt(created?['id']) ?? 0;
        if (driverId == 0) {
          AppSnackbar.error(
            title: 'Error',
            message: 'Driver was created but no ID was returned.',
          );
          return false;
        }
      }

      if (assignedIds.contains(driverId)) {
        AppSnackbar.error(
          title: 'Already assigned',
          message: 'This driver is already assigned to the vehicle.',
        );
        return false;
      }

      final assignResponse = await _dioClient.assignVehicleDriver(
        vehicleId: vehicle.value.id,
        driverId: driverId,
        isPrimary: isPrimary,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (assignResponse.statusCode == 200 ||
          assignResponse.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Driver assigned successfully.',
        );
        await Future.wait([loadVehicle(), loadDrivers()]);
        return true;
      } else {

        AppSnackbar.error(
          title: 'Error',
          message: assignResponse.data?['message']?.toString() ??
              assignResponse.data?['error']?.toString() ??
              'Unable to assign driver.',
        );

      }

      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to assign driver.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isAssigningDriver.value = false;
    }
  }

  Future<bool> deleteAssignment(VehicleDriverAssignment assignment) async {
    final session = _sessionOrNull(showError: true);
    if (session == null) return false;

    try {
      isDeletingAssignment.value = true;
      final response = await _dioClient.deleteVehicleDriverAssignment(
        vehicleId: vehicle.value.id,
        assignmentId: assignment.id,
        companyId: session.companyId,
        accessToken: session.token,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Driver assignment removed.',
        );
        await loadVehicle();
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: _responseMessage(
            response.data,
            'Unable to remove assignment.',
          ),
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _dioMessage(e, 'Unable to remove assignment.'),
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isDeletingAssignment.value = false;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic>? _extractMap(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data'] as Map);
      }
      if (map['vehicle'] is Map) {
        return Map<String, dynamic>.from(map['vehicle'] as Map);
      }
      return map;
    }
    return null;
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in [
        'data',
        'items',
        'trips',
        'fuel',
        'fuel_logs',
        'services',
        'insurance',
        'documents',
        'drivers',
        'locations',
        'results',
      ]) {
        if (map[key] is List) return map[key] as List;
      }
    }
    return const [];
  }

  String _responseMessage(dynamic data, String fallback) {
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        final str = message.toString();
        if (str.toLowerCase().contains('missing vehical id') ||
            str.toLowerCase().contains('missing vehicle id') ||
            str.toLowerCase().contains('company id missing') ||
            str.toLowerCase().contains('missing company id')) {
          return 'Vehicle details unavailable.';
        }
        return str;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      final str = data.trim();
      if (str.toLowerCase().contains('missing vehical id') ||
          str.toLowerCase().contains('missing vehicle id') ||
          str.toLowerCase().contains('company id missing') ||
          str.toLowerCase().contains('missing company id')) {
        return 'Vehicle details unavailable.';
      }
      return str;
    }
    return fallback;
  }

  String _dioMessage(DioException e, String fallback) {
    return _responseMessage(e.response?.data, e.message ?? fallback);
  }

  String formatMoney(num? value) {
    if (value == null) return '—';
    return '$currencySymbol${NumberFormat('#,##0.00').format(value)}';
  }

  String formatKm(num? value) {
    if (value == null) return '—';
    final formatter = NumberFormat('#,##0.##');
    return '${formatter.format(value)} km';
  }

  String formatLiters(num? value) {
    if (value == null) return '—';
    final formatter = NumberFormat('#,##0.##');
    return '${formatter.format(value)} L';
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy').format(parsed.toLocal());
  }

  String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('d MMM yyyy, HH:mm').format(parsed.toLocal());
  }

  Future<void> refreshVehicle() => loadVehicle();

  @override
  void onClose() {
    tripFromController.dispose();
    tripToController.dispose();
    tripPurposeController.dispose();
    tripPassengersController.dispose();
    tripVisitedCustomerController.dispose();
    tripStartOdometerController.dispose();
    tripEndOdometerController.dispose();
    tripNotesController.dispose();
    super.onClose();
  }
}
