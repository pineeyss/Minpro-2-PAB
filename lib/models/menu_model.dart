class MenuModel {
  final int? id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String gambar;

  MenuModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      nama: json['nama_menu'] ?? '',
      harga: json['harga'] ?? 0,
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_menu': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}