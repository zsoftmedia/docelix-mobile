
import 'dart:math';

import 'package:docelix_mobileapp/controllers/controller_auth/login_controller.dart';
import 'package:docelix_mobileapp/ui/ui_custom/topCurveClipper.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/constants.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {

  final LoginController loginController = Get.put(LoginController());

  bool checkLoginProgressbar = false;
  bool _obscureText = true;

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
                    // WELCOME BACK
                    // --------------------------------------------------
                    Text(
                      "Welcome back",
                      style: TextStyle(
                        fontSize: width * 0.075,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0A2342),
                      ),
                    ),

                    SizedBox(height: height * 0.001),

                    Text(
                      "Sign in to Docelix",
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
                       controller:
                       loginController.emailController,

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
                       controller:
                       loginController.passwordController,

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

                    // --------------------------------------------------
                    // REMEMBER ME + FORGOT PASSWORD
                    // --------------------------------------------------
                    Row(
                      children: [

                        SizedBox(
                          width: width * 0.055,
                          height: width * 0.055,

                          child: Checkbox(
                            value: false,

                            onChanged: (value) {
                              // Handle remember me
                            },

                            side: const BorderSide(
                              color: Color(0xFF102F52),
                              width: 1.5,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),

                        SizedBox(width: width * 0.018),

                        Text(
                          "Remember me",
                          style: TextStyle(
                            fontSize: width * 0.038,
                            color: const Color(0xFF172A46),
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () {
                            // Forgot password
                          },

                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: width * 0.038,
                              color: const Color(0xFF1551C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.020),

                    // --------------------------------------------------
                    // SIGN IN BUTTON
                    // --------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.070,

                      child: ElevatedButton(
                        onPressed: () async {

                          loginController.login();

                          // Your existing login code goes here.
                          /*Get.offNamed(
                              '/LandScreen',
                              arguments: 'Land Screen',);*/

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
                          "Sign in",
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.045),

                    // --------------------------------------------------
                    // OR CONTINUE WITH
                    // --------------------------------------------------

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFD0DAE6),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.030,
                          ),

                          child: Text(
                            "or continue with",
                            style: TextStyle(
                              fontSize: width * 0.037,
                              color: const Color(0xFF647993),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xFFD0DAE6),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.030),

                    // --------------------------------------------------
                    // GOOGLE BUTTON
                    // --------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.070,

                      child: OutlinedButton(
                        onPressed: () {
                          // Google login
                        },

                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,

                          side: const BorderSide(
                            color: Color(0xFFD2DDEB),
                            width: 1.3,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              width * 0.035,
                            ),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            // Google logo
                            Image.asset(
                              'assets/google_logo.png',
                              width: width * 0.065,
                              height: width * 0.065,
                            ),

                            SizedBox(width: width * 0.035),

                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: width * 0.043,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF172A46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.030),

                    // --------------------------------------------------
                    // CREATE ACCOUNT
                    // --------------------------------------------------
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don’t have an account? ",

                          style: TextStyle(
                            fontSize: width * 0.038,
                            color: const Color(0xFF60728D),
                          ),

                          children: [

                            TextSpan(
                              text: "Create account",

                              style: TextStyle(
                                fontSize: width * 0.038,
                                color: const Color(0xFF1551C0),
                                fontWeight: FontWeight.w500,
                              ),

                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(
                                    '/RegisterScreen',
                                    arguments: 'Register Screen',
                                  );
                                },
                            ),
                          ],
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