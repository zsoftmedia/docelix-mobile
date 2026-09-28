import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final CreateInvoiceController controller =
  Get.put(CreateInvoiceController());

  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color primaryColor = Color(0xFF0A2342);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondaryTextColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        final currentStep = controller.currentStep.value;

        return Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepTapped: controller.goToStep,
          onStepContinue: controller.nextStep,
          onStepCancel: controller.previousStep,
          elevation: 0,
          margin: EdgeInsets.zero,
          controlsBuilder: _buildControls,
          steps: [
            Step(
              title: const Text(
                'Sender',
                style: TextStyle(fontSize: 11),
              ),
              isActive: currentStep >= 0,
              state: currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: _senderStep(),
            ),
            Step(
              title: const Text(
                'Client',
                style: TextStyle(fontSize: 11),
              ),
              isActive: currentStep >= 1,
              state: currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: _clientStep(),
            ),
            Step(
              title: const Text(
                'Invoice',
                style: TextStyle(fontSize: 11),
              ),
              isActive: currentStep >= 2,
              state: currentStep > 2
                  ? StepState.complete
                  : StepState.indexed,
              content: _invoiceStep(),
            ),
            Step(
              title: const Text(
                'Items',
                style: TextStyle(fontSize: 11),
              ),
              isActive: currentStep >= 3,
              state: StepState.indexed,
              content: _itemsStep(),
            ),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        'Create Invoice',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildControls(
      BuildContext context,
      ControlsDetails details,
      ) {
    final isFirstStep = controller.currentStep.value == 0;
    final isLastStep =
        controller.currentStep.value == controller.totalSteps - 1;

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
                  side: const BorderSide(
                    color: Color(0xFFD1D5DB),
                  ),
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
                onPressed: isLoading
                    ? null
                    : details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: primaryColor,
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
                  isLastStep ? 'Save Invoice' : 'Next',
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
  // Sender
  // ---------------------------------------------------------------------------

  Widget _senderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sender Details'),
        const SizedBox(height: 16),
        Obx(
              () => AppTextField(
            isDropdown: true,
            hintText: 'Select sender',
            prefixIcon: Icons.business_outlined,
            dropdownItems: controller.senders,
            selectedValue: controller.selectedSender.value,
            onDropdownChanged: controller.selectSender,
          ),
        ),
        const SizedBox(height: 12),
        _infoField(
          icon: Icons.email_outlined,
          text: SessionManager.email ?? '',
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Client
  // ---------------------------------------------------------------------------

  Widget _clientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Client Details'),
        const SizedBox(height: 16),
        Obx(
              () => AppTextField(
            isDropdown: true,
            hintText: controller.isLoading.value
                ? 'Loading clients...'
                : 'Select client',
            prefixIcon: Icons.person_search_outlined,
            dropdownItems: controller.clientNames,
            selectedValue: controller.selectedClientName.value,
            onDropdownChanged: controller.selectClient,
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: controller.customerController,
          hintText: 'Customer / Company',
          prefixIcon: Icons.business_outlined,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.addressController,
          hintText: 'Street / Address',
          prefixIcon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller.zipController,
                hintText: 'ZIP',
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: controller.cityController,
                hintText: 'City',
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.attnController,
          hintText: 'Attn',
          prefixIcon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.emailController,
          hintText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.phoneController,
          hintText: 'Phone',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Invoice
  // ---------------------------------------------------------------------------

  Widget _invoiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Invoice Details'),
        const SizedBox(height: 16),
        Obx(
              () => _switchRow(
            title: 'Auto generate invoice number',
            value: controller.autoGenerate.value,
            onChanged: controller.toggleAutoGenerate,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
              () => AppTextField(
            controller: controller.invoiceNumberController,
            hintText: controller.autoGenerate.value
                ? 'Invoice number will be generated automatically'
                : 'Invoice number',
            prefixIcon: Icons.receipt_long_outlined,
            readOnly: controller.autoGenerate.value,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.invoiceDateController,
          hintText: 'Invoice date',
          prefixIcon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: controller.selectInvoiceDate,
        ),
        const SizedBox(height: 12),
        Obx(
              () => _switchRow(
            title: 'Enable VAT',
            value: controller.enableVat.value,
            onChanged: controller.toggleEnableVat,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Items
  // ---------------------------------------------------------------------------

  Widget _itemsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Line Items'),
        const SizedBox(height: 16),

        AppTextField(
          controller: controller.descriptionController,
          hintText: 'Description',
          prefixIcon: Icons.description_outlined,
        ),
        const SizedBox(height: 12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: controller.quantityController,
                hintText: 'Quantity',
                prefixIcon: Icons.numbers_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                    () => AppTextField(
                  isDropdown: true,
                  hintText: 'Unit',
                  prefixIcon: Icons.straighten_outlined,
                  dropdownItems: controller.units,
                  selectedValue: controller.selectedUnit.value,
                  onDropdownChanged: controller.selectUnit,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.unitPriceController,
          hintText: 'Unit price',
          prefixIcon: Icons.euro_outlined,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.addLine,
            icon: const Icon(Icons.add, size: 19),
            label: const Text('Add line'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(
                color: Color(0xFFD1D5DB),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildItemsList(),

        const SizedBox(height: 12),

        _buildSubtotal(),

        const SizedBox(height: 20),

        _sectionTitle('Closing Text'),

        const SizedBox(height: 12),

        AppTextField(
          controller: controller.closingTextController,
          hintText: 'Enter closing text',
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),

        const SizedBox(height: 16),

        Obx(
              () => _switchRow(
            title: 'Recurring invoice',
            value: controller.recurringInvoice.value,
            onChanged: controller.toggleRecurringInvoice,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      if (controller.lineItems.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No items added yet.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        );
      }

      return Column(
        children: List.generate(
          controller.lineItems.length,
              (index) => _itemRow(
            index,
            controller.lineItems[index],
          ),
        ),
      );
    });
  }

  Widget _buildSubtotal() {
    return Obx(
          () => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          top: 14,
          bottom: 4,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: borderColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtotal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '€${controller.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Item Row
  // ---------------------------------------------------------------------------

  Widget _itemRow(
      int index,
      Map<String, dynamic> item,
      ) {
    final description = item['description']?.toString() ?? '';
    final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
    final unit = item['unit']?.toString() ?? '';
    final unitPrice = (item['unitPrice'] as num?)?.toDouble() ?? 0;
    final total = (item['total'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity $unit × €${unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '€${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => controller.removeLine(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
            ),
            color: secondaryTextColor,
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable Widgets
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _infoField({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: secondaryTextColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
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
}