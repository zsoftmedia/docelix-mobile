import 'package:docelix_mobileapp/config/api_constants.dart';
import 'package:docelix_mobileapp/models/user_model.dart';
import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginController extends GetxController {

  final authService = AuthServices();
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final isLoading = false.obs;

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  void login () async {

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please enter email and password.',
      );
      return;
    }

    try{
      isLoading.value = true;
      // await authService.signInWithEmailPassword(email, password);
      final response = await authService.signInWithEmailPassword(
        email,
        password,
      );

      // GET SESSION
      final Session? session = response.session;

      if (session == null) {

        Get.snackbar(
          'Login Failed',
          'Unable to create a session.',
        );

        return;
      }
      // GET USER
      final User user = session.user;

      // GET SUPABASE ACCESS TOKEN
      final String accessToken = session.accessToken;

      // DEBUG ONLY
      debugPrint('================================');
      debugPrint('SUPABASE LOGIN SUCCESS');
      debugPrint('User ID: ${user.id}');
      debugPrint('Email: ${user.email}');
      debugPrint('Access Token: $accessToken');
      debugPrint('================================');

     // String Tokens = 'eyJhbGciOiJFUzI1NiIsImtpZCI6IjE3YWU0MDk5LTJhYzktNDQ1Yy1hZTcwLTQ4ZjNmNzdiODhiNSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3VxaHVmZGV2c25zdGRwY2JnYWNlLnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI5NGRmNWQ0MC04ZTI2LTQ3MWUtOWU5YS1hYWY1NjVhZDAxZGYiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzg5MDIxMTE2LCJpYXQiOjE3ODkwMTc1MTYsImVtYWlsIjoicmFtZWV6QGJlcnJpbmV4LmNvbSIsInBob25lIjoiIiwiYXBwX21ldGFkYXRhIjp7InByb3ZpZGVyIjoiZW1haWwiLCJwcm92aWRlcnMiOlsiZW1haWwiXX0sInVzZXJfbWV0YWRhdGEiOnsiZW1haWxfdmVyaWZpZWQiOnRydWV9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6InBhc3N3b3JkIiwidGltZXN0YW1wIjoxNzg5MDE3NTE2fV0sInNlc3Npb25faWQiOiIwMDU3ZmJlMC00YmEzLTRjNTctYTMyYi01MTY2OWM5YjQ5OTIiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.WAyQACAAhCtahL2PpD0ej58tfHP2jhq9G9lDtUGzW0ki6rHmLy1Z9haTKJ5zcD0AmJRJBjCiPsc3_UX4sZ7YQA';

      // ==============================
      // 4. CALL DOCELIX /api/me
      // ==============================
      final meResponse = await dioClient.getMe('/me',accessToken);

      if (meResponse.statusCode == 200) {

        UserModel user = UserModel.fromJson(meResponse.data);

        print(user.id);
        print(user.email);
        print(user.username);

        print(user.role?.name);

        print(user.companies?.first.id);
        print(user.companies?.first.name);

        print(user.companies?.first.currencyCode);
        print(user.companies?.first.myRole);

        print(user.companies?.first.myPlanFeatures?.hasFinance);
        print(user.companies?.first.myPlanFeatures?.hasAI);

        final company = user.companies?.isNotEmpty == true
            ? user.companies!.first
            : null;

        if (company != null) {
          print("Company ID: ${company.id}");
          print("Company Name: ${company.name}");
          print("Currency: ${company.currencyCode}");
          print("Role: ${company.myRole}");
        }

        // Save token
        await SessionManager.saveAccessToken(accessToken);
        await SessionManager.saveCompanyid(company?.id ?? 0);
        await SessionManager.saveCompanyname(company?.name ?? '');
        await SessionManager.saveCorrencycode(company?.currencyCode ?? '');
        await SessionManager.saveRole(company?.myRole ?? '');


        Get.offNamed(
          '/LandScreen',
          arguments: meResponse.data,
        );

      } else {

        Get.snackbar(
          'Login Failed',
          'Unable to load user information.',
        );
      }

      /*Get.offNamed(
        '/LandScreen',
        arguments: 'Land Screen',
      );*/
    }on AuthException catch (e) {

      // Supabase authentication error
      isLoading.value = false;

      debugPrint('Supabase Auth Error: ${e.message}');

      final isInvalidCredentials = e.code == 'invalid_credentials';

      Get.snackbar(
        'Login Failed',
        isInvalidCredentials
            ? 'Invalid credentials on ${Uri.parse(ApiConstants.supabaseUrl).host}. '
                'The user must exist in THAT project, and the email must be confirmed '
                '(Confirm email is ON). Create the account in this app first, or confirm the user in the dashboard.'
            : e.message,
        duration: const Duration(seconds: 8),
      );

      debugPrint('================================');
      debugPrint('SUPABASE AUTH ERROR');
      debugPrint('Project URL: ${Supabase.instance.client.rest.url}');
      debugPrint('Email: $email');
      debugPrint('Message: ${e.message}');
      debugPrint('Status Code: ${e.statusCode}');
      debugPrint('Code: ${e.code}');
      debugPrint('================================');

    } catch(e) {

      isLoading.value = false;

      Get.snackbar(
        'Failed',
        'Something went wrong $e',
      );

    } finally {

      isLoading.value = false;

    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

}