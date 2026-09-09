
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Sign in with email and password
Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
  return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password);
}
  // Sign up with email and password
Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
  return await _supabaseClient.auth.signUp(
      email: email,
      password: password);
}
  // Sign out
Future<void> signOut() async{
  await _supabaseClient.auth.signOut();
}

  // CURRENT SESSION

  Session? get currentSession {
    return _supabaseClient.auth.currentSession;
  }

  // =========================================================
  // CURRENT USER
  // =========================================================

  User? get currentUser {
    return _supabaseClient.auth.currentUser;
  }

  // =========================================================
  // ACCESS TOKEN
  // =========================================================

  String? get accessToken {
    return _supabaseClient.auth.currentSession?.accessToken;
  }

  // =========================================================
  // REFRESH TOKEN
  // =========================================================

  String? get refreshToken {
    return _supabaseClient.auth.currentSession?.refreshToken;
  }

  // =========================================================
  // USER EMAIL
  // =========================================================

  String? get currentUserEmail {
    return _supabaseClient.auth.currentUser?.email;
  }

  // =========================================================
  // LOGIN STATUS
  // =========================================================

  bool get isLoggedIn {
    return _supabaseClient.auth.currentSession != null;
  }

  // =========================================================
  // AUTH STATE
  // =========================================================

  Stream<AuthState> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange;
  }
  // Get user email
String? getCurrentUserEmail(){
  final session = _supabaseClient.auth.currentSession;
  final user = session?.user;
  return user?.email;
}
}