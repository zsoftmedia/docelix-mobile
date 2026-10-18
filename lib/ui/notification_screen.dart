import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui_custom/topCurveClipper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(20),
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: TopCurveClipper(),
                child: Container(
                  width: rs.isPhone ? rs.wp(0.70) : rs.s(280),
                  height: rs.isPhone ? rs.hp(0.28) : rs.s(200),
                  color: const Color(0xFFEAF3FB),
                ),
              ),
            ),
            ResponsivePage(
              child: const Center(
                child: Text(
                  'Notification not found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorsList.textHintColor,
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
