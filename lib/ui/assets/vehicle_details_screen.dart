import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/vehicle_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/vehicle_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

double _designWidth(BuildContext context) {
  final rs = context.rs;
  return rs.isPhone ? rs.width : ResponsiveBreakpoints.designWidth * rs.scale;
}

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
    final width = _designWidth(context);

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
                  fontSize: width.fontSizeW(0.042),
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                controller.vehicle.value.plateNumber?.isNotEmpty == true
                    ? controller.vehicle.value.plateNumber!
                    : 'No plate',
                style: TextStyle(
                  color: colorsList.secondaryText,
                  fontSize: width.fontSizeW(0.026),
                  fontWeight: FontWeight.normal,
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
            child: ResponsivePage(
              padding: EdgeInsets.fromLTRB(
                context.rs.isPhone ? width * 0.04 : context.rs.pagePaddingH,
                0,
                context.rs.isPhone ? width * 0.04 : context.rs.pagePaddingH,
                width * 0.03,
              ),
              child: _SummaryCard(controller: controller),
            ),
          ),
          Container(
            width: double.infinity,
            color: colorsList.colorWhite,
            child: ResponsivePage(
              padding: EdgeInsets.zero,
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
                  fontSize: width.fontSizeW(0.032),
                  fontWeight: FontWeight.normal,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: width.fontSizeW(0.032),
                  fontWeight: FontWeight.normal,
                ),
                tabs: _tabs.map((t) => Tab(height: 40, text: t)).toList(),
              ),
            ),
          ),
          Expanded(
            child: ResponsivePage(
              padding: EdgeInsets.zero,
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
    final width = _designWidth(context);

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
                      fontSize: width.fontSizeW(0.034),
                      fontWeight: FontWeight.normal,
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
                          fontSize: width.fontSizeW(0.026),
                          fontWeight: FontWeight.normal,
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
                          fontSize: width.fontSizeW(0.026),
                          fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
          fontSize: width.fontSizeW(0.024),
          fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _AssignDriverSheet(controller: controller),
        ),
      ),
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
      ResponsiveDialogBody(
        child: AlertDialog(
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
      ),
    );

    if (confirmed == true) {
      await controller.deleteAssignment(assignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        countLabel,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
    final width = _designWidth(context);

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
                    fontSize: width.fontSizeW(0.034),
                    fontWeight: FontWeight.normal,
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
                        fontSize: width.fontSizeW(0.026),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*IconButton(
            onPressed: onDelete,
            tooltip: 'Remove',
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorsList.red,
              size: width * 0.055,
            ),
          ),*/
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
      AppSnackbar.error(
          title: 'Select a driver',
          message: 'Choose an existing driver to assign.');
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
    final width = _designWidth(context);
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
                        fontSize: width.fontSizeW(0.042),
                        fontWeight: FontWeight.normal,
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
                                fontSize: width.fontSizeW(0.03),
                                fontWeight: FontWeight.normal,
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
                              fontSize: width.fontSizeW(0.032),
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
                    fontSize: width.fontSizeW(0.033),
                    fontWeight: FontWeight.normal,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.normal),
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
    final width = _designWidth(context);

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
              fontSize: width.fontSizeW(0.03),
              fontWeight: FontWeight.normal,
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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _AddTripSheet(controller: controller),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, VehicleTrip trip) async {
    final confirmed = await Get.dialog<bool>(
      ResponsiveDialogBody(
        child: AlertDialog(
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
      ),
    );

    if (confirmed == true) {
      await controller.deleteTrip(trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${trips.length} trip${trips.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
                          fontSize: width.fontSizeW(0.03),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.formatKm(totalDistance)} · $totalDuration min',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width.fontSizeW(0.03),
                        fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
                    fontSize: width.fontSizeW(0.034),
                    fontWeight: FontWeight.normal,
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
                    fontSize: width.fontSizeW(0.027),
                  ),
                ),
                if (trip.purpose?.trim().isNotEmpty == true) ...[
                  SizedBox(height: width * 0.01),
                  Text(
                    trip.purpose!,
                    style: TextStyle(
                      color: colorsList.mutedTextColor,
                      fontSize: width.fontSizeW(0.026),
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
                  fontSize: width.fontSizeW(0.032),
                  fontWeight: FontWeight.normal,
                ),
              ),
              /*IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorsList.red,
                  size: width * 0.055,
                ),
              ),*/
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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.resetTripForm();
  }

  Widget _buildHighlightedText(PlaceSuggestion suggestion) {
    final text = suggestion.mainText;
    if (suggestion.matches.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 13, color: colorsList.primaryText));
    }

    final match = suggestion.matches.first;
    final start = match.start.clamp(0, text.length);
    final end = match.end.clamp(start, text.length);

    final before = text.substring(0, start);
    final matched = text.substring(start, end);
    final after = text.substring(end);

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 13, color: colorsList.primaryText),
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          if (matched.isNotEmpty)
            TextSpan(
              text: matched,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
    );
  }

  Widget _buildOdometerComparisonBanner() {
    return Obx(() {
      final routeResult = widget.controller.calculatedDistance.value;
      final routeKm = routeResult?.distanceKm ?? 0.0;

      final startOdo = double.tryParse(widget.controller.tripStartOdometerController.text.trim()) ?? 0.0;
      final endOdo = double.tryParse(widget.controller.tripEndOdometerController.text.trim()) ?? 0.0;
      final odoKm = (endOdo > startOdo) ? (endOdo - startOdo) : 0.0;

      if (routeKm <= 0) {
        return const SizedBox.shrink();
      }

      if (odoKm <= 0) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calculated route: ${routeResult!.distanceText} (estimate only).',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        );
      }

      final diffKm = (odoKm - routeKm).abs();
      final diffPercent = (diffKm / routeKm) * 100.0;

      if (diffPercent > 30.0) {
        final String formattedOdo = _formatNum(odoKm);
        final String formattedRoute = routeResult!.distanceText;
        final String formattedDiff = _formatNum(diffPercent);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEFCE8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE047)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFA16207)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'The odometer shows $formattedOdo km, the calculated route $formattedRoute ($formattedDiff % difference). Please check the readings.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFA16207), height: 1.35),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Calculated route: ${routeResult!.distanceText} (estimate only).',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _close([bool saved = false]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  Future<void> _pickDate({bool isArrival = false}) async {
    final initial = isArrival
        ? (widget.controller.tripArrivalDate.value ?? widget.controller.tripDate.value ?? DateTime.now())
        : (widget.controller.tripDate.value ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isArrival) {
        widget.controller.tripArrivalDate.value = picked;
      } else {
        widget.controller.tripDate.value = picked;
      }
    }
  }

  Future<void> _pickTime({bool isEnd = false}) async {
    final initial = isEnd
        ? (widget.controller.tripEndTime.value ?? TimeOfDay.now())
        : (widget.controller.tripStartTime.value ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      if (isEnd) {
        widget.controller.tripEndTime.value = picked;
      } else {
        widget.controller.tripStartTime.value = picked;
      }
    }
  }

  Future<void> _calculate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await widget.controller.calculateDistance(
      startAddress: widget.controller.tripFromController.text,
      destination: widget.controller.tripToController.text,
    );
    if (!mounted) return;
    widget.controller.calculatedDistance.value = result;
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (widget.controller.tripPurposeController.text.trim().isEmpty) {
      widget.controller.tripPurposeController.text =
          widget.controller.tripType.value == 'Private'
              ? 'Private Trip'
              : 'Business Trip';
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter starting and destination addresses.',
      );
      return;
    }

    final startOdo = double.tryParse(widget.controller.tripStartOdometerController.text.trim()) ?? 0;
    final endOdo = double.tryParse(widget.controller.tripEndOdometerController.text.trim()) ?? 0;
    final calculatedOdoDistance = (endOdo > startOdo) ? (endOdo - startOdo) : 0.0;

    final distanceResult = widget.controller.calculatedDistance.value ??
        VehicleDistanceResult(
          distanceKm: calculatedOdoDistance > 0 ? calculatedOdoDistance : 10.0,
          durationMinutes: 15,
          distanceText: '${calculatedOdoDistance > 0 ? _formatNum(calculatedOdoDistance) : 10} km',
          durationText: '15 mins',
        );

    setState(() => _isSubmitting = true);

    final ok = await widget.controller.createTrip(
      tripDate: widget.controller.tripDate.value ?? DateTime.now(),
      fromAddress: widget.controller.tripFromController.text.trim(),
      toAddress: widget.controller.tripToController.text.trim(),
      purpose: widget.controller.tripPurposeController.text.trim(),
      distance: distanceResult,
      driverId: widget.controller.selectedTripDriverId.value,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) await _close(true);
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    final String vehicleLabel =
        '${widget.controller.vehicle.value.name} · ${widget.controller.vehicle.value.plateNumber ?? 'No Plate'}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        width * 0.04,
        width * 0.035,
        width * 0.04,
        width * 0.04 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER TITLE
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Trip',
                      style: TextStyle(
                        color: colorsList.primaryText,
                        fontSize: width.fontSizeW(0.045),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======================================================
              // SECTION 1: VEHICLE & DRIVER
              // ======================================================
              _sectionCard(
                stepNumber: '1',
                title: 'Vehicle & driver',
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Vehicle', required: true),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              vehicleLabel,
                              style: TextStyle(
                                color: colorsList.primaryText,
                                fontSize: width.fontSizeW(0.033),
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: colorsList.secondaryText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(text: 'Driver', required: true),
                    const SizedBox(height: 6),
                    Obx(() {
                      final driversList = widget.controller.drivers;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorsList.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: widget.controller.selectedTripDriverId.value,
                            isExpanded: true,
                            hint: const Text('Select driver'),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            items: driversList.map((driver) {
                              return DropdownMenuItem<int>(
                                value: driver.id,
                                child: Text(driver.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                widget.controller.selectedTripDriverId.value = val;
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ======================================================
              // SECTION 2: DATE & PURPOSE
              // ======================================================
              _sectionCard(
                stepNumber: '2',
                title: 'Date & purpose',
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final tripDateVal = widget.controller.tripDate.value ?? DateTime.now();
                      final arrivalDateVal = widget.controller.tripArrivalDate.value;
                      final startTimeVal = widget.controller.tripStartTime.value;
                      final endTimeVal = widget.controller.tripEndTime.value;

                      final tripDateLabel = _formatDateUI(tripDateVal);
                      final arrivalDateLabel = arrivalDateVal != null ? _formatDateUI(arrivalDateVal) : 'dd/mm/yyyy';
                      final startTimeLabel = startTimeVal != null ? startTimeVal.format(context) : '--:-- --';
                      final endTimeLabel = endTimeVal != null ? endTimeVal.format(context) : '--:-- --';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'Date', required: true),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () => _pickDate(isArrival: false),
                                      borderRadius: BorderRadius.circular(10),
                                      child: InputDecorator(
                                        decoration: _inputDecoration(width),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                tripDateLabel,
                                                style: TextStyle(
                                                  color: colorsList.primaryText,
                                                  fontSize: width.fontSizeW(0.031),
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.calendar_month_outlined,
                                                size: 18, color: colorsList.iconColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'Arrival date'),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () => _pickDate(isArrival: true),
                                      borderRadius: BorderRadius.circular(10),
                                      child: InputDecorator(
                                        decoration: _inputDecoration(width),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                arrivalDateLabel,
                                                style: TextStyle(
                                                  color: arrivalDateVal != null
                                                      ? colorsList.primaryText
                                                      : colorsList.textHintColor,
                                                  fontSize: width.fontSizeW(0.031),
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.calendar_month_outlined,
                                                size: 18, color: colorsList.iconColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Only for trips that end after midnight.',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorsList.textHintColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // START TIME & END TIME
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'Start time'),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () => _pickTime(isEnd: false),
                                      borderRadius: BorderRadius.circular(10),
                                      child: InputDecorator(
                                        decoration: _inputDecoration(width),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                startTimeLabel,
                                                style: TextStyle(
                                                  color: startTimeVal != null
                                                      ? colorsList.primaryText
                                                      : colorsList.textHintColor,
                                                  fontSize: width.fontSizeW(0.031),
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.access_time_rounded,
                                                size: 18, color: colorsList.iconColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _FieldLabel(text: 'End time'),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () => _pickTime(isEnd: true),
                                      borderRadius: BorderRadius.circular(10),
                                      child: InputDecorator(
                                        decoration: _inputDecoration(width),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                endTimeLabel,
                                                style: TextStyle(
                                                  color: endTimeVal != null
                                                      ? colorsList.primaryText
                                                      : colorsList.textHintColor,
                                                  fontSize: width.fontSizeW(0.031),
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.access_time_rounded,
                                                size: 18, color: colorsList.iconColor),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 14),

                    // TRIP TYPE (BUSINESS vs PRIVATE TOGGLE)
                    _FieldLabel(text: 'Trip type'),
                    const SizedBox(height: 6),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.controller.setTripType('Business'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: widget.controller.tripType.value == 'Business'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: widget.controller.tripType.value == 'Business'
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.business_center_outlined,
                                        size: 16,
                                        color: widget.controller.tripType.value == 'Business'
                                            ? const Color(0xFF2563EB)
                                            : colorsList.secondaryText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Business',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: widget.controller.tripType.value == 'Business'
                                              ? const Color(0xFF2563EB)
                                              : colorsList.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => widget.controller.setTripType('Private'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: widget.controller.tripType.value == 'Private'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: widget.controller.tripType.value == 'Private'
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.04),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_outlined,
                                        size: 16,
                                        color: widget.controller.tripType.value == 'Private'
                                            ? const Color(0xFF2563EB)
                                            : colorsList.secondaryText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Private',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: widget.controller.tripType.value == 'Private'
                                              ? const Color(0xFF2563EB)
                                              : colorsList.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CONDITIONAL FIELDS (BUSINESS vs PRIVATE)
                    Obx(() {
                      final isBusiness = widget.controller.tripType.value == 'Business';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isBusiness) ...[
                            _FieldLabel(text: 'Passengers'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: widget.controller.tripPassengersController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(width, hint: '0'),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Only people whose ride is required for the business trip (passenger surcharge, cars only).',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorsList.textHintColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // PURPOSE OF THE TRIP (SHOWN FOR BOTH)
                          _FieldLabel(text: 'Purpose of the trip *', required: true),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: widget.controller.tripPurposeController,
                            decoration: _inputDecoration(width,
                                hint: 'e.g. Client meeting with Muster GmbH'),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Purpose is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What the trip was for, e.g. installation of the accounting system.',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorsList.textHintColor,
                            ),
                          ),

                          if (isBusiness) ...[
                            const SizedBox(height: 12),
                            _FieldLabel(text: 'Visited customer / business partner'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: widget.controller.tripVisitedCustomerController,
                              decoration: _inputDecoration(width,
                                  hint: 'Search customers or type a name'),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Optional. Who was visited — a customer, supplier or other business partner.',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorsList.textHintColor,
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ======================================================
              // SECTION 3: ROUTE (WITH REAL-TIME AUTOCOMPLETE & ROUTE PREVIEW)
              // ======================================================
              _sectionCard(
                stepNumber: '3',
                title: 'Route',
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Starting address *', required: true),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: widget.controller.tripFromController,
                      builder: (context, value, _) {
                        return TextFormField(
                          controller: widget.controller.tripFromController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            width,
                            hint: 'Street, city or place',
                            suffixIcon: value.text.trim().isNotEmpty
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20)
                                : null,
                          ),
                          onChanged: (val) {
                            if (widget.controller.calculatedDistance.value != null) {
                              widget.controller.calculatedDistance.value = null;
                            }
                            widget.controller.searchPlaceAutocomplete(input: val, isStart: true);
                          },
                          validator: (valStr) {
                            if (valStr == null || valStr.trim().isEmpty) {
                              return 'Starting address is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    Obx(() {
                      final isSearching = widget.controller.isSearchingStartPlaces.value;
                      final suggestions = widget.controller.startingAddressSuggestions;

                      if (isSearching) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Searching places...', style: TextStyle(fontSize: 12, color: colorsList.secondaryText)),
                            ],
                          ),
                        );
                      }

                      if (suggestions.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorsList.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final item = suggestions[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 18),
                              title: _buildHighlightedText(item),
                              subtitle: item.secondaryText.isNotEmpty
                                  ? Text(item.secondaryText, style: const TextStyle(fontSize: 11, color: colorsList.secondaryText))
                                  : null,
                              onTap: () => widget.controller.selectStartingSuggestion(item),
                            );
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    _FieldLabel(text: 'Destination address *', required: true),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: widget.controller.tripToController,
                      builder: (context, value, _) {
                        return TextFormField(
                          controller: widget.controller.tripToController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            width,
                            hint: 'Street, city or place',
                            suffixIcon: value.text.trim().isNotEmpty
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20)
                                : null,
                          ),
                          onChanged: (val) {
                            if (widget.controller.calculatedDistance.value != null) {
                              widget.controller.calculatedDistance.value = null;
                            }
                            widget.controller.searchPlaceAutocomplete(input: val, isStart: false);
                          },
                          validator: (valStr) {
                            if (valStr == null || valStr.trim().isEmpty) {
                              return 'Destination address is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    Obx(() {
                      final isSearching = widget.controller.isSearchingDestPlaces.value;
                      final suggestions = widget.controller.destinationAddressSuggestions;

                      if (isSearching) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Searching places...', style: TextStyle(fontSize: 12, color: colorsList.secondaryText)),
                            ],
                          ),
                        );
                      }

                      if (suggestions.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorsList.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final item = suggestions[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 18),
                              title: _buildHighlightedText(item),
                              subtitle: item.secondaryText.isNotEmpty
                                  ? Text(item.secondaryText, style: const TextStyle(fontSize: 11, color: colorsList.secondaryText))
                                  : null,
                              onTap: () => widget.controller.selectDestinationSuggestion(item),
                            );
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 14),

                    // ROUTE PREVIEW CARD (MATCHES WEB SCREENSHOT 100%)
                    Obx(() {
                      final dist = widget.controller.calculatedDistance.value;
                      final isCalculating = widget.controller.isCalculatingDistance.value;
                      final from = widget.controller.tripFromController.text.trim();
                      final to = widget.controller.tripToController.text.trim();

                      if (isCalculating) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 10),
                              Text('Calculating distance and route...', style: TextStyle(fontSize: 12, color: colorsList.secondaryText)),
                            ],
                          ),
                        );
                      }

                      if (dist == null || from.isEmpty || to.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.outlined_flag_rounded, size: 18, color: colorsList.textHintColor),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Enter a starting and a destination address to see the route.',
                                  style: TextStyle(fontSize: 12, color: colorsList.textHintColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // START PIN ROW
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF16A34A), width: 2.5),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    from,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF0A2342),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // DESTINATION PIN ROW
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    to,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF0A2342),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),

                            // METRICS ROW (DISTANCE & EST DURATION)
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DISTANCE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dist.distanceText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF0A2342),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EST. DURATION',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF64748B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dist.durationText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Color(0xFF0A2342),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),

                            // MAP PREVIEW FOOTER & GOOGLE MAPS LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Map preview unavailable.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    final mapsUrl =
                                        'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(from)}&destination=${Uri.encodeComponent(to)}';
                                    launchUrl(Uri.parse(mapsUrl), mode: LaunchMode.externalApplication);
                                  },
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Open in Google Maps',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF2563EB)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ======================================================
              // SECTION 4: ODOMETER & DISTANCE
              // ======================================================
              _sectionCard(
                stepNumber: '4',
                title: 'Odometer & distance',
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Starting odometer (km)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: widget.controller.tripStartOdometerController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration(width, hint: '1000'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Ending odometer (km)'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: widget.controller.tripEndOdometerController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDecoration(width, hint: '2500'),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'From the last verified trip.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorsList.textHintColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CALCULATE ROUTE BUTTON & ACTUAL DISTANCE DISPLAY
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(text: 'Actual distance (km)'),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: colorsList.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Builder(
                                        builder: (_) {
                                          final start = double.tryParse(widget.controller.tripStartOdometerController.text.trim()) ?? 0.0;
                                          final end = double.tryParse(widget.controller.tripEndOdometerController.text.trim()) ?? 0.0;
                                          final odoKm = (end > start) ? (end - start) : 0.0;
                                          final displayText = odoKm > 0
                                              ? _formatNum(odoKm)
                                              : (widget.controller.calculatedDistance.value?.distanceText ?? '—');

                                          return Text(
                                            displayText,
                                            style: TextStyle(
                                              color: colorsList.primaryText,
                                              fontSize: width.fontSizeW(0.033),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Text(
                                      'ODOMETER',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorsList.textHintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() {
                          final loading = widget.controller.isCalculatingDistance.value;
                          return Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: OutlinedButton.icon(
                              onPressed: loading ? null : _calculate,
                              icon: const Icon(Icons.alt_route_rounded, size: 16),
                              label: Text(loading ? 'Calculating…' : 'Calculate route'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                minimumSize: const Size(0, 46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ending minus starting odometer. This is the recorded distance.',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorsList.textHintColor,
                      ),
                    ),

                    // ODOMETER COMPARISON & VALIDATION BANNER
                    _buildOdometerComparisonBanner(),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ======================================================
              // SECTION 5: NOTES
              // ======================================================
              _sectionCard(
                stepNumber: '5',
                title: 'Notes',
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Notes'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: widget.controller.tripNotesController,
                      maxLines: 3,
                      decoration: _inputDecoration(width, hint: 'Add trip notes...'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ACTION BUTTONS (CANCEL & SAVE TRIP)
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
                              style: TextStyle(fontWeight: FontWeight.normal),
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

  Widget _sectionCard({
    required String stepNumber,
    required String title,
    required double width,
    required Widget child,
  }) {
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
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: width.fontSizeW(0.038),
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(double width, {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colorsList.textHintColor,
        fontSize: width.fontSizeW(0.031),
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.03,
        vertical: width * 0.03,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorsList.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorsList.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: colorsList.colorButton, width: 1.2),
      ),
    );
  }

  String _formatDateUI(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatNum(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(1);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Text.rich(
      TextSpan(
        text: text,
        style: TextStyle(
          color: colorsList.secondaryText,
          fontSize: width.fontSizeW(0.03),
          fontWeight: FontWeight.normal,
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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _LogFuelSheet(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${logs.length} fuel log${logs.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        final width = _designWidth(context);
        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: colorsList.colorWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: SafeArea(
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
      AppSnackbar.error(
        title: 'Invalid values',
        message: 'Enter valid numbers for liters, cost, and odometer.',
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
    final width = _designWidth(context);
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
                        fontSize: width.fontSizeW(0.042),
                        fontWeight: FontWeight.normal,
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
                        fontSize: width.fontSizeW(0.036),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: width * 0.015),
                    Text(
                      'Take a photo of your fuel receipt and we\'ll automatically extract the cost and date and save it to your incoming invoices ledger.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorsList.secondaryText,
                        fontSize: width.fontSizeW(0.028),
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
                          style: const TextStyle(fontWeight: FontWeight.normal),
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
                  fontSize: width.fontSizeW(0.028),
                  fontWeight: FontWeight.normal,
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
                                  fontSize: width.fontSizeW(0.033),
                                  fontWeight: FontWeight.normal,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.normal),
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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _LogServiceSheet(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${items.length} service${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
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
      AppSnackbar.error(
        title: 'Invalid values',
        message: 'Enter valid numbers for cost and odometer.',
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
    final width = _designWidth(context);
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
                        fontSize: width.fontSizeW(0.042),
                        fontWeight: FontWeight.normal,
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
                                  fontSize: width.fontSizeW(0.033),
                                  fontWeight: FontWeight.normal,
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
                              style: TextStyle(
                                  fontWeight: FontWeight.normal),
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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _LogInsuranceSheet(controller: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${policies.length} polic${policies.length == 1 ? 'y' : 'ies'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
                        fontSize: width.fontSizeW(0.032),
                        fontWeight: FontWeight.normal,
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
      AppSnackbar.error(
        title: 'Invalid cost',
        message: 'Enter a valid premium cost.',
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
    final width = _designWidth(context);
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
                        fontSize: width.fontSizeW(0.042),
                        fontWeight: FontWeight.normal,
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
      backgroundColor: Colors.transparent,
      builder: (_) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: _UploadDocumentSheet(controller: controller),
        ),
      ),
    );
  }

  void _openDocumentPreview(VehicleDocument document) {
    final url = document.url?.trim();
    if (url == null || url.isEmpty) {
      AppSnackbar.error(
        title: 'Unavailable',
        message: 'No preview URL for this document.',
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
              fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
                          fontSize: width.fontSizeW(0.036),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: width * 0.008),
                      Text(
                        '${docs.length} document${docs.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.028),
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
                      fontWeight: FontWeight.normal,
                      fontSize: width.fontSizeW(0.03),
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
                        fontSize: width.fontSizeW(0.028),
                        fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);
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
                        fontSize: width.fontSizeW(0.042),
                        fontWeight: FontWeight.normal,
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
                        fontSize: width.fontSizeW(0.026),
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
                  fontSize: width.fontSizeW(0.033),
                  fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
                    style: const TextStyle(fontWeight: FontWeight.normal),
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
    final width = _designWidth(context);

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
              fontSize: width.fontSizeW(0.034),
              fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
                fontSize: width.fontSizeW(0.03),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width.fontSizeW(0.032),
                fontWeight: FontWeight.normal,
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
    final width = _designWidth(context);

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
                        fontSize: width.fontSizeW(0.034),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      SizedBox(height: width * 0.01),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colorsList.secondaryText,
                          fontSize: width.fontSizeW(0.027),
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
    final width = _designWidth(context);

    return Column(
      children: [
        Icon(icon, size: width * 0.12, color: colorsList.mutedTextColor),
        SizedBox(height: width * 0.03),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width.fontSizeW(0.034),
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
