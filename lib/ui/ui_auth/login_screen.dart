import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/controller_auth/login_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final LoginController loginController = Get.put(LoginController());

  /// Split brand | form on wide tablets / iPads.
  bool _useSplitLayout(ResponsiveMetrics rs) =>
      rs.isTabletOrLarger && rs.width >= 800;

  Widget _buildLogo(ResponsiveMetrics rs, {required bool large}) {
    return Image.asset(
      'assets/main_logo.png',
      width: large
          ? (rs.isLandscape ? rs.s(220) : rs.s(200))
          : (rs.isPhone ? rs.wp(0.40) : rs.s(160)),
      fit: BoxFit.contain,
    );
  }

  Widget _buildBrandPanel(ResponsiveMetrics rs) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAF3FB),
            Color(0xFFD6E8F7),
            Color(0xFFC5DFF2),
          ],
        ),
      ),
      child: SafeArea(
        right: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rs.s(40)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(rs, large: true),
                SizedBox(height: rs.s(28)),
                Text(
                  'Your business,\norganized.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: rs.sp(26),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: colorsList.primaryBlue,
                  ),
                ),
                SizedBox(height: rs.s(12)),
                Text(
                  'Invoices, clients, and finance\nin one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: rs.sp(15),
                    height: 1.45,
                    color: colorsList.textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(ResponsiveMetrics rs, {required bool compactTop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compactTop) ...[
          SizedBox(height: rs.s(28)),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildLogo(rs, large: false),
          ),
          SizedBox(height: rs.isPhone ? rs.hp(0.10) : rs.s(48)),
        ] else ...[
          SizedBox(height: rs.s(8)),
        ],
        Text(
          'WELCOME BACK',
          style: TextStyle(
            fontSize: context.sp(compactTop ? 32 : 28),
            fontWeight: FontWeight.w900,
            color: colorsList.primaryBlue,
            letterSpacing: -1.0,
          ),
        ),
        SizedBox(height: rs.s(compactTop ? 36 : 28)),
        Text(
          'Email address',
          style: TextStyle(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: rs.s(10)),
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
        SizedBox(height: rs.s(18)),
        Text(
          'Password',
          style: TextStyle(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: rs.s(10)),
        Obx(
          () => AppTextField(
            controller: loginController.passwordController,
            hintText: 'Password',
            obscureText: !loginController.isPasswordVisible.value,
            keyboardType: TextInputType.visiblePassword,
            suffixIcon: IconButton(
              icon: Icon(
                loginController.isPasswordVisible.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: loginController.togglePasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: rs.s(12)),
        GestureDetector(
          onTap: () {
            // Forgot password
          },
          child: Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: context.sp(14),
              color: const Color(0xFF198754),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: rs.s(20)),
        Row(
          children: [
            Obx(
              () => SizedBox(
                width: rs.s(22),
                height: rs.s(22),
                child: Checkbox(
                  value: loginController.rememberMe.value,
                  onChanged: (value) {
                    loginController.rememberMe.value = value ?? false;
                  },
                  side: const BorderSide(
                    color: colorsList.textColor,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            SizedBox(width: rs.s(8)),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: context.sp(14),
                color: colorsList.textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: rs.s(28)),
        Obx(
          () => AppButton(
            text: 'Sign in',
            isLoading: loginController.isLoading.value,
            onPressed: () {
              loginController.login();
            },
            width: double.infinity,
            height: rs.s(52),
            backgroundColor: colorsList.primaryBlue,
            disabledBackgroundColor: colorsList.primaryBlue,
            foregroundColor: Colors.white,
            loadingColor: Colors.white,
            borderRadius: 4,
            fontSize: context.sp(16),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: rs.s(32)),
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: colorsList.dividerColor,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs.s(14)),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: context.sp(13),
                  color: colorsList.textColor,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: colorsList.dividerColor,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: rs.s(20)),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: rs.s(52),
            child: OutlinedButton(
              onPressed: loginController.isLoading.value
                  ? null
                  : () {
                      loginController.loginWithGoogle();
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
                    width: rs.s(22),
                    height: rs.s(22),
                  ),
                  SizedBox(width: rs.s(10)),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: rs.s(36)),
      ],
    );
  }

  Widget _buildSplitLayout(ResponsiveMetrics rs) {
    return Row(
      children: [
        Expanded(
          flex: rs.isLandscape ? 5 : 4,
          child: _buildBrandPanel(rs),
        ),
        Expanded(
          flex: rs.isLandscape ? 5 : 6,
          child: ColoredBox(
            color: Colors.white,
            child: SafeArea(
              left: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: rs.authFormMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: rs.s(36),
                      vertical: rs.s(24),
                    ),
                    child: _buildFormContent(rs, compactTop: false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(ResponsiveMetrics rs) {
    return ResponsiveAuthShell(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildFormContent(rs, compactTop: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final split = _useSplitLayout(rs);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: split ? _buildSplitLayout(rs) : _buildCompactLayout(rs),
    );
  }
}
