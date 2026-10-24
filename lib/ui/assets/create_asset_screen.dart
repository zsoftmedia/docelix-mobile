import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/controllers/create_asset_controller.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Phone: real screen width. Tablet+: design width scaled (keeps proportions
/// consistent instead of stretching with the viewport).
double _designWidth(BuildContext context) {
  final rs = context.rs;
  return rs.isPhone ? rs.width : ResponsiveBreakpoints.designWidth * rs.scale;
}

class CreateAssetScreen extends StatelessWidget {
  const CreateAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAssetController());
    final width = _designWidth(context);

    // Do not Get.delete here — disposing TextEditingControllers while the
    // route is still exiting causes "used after being disposed" + red screen.
    // FixedAssetsScreen deletes the controller after Get.toNamed returns.
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
          'Add New Asset',
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width.fontSizeW(0.045),
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoadingMeta.value &&
            controller.categories.isEmpty &&
            controller.accounts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: Form(
            key: controller.formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                width * 0.045,
                width * 0.04,
                width * 0.045,
                width * 0.08,
              ),
              children: [
                _SectionCard(
                  title: 'General Information',
                  children: [
                    _FieldLabel(text: 'Asset Name', required: true),
                    _NameField(controller: controller),
                    SizedBox(height: width * 0.035),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Category'),
                              _DropdownField<int?>(
                                value: controller.selectedCategoryId.value,
                                hint: 'Select category',
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('None'),
                                  ),
                                  ...controller.categories.map(
                                    (category) => DropdownMenuItem<int?>(
                                      value: category.id,
                                      child: Text(
                                        category.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) =>
                                    controller.selectedCategoryId.value = value,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Status'),
                              _DropdownField<String>(
                                value: controller.status.value,
                                items: CreateAssetController.statusOptions
                                    .map(
                                      (status) => DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.status.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.035),
                    const _FieldLabel(text: 'Asset Number'),
                    _InputField(
                      controller: controller.assetNumberController,
                      hint: 'e.g. AST-2026-0001',
                    ),
                    SizedBox(height: width * 0.01),
                    Text(
                      'Leave blank to auto-generate',
                      style: TextStyle(
                        color: colorsList.mutedTextColor,
                        fontSize: width.fontSizeW(0.026),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: width * 0.035),
                _SectionCard(
                  title: 'Financial Details',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(
                                text: 'Purchase Date',
                                required: true,
                              ),
                              InkWell(
                                onTap: () =>
                                    controller.pickPurchaseDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: _inputDecoration(),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy').format(
                                            controller.purchaseDate.value,
                                          ),
                                          style: TextStyle(
                                            color: colorsList.primaryText,
                                            fontWeight: FontWeight.normal,
                                            fontSize: width.fontSizeW(0.033),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: width * 0.04,
                                        color: colorsList.secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                text:
                                    'Purchase Price (${controller.currencySymbol.trim()})',
                                required: true,
                              ),
                              _InputField(
                                controller: controller.purchasePriceController,
                                hint: '0.00',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value.trim()) == null) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.035),
                    const _FieldLabel(text: 'Ledger Account', required: true),
                    _LedgerAccountField(controller: controller),
                    SizedBox(height: width * 0.035),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                text:
                                    'Current Book Value (${controller.currencySymbol.trim()})',
                              ),
                              _InputField(
                                controller: controller.bookValueController,
                                hint: 'Optional',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                              ),
                              SizedBox(height: width * 0.01),
                              Text(
                                'Defaults to purchase price if left empty',
                                style: TextStyle(
                                  color: colorsList.mutedTextColor,
                                  fontSize: width.fontSizeW(0.024),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Useful Life (Years)'),
                              _InputField(
                                controller: controller.usefulLifeController,
                                hint: 'e.g. 5',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              SizedBox(height: width * 0.01),
                              Text(
                                'Official recommendation from Depreciation Engine',
                                style: TextStyle(
                                  color: colorsList.mutedTextColor,
                                  fontSize: width.fontSizeW(0.024),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.035),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Annual Rate (%)'),
                              _InputField(
                                controller: controller.annualRateController,
                                hint: 'e.g. 33.33',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                              ),
                              SizedBox(height: width * 0.01),
                              Text(
                                'Auto-filled from Depreciation Engine',
                                style: TextStyle(
                                  color: colorsList.mutedTextColor,
                                  fontSize: width.fontSizeW(0.024),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Depreciation Method'),
                              _DropdownField<String>(
                                value: controller.depreciationMethod.value,
                                items: CreateAssetController
                                    .depreciationMethodOptions
                                    .map(
                                      (method) => DropdownMenuItem<String>(
                                        value: method,
                                        child: Text(
                                          method == 'Linear'
                                              ? 'Linear (Straight Line)'
                                              : method,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.depreciationMethod.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.04),
                    _LiveTaxCard(controller: controller),
                  ],
                ),
                SizedBox(height: width * 0.035),
                _SectionCard(
                  title: 'Additional Details',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Supplier'),
                              _InputField(
                                controller: controller.supplierController,
                                hint: 'Supplier name',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Serial Number'),
                              _InputField(
                                controller: controller.serialController,
                                hint: 'Serial number',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.035),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Location'),
                              _InputField(
                                controller: controller.locationController,
                                hint: 'Location',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel(text: 'Ownership Type'),
                              _DropdownField<String>(
                                value: controller.ownershipType.value,
                                items: CreateAssetController.ownershipOptions
                                    .map(
                                      (type) => DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.ownershipType.value = value;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.035),
                    const _FieldLabel(text: 'Notes'),
                    _InputField(
                      controller: controller.notesController,
                      hint: 'Optional notes',
                      maxLines: 4,
                    ),
                  ],
                ),
                SizedBox(height: width * 0.05),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : Get.back,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
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
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final created = await controller.submit();
                                if (!created) return;
                                // Pop first; list screen refreshes + shows snackbar.
                                Get.back(result: true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsList.colorButton,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Asset',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreateAssetController controller;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Column(
      children: [
        TextFormField(
          controller: controller.nameController,
          onChanged: controller.onNameChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Asset name is required';
            }
            return null;
          },
          decoration: _inputDecoration(
            hint: 'Start typing to search AI suggestions',
          ),
          style: TextStyle(
            color: colorsList.primaryText,
            fontWeight: FontWeight.normal,
            fontSize: width.fontSizeW(0.033),
          ),
        ),
        Obx(() {
          if (!controller.isSearchingAi.value &&
              controller.suggestions.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: width * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorsList.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: controller.isSearchingAi.value
                ? Padding(
                    padding: EdgeInsets.all(width * 0.035),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: width * 0.04,
                          color: const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: width * 0.025),
                        Text(
                          'AI is searching for matches...',
                          style: TextStyle(
                            color: colorsList.colorButton,
                            fontSize: width.fontSizeW(0.03),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: controller.suggestions
                        .map(
                          (suggestion) => _SuggestionTile(
                            suggestion: suggestion,
                            onTap: () =>
                                controller.selectSuggestion(suggestion),
                          ),
                        )
                        .toList(),
                  ),
          );
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final DepreciationSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.035,
          vertical: width * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.assetName,
              style: TextStyle(
                color: colorsList.primaryText,
                fontSize: width.fontSizeW(0.032),
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: width * 0.012),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: width * 0.035,
                  color: const Color(0xFF12B886),
                ),
                SizedBox(width: width * 0.015),
                Expanded(
                  child: Text(
                    [
                      if (suggestion.isIndustryMatch)
                        'Recommended for your Industry',
                      if (suggestion.usefulLifeYears != null)
                        '${suggestion.usefulLifeYears} Years Useful Life',
                    ].join(' • '),
                    style: TextStyle(
                      color: colorsList.secondaryText,
                      fontSize: width.fontSizeW(0.026),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTaxCard extends StatelessWidget {
  const _LiveTaxCard({required this.controller});

  final CreateAssetController controller;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Obx(() {
      final show =
          controller.purchasePrice.value > 0 &&
          (controller.annualRate.value > 0 ||
              controller.usefulLifeYears.value > 0);

      if (!show) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(width * 0.035),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: width * 0.045,
                  color: colorsList.colorButton,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  'Live Tax Return Calculation',
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width.fontSizeW(0.033),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.035),
            Row(
              children: [
                Expanded(
                  child: _TaxStat(
                    label: 'Full Year Write-off',
                    value: controller.formatMoney(controller.fullYearWriteOff),
                  ),
                ),
                Expanded(
                  child: _TaxStat(
                    label:
                        'Tax Return ${controller.purchaseDate.value.year} (Pro-rata)',
                    value: controller.formatMoney(controller.taxReturnProRata),
                    valueColor: const Color(0xFF12B886),
                    subtitle:
                        '${controller.monthsActiveThisYear} months active',
                  ),
                ),
              ],
            ),
            SizedBox(height: width * 0.03),
            _TaxStat(
              label: 'Remaining Useful Life',
              value: controller.remainingUsefulLife == null
                  ? '—'
                  : '${controller.remainingUsefulLife} Years',
              subtitle: controller.depreciationEndYear == null
                  ? null
                  : 'Ends in ${controller.depreciationEndYear}',
            ),
          ],
        ),
      );
    });
  }
}

class _TaxStat extends StatelessWidget {
  const _TaxStat({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width.fontSizeW(0.025),
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: width * 0.01),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colorsList.primaryText,
            fontSize: width.fontSizeW(0.038),
            fontWeight: FontWeight.normal,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: width * 0.006),
          Text(
            subtitle!,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width.fontSizeW(0.024),
            ),
          ),
        ],
      ],
    );
  }
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
              fontSize: width.fontSizeW(0.038),
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: width * 0.02),
          const Divider(height: 1, color: colorsList.borderColor),
          SizedBox(height: width * 0.035),
          ...children,
        ],
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
    final width = _designWidth(context);

    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.015),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width.fontSizeW(0.03),
            fontWeight: FontWeight.normal,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFE5484D),
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
      style: TextStyle(
        color: colorsList.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: width.fontSizeW(0.033),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.validator,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: _inputDecoration(hint: hint),
      style: TextStyle(
        color: colorsList.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: width.fontSizeW(0.033),
      ),
    );
  }
}

class _LedgerAccountField extends StatelessWidget {
  const _LedgerAccountField({required this.controller});

  final CreateAssetController controller;

  Future<void> _openSheet(BuildContext context) async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _LedgerAccountSheet(
        accounts: controller.accounts.toList(),
        selectedId: controller.selectedAccountId.value,
      ),
    );

    if (selectedId != null) {
      controller.selectedAccountId.value = selectedId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = _designWidth(context);

    return FormField<int?>(
      validator: (_) {
        if (controller.selectedAccountId.value == null) {
          return 'Please select a ledger account';
        }
        return null;
      },
      builder: (field) {
        return Obx(() {
          final account = controller.selectedAccount;
          final hasValue = account != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _openSheet(context);
                    field.didChange(controller.selectedAccountId.value);
                    field.validate();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.035,
                      vertical: width * 0.032,
                    ),
                    decoration: BoxDecoration(
                      color: colorsList.colorBoxDecoration,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: field.hasError
                            ? const Color(0xFFE5484D)
                            : colorsList.borderColor.withValues(alpha: 0.0),
                        width: field.hasError ? 1.2 : 0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: width * 0.1,
                          height: width * 0.1,
                          decoration: BoxDecoration(
                            color: hasValue
                                ? colorsList.colorButton.withValues(alpha: 0.12)
                                : const Color(0xFFE8EEF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_outlined,
                            size: width * 0.045,
                            color: hasValue
                                ? colorsList.colorButton
                                : colorsList.secondaryText,
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasValue && account.code.isNotEmpty) ...[
                                Text(
                                  account.code,
                                  style: TextStyle(
                                    color: colorsList.colorButton,
                                    fontSize: width.fontSizeW(0.026),
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: width * 0.006),
                                Text(
                                  account.name.isNotEmpty
                                      ? account.name
                                      : account.displayLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colorsList.primaryText,
                                    fontSize: width.fontSizeW(0.033),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ] else
                                Text(
                                  'Select ledger account',
                                  style: TextStyle(
                                    color: colorsList.mutedTextColor,
                                    fontSize: width.fontSizeW(0.033),
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorsList.secondaryText,
                          size: width * 0.055,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (field.hasError) ...[
                SizedBox(height: width * 0.015),
                Padding(
                  padding: EdgeInsets.only(left: width * 0.01),
                  child: Text(
                    field.errorText ?? '',
                    style: TextStyle(
                      color: const Color(0xFFE5484D),
                      fontSize: width.fontSizeW(0.026),
                    ),
                  ),
                ),
              ],
            ],
          );
        });
      },
    );
  }
}

class _LedgerAccountSheet extends StatefulWidget {
  const _LedgerAccountSheet({required this.accounts, required this.selectedId});

  final List<LedgerAccount> accounts;
  final int? selectedId;

  @override
  State<_LedgerAccountSheet> createState() => _LedgerAccountSheetState();
}

class _LedgerAccountSheetState extends State<_LedgerAccountSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LedgerAccount> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.accounts;
    return widget.accounts.where((account) {
      return account.code.toLowerCase().contains(q) ||
          account.name.toLowerCase().contains(q) ||
          account.displayLabel.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final width = _designWidth(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final accounts = _filtered;

    return ResponsiveSheetBody(
      padding: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(maxHeight: rs.height * 0.78),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: width * 0.03),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DDE5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width * 0.045,
                  width * 0.04,
                  width * 0.045,
                  width * 0.02,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ledger Account',
                            style: TextStyle(
                              color: colorsList.primaryText,
                              fontSize: width.fontSizeW(0.042),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: width * 0.008),
                          Text(
                            '${widget.accounts.length} account${widget.accounts.length == 1 ? '' : 's'} available',
                            style: TextStyle(
                              color: colorsList.secondaryText,
                              fontSize: width.fontSizeW(0.028),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorsList.secondaryText,
                        size: width * 0.055,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.045),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorsList.colorBoxDecoration,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: widget.accounts.length > 8,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Search by code or name...',
                      hintStyle: TextStyle(
                        color: colorsList.mutedTextColor,
                        fontSize: width.fontSizeW(0.032),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorsList.secondaryText,
                        size: width * 0.05,
                      ),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: Icon(
                                Icons.clear_rounded,
                                size: width * 0.045,
                                color: colorsList.secondaryText,
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: width * 0.032,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: width * 0.02),
              Flexible(
                child: accounts.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(width * 0.08),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: width * 0.12,
                              color: colorsList.mutedTextColor,
                            ),
                            SizedBox(height: width * 0.03),
                            Text(
                              _query.isEmpty
                                  ? 'No ledger accounts loaded'
                                  : 'No accounts match “$_query”',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorsList.secondaryText,
                                fontSize: width.fontSizeW(0.032),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(
                          width * 0.045,
                          width * 0.01,
                          width * 0.045,
                          width * 0.05 + MediaQuery.paddingOf(context).bottom,
                        ),
                        itemCount: accounts.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: width * 0.02),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final selected = account.id == widget.selectedId;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context, account.id),
                              borderRadius: BorderRadius.circular(14),
                              child: Ink(
                                padding: EdgeInsets.all(width * 0.035),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colorsList.colorButton.withValues(
                                          alpha: 0.08,
                                        )
                                      : colorsList.colorBoxDecoration,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected
                                        ? colorsList.colorButton.withValues(
                                            alpha: 0.35,
                                          )
                                        : colorsList.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: width * 0.14,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.02,
                                        vertical: width * 0.014,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? colorsList.colorButton
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: selected
                                              ? colorsList.colorButton
                                              : colorsList.borderColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        account.code.isNotEmpty
                                            ? account.code
                                            : '#${account.id}',
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : colorsList.colorButton,
                                          fontSize: width.fontSizeW(0.026),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.03),
                                    Expanded(
                                      child: Text(
                                        account.name.isNotEmpty
                                            ? account.name
                                            : account.displayLabel,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colorsList.primaryText,
                                          fontSize: width.fontSizeW(0.033),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (selected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: colorsList.colorButton,
                                        size: width * 0.055,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: colorsList.mutedTextColor,
      fontWeight: FontWeight.normal,
    ),
    filled: true,
    fillColor: colorsList.colorBoxDecoration,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: colorsList.colorButton, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5484D)),
    ),
  );
}
