import 'package:docelix_mobileapp/controllers/vehicles_controller.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late final VehiclesController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<VehiclesController>()) {
      Get.delete<VehiclesController>(force: true);
    }
    controller = Get.put(VehiclesController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<VehiclesController>()) {
      Get.delete<VehiclesController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Text(
          'Vehicles & Logbook',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => Get.toNamed('/FleetDashboardScreen'),
            icon: Icon(
              Icons.bar_chart_rounded,
              size: width * 0.045,
              color: colorsList.iconColor,
            ),
            label: Text(
              'Dashboard',
              style: TextStyle(
                color: colorsList.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: width * 0.032,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddVehicleSheet(context),
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Vehicle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              width * 0.045,
              width * 0.03,
              width * 0.045,
              width * 0.02,
            ),
            child: _SearchHeader(controller: controller),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.vehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: controller.refreshVehicles,
                child: controller.filteredVehicles.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: width * 0.25),
                          _EmptyState(
                            hasSearch: controller.searchQuery.value.isNotEmpty,
                            onClear: controller.clearSearch,
                            onAdd: () => _openAddVehicleSheet(context),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          width * 0.045,
                          0,
                          width * 0.045,
                          width * 0.28,
                        ),
                        itemCount: controller.filteredVehicles.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: width * 0.03),
                        itemBuilder: (context, index) {
                          final vehicle = controller.filteredVehicles[index];
                          return _VehicleCard(
                            vehicle: vehicle,
                            onTap: () => Get.toNamed(
                              '/VehicleDetailsScreen',
                              arguments: vehicle,
                            ),
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAddVehicleSheet(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _AddVehicleSheet(controller: controller),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.controller});

  final VehiclesController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        children: [
          Obx(
            () => Row(
              children: [
                Text(
                  '${controller.filteredVehicles.length} vehicle${controller.filteredVehicles.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (controller.isSearching.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (controller.searchQuery.value.isNotEmpty)
                  TextButton(
                    onPressed: controller.clearSearch,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          SizedBox(height: width * 0.025),
          Container(
            decoration: BoxDecoration(
              color: colorsList.colorBoxDecoration,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                controller.searchQuery.value = value;
                controller.loadVehicles(showLoader: false);
              },
              decoration: InputDecoration(
                hintText: 'Search by name, plate, brand...',
                hintStyle: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.032,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorsList.secondaryText,
                  size: width * 0.05,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: width * 0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle, required this.onTap});

  final VehicleModel vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorsList.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: TextStyle(
                            color: colorsList.primaryText,
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: width * 0.008),
                        Text(
                          vehicle.plateNumber?.isNotEmpty == true
                              ? vehicle.plateNumber!
                              : 'No plate',
                          style: TextStyle(
                            color: colorsList.secondaryText,
                            fontSize: width * 0.028,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.025,
                      vertical: width * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.isActive
                          ? const Color(0xFF12B886).withValues(alpha: 0.12)
                          : colorsList.secondaryText.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.statusLabel,
                      style: TextStyle(
                        color: vehicle.isActive
                            ? const Color(0xFF12B886)
                            : colorsList.secondaryText,
                        fontSize: width * 0.026,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.025),
              Wrap(
                spacing: width * 0.015,
                runSpacing: width * 0.015,
                children: [
                  _Chip(
                    label: vehicle.typeLabel,
                    color: const Color(0xFF3B82F6),
                  ),
                  _Chip(
                    label: vehicle.isInsured ? 'Insured' : 'Not insured',
                    color: vehicle.isInsured
                        ? const Color(0xFF12B886)
                        : colorsList.secondaryText,
                  ),
                ],
              ),
              SizedBox(height: width * 0.03),
              Row(
                children: [
                  Expanded(
                    child: _MetaBlock(
                      label: 'Brand / Model',
                      value: vehicle.brandModelLabel,
                    ),
                  ),
                  Expanded(
                    child: _MetaBlock(
                      label: 'Current KM',
                      value: vehicle.kmLabel,
                    ),
                  ),
                ],
              ),
              if (vehicle.year != null) ...[
                SizedBox(height: width * 0.025),
                _MetaBlock(label: 'Year', value: '${vehicle.year}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.025,
        vertical: width * 0.01,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: width * 0.026,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.mutedTextColor,
            fontSize: width * 0.024,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: width * 0.006),
        Text(
          value,
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width * 0.032,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearch,
    required this.onClear,
    required this.onAdd,
  });

  final bool hasSearch;
  final VoidCallback onClear;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: width * 0.16,
              color: const Color(0xFFCBD5E1),
            ),
            SizedBox(height: width * 0.04),
            Text(
              'No vehicles found',
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width * 0.042,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: width * 0.02),
            Text(
              hasSearch
                  ? 'No vehicles match your search.'
                  : 'Add your first vehicle to start tracking the fleet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorsList.secondaryText,
                fontSize: width * 0.032,
                height: 1.4,
              ),
            ),
            SizedBox(height: width * 0.04),
            if (hasSearch)
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear Search'),
              )
            else
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorsList.colorButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  const _AddVehicleSheet({required this.controller});

  final VehiclesController controller;

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: '${DateTime.now().year}');
  final _vinController = TextEditingController();
  final _kmController = TextEditingController(text: '0');

  String _vehicleType = 'car';
  bool _isInsured = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.createVehicle(
      name: _nameController.text,
      plateNumber: _plateController.text,
      vehicleType: _vehicleType,
      brand: _brandController.text,
      model: _modelController.text,
      year: int.tryParse(_yearController.text.trim()),
      vin: _vinController.text,
      currentKm: double.tryParse(_kmController.text.trim()) ?? 0,
      isInsured: _isInsured,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) await _close(true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.05,
        width * 0.04,
        width * 0.05,
        width * 0.05 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DDE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: width * 0.04),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add New Vehicle',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting ? null : () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Text(
                'Vehicle Details',
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: width * 0.03),
              _label('Vehicle Name', required: true),
              _field(
                controller: _nameController,
                hint: 'e.g. civic',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: width * 0.03),
              _label('Plate Number', required: true),
              _field(
                controller: _plateController,
                hint: 'e.g. BH636',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: width * 0.03),
              _label('Vehicle Type'),
              DropdownButtonFormField<String>(
                key: ValueKey(_vehicleType),
                initialValue: _vehicleType,
                isExpanded: true,
                decoration: _decoration(),
                items: vehicleTypeOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _vehicleType = value);
                      },
              ),
              SizedBox(height: width * 0.03),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Brand (Make)'),
                        _field(controller: _brandController, hint: 'Toyota'),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Model'),
                        _field(controller: _modelController, hint: 'X'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.03),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Year'),
                        _field(
                          controller: _yearController,
                          hint: '2026',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('VIN'),
                        _field(
                          controller: _vinController,
                          hint: 'Chassis number',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.045),
              Text(
                'Status & Mileage',
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: width * 0.03),
              _label('Current KM (Odometer)'),
              _field(
                controller: _kmController,
                hint: '0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              SizedBox(height: width * 0.02),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Insured',
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.033,
                  ),
                ),
                value: _isInsured,
                activeThumbColor: colorsList.colorButton,
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _isInsured = value),
              ),
              SizedBox(height: width * 0.04),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _close(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: colorsList.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.015),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width * 0.03,
            fontWeight: FontWeight.w600,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFE5484D),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final width = MediaQuery.of(context).size.width;
    return TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _decoration(hint: hint),
      style: TextStyle(
        color: colorsList.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: width * 0.033,
      ),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: colorsList.mutedTextColor,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: colorsList.colorBoxDecoration,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: colorsList.colorButton, width: 1.4),
      ),
    );
  }
}
