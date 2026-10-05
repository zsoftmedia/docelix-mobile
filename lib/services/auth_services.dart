import 'dart:async';

import 'package:docelix_mobileapp/config/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // ======================================================
  // GOOGLE SIGN IN
  // ======================================================

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: ApiConstants.googleServerClientId,
    );

    _googleInitialized = true;

    debugPrint('Google Sign-In initialized successfully.');
  }

  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('========================================');
      debugPrint('STARTING NATIVE GOOGLE SIGN-IN');
      debugPrint('========================================');

      // Initialize Google Sign-In
      await _initializeGoogleSignIn();

      debugPrint('Opening Google account picker...');

      // Native Google authentication
      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      debugPrint('Google authentication successful.');
      debugPrint('Google Email: ${googleUser.email}');
      debugPrint('Google Display Name: ${googleUser.displayName}');

      // Get Google authentication tokens
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      debugPrint('Google ID Token available: ${idToken != null}');

      if (idToken == null) {
        debugPrint('ERROR: Google ID Token is null.');
        return false;
      }

      // Get authorization/access token for Supabase.
      //
      // Supabase requires the Google access token as well
      // for Google signInWithIdToken().
      final GoogleSignInClientAuthorization authorization =
      await googleUser.authorizationClient.authorizeScopes(
        <String>[
          'email',
          'profile',
        ],
      );

      final String? accessToken = authorization.accessToken;

      debugPrint(
        'Google Access Token available: ${accessToken != null}',
      );

      if (accessToken == null) {
        debugPrint('ERROR: Google Access Token is null.');
        return false;
      }

      debugPrint('Signing in to Supabase using Google ID Token...');

      // Native Google -> Supabase authentication
      final AuthResponse response =
      await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('Supabase Google authentication successful.');
      debugPrint(
        'Supabase Session exists: ${response.session != null}',
      );

      if (response.session != null) {
        debugPrint(
          'Supabase User ID: ${response.session!.user.id}',
        );

        debugPrint(
          'Supabase User Email: ${response.session!.user.email}',
        );
      }

      debugPrint('========================================');

      return response.session != null;
    } on GoogleSignInException catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GOOGLE SIGN-IN EXCEPTION');
      debugPrint('Code: ${e.code}');
      debugPrint('Description: ${e.description}');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

      return false;
    } on AuthException catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('SUPABASE AUTH ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('Status: ${e.statusCode}');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

      return false;
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('GOOGLE SIGN-IN ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

      return false;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign in / Register with Google OAuth
  /*Future<bool> signInWithGoogle() async {
    try {
      const redirectUrl =
          'com.docelix.docelix_mobileapp://auth/callback';

      debugPrint('Starting Google OAuth...');
      debugPrint('Redirect URL: $redirectUrl');

      final result = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('Google OAuth started: $result');

      return result;
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }*/

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // CURRENT SESSION
  Session? get currentSession {
    return _supabaseClient.auth.currentSession;
  }

  // CURRENT USER
  User? get currentUser {
    return _supabaseClient.auth.currentUser;
  }

  // ACCESS TOKEN
  String? get accessToken {
    return _supabaseClient.auth.currentSession?.accessToken;
  }

  // REFRESH TOKEN
  String? get refreshToken {
    return _supabaseClient.auth.currentSession?.refreshToken;
  }

  // USER EMAIL
  String? get currentUserEmail {
    return _supabaseClient.auth.currentUser?.email;
  }

  // LOGIN STATUS
  bool get isLoggedIn {
    return _supabaseClient.auth.currentSession != null;
  }

  // AUTH STATE
  Stream<AuthState> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange;
  }

  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}