# DESIGN.md

Referensi desain: `design/ui_reference.png`

## Daftar Layar
1. **Beranda** — daftar tugas rekomendasi (kartu tugas), search bar dengan tombol filter, dan daftar kategori.
2. **Peta "Direkomendasikan Untukmu"** — peta STATIS (gambar `assets/images/map.png`), avatar pemosting diposisikan dengan `Stack`/`Positioned`, dan kartu info di bawah (nama + centang, rating, judul, jarak, tarif). Bukan peta interaktif dan tidak menggunakan Google Maps API.
3. **Detail Tugas** — header foto tinggi dengan sudut bawah rounded, tombol back dan share di atas foto, chip pemosting, judul + ikon hati, deskripsi, baris "Tarif Rp ..." dan lokasi + jarak, tombol chat (kotak putih) di kiri dan tombol "Ambil" kuning lebar di kanan.

## Palet Warna
| Warna | Hex | Keterangan |
|-------|-----|------------|
| Aksen Utama | #FFCC00 | Kuning utama, tombol "Ambil" dan tombol filter |
| Background Layar | #FAFAFA | Abu sangat terang atau putih |
| Surface Kartu | #FFFFFF | Putih untuk kartu dan kontainer |
| Teks Utama | #1A1A1A | Hitam tua untuk judul, label, dan nominal Rupiah |
| Teks Sekunder | #666666 | Abu-abu untuk keterangan |
| Verifikasi | #00C853 | Hijau untuk centang terverifikasi |
| Batas / Divider | #E0E0E0 | Abu-abu muda untuk pemisah |

## Tipografi
- Font: **Montserrat** (paket `google_fonts`)
- Heading / Judul layar: 20sp, bold
- Judul tugas / kartu: 16sp, semibold
- Teks deskripsi: 14sp, regular
- Caption / keterangan kecil: 12sp, regular
- Nominal Rupiah: 16sp, bold, warna teks utama gelap #1A1A1A (bukan kuning)

## Radius
- Radius kartu: 16 dp
- Radius sudut foto tugas / peta: 16 dp (sudut bawah rounded pada header detail)
- Radius tombol: 12 dp
- Radius search bar: 12 dp
- Radius tombol filter: 12 dp
- Radius avatar / chip: 20 dp (lingkaran penuh)
- Radius chip kategori: 8 dp

## Shadow
- Shadow kartu: `BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))`
- Shadow tombol utama: `BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))`

## Spacing
- Padding layar: 16 dp (kiri-kanan)
- Gap antar elemen: 8 dp / 12 dp / 16 dp
- Tinggi bottom nav: 70 dp
- Tinggi tombol utama: 50 dp

## Daftar Komponen Reusable
1. **Search bar** — input teks dengan ikon kaca pembesar, placeholder "Cari", radius 12 dp, border lembut.
2. **Tombol filter kuning** — kotak penuh kuning #FFCC00 radius 12 dp berisi ikon slider/tune, tanpa teks, diposisikan di sebelah kanan search bar.
3. **Kartu tugas (beranda)** — foto tugas dengan sudut rounded, label "Sampai dd.MM" di kiri atas foto, ikon hati di kanan atas foto, chip pemosting (avatar, nama, rating) di kiri bawah foto; di bawah foto ada judul tugas dan ikon chat. Tidak ada harga atau tombol aksi di kartu ini.
4. **Tile kategori** — item kategori dengan ikon, nama kategori, dan jumlah tugas, radius 12 dp.
5. **Bottom nav dengan tombol + di tengah** — navigasi bawah 5 item, tombol floating "+" diletakkan di tengah menonjol di atas nav.
6. **Chip avatar terverifikasi** — lingkaran avatar kecil dengan centang hijau di sudut kanan bawah dan nama pengguna.
