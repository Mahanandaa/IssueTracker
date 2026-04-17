import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambahAkun.dart';

class DataAkun extends StatefulWidget {
  const DataAkun({super.key});

  @override
  State<DataAkun> createState() => _DataAkunState();
}

class _DataAkunState extends State<DataAkun> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> karyawanList = [];
  List<Map<String, dynamic>> teknisiList = [];
  Map<String, double> teknisiRatings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
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

      // Hitung rating untuk setiap teknisi: total rating / jumlah tugas selesai
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
            // Rumus: total rating / jumlah tugas selesai
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
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
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                onPressed: () async {
                  await supabase.from('users').update({
                    'name': nameCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'updated_at': DateTime.now().toIso8601String(),
                  }).eq('id', user['id']);
                  if (mounted) Navigator.pop(context);
                  fetchUsers();
                },
                child: const Text('Simpan',
                    style:
                        TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
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

          // Rating hanya tampil untuk teknisi
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label:
            const Text('Tambah Akun', style: TextStyle(color: Colors.white)),
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