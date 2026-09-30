import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui_custom/topCurveClipper.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

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
            color: colorsList.iconColor,
            size: 20,
          ),
        ),

        title: const Text(
          'Notification',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,
      ),

      body: SafeArea(
        child: Stack(
          children: [
            // TOP RIGHT DECORATION
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

            const Center(
              child: Text(
                'Notification not found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorsList.textHintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}