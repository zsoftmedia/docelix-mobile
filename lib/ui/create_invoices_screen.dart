import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: _buildAppBar(rs),
      body: Obx(() {
        final currentStep = controllerCreateInvoice.currentStep.value;

        return ResponsivePage(
          padding: EdgeInsets.symmetric(
            horizontal: rs.isPhone ? 0 : rs.pagePaddingH,
          ),
          child: Stepper(
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
                title: Text(
                  'Sender',
                  style: TextStyle(fontSize: rs.sp(10)),
                ),
                isActive: currentStep >= 0,
                state: currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: _senderStep(),
              ),
              Step(
                title: Text(
                  'Client',
                  style: TextStyle(fontSize: rs.sp(10)),
                ),
                isActive: currentStep >= 1,
                state: currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: _clientStep(),
              ),
              Step(
                title: Text(
                  'Details',
                  style: TextStyle(fontSize: rs.sp(10)),
                ),
                isActive: currentStep >= 2,
                state: currentStep > 2
                    ? StepState.complete
                    : StepState.indexed,
                content: _serviceStep(),
              ),

              Step(
                title: Text(
                  'Items',
                  style: TextStyle(fontSize: rs.sp(10)),
                ),
                isActive: currentStep >= 3,
                state: StepState.indexed,
                content: _itemsStep(),
              ),
            ],
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(ResponsiveMetrics rs) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        onPressed: Get.back,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: rs.s(19),
        ),
      ),
      title: Text(
        'Create Invoice',
        style: TextStyle(
          fontSize: rs.sp(20),
          fontWeight: FontWeight.normal,
          color: colorsList.textColor,
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
                  side: BorderSide(
                    color: colorsList.borderColor,
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
        Obx(() {
          final client = controllerCreateInvoice.selectedClient.value;
          final displayText = client != null
              ? client.name
              : (controllerCreateInvoice.isLoading.value
                  ? 'Loading clients...'
                  : 'Select client');

          return InkWell(
            onTap: () => _showClientSearchBottomSheet(context),
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
                    Icons.person_search_outlined,
                    color: Color(0xFF4b4f57),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: client != null
                            ? const Color(0xFF172033)
                            : const Color(0xFFA8A8A8),
                        fontWeight: client != null
                            ? FontWeight.w600
                            : FontWeight.w400,
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
  // Service
  // ---------------------------------------------------------------------------

  void _showCurrencySheet(BuildContext context) {
    controllerCreateInvoice.currencySearchQuery.value = '';
    final searchInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height;
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            height: height * 0.65,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchInputController,
                    autofocus: true,
                    onChanged: (val) => controllerCreateInvoice.currencySearchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search currency code...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchInputController,
                        builder: (context, value, _) {
                          if (value.text.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              searchInputController.clear();
                              controllerCreateInvoice.currencySearchQuery.value = '';
                            },
                          );
                        },
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                Expanded(
                  child: Obx(() {
                    final list = controllerCreateInvoice.filteredCurrencies;
                    final selected = controllerCreateInvoice.selectedCurrency.value;

                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final currency = list[index];
                        final isSelected = selected == currency;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          title: Text(
                            currency,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                              : null,
                          onTap: () {
                            controllerCreateInvoice.selectCurrency(currency);
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVatTreatmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ResponsiveSheetBody(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VAT Treatment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A2342),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ...CreateInvoiceController.vatTreatmentOptions.map((opt) {
                    final isSelected = controllerCreateInvoice.selectedVatTreatment.value == opt;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0A2342),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20)
                          : null,
                      onTap: () {
                        controllerCreateInvoice.selectVatTreatment(opt);
                        Navigator.of(ctx).pop();
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Service Step
  // ---------------------------------------------------------------------------

  Widget _serviceStep() {
    if (controllerCreateInvoice.invoiceDateController.text.trim().isEmpty) {
      final now = DateTime.now();
      controllerCreateInvoice.invoiceDateController.text =
          '${now.day.toString().padLeft(2, '0')}.'
          '${now.month.toString().padLeft(2, '0')}.'
          '${now.year}';
    }

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

        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 16),

        // ROW: SERVICE / DELIVERY DATE & CURRENCY (MATCHING SCREENSHOT 1 & 3)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SERVICE DATE FIELD
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Service / delivery date',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '§ 11 UStG',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        controllerCreateInvoice.serviceDateController.text =
                            '${pickedDate.day.toString().padLeft(2, '0')}.'
                            '${pickedDate.month.toString().padLeft(2, '0')}.'
                            '${pickedDate.year}';
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              controllerCreateInvoice.serviceDateController.text.isNotEmpty
                                  ? controllerCreateInvoice.serviceDateController.text
                                  : 'Select date',
                              style: TextStyle(
                                fontSize: 14,
                                color: controllerCreateInvoice.serviceDateController.text.isNotEmpty
                                    ? const Color(0xFF0A2342)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // CURRENCY DROPDOWN (MATCHING SCREENSHOT 1 & 2)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => InkWell(
                      onTap: () => _showCurrencySheet(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorsList.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controllerCreateInvoice.selectedCurrency.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A2342),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // EXCHANGE RATE BOX (WHEN SELECTED CURRENCY != COMPANY CURRENCY e.g. INR) [SCREENSHOT 3]
        Obx(() {
          final selectedCurr = controllerCreateInvoice.selectedCurrency.value;
          final rateData = controllerCreateInvoice.exchangeRateData.value;
          final isLoadingRate = controllerCreateInvoice.isLoadingExchangeRate.value;

          if (selectedCurr == 'EUR' && rateData == null) {
            return const SizedBox.shrink();
          }

          if (isLoadingRate) {
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorsList.borderColor),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('Loading ECB exchange rate...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            );
          }

          if (rateData == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exchange rate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorsList.borderColor),
                ),
                child: Row(
                  children: [
                    Text(
                      '1 $selectedCurr = ',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    Expanded(
                      child: Text(
                        rateData.rate.toStringAsFixed(6),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342)),
                      ),
                    ),
                    Text(
                      rateData.quote,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ECB reference rate of ${rateData.requestedDate}: ${rateData.rate}. Used when left empty; fixed when the invoice is issued.',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
            ],
          );
        }),

        // ==========================================================
        // VAT TREATMENT & EXEMPTIONS (SCREENSHOTS 4, 5, 6, 7, 8)
        // ==========================================================
        const Text(
          'VAT treatment',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => InkWell(
            onTap: () => _showVatTreatmentSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorsList.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controllerCreateInvoice.selectedVatTreatment.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // EXPLANATORY VAT CARDS (MATCHING SCREENSHOTS 4, 5, 6, 7, 8)
        Obx(() {
          final treatment = controllerCreateInvoice.selectedVatTreatment.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BASE EXPLANATORY TEXT FOR NON-VAT REGISTERED COMPANY
              const Text(
                'Your company is set up as not VAT-registered, so this invoice cannot charge VAT. If you are VAT-registered, update it in the company settings.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 4),
              const Text(
                'VAT is set to 0% for this treatment. The required wording is included in the invoice.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),

              const SizedBox(height: 12),

              // OPTION 2: Exempt / zero-rated (reason required) [SCREENSHOT 4]
              if (treatment == 'Exempt / zero-rated (reason required)') ...[
                const Text(
                  'Exemption reason / legal basis',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controllerCreateInvoice.exemptionReasonController,
                  decoration: InputDecoration(
                    hintText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: colorsList.borderColor),
                    ),
                  ),
                ),
              ],

              // OPTION 3: Kleinunternehmer exemption [SCREENSHOT 5]
              if (treatment == 'Kleinunternehmer exemption') ...[
                Obx(
                  () => CheckboxListTile(
                    value: controllerCreateInvoice.isSmallBusinessConfirmed.value,
                    onChanged: (val) => controllerCreateInvoice.isSmallBusinessConfirmed.value = val ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF063C70),
                    title: const Text(
                      'I confirm that this company qualifies for the Austrian small-business exemption under § 6(1)(27) UStG',
                      style: TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                    ),
                  ),
                ),
                const Text(
                  'Check relevant company turnover for both the previous and current calendar year. The €55,000 threshold and statutory 10% tolerance determine when the exemption applies.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                ),
              ],

              // OPTION 4: Reverse charge [SCREENSHOT 6]
              if (treatment == 'Reverse charge' || treatment == 'Intra-EU supply of goods') ...[
                Obx(
                  () => CheckboxListTile(
                    value: controllerCreateInvoice.isViesChecked.value,
                    onChanged: (val) => controllerCreateInvoice.isViesChecked.value = val ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF063C70),
                    title: const Text(
                      'I have checked the customer UID in VIES',
                      style: TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://ec.europa.eu/taxation_customs/vies/#/vat-validation');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text(
                    'Open the official VIES checker',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],

              // OPTION 6: Export outside the EU [SCREENSHOT 8]
              if (treatment == 'Export outside the EU') ...[
                Obx(
                  () => CheckboxListTile(
                    value: controllerCreateInvoice.isExportEvidenceChecked.value,
                    onChanged: (val) => controllerCreateInvoice.isExportEvidenceChecked.value = val ?? false,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF063C70),
                    title: const Text(
                      'I have evidence that the goods left the EU',
                      style: TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),

        const SizedBox(height: 16),
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

            const SizedBox(width: 8),

            Expanded(
              child: Obx(() {
                final selected =
                    controllerCreateInvoice.currentSelectedUnitLabel ??
                        'Select Unit';

                return InkWell(
                  onTap: () => _showUnitSearchBottomSheet(context),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
                          Icons.straighten_outlined,
                          color: Color(0xFF4b4f57),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selected,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4b4f57),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF4b4f57),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
        fontSize: 18,
        fontWeight: FontWeight.normal,
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
        color: colorsList.colorBoxDecoration,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: colorsList.iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: colorsList.textColor,
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
          color: colorsList.colorBoxDecoration,
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
    controllerCreateInvoice.updateUnitSearchQuery('');

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
                controllerCreateInvoice.updateUnitSearchQuery(val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final list = controllerCreateInvoice.filteredUnits;

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
                        unitLabel == controllerCreateInvoice.currentSelectedUnitLabel;

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
                        controllerCreateInvoice.selectUnit(unitLabel);
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

  void _showClientSearchBottomSheet(BuildContext context) {
    final searchController = TextEditingController();
    controllerCreateInvoice.updateClientSearchQuery('');

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
                    'Select Client',
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
              hintText: 'Search client by name, email, city...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) {
                controllerCreateInvoice.updateClientSearchQuery(val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final list = controllerCreateInvoice.filteredClients;

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching clients found.',
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
                    final client = list[index];
                    final isSelected =
                        client.id == controllerCreateInvoice.selectedClient.value?.id;

                    final subtitleParts = <String>[];
                    if (client.email != null && client.email!.trim().isNotEmpty) {
                      subtitleParts.add(client.email!.trim());
                    }
                    if (client.city != null && client.city!.trim().isNotEmpty) {
                      subtitleParts.add(client.city!.trim());
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colorsList.colorBoxDecoration,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: colorsList.iconColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        client.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorsList.primaryColor
                              : colorsList.textColor,
                        ),
                      ),
                      subtitle: subtitleParts.isNotEmpty
                          ? Text(
                              subtitleParts.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: colorsList.textHintColor,
                              ),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: colorsList.primaryColor,
                              size: 22,
                            )
                          : null,
                      onTap: () {
                        controllerCreateInvoice.selectClientByModel(client);
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
      backgroundColor: Colors.transparent,
      ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
        height: Get.context!.rs.height * 0.75,
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
                  icon: const Icon(Icons.close,
                    color: colorsList.iconColor,),
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
                prefixIcon: Icon(Icons.search,
                  color: colorsList.iconColor,),
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
                            color: colorsList.iconColor,
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
                              color: colorsList.textColor,
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
                                color: colorsList.textHintColor,
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: colorsList.textColor
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
                                Divider(
                                  height: 1,
                                  color: colorsList.dividerColor,
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