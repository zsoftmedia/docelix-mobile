
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoicesScreen extends StatefulWidget {
  @override
  State<CreateInvoicesScreen> createState() => _CreateInvoicesScreenState();
}

class _CreateInvoicesScreenState extends State<CreateInvoicesScreen> {
  // var loginPage_Controller = Get.put(LoginPage_Ctrl());
  // final _formKey = GlobalKey<FormState>(); // GlobalKey to manage form state

  bool checkLoginProgressbar = false;
  bool _obscureText = true;

  static const List<String> registerAs = [
    'Accountant',
    'Tax Adviser',
    'Chief Financial Officer (CFO)',
    'Controller',
    'Accounting Manager',
    'Senior Accountant',
    'Financial Analyst',
    'Financial Consultant',
    'Bookkeeper',
    'Accounts Payable (AP) Clerk',
    'Accounts Receivable (AR) Clerk',
    'Payroll Administrator',
    'Tax Specialist',
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Stack(
          children: [

            // ----------------------------------------------------------
            // TOP RIGHT DECORATION
            // ----------------------------------------------------------
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

            // ----------------------------------------------------------
            // MAIN CONTENT
            // ----------------------------------------------------------
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.11,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // --------------------------------------------------
                    // BACK BUTTON
                    // --------------------------------------------------

                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0A2342),
                        size: width * 0.045,
                      ),

                    ),

                    SizedBox(height: height * 0.065),

                    // --------------------------------------------------
                    // LOGO
                    // --------------------------------------------------
                    Center(
                      child: Image.asset(
                        'assets/main_logo.png',
                        width: width * 0.68,
                        fit: BoxFit.contain,

                        // IMPORTANT:
                        // Don't use white ColorFilter here.
                      ),
                    ),

                    SizedBox(height: height * 0.075),

                    // --------------------------------------------------
                    // REGISTER NOW
                    // --------------------------------------------------
                    Text(
                      StringsList.txtbtnRegister,
                      style: TextStyle(
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A2342),
                      ),
                    ),

                    SizedBox(height: height * 0.001),

                    Text(
                      StringsList.txtRegister_desc,
                      style: TextStyle(
                        fontSize: width * 0.043,
                        color: const Color(0xFF60728D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: height * 0.025),

                    // --------------------------------------------------
                    // EMAIL
                    // --------------------------------------------------
                    TextFormField(
                      // controller:
                      // loginPage_Controller.identityController,

                      keyboardType: TextInputType.emailAddress,

                      decoration: InputDecoration(
                        hintText: "Email address",
                        hintStyle: TextStyle(
                          color: const Color(0xFF71829A),
                          fontSize: width * 0.043,
                        ),

                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: const Color(0xFF344E6F),
                          size: width * 0.065,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.021,
                          horizontal: width * 0.04,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFF0B4380),
                            width: 1.5,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: height * 0.021),

                    // --------------------------------------------------
                    // PASSWORD
                    // --------------------------------------------------
                    TextFormField(
                      // controller:
                      // loginPage_Controller.passwordController,

                      obscureText: _obscureText,

                      decoration: InputDecoration(
                        hintText: "Password",

                        hintStyle: TextStyle(
                          color: const Color(0xFF71829A),
                          fontSize: width * 0.043,
                        ),

                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: const Color(0xFF344E6F),
                          size: width * 0.065,
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },

                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color: const Color(0xFF344E6F),
                            size: width * 0.065,
                          ),
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.021,
                          horizontal: width * 0.04,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFF0B4380),
                            width: 1.5,
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: height * 0.010),

                    DropdownButtonFormField<String>(
                      value: null,

                      isExpanded: true,

                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF344E6F),
                        size: width * 0.065,
                      ),

                      hint: Text(
                        "Select Country",
                        style: TextStyle(
                          color: const Color(0xFF71829A),
                          fontSize: width * 0.043,
                        ),
                      ),

                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: EdgeInsets.symmetric(
                          vertical: height * 0.021,
                          horizontal: width * 0.04,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Color(0xFF0B4380),
                            width: 1.5,
                          ),
                        ),

                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.3,
                          ),
                        ),

                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            width * 0.04,
                          ),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                      ),

                      items: registerAs.map((country) {
                        return DropdownMenuItem<String>(
                          value: country,

                          child: Text(
                            country,
                            style: TextStyle(
                              color: const Color(0xFF172A46),
                              fontSize: width * 0.043,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {
                        // Handle selected country
                      },

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a country';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: height * 0.010),
                    // --------------------------------------------------
                    // REGISTER BUTTON
                    // --------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.070,

                      child: ElevatedButton(
                        onPressed: () async {

                          // Your existing login code goes here.

                        },

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

                        child: Text(
                          StringsList.txtRegister,
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.050),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}