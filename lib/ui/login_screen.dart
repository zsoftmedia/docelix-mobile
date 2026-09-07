
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/constants.dart';
import 'package:docelix_mobileapp/utils/string_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
 // var loginPage_Controller = Get.put(LoginPage_Ctrl());
 // final _formKey = GlobalKey<FormState>(); // GlobalKey to manage form state

  bool checkLoginProgressbar = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,  // Prevent the form from moving up when the keyboard appears
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: height / 2.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorsList.colorFireOpal_1100,
                      colorsList.colorFireOpal_1100,
                      colorsList.colorFireOpal_1100,
                      colorsList.colorFireOpal_1100,
                      colorsList.colorFireOpal_1100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(height / 20),
                    bottomLeft: Radius.circular(height / 20),
                  ),
                ),
              ),
            ),
            Positioned(
              top: height / 9,
              left: width / 7.5,
              child: SvgPicture.asset(
                'assets/main_logo.svg',
                width: width / 1.4,
                // height: height / 12,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),

            /*Align(
              alignment: Alignment.center,
              child: Obx(() {
                // Show loading animation when checkLoginProgressbar is true
                return loginPage_Controller.checkLoginProgressbar.value
                    ? LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.blue,
                  size: 50,
                )
                    : SizedBox.shrink(); // Return an empty widget if not loading
              }),
            ),*/

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height / 1.4,
                padding: EdgeInsets.all(width / 40),
                margin: EdgeInsets.symmetric(horizontal: width / 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(width / 12),
                    bottom: Radius.circular(width / 12),
                  ),
                ),

                child: Form(
                //  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 20),
                    child: ListView(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height / 70),
                        Text(
                          StringsList.txtLogin,
                          style: TextStyle(
                              fontSize: fontSize_25,
                              fontWeight: FontWeight.bold,
                              color: colorsList.colorBlue_1050),
                        ),
                        // SizedBox(height: height / 100),
                        Text(
                          StringsList.txtSignin_desc,
                          style: TextStyle(
                              fontSize: fontSize_14,
                              color: colorsList.colorGray_350),
                        ),

                        SizedBox(height: height / 70),
                        /*Center(
                          child: Obx (() => Text(loginPage_Controller.errorText.value,
                            style: TextStyle(color: colorsList.colorRed),),
                          ),
                        ),*/
                        SizedBox(height: height / 70),
                        Text(
                          StringsList.txtUsername,
                          style: TextStyle(
                              fontSize: fontSize_14,
                              color: colorsList.colorGray_350),
                        ),
                        TextFormField(
                        //  controller: loginPage_Controller.identityController,
                          decoration: InputDecoration(
                            hintText: "e.g. anees.irshad@berrinex.com",
                            hintStyle: TextStyle(
                                color: colorsList.colorGray_350, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width / 25),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: colorsList.colorGray_400.withOpacity(0.1),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height / 70),
                        Text(
                          StringsList.txtPassword,
                          style: TextStyle(
                              fontSize: fontSize_14,
                              color: colorsList.colorGray_350),
                        ),
                        TextFormField(
                        //  controller: loginPage_Controller.passwordController,
                          decoration: InputDecoration(
                            hintText: "********",
                            hintStyle: TextStyle(
                                color: colorsList.colorGray_450,
                                fontSize: fontSize_14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width / 25),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: colorsList.colorGray_400.withOpacity(0.1),
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: colorsList.colorGray_400,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureText,
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
                        SizedBox(height: height / 70),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "If you're not registered, ",
                              style: TextStyle(
                                fontSize: fontSize_14,
                                color: colorsList.colorGray_350,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Create Account
                                Get.offNamed(
                                  '/RegisterScreen', arguments: 'Register Screen',
                                );
                              },
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: fontSize_14,
                                  fontWeight: FontWeight.bold,
                                  color: colorsList.colorFireOpal_1100,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height / 40),
                        InkWell(
                          onTap: () async {
                            /*if (_formKey.currentState!.validate()) {
                              await loginPage_Controller.checkInternetConnection();

                              if (loginPage_Controller.isConnected.value) {
                                loginPage_Controller.checkLoginProgressbar.value =
                                true; // Show progress bar
                                await loginPage_Controller.loginFunction(); // Perform login
                                loginPage_Controller.checkLoginProgressbar.value =
                                false; // Hide progress bar
                              } else {
                                loginPage_Controller.checkLoginProgressbar.value =
                                false; // Hide progress bar if no internet
                              }
                            }*/
                          },
                          child: Container(
                            height: height * 0.07,  // Adjust height as needed
                            width: width * 0.9,     // Adjust width as needed
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  colorsList.colorGray_1100,
                                  colorsList.colorGray_1100,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(width / 25),
                            ),
                            child: Center(
                              child: Text(
                                StringsList.txtbtnLogin,
                                style: TextStyle(
                                  fontSize: fontSize_16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          /*child: Obx(() {
                            return Container(
                              height: height * 0.07,  // Adjust height as needed
                              width: width * 0.9,     // Adjust width as needed
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    colorsList.colorMediumTealBlue,
                                    colorsList.colorMediumTealBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(width / 25),
                              ),
                              child: Center(
                                child: loginPage_Controller.checkLoginProgressbar.value
                                    ? LoadingAnimationWidget.staggeredDotsWave( // Show loading animation
                                  color: Colors.white,
                                  size: 24,
                                )
                                    : Text(
                                  StringsList.txtbtnLogin,
                                  style: TextStyle(
                                    fontSize: fontSize_16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }),*/
                        ),

                        SizedBox(height: height / 4.6),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}