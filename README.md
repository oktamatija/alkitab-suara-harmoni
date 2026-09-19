# 📖 Alkitab Harmoni Suara

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Flutter](https://img.shields.io/badge/Flutter-v3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-green.svg)](https://github.com/oktamatija/alkitab-suara-harmoni)
[![Release](https://img.shields.io/badge/Release-v1.0.0-orange.svg)](https://github.com/oktamatija/alkitab-suara-harmoni/releases)

Aplikasi Alkitab Bahasa Indonesia modern dan imersif yang dirancang untuk pengalaman membaca dan mendengarkan Firman yang mendalam. Menggabungkan **narasi audio ayat per ayat** dengan **harmoni musik pengiring multi-genre** dan **sinkronisasi sorotan teks real-time**.

---

## ✨ Fitur Utama

- 🎵 **Harmoni Musik Pengiring Multi-Genre**:
  - **Piano Khidmat** (*Peaceful & Worship*)
  - **Akustik Meditasi** (*Warm & Reflective*)
  - **Ambient Teduh** (*Celestial Pads*)
  - **Lofi Santai** (*Mellow Chill*)
  - **Suara Alam Damai** (*Gentle Rain & Calm*)
  - **Orkestra Khidmat** (*Sacred Strings*)
  - **Tanpa Musik** (*Mute*)
- 🗣️ **Narasi Suara Natural & Pilihan Suara**:
  - Pilihan narator Pria dan Wanita dengan intonasi jelas dan pengucapan sakral.
- 🎯 **Sinkronisasi Sorotan Teks Real-Time**:
  - Auto-scroll halus menjaga ayat yang sedang dibacakan tepat di posisi tengah layar.
- 🔢 **Pemilihan Pasal & Rentang Ayat Dinamis**:
  - Pilihan rentang ayat (misal ayat 1–10, 1–15, dll.) dengan fitur **Auto-Stop** otomatis begitu ayat akhir selesai dibacakan.
- 🎚️ **Mixer Audio Canggih**:
  - Kontrol volume narasi dan musik latar terpisah, *Auto-Ducking* cerdas saat narasi berbunyi, kecepatan bacaan (0.75x – 1.5x), dan jeda refleksi antar ayat.
- 📱 **Multiplatform**:
  - Mendukung **Windows Desktop** (x64) dan **Android**.
- 📴 **Offline-First**:
  - Teks lengkap 66 kitab Perjanjian Lama & Baru tersimpan secara lokal dan dapat diakses tanpa koneksi internet.

---

## 📥 Unduh Aplikasi (Rilis Siap Pakai)

Berkas installer dapat diunduh langsung melalui menu [Releases](https://github.com/oktamatija/alkitab-suara-harmoni/releases) atau di folder `installer/`:

| Platform | Format | Keterangan |
| :--- | :--- | :--- |
| **Windows** | `Setup (.exe)` | Installer Inno Setup dengan pintasan Desktop & Menu Mulai |
| **Windows** | `Portable (.zip)` | Langsung ekstrak dan jalankan tanpa perlu instalasi |
| **Android** | `APK (.apk)` | Paket instalasi Android Release |

---

## 🛠️ Pengembangan & Menjalankan dari Source

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.5 atau lebih baru)
- Android SDK (untuk build Android)
- Visual Studio dengan C++ Desktop Development (untuk build Windows)
- Python 3 (untuk skrip data & sintesis audio)

### Langkah Menjalankan

```bash
# 1. Clone repositori
git clone https://github.com/oktamatija/alkitab-suara-harmoni.git
cd alkitab-suara-harmoni

# 2. Ambil dependensi Flutter
flutter pub get

# 3. Jalankan aplikasi di Windows Desktop
flutter run -d windows

# Atau jalankan di perangkat / emulator Android
flutter run -d android
```

### Membangun Paket Rilis

```bash
# Build Windows Release
flutter build windows --release

# Build Android APK Release
flutter build apk --release
```

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah lisensi **GNU General Public License v3.0 (GPLv3)**.  
Lihat berkas [LICENSE](LICENSE) untuk ketentuan dan rincian selengkapnya.
