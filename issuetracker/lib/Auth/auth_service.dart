import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
Future<AuthResponse> signUp(
    String email, String password, String telepon, String nama) async {

  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {
      'nama': nama,
      'telepon': telepon,
    },
  );

  final user = response.user;

  if (user != null) {
    await _supabase.from('users').insert({
      'id': user.id,
      'email': email,
      'nama': nama,
      'telepon': telepon,
      'role': 'karyawan',
    });
  }

  return response;
}

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> keluar() async {
    await _supabase.auth.signOut();
  }
}
