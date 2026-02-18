import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> daftar(
      String email, String password, String telepon, String nama) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'nama': nama,
        'telepon': telepon,
      },
    );
  }

  Future<AuthResponse> masuk(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> keluar() async {
    await _supabase.auth.signOut();
  }
}
