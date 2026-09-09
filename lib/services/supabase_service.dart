
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  String? get accessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}