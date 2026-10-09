import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared entry screen for Assets module sections.
/// Ready to be replaced with full feature screens later.
class AssetModuleScreen extends StatelessWidget {
  const AssetModuleScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: colorsList.colorWhite,
        elevation: 0,
        surfaceTintColor: colorsList.colorWhite,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.045,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorsList.primaryText,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.22,
                  height: width * 0.22,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: width * 0.10,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: width * 0.06),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorsList.primaryText,
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: width * 0.025),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorsList.secondaryText,
                    fontSize: width * 0.035,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: width * 0.04),
                Text(
                  'This module is ready for feature implementation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorsList.mutedTextColor,
                    fontSize: width * 0.032,
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
