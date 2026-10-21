import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/user_model.dart';
import 'package:docelix_mobileapp/services/auth_services.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final restored = await _restorePersistedSession();
    if (!mounted) return;

    if (restored) {
      Get.offAllNamed('/LandScreen');
    } else {
      Get.offNamed('/LoginScreen', arguments: 'Login Screen');
    }
  }

  /// Restores a Supabase session (persisted by the SDK) into SessionManager.
  Future<bool> _restorePersistedSession() async {
    try {
      final auth = AuthServices();
      var session = auth.currentSession;

      if (session == null) {
        debugPrint('[Splash] No persisted Supabase session.');
        return false;
      }

      // Refresh when possible so API calls start with a valid access token.
      final refreshedToken = await auth.refreshAccessToken();
      final accessToken = refreshedToken ?? session.accessToken;
      if (accessToken.isEmpty) return false;

      await SessionManager.saveAccessToken(accessToken);

      final email = SessionManager.email;
      final companyId = SessionManager.accessCompanyid;
      final needsProfile =
          email == null || email.isEmpty || companyId == null || companyId == 0;

      if (needsProfile) {
        await _hydrateSessionFromMe(accessToken, auth);
      }

      debugPrint('[Splash] Session restored for ${auth.currentUserEmail}.');
      return SessionManager.isLoggedIn;
    } catch (e) {
      debugPrint('[Splash] Session restore failed: $e');
      return false;
    }
  }

  Future<void> _hydrateSessionFromMe(
    String accessToken,
    AuthServices auth,
  ) async {
    try {
      final response = await DioClient().getMe('/me', accessToken);
      if (response.statusCode != 200) return;

      final user = UserModel.fromJson(response.data);
      final createdDate = user.createdAt != null
          ? DateTime.parse(user.createdAt!).toString().split(' ').first
          : '';
      final company =
          user.companies?.isNotEmpty == true ? user.companies!.first : null;

      await SessionManager.saveEmail(
        user.email ?? auth.currentUserEmail ?? '',
      );
      await SessionManager.saveAccessToken(accessToken);
      await SessionManager.saveCompanyid(company?.id ?? 0);
      await SessionManager.saveCompanyname(company?.name ?? '');
      await SessionManager.saveCorrencycode(company?.currencyCode ?? '');
      await SessionManager.saveRole(company?.myRole ?? '');
      await SessionManager.saveAccCreatedDate(createdDate);
    } catch (e) {
      debugPrint('[Splash] Failed to hydrate profile from /me: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    // Cap logo so it does not dominate 7"/10" iPads.
    final logoBox = (rs.shortestSide * 0.42).clamp(160.0, 280.0);

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: logoBox,
                    height: logoBox,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 35,
                          spreadRadius: 5,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/onelogo.png',
                        width: logoBox * 0.85,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
