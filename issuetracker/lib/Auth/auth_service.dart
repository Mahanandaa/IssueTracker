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
    final existing = await _supabase
        .from('users')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    if (existing != null) {
      throw Exception('Email sudah terdaftar. Silakan login.');
    }

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
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': email,
        'name': nama,
        'phone': telepon,
        'role': 'karyawan',
        // Simpan password asli agar admin bisa update Auth email nanti
        'password_hash': password,
      });
    }

    return response;
  }

  /// Login — sekaligus update password_hash jika masih '-' (akun lama)
  Future<AuthResponse> signInWithPassword(
      String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Jika password berubah sejak terakhir disimpan di users.password_hash,
    // sinkronkan kembali setelah login berhasil.
    final uid = response.user?.id;
    if (uid != null) {
      try {
        final userData = await _supabase
            .from('users')
            .select('password_hash')
            .eq('id', uid)
            .maybeSingle();

        final stored = userData?['password_hash'] as String?;
        if (stored != password) {
          await _supabase
              .from('users')
              .update({'password_hash': password}).eq('id', uid);
        }
      } catch (e) {
        debugPrint('Update password_hash error: $e');
      }
    }

    return response;
  }

  Future<String?> tambahTeknisiDanKembali({
    required String email,
    required String password,
    required String nama,
    required String telepon,
    String? department,
    required String adminEmail,
    required String adminPassword,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nama': nama, 'telepon': telepon},
      );

      final user = response.user;
      if (user != null) {
        await _supabase.from('users').upsert({
          'id': user.id,
          'email': email,
          'name': nama,
          'phone': telepon,
          'role': 'teknisi',
          'department': department,
          // Simpan password asli
          'password_hash': password,
          'is_available': true,
        });
      }

      await _supabase.auth.signInWithPassword(
        email: adminEmail,
        password: adminPassword,
      );

      return null;
    } catch (e) {
      try {
        await _supabase.auth.signInWithPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (_) {}
      return e.toString();
    }
  }

  /// Admin update email user lain tanpa perlu input password admin manual.
  /// Alur:
  /// 1. Ambil password_hash user target dari DB
  /// 2. Sign in sebagai user target
  /// 3. Update Auth email user target
  /// 4. Update tabel users
  /// 5. Sign in kembali sebagai admin (pakai session yang sudah tersimpan)
  Future<void> adminUpdateUserEmail({
    required String targetUserId,
    required String targetOldEmail,
    required String targetNewEmail,
    required String adminEmail,
    required String adminPassword,
  }) async {
    // Ambil password user target
    final userData = await _supabase
        .from('users')
        .select('password_hash')
        .eq('id', targetUserId)
        .maybeSingle();

    final targetPassword = userData?['password_hash'] as String?;

    if (targetPassword == null ||
        targetPassword == '-' ||
        targetPassword.isEmpty) {
      throw Exception('password_not_stored');
    }

    try {
      // Sign in sebagai user target
      await _supabase.auth.signInWithPassword(
        email: targetOldEmail,
        password: targetPassword,
      );

      // Update Auth email user target
      await _supabase.auth.updateUser(
        UserAttributes(email: targetNewEmail),
      );

      // Update tabel users
      await _supabase.from('users').update({
        'email': targetNewEmail,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', targetUserId);

      // Sign in kembali sebagai admin
      await _supabase.auth.signInWithPassword(
        email: adminEmail,
        password: adminPassword,
      );
    } catch (e) {
      // Pastikan admin tetap login walau gagal
      try {
        await _supabase.auth.signInWithPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> keluar() async {
    await _supabase.auth.signOut();
  }
}