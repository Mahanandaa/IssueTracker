import 'package:flutter/material.dart';
import 'package:issuetracker/admin/dashboard_admin.dart';
import 'package:issuetracker/admin/kasus_admin.dart';
import 'package:issuetracker/admin/profile_admin.dart';
import 'package:issuetracker/Auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambahAkun.dart';

class DataAkun extends StatefulWidget {
  const DataAkun({super.key});

  @override
  State<DataAkun> createState() => _DataAkunState();
}

class _DataAkunState extends State<DataAkun> {
  final supabase = Supabase.instance.client;
  final authService = AuthService();

  List<Map<String, dynamic>> karyawanList = [];
  List<Map<String, dynamic>> teknisiList = [];
  Map<String, double> teknisiRatings = {};

  // Simpan password admin saat halaman ini dibuild
  // (diambil dari shared state / login session)
  String _adminPassword = '';

  bool isLoading = true;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _promptAdminPassword();
  }

  /// Minta password admin sekali saja saat halaman dibuka
  Future<void> _promptAdminPassword() async {
    final ctrl = TextEditingController();
    bool obscure = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Verifikasi Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan password Anda untuk dapat mengelola akun.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Password admin',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setSt(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Masuk',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _adminPassword = result);
    } else {
      // Jika admin tidak memasukkan password, kembali ke halaman sebelumnya
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('users')
          .select('id, name, email, phone, role, password_hash')
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> users =
          List<Map<String, dynamic>>.from(data);

      final karyawan = users.where((u) => u['role'] == 'karyawan').toList();
      final teknisi = users.where((u) => u['role'] == 'teknisi').toList();

      final Map<String, double> ratings = {};
      for (final t in teknisi) {
        final uid = t['id'] as String;
        try {
          final ratingData = await supabase
              .from('ratings')
              .select('rating')
              .eq('technician_id', uid);
          final List rList = ratingData as List;

          final resolvedData = await supabase
              .from('issues')
              .select('id')
              .eq('assigned_to', uid)
              .eq('status', 'Resolved');
          final int resolvedCount = (resolvedData as List).length;

          if (rList.isNotEmpty && resolvedCount > 0) {
            double total = 0;
            for (final r in rList) {
              final val = r['rating'];
              if (val != null) total += (val as num).toDouble();
            }
            ratings[uid] = total / resolvedCount;
          }
        } catch (_) {}
      }

      setState(() {
        karyawanList = karyawan;
        teknisiList = teknisi;
        teknisiRatings = ratings;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text('Yakin ingin menghapus akun ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('users').delete().eq('id', id);
      fetchUsers();
    }
  }

  void editUser(Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user['name']);
    final emailCtrl = TextEditingController(text: user['email']);
    final phoneCtrl = TextEditingController(text: user['phone'] ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Akun',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Nama'),
              const SizedBox(height: 12),
              _sheetField(emailCtrl, 'Email'),
              const SizedBox(height: 12),
              _sheetField(phoneCtrl, 'Nomor'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newName = nameCtrl.text.trim();
                          final newPhone = phoneCtrl.text.trim();
                          final newEmail = emailCtrl.text.trim();
                          final oldEmail = user['email'] as String;
                          final emailChanged = newEmail != oldEmail;

                          // Validasi input
                          if (newName.isEmpty ||
                              newEmail.isEmpty ||
                              newPhone.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Semua field wajib diisi')),
                            );
                            return;
                          }

                          // Validasi format email sederhana
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(newEmail)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Format email tidak valid')),
                            );
                            return;
                          }

                          setSheetState(() => isSaving = true);

                          try {
                            if (!emailChanged) {
                              // ── Hanya nama & nomor berubah ──────────────
                              await supabase.from('users').update({
                                'name': newName,
                                'phone': newPhone,
                                'updated_at':
                                    DateTime.now().toIso8601String(),
                              }).eq('id', user['id']);
                            } else {
                              // ── Email berubah: update Supabase Auth + tabel users ──
                              // SYARAT: Di Supabase Dashboard → Authentication →
                              // Providers → Email → matikan "Confirm email"
                              // agar email baru langsung aktif tanpa verifikasi.
                              final adminEmail =
                                  supabase.auth.currentUser?.email ?? '';

                              // Update nama & nomor + email sekaligus di tabel users
                              await supabase.from('users').update({
                                'name': newName,
                                'phone': newPhone,
                              }).eq('id', user['id']);

                              // Update Auth email user target via sign in sebagai
                              // user target → updateUser → kembali sign in admin
                              await authService.adminUpdateUserEmail(
                                targetUserId: user['id'],
                                targetOldEmail: oldEmail,
                                targetNewEmail: newEmail,
                                adminEmail: adminEmail,
                                adminPassword: _adminPassword,
                              );
                              // Catatan: adminUpdateUserEmail sudah update
                              // tabel users.email & updated_at di dalamnya
                            }

                            if (mounted) Navigator.pop(sheetContext);
                            await fetchUsers();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(emailChanged
                                      ? 'Email berhasil diubah ke $newEmail ✓\n'
                                          'User dapat login dengan email baru.'
                                      : 'Akun berhasil diupdate ✓'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            setSheetState(() => isSaving = false);
                            if (mounted) {
                              String msg = e.toString();
                              if (msg.contains('password_not_stored')) {
                                msg =
                                    'Gagal: User belum pernah login setelah update terbaru.\n'
                                    'Minta user login ulang terlebih dahulu.';
                              } else if (msg.contains('Invalid login') ||
                                  msg.contains('invalid_credentials')) {
                                msg =
                                    'Gagal: Password user di database tidak cocok.\n'
                                    'Minta user login ulang agar password tersinkron.';
                              } else if (msg.contains('already registered') ||
                                  msg.contains('already been registered')) {
                                msg =
                                    'Gagal: Email $newEmail sudah digunakan akun lain.';
                              } else if (msg
                                  .contains('email_address_not_authorized')) {
                                msg =
                                    'Gagal: Email tidak diizinkan. Periksa pengaturan Supabase.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _sheetField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> user, {bool isTeknisi = false}) {
    final uid = user['id'] as String;
    final rating = isTeknisi ? teknisiRatings[uid] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user['name'] ?? '-',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const CircleAvatar(
                radius: 22,
                child: Icon(Icons.person),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Email  : ${user['email'] ?? '-'}'),
          const SizedBox(height: 4),
          Text('Nomor : ${user['phone'] ?? '-'}'),
          const SizedBox(height: 4),
          Text('Role    : ${user['role'] ?? '-'}'),
          if (isTeknisi) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Rating  : ${rating != null ? rating.toStringAsFixed(1) : 'Belum ada'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => editUser(user),
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => deleteUser(user['id']),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> list,
      {bool isTeknisi = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 18)),
        const SizedBox(height: 10),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text('Tidak ada data $title.',
                style: TextStyle(color: Colors.grey[500])),
          )
        else
          ...list.map((u) => _buildCard(u, isTeknisi: isTeknisi)),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text('Data Akun'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DashboardAdmin()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => KasusAdmin()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const DataAkun()));
          } else if (index == 3) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileAdmin()));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Tambah Akun',
            style: TextStyle(color: Colors.white)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Tambahakun()),
          );
          fetchUsers();
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: fetchUsers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Data Karyawan', karyawanList),
                      _buildSection('Data Teknisi', teknisiList,
                          isTeknisi: true),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}