import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/controller_auth/forgotpassword_controller.dart';
import 'package:docelix_mobileapp/controllers/controller_auth/login_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController forgotController = Get.put(ForgotPasswordController());

  bool checkLoginProgressbar = false;
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.07,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ======================================================
                // LOGO
                // ======================================================

                SizedBox(
                  height: height * 0.035,
                ),

                Align(
                  alignment: Alignment.centerLeft,

                  child: Image.asset(
                    'assets/main_logo.png',
                    width: width * 0.40,
                    fit: BoxFit.contain,
                  ),
                ),

                // ======================================================
                // RESET YOUR PASSWORD
                // ======================================================

                SizedBox(
                  height: height * 0.105,
                ),

                Text(
                  "Reset your password",
                  style: TextStyle(
                    fontSize: width * 0.085,
                    fontWeight: FontWeight.w900,
                    color: colorsList.primaryBlue,
                    letterSpacing: -1.0,
                  ),
                ),

                SizedBox(
                  height: height * 0.045,
                ),

                // ======================================================
                // EMAIL LABEL
                // ======================================================

                Text(
                  "Email address",
                  style: TextStyle(
                    fontSize: width * 0.040,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),

                SizedBox(
                  height: height * 0.012,
                ),

                AppTextField(
                  controller: forgotController.emailController,
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }

                    return null;
                  },
                ),

                // ======================================================
                // FORGOT PASSWORD BUTTON
                // ======================================================

                SizedBox(
                  height: height * 0.035,
                ),

                Obx(
                      () => AppButton(
                    text: 'Send Reset Link',

                    isLoading: forgotController.isLoading.value,

                    onPressed: () {
                      forgotController.login();
                    },

                    width: double.infinity,
                    height: height * 0.062,

                    backgroundColor: colorsList.primaryBlue,
                    disabledBackgroundColor: colorsList.primaryBlue,

                    foregroundColor: Colors.white,
                    loadingColor: Colors.white,

                    borderRadius: 4,

                    fontSize: width * 0.043,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // ======================================================
                // OR CONTINUE WITH
                // ======================================================

                SizedBox(
                  height: height * 0.040,
                ),

                Row(
                  children: [

                    const Expanded(
                      child: Divider(
                        color: colorsList.dividerColor,
                        thickness: 1,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.035,
                      ),

                      child: Text(
                        "or continue with",
                        style: TextStyle(
                          fontSize: width * 0.035,
                          color: colorsList.textColor,
                        ),
                      ),
                    ),

                    const Expanded(
                      child: Divider(
                        color: colorsList.dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                // ======================================================
                // REQUEST DEMO
                // ======================================================

                /*SizedBox(
                  height: height * 0.035,
                ),*/

                /*Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Request for ",

                      style: TextStyle(
                        fontSize: width * 0.037,
                        color: colorsList.textColor,
                      ),

                      children: [

                        TextSpan(
                          text: "Demo",
                          style: TextStyle(
                            fontSize: width * 0.037,
                            color: colorsList.green,
                            fontWeight: FontWeight.w600,
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

                SizedBox(
                  height: height * 0.045,
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}