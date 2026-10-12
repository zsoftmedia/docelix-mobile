import 'package:docelix_mobileapp/controllers/vehicle_details_controller.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final VehicleDetailsController controller;
  late final TabController tabController;
  late final String _tag;

  static const _tabs = [
    'Overview',
    'Drivers',
    'Trip History',
    'Fuel Logs',
    'Services',
    'Insurance',
    'Documents',
  ];

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    final initial = arg is VehicleModel
        ? arg
        : const VehicleModel(
            id: 0,
            companyId: 0,
            name: 'Vehicle',
            vehicleType: 'car',
            status: 'active',
            currentKm: 0,
          );

    _tag = 'vehicle_${initial.id}';
    controller = Get.put(
      VehicleDetailsController(initialVehicle: initial),
      tag: _tag,
    );
    tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    Get.delete<VehicleDetailsController>(tag: _tag);
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
        scrolledUnderElevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.vehicle.value.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.042,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                controller.vehicle.value.plateNumber?.isNotEmpty == true
                    ? controller.vehicle.value.plateNumber!
                    : 'No plate',
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width * 0.026,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(
            () => controller.isLoading.value
                ? Padding(
                    padding: EdgeInsets.only(right: width * 0.04),
                    child: SizedBox(
                      width: width * 0.05,
                      height: width * 0.05,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Refresh',
                    onPressed: controller.refreshAll,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colorsList.iconColor,
                      size: width * 0.055,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colorsList.colorWhite,
            padding: EdgeInsets.fromLTRB(
              width * 0.04,
              0,
              width * 0.04,
              width * 0.03,
            ),
            child: _SummaryCard(controller: controller),
          ),
          Container(
            color: colorsList.colorWhite,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: width * 0.02),
              labelPadding: EdgeInsets.symmetric(horizontal: width * 0.035),
              labelColor: colorsList.colorButton,
              unselectedLabelColor: colorsList.mutedTextColor,
              indicatorColor: colorsList.colorButton,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: colorsList.borderColor,
              labelStyle: TextStyle(
                fontSize: width * 0.032,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: width * 0.032,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs.map((t) => Tab(height: 40, text: t)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _OverviewTab(controller: controller),
                _DriversTab(controller: controller),
                _TripsTab(controller: controller),
                _FuelTab(controller: controller),
                _ServicesTab(controller: controller),
                _InsuranceTab(controller: controller),
                _DocumentsTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});

  final VehicleDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final vehicle = controller.vehicle.value;
      final statusColor = vehicle.isActive
          ? const Color(0xFF16A34A)
          : colorsList.secondaryText;

      return Container(
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: colorsList.colorBoxDecoration.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorsList.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.1,
              height: width * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: colorsList.borderColor),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: colorsList.colorButton,
                size: width * 0.048,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.brandModelLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorsList.primaryText,
                      fontSize: width * 0.034,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: width * 0.01),
                  Wrap(
                    spacing: width * 0.02,
                    runSpacing: width * 0.01,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MiniChip(label: vehicle.statusLabel, color: statusColor),
                      Text(
                        vehicle.typeLabel,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.026,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '·',
                        style: TextStyle(color: colorsList.mutedTextColor),
                      ),
                      Text(
                        vehicle.kmLabel,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.026,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: width * 0.006,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: width * 0.024,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.controller});

  final VehicleDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final vehicle = controller.vehicle.value;

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            _SectionCard(
              title: 'Vehicle details',
              children: [
                _MetaRow(label: 'Brand', value: _dash(vehicle.brand)),
                _MetaRow(label: 'Model', value: _dash(vehicle.model)),
                _MetaRow(label: 'Year', value: vehicle.year?.toString() ?? '—'),
                _MetaRow(label: 'VIN', value: _dash(vehicle.vin)),
                _MetaRow(label: 'Type', value: vehicle.typeLabel),
                _MetaRow(
                  label: 'VAT class',
                  value: vehicle.vatClassificationLabel,
                ),
                _MetaRow(
                  label: 'Insured',
                  value: vehicle.isInsured ? 'Yes' : 'No',
                ),
              ],
            ),
            SizedBox(height: width * 0.035),
            _SectionCard(
              title: 'Purchase',
              children: [
                _MetaRow(
                  label: 'Price',
                  value: controller.formatMoney(vehicle.purchasePrice),
                ),
                _MetaRow(
                  label: 'Date',
                  value: controller.formatDate(vehicle.purchaseDate),
                ),
                _MetaRow(
                  label: 'Linked asset',
                  value: vehicle.assetId != null ? '#${vehicle.assetId}' : '—',
                ),
              ],
            ),
            SizedBox(height: width * 0.035),
            _SectionCard(
              title: 'Record',
              children: [
                _MetaRow(
                  label: 'Created',
                  value: controller.formatDateTime(vehicle.createdAt),
                ),
                _MetaRow(
                  label: 'Updated',
                  value: controller.formatDateTime(vehicle.updatedAt),
                ),
                _MetaRow(label: 'Vehicle ID', value: '#${vehicle.id}'),
              ],
            ),
          ],
        ),
      );
    });
  }

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }
}

class _DriversTab extends StatelessWidget {
  const _DriversTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openAssignDriver(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _AssignDriverSheet(controller: controller),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VehicleDriverAssignment assignment,
  ) async {
    final name = assignment.driverName?.trim().isNotEmpty == true
        ? assignment.driverName!
        : 'this driver';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove assignment'),
        content: Text('Remove $name from this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: colorsList.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteAssignment(assignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final assignments = controller.vehicle.value.vehicleDriverAssignments;
      final countLabel =
          '${assignments.length} driver${assignments.length == 1 ? '' : 's'}';

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.loadVehicle(),
            controller.loadDrivers(),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Drivers',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        countLabel,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openAssignDriver(context),
                  icon: Icon(
                    Icons.add_rounded,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Assign Driver',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (assignments.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.person_outline_rounded,
                  message: 'No driver assignments',
                ),
              )
            else
              ...assignments.map((assignment) {
                final name = assignment.driverName?.trim().isNotEmpty == true
                    ? assignment.driverName!
                    : 'Driver #${assignment.driverId ?? assignment.id}';

                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _DriverAssignmentCard(
                    name: name,
                    assignedAt: controller.formatDate(
                      assignment.assignedAt ?? assignment.startDate,
                    ),
                    isPrimary: assignment.isPrimary,
                    onDelete: controller.isDeletingAssignment.value
                        ? null
                        : () => _confirmDelete(context, assignment),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _DriverAssignmentCard extends StatelessWidget {
  const _DriverAssignmentCard({
    required this.name,
    required this.assignedAt,
    required this.isPrimary,
    required this.onDelete,
  });

  final String name;
  final String assignedAt;
  final bool isPrimary;
  final VoidCallback? onDelete;

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
      child: Row(
        children: [
          Container(
            width: width * 0.1,
            height: width * 0.1,
            decoration: BoxDecoration(
              color: colorsList.colorBoxDecoration,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: colorsList.colorButton,
              size: width * 0.05,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.034,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: width * 0.01),
                Wrap(
                  spacing: width * 0.02,
                  runSpacing: width * 0.01,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (isPrimary)
                      _MiniChip(
                        label: 'Primary',
                        color: colorsList.colorButton,
                      ),
                    Text(
                      'Assigned $assignedAt',
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.026,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Remove',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorsList.red,
              size: width * 0.055,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignDriverSheet extends StatefulWidget {
  const _AssignDriverSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_AssignDriverSheet> createState() => _AssignDriverSheetState();
}

class _AssignDriverSheetState extends State<_AssignDriverSheet> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _createNew = true;
  int? _selectedDriverId;
  bool _isPrimary = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadDrivers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_createNew) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    } else if (_selectedDriverId == null) {
      Get.snackbar(
        'Select a driver',
        'Choose an existing driver to assign.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.assignDriver(
      existingDriverId: _createNew ? null : _selectedDriverId,
      newDriverName: _createNew ? _nameController.text : null,
      isPrimary: _isPrimary,
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
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Assign Driver',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                padding: EdgeInsets.all(width * 0.01),
                decoration: BoxDecoration(
                  color: colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeChip(
                        label: 'Select Existing',
                        selected: !_createNew,
                        onTap: () => setState(() => _createNew = false),
                      ),
                    ),
                    Expanded(
                      child: _ModeChip(
                        label: 'Create New',
                        selected: _createNew,
                        onTap: () => setState(() => _createNew = true),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: _createNew
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Driver Name',
                              style: TextStyle(
                                color: colorsList.secondaryText,
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: width * 0.02),
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'e.g. John Doe',
                              hintStyle: TextStyle(
                                color: colorsList.mutedTextColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorsList.borderColor,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.035,
                                vertical: width * 0.03,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Driver name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Obx(() {
                        final assignedIds = widget
                            .controller
                            .vehicle
                            .value
                            .vehicleDriverAssignments
                            .map((a) => a.driverId)
                            .whereType<int>()
                            .toSet();
                        final companyDrivers = widget.controller.drivers;

                        if (widget.controller.isLoadingDrivers.value &&
                            companyDrivers.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (companyDrivers.isEmpty) {
                          return Text(
                            'No drivers in the company yet. Create a new one.',
                            style: TextStyle(
                              color: colorsList.secondaryText,
                              fontSize: width * 0.032,
                            ),
                          );
                        }

                        return DropdownButtonFormField<int>(
                          initialValue:
                              companyDrivers.any(
                                (d) => d.id == _selectedDriverId,
                              )
                              ? _selectedDriverId
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Driver',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: colorsList.borderColor,
                              ),
                            ),
                          ),
                          items: companyDrivers.map((d) {
                            final alreadyOnVehicle = assignedIds.contains(d.id);
                            return DropdownMenuItem<int>(
                              value: d.id,
                              enabled: !alreadyOnVehicle,
                              child: Text(
                                alreadyOnVehicle
                                    ? '${d.name} (already assigned)'
                                    : d.name,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null && assignedIds.contains(value)) {
                              return;
                            }
                            setState(() => _selectedDriverId = value);
                          },
                        );
                      }),
              ),
              SizedBox(height: width * 0.025),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Primary driver',
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _isPrimary,
                activeThumbColor: colorsList.colorButton,
                onChanged: (value) => setState(() => _isPrimary = value),
              ),
              SizedBox(height: width * 0.03),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _close(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorsList.primaryText,
                        side: BorderSide(color: colorsList.borderColor),
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Assign Driver',
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
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: selected ? colorsList.colorButton : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: width * 0.028),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : colorsList.colorButton,
              fontSize: width * 0.03,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TripsTab extends StatelessWidget {
  const _TripsTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openAddTrip(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _AddTripSheet(controller: controller),
    );
  }

  Future<void> _confirmDelete(BuildContext context, VehicleTrip trip) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete trip'),
        content: Text('Delete trip ${trip.routeLabel}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: colorsList.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteTrip(trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingTrips.value && controller.trips.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final trips = controller.trips;
      final totalDistance = trips.fold<double>(
        0,
        (sum, trip) => sum + (trip.distanceKm ?? 0),
      );
      final totalDuration = trips.fold<int>(
        0,
        (sum, trip) => sum + (trip.durationMinutes ?? 0),
      );

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.loadLocations(),
            controller.loadTrips(),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip History',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${trips.length} trip${trips.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openAddTrip(context),
                  icon: Icon(
                    Icons.add_rounded,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Add Trip',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (trips.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.route_outlined,
                  message: 'No trip history',
                ),
              )
            else ...[
              ...trips.map((trip) {
                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _TripCard(
                    trip: trip,
                    dateLabel: controller.formatDate(trip.date),
                    distanceLabel: controller.formatKm(trip.distanceKm),
                    reimbursementLabel: trip.reimbursement == null
                        ? null
                        : controller.formatMoney(trip.reimbursement),
                    onDelete: controller.isDeletingTrip.value
                        ? null
                        : () => _confirmDelete(context, trip),
                  ),
                );
              }),
              Container(
                padding: EdgeInsets.all(width * 0.035),
                decoration: BoxDecoration(
                  color: colorsList.colorBoxDecoration,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total (all trips)',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.03,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.formatKm(totalDistance)} · $totalDuration min',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.dateLabel,
    required this.distanceLabel,
    required this.reimbursementLabel,
    required this.onDelete,
  });

  final VehicleTrip trip;
  final String dateLabel;
  final String distanceLabel;
  final String? reimbursementLabel;
  final VoidCallback? onDelete;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.routeLabel,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.034,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: width * 0.012),
                Text(
                  [
                    dateLabel,
                    if (trip.driverName?.trim().isNotEmpty == true)
                      trip.driverName!,
                    trip.durationLabel,
                    if (reimbursementLabel != null) reimbursementLabel!,
                  ].join(' · '),
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.027,
                  ),
                ),
                if (trip.purpose?.trim().isNotEmpty == true) ...[
                  SizedBox(height: width * 0.01),
                  Text(
                    trip.purpose!,
                    style: TextStyle(
                      color: colorsList.mutedTextColor,
                      fontSize: width * 0.026,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distanceLabel,
                style: TextStyle(
                  color: colorsList.primaryText,
                  fontSize: width * 0.032,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorsList.red,
                  size: width * 0.055,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddTripSheet extends StatefulWidget {
  const _AddTripSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends State<_AddTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _purposeController = TextEditingController();

  DateTime _tripDate = DateTime.now();
  VehicleDistanceResult? _distance;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tripDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _tripDate = picked);
    }
  }

  Future<void> _calculate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await widget.controller.calculateDistance(
      startAddress: _fromController.text,
      destination: _toController.text,
    );
    if (!mounted) return;
    setState(() => _distance = result);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_distance == null) {
      Get.snackbar(
        'Calculate distance',
        'Calculate distance before saving the trip.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.createTrip(
      tripDate: _tripDate,
      fromAddress: _fromController.text,
      toAddress: _toController.text,
      purpose: _purposeController.text,
      distance: _distance!,
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
    final dateLabel =
        '${_tripDate.day.toString().padLeft(2, '0')}/${_tripDate.month.toString().padLeft(2, '0')}/${_tripDate.year}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Trip',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Date', required: true),
                    SizedBox(height: width * 0.015),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: _inputDecoration(width),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  color: colorsList.primaryText,
                                  fontSize: width * 0.033,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: width * 0.045,
                              color: colorsList.iconColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'From Location'),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _fromController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(width),
                      onChanged: (_) {
                        if (_distance != null) {
                          setState(() => _distance = null);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'From location is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'To Location'),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _toController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(width),
                      onChanged: (_) {
                        if (_distance != null) {
                          setState(() => _distance = null);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'To location is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    Obx(() {
                      final loading =
                          widget.controller.isCalculatingDistance.value;
                      return OutlinedButton(
                        onPressed: loading ? null : _calculate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF16A34A),
                          side: const BorderSide(color: Color(0xFF16A34A)),
                          minimumSize: Size(double.infinity, width * 0.11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: loading
                            ? SizedBox(
                                width: width * 0.05,
                                height: width * 0.05,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Calculate Distance',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      );
                    }),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Purpose'),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _purposeController,
                      maxLines: 3,
                      decoration: _inputDecoration(width),
                    ),
                    if (_distance != null) ...[
                      SizedBox(height: width * 0.03),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(width * 0.035),
                        decoration: BoxDecoration(
                          color: colorsList.colorBoxDecoration,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL DISTANCE',
                                    style: TextStyle(
                                      color: colorsList.mutedTextColor,
                                      fontSize: width * 0.024,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: width * 0.01),
                                  Text(
                                    _distance!.distanceText,
                                    style: TextStyle(
                                      color: colorsList.primaryText,
                                      fontSize: width * 0.034,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EST. DURATION',
                                    style: TextStyle(
                                      color: colorsList.mutedTextColor,
                                      fontSize: width * 0.024,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: width * 0.01),
                                  Text(
                                    _distance!.durationText,
                                    style: TextStyle(
                                      color: colorsList.primaryText,
                                      fontSize: width * 0.034,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _close(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorsList.primaryText,
                        side: BorderSide(color: colorsList.borderColor),
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Trip',
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

  InputDecoration _inputDecoration(double width) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorsList.borderColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.035,
        vertical: width * 0.03,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          color: colorsList.secondaryText,
          fontSize: width * 0.03,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (required)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
        ],
      ),
    );
  }
}

class _FuelTab extends StatelessWidget {
  const _FuelTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openLogFuel(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _LogFuelSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingFuel.value && controller.fuelLogs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final logs = controller.fuelLogs;

      return RefreshIndicator(
        onRefresh: controller.loadFuelLogs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fuel History',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${logs.length} fuel log${logs.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openLogFuel(context),
                  icon: Icon(
                    Icons.local_gas_station_rounded,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Log Fuel',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (logs.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.local_gas_station_outlined,
                  message: 'No fuel logs',
                ),
              )
            else
              ...logs.map((log) {
                final costPerL = log.costPerLiter;
                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _ListCard(
                    title: controller.formatDate(log.date),
                    subtitle: [
                      controller.formatLiters(log.liters),
                      controller.formatKm(log.odometerKm),
                      if (costPerL != null)
                        '${controller.formatMoney(costPerL)}/L',
                    ].join(' · '),
                    trailing: Text(
                      controller.formatMoney(log.cost),
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _LogFuelSheet extends StatefulWidget {
  const _LogFuelSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_LogFuelSheet> createState() => _LogFuelSheetState();
}

class _LogFuelSheetState extends State<_LogFuelSheet> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final km = widget.controller.vehicle.value.currentKm;
    _odometerController.text = km % 1 == 0
        ? km.toInt().toString()
        : km.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _litersController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickReceiptSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final width = MediaQuery.of(context).size.width;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_camera_outlined,
                    color: colorsList.colorButton,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colorsList.colorButton,
                  ),
                  title: const Text('Upload from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    await _uploadReceipt(source);
  }

  Future<void> _uploadReceipt(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    final ok = await widget.controller.uploadFuelReceipt(
      filePath: file.path,
      fileName: file.name,
    );
    if (!mounted) return;
    if (ok) await _close(true);
  }

  Future<void> _saveManual() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final liters = double.tryParse(_litersController.text.trim());
    final cost = double.tryParse(_costController.text.trim());
    final odometer = double.tryParse(_odometerController.text.trim());

    if (liters == null || cost == null || odometer == null) {
      Get.snackbar(
        'Invalid values',
        'Enter valid numbers for liters, cost, and odometer.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.createFuelLog(
      date: _date,
      liters: liters,
      cost: cost,
      odometer: odometer,
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
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    final currency = widget.controller.currencySymbol.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Log Fuel',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorsList.colorButton.withValues(alpha: 0.35),
                    style: BorderStyle.solid,
                  ),
                  color: colorsList.colorButton.withValues(alpha: 0.04),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: colorsList.colorButton,
                      size: width * 0.08,
                    ),
                    SizedBox(height: width * 0.02),
                    Text(
                      'Smart Receipt Upload',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.036,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: width * 0.015),
                    Text(
                      'Take a photo of your fuel receipt and we\'ll automatically extract the cost and date and save it to your incoming invoices ledger.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width * 0.028,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: width * 0.03),
                    Obx(() {
                      final uploading =
                          widget.controller.isUploadingFuelReceipt.value;
                      return ElevatedButton.icon(
                        onPressed: uploading || _isSubmitting
                            ? null
                            : _pickReceiptSource,
                        icon: uploading
                            ? SizedBox(
                                width: width * 0.04,
                                height: width * 0.04,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          uploading
                              ? 'Uploading…'
                              : 'Take Photo / Upload Receipt',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsList.colorButton,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size(double.infinity, width * 0.11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: width * 0.04),
              Text(
                'OR ENTER MANUALLY:',
                style: TextStyle(
                  color: colorsList.mutedTextColor,
                  fontSize: width * 0.028,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: width * 0.025),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Date', required: true),
                    SizedBox(height: width * 0.015),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: _fuelInputDecoration(width),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  color: colorsList.primaryText,
                                  fontSize: width * 0.033,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: width * 0.045,
                              color: colorsList.iconColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Amount (Liters)', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _litersController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fuelInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Liters are required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Total Cost ($currency)', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fuelInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Cost is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Odometer (KM)', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _odometerController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fuelInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Odometer is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ||
                              widget.controller.isUploadingFuelReceipt.value
                          ? null
                          : () => _close(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorsList.primaryText,
                        side: BorderSide(color: colorsList.borderColor),
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ||
                              widget.controller.isUploadingFuelReceipt.value
                          ? null
                          : _saveManual,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Manually',
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

  InputDecoration _fuelInputDecoration(double width) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorsList.borderColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.035,
        vertical: width * 0.03,
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openLogService(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _LogServiceSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingServices.value && controller.services.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = controller.services;

      return RefreshIndicator(
        onRefresh: controller.loadServices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service & Maintenance',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${items.length} service${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openLogService(context),
                  icon: Icon(
                    Icons.build_rounded,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Log Service',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (items.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.build_outlined,
                  message: 'No service records',
                ),
              )
            else
              ...items.map((service) {
                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _ListCard(
                    title: service.titleLabel,
                    subtitle: [
                      controller.formatDate(service.date),
                      controller.formatKm(service.odometerKm),
                    ].join(' · '),
                    trailing: Text(
                      controller.formatMoney(service.cost),
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _LogServiceSheet extends StatefulWidget {
  const _LogServiceSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_LogServiceSheet> createState() => _LogServiceSheetState();
}

class _LogServiceSheetState extends State<_LogServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final km = widget.controller.vehicle.value.currentKm;
    _odometerController.text = km % 1 == 0
        ? km.toInt().toString()
        : km.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cost = double.tryParse(_costController.text.trim());
    final odometer = double.tryParse(_odometerController.text.trim());
    if (cost == null || odometer == null) {
      Get.snackbar(
        'Invalid values',
        'Enter valid numbers for cost and odometer.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.createServiceLog(
      date: _date,
      description: _descriptionController.text,
      cost: cost,
      odometer: odometer,
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
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    final currency = widget.controller.currencySymbol.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Log Service / Maintenance',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Date', required: true),
                    SizedBox(height: width * 0.015),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: _serviceInputDecoration(width),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  color: colorsList.primaryText,
                                  fontSize: width * 0.033,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: width * 0.045,
                              color: colorsList.iconColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Description', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _serviceInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Total Cost ($currency)', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _serviceInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Cost is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Odometer (KM)', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _odometerController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _serviceInputDecoration(width),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Odometer is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => _close(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorsList.primaryText,
                        side: BorderSide(color: colorsList.borderColor),
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: width * 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: width * 0.05,
                              height: width * 0.05,
                              child: const CircularProgressIndicator(
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

  InputDecoration _serviceInputDecoration(double width) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colorsList.borderColor),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.035,
        vertical: width * 0.03,
      ),
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  const _InsuranceTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openAddPolicy(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _LogInsuranceSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingInsurance.value &&
          controller.insurancePolicies.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final policies = controller.insurancePolicies;

      return RefreshIndicator(
        onRefresh: controller.loadInsurance,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insurance Policies',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${policies.length} polic${policies.length == 1 ? 'y' : 'ies'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openAddPolicy(context),
                  icon: Icon(
                    Icons.verified_user_outlined,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Add Policy',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (policies.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.health_and_safety_outlined,
                  message: 'No insurance records',
                ),
              )
            else
              ...policies.map((policy) {
                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _ListCard(
                    title: policy.titleLabel,
                    subtitle: [
                      if (policy.policyNumber?.trim().isNotEmpty == true)
                        policy.policyNumber!,
                      '${controller.formatDate(policy.startDate)} → ${controller.formatDate(policy.endDate)}',
                    ].join(' · '),
                    trailing: Text(
                      controller.formatMoney(policy.premium),
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _LogInsuranceSheet extends StatefulWidget {
  const _LogInsuranceSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_LogInsuranceSheet> createState() => _LogInsuranceSheetState();
}

class _LogInsuranceSheetState extends State<_LogInsuranceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _policyController = TextEditingController();
  final _costController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _providerController.dispose();
    _policyController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cost = double.tryParse(_costController.text.trim());
    if (cost == null) {
      Get.snackbar(
        'Invalid cost',
        'Enter a valid premium cost.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.controller.createInsurancePolicy(
      provider: _providerController.text,
      policyNumber: _policyController.text,
      cost: cost,
      startDate: _startDate,
      endDate: _endDate,
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
    final currency = widget.controller.currencySymbol.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Log Insurance Policy',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Provider', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _providerController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _sheetInputDecoration(width),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Policy Number'),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _policyController,
                      decoration: _sheetInputDecoration(width),
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(
                      text: 'Premium Cost ($currency)',
                      required: true,
                    ),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _sheetInputDecoration(width),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Start Date', required: true),
                    SizedBox(height: width * 0.015),
                    _DateField(
                      label: _fmt(_startDate),
                      onTap: _pickStart,
                      width: width,
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'End Date'),
                    SizedBox(height: width * 0.015),
                    _DateField(
                      label: _endDate == null ? 'Select date' : _fmt(_endDate!),
                      onTap: _pickEnd,
                      width: width,
                      muted: _endDate == null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              _SheetActions(
                isSubmitting: _isSubmitting,
                onCancel: () => _close(),
                onSave: _save,
                saveLabel: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({required this.controller});

  final VehicleDetailsController controller;

  Future<void> _openUpload(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorsList.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _UploadDocumentSheet(controller: controller),
    );
  }

  void _openDocumentPreview(VehicleDocument document) {
    final url = document.url?.trim();
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No preview URL for this document.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final lower = url.toLowerCase();
    final isPdf =
        lower.contains('.pdf') ||
        (document.documentType?.toLowerCase().contains('pdf') ?? false);
    final isImage = [
      '.png',
      '.jpg',
      '.jpeg',
      '.webp',
      '.heic',
      '.gif',
    ].any(lower.contains);

    Get.to(
      () => Scaffold(
        backgroundColor: colorsList.backgroundColor,
        appBar: AppBar(
          backgroundColor: colorsList.colorWhite,
          title: Text(
            document.titleLabel,
            style: TextStyle(
              color: colorsList.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: isPdf
            ? SfPdfViewer.network(url)
            : isImage
            ? InteractiveViewer(
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => _UrlFallback(url: url),
                  ),
                ),
              )
            : _UrlFallback(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      if (controller.isLoadingDocuments.value && controller.documents.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = controller.documents;

      return RefreshIndicator(
        onRefresh: controller.loadDocuments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.04,
            width * 0.035,
            width * 0.04,
            width * 0.08,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Documents',
                        style: TextStyle(
                          color: colorsList.primaryText,
                          fontSize: width * 0.036,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${docs.length} document${docs.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openUpload(context),
                  icon: Icon(
                    Icons.upload_file_outlined,
                    size: width * 0.045,
                    color: colorsList.colorButton,
                  ),
                  label: Text(
                    'Upload Document',
                    style: TextStyle(
                      color: colorsList.colorButton,
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.02),
            if (docs.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.12),
                child: _EmptyState(
                  icon: Icons.description_outlined,
                  message: 'No documents',
                ),
              )
            else
              ...docs.map((doc) {
                return Padding(
                  padding: EdgeInsets.only(bottom: width * 0.03),
                  child: _ListCard(
                    title: doc.titleLabel,
                    subtitle: [
                      if (doc.documentType?.trim().isNotEmpty == true)
                        doc.documentType!,
                      controller.formatDate(doc.createdAt),
                    ].join(' · '),
                    trailing: Text(
                      'View File',
                      style: TextStyle(
                        color: colorsList.colorButton,
                        fontSize: width * 0.028,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => _openDocumentPreview(doc),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _UploadDocumentSheet extends StatefulWidget {
  const _UploadDocumentSheet({required this.controller});

  final VehicleDetailsController controller;

  @override
  State<_UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<_UploadDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  String _documentType = vehicleDocumentTypes.last;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
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
    final ok = await widget.controller.createVehicleDocument(
      name: _nameController.text,
      documentType: _documentType,
      fileUrl: _urlController.text,
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
        width * 0.045,
        width * 0.035,
        width * 0.045,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Upload Document',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: width * 0.02),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Document Name', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _sheetInputDecoration(width),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'Document Type'),
                    SizedBox(height: width * 0.015),
                    DropdownButtonFormField<String>(
                      initialValue: _documentType,
                      decoration: _sheetInputDecoration(width),
                      items: vehicleDocumentTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _documentType = value);
                        }
                      },
                    ),
                    SizedBox(height: width * 0.03),
                    _FieldLabel(text: 'File URL', required: true),
                    SizedBox(height: width * 0.015),
                    TextFormField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      decoration: _sheetInputDecoration(width),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final uri = Uri.tryParse(v.trim());
                        if (uri == null ||
                            !(uri.isScheme('http') || uri.isScheme('https'))) {
                          return 'Enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: width * 0.015),
                    Text(
                      'Provide a valid URL to the document (Temporary implementation)',
                      style: TextStyle(
                        color: colorsList.mutedTextColor,
                        fontSize: width * 0.026,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: width * 0.035),
              _SheetActions(
                isSubmitting: _isSubmitting,
                onCancel: () => _close(),
                onSave: _save,
                saveLabel: 'Save',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.onTap,
    required this.width,
    this.muted = false,
  });

  final String label;
  final VoidCallback onTap;
  final double width;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: _sheetInputDecoration(width),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: muted
                      ? colorsList.mutedTextColor
                      : colorsList.primaryText,
                  fontSize: width * 0.033,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: width * 0.045,
              color: colorsList.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorsList.primaryText,
              side: BorderSide(color: colorsList.borderColor),
              padding: EdgeInsets.symmetric(vertical: width * 0.035),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorsList.colorButton,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: width * 0.035),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: width * 0.05,
                    height: width * 0.05,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    saveLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}

class _UrlFallback extends StatelessWidget {
  const _UrlFallback({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          url,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorsList.secondaryText),
        ),
      ),
    );
  }
}

InputDecoration _sheetInputDecoration(double width) {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colorsList.borderColor),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: width * 0.035,
      vertical: width * 0.03,
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorsList.primaryText,
              fontSize: width * 0.034,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: width * 0.015),
          ...children,
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.014),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.32,
            child: Text(
              label,
              style: TextStyle(
                color: colorsList.mutedTextColor,
                fontSize: width * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width * 0.032,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(width * 0.035),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorsList.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width * 0.034,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      SizedBox(height: width * 0.01),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width * 0.027,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: width * 0.025),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Icon(icon, size: width * 0.12, color: colorsList.mutedTextColor),
        SizedBox(height: width * 0.03),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width * 0.034,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
