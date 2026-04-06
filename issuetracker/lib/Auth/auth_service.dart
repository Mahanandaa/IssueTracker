import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> getUserRole(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', uid)
          .maybeSingle();
      return response?['role'] as String?;
    } catch (e) {
      debugPrint('getUserRole error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    return await _supabase
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();
  }

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
        'name': nama,
        'phone': telepon,
        'role': 'karyawan',
        'password_hash': '-', 
      });
    }

    return response;
  }

  Future<void> tambahTeknisi({
    required String email,
    required String password,
    required String nama,
    required String telepon,
    String? department,
  }) async {
   
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'nama': nama, 'telepon': telepon},
    );

    final user = response.user;
    if (user != null) {
      await _supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'name': nama,
        'phone': telepon,
        'role': 'teknisi',
        'department': department,
        'password_hash': '-',
      });
    }
  }

  Future<AuthResponse> signInWithPassword(
      String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> keluar() async {
    await _supabase.auth.signOut();
  }
}