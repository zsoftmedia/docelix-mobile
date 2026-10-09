class VehicleDriver {
  final int id;
  final int companyId;
  final int? userId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  const VehicleDriver({
    required this.id,
    required this.companyId,
    required this.name,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleDriver.fromJson(Map<String, dynamic> json) {
    return VehicleDriver(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      userId: _asInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class VehicleDriverAssignment {
  final int id;
  final int? vehicleId;
  final int? driverId;
  final String? driverName;
  final String? assignedAt;
  final String? startDate;
  final String? endDate;
  final bool isPrimary;

  const VehicleDriverAssignment({
    required this.id,
    this.vehicleId,
    this.driverId,
    this.driverName,
    this.assignedAt,
    this.startDate,
    this.endDate,
    this.isPrimary = false,
  });

  factory VehicleDriverAssignment.fromJson(Map<String, dynamic> json) {
    String? nestedName;
    final driver = json['driver'];
    if (driver is Map) {
      nestedName = driver['name']?.toString() ??
          driver['full_name']?.toString() ??
          [
            driver['first_name']?.toString(),
            driver['last_name']?.toString(),
          ].whereType<String>().where((p) => p.trim().isNotEmpty).join(' ');
      if (nestedName.trim().isEmpty) nestedName = null;
    }

    return VehicleDriverAssignment(
      id: _asInt(json['id']) ?? 0,
      vehicleId: _asInt(json['vehicle_id']),
      driverId: _asInt(json['driver_id']) ??
          _asInt(driver is Map ? driver['id'] : null),
      driverName: json['driver_name']?.toString() ??
          json['name']?.toString() ??
          nestedName,
      assignedAt: json['created_at']?.toString() ??
          json['assigned_at']?.toString(),
      startDate: json['start_date']?.toString() ??
          json['created_at']?.toString() ??
          json['assigned_at']?.toString(),
      endDate: json['end_date']?.toString() ?? json['unassigned_at']?.toString(),
      isPrimary: json['is_primary'] == true,
    );
  }
}

class VehicleModel {
  final int id;
  final int companyId;
  final String name;
  final String? plateNumber;
  final String? brand;
  final String? model;
  final int? year;
  final String? vin;
  final String vehicleType;
  final String status;
  final double? purchasePrice;
  final String? purchaseDate;
  final double currentKm;
  final bool isInsured;
  final int? assetId;
  final String? vatVehicleClassification;
  final String? createdAt;
  final String? updatedAt;
  final List<VehicleDriverAssignment> vehicleDriverAssignments;

  const VehicleModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.plateNumber,
    this.brand,
    this.model,
    this.year,
    this.vin,
    required this.vehicleType,
    required this.status,
    this.purchasePrice,
    this.purchaseDate,
    required this.currentKm,
    this.isInsured = false,
    this.assetId,
    this.vatVehicleClassification,
    this.createdAt,
    this.updatedAt,
    this.vehicleDriverAssignments = const [],
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final assignmentsRaw = json['vehicle_driver_assignments'];
    final assignments = <VehicleDriverAssignment>[];
    if (assignmentsRaw is List) {
      for (final item in assignmentsRaw) {
        if (item is Map) {
          assignments.add(
            VehicleDriverAssignment.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return VehicleModel(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      name: json['name']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString(),
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: _asInt(json['year']),
      vin: json['vin']?.toString(),
      vehicleType: json['vehicle_type']?.toString() ?? 'car',
      status: json['status']?.toString() ?? 'active',
      purchasePrice: _asDouble(json['purchase_price']),
      purchaseDate: json['purchase_date']?.toString(),
      currentKm: _asDouble(json['current_km']) ?? 0,
      isInsured: json['is_insured'] == true,
      assetId: _asInt(json['asset_id']),
      vatVehicleClassification:
          json['vat_vehicle_classification']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      vehicleDriverAssignments: assignments,
    );
  }

  String get brandModelLabel {
    final parts = <String>[
      if (brand != null && brand!.trim().isNotEmpty) brand!.trim(),
      if (model != null && model!.trim().isNotEmpty) model!.trim(),
    ];
    if (parts.isEmpty) return '—';
    return parts.join(' ');
  }

  String get typeLabel {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return 'Car';
      case 'van':
        return 'Van';
      case 'truck':
        return 'Truck';
      case 'motorcycle':
        return 'Motorcycle';
      case 'other':
        return 'Other';
      default:
        if (vehicleType.isEmpty) return 'Other';
        return '${vehicleType[0].toUpperCase()}${vehicleType.substring(1)}';
    }
  }

  String get statusLabel {
    if (status.isEmpty) return 'Active';
    return '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
  }

  String get kmLabel {
    final value = currentKm % 1 == 0
        ? currentKm.toInt().toString()
        : currentKm.toStringAsFixed(1);
    return '$value km';
  }

  bool get isActive => status.toLowerCase() == 'active';

  String get vatClassificationLabel {
    final raw = vatVehicleClassification?.trim();
    if (raw == null || raw.isEmpty) return '—';
    switch (raw.toLowerCase()) {
      case 'unknown':
        return 'Unknown';
      case 'passenger':
        return 'Passenger';
      case 'commercial':
        return 'Commercial';
      default:
        return '${raw[0].toUpperCase()}${raw.substring(1)}';
    }
  }
}

class VehicleDashboard {
  final int totalVehicles;
  final int activeVehicles;
  final double totalFleetValue;
  final double totalMileage;
  final double totalFuelCost;
  final double totalServiceCost;
  final double totalInsuranceCost;
  final double totalExpenses;

  const VehicleDashboard({
    this.totalVehicles = 0,
    this.activeVehicles = 0,
    this.totalFleetValue = 0,
    this.totalMileage = 0,
    this.totalFuelCost = 0,
    this.totalServiceCost = 0,
    this.totalInsuranceCost = 0,
    this.totalExpenses = 0,
  });

  factory VehicleDashboard.fromJson(Map<String, dynamic> json) {
    return VehicleDashboard(
      totalVehicles: _asInt(json['totalVehicles']) ?? 0,
      activeVehicles: _asInt(json['activeVehicles']) ?? 0,
      totalFleetValue: _asDouble(json['totalFleetValue']) ?? 0,
      totalMileage: _asDouble(json['totalMileage']) ?? 0,
      totalFuelCost: _asDouble(json['totalFuelCost']) ?? 0,
      totalServiceCost: _asDouble(json['totalServiceCost']) ?? 0,
      totalInsuranceCost: _asDouble(json['totalInsuranceCost']) ?? 0,
      totalExpenses: _asDouble(json['totalExpenses']) ?? 0,
    );
  }
}

class VehicleTypeOption {
  final String value;
  final String label;

  const VehicleTypeOption({required this.value, required this.label});
}

const vehicleTypeOptions = <VehicleTypeOption>[
  VehicleTypeOption(value: 'car', label: 'Car'),
  VehicleTypeOption(value: 'van', label: 'Van'),
  VehicleTypeOption(value: 'truck', label: 'Truck'),
  VehicleTypeOption(value: 'motorcycle', label: 'Motorcycle'),
  VehicleTypeOption(value: 'other', label: 'Other'),
];

class VehicleLocation {
  final String id;
  final int companyId;
  final String name;
  final String? address;
  final String? placeId;

  const VehicleLocation({
    required this.id,
    required this.companyId,
    required this.name,
    this.address,
    this.placeId,
  });

  factory VehicleLocation.fromJson(Map<String, dynamic> json) {
    return VehicleLocation(
      id: json['id']?.toString() ?? '',
      companyId: _asInt(json['company_id']) ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      placeId: json['place_id']?.toString(),
    );
  }

  String get displayLabel {
    final addr = address?.trim();
    if (addr != null && addr.isNotEmpty) return addr;
    return name;
  }
}

class VehicleDistanceResult {
  final double distanceKm;
  final String distanceText;
  final String durationText;
  final int durationMinutes;
  final String? polyline;

  const VehicleDistanceResult({
    required this.distanceKm,
    required this.distanceText,
    required this.durationText,
    required this.durationMinutes,
    this.polyline,
  });

  factory VehicleDistanceResult.fromJson(Map<String, dynamic> json) {
    final durationRaw = json['duration']?.toString() ?? '';
    return VehicleDistanceResult(
      distanceKm: _asDouble(json['distance']) ?? 0,
      distanceText: json['text']?.toString() ??
          '${_asDouble(json['distance']) ?? 0} km',
      durationText: durationRaw.isEmpty ? '—' : durationRaw,
      durationMinutes: _parseDurationMinutes(durationRaw) ??
          _asInt(json['duration_minutes']) ??
          0,
      polyline: json['polyline']?.toString(),
    );
  }
}

class VehicleTrip {
  final String id;
  final int? vehicleId;
  final int? driverId;
  final String? date;
  final String? purpose;
  final String? fromLocationId;
  final String? toLocationId;
  final String? startLocation;
  final String? endLocation;
  final double? distanceKm;
  final int? durationMinutes;
  final double? reimbursement;
  final String? notes;
  final String? driverName;

  const VehicleTrip({
    required this.id,
    this.vehicleId,
    this.driverId,
    this.date,
    this.purpose,
    this.fromLocationId,
    this.toLocationId,
    this.startLocation,
    this.endLocation,
    this.distanceKm,
    this.durationMinutes,
    this.reimbursement,
    this.notes,
    this.driverName,
  });

  factory VehicleTrip.fromJson(Map<String, dynamic> json) {
    String? locationName(dynamic value) {
      if (value is Map) {
        return value['name']?.toString() ??
            value['address']?.toString() ??
            value['label']?.toString();
      }
      return value?.toString();
    }

    return VehicleTrip(
      id: json['id']?.toString() ?? '',
      vehicleId: _asInt(json['vehicle_id']),
      driverId: _asInt(json['driver_id']),
      date: json['date']?.toString() ??
          json['trip_date']?.toString() ??
          json['started_at']?.toString(),
      purpose: json['purpose']?.toString() ?? json['description']?.toString(),
      fromLocationId: json['from_location_id']?.toString(),
      toLocationId: json['to_location_id']?.toString(),
      startLocation: locationName(json['from_location']) ??
          json['start_location']?.toString() ??
          json['from_address']?.toString() ??
          json['from']?.toString() ??
          json['origin']?.toString(),
      endLocation: locationName(json['to_location']) ??
          json['end_location']?.toString() ??
          json['to_address']?.toString() ??
          json['to']?.toString() ??
          json['destination']?.toString(),
      distanceKm: _asDouble(json['distance_km']) ??
          _asDouble(json['distance']) ??
          _asDouble(json['km']),
      durationMinutes: _asInt(json['duration_minutes']) ??
          _parseDurationMinutes(json['duration']?.toString()),
      reimbursement: _asDouble(json['reimbursement']) ??
          _asDouble(json['reimbursement_amount']) ??
          _asDouble(json['kilometergeld']),
      notes: json['notes']?.toString(),
      driverName: json['driver_name']?.toString() ??
          (json['driver'] is Map
              ? (json['driver']['name']?.toString())
              : null),
    );
  }

  String get routeLabel {
    final from = startLocation?.trim();
    final to = endLocation?.trim();
    if ((from == null || from.isEmpty) && (to == null || to.isEmpty)) {
      return purpose?.trim().isNotEmpty == true ? purpose!.trim() : 'Trip';
    }
    if (from == null || from.isEmpty) return to!;
    if (to == null || to.isEmpty) return from;
    return '$from → $to';
  }

  String get durationLabel {
    if (durationMinutes == null) return '—';
    return '$durationMinutes min';
  }
}

class VehicleFuelLog {
  final int id;
  final String? date;
  final double? liters;
  final double? cost;
  final double? odometerKm;
  final String? station;
  final String? notes;
  final String? fuelType;

  const VehicleFuelLog({
    required this.id,
    this.date,
    this.liters,
    this.cost,
    this.odometerKm,
    this.station,
    this.notes,
    this.fuelType,
  });

  factory VehicleFuelLog.fromJson(Map<String, dynamic> json) {
    // API: amount = liters, cost = total money
    return VehicleFuelLog(
      id: _asInt(json['id']) ?? 0,
      date: json['date']?.toString() ??
          json['fuel_date']?.toString() ??
          json['created_at']?.toString(),
      liters: _asDouble(json['amount']) ??
          _asDouble(json['liters']) ??
          _asDouble(json['volume']) ??
          _asDouble(json['quantity']),
      cost: _asDouble(json['cost']) ??
          _asDouble(json['total_cost']) ??
          _asDouble(json['price']),
      odometerKm: _asDouble(json['odometer']) ??
          _asDouble(json['odometer_km']) ??
          _asDouble(json['mileage']),
      station: json['station']?.toString() ??
          json['fuel_station']?.toString() ??
          json['location']?.toString(),
      notes: json['notes']?.toString(),
      fuelType: json['fuel_type']?.toString(),
    );
  }

  double? get costPerLiter {
    if (liters == null || cost == null || liters! <= 0) return null;
    return cost! / liters!;
  }
}

class VehicleServiceLog {
  final int id;
  final String? date;
  final String? serviceType;
  final String? description;
  final double? cost;
  final double? odometerKm;
  final String? provider;
  final String? status;

  const VehicleServiceLog({
    required this.id,
    this.date,
    this.serviceType,
    this.description,
    this.cost,
    this.odometerKm,
    this.provider,
    this.status,
  });

  factory VehicleServiceLog.fromJson(Map<String, dynamic> json) {
    return VehicleServiceLog(
      id: _asInt(json['id']) ?? 0,
      date: json['date']?.toString() ??
          json['service_date']?.toString() ??
          json['created_at']?.toString(),
      serviceType: json['service_type']?.toString() ??
          json['type']?.toString() ??
          json['category']?.toString(),
      description: json['description']?.toString() ??
          json['notes']?.toString() ??
          json['title']?.toString(),
      cost: _asDouble(json['cost']) ??
          _asDouble(json['amount']) ??
          _asDouble(json['total_cost']),
      odometerKm: _asDouble(json['odometer']) ??
          _asDouble(json['odometer_km']) ??
          _asDouble(json['mileage']),
      provider: json['provider']?.toString() ??
          json['vendor']?.toString() ??
          json['workshop']?.toString(),
      status: json['status']?.toString(),
    );
  }

  String get titleLabel {
    final desc = description?.trim();
    if (desc != null && desc.isNotEmpty) return desc;
    final type = serviceType?.trim();
    if (type != null && type.isNotEmpty) return type;
    return 'Service';
  }
}

class VehicleInsurance {
  final int id;
  final String? provider;
  final String? policyNumber;
  final String? coverageType;
  final String? startDate;
  final String? endDate;
  final double? premium;
  final String? status;
  final String? notes;

  const VehicleInsurance({
    required this.id,
    this.provider,
    this.policyNumber,
    this.coverageType,
    this.startDate,
    this.endDate,
    this.premium,
    this.status,
    this.notes,
  });

  factory VehicleInsurance.fromJson(Map<String, dynamic> json) {
    return VehicleInsurance(
      id: _asInt(json['id']) ?? 0,
      provider: json['provider']?.toString() ??
          json['insurer']?.toString() ??
          json['company']?.toString(),
      policyNumber: json['policy_number']?.toString() ??
          json['policy_no']?.toString(),
      coverageType: json['coverage_type']?.toString() ??
          json['type']?.toString(),
      startDate: json['start_date']?.toString() ??
          json['valid_from']?.toString(),
      endDate: json['end_date']?.toString() ??
          json['valid_to']?.toString() ??
          json['expiry_date']?.toString(),
      premium: _asDouble(json['premium']) ??
          _asDouble(json['cost']) ??
          _asDouble(json['amount']),
      status: json['status']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  String get titleLabel {
    final providerLabel = provider?.trim();
    if (providerLabel != null && providerLabel.isNotEmpty) {
      return providerLabel;
    }
    final coverage = coverageType?.trim();
    if (coverage != null && coverage.isNotEmpty) return coverage;
    return 'Insurance policy';
  }
}

class VehicleDocument {
  final int id;
  final String? name;
  final String? documentType;
  final String? url;
  final String? createdAt;
  final String? notes;

  const VehicleDocument({
    required this.id,
    this.name,
    this.documentType,
    this.url,
    this.createdAt,
    this.notes,
  });

  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: _asInt(json['id']) ?? 0,
      name: json['name']?.toString() ??
          json['file_name']?.toString() ??
          json['title']?.toString(),
      documentType: json['document_type']?.toString() ??
          json['type']?.toString(),
      url: json['url']?.toString() ??
          json['signed_url']?.toString() ??
          json['file_url']?.toString(),
      createdAt: json['created_at']?.toString() ??
          json['uploaded_at']?.toString(),
      notes: json['notes']?.toString() ?? json['description']?.toString(),
    );
  }

  String get titleLabel {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final t = documentType?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Document #$id';
  }
}

const vehicleDocumentTypes = <String>[
  'Registration',
  'Lease Agreement',
  'Insurance Policy',
  'Inspection Report',
  'Other',
];

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _parseDurationMinutes(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final match = RegExp(r'(\d+)').firstMatch(raw);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}
