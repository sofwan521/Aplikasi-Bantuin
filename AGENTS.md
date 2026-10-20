# AGENTS.md

## Ringkasan Tugas
Aplikasi "Bantuin" adalah marketplace tugas harian berbasis bantuan sesama. Pengguna melihat tugas di sekitarnya (jalan-jalan anjing, pindah rumah, bantu pekerjaan rumah, dll), lalu menekan "Ambil" untuk mengerjakan dan mendapat imbalan dalam Rupiah. Pengguna hanya berperan sebagai agen yang mencari dan mengambil tugas; aplikasi tidak menyediakan fitur membuat atau memasang tugas. Tugas UTS Mobile Programming, UI mengikuti design/ui_reference.png.

## Ketentuan Wajib dari Soal UTS
- Stack: Flutter dengan paket `google_fonts` dan font **Montserrat**.
- Aksen warna utama: **#FFCC00**.
- Model data: `category.dart` dan `task.dart` di dalam `lib/models/`.
- Service repository: abstract class `TaskRepository` beserta implementasi `LocalJsonRepository` di `lib/services/task_repository.dart`.
- Halaman wajib di `lib/pages/`: `main_shell.dart`, `home_page.dart`, `category_page.dart`, `detail_page.dart`, `map_page.dart`, `favorites_page.dart`, `chat_page.dart`, `profile_page.dart`, `my_tasks_page.dart`.
- Minimal 3 halaman terhubung navigasi (Navigator.push + BottomNavigationBar).
- Data dummy dari JSON lokal, struktur siap diganti API.
- Widget layout beragam (Row, Column, Stack, ListView, Card, dll).
- Responsive, tanpa unsur SARA.
- Semua teks UI dalam Bahasa Indonesia, mata uang Rupiah.
- Kode rapi dengan komentar bahasa Indonesia, README.md lengkap.
- Widget reusable di `lib/widgets/`.
- Tema dan warna di `lib/theme/`.
- Definisi rute navigasi di `lib/routes/`.
- Data JSON wajib ada di `assets/data/categories.json` dan `assets/data/tasks.json`.
- Gambar aset di `assets/images/`.
- Referensi desain: Aleksandr Volodkovich, "Find Assistants - Mobile App" (Dribbble, https://dribbble.com/shots/19553505-Find-Assistants-Mobile-App) dan berkas "Task App" (Figma Community, https://www.figma.com/community/file/1158702322980754042/task-app); dimodifikasi: teks Bahasa Indonesia, aksen kuning, dan mata uang Rupiah.
- Path referensi desain: `design/ui_reference.png` dan `docs/soal_uts.pdf`.

## Stack
- Flutter
- `google_fonts`
- Font: Montserrat
- Aset: JSON (`assets/data/`), gambar (`assets/images/`)

## Konvensi Kode
- Penamaan file dan folder menggunakan `snake_case`.
- Penamaan class menggunakan `PascalCase`.
- Penamaan variabel dan fungsi menggunakan `camelCase`.
- Widget stateless dipisah ke file sendiri jika cukup kompleks.
- Tidak menaruh logika bisnis langsung di widget UI; gunakan repository/service.
- Warna aksen #FFCC00 didefinisikan sekali di `lib/theme/` dan digunakan secara konsisten.
- Semua halaman terdaftar di `lib/routes/` untuk navigasi terpusat.

## Struktur Folder
```
lib/
  main.dart
  models/
    category.dart
    task.dart
  services/
    task_repository.dart   (abstract class + LocalJsonRepository)
  pages/
    main_shell.dart
    home_page.dart
    category_page.dart
    detail_page.dart
    map_page.dart
    favorites_page.dart
    chat_page.dart
    profile_page.dart
    my_tasks_page.dart
  widgets/
  theme/
  routes/
assets/
  data/
    categories.json
    tasks.json
  images/
design/
  ui_reference.png
docs/
  soal_uts.pdf
```
