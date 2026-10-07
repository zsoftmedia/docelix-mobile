import 'dart:io';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      selectedProfileImage.value = File(pickedFile.path);

      debugPrint('Selected profile image: ${pickedFile.path}');
    } catch (e) {
      debugPrint('pickProfileImage error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to select profile picture.',
      );
    }
  }

  Future<void> changeProfilePicture() async {
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
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
                  borderRadius: BorderRadius.circular(10),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF1769AA),
                  ),
                ),
                title: const Text('Take a photo'),
                subtitle: const Text('Use your camera'),
                onTap: () async {
                  Get.back();
                  await pickProfileImage(source: ImageSource.camera);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF1769AA),
                  ),
                ),
                title: const Text('Choose from gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () async {
                  Get.back();
                  await pickProfileImage(source: ImageSource.gallery);
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
        debugPrint('Access token not found');
        return;
      }

      final meResponse = await dioClient.getMe('/me', accessToken);

      if (meResponse.statusCode != 200) {
        debugPrint('Failed to get profile. Status: ${meResponse.statusCode}');
        return;
      }

      final UserModel user = UserModel.fromJson(meResponse.data);

      profileName.value = user.username ?? '';
      profileUsername.value = user.username ?? '';
      profileEmail.value = user.email ?? '';
      profileRole.value = user.role?.name ?? '';

      accountCreatedDate.value = user.createdAt != null
          ? DateTime.parse(user.createdAt!).toString().split(' ').first
          : '';

      if (user.avatar?.url != null && user.avatar!.url!.isNotEmpty) {
        profileImageUrl.value = user.avatar!.url!;
      }

      final company = user.companies?.isNotEmpty == true
          ? user.companies!.first
          : null;

      if (company != null) {
        companyName.value = company.name ?? '';
        companyCurrency.value = company.currencyCode ?? '';
      }

      nameController.text = profileName.value;
      usernameController.text = profileUsername.value;
      emailController.text = profileEmail.value;

      debugPrint('Profile loaded successfully');
      debugPrint('ID: ${user.id}');
      debugPrint('Name: ${profileName.value}');
      debugPrint('Email: ${profileEmail.value}');
      debugPrint('Avatar URL: ${profileImageUrl.value}');
    } catch (e) {
      debugPrint('getProfileData error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to load profile information.',
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
  // SAVE PROFILE (PATCH /api/me)
  // ============================================================

  Future<void> saveChanges() async {
    final String nameInput = nameController.text.trim();
    final String usernameInput = usernameController.text.trim();

    final String username = nameInput.isNotEmpty ? nameInput : usernameInput;

    if (username.isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter your name/username.',
      );
      return;
    }

    try {
      isSaving.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token not found.',
        );
        return;
      }

      final String email = emailController.text.trim();

      debugPrint('========================================');
      debugPrint('PATCH /api/me REQUEST');
      debugPrint('Username: $username');
      debugPrint('Email: $email');
      debugPrint('Avatar File Selected: ${selectedProfileImage.value != null}');
      if (selectedProfileImage.value != null) {
        debugPrint('Avatar File Path: ${selectedProfileImage.value!.path}');
      }
      debugPrint('========================================');

      final response = await dioClient.updateProfile(
        endpoint: '/me',
        accessToken: accessToken,
        username: username,
        email: email,
        avatar: selectedProfileImage.value,
      );

      debugPrint('========================================');
      debugPrint('PATCH /api/me RESPONSE');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      debugPrint('========================================');

      if (response.statusCode == 200 && response.data != null) {
        final UserModel updatedUser = UserModel.fromJson(response.data);

        profileName.value = updatedUser.username ?? '';
        profileUsername.value = updatedUser.username ?? '';
        profileEmail.value = updatedUser.email ?? '';
        profileRole.value = updatedUser.role?.name ?? '';

        if (updatedUser.avatar?.url != null && updatedUser.avatar!.url!.isNotEmpty) {
          profileImageUrl.value = updatedUser.avatar!.url!;
        }

        nameController.text = profileName.value;
        usernameController.text = profileUsername.value;
        emailController.text = profileEmail.value;

        selectedProfileImage.value = null;

        AppSnackbar.success(
          title: 'Success',
          message: 'Profile updated successfully.',
        );

        debugPrint('Profile updated successfully!');
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to update profile. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('========================================');
      debugPrint('PATCH /api/me DIO EXCEPTION');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('========================================');

      String message = 'Unable to update profile';

      if (e.response?.data is Map) {
        final data = e.response?.data as Map;
        message = data['message']?.toString() ??
            data['detail']?.toString() ??
            data['error']?.toString() ??
            message;
      } else if (e.response?.data is String) {
        message = e.response!.data.toString();
      }

      AppSnackbar.error(
        title: 'Error',
        message: message,
      );
    } catch (e) {
      debugPrint('saveChanges error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to update profile: $e',
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}