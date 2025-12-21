// lib/models/user_model.dart
class UserModel {
  final String? id; // ✅ GANTI: dari int? ke String?
  final String email;
  final String nama;
  final String? noHp;
  final String? alamatLengkap;
  final String role;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.email,
    required this.nama,
    this.noHp,
    this.alamatLengkap,
    this.role = 'customer',
    this.createdAt,
  });

  // ✅ Helper getter untuk cek admin
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(), // ✅ TAMBAH: konversi ke String
      email: json['email'],
      nama: json['nama'],
      noHp: json['no_hp'],
      alamatLengkap: json['alamat_lengkap'],
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'nama': nama,
      if (noHp != null) 'no_hp': noHp,
      if (alamatLengkap != null) 'alamat_lengkap': alamatLengkap,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
