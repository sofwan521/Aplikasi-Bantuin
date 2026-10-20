/// Model kategori tugas.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.offerCount,
  });

  /// ID unik kategori.
  final String id;

  /// Nama kategori yang ditampilkan ke pengguna.
  final String name;

  /// Nama ikon Material, misalnya "pets" atau "menu_book".
  final String iconName;

  /// Jumlah tawaran tugas pada kategori ini.
  final int offerCount;

  /// Membuat kategori dari data JSON.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['nama'] as String,
      iconName: json['ikon'] as String,
      offerCount: (json['jumlah_tawaran'] as num).toInt(),
    );
  }

  /// Mengubah kategori menjadi data JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nama': name,
      'ikon': iconName,
      'jumlah_tawaran': offerCount,
    };
  }
}
