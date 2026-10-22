import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/edit_catalogs_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditCatalogsScreen extends StatefulWidget {
  const EditCatalogsScreen({super.key});

  @override
  State<EditCatalogsScreen> createState() => _EditCatalogsScreenState();
}

class _EditCatalogsScreenState extends State<EditCatalogsScreen> {
  final EditCatalogsController controller = Get.put(EditCatalogsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
          ),
        ),
        title: const Text(
          'Edit Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: colorsList.textColor,
          ),
        ),
      ),
      body: Obx(() {
        final currentStep = controller.currentStep.value;

        return Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepTapped: (step) {
            if (controller.validateStep(currentStep)) {
              controller.currentStep.value = step;
            }
          },
          onStepContinue: () {
            if (controller.currentStep.value < 2) {
              controller.nextStep();
            } else {
              controller.saveItem();
            }
          },
          onStepCancel: controller.previousStep,
          elevation: 0,
          margin: EdgeInsets.zero,
          controlsBuilder: _buildControls,
          steps: [
            Step(
              title: const Text('Basic', style: TextStyle(fontSize: 11)),
              isActive: currentStep >= 0,
              state: currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _basicInfoStep(),
            ),
            Step(
              title: const Text('Unit & Qty', style: TextStyle(fontSize: 11)),
              isActive: currentStep >= 1,
              state: currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _unitQuantityStep(),
            ),
            Step(
              title: const Text('Pricing', style: TextStyle(fontSize: 11)),
              isActive: currentStep >= 2,
              state: StepState.indexed,
              content: _pricingStep(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isFirstStep = controller.currentStep.value == 0;
    final isLastStep = controller.currentStep.value == 2;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: colorsList.borderColor),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoading.value;

              return ElevatedButton(
                onPressed: isLoading ? null : details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colorsList.colorButton,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isLastStep ? 'Save Changes' : 'Next',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: Basic Info
  // ---------------------------------------------------------------------------

  Widget _basicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Basic Information'),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.nameController,
          hintText: 'Item name *',
          prefixIcon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.articleNumberController,
          hintText: 'Article number (e.g. CF-001)',
          prefixIcon: Icons.numbers_outlined,
        ),
        const SizedBox(height: 12),
        Obx(
              () => AppTextField(
            isDropdown: true,
            hintText: 'Item type',
            prefixIcon: Icons.category_outlined,
            dropdownItems: controller.itemTypes,
            selectedValue: controller.selectedItemType.value,
            onDropdownChanged: controller.selectItemType,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.groupCodeController,
          hintText: 'Group code / category',
          prefixIcon: Icons.folder_open_outlined,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.descriptionController,
          hintText: 'Description',
          prefixIcon: Icons.notes_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: Unit & Quantity
  // ---------------------------------------------------------------------------

  Widget _unitQuantityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Unit & Stock Settings'),
        const SizedBox(height: 16),

        Obx(() {
          final selectedUnitLabel =
              controller.selectedUnit.value ?? 'Select Unit *';

          return InkWell(
            onTap: () => _showUnitSearchBottomSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorsList.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.straighten_outlined,
                    color: colorsList.iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedUnitLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: colorsList.textColor,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorsList.iconColor,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.quantityController,
          hintText: 'Default quantity *',
          prefixIcon: Icons.unfold_more_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 16),

        Obx(
              () => _switchRow(
            title: 'Track Stock Quantity',
            value: controller.trackStock.value,
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
              AppTextField(
                controller: controller.stockController,
                hintText: 'Current stock quantity',
                prefixIcon: Icons.inventory_outlined,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: controller.minimumStockController,
                hintText: 'Minimum stock alert level',
                prefixIcon: Icons.warning_amber_rounded,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Pricing
  // ---------------------------------------------------------------------------

  Widget _pricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Pricing Details'),
        const SizedBox(height: 16),
        AppTextField(
          controller: controller.salePriceController,
          hintText: 'Sale price net (€)',
          prefixIcon: Icons.sell_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.costPriceController,
          hintText: 'Purchase / Cost price net (€)',
          prefixIcon: Icons.shopping_bag_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.vatController,
          hintText: 'VAT rate (%)',
          prefixIcon: Icons.percent_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.discountController,
          hintText: 'Discount (%)',
          prefixIcon: Icons.discount_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.msrpController,
          hintText: 'MSRP price (€)',
          prefixIcon: Icons.price_change_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: colorsList.textColor,
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorsList.colorBoxDecoration),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: colorsList.textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showUnitSearchBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    controller.updateUnitSearchQuery('');

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    'Select Unit',
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
              controller: searchController,
              hintText: 'Search unit (e.g. hour, kg, pc)...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) {
                controller.updateUnitSearchQuery(val);
              },
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
                          fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorsList.primaryColor
                              : colorsList.textColor,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check_circle_rounded,
                        color: colorsList.primaryColor,
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
      isScrollControlled: true,
    );
  }
}