import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/controller_auth/forgotpassword_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController forgotController = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.07,
            ),
            child: Obx(() {
              // ======================================================
              // STATE 2: CHECK YOUR EMAIL SUCCESS STATE
              // ======================================================

              if (forgotController.isEmailSent.value) {
                final userEmail = forgotController.emailController.text.trim();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.02),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/main_logo.png',
                        width: width * 0.40,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: height * 0.05),

                    Text(
                      "Check your email",
                      style: TextStyle(
                        fontSize: width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: colorsList.primaryBlue,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: height * 0.015),

                    Text(
                      "Follow the link in the email to choose a new password.",
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: const Color(0xFF475569),
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // GREEN INFORMATIONAL BANNER CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD1FAE5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              color: Color(0xFF059669),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: width * 0.034,
                                  color: const Color(0xFF065F46),
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: "If an account exists for "),
                                  TextSpan(
                                    text: userEmail,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                    text: ", we've sent a link to reset your password. The link expires after a short time.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    // DIDN'T GET EMAIL / SEND AGAIN
                    Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            const TextSpan(text: "Didn't get the email? Check your spam folder or "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: forgotController.isLoading.value
                                    ? null
                                    : () => forgotController.sendPasswordResetEmail(),
                                child: Text(
                                  "send it again",
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: colorsList.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    // BACK TO SIGN IN BUTTON
                    Center(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Back to sign in',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorsList.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // ======================================================
              // STATE 1: INITIAL RESET PASSWORD FORM
              // ======================================================

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.02,
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/main_logo.png',
                      width: width * 0.40,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(
                    height: height * 0.06,
                  ),

                  Text(
                    "Reset your password",
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.normal,
                      color: colorsList.primaryBlue,
                      letterSpacing: -0.5,
                    ),
                  ),

                  SizedBox(
                    height: height * 0.04,
                  ),

                  Text(
                    "Email address",
                    style: TextStyle(
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.normal,
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
                    prefixIcon: Icons.alternate_email_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: height * 0.035,
                  ),

                  AppButton(
                    text: 'Send Reset Link',
                    isLoading: forgotController.isLoading.value,
                    onPressed: () {
                      forgotController.sendPasswordResetEmail();
                    },
                    width: double.infinity,
                    height: height * 0.062,
                    backgroundColor: colorsList.primaryBlue,
                    disabledBackgroundColor: colorsList.primaryBlue,
                    foregroundColor: Colors.white,
                    loadingColor: Colors.white,
                    borderRadius: 8,
                    fontSize: width * 0.040,
                    fontWeight: FontWeight.normal,
                  ),

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
                          "or back to login",
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

                  SizedBox(
                    height: height * 0.03,
                  ),

                  Center(
                    child: TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Back to Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: colorsList.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}