# Panduan Lengkap Publikasi ke Google Play Console

Dokumen ini berisi panduan langkah demi langkah untuk mengunggah dan merilis **Alkitab Harmoni Suara** ke Google Play Store melalui Google Play Console.

---

## Berkas yang Sudah Disiapkan untuk Anda

Semua berkas yang dibutuhkan Google Play Store telah disiapkan di folder **`D:\App\Alkitab\installer\`**:

1. **`Alkitab_Harmoni_Suara.aab`** (Android App Bundle resmi, bertanda tangan rilis dengan upload keystore).
2. **`store_assets/app_icon_512.png`** (Ikon Aplikasi 512x512 PNG berkualitas tinggi dengan logo Salib Emas).
3. **`store_assets/feature_graphic_1024x500.png`** (Gambar Fitur 1024x500 PNG untuk banner utama Google Play).
4. **`play_store_metadata.txt`** (Judul, deskripsi singkat, dan deskripsi lengkap siap salin-tempel).
5. **Kebijakan Privasi (Privacy Policy)**:  
   Tersedia langsung di URL publik:  
   `https://github.com/oktamatija/alkitab-suara-harmoni/blob/main/PRIVACY_POLICY.md`

---

## Langkah 1: Buka Google Play Console & Buat Aplikasi

1. Buka [Google Play Console](https://play.google.com/console) dan masuk menggunakan akun Google Developer Anda.
2. Di halaman beranda, klik tombol **Buat Aplikasi** (*Create App*).
3. Isi rincian dasar aplikasi:
   - **Nama Aplikasi**: `Alkitab Harmoni Suara`
   - **Bahasa default**: `Indonesia (id)`
   - **Jenis aplikasi**: `Aplikasi` (*App*)
   - **Gratis atau Berbayar**: `Gratis` (*Free*)
   - Centang deklarasi persetujuan hukum (Undang-undang ekspor AS & Pedoman konten pengembang).
4. Klik tombol **Buat Aplikasi** (*Create app*).

---

## Langkah 2: Lengkapi Halaman Listing Toko Utama (*Main Store Listing*)

Masuk ke menu **Pertumbuhan** (*Growth*) $\rightarrow$ **Listing toko utama** (*Main store listing*):

1. **Rincian Aplikasi**:
   - **Nama aplikasi**: `Alkitab Harmoni Suara`
   - **Deskripsi singkat**: Salin dari berkas `play_store_metadata.txt` (*Maksimal 80 karakter*).
   - **Deskripsi lengkap**: Salin teks deskripsi lengkap dari `play_store_metadata.txt`.
2. **Grafis Toko**:
   - **Ikon aplikasi**: Unggah `D:\App\Alkitab\installer\store_assets\app_icon_512.png` (512x512).
   - **Gambar fitur** (*Feature graphic*): Unggah `D:\App\Alkitab\installer\store_assets\feature_graphic_1024x500.png` (1024x500).
   - **Tangkapan Layar Ponsel** (*Phone screenshots*): Ambil 2–4 tangkapan layar dari aplikasi di ponsel Anda atau emulator dan unggah di sini.
3. Klik **Simpan** (*Save*).

---

## Langkah 3: Siapkan Konten Aplikasi (*App Content*)

Buka menu **Kebijakan & Program** (*Policy and programs*) $\rightarrow$ **Konten aplikasi** (*App content*). Lengkapi kuesioner berikut:

1. **Kebijakan Privasi** (*Privacy Policy*):
   - Masukkan URL: `https://github.com/oktamatija/alkitab-suara-harmoni/blob/main/PRIVACY_POLICY.md`
2. **Akses Aplikasi** (*App Access*):
   - Pilih: *Semua fungsionalitas tersedia tanpa batasan khusus* (karena tidak ada login/password).
3. **Iklan** (*Ads*):
   - Pilih: *Tidak, aplikasi saya tidak berisi iklan*.
4. **Rating Konten** (*Content Rating*):
   - Masukkan alamat email Anda (`oktamatija@gmail.com`).
   - Pilih kategori: *Utilitas, Produktivitas, Komunikasi, atau Lainnya* (*Reference / Utility*).
   - Jawab kuesioner (Semua pertanyaan mengenai kekerasan, konten seksual, judi, atau bahasa kasar dijawab **Tidak**).
   - Klik Simpan dan Kirim untuk mendapatkan rating **Semua Umur / PEGI 3**.
5. **Target Audiens** (*Target Audience*):
   - Pilih rentang usia: *13 ke atas* atau *Semua kelompok umur*.
6. **Keamanan Data** (*Data Safety*):
   - Jawab: *Aplikasi tidak mengumpulkan atau membagikan data pengguna apa pun*.

---

## Langkah 4: Unggah Android App Bundle (.aab) & Luncurkan Rilis

1. Buka menu **Rilis** (*Release*) $\rightarrow$ **Produksi** (*Production*) atau **Uji Tertutup** (*Closed Testing*).
2. Klik **Buat rilis baru** (*Create new release*).
3. Pada bagian **Paket aplikasi** (*App bundles*), klik tombol **Upload** lalu pilih berkas:
   `D:\App\Alkitab\installer\Alkitab_Harmoni_Suara.aab`
4. Tunggu proses verifikasi selesai. Google Play akan secara otomatis mendeteksi:
   - Package Name: `com.alkitabaudio.alkitab_suara_harmoni`
   - Target SDK: Android 14/15
   - Keystore: Telah ditandatangani secara sah (*Signed release*).
5. Pada **Nama rilis** (*Release name*), masukkan: `1.0.0`.
6. Pada **Catatan rilis** (*Release notes*), salin teks rilis dari `play_store_metadata.txt`.
7. Klik **Berikutnya** (*Next*) $\rightarrow$ **Simpan** $\rightarrow$ **Kirim untuk ditinjau** (*Send for review*).

---

## Langkah 5: Peninjauan Google (*Google Review*)

- Google akan meninjau aplikasi Anda (biasanya memakan waktu 1 hingga 3 hari kerja).
- Setelah disetujui, aplikasi akan berstatus **Aktif** dan dapat dicari serta diunduh oleh jutaan pengguna di seluruh dunia melalui aplikasi Google Play Store!
