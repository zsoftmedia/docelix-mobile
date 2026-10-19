import 'package:docelix_mobileapp/controllers/controller_auth/signup_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignupController signupController = Get.put(SignupController());
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

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    final radius = context.s(14);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colorsList.textColor,
        fontSize: context.sp(15),
      ),
      prefixIcon: Icon(
        prefix,
        color: colorsList.textColor,
        size: context.s(22),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        vertical: context.s(16),
        horizontal: context.s(14),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(
          color: colorsList.borderColor,
          width: 1.3,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(
          color: colorsList.borderColor,
          width: 1.3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(
          color: colorsList.primaryBlue,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                width: rs.isPhone ? rs.wp(0.70) : rs.s(320),
                height: rs.isPhone ? rs.hp(0.28) : rs.s(220),
                color: const Color(0xFFEAF3FB),
              ),
            ),
          ),
          ResponsiveAuthShell(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: rs.s(8)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: const Color(0xFF0A2342),
                      size: context.s(18),
                    ),
                  ),
                  SizedBox(height: rs.isPhone ? rs.hp(0.06) : rs.s(40)),
                  Center(
                    child: Image.asset(
                      'assets/main_logo.png',
                      width: rs.isPhone ? rs.wp(0.68) : rs.s(260),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: rs.isPhone ? rs.hp(0.06) : rs.s(40)),
                  Text(
                    StringsList.txtbtnRegister,
                    style: TextStyle(
                      fontSize: context.sp(28),
                      fontWeight: FontWeight.w700,
                      color: colorsList.textColor,
                    ),
                  ),
                  SizedBox(height: rs.s(4)),
                  Text(
                    StringsList.txtRegister_desc,
                    style: TextStyle(
                      fontSize: context.sp(15),
                      color: colorsList.mutedTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: rs.s(20)),
                  TextFormField(
                    controller: signupController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration(
                      context: context,
                      hint: 'Email address',
                      prefix: Icons.mail_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: rs.s(14)),
                  TextFormField(
                    controller: signupController.passwordController,
                    obscureText: _obscureText,
                    decoration: _fieldDecoration(
                      context: context,
                      hint: 'Password',
                      prefix: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() => _obscureText = !_obscureText);
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorsList.textColor,
                          size: context.s(22),
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
                  SizedBox(height: rs.s(10)),
                  DropdownButtonFormField<String>(
                    initialValue: null,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorsList.iconColor,
                      size: context.s(22),
                    ),
                    hint: Text(
                      'Select Country',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: context.sp(15),
                      ),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: context.s(16),
                        horizontal: context.s(14),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.s(14)),
                        borderSide: const BorderSide(
                          color: colorsList.borderColor,
                          width: 1.3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.s(14)),
                        borderSide: const BorderSide(
                          color: colorsList.borderColor,
                          width: 1.3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.s(14)),
                        borderSide: const BorderSide(
                          color: colorsList.focusedBorderColor,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.s(14)),
                        borderSide: const BorderSide(
                          color: colorsList.red,
                          width: 1.3,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.s(14)),
                        borderSide: const BorderSide(
                          color: colorsList.red,
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
                            color: colorsList.textColor,
                            fontSize: context.sp(15),
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
                  SizedBox(height: rs.s(10)),
                  SizedBox(
                    width: double.infinity,
                    height: rs.s(52),
                    child: ElevatedButton(
                      onPressed: () async {
                        await signupController.signUp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.s(12)),
                        ),
                      ),
                      child: Text(
                        StringsList.txtRegister,
                        style: TextStyle(
                          fontSize: context.sp(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: rs.s(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
