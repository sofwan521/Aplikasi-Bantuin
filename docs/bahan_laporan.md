# 1. Halaman Judul

**[LOGO FAKULTAS]**

## LAPORAN UTS MOBILE PROGRAMMING

### BANTUIN: Marketplace Tugas Harian Berbasis Bantuan Sesama

| Keterangan | Isi |
| --- | --- |
| Nama | [NAMA MAHASISWA] |
| NIM | [NIM] |
| Kelas | [KELAS] |
| Program Studi | [PROGRAM STUDI] |
| Fakultas | [FAKULTAS] |
| Universitas | [UNIVERSITAS] |
| Mata Kuliah | Mobile Programming |
| Dosen Pengampu | [NAMA DOSEN] |
| Tahun Akademik | [TAHUN AKADEMIK] |

---

## 2. Pendahuluan

### 2.1 Deskripsi Tema

Aplikasi **Bantuin** merupakan aplikasi mobile berbasis *marketplace* tugas harian yang mempertemukan pemosting tugas dengan pengguna yang bersedia membantu. Tema yang diangkat adalah kegiatan tolong-menolong dalam kehidupan sehari-hari, seperti mengajak anjing berjalan, membantu pindahan, membersihkan rumah, menemani belanja, atau membantu belajar.

Dalam aplikasi ini, pengguna berperan sebagai **agen**. Agen dapat melihat daftar tugas, mencari tugas berdasarkan kata kunci, memfilter kategori dan tarif, membaca detail tugas, menyimpan favorit, lalu menekan tombol **Ambil** untuk mengerjakan tugas dan memperoleh imbalan dalam Rupiah. Aplikasi **tidak menyediakan fitur membuat atau memasang tugas**, sehingga seluruh tugas berasal dari data dummy yang telah disediakan.

Setiap tugas memuat informasi berupa judul, deskripsi, kategori, tarif, lokasi, jarak, batas waktu, nama pemosting, rating, status verifikasi, dan status tugas. Informasi tersebut ditampilkan melalui halaman Beranda, Kategori, Detail, Peta, Favorit, Tugas Saya, Chat, dan Profil.

### 2.2 Alasan Pemilihan Tema

Tema bantuan sesama dipilih karena relevan dengan aktivitas masyarakat urban yang padat. Tidak semua orang memiliki waktu, tenaga, atau keterampilan untuk menyelesaikan pekerjaan harian tertentu. Di sisi lain, terdapat pengguna lain yang memiliki waktu dan kemampuan untuk membantu. Aplikasi Bantuin menawarkan alur yang sederhana dan transparan untuk mempertemukan kedua kebutuhan tersebut.

Selain itu, tema ini memberikan ruang eksplorasi antarmuka yang cukup luas. Pengembang dapat menerapkan berbagai komponen Flutter, seperti `Row`, `Column`, `Stack`, `ListView`, `Card`, `BottomNavigationBar`, `FutureBuilder`, serta widget kustom yang dapat digunakan kembali. Kebutuhan untuk menampilkan daftar tugas, kategori, peta, detail, favorit, dan status pengambilan tugas juga mendorong penerapan pemisahan model, layanan, halaman, widget, tema, dan rute.

### 2.3 Relevansi terhadap Aplikasi Mobile

Aplikasi mobile memiliki karakteristik yang sesuai dengan kebutuhan Bantuin, antara lain:

1. **Mobilitas:** agen dapat mencari dan mengambil tugas kapan saja melalui perangkat yang dibawa sehari-hari.
2. **Kedekatan lokasi:** informasi alamat, jarak, dan sebaran tugas pada peta membantu agen memilih tugas yang terjangkau.
3. **Interaksi cepat:** pencarian, filter, favorit, dan tombol **Ambil** memberikan alur yang singkat dengan umpan balik langsung.
4. **Personalisasi:** halaman Favorit, Tugas Saya, dan Profil membantu agen mengelola tugas yang diminati serta tugas yang telah diambil.
5. **Potensi pengembangan:** aplikasi mobile dapat dikembangkan dengan GPS *real-time*, notifikasi push, pembayaran digital, autentikasi, dan chat langsung.

### 2.4 Ruang Lingkup

Versi ini merupakan prototipe untuk memenuhi tugas UTS. Data kategori dan tugas masih berupa data dummy dari JSON lokal. Favorit dan tugas yang diambil disimpan di memori melalui `AppState`, sehingga data tersebut kembali kosong ketika aplikasi ditutup. Peta yang digunakan adalah peta statis, bukan peta interaktif berbasis Google Maps API. Fitur chat, bagikan, pengaturan, dan bantuan masih berupa tampilan dengan umpan balik *snackbar*.

---

## 3. Perancangan Antarmuka

### 3.1 Sumber dan Konsep Visual

Referensi desain awal diambil dari **Task App, Figma Community (dimodifikasi)**. Referensi tersebut kemudian disesuaikan dengan identitas Bantuin, kebutuhan data lokal, serta komponen Flutter yang digunakan. Spesifikasi warna, tipografi, radius, shadow, dan spacing dicatat pada `docs/DESIGN.md`, sedangkan gambar referensi utama tersedia di `design/ui_reference.png`.

Konsep visual Bantuin dirancang agar terasa ramah, hangat, dan mudah digunakan. Aksen kuning dipilih sebagai warna utama karena memberikan kesan energik dan menonjolkan ajakan untuk membantu. Latar halaman menggunakan abu sangat terang agar kartu putih terlihat bersih dan memiliki hierarki visual yang jelas. Teks utama berwarna hitam tua untuk menjaga keterbacaan, sedangkan teks sekunder berwarna abu untuk informasi pendukung.

**[SCREENSHOT: `design/ui_reference.png` — Referensi desain awal dari Task App, Figma Community (dimodifikasi)]**

### 3.2 Konsep Warna

| Warna | Hex | Penerapan |
| --- | --- | --- |
| Kuning aksen | `#FFCC00` | Tombol utama, tombol filter, tombol tengah, dan elemen penekanan |
| Latar halaman | `#FAFAFA` | Latar seluruh layar |
| Permukaan kartu | `#FFFFFF` | Kartu tugas, tile kategori, search bar, dan bottom navigation |
| Teks utama | `#1A1A1A` | Judul, label penting, dan nominal Rupiah |
| Teks sekunder | `#666666` | Deskripsi pendukung, jarak, dan caption |
| Hijau verifikasi | `#00C853` | Centang akun terverifikasi |
| Abu divider | `#E0E0E0` | Garis pemisah dan border lembut |
| Merah favorit | `#E53935` | Ikon hati saat tugas disimpan |
| Placeholder | `#EEEEEE` | Latar gambar yang belum tersedia atau gagal dimuat |

Warna tersebut dipusatkan di `lib/theme/app_theme.dart` melalui kelas `AppColors`. Pemusatan warna bertujuan agar perubahan tema dapat dilakukan sekali tanpa mengubah banyak file.

### 3.3 Konsep Ikon

Aplikasi menggunakan **Material Icons** bawaan Flutter agar konsisten dengan gaya Material 3. Ikon kategori dipetakan dari field `ikon` pada JSON melalui fungsi `categoryIconFromName` di `lib/widgets/category_tile.dart`, yaitu:

- `local_shipping` untuk kategori Pindah Rumah;
- `home_repair_service` untuk Membantu Sekitar Rumah;
- `pets` untuk Hewan Peliharaan;
- `shopping_bag` untuk Belanja dan Antar;
- `cleaning_services` untuk Kebersihan;
- `menu_book` untuk Bantuan Belajar.

Ikon lain yang digunakan antara lain `search`, `tune`, `favorite_border`, `chat_bubble_outline`, `place_outlined`, `verified`, `home`, `person_outline`, `chevron_right`, dan `checklist_rounded`. Ikon hati ditempatkan pada kartu dan halaman detail, ikon lokasi berada di samping alamat, sedangkan ikon ceklis digunakan pada tombol tengah bottom navigation untuk membuka halaman Tugas Saya.

### 3.4 Konsep Layout

Layout dirancang dengan pendekatan *mobile-first* dan memperhatikan kenyamanan penggunaan satu tangan:

1. **Padding layar:** 16 dp di kiri dan kanan.
2. **Kartu:** sudut membulat 16 dp dengan shadow tipis agar terlihat mengambang lembut.
3. **Search bar dan tombol filter:** berada dalam satu baris; search bar mengisi ruang tersisa, sedangkan tombol filter kuning berukuran 52 × 52 dp berada di sebelah kanan.
4. **Kartu rekomendasi:** ditampilkan horizontal dengan lebar dan tinggi yang menyesuaikan ukuran layar agar tetap proporsional.
5. **Daftar kategori:** menggunakan `Column` berisi tile dengan ikon, nama kategori, jumlah tugas, dan chevron.
6. **Bottom navigation:** lima item dengan tombol ceklis kuning yang menonjol di tengah untuk membuka halaman Tugas Saya.
7. **Halaman detail:** foto header tinggi dengan sudut bawah membulat, informasi tugas di bawahnya, dan baris aksi tetap di bagian bawah.
8. **Peta:** latar peta statis dengan avatar pemosting yang diposisikan menggunakan `Stack` dan `Positioned`, serta kartu informasi tugas di bawah peta.
9. **Hasil pencarian dan filter:** menggunakan daftar kartu vertikal agar informasi tugas lebih mudah dibaca.

Layout memanfaatkan kombinasi `Row`, `Column`, `Stack`, `ListView`, `Card`, `Expanded`, dan `ConstrainedBox`. Beberapa ukuran dibatasi dengan `clamp` agar tetap proporsional pada layar kecil maupun besar.

### 3.5 Konsep Tipografi

Tipografi menggunakan font **Montserrat** melalui paket `google_fonts`. Pemilihan Montserrat bertujuan memberikan kesan modern, tegas, dan mudah dibaca pada antarmuka mobile.

| Elemen | Ukuran | Ketebalan | Warna |
| --- | --- | --- | --- |
| Judul layar / heading | 20 sp | Bold | Teks utama |
| Judul tugas / kartu | 16 sp | Semi-bold | Teks utama |
| Deskripsi | 14 sp | Regular | Teks utama |
| Caption / keterangan | 12 sp | Regular | Teks sekunder |
| Nominal Rupiah | 16 sp | Bold | Teks utama |

Nominal Rupiah sengaja menggunakan warna teks utama, bukan kuning, agar tetap terbaca jelas. Format nominal dibuat otomatis menjadi bentuk seperti `Rp 100.000`.

### 3.6 Radius, Shadow, dan Spacing

| Token | Nilai | Penggunaan |
| --- | --- | --- |
| Radius kartu | 16 dp | Kartu tugas, kartu informasi, dan permukaan utama |
| Radius foto | 16 dp | Foto tugas dan header detail |
| Radius tombol | 12 dp | Tombol utama dan tombol filter |
| Radius search bar | 12 dp | Kolom pencarian |
| Radius avatar/chip | 20 dp | Avatar dan chip pemosting |
| Radius chip kategori | 8 dp | Chip kategori dan label kecil |
| Shadow kartu | `black12`, blur 8, offset (0, 4) | Kartu dan elemen mengambang |
| Shadow tombol | `black12`, blur 6, offset (0, 2) | Tombol utama |
| Gap antarelemen | 8, 12, 16 dp | Jarak antar komponen |
| Tinggi bottom nav | 70 dp | Navigasi bawah |
| Tinggi tombol utama | 50 dp | Tombol aksi utama |

### 3.7 Komponen Reusable

Komponen yang dipisahkan ke `lib/widgets/` antara lain:

1. `AppSearchBar` — kolom pencarian dengan ikon kaca pembesar.
2. `FilterButton` — tombol filter kuning tanpa teks.
3. `TaskCard` — kartu tugas horizontal pada beranda.
4. `TaskListCard` — kartu tugas berbentuk baris untuk hasil pencarian, kategori, favorit, dan Tugas Saya.
5. `CategoryTile` — tile kategori dengan ikon dan jumlah tugas.
6. `PrimaryButton` — tombol utama kuning dengan label dan ikon opsional.
7. `VerifiedAvatarChip` — avatar dengan centang verifikasi, nama, dan rating pemosting.
8. `AppImage` — gambar dari aset atau jaringan dengan fallback placeholder.

---

## 4. Implementasi Program

### 4.1 Teknologi dan Alat

- **Framework:** Flutter dengan Material 3.
- **Bahasa:** Dart.
- **Font:** `google_fonts` dengan keluarga Montserrat.
- **Data:** aset JSON lokal di `assets/data/`.
- **Gambar:** aset lokal di `assets/images/` dan URL avatar eksternal.
- **State management:** `ChangeNotifier` dan `InheritedNotifier` melalui `AppState` dan `AppStateScope`.
- **Linting:** `flutter_lints`.
- **Pengujian:** `flutter_test` dengan widget test dasar yang memeriksa keberadaan kolom pencarian pada Beranda.

### 4.2 Struktur Halaman dan Rute

Aplikasi menggunakan `MainShell` sebagai kerangka utama. Empat halaman ditampilkan melalui `IndexedStack`, sedangkan tombol tengah membuka halaman Tugas Saya. Rute bernama didefinisikan secara terpusat di `lib/routes/app_routes.dart`.

| Halaman | File | Rute | Keterangan |
| --- | --- | --- | --- |
| Kerangka utama | `lib/pages/main_shell.dart` | `/` | Bottom navigation, `IndexedStack`, dan tombol tengah |
| Beranda | `lib/pages/home_page.dart` | Tab pertama `MainShell` | Pencarian seluruh tugas, filter, rekomendasi, dan kategori |
| Kategori | `lib/pages/category_page.dart` | `/kategori` | Daftar tugas berdasarkan kategori |
| Detail | `lib/pages/detail_page.dart` | `/detail` | Detail tugas dan aksi ambil |
| Peta | `lib/pages/map_page.dart` | `/peta` | Peta statis dan kartu info tugas |
| Favorit | `lib/pages/favorites_page.dart` | `/favorit` dan tab kedua | Daftar tugas favorit |
| Chat | `lib/pages/chat_page.dart` | `/chat` dan tab ketiga | Daftar percakapan dummy |
| Profil | `lib/pages/profile_page.dart` | `/profil` dan tab keempat | Profil, statistik, dan menu |
| Tugas Saya | `lib/pages/my_tasks_page.dart` | `/tugas-saya` | Tugas yang telah diambil agen |

### 4.3 Widget Utama dan Navigasi Bawah

Widget utama aplikasi adalah `MainShell`. Widget ini menggabungkan halaman-halaman utama dengan `IndexedStack` agar state setiap tab tetap terjaga. Tombol tengah tidak berpindah tab, tetapi membuka `MyTasksPage` melalui `Navigator.push`.

```dart
// lib/pages/main_shell.dart (diringkas)
void _onNavTap(int index) {
  if (index == 2) {
    _openMyTasks();
    return;
  }

  setState(() {
    _navIndex = index;
  });
}

void _openMyTasks() {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MyTasksPage(repository: _repository),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: IndexedStack(
      index: _pageIndex,
      children: [
        HomePage(repository: _repository),
        FavoritesPage(repository: _repository),
        const ChatPage(),
        const ProfilePage(),
      ],
    ),
    bottomNavigationBar: _MainBottomNavigationBar(
      currentIndex: _navIndex,
      onTap: _onNavTap,
    ),
  );
}
```

Tombol tengah menggunakan lingkaran kuning dengan ikon ceklis. Kode berikut menunjukkan inti tombol tersebut:

```dart
Tooltip(
  message: 'Tugas Saya',
  child: Material(
    color: AppColors.accent,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: () => onTap(2),
      customBorder: const CircleBorder(),
      child: const SizedBox(
        width: 56,
        height: 56,
        child: Icon(
          Icons.checklist_rounded,
          size: 30,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  ),
)
```

Kartu tugas pada Beranda menggunakan `TaskCard.fromTask`, sedangkan hasil pencarian, Kategori, Favorit, dan Tugas Saya menggunakan `TaskListCard`. Keduanya menerima status favorit dari `AppState` dan aksi navigasi ke halaman detail.

### 4.4 Navigasi Antarlayar

Navigasi menggunakan dua mekanisme, yaitu `BottomNavigationBar` untuk halaman utama dan `Navigator.pushNamed` untuk halaman turunan. Rute yang membutuhkan argumen objek `Category` atau `Task` ditangani melalui `onGenerateRoute`.

```dart
// lib/routes/app_routes.dart (diringkas)
static const String category = '/kategori';
static const String detail = '/detail';
static const String map = '/peta';
static const String favorites = '/favorit';
static const String chat = '/chat';
static const String profile = '/profil';
static const String myTasks = '/tugas-saya';

static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  if (settings.name == category) {
    final Object? arguments = settings.arguments;
    if (arguments is Category) {
      return MaterialPageRoute<void>(
        builder: (_) => CategoryPage(category: arguments),
        settings: settings,
      );
    }
  }

  if (settings.name == detail) {
    final Object? arguments = settings.arguments;
    if (arguments is Task) {
      return MaterialPageRoute<void>(
        builder: (_) => DetailPage(task: arguments),
        settings: settings,
      );
    }
  }

  if (settings.name == map) {
    return MaterialPageRoute<void>(
      builder: (_) => const MapPage(),
      settings: settings,
    );
  }

  return null;
}
```

Halaman Beranda menghubungkan pengguna ke Peta, Kategori, dan Detail. Halaman Kategori, Peta, Favorit, dan Tugas Saya dapat membuka Detail. Dengan demikian, aplikasi memiliki lebih dari tiga halaman yang saling terhubung melalui navigasi.

### 4.5 Tema dan Tipografi Montserrat

Tema utama didefinisikan di `lib/theme/app_theme.dart`. Warna aksen `#FFCC00` didefinisikan sekali pada `AppColors.accent` dan digunakan secara konsisten. Font Montserrat diterapkan melalui `GoogleFonts.montserratTextTheme()`.

```dart
// lib/theme/app_theme.dart (diringkas)
class AppColors {
  AppColors._();

  static const Color accent = Color(0xFFFFCC00);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
}

static ThemeData get light {
  final TextTheme baseTextTheme = GoogleFonts.montserratTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    textTheme: baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
```

### 4.6 Pengolahan Data Dummy JSON

Data dummy berada di `assets/data/categories.json` dan `assets/data/tasks.json`. Saat ini tersedia enam kategori dan dua belas tugas. Seluruh tugas berstatus `tersedia` pada data awal. Kedua file didaftarkan pada bagian `assets` di `pubspec.yaml`, kemudian dimuat oleh `LocalJsonRepository` melalui `rootBundle`.

Alur pengolahan data adalah sebagai berikut:

1. `LocalJsonRepository` membaca file JSON menggunakan `rootBundle.loadString`.
2. String JSON diubah menjadi `List<dynamic>` dengan `jsonDecode`.
3. Setiap item dipetakan menjadi objek `Category` atau `Task` melalui `fromJson`.
4. Hasilnya disimpan sebagai cache di memori agar pembacaan berikutnya lebih efisien.
5. Halaman UI mengambil data melalui `FutureBuilder` dan menampilkan state loading, error, atau konten.
6. Status favorit dan tugas yang diambil dibaca dari `AppState` saat kartu tugas ditampilkan.

Model `Task` memetakan field JSON berbahasa Indonesia menjadi properti Dart:

```dart
// lib/models/task.dart (diringkas)
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
```

Proses pembacaan aset dan konversi data dilakukan di repository:

```dart
// lib/services/task_repository.dart (diringkas)
Future<List<Task>> _loadTasks() async {
  final String raw = await _bundle.loadString(tasksAssetPath);
  final List<dynamic> data = jsonDecode(raw) as List<dynamic>;

  return data
      .map((dynamic item) => Task.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}
```

Data yang sedang dimuat ditampilkan melalui `FutureBuilder`. Jika terjadi kesalahan, pengguna mendapat tombol **Coba lagi** untuk memuat ulang data:

```dart
FutureBuilder<_HomeData>(
  future: _dataFuture,
  builder: (BuildContext context, AsyncSnapshot<_HomeData> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const _LoadingState();
    }
    if (snapshot.hasError) {
      return _ErrorState(onRetry: _reload);
    }
    return _buildContent(context, snapshot.data!);
  },
);
```

### 4.7 `TaskRepository` sebagai Lapisan yang Siap Diganti API

`TaskRepository` di `lib/services/task_repository.dart` adalah kontrak sumber data. Halaman UI bergantung pada abstraksi ini, bukan pada cara data dimuat. Implementasi saat ini adalah `LocalJsonRepository`, sedangkan integrasi API nantinya dapat dibuat sebagai implementasi baru tanpa mengubah halaman.

```dart
// lib/services/task_repository.dart (diringkas)
abstract class TaskRepository {
  Future<List<Category>> getCategories();
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksByCategory(String categoryId);
  Future<Task?> getTaskById(String id);
  Future<Map<String, int>> countTasksByCategory();
}
```

`HomePage`, `CategoryPage`, `MapPage`, `FavoritesPage`, dan `MyTasksPage` menerima parameter `repository` opsional. `MainShell` membuat satu repository dan meneruskannya ke Beranda, Favorit, serta Tugas Saya. Pola ini memudahkan penggantian sumber data dan pengujian.

| Method | Fungsi | Rencana endpoint API |
| --- | --- | --- |
| `getCategories()` | Mengambil seluruh kategori. | `GET /categories` |
| `getTasks()` | Mengambil seluruh tugas. | `GET /tasks` |
| `getTasksByCategory(categoryId)` | Mengambil tugas pada satu kategori. | `GET /tasks?categoryId={id}` |
| `getTaskById(id)` | Mengambil satu tugas berdasarkan ID. | `GET /tasks/{id}` |
| `countTasksByCategory()` | Menghitung jumlah tugas per kategori. | `GET /categories/counts` atau dihitung dari `GET /tasks` |

Aksi favorit dan pengambilan tugas belum menjadi method repository karena masih disimpan di `AppState`. Pada integrasi API, keduanya dapat ditambahkan sebagai endpoint tulis, misalnya `POST /favorites`, `DELETE /favorites/{id}`, dan `PATCH /tasks/{id}/status`. Tidak diperlukan endpoint untuk membuat tugas karena aplikasi hanya digunakan oleh agen.

### 4.8 Pencarian dan Filter

Pencarian pada Beranda bekerja terhadap seluruh data tugas, bukan hanya empat tugas rekomendasi. Kata kunci dicocokkan secara *case-insensitive* pada judul, deskripsi, dan lokasi.

```dart
// lib/pages/home_page.dart (diringkas)
List<Task> _filterTasks(List<Task> tasks) {
  final String query = _query.trim().toLowerCase();
  final RangeValues? rateRange = _filter.rateRange;

  return tasks
      .where((Task task) {
        final bool matchesQuery =
            query.isEmpty ||
            task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query) ||
            task.location.toLowerCase().contains(query);
        final bool matchesCategory =
            _filter.categoryId == null ||
            task.categoryId == _filter.categoryId;
        final bool matchesRate =
            rateRange == null ||
            (task.rate >= rateRange.start && task.rate <= rateRange.end);
        return matchesQuery && matchesCategory && matchesRate;
      })
      .toList(growable: false);
}
```

Tombol filter membuka bottom sheet yang berisi chip kategori dan `RangeSlider` tarif. Nilai minimum dan maksimum slider dihitung dari data tugas. Pengguna dapat menekan **Reset** untuk menghapus filter atau **Terapkan** untuk memakai pilihan. Filter digabungkan dengan kata kunci pencarian.

Saat pencarian atau filter aktif, bagian rekomendasi dan kategori disembunyikan. Hasil ditampilkan sebagai daftar vertikal `TaskListCard` dengan teks jumlah hasil, misalnya `3 hasil`. Jika tidak ada hasil, muncul empty state `Tugas tidak ditemukan`. Ketika kata kunci dikosongkan dan filter direset, tampilan Beranda kembali normal.

```dart
// lib/pages/home_page.dart (diringkas)
if (_isSearchOrFilterActive) {
  return _SearchResults(tasks: filteredTasks);
}

return _buildHomeSections(context, data);
```

### 4.9 State Tugas Diambil

Favorit dan tugas yang diambil dikelola oleh `AppState`, sebuah `ChangeNotifier` yang disediakan ke seluruh widget melalui `AppStateScope`. Perubahan favorit langsung memperbarui kartu tugas, halaman Favorit, dan jumlah favorit di Profil.

```dart
// lib/services/app_state.dart (diringkas)
final Set<String> _favoriteTaskIds = <String>{};
final Set<String> _takenTaskIds = <String>{};

bool isTaken(String taskId) => _takenTaskIds.contains(taskId);

void takeTask(String taskId) {
  if (_takenTaskIds.add(taskId)) {
    notifyListeners();
  }
}
```

Halaman Detail meminta konfirmasi sebelum tugas diambil. Setelah dikonfirmasi, ID tugas disimpan ke `AppState` dan snackbar keberhasilan ditampilkan:

```dart
// lib/pages/detail_page.dart (diringkas)
AppStateScope.read(context).takeTask(widget.task.id);
_showMessage('Tugas berhasil diambil');
```

Status tombol pada Detail dihitung dari status JSON dan `AppState`. Tugas yang sudah diambil atau selesai tidak dapat diambil kembali. Halaman Tugas Saya kemudian membaca data tugas dan memfilter status `diambil` atau ID yang tercatat di `AppState`:

```dart
// lib/pages/my_tasks_page.dart (diringkas)
final List<Task> takenTasks = (snapshot.data ?? const <Task>[])
    .where(
      (Task task) =>
          task.status == TaskStatus.taken ||
          appState.isTaken(task.id),
    )
    .toList(growable: false);
```

Karena seluruh data dummy saat ini berstatus `tersedia`, halaman Tugas Saya kosong pada saat aplikasi pertama dibuka. Halaman tersebut terisi setelah pengguna menekan **Ambil** pada salah satu tugas. Empty state yang ditampilkan adalah `Belum ada tugas yang diambil`.

### 4.10 Screenshot Implementasi

**[SCREENSHOT: `docs/screenshots/beranda.png` — Halaman Beranda menampilkan pencarian, rekomendasi, dan kategori]**

**[SCREENSHOT: `docs/screenshots/filter.png` — Bottom sheet filter kategori dan rentang tarif]**

**[SCREENSHOT: `docs/screenshots/kategori.png` — Halaman Kategori menampilkan daftar tugas sesuai kategori]**

**[SCREENSHOT: `docs/screenshots/detail.png` — Halaman Detail Tugas menampilkan foto, tarif, lokasi, dan tombol Ambil]**

**[SCREENSHOT: `docs/screenshots/peta.png` — Halaman Peta menampilkan sebaran avatar dan kartu info tugas]**

**[SCREENSHOT: `docs/screenshots/favorit.png` — Halaman Favorit menampilkan tugas yang disimpan pengguna]**

**[SCREENSHOT: `docs/screenshots/chat.png` — Halaman Chat menampilkan daftar percakapan dummy]**

**[SCREENSHOT: `docs/screenshots/profil.png` — Halaman Profil menampilkan data pengguna dan statistik]**

**[SCREENSHOT: `docs/screenshots/tugas_saya.png` — Halaman Tugas Saya menampilkan tugas yang telah diambil]**

---

## 5. Hasil dan Pembahasan

### 5.1 Fungsi Tiap Halaman

| Halaman | Fungsi Utama |
| --- | --- |
| Beranda | Menampilkan pencarian seluruh tugas, filter kategori dan tarif, empat kartu rekomendasi, serta enam kategori dengan jumlah tugas. |
| Kategori | Menampilkan tugas pada kategori terpilih, dengan status loading, error, empty state, tombol favorit, dan navigasi ke detail. |
| Detail Tugas | Menampilkan foto, pemosting, tenggat, judul, deskripsi, tarif, lokasi, jarak, tombol favorit, bagikan, chat, dan tombol **Ambil** dengan dialog konfirmasi. |
| Peta | Menampilkan sebaran avatar pemosting berdasarkan koordinat, penyebaran avatar agar tidak bertumpuk, kartu info tugas, dan navigasi ke detail. |
| Favorit | Menampilkan tugas yang disimpan pengguna, memperbarui daftar saat favorit diubah, dan menyediakan empty state. |
| Chat | Menampilkan daftar percakapan dummy beserta waktu dan pesan terakhir; aksi membuka percakapan masih berupa placeholder. |
| Profil | Menampilkan kartu pengguna, jumlah favorit, statistik tugas diambil, serta menu Pengaturan dan Bantuan. |
| Tugas Saya | Menampilkan tugas yang telah diambil dari status JSON atau `AppState`, berupa `TaskListCard`, dan dapat dibuka ke detail. |

### 5.2 Alur Interaksi Pengguna

1. **Membuka aplikasi:** pengguna masuk ke Beranda. Data dimuat dari JSON dan ditampilkan setelah indikator loading selesai. Jika gagal, muncul pesan error dan tombol **Coba lagi**.
2. **Mencari tugas:** pengguna mengetik kata kunci pada search bar. Seluruh tugas difilter berdasarkan judul, deskripsi, dan lokasi. Hasil tampil sebagai daftar vertikal dengan jumlah hasil.
3. **Memfilter tugas:** pengguna menekan tombol filter, memilih kategori, mengatur rentang tarif, lalu menekan **Terapkan**. Filter dapat direset dan digabungkan dengan pencarian.
4. **Menjelajahi kategori:** pengguna memilih salah satu tile kategori. Halaman Kategori menampilkan tugas yang sesuai dan dapat membuka Detail.
5. **Melihat peta:** pengguna menekan **Lihat di peta**. Avatar pemosting tampil pada peta statis; menekan avatar memperbarui kartu info, lalu kartu dapat ditekan untuk membuka Detail.
6. **Menyimpan favorit:** pengguna menekan ikon hati pada kartu atau Detail. Ikon berubah warna, tugas muncul di halaman Favorit, dan jumlah favorit di Profil bertambah.
7. **Mengambil tugas:** pengguna menekan **Ambil** pada Detail. Dialog konfirmasi muncul; setelah dikonfirmasi, status tombol berubah menjadi **Sudah Diambil**, snackbar keberhasilan tampil, dan tugas masuk ke halaman Tugas Saya.
8. **Membuka Tugas Saya:** pengguna menekan tombol ceklis kuning di tengah bottom navigation. Halaman Tugas Saya terbuka melalui `Navigator.push` dan menampilkan daftar tugas yang telah diambil.
9. **Membuka chat dan profil:** pengguna berpindah melalui bottom navigation. Chat menampilkan percakapan dummy, sedangkan Profil menampilkan ringkasan pengguna dan menu yang masih berupa placeholder.

### 5.3 Perbandingan Desain Awal dan Hasil Akhir

| Aspek | Desain Awal | Hasil Akhir | Adaptasi |
| --- | --- | --- | --- |
| Identitas dan bahasa | Mengacu pada Task App, Figma Community | Aplikasi Bantuin dengan seluruh teks Bahasa Indonesia | Nama, istilah, dan konten disesuaikan dengan konteks bantuan harian. |
| Warna | Aksen kuning | Aksen `#FFCC00` pada tombol utama, filter, dan tombol tengah | Palet dipertahankan dan dipusatkan di `AppColors`. |
| Tipografi | Montserrat | Montserrat melalui `google_fonts` | Diterapkan global melalui `AppTheme.light`. |
| Mata uang | Belum ditentukan | Rupiah dengan format `Rp 100.000` | Nominal data JSON ditampilkan menggunakan format Rupiah. |
| Navigasi tengah | Tombol `+` untuk menambah tugas | Tombol ceklis kuning untuk membuka Tugas Saya | Fitur membuat tugas dihapus karena pengguna hanya berperan sebagai agen. |
| Pembuatan tugas | Tersedia melalui bottom sheet | Tidak tersedia | Aplikasi hanya menyediakan alur mencari dan mengambil tugas. |
| Pencarian | Search bar pada Beranda | Pencarian seluruh tugas berdasarkan judul, deskripsi, dan lokasi | Hasil tampil sebagai daftar kartu vertikal dengan jumlah hasil dan empty state. |
| Filter | Tombol filter pada desain awal | Bottom sheet kategori dan rentang tarif | Filter berfungsi dan digabungkan dengan pencarian. |
| Peta | Peta statis dengan aset `map.png` | Peta statis dengan fallback `CustomPaint` karena aset peta belum tersedia | Tidak menggunakan Google Maps API dan tidak memerlukan GPS. |
| Halaman | Beranda, Peta, dan Detail | Beranda, Kategori, Detail, Peta, Favorit, Chat, Profil, dan Tugas Saya | Halaman pelengkap ditambahkan untuk mendukung alur agen. |
| Status tugas | Tombol **Ambil** pada Detail | Status tersimpan di `AppState` dan tampil di Tugas Saya | State bersama memungkinkan tugas yang diambil muncul di halaman lain. |

**[SCREENSHOT: `docs/screenshots/perbandingan_desain.png` — Perbandingan desain awal dan hasil implementasi]**

### 5.4 Fitur yang Masih Berupa Tampilan dan Rencana Pengembangan

| Fitur | Kondisi Saat Ini | Rencana Pengembangan |
| --- | --- | --- |
| Chat | Halaman Chat berisi percakapan dummy; tombol chat pada Detail dan kartu menampilkan snackbar. | Menghubungkan chat ke backend atau WebSocket, menyimpan riwayat pesan, menambahkan status baca, dan notifikasi. |
| Bagikan | Tombol bagikan pada Detail menampilkan snackbar. | Menggunakan `share_plus` atau tautan dalam aplikasi untuk membagikan detail tugas. |
| Pengaturan | Menu Pengaturan pada Profil menampilkan snackbar. | Menambahkan preferensi akun, notifikasi, tema, dan pengaturan privasi. |
| Bantuan | Menu Bantuan pada Profil menampilkan snackbar. | Menyediakan pusat bantuan, FAQ, dan kanal kontak. |
| Lihat semua kategori | Tautan pada bagian kategori menampilkan snackbar. | Membuat halaman daftar seluruh kategori atau halaman eksplorasi. |
| Peta | Peta statis dengan avatar berdasarkan koordinat dummy; tidak menggunakan GPS. | Mengintegrasikan peta interaktif, geolokasi, dan pembaruan posisi secara *real-time*. |
| Statistik profil | Jumlah favorit mengikuti `AppState`; statistik tugas diambil masih statis. | Menghitung statistik dari data tugas dan menyinkronkannya dengan API. |
| Penyimpanan | Favorit dan tugas yang diambil hanya tersimpan di memori. | Menambahkan penyimpanan lokal permanen atau sinkronisasi dengan backend. |

Semua tombol placeholder memakai snackbar dengan pesan yang sama, yaitu `Fitur ini akan tersedia pada pengembangan berikutnya`.

### 5.5 Responsivitas dan Penanganan State

Aplikasi telah dilengkapi beberapa penyesuaian responsif dan penanganan state:

- Ukuran kartu rekomendasi dihitung dari ukuran layar dengan `clamp` agar tidak terlalu kecil atau terlalu besar.
- Judul bagian dibatasi dua baris dan menggunakan ellipsis.
- Bottom sheet filter dapat digulir dan menggunakan `SafeArea`.
- Chip pemosting pada header detail dibatasi agar tidak bertabrakan dengan label tenggat.
- Halaman Beranda, Kategori, Peta, Favorit, dan Tugas Saya memiliki state loading, error, dan retry.
- Halaman Kategori, Peta, Favorit, Tugas Saya, dan Chat memiliki empty state yang informatif.
- Gambar yang gagal dimuat akan menampilkan placeholder atau inisial nama.
- Perubahan favorit dan tugas yang diambil langsung memperbarui widget yang bergantung pada `AppState`.

### 5.6 Keterbatasan

1. Data masih statis dan belum terhubung ke backend.
2. Favorit dan tugas yang diambil belum disimpan ke penyimpanan permanen.
3. Peta belum interaktif dan belum menggunakan layanan peta.
4. Chat, bagikan, pengaturan, bantuan, dan tautan lihat semua kategori belum berfungsi penuh.
5. Statistik tugas diambil pada Profil belum terhubung ke `AppState`.
6. Belum ada autentikasi, pembayaran, notifikasi push, dan validasi pengguna secara nyata.
7. Pengujian otomatis masih terbatas pada widget test dasar.

---

## 6. Kesimpulan

### 6.1 Ringkasan Proses

Perancangan dan implementasi aplikasi Bantuin dimulai dari analisis kebutuhan tugas UTS, penyusunan tema, perancangan antarmuka berdasarkan referensi **Task App, Figma Community (dimodifikasi)**, pembuatan model data, repository JSON lokal, tema global, widget reusable, serta sembilan halaman utama. Selanjutnya dilakukan integrasi navigasi, pengelolaan state favorit dan tugas yang diambil, penanganan loading/error/empty state, serta penyesuaian responsif.

Pencarian dan filter dikembangkan agar bekerja pada seluruh data tugas. Tombol tengah bottom navigation diubah dari tombol tambah tugas menjadi tombol ceklis untuk membuka halaman Tugas Saya. Perubahan ini menegaskan bahwa aplikasi hanya digunakan oleh agen untuk mencari dan mengambil tugas.

### 6.2 Pencapaian

1. Aplikasi Flutter berhasil dibuat dengan tema Bantuin, font Montserrat, dan aksen `#FFCC00`.
2. Seluruh halaman wajib tersedia dan saling terhubung melalui bottom navigation serta `Navigator.pushNamed`.
3. Data dummy dari `categories.json` dan `tasks.json` berhasil dimuat, dipetakan ke model, dan ditampilkan pada UI.
4. Repository menggunakan abstraksi `TaskRepository` dengan implementasi `LocalJsonRepository`, sehingga siap diganti dengan API.
5. Pencarian seluruh tugas, filter kategori dan tarif, favorit, peta statis, detail tugas, serta alur ambil tugas telah berfungsi pada tingkat prototipe.
6. Tugas yang diambil tersimpan di `AppState` dan tampil pada halaman Tugas Saya.
7. Penanganan state loading, error, empty, dan retry diterapkan pada halaman-halaman utama.
8. Struktur kode mengikuti pemisahan model, service, halaman, widget, tema, dan rute sehingga lebih mudah dirawat.

### 6.3 Refleksi

Proyek ini memberikan pengalaman dalam menerjemahkan rancangan visual menjadi antarmuka Flutter yang responsif. Tantangan utama muncul pada penyesuaian ukuran layar, pengelolaan state agar favorit dan tugas yang diambil konsisten di beberapa halaman, serta pemisahan logika data dari widget UI. Penggunaan widget reusable dan token tema terbukti membantu menjaga konsistensi tampilan.

Perubahan peran aplikasi menjadi khusus agen juga menuntut penyesuaian alur. Tombol tambah tugas dihapus, pencarian dan filter diperluas ke seluruh data, dan halaman Tugas Saya ditambahkan. Ke depan, disiplin dalam menambahkan pengujian dan dokumentasi perlu ditingkatkan agar perubahan fitur tidak menimbulkan regresi.

### 6.4 Potensi Pengembangan

1. Mengimplementasikan `ApiTaskRepository` dengan endpoint nyata dan penanganan autentikasi.
2. Menambahkan autentikasi pengguna, profil nyata, dan pembatasan akses berdasarkan peran agen.
3. Mengembangkan chat sungguhan dengan backend, riwayat pesan, notifikasi, dan status baca.
4. Mengganti peta statis dengan peta interaktif dan geolokasi *real-time*.
5. Menambahkan penyimpanan lokal permanen untuk favorit dan tugas yang diambil.
6. Menambahkan notifikasi push, pembayaran, riwayat tugas, ulasan, dan verifikasi pengguna yang lebih lengkap.
7. Melengkapi fitur bagikan, pengaturan, bantuan, dan halaman seluruh kategori.
8. Menambahkan pengujian widget, integrasi, dan *golden test* untuk menjaga kualitas antarmuka.

---

**[SCREENSHOT: `docs/screenshots/bukti_pengujian.png` — Bukti menjalankan `flutter analyze` dan `flutter test`]**
