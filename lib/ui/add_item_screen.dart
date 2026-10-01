
import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/add_item_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemScreen extends StatelessWidget {
  AddItemScreen({super.key});

  static const Color _textColor = Color(0xFF172033);
  static const Color _mutedColor = Color(0xFF667085);

  final AddItemController controller = Get.put(AddItemController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: controller.previousStep,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.colorBackArrow,
            size: 20,
          ),
        ),
        title: const Text(
          'Add Item',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
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

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepper(step),
                      const SizedBox(height: 24),
                      _buildStepHeading(step),
                      const SizedBox(height: 20),
                      if (step == 0) _buildBasicInformation(),
                      if (step == 1) _buildUnitAndQuantity(),
                      if (step == 2) _buildPricing(),
                    ],
                  ),
                );
              }),
            ),
            _buildBottomActions(size),
          ],
        ),
      ),

    );
  }

  Widget _buildStepper(int activeStep) {
    const titles = ['Basic Info', 'Unit & Quantity', 'Pricing'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                        width: 36,
                        height: 36,
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
                          size: 18,
                          color: isCompleted || isActive
                              ? Colors.white
                              : colorsList.iconColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive || isCompleted
                              ? colorsList.colorButton
                              : _mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 2)
                  Container(
                    height: 2,
                    width: 12,
                    margin: const EdgeInsets.only(bottom: 22),
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

  Widget _buildStepHeading(int step) {
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
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          descriptions[step],
          style: const TextStyle(
            fontSize: 13,
            color: _mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  })
  {
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
                    fontWeight: FontWeight.w700,
                    color: _textColor,
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
            color: _textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
  })
  {
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

  Widget _buildBasicInformation() {
    return _section(
      title: 'Item Details',
      icon: Icons.description_outlined,
      children: [
        _textField(
          label: 'Name',
          textController: controller.nameController,
          hint: 'e.g. Technician hour',
          required: true,
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Article Number',
          textController: controller.articleNumberController,
          hint: 'e.g. CF-0002',
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Group Code',
          textController: controller.groupCodeController,
          hint: 'e.g. service, labor, material',
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Description',
          textController: controller.descriptionController,
          hint: 'Enter item description',
        ),
        const SizedBox(height: 8),
        const Text(
          'Shown in item suggestions and can be copied into offers/invoices.',
          style: TextStyle(
            color: _mutedColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitAndQuantity() {
    return _section(
      title: 'Unit and Quantity',
      icon: Icons.straighten_rounded,
      children: [
        _fieldLabel('Unit', required: true),
        Obx(
              () => AppTextField(
            isDropdown: true,
            hintText: 'Select unit',
            prefixIcon: Icons.straighten_rounded,
            dropdownItems: controller.unitOptions,
            selectedValue: controller.selectedUnit.value,
            onDropdownChanged: controller.selectUnit,
          ),
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Find Unit in List',
          textController: controller.unitSearchController,
          hint: 'e.g. hour, campaign, pallet, m2',
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Default Quantity',
          textController: controller.quantityController,
          hint: '1',
          required: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),
        const SizedBox(height: 18),
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
        const SizedBox(height: 12),
        Obx(
              () => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Track stock in store',
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
              ),
            ),
            value: controller.trackStock.value,
            activeColor: colorsList.colorButton,
            onChanged: controller.toggleStock,
          ),
        ),
        Obx(() {
          if (!controller.trackStock.value) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              const SizedBox(height: 12),
              _textField(
                label: 'Stock in Store',
                textController: controller.stockController,
                hint: '1',
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 18),
              _textField(
                label: 'Minimum Stock Alert Threshold',
                textController: controller.minimumStockController,
                hint: '0',
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure the minimum stock quantity for low-stock alerts.',
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPricing() {
    return _section(
      title: 'Pricing',
      icon: Icons.sell_outlined,
      children: [
        _textField(
          label: 'Item Cost Price (Net)',
          textController: controller.costPriceController,
          hint: '0',
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Sale Price (Net)',
          textController: controller.salePriceController,
          hint: '0',
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'VAT %',
          textController: controller.vatController,
          hint: '20',
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'Discount %',
          textController: controller.discountController,
          hint: '0',
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 18),
        _textField(
          label: 'MSRP',
          textController: controller.msrpController,
          hint: '0',
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),
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
                color: _mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Size size) {
    return Obx(() {
      final step = controller.currentStep.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
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
                    minimumSize: Size(0, size.height * 0.058),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: step == 0 ? 1 : 2,
              child: AppButton(
                text: step == 2 ? 'Save Item' : 'Next Step',
                icon: step == 2
                    ? Icons.save_outlined
                    : Icons.arrow_forward_rounded,
                height: size.height * 0.058,
                backgroundColor: colorsList.colorButton,
                foregroundColor: Colors.white,
                isLoading: controller.isLoading.value,
                onPressed:
                step == 2 ? controller.saveItem : controller.nextStep,
              ),
            ),
          ],
        ),
      );
    });
  }
}