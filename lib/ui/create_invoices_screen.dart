import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
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
  final CreateInvoiceController controllerCreateInvoice = Get.put(CreateInvoiceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        final currentStep = controllerCreateInvoice.currentStep.value;

        return Stepper(
          type: StepperType.horizontal,
          currentStep: currentStep,
          onStepTapped: controllerCreateInvoice.goToStep,
          onStepContinue: controllerCreateInvoice.nextStep,
          onStepCancel: controllerCreateInvoice.previousStep,
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
      )
  {
    final isFirstStep = controllerCreateInvoice.currentStep.value == 0;
    final isLastStep =
        controllerCreateInvoice.currentStep.value == controllerCreateInvoice.totalSteps - 1;

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
              final isLoading = controllerCreateInvoice.isLoading.value;

              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colorsList.primaryColor,
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
            dropdownItems: controllerCreateInvoice.companyNames,
            selectedValue:
            controllerCreateInvoice.selectedCompany.value?.name,
            onDropdownChanged:
            controllerCreateInvoice.selectCompanyByName,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
              () => _infoField(
            icon: Icons.email_outlined,
            text: controllerCreateInvoice.sessionEmail.value.isEmpty
                ? 'No email available'
                : controllerCreateInvoice.sessionEmail.value,
          ),
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
            hintText: controllerCreateInvoice.isLoading.value
                ? 'Loading clients...'
                : 'Select client',
            prefixIcon: Icons.person_search_outlined,
            dropdownItems: controllerCreateInvoice.clientNames,
            selectedValue: controllerCreateInvoice.selectedClientName.value,
            onDropdownChanged: controllerCreateInvoice.selectClient,
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: controllerCreateInvoice.customerController,
          hintText: 'Customer / Company',
          prefixIcon: Icons.business_outlined,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controllerCreateInvoice.addressController,
          hintText: 'Street / Address',
          prefixIcon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controllerCreateInvoice.zipController,
                hintText: 'ZIP',
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: controllerCreateInvoice.cityController,
                hintText: 'City',
                prefixIcon: Icons.location_city_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controllerCreateInvoice.attnController,
          hintText: 'Attn',
          prefixIcon: Icons.person_outline_rounded,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controllerCreateInvoice.emailController,
          hintText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller: controllerCreateInvoice.phoneController,
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
            value: controllerCreateInvoice.autoGenerate.value,
            onChanged: controllerCreateInvoice.toggleAutoGenerate,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
              () => AppTextField(
            controller: controllerCreateInvoice.invoiceNumberController,
            hintText: controllerCreateInvoice.autoGenerate.value
                ? 'Invoice number will be generated automatically'
                : 'Invoice number',
            prefixIcon: Icons.receipt_long_outlined,
            readOnly: controllerCreateInvoice.autoGenerate.value,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllerCreateInvoice.invoiceDateController,
          hintText: 'Invoice date',
          prefixIcon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: controllerCreateInvoice.selectInvoiceDate,
        ),
        const SizedBox(height: 12),
                 // ==========================================================
          // VAT
          // ==========================================================

        Obx(
              () => _switchRow(
            title: 'Enable VAT',
            value: controllerCreateInvoice.enableVat.value,
            onChanged: controllerCreateInvoice.toggleEnableVat,
          ),
        ),

        Obx(
              () => controllerCreateInvoice.enableVat.value
              ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppTextField(
              controller:
              controllerCreateInvoice.vatRateController,
              hintText: 'VAT rate (%)',
              prefixIcon: Icons.percent_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          )
              : const SizedBox.shrink(),
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

        Obx(
              () => InkWell(
            onTap: () => _showCatalogSearch(),
            borderRadius: BorderRadius.circular(8),
            child: IgnorePointer(
              child: AppTextField(
                controller:
                controllerCreateInvoice.descriptionController,
                hintText: controllerCreateInvoice.isLoading.value
                    ? 'Loading catalog...'
                    : 'Search catalog item',
                prefixIcon: Icons.description_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        /*Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller:
                controllerCreateInvoice.quantityController,
                hintText: 'Quantity',
                prefixIcon:
                Icons.numbers_outlined,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Obx(
                    () => AppTextField(
                  isDropdown: true,
                  hintText: 'Select Unit',
                  prefixIcon: Icons.straighten_outlined,
                  dropdownItems: controllerCreateInvoice.unitNames,
                  selectedValue: controllerCreateInvoice.selectedUnit.value?.label,
                  onDropdownChanged: controllerCreateInvoice.selectUnit,
                ),
              ),
            ),
          ],
        ),*/

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller:
                controllerCreateInvoice.quantityController,
                hintText: 'Quantity',
                prefixIcon: Icons.numbers_outlined,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),

            SizedBox(width: 7),

            Expanded(
              child: Obx(
                    () => AppTextField(
                  isDropdown: true,
                  hintText: 'Select Unit',
                  prefixIcon: Icons.straighten_outlined,
                  dropdownItems:
                  controllerCreateInvoice.unitNames,
                  selectedValue:
                  controllerCreateInvoice
                      .selectedUnit
                      .value
                      ?.label,
                  onDropdownChanged:
                  controllerCreateInvoice.selectUnit,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppTextField(
          controller:
          controllerCreateInvoice.unitPriceController,
          hintText: 'Unit price',
          prefixIcon: Icons.euro_outlined,
          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
            controllerCreateInvoice.addLine,
            icon: const Icon(
              Icons.add,
              size: 19,
            ),
            label: const Text('Add line'),
            style: OutlinedButton.styleFrom(
              minimumSize:
              const Size.fromHeight(46),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8),
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
          controller: controllerCreateInvoice.closingTextController,
          hintText: 'Enter closing text',
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
        ),

        const SizedBox(height: 16),

        /*Obx(
              () => _switchRow(
            title: 'Recurring invoice',
            value: controllerCreateInvoice.recurringInvoice.value,
            onChanged: controllerCreateInvoice.toggleRecurringInvoice,
          ),
        ),*/
      ],
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      if (controllerCreateInvoice.lineItems.isEmpty) {
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
          controllerCreateInvoice.lineItems.length,
              (index) => _itemRow(
            index,
                controllerCreateInvoice.lineItems[index],
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
              color: colorsList.borderColor,
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
              '€${controllerCreateInvoice.subtotal.toStringAsFixed(2)}',
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
      )
  {
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
            color: colorsList.borderColor,
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
                    color: colorsList.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity $unit × €${unitPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: colorsList.secondaryTextColor,
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
            onPressed: () => controllerCreateInvoice.removeLine(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
            ),
            color: colorsList.secondaryTextColor,
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
        color: colorsList.textColor,
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
            color: colorsList.secondaryTextColor,
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
          color: colorsList.borderColor,
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

  void _showCatalogSearch() {
    final searchController = TextEditingController();
    final searchText = ''.obs;
    final filteredItems = <CatalogModel>[].obs;

    filteredItems.assignAll(
      controllerCreateInvoice.catalogList,
    );

    void search(String value) {
      searchText.value = value;

      final query = value.trim().toLowerCase();

      if (query.isEmpty) {
        filteredItems.assignAll(
          controllerCreateInvoice.catalogList,
        );
        return;
      }

      filteredItems.assignAll(
        controllerCreateInvoice.catalogList.where(
              (item) {
            final name =
                item.articleName?.toLowerCase() ?? '';

            return name.contains(query);
          },
        ),
      );
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Catalog Item',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ======================================================
            // SEARCH
            // ======================================================

            TextField(
              controller: searchController,
              onChanged: search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search item or enter manually',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ======================================================
            // RESULTS
            // ======================================================

            Expanded(
              child: Obx(
                    () {
                  final query = searchText.value.trim();

                  return ListView(
                    children: [
                      // ==================================================
                      // MANUAL ENTRY
                      // ==================================================

                      if (query.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.edit_outlined,
                          ),
                          title: Text(
                            'Use "$query"',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: const Text(
                            'Add this item manually',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          onTap: () {
                            controllerCreateInvoice
                                .descriptionController
                                .text = query;

                            Get.back();
                          },
                        ),

                      if (query.isNotEmpty)
                        const Divider(height: 1),

                      // ==================================================
                      // CATALOG ITEMS
                      // ==================================================

                      if (filteredItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                          ),
                          child: Center(
                            child: Text(
                              query.isEmpty
                                  ? 'No catalog items available.'
                                  : 'No catalog item found.',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredItems.map(
                              (item) {
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding:
                                  EdgeInsets.zero,
                                  title: Text(
                                    item.articleName ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _catalogSubtitle(item),
                                  ),
                                  onTap: () {
                                    controllerCreateInvoice
                                        .selectCatalogItem(
                                      item.articleName,
                                    );

                                    Get.back();
                                  },
                                ),
                                const Divider(
                                  height: 1,
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _catalogSubtitle(CatalogModel item) {
    final unit = item.unitCode?.trim() ?? '';

    final price =
        item.unitPriceNet?.toString() ?? '';

    if (unit.isEmpty && price.isEmpty) {
      return '';
    }

    if (unit.isEmpty) {
      return '€$price';
    }

    if (price.isEmpty) {
      return unit;
    }

    return '$unit • €$price';
  }
}