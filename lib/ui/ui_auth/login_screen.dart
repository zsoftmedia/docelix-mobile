import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/controller_auth/login_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());

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
                // WELCOME BACK
                // ======================================================

                SizedBox(
                  height: height * 0.105,
                ),

                Text(
                  "WELCOME BACK",
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

                // ======================================================
                // EMAIL
                // ======================================================

                /*TextFormField(
                  controller: loginController.emailController,

                  keyboardType: TextInputType.emailAddress,

                  style: TextStyle(
                    fontSize: width * 0.043,
                    color: const Color(0xFF222222),
                  ),

                  decoration: InputDecoration(
                    hintText: "Email address",

                    hintStyle: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontSize: width * 0.043,
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.045,
                      vertical: height * 0.020,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF333333),
                        width: 1.2,
                      ),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF333333),
                        width: 1.2,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                        color: Color(0xFF222222),
                        width: 1.8,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }

                    return null;
                  },
                ),*/

                AppTextField(
                  controller: loginController.emailController,
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
                // PASSWORD LABEL
                // ======================================================

                SizedBox(
                  height: height * 0.022,
                ),

                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: width * 0.040,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),

                SizedBox(
                  height: height * 0.012,
                ),

                // ======================================================
                // PASSWORD
                // ======================================================

                AppTextField(
                  controller: loginController.passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    return null;
                  },
                ),

                // ======================================================
                // FORGOT PASSWORD
                // ======================================================

                SizedBox(
                  height: height * 0.015,
                ),

                GestureDetector(
                  onTap: () {
                    // Forgot password
                  },

                  child: Text(
                    "Forgot your password?",
                    style: TextStyle(
                      fontSize: width * 0.037,
                      color: const Color(0xFF198754),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // ======================================================
                // REMEMBER ME
                // ======================================================

                SizedBox(
                  height: height * 0.025,
                ),

                Row(
                  children: [

                    SizedBox(
                      width: width * 0.055,
                      height: width * 0.055,

                      child: Checkbox(
                        value: _rememberMe,

                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },

                        side: const BorderSide(
                          color: Color(0xFF333333),
                          width: 1.4,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),

                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                    SizedBox(
                      width: width * 0.018,
                    ),

                    Text(
                      "Remember me",
                      style: TextStyle(
                        fontSize: width * 0.037,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),

                // ======================================================
                // SIGN IN BUTTON
                // ======================================================

                SizedBox(
                  height: height * 0.035,
                ),

                Obx(
                      () => AppButton(
                    text: 'Sign in',

                    isLoading: loginController.isLoading.value,

                    onPressed: () {
                      loginController.login();
                    },

                    width: double.infinity,
                    height: height * 0.070,

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
                        color: Color(0xFFD5D5D5),
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
                          color: const Color(0xFF777777),
                        ),
                      ),
                    ),

                    const Expanded(
                      child: Divider(
                        color: Color(0xFFD5D5D5),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                // ======================================================
                // GOOGLE
                // ======================================================

                SizedBox(
                  height: height * 0.025,
                ),

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
                        color: Color(0xFFD0D0D0),
                        width: 1.2,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Image.asset(
                          'assets/google_logo.png',
                          width: width * 0.055,
                          height: width * 0.055,
                        ),

                        SizedBox(
                          width: width * 0.025,
                        ),

                        Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontSize: width * 0.040,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ======================================================
                // REQUEST DEMO
                // ======================================================

                SizedBox(
                  height: height * 0.035,
                ),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Request for ",

                      style: TextStyle(
                        fontSize: width * 0.037,
                        color: const Color(0xFF777777),
                      ),

                      children: [

                        TextSpan(
                          text: "Demo",

                          style: TextStyle(
                            fontSize: width * 0.037,
                            color: const Color(0xFF198754),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}