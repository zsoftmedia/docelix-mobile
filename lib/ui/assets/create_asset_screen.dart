import 'package:docelix_mobileapp/controllers/create_asset_controller.dart';
import 'package:docelix_mobileapp/controllers/fixed_assets_controller.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAssetScreen extends StatelessWidget {
  const CreateAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAssetController());
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && Get.isRegistered<CreateAssetController>()) {
          Get.delete<CreateAssetController>();
        }
      },
      child: Scaffold(
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
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
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

        return Form(
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
                      fontSize: width * 0.026,
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
                                          fontWeight: FontWeight.w600,
                                          fontSize: width * 0.033,
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
                  _DropdownField<int?>(
                    value: controller.selectedAccountId.value,
                    hint: 'Select ledger account',
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Select ledger account'),
                      ),
                      ...controller.accounts.map(
                        (account) => DropdownMenuItem<int?>(
                          value: account.id,
                          child: Text(
                            account.displayLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.selectedAccountId.value = value,
                    validator: (value) {
                      if (value == null) return 'Required';
                      return null;
                    },
                  ),
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
                                fontSize: width * 0.024,
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
                                fontSize: width * 0.024,
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
                                fontSize: width * 0.024,
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
                      onPressed: controller.isSubmitting.value ? null : Get.back,
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
                              if (Get.isRegistered<FixedAssetsController>()) {
                                await Get.find<FixedAssetsController>()
                                    .refreshAssets();
                              }
                              Get.back();
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
        );
      }),
    ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreateAssetController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
            fontWeight: FontWeight.w600,
            fontSize: width * 0.033,
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
                            fontSize: width * 0.03,
                            fontWeight: FontWeight.w600,
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
  const _SuggestionTile({
    required this.suggestion,
    required this.onTap,
  });

  final DepreciationSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
                fontSize: width * 0.032,
                fontWeight: FontWeight.w700,
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
                      fontSize: width * 0.026,
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
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final show = controller.purchasePrice.value > 0 &&
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
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w700,
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
                    subtitle: '${controller.monthsActiveThisYear} months active',
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
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorsList.secondaryText,
            fontSize: width * 0.025,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: width * 0.01),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colorsList.primaryText,
            fontSize: width * 0.038,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: width * 0.006),
          Text(
            subtitle!,
            style: TextStyle(
              color: colorsList.mutedTextColor,
              fontSize: width * 0.024,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

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
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
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
  const _FieldLabel({
    required this.text,
    this.required = false,
  });

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
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
    final width = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
      style: TextStyle(
        color: colorsList.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: width * 0.033,
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
    final width = MediaQuery.of(context).size.width;

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
        fontWeight: FontWeight.w600,
        fontSize: width * 0.033,
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) {
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
