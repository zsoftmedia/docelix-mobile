import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/profile_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController =
  Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      /*appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),*/

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: width * 0.05,
          ),
        ),

        title: Text(
          "Profile",
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: width * 0.055,
            fontWeight: FontWeight.w700,
          ),
        ),

      ),

      body: Obx(
            () {
          if (profileController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.045,
              vertical: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =========================================================
                // PROFILE HEADER
                // =========================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorsList.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [

                      // Profile Picture
                      Stack(
                        clipBehavior: Clip.none,
                        children: [

                          Obx(
                                () {
                              final selectedImage =
                                  profileController
                                      .selectedProfileImage
                                      .value;

                              final imageUrl =
                                  profileController
                                      .profileImageUrl
                                      .value;

                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEFF3F7),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  image: selectedImage != null
                                      ? DecorationImage(
                                    image: FileImage(
                                      selectedImage,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                      : imageUrl.isNotEmpty
                                      ? DecorationImage(
                                    image: NetworkImage(
                                      imageUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: selectedImage == null &&
                                    imageUrl.isEmpty
                                    ? const Icon(
                                  Icons.person_outline,
                                  size: 55,
                                  color: colorsList.iconColor,
                                )
                                    : null,
                              );
                            },
                          ),

                          // Camera Button
                          Positioned(
                            right: -2,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: profileController
                                  .changeProfilePicture,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1769AA),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Obx(
                            () => Text(
                          profileController
                              .profileName
                              .value
                              .isEmpty
                              ? 'User'
                              : profileController
                              .profileName
                              .value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                          //  fontWeight: FontWeight.w600,
                            color: colorsList.textColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Email
                      Obx(
                            () => Text(
                          profileController
                              .profileEmail
                              .value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: colorsList.textHintColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Badges
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          // Plan
                          Obx(
                                () => _badge(
                              text: profileController
                                  .profilePlan
                                  .value,
                              backgroundColor:
                              colorsList.backgroundColor,
                              textColor:
                              colorsList.textColor,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Role
                          Obx(
                                () => profileController
                                .profileRole
                                .value
                                .isNotEmpty
                                ? _badge(
                              text: profileController
                                  .profileRole
                                  .value,
                              backgroundColor:
                              colorsList.backgroundColor,
                              textColor:
                              colorsList.textColor,
                            )
                                : const SizedBox(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Change Picture
                      GestureDetector(
                        onTap: profileController
                            .changeProfilePicture,
                        child: const Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            color: colorsList.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // ACCOUNT INFORMATION
                // =========================================================

                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 17,
                    //fontWeight: FontWeight.w600,
                    color: colorsList.textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorsList.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [

                      // Name
                      _fieldLabel('Name'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                        profileController.nameController,
                        decoration: _inputDecoration(
                          hint: 'Enter your name',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Username
                      _fieldLabel('Username'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                        profileController
                            .usernameController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          hint: 'Username',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _fieldLabel('Email'),

                      const SizedBox(height: 7),

                      TextField(
                        controller:
                        profileController.emailController,
                        keyboardType:
                        TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hint: 'Enter your email',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =========================================================
                // ACCOUNT DETAILS
                // =========================================================

                const Text(
                  'Account Details',
                  style: TextStyle(
                    fontSize: 17,
                  //  fontWeight: FontWeight.w600,
                    color: colorsList.textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorsList.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [

                      _detailRow(
                        title: 'Plan',
                        value: profileController
                            .profilePlan
                            .value,
                      ),

                      _divider(),

                      _detailRow(
                        title: 'Role',
                        value: profileController
                            .profileRole
                            .value,
                      ),

                      _divider(),

                      _detailRow(
                        title: 'Account Created',
                        value: profileController
                            .accountCreatedDate
                            .value,
                      ),

                      if (profileController
                          .companyName
                          .value
                          .isNotEmpty) ...[
                        _divider(),

                        _detailRow(
                          title: 'Company',
                          value: profileController
                              .companyName
                              .value,
                        ),
                      ],

                      if (profileController
                          .companyCurrency
                          .value
                          .isNotEmpty) ...[
                        _divider(),

                        _detailRow(
                          title: 'Currency',
                          value: profileController
                              .companyCurrency
                              .value,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =========================================================
                // SAVE BUTTON
                // =========================================================

                Obx(
                      () => AppButton(
                    text: 'Save',
                    isLoading:
                    profileController.isSaving.value,
                    onPressed:
                    profileController.saveChanges,
                    width: double.infinity,
                    height: height * 0.062,
                    backgroundColor:
                    colorsList.primaryBlue,
                    disabledBackgroundColor:
                    colorsList.primaryBlue,
                    foregroundColor: Colors.white,
                    loadingColor: Colors.white,
                    borderRadius: 4,
                    fontSize: width * 0.043,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // BADGE
  // =========================================================

  Widget _badge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // =========================================================
  // FIELD LABEL
  // =========================================================

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorsList.textColor,
        ),
      ),
    );
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration _inputDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorsList.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: colorsList.borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: colorsList.borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: colorsList.focusedBorderColor,
          width: 1.2,
        ),
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: colorsList.textHintColor,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorsList.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: colorsList.dividerColor,
    );
  }
}