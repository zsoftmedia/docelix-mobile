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
            child: Column(
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

                Obx(
                  () => AppButton(
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
            ),
          ),
        ),
      ),
    );
  }
}