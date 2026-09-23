import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final vatIdController = TextEditingController();
  final endpointIdController = TextEditingController();

  final ibanController = TextEditingController();
  final accountHolderController = TextEditingController();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();

  // ============================================================
  // DROPDOWN
  // ============================================================

  String? selectedSchemeId;
  String? selectedCountry;

  static const schemeIds = [
    '0088 - GLN',
    '0096 - DUNS',
    '9914 - Austrian VAT',
    '9915 - Austrian tax number',
    '9930 - Austrian business register',
    '9948 - VAT identification number',
  ];

  static const countries = [
    'Austria',
    'Germany',
    'Switzerland',
    'France',
    'Italy',
    'Netherlands',
    'Belgium',
    'United Kingdom',
    'United States',
    'Pakistan',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    vatIdController.dispose();
    endpointIdController.dispose();
    ibanController.dispose();
    accountHolderController.dispose();
    emailController.dispose();
    phoneController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    cityController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0A2342),
            size: 20,
          ),
        ),

        title: const Text(
          'Add Client',
          style: TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.07,
          vertical: 15,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Create a new client and manage their information.',
              style: TextStyle(
                fontSize: width * 0.040,
                color: const Color(0xFF60728D),
              ),
            ),

            const SizedBox(height: 30),

            // ====================================================
            // MASTER DATA
            // ====================================================

            _sectionTitle(
              icon: Icons.business_outlined,
              title: 'MASTER DATA',
            ),

            const SizedBox(height: 18),

            _label('Name'),

            const SizedBox(height: 8),

            AppTextField(
              controller: nameController,
              hintText: 'Client name',
              prefixIcon: Icons.business_outlined,
            ),

            const SizedBox(height: 18),

            _label('VAT ID'),

            const SizedBox(height: 8),

            AppTextField(
              controller: vatIdController,
              hintText: 'e.g. ATU12345678',
              prefixIcon: Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 30),

            // ====================================================
            // E-INVOICE
            // ====================================================

            _sectionTitle(
              icon: Icons.receipt_long_outlined,
              title: 'E-INVOICE (AT / PEPPOL)',
            ),

            const SizedBox(height: 18),

            _label('Scheme ID'),

            const SizedBox(height: 8),

            AppTextField(
              isDropdown: true,
              hintText: 'Select Scheme ID',
              prefixIcon: Icons.tag_outlined,
              dropdownItems: schemeIds,
              selectedValue: selectedSchemeId,
              onDropdownChanged: (value) {
                setState(() {
                  selectedSchemeId = value;
                });
              },
            ),

            const SizedBox(height: 18),

            _label('Endpoint ID'),

            const SizedBox(height: 8),

            AppTextField(
              controller: endpointIdController,
              hintText: 'Enter Endpoint ID',
              prefixIcon: Icons.fingerprint_rounded,
            ),

            const SizedBox(height: 30),

            // ====================================================
            // PAYMENT
            // ====================================================

            _sectionTitle(
              icon: Icons.account_balance_outlined,
              title: 'PAYMENT',
            ),

            const SizedBox(height: 18),

            _label('IBAN'),

            const SizedBox(height: 8),

            AppTextField(
              controller: ibanController,
              hintText: 'Enter IBAN',
              prefixIcon: Icons.account_balance_outlined,
            ),

            const SizedBox(height: 18),

            _label('Account Holder'),

            const SizedBox(height: 8),

            AppTextField(
              controller: accountHolderController,
              hintText: 'Account holder name',
              prefixIcon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 30),

            // ====================================================
            // CONTACT
            // ====================================================

            _sectionTitle(
              icon: Icons.contact_mail_outlined,
              title: 'CONTACT',
            ),

            const SizedBox(height: 18),

            _label('Email'),

            const SizedBox(height: 8),

            AppTextField(
              controller: emailController,
              hintText: 'client@example.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 18),

            _label('Phone'),

            const SizedBox(height: 8),

            AppTextField(
              controller: phoneController,
              hintText: 'Phone number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 30),

            // ====================================================
            // ADDRESS
            // ====================================================

            _sectionTitle(
              icon: Icons.location_on_outlined,
              title: 'ADDRESS',
            ),

            const SizedBox(height: 18),

            _label('Address 1'),

            const SizedBox(height: 8),

            AppTextField(
              controller: address1Controller,
              hintText: 'Street and house number',
              prefixIcon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 18),

            _label('Address 2'),

            const SizedBox(height: 8),

            AppTextField(
              controller: address2Controller,
              hintText: 'Apartment, floor, etc. (optional)',
              prefixIcon: Icons.location_city_outlined,
            ),

            const SizedBox(height: 18),

            _label('ZIP'),

            const SizedBox(height: 8),

            AppTextField(
              controller: zipController,
              hintText: 'ZIP / Postal code',
              prefixIcon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 18),

            _label('City'),

            const SizedBox(height: 8),

            AppTextField(
              controller: cityController,
              hintText: 'City',
              prefixIcon: Icons.location_city_outlined,
            ),

            const SizedBox(height: 18),

            _label('Country'),

            const SizedBox(height: 8),

            AppTextField(
              isDropdown: true,
              hintText: 'Select Country',
              prefixIcon: Icons.public_outlined,
              dropdownItems: countries,
              selectedValue: selectedCountry,
              onDropdownChanged: (value) {
                setState(() {
                  selectedCountry = value;
                });
              },
            ),

            const SizedBox(height: 35),

            // ====================================================
            // SAVE BUTTON
            // ====================================================

            AppButton(
              text: 'Save Client',

              icon: Icons.person_add_alt_1_rounded,

              height: 52,

              backgroundColor: const Color(0xFF063C70),

              foregroundColor: Colors.white,

              onPressed: () {
                // TODO: Save client through API

                Get.back();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF063C70),
          size: 22,
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF172A46),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
