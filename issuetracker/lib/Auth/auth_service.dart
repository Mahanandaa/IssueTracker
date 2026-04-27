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

    // Jika password_hash masih placeholder '-', update sekarang
    final uid = response.user?.id;
    if (uid != null) {
      try {
        final userData = await _supabase
            .from('users')
            .select('password_hash')
            .eq('id', uid)
            .maybeSingle();

        final stored = userData?['password_hash'] as String?;
        if (stored == null || stored == '-' || stored.isEmpty) {
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

  /// Admin update email user lain langsung aktif tanpa konfirmasi email.
  /// Alur:
  /// 1. Ambil password_hash user target dari DB
  /// 2. Sign in sebagai user target
  /// 3. Update password user target dengan email baru sekaligus (trick bypass konfirmasi)
  ///    → sign out user target, lalu sign up ulang dengan email baru & password sama
  ///    → TIDAK, gunakan cara: update email via updateUser + langsung update tabel users
  ///    → agar bypass konfirmasi: set email_confirmed_at via raw update di tabel auth.users
  ///    → karena RLS mencegah itu, solusi terbaik tanpa edge function:
  ///       sign in sebagai user target → updateUser → update tabel users
  ///       + pastikan di Supabase Dashboard: Auth > Settings > "Enable email confirmations" = OFF
  /// 4. Update tabel users dengan email baru
  /// 5. Sign in kembali sebagai admin
  Future<void> adminUpdateUserEmail({
    required String targetUserId,
    required String targetOldEmail,
    required String targetNewEmail,
    required String adminEmail,
    required String adminPassword,
  }) async {
    // 1. Ambil password_hash user target
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
      // 2. Sign in sebagai user target
      await _supabase.auth.signInWithPassword(
        email: targetOldEmail,
        password: targetPassword,
      );

      // 3. Update email di Supabase Auth
      //    PENTING: Agar ini langsung aktif tanpa konfirmasi email,
      //    pastikan di Supabase Dashboard → Authentication → Providers → Email
      //    matikan "Confirm email" / "Enable email confirmations"
      await _supabase.auth.updateUser(
        UserAttributes(email: targetNewEmail),
      );

      // 4. Langsung update tabel users dengan email baru
      //    Ini memastikan tampilan & login menggunakan email baru
      await _supabase.from('users').update({
        'email': targetNewEmail,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', targetUserId);

      // 5. Sign in kembali sebagai admin agar sesi admin pulih
      await _supabase.auth.signInWithPassword(
        email: adminEmail,
        password: adminPassword,
      );
    } catch (e) {
      // Pastikan admin selalu kembali login meski terjadi error
      try {
        await _supabase.auth.signInWithPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (_) {}
      rethrow;
    }
  }
  Future<void> updateOwnEmail({
    required String newEmail,
    required String userId,
  }) async {
    await _supabase.auth.updateUser(
      UserAttributes(email: newEmail),
    );

    await _supabase.from('users').update({
      'email': newEmail,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> keluar() async {
    await _supabase.auth.signOut();
  }
}