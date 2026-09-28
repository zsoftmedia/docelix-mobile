import 'dart:io';

import 'package:docelix_mobileapp/models/user_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final DioClient dioClient = DioClient();

  final ImagePicker imagePicker = ImagePicker();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isImageUploading = false.obs;

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  // ============================================================
  // PROFILE DATA
  // ============================================================

  final profileName = ''.obs;
  final profileUsername = ''.obs;
  final profileEmail = ''.obs;
  final profileRole = ''.obs;
  final profilePlan = 'Free'.obs;
  final accountCreatedDate = ''.obs;

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  final Rxn<File> selectedProfileImage = Rxn<File>();

  final profileImageUrl = ''.obs;

  // ============================================================
  // COMPANY DATA
  // ============================================================

  final companyName = ''.obs;
  final companyCurrency = ''.obs;

  @override
  void onInit() {
    super.onInit();

    getProfileData();
  }

  // ============================================================
// SELECT PROFILE IMAGE
// ============================================================

  Future<void> pickProfileImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile =
      await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      selectedProfileImage.value =
          File(pickedFile.path);

      print(
        'Selected profile image: ${pickedFile.path}',
      );
    } catch (e) {
      print('pickProfileImage error: $e');

      Get.snackbar(
        'Error',
        'Unable to select profile picture',
      );
    }
  }

  Future<void> changeProfilePicture() async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 18),

              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF1769AA),
                  ),
                ),
                title: const Text(
                  'Take a photo',
                ),
                subtitle: const Text(
                  'Use your camera',
                ),
                onTap: () async {
                  Get.back();

                  await pickProfileImage(
                    source: ImageSource.camera,
                  );
                },
              ),

              ListTile(
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF1769AA),
                  ),
                ),
                title: const Text(
                  'Choose from gallery',
                ),
                subtitle: const Text(
                  'Select an existing photo',
                ),
                onTap: () async {
                  Get.back();

                  await pickProfileImage(
                    source: ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ============================================================
  // GET PROFILE
  // ============================================================

  Future<void> getProfileData() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        print('Access token not found');
        return;
      }

      final meResponse = await dioClient.getMe(
        '/me',
        accessToken,
      );

      if (meResponse.statusCode != 200) {
        print(
          'Failed to get profile. '
              'Status: ${meResponse.statusCode}',
        );
        return;
      }

      final UserModel user = UserModel.fromJson(
        meResponse.data,
      );

      // ==========================================================
      // USER DATA
      // ==========================================================

      profileName.value = user.username ?? '';
      profileUsername.value = user.username ?? '';
      profileEmail.value = user.email ?? '';
      profileRole.value = user.role?.name ?? '';

      // ==========================================================
      // ACCOUNT CREATED DATE
      // ==========================================================

      accountCreatedDate.value = user.createdAt != null
          ? DateTime.parse(
        user.createdAt!,
      ).toString().split(' ').first
          : '';

      // ==========================================================
      // PROFILE IMAGE
      // ==========================================================

      // IMPORTANT:
      // Replace `user.profileImage` with the actual field
      // from your UserModel/API response.
      //
      // profileImageUrl.value = user.profileImage ?? '';

      // ==========================================================
      // COMPANY
      // ==========================================================

      final company = user.companies?.isNotEmpty == true
          ? user.companies!.first
          : null;

      if (company != null) {
        companyName.value = company.name ?? '';
        companyCurrency.value =
            company.currencyCode ?? '';
      }

      // ==========================================================
      // SET TEXT CONTROLLERS
      // ==========================================================

      nameController.text = profileName.value;
      usernameController.text = profileUsername.value;
      emailController.text = profileEmail.value;

      print('Profile loaded successfully');
      print('ID: ${user.id}');
      print('Name: ${profileName.value}');
      print('Email: ${profileEmail.value}');
      print('Username: ${profileUsername.value}');
      print('Role: ${profileRole.value}');
      print('Created: ${accountCreatedDate.value}');
      print('Company: ${companyName.value}');
      print('Currency: ${companyCurrency.value}');
    } catch (e) {
      print('getProfileData error: $e');

      Get.snackbar(
        'Error',
        'Unable to load profile information',
      );
    } finally {
      isLoading.value = false;
    }
  }


  // ============================================================
  // REMOVE SELECTED IMAGE
  // ============================================================

  void removeSelectedProfileImage() {
    selectedProfileImage.value = null;
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> saveChanges() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
      );
      return;
    }

    try {
      isSaving.value = true;

      // ==========================================================
      // TODO:
      // Upload profile data + selectedProfileImage here.
      // ==========================================================

      /*
      await dioClient.updateProfile(
        accessToken: SessionManager.accessToken!,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImage: selectedProfileImage.value,
      );
      */

      await Future.delayed(
        const Duration(seconds: 1),
      );

      profileName.value =
          nameController.text.trim();

      profileEmail.value =
          emailController.text.trim();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
      );
    } catch (e) {
      print('saveChanges error: $e');

      Get.snackbar(
        'Error',
        'Unable to update profile',
      );
    } finally {
      isSaving.value = false;
    }
  }



  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();

    super.onClose();
  }
}