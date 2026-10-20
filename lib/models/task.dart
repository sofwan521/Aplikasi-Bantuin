/// Status yang mungkin dimiliki sebuah tugas.
class TaskStatus {
  TaskStatus._();

  static const String available = 'tersedia';
  static const String taken = 'diambil';
  static const String completed = 'selesai';
}

/// Model tugas harian yang ditawarkan pemosting.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.rate,
    required this.location,
    required this.distanceMeters,
    required this.latitude,
    required this.longitude,
    required this.deadline,
    required this.posterName,
    required this.rating,
    required this.isVerified,
    required this.photoUrl,
    required this.posterPhotoUrl,
    required this.status,
  });

  /// ID unik tugas.
  final String id;

  /// Judul tugas.
  final String title;

  /// Deskripsi lengkap tugas.
  final String description;

  /// ID kategori tempat tugas ini berada.
  final String categoryId;

  /// Imbalan dalam Rupiah.
  final int rate;

  /// Alamat lokasi tugas.
  final String location;

  /// Jarak lokasi dari pengguna dalam meter.
  final int distanceMeters;

  /// Koordinat lintang lokasi tugas.
  final double latitude;

  /// Koordinat bujur lokasi tugas.
  final double longitude;

  /// Batas waktu pengerjaan tugas.
  final DateTime deadline;

  /// Nama pengguna yang memposting tugas.
  final String posterName;

  /// Rating pemosting.
  final double rating;

  /// Apakah akun pemosting sudah terverifikasi.
  final bool isVerified;

  /// URL foto tugas.
  final String photoUrl;

  /// URL foto profil pemosting.
  final String posterPhotoUrl;

  /// Status tugas: tersedia, diambil, atau selesai.
  final String status;

  /// Membuat tugas dari data JSON.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['judul'] as String,
      description: json['deskripsi'] as String,
      categoryId: json['categoryId'] as String,
      rate: (json['tarif'] as num).toInt(),
      location: json['lokasi'] as String,
      distanceMeters: (json['jarak_meter'] as num).toInt(),
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      deadline: DateTime.parse(json['batas_waktu'] as String),
      posterName: json['nama_pemosting'] as String,
      rating: (json['rating'] as num).toDouble(),
      isVerified: json['verified'] as bool,
      photoUrl: json['foto_url'] as String,
      posterPhotoUrl: json['foto_pemosting_url'] as String,
      status: json['status'] as String,
    );
  }

  /// Mengubah tugas menjadi data JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'judul': title,
      'deskripsi': description,
      'categoryId': categoryId,
      'tarif': rate,
      'lokasi': location,
      'jarak_meter': distanceMeters,
      'lat': latitude,
      'lng': longitude,
      'batas_waktu': deadline.toIso8601String(),
      'nama_pemosting': posterName,
      'rating': rating,
      'verified': isVerified,
      'foto_url': photoUrl,
      'foto_pemosting_url': posterPhotoUrl,
      'status': status,
    };
  }
}
