import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  bool checkLoginProgressbar = false;

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController vatIdController = TextEditingController();

  final TextEditingController endpointIdController =
  TextEditingController();

  final TextEditingController ibanController = TextEditingController();
  final TextEditingController accountHolderController =
  TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? selectedSchemeId;
  String? selectedCountry;

  // ==============================================================
  // DROPDOWN DATA
  // ==============================================================

  static const List<String> schemeIds = [
    '0088 - GLN',
    '0096 - DUNS',
    '9914 - Austrian VAT',
    '9915 - Austrian tax number',
    '9930 - Austrian business register',
    '9948 - VAT identification number',
  ];

  static const List<String> countries = [
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

  // ==============================================================
  // DISPOSE
  // ==============================================================

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

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack(
          children: [

            // ==========================================================
            // TOP RIGHT DECORATION
            // ==========================================================

            Positioned(
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: TopCurveClipper(),
                child: Container(
                  width: width * 0.70,
                  height: height * 0.28,
                  color: const Color(0xFFEAF3FB),
                ),
              ),
            ),

            // ==========================================================
            // MAIN CONTENT
            // ==========================================================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.07,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: height * 0.025),

                    // ==================================================
                    // BACK BUTTON
                    // ==================================================

                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },

                      child: Container(
                        width: width * 0.11,
                        height: width * 0.11,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(
                            width * 0.035,
                          ),

                          border: Border.all(
                            color: const Color(0xFFD2DDEB),
                            width: 1.2,
                          ),
                        ),

                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF0A2342),
                          size: width * 0.045,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // PAGE TITLE
                    // ==================================================

                    Text(
                      "Add Client",
                      style: TextStyle(
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A2342),
                      ),
                    ),

                    SizedBox(height: height * 0.008),

                    Text(
                      "Create a new client and manage their information.",
                      style: TextStyle(
                        fontSize: width * 0.040,
                        color: const Color(0xFF60728D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // 1. MASTER DATA
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.business_outlined,
                      title: "MASTER DATA",
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Name",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: nameController,
                      hintText: "Client name",
                      icon: Icons.business_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "VAT ID",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: vatIdController,
                      hintText: "e.g. ATU12345678",
                      icon: Icons.receipt_long_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.025),

                    // ==================================================
                    // E-INVOICE INFORMATION
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.all(
                        width * 0.045,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8FC),

                        borderRadius: BorderRadius.circular(
                          width * 0.035,
                        ),

                        border: Border.all(
                          color: const Color(0xFFDCE7F2),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Icon(
                                Icons.receipt_long_outlined,
                                color: const Color(0xFF063C70),
                                size: width * 0.060,
                              ),

                              SizedBox(width: width * 0.025),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      "E-Invoice (AT / PEPPOL)",
                                      style: TextStyle(
                                        color: const Color(0xFF0A2342),
                                        fontSize: width * 0.043,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    SizedBox(
                                      height: height * 0.006,
                                    ),

                                    Text(
                                      "For B2G in Austria (PEPPOL), "
                                          "EndpointID + schemeID are required.",
                                      style: TextStyle(
                                        color: const Color(0xFF60728D),
                                        fontSize: width * 0.034,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: height * 0.020),

                          // SCHEME ID

                          _fieldLabel(
                            "Scheme ID",
                            width,
                          ),

                          SizedBox(height: height * 0.008),

                          _dropdownField(
                            hintText: "Select Scheme ID",
                            value: selectedSchemeId,
                            items: schemeIds,
                            icon: Icons.tag_outlined,
                            width: width,
                            height: height,

                            onChanged: (value) {
                              setState(() {
                                selectedSchemeId = value;
                              });
                            },
                          ),

                          SizedBox(height: height * 0.018),

                          // ENDPOINT ID

                          _fieldLabel(
                            "Endpoint ID",
                            width,
                          ),

                          SizedBox(height: height * 0.008),

                          _textField(
                            controller: endpointIdController,
                            hintText: "Enter Endpoint ID",
                            icon: Icons.fingerprint_rounded,
                            width: width,
                            height: height,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // 2. PAYMENT
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.account_balance_outlined,
                      title: "PAYMENT",
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "IBAN",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: ibanController,
                      hintText: "Enter IBAN",
                      icon: Icons.account_balance_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Account Holder",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: accountHolderController,
                      hintText: "Account holder name",
                      icon: Icons.person_outline_rounded,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // 3. CONTACT
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.contact_mail_outlined,
                      title: "CONTACT",
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Email",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: emailController,
                      hintText: "client@example.com",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Phone",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: phoneController,
                      hintText: "Phone number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // 4. ADDRESS
                    // ==================================================

                    _sectionHeader(
                      icon: Icons.location_on_outlined,
                      title: "ADDRESS",
                      width: width,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Address 1",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: address1Controller,
                      hintText: "Street and house number",
                      icon: Icons.location_on_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Address 2",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: address2Controller,
                      hintText: "Apartment, floor, etc. (optional)",
                      icon: Icons.location_city_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "ZIP",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: zipController,
                      hintText: "ZIP / Postal code",
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "City",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _textField(
                      controller: cityController,
                      hintText: "City",
                      icon: Icons.location_city_outlined,
                      width: width,
                      height: height,
                    ),

                    SizedBox(height: height * 0.018),

                    _fieldLabel(
                      "Country",
                      width,
                    ),

                    SizedBox(height: height * 0.008),

                    _dropdownField(
                      hintText: "Select Country",
                      value: selectedCountry,
                      items: countries,
                      icon: Icons.public_outlined,
                      width: width,
                      height: height,

                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                    ),

                    SizedBox(height: height * 0.035),

                    // ==================================================
                    // SAVE CLIENT BUTTON
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: height * 0.070,

                      child: ElevatedButton.icon(
                        onPressed: () {

                          // TODO:
                          // Add your API / database logic here.

                          Get.back();
                        },

                        icon: const Icon(
                          Icons.person_add_alt_1_rounded,
                        ),

                        label: Text(
                          "Save Client",
                          style: TextStyle(
                            fontSize: width * 0.043,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF063C70),
                          foregroundColor: Colors.white,
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              width * 0.035,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.045),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SECTION HEADER
  // ==============================================================

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required double width,
  }) {
    return Row(
      children: [

        Container(
          width: width * 0.105,
          height: width * 0.105,

          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FB),
            borderRadius: BorderRadius.circular(
              width * 0.03,
            ),
          ),

          child: Icon(
            icon,
            color: const Color(0xFF063C70),
            size: width * 0.055,
          ),
        ),

        SizedBox(width: width * 0.025),

        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF0A2342),
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // FIELD LABEL
  // ==============================================================

  Widget _fieldLabel(
      String title,
      double width,
      ) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF172A46),
        fontSize: width * 0.037,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ==============================================================
  // TEXT FIELD
  // ==============================================================

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double width,
    required double height,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: TextStyle(
          color: const Color(0xFF71829A),
          fontSize: width * 0.040,
        ),

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF344E6F),
          size: width * 0.060,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(
          vertical: height * 0.019,
          horizontal: width * 0.04,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFFD2DDEB),
            width: 1.3,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFFD2DDEB),
            width: 1.3,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFF0B4380),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // DROPDOWN FIELD
  // ==============================================================

  Widget _dropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required IconData icon,
    required double width,
    required double height,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,

      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFF344E6F),
        size: width * 0.065,
      ),

      hint: Text(
        hintText,
        style: TextStyle(
          color: const Color(0xFF71829A),
          fontSize: width * 0.040,
        ),
      ),

      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF344E6F),
          size: width * 0.060,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: EdgeInsets.symmetric(
          vertical: height * 0.019,
          horizontal: width * 0.04,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFFD2DDEB),
            width: 1.3,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFFD2DDEB),
            width: 1.3,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            width * 0.035,
          ),

          borderSide: const BorderSide(
            color: Color(0xFF0B4380),
            width: 1.5,
          ),
        ),
      ),

      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,

          child: Text(
            item,
            style: TextStyle(
              color: const Color(0xFF172A46),
              fontSize: width * 0.040,
            ),
          ),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}