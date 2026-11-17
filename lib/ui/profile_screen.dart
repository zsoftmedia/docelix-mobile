import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/controllers/profile_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // =========================================================
              // 1. TOP HEADER BAR
              // =========================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12.0),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF063C70),
                          size: 20.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(18.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40.0), // Balance back button
                  ],
                ),
              ),

              SizedBox(height: rs.s(4.0)),

              // =========================================================
              // 2. MAIN SCROLLABLE CONTENT (CENTERED ON TABLET)
              // =========================================================
              Expanded(
                child: Obx(() {
                  if (profileController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: rs.pagePaddingH,
                      vertical: rs.s(12.0),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // =========================================================
                            // PROFILE HEADER CARD
                            // =========================================================
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isTab ? 20.0 : 20.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: const Color(0xFFE4EAF1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10.0,
                                    offset: const Offset(0.0, 3.0),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // PROFILE PICTURE & CAMERA OVERLAY BUTTON
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Obx(() {
                                        final selectedImage =
                                            profileController.selectedProfileImage.value;
                                        final imageUrl =
                                            profileController.profileImageUrl.value;

                                        return Container(
                                          width: isTab ? 100.0 : 96.0,
                                          height: isTab ? 100.0 : 96.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFEFF3F7),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 10.0,
                                                offset: const Offset(0.0, 4.0),
                                              ),
                                            ],
                                            image: selectedImage != null
                                                ? DecorationImage(
                                                    image: FileImage(selectedImage),
                                                    fit: BoxFit.cover,
                                                  )
                                                : imageUrl.isNotEmpty
                                                    ? DecorationImage(
                                                        image: NetworkImage(imageUrl),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                          ),
                                          child: selectedImage == null && imageUrl.isEmpty
                                              ? const Icon(
                                                  Icons.person_rounded,
                                                  size: 50.0,
                                                  color: Color(0xFF94A3B8),
                                                )
                                              : null,
                                        );
                                      }),

                                      // CAMERA ICON OVERLAY BUTTON
                                      Positioned(
                                        right: -2.0,
                                        bottom: 0.0,
                                        child: GestureDetector(
                                          onTap: profileController.changeProfilePicture,
                                          child: Container(
                                            width: 32.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF063C70),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 15.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14.0),

                                  // USER FULL NAME
                                  Obx(
                                    () => Text(
                                      profileController.profileName.value.isEmpty
                                          ? 'User'
                                          : profileController.profileName.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isTab ? 20.0 : rs.sp(20.0),
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0A2342),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 4.0),

                                  // USER EMAIL
                                  Obx(
                                    () => Text(
                                      profileController.profileEmail.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isTab ? 13.0 : rs.sp(13.0),
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12.0),

                                  // PILL BADGES ROW (PLAN + ROLE)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(
                                        () => _badge(
                                          text: profileController.profilePlan.value,
                                          bg: const Color(0xFFEFF6FF),
                                          textCol: const Color(0xFF2563EB),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Obx(
                                        () => profileController.profileRole.value.isNotEmpty
                                            ? _badge(
                                                text: profileController.profileRole.value,
                                                bg: const Color(0xFFF1F5F9),
                                                textCol: const Color(0xFF64748B),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14.0),

                                  // CHANGE PROFILE PICTURE ACTION
                                  GestureDetector(
                                    onTap: profileController.changeProfilePicture,
                                    child: const Text(
                                      'Change Profile Picture',
                                      style: TextStyle(
                                        color: Color(0xFF063C70),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20.0),

                            // =========================================================
                            // SECTION 1: ACCOUNT INFORMATION
                            // =========================================================
                            const Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2342),
                              ),
                            ),

                            const SizedBox(height: 8.0),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: const Color(0xFFE4EAF1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // NAME
                                  _fieldLabel('Name'),
                                  const SizedBox(height: 6.0),
                                  TextField(
                                    controller: profileController.nameController,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A2342),
                                    ),
                                    decoration: _inputDecoration(hint: 'Enter your name'),
                                  ),

                                  const SizedBox(height: 14.0),

                                  // USERNAME
                                  _fieldLabel('Username'),
                                  const SizedBox(height: 6.0),
                                  TextField(
                                    controller: profileController.usernameController,
                                    readOnly: true,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A2342),
                                    ),
                                    decoration: _inputDecoration(hint: 'Username'),
                                  ),

                                  const SizedBox(height: 14.0),

                                  // EMAIL
                                  _fieldLabel('Email'),
                                  const SizedBox(height: 6.0),
                                  TextField(
                                    controller: profileController.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0A2342),
                                    ),
                                    decoration: _inputDecoration(hint: 'Enter your email'),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20.0),

                            // =========================================================
                            // SECTION 2: ACCOUNT DETAILS
                            // =========================================================
                            const Text(
                              'Account Details',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A2342),
                              ),
                            ),

                            const SizedBox(height: 8.0),

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: const Color(0xFFE4EAF1)),
                              ),
                              child: Column(
                                children: [
                                  _detailRow(
                                    title: 'Plan',
                                    value: profileController.profilePlan.value,
                                  ),
                                  _divider(),
                                  _detailRow(
                                    title: 'Role',
                                    value: profileController.profileRole.value,
                                  ),
                                  _divider(),
                                  _detailRow(
                                    title: 'Account Created',
                                    value: profileController.accountCreatedDate.value,
                                  ),
                                  if (profileController.companyName.value.isNotEmpty) ...[
                                    _divider(),
                                    _detailRow(
                                      title: 'Company',
                                      value: profileController.companyName.value,
                                    ),
                                  ],
                                  if (profileController.companyCurrency.value.isNotEmpty) ...[
                                    _divider(),
                                    _detailRow(
                                      title: 'Currency',
                                      value: profileController.companyCurrency.value,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 24.0),

                            // =========================================================
                            // SAVE BUTTON (PRIMARY DARK NAVY)
                            // =========================================================
                            Obx(
                              () => AppButton(
                                text: 'Save',
                                isLoading: profileController.isSaving.value,
                                onPressed: profileController.saveChanges,
                                width: double.infinity,
                                height: 48.0,
                                backgroundColor: const Color(0xFF063C70),
                                disabledBackgroundColor: const Color(0xFF063C70),
                                foregroundColor: Colors.white,
                                loadingColor: Colors.white,
                                borderRadius: 10,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24.0),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HELPER WIDGETS
  // =========================================================

  Widget _badge({
    required String text,
    required Color bg,
    required Color textCol,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.0, color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14.0,
        vertical: 12.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
      ),
    );
  }

  Widget _detailRow({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 14.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.0,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 15.0),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2342),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1.0,
      thickness: 1.0,
      color: Color(0xFFF1F5F9),
    );
  }
}