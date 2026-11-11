import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/create_invoice_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
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
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildCustomHorizontalStepperHeader(context, currentStep, rs),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.isPhone ? rs.s(16) : rs.pagePaddingH,
                    vertical: rs.s(12),
                  ),
                  child: Column(
                    children: [
                      _buildCurrentStepContent(currentStep),
                      _buildControls(context, currentStep),
                    ],
                  ),
                ),
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

  Widget _buildCustomHorizontalStepperHeader(BuildContext context, int currentStep, ResponsiveMetrics rs) {
    final steps = ['Sender', 'Client', 'Details', 'Items', 'Recurring'];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: rs.s(12), horizontal: rs.s(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(steps.length, (index) {
            final isCurrent = currentStep == index;
            final isCompleted = currentStep > index;

            return GestureDetector(
              onTap: () => controllerCreateInvoice.goToStep(index),
              child: Row(
                children: [
                  Container(
                    width: rs.s(26),
                    height: rs.s(26),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colorsList.colorButton
                          : (isCurrent ? colorsList.colorButton : const Color(0xFFF1F5F9)),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? Icon(Icons.check_rounded, color: Colors.white, size: rs.s(16))
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : const Color(0xFF64748B),
                              fontSize: rs.sp(11),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  SizedBox(width: rs.s(6)),
                  Text(
                    steps[index],
                    style: TextStyle(
                      color: isCurrent ? const Color(0xFF0A2342) : const Color(0xFF64748B),
                      fontSize: rs.sp(12),
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: rs.s(20),
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: rs.s(8)),
                      color: isCompleted ? colorsList.colorButton : const Color(0xFFE2E8F0),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(int step) {
    switch (step) {
      case 0:
        return _senderStep();
      case 1:
        return _clientStep();
      case 2:
        return _serviceStep();
      case 3:
        return _itemsStep();
      case 4:
        return _recurringStep();
      default:
        return _senderStep();
    }
  }

  Widget _buildControls(BuildContext context, int currentStep) {
    final isFirstStep = currentStep == 0;
    final isLastStep = currentStep == controllerCreateInvoice.totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Row(
        children: [
          if (!isFirstStep) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: controllerCreateInvoice.previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
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
                    color: Color(0xFF334155),
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
                onPressed: isLoading ? null : controllerCreateInvoice.nextStep,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: colorsList.colorButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isLastStep ? 'Save Invoice' : 'Continue',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
        _sectionTitle('Sender Information'),
        const SizedBox(height: 16),

        Obx(
          () => InkWell(
            onTap: () => _showCompanySearch(),
            borderRadius: BorderRadius.circular(8),
            child: IgnorePointer(
              child: AppTextField(
                controller: TextEditingController(
                  text: controllerCreateInvoice.selectedCompany.value?.name ?? '',
                ),
                hintText: controllerCreateInvoice.isLoading.value
                    ? 'Loading senders...'
                    : 'Select sender (company)',
                prefixIcon: Icons.business_outlined,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Obx(() {
          final company = controllerCreateInvoice.selectedCompany.value;
          final userEmail = SessionManager.email ?? controllerCreateInvoice.sessionEmail.value;

          if (company == null) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A2342),
                            ),
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if ((company.city ?? '').isNotEmpty ||
                    (company.country ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFFDE68A)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        [company.city, company.country]
                            .where((e) => (e ?? '').isNotEmpty)
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
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
        _sectionTitle('Client Information'),
        const SizedBox(height: 16),

        Obx(
          () => InkWell(
            onTap: () => _showClientSearch(),
            borderRadius: BorderRadius.circular(8),
            child: IgnorePointer(
              child: AppTextField(
                controller: TextEditingController(
                  text: controllerCreateInvoice.selectedClientName.value ?? '',
                ),
                hintText: controllerCreateInvoice.isLoading.value
                    ? 'Loading clients...'
                    : 'Select client',
                prefixIcon: Icons.person_outline,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        AppTextField(
          controller: controllerCreateInvoice.customerController,
          hintText: 'Client / Company Name',
          prefixIcon: Icons.business_outlined,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllerCreateInvoice.addressController,
          hintText: 'Address Line',
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controllerCreateInvoice.zipController,
                hintText: 'ZIP Code',
                prefixIcon: Icons.markunread_mailbox_outlined,
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
          hintText: 'Attn / Contact Person',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllerCreateInvoice.emailController,
          hintText: 'Client Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controllerCreateInvoice.phoneController,
          hintText: 'Client Phone',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Service Step
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

        // ROW: SERVICE / DELIVERY DATE & CURRENCY
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

            // CURRENCY DROPDOWN
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

        // EXCHANGE RATE BOX (WHEN SELECTED CURRENCY != COMPANY CURRENCY e.g. INR)
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
        // VAT TREATMENT & EXEMPTIONS
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

        // EXPLANATORY VAT CARDS
        Obx(() {
          final treatment = controllerCreateInvoice.selectedVatTreatment.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
  // Recurring
  // ---------------------------------------------------------------------------

  Widget _recurringStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Recurring Schedule'),
        const SizedBox(height: 16),

        // HEADER ROW WITH SWITCH
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Obx(
            () => Row(
              children: [
                const Icon(Icons.sync_rounded, color: Color(0xFF063C70), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Recurring invoice',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                ),
                Text(
                  'Enable recurring invoice',
                  style: TextStyle(
                    fontSize: 12,
                    color: controllerCreateInvoice.recurringInvoice.value
                        ? const Color(0xFF063C70)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: controllerCreateInvoice.recurringInvoice.value,
                  activeThumbColor: const Color(0xFF063C70),
                  onChanged: controllerCreateInvoice.toggleRecurringInvoice,
                ),
              ],
            ),
          ),
        ),

        // CONDITIONAL FORM FIELDS (SHOWN WHEN RECURRING INVOICE IS ENABLED)
        Obx(() {
          if (!controllerCreateInvoice.recurringInvoice.value) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ROW 1: FREQUENCY, REPEAT EVERY, START DATE
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;

                  final frequencyWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequency',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorsList.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controllerCreateInvoice.recurringFrequency.value,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              items: CreateInvoiceController.recurringFrequencyOptions.map((opt) {
                                return DropdownMenuItem<String>(
                                  value: opt,
                                  child: Text(opt, style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342))),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) controllerCreateInvoice.setFrequency(val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                  final repeatEveryWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Repeat every',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => TextFormField(
                          controller: controllerCreateInvoice.repeatEveryController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                controllerCreateInvoice.repeatEveryUnitLabel,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: colorsList.borderColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                  final startDateWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controllerCreateInvoice.recurringStartDateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.'
                                '${picked.month.toString().padLeft(2, '0')}.'
                                '${picked.year}';
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colorsList.borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controllerCreateInvoice.recurringStartDateController.text.isNotEmpty
                                    ? controllerCreateInvoice.recurringStartDateController.text
                                    : 'Select date',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                              ),
                              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: frequencyWidget),
                        const SizedBox(width: 10),
                        Expanded(child: repeatEveryWidget),
                        const SizedBox(width: 10),
                        Expanded(child: startDateWidget),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: frequencyWidget),
                          const SizedBox(width: 10),
                          Expanded(child: repeatEveryWidget),
                        ],
                      ),
                      const SizedBox(height: 12),
                      startDateWidget,
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // ROW 2: ENDS DROPDOWN & CONDITIONAL END FIELD
              Obx(() {
                final endsOption = controllerCreateInvoice.recurringEndsOption.value;

                final endsWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ends',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colorsList.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: endsOption,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: CreateInvoiceController.recurringEndsOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt, style: const TextStyle(fontSize: 14, color: Color(0xFF0A2342))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controllerCreateInvoice.setEndsOption(val);
                          },
                        ),
                      ),
                    ),
                  ],
                );

                Widget? conditionalEndWidget;

                if (endsOption == 'On a date') {
                  conditionalEndWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End date',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controllerCreateInvoice.recurringEndDateController.text =
                                '${picked.day.toString().padLeft(2, '0')}.'
                                '${picked.month.toString().padLeft(2, '0')}.'
                                '${picked.year}';
                            setState(() {});
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                  controllerCreateInvoice.recurringEndDateController.text.isNotEmpty
                                      ? controllerCreateInvoice.recurringEndDateController.text
                                      : 'Select date',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0A2342)),
                                ),
                              ),
                              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (endsOption == 'After a number of invoices') {
                  conditionalEndWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total invoices',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: controllerCreateInvoice.recurringTotalInvoicesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: colorsList.borderColor),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (conditionalEndWidget != null) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: endsWidget),
                        const SizedBox(width: 12),
                        Expanded(child: conditionalEndWidget),
                      ],
                    );
                  }

                  return endsWidget;
                },
              ),

              const SizedBox(height: 16),

              // ROW 3: AUTOMATICALLY EMAIL SWITCH
              Obx(
                () => _switchRow(
                  title: 'Automatically email each invoice when it is generated',
                  value: controllerCreateInvoice.autoEmailGeneratedInvoice.value,
                  onChanged: (val) => controllerCreateInvoice.autoEmailGeneratedInvoice.value = val,
                ),
              ),
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
                controller: controllerCreateInvoice.descriptionController,
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
                controller: controllerCreateInvoice.quantityController,
                hintText: 'Qty',
                prefixIcon: Icons.pin_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => InkWell(
                  onTap: () => _showUnitSearch(),
                  borderRadius: BorderRadius.circular(8),
                  child: IgnorePointer(
                    child: AppTextField(
                      controller: controllerCreateInvoice.unitController,
                      hintText: controllerCreateInvoice.isLoading.value
                          ? 'Loading units...'
                          : 'Unit',
                      prefixIcon: Icons.straighten_outlined,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        AppTextField(
          controller: controllerCreateInvoice.unitPriceController,
          hintText: 'Unit Price',
          prefixIcon: Icons.attach_money_outlined,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: controllerCreateInvoice.addLine,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorsList.colorButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Line Item',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Line Items List
        Obx(() {
          if (controllerCreateInvoice.lineItems.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorsList.borderColor),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.format_list_bulleted_outlined,
                    size: 36,
                    color: colorsList.textHintColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No items added yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorsList.textHintColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: List.generate(
              controllerCreateInvoice.lineItems.length,
              (index) {
                final item = controllerCreateInvoice.lineItems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorsList.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['description']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: colorsList.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item['quantity']} ${item['unit']} x ${controllerCreateInvoice.formatCurrency(item['unit_price'] as num?, null)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: colorsList.textHintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        controllerCreateInvoice.formatCurrency(
                          item['gross_amount'] as num?,
                          null,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorsList.textColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => controllerCreateInvoice.removeLine(index),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),

        const SizedBox(height: 16),

        // Subtotal Card
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorsList.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorsList.textColor,
                  ),
                ),
                Text(
                  controllerCreateInvoice.formatCurrency(
                    controllerCreateInvoice.subtotal,
                    controllerCreateInvoice.selectedCurrency.value,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorsList.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _sectionTitle('Closing Text'),
        const SizedBox(height: 8),
        AppTextField(
          controller: controllerCreateInvoice.closingTextController,
          hintText: 'Enter closing text or notes (optional)',
          prefixIcon: Icons.notes_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Search Bottom Sheets
  // ---------------------------------------------------------------------------

  void _showCompanySearch() {
    controllerCreateInvoice.getCompanies();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Sender Company',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorsList.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Obx(() {
                if (controllerCreateInvoice.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  );
                }

                if (controllerCreateInvoice.companies.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No companies available'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controllerCreateInvoice.companies.length,
                  itemBuilder: (context, index) {
                    final company = controllerCreateInvoice.companies[index];

                    return ListTile(
                      title: Text(company.name),
                      subtitle: Text(
                        [company.city, company.country]
                            .where((e) => (e ?? '').isNotEmpty)
                            .join(', '),
                      ),
                      onTap: () {
                        controllerCreateInvoice.selectCompany(company);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showClientSearch() {
    controllerCreateInvoice.clientSearchQuery.value = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorsList.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: controllerCreateInvoice.updateClientSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search client name, email, phone...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Obx(() {
                if (controllerCreateInvoice.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  );
                }

                final list = controllerCreateInvoice.filteredClients;

                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No clients found'),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final client = list[index];

                      return ListTile(
                        title: Text(client.name),
                        subtitle: Text(
                          [client.email, client.phone, client.city]
                              .where((e) => (e ?? '').isNotEmpty)
                              .join(' • '),
                        ),
                        onTap: () {
                          controllerCreateInvoice.selectClientByModel(client);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCatalogSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Item from Catalog',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorsList.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Obx(() {
                if (controllerCreateInvoice.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  );
                }

                if (controllerCreateInvoice.catalogList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No catalog items available'),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: controllerCreateInvoice.catalogList.length,
                    itemBuilder: (context, index) {
                      final item = controllerCreateInvoice.catalogList[index];

                      return ListTile(
                        title: Text(item.articleName ?? 'Item'),
                        subtitle: Text(
                          'Price: ${item.unitPriceNet ?? 0.0} ${item.unitCode ?? ''}',
                        ),
                        onTap: () {
                          controllerCreateInvoice.selectCatalogItem(item.articleName);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitSearch() {
    controllerCreateInvoice.unitSearchQuery.value = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Unit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorsList.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: controllerCreateInvoice.updateUnitSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search unit...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Obx(() {
                final list = controllerCreateInvoice.filteredUnits;

                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No units found'),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final unitLabel = list[index];

                      return ListTile(
                        title: Text(unitLabel),
                        onTap: () {
                          controllerCreateInvoice.selectUnit(unitLabel);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorsList.textColor,
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorsList.textColor,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: colorsList.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}