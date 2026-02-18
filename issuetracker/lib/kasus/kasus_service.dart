import 'package:supabase_flutter/supabase_flutter.dart';

class KasusService {
  int? idKasus;
  int? idUsers;
  String judul;
  String deskripsi;
  String lokasi;
  String foto;
  PrioritasKasus prioritas;
  Status status;
  Kategori kategori;

  KasusService({
    this.idKasus,
    this.idUsers,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    required this.foto,
    required this.prioritas,
    required this.status,
    required this.kategori,
  });

  factory KasusService.fromMap(Map<String, dynamic> map) {
    return KasusService(
      idKasus: map['id_kasus'] as int,
      idUsers: map['id_users'] as int,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String,
      lokasi: map['lokasi'] as String,
      foto: map['foto'] as String,
      prioritas: PrioritasKasus.values.byName(map['prioritas']),
      status: Status.values.byName(map['status']),
      kategori: Kategori.values.byName(map['kategori']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_kasus': idKasus,
      'id_users': idUsers,
      'judul': judul,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'foto': foto,
      'prioritas': prioritas.name,
      'status': status.name,
      'kategori': kategori.name,
    };
  }
}

enum PrioritasKasus {
  low,
  medium,
  urgent
}

enum Status {
  pending,
  in_progress,
  resolved,
  rejected
}

enum Kategori {
  it_equipment,
  facilities,
  cleaning,
  security
}
