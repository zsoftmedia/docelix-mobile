import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/add_item_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemScreen extends StatelessWidget {
  AddItemScreen({super.key});

  final AddItemController controller = Get.put(AddItemController());

  Widget _pairOrStack({
    required BuildContext context,
    required Widget left,
    required Widget right,
  }) {
    if (context.rs.formColumns < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          SizedBox(height: context.s(18)),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: context.s(12)),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: controller.previousStep,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.colorBackArrow,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Add Item',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(20),
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final step = controller.currentStep.value;

                return ResponsivePage(
                  padding: EdgeInsets.all(rs.s(18)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepper(context, step),
                        SizedBox(height: rs.s(24)),
                        _buildStepHeading(context, step),
                        SizedBox(height: rs.s(20)),
                        if (step == 0) _buildBasicInformation(context),
                        if (step == 1) _buildUnitAndQuantity(context),
                        if (step == 2) _buildPricing(context),
                      ],
                    ),
                  ),
                );
              }),
            ),
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(BuildContext context, int activeStep) {
    final rs = context.rs;
    const titles = ['Basic Info', 'Unit & Quantity', 'Pricing'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.s(12),
        vertical: rs.s(18),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs.s(16)),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isCompleted = index < activeStep;
          final isActive = index == activeStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: rs.s(36),
                        height: rs.s(36),
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? colorsList.colorButton
                              : colorsList.progressBackground,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : _stepIcon(index),
                          size: rs.s(18),
                          color: isCompleted || isActive
                              ? Colors.white
                              : colorsList.iconColor,
                        ),
                      ),
                      SizedBox(height: rs.s(8)),
                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: rs.sp(11),
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive || isCompleted
                              ? colorsList.colorButton
                              : colorsList.textHintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 2)
                  Container(
                    height: 2,
                    width: rs.s(12),
                    margin: EdgeInsets.only(bottom: rs.s(22)),
                    color: index < activeStep
                        ? colorsList.colorButton
                        : colorsList.progressBackground,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _stepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.description_outlined;
      case 1:
        return Icons.straighten_rounded;
      default:
        return Icons.sell_outlined;
    }
  }

  Widget _buildStepHeading(BuildContext context, int step) {
    final rs = context.rs;
    const headings = [
      'Basic Information',
      'Unit and Quantity',
      'Pricing Details',
    ];

    const descriptions = [
      'Enter the main details for this item.',
      'Configure the unit, quantity and stock options.',
      'Set the cost, sale price, VAT and discount.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headings[step],
          style: TextStyle(
            fontSize: rs.sp(21),
            fontWeight: FontWeight.w700,
            color: colorsList.textColor,
          ),
        ),
        SizedBox(height: rs.s(5)),
        Text(
          descriptions[step],
          style: TextStyle(
            fontSize: rs.sp(13),
            color: colorsList.textHintColor,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorsList.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorsList.iconColor,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                  //  fontWeight: FontWeight.w700,
                    color: colorsList.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: colorsList.textColor,
            fontSize: 14,
           // fontWeight: FontWeight.w600,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController textController,
    required String hint,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        AppTextField(
          controller: textController,
          hintText: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildBasicInformation(BuildContext context) {
    return _section(
      title: 'Item Details',
      icon: Icons.description_outlined,
      children: [
        _pairOrStack(
          context: context,
          left: _textField(
            label: 'Name',
            textController: controller.nameController,
            hint: 'e.g. Technician hour',
            required: true,
          ),
          right: _textField(
            label: 'Article Number',
            textController: controller.articleNumberController,
            hint: 'e.g. CF-0002',
          ),
        ),
        SizedBox(height: context.s(18)),
        _textField(
          label: 'Group Code',
          textController: controller.groupCodeController,
          hint: 'e.g. service, labor, material',
        ),
        SizedBox(height: context.s(18)),
        _textField(
          label: 'Description',
          textController: controller.descriptionController,
          hint: 'Enter item description',
        ),
        SizedBox(height: context.s(8)),
        Text(
          'Shown in item suggestions and can be copied into offers/invoices.',
          style: TextStyle(
            color: colorsList.textHintColor,
            fontSize: context.sp(12),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitAndQuantity(BuildContext context) {
    return _section(
      title: 'Unit and Quantity',
      icon: Icons.straighten_rounded,
      children: [
        _fieldLabel('Unit', required: true),
        Obx(() {
          final selected = controller.currentSelectedUnit ?? 'Select unit';

          return InkWell(
            onTap: () => _showUnitBottomSheet(context),
            borderRadius: BorderRadius.circular(7),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.straighten_rounded,
                    color: Color(0xFF4b4f57),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selected,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4b4f57),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF4b4f57),
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: context.s(18)),
        _pairOrStack(
          context: context,
          left: _textField(
            label: 'Default Quantity',
            textController: controller.quantityController,
            hint: '1',
            required: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          right: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel('Item Type'),
              Obx(
                () => AppTextField(
                  isDropdown: true,
                  hintText: 'Select item type',
                  prefixIcon: Icons.category_outlined,
                  dropdownItems: controller.itemTypes,
                  selectedValue: controller.selectedItemType.value,
                  onDropdownChanged: controller.selectItemType,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.s(12)),
        Obx(
          () => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Track stock in store',
              style: TextStyle(
                fontSize: context.sp(14),
                color: colorsList.textColor,
              ),
            ),
            value: controller.trackStock.value,
            activeThumbColor: colorsList.colorButton,
            onChanged: controller.toggleStock,
          ),
        ),
        Obx(() {
          if (!controller.trackStock.value) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              SizedBox(height: context.s(12)),
              _pairOrStack(
                context: context,
                left: _textField(
                  label: 'Stock in Store',
                  textController: controller.stockController,
                  hint: '1',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                right: _textField(
                  label: 'Minimum Stock Alert Threshold',
                  textController: controller.minimumStockController,
                  hint: '0',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(height: context.s(8)),
              Text(
                'Configure the minimum stock quantity for low-stock alerts.',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: context.sp(12),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _showUnitBottomSheet(BuildContext context) {
    controller.unitSearchController.clear();
    controller.updateUnitSearchQuery('');

    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          height: context.rs.height * 0.75,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorsList.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Measurement Unit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorsList.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.unitSearchController,
                hintText: 'Search unit (e.g. hour, kg, m²)...',
                prefixIcon: Icons.search_rounded,
                onChanged: controller.updateUnitSearchQuery,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final list = controller.filteredUnits;

                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching units found.',
                        style: TextStyle(
                          color: colorsList.textHintColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.8,
                      color: colorsList.borderColor,
                    ),
                    itemBuilder: (context, index) {
                      final unitLabel = list[index];
                      final isSelected =
                          unitLabel == controller.currentSelectedUnit;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        title: Text(
                          unitLabel,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? colorsList.colorButton
                                : colorsList.textColor,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: colorsList.colorButton,
                                size: 22,
                              )
                            : null,
                        onTap: () {
                          controller.selectUnit(unitLabel);
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPricing(BuildContext context) {
    return _section(
      title: 'Pricing',
      icon: Icons.sell_outlined,
      children: [
        _pairOrStack(
          context: context,
          left: _textField(
            label: 'Item Cost Price (Net)',
            textController: controller.costPriceController,
            hint: '0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          right: _textField(
            label: 'Sale Price (Net)',
            textController: controller.salePriceController,
            hint: '0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(height: context.s(18)),
        _pairOrStack(
          context: context,
          left: _textField(
            label: 'VAT %',
            textController: controller.vatController,
            hint: '20',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          right: _textField(
            label: 'Discount %',
            textController: controller.discountController,
            hint: '0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        SizedBox(height: context.s(18)),
        _textField(
          label: 'MSRP',
          textController: controller.msrpController,
          hint: '0',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: context.s(16)),
        _buildPriceSummary(),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorsList.colorBoxDecoration,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorsList.iconColor,
            size: 19,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prices are entered as net amounts. VAT and discount are stored separately.',
              style: TextStyle(
                fontSize: 12,
                color: colorsList.textHintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final rs = context.rs;

    return Obx(() {
      final step = controller.currentStep.value;

      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rs.contentMaxWidth),
          child: Container(
            padding: EdgeInsets.fromLTRB(rs.s(18), rs.s(12), rs.s(18), rs.s(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: colorsList.borderColor),
              ),
            ),
            child: Row(
              children: [
                if (step > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorsList.colorButton,
                        side: const BorderSide(
                          color: colorsList.borderColor,
                        ),
                        minimumSize: Size(0, rs.s(48)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rs.s(12)),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                  SizedBox(width: rs.s(12)),
                ],
                Expanded(
                  flex: step == 0 ? 1 : 2,
                  child: AppButton(
                    text: step == 2 ? 'Save Item' : 'Next Step',
                    icon: step == 2
                        ? Icons.save_outlined
                        : Icons.arrow_forward_rounded,
                    height: rs.s(48),
                    backgroundColor: colorsList.colorButton,
                    foregroundColor: Colors.white,
                    isLoading: controller.isLoading.value,
                    onPressed:
                        step == 2 ? controller.saveItem : controller.nextStep,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}