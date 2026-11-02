# 📝 Aplikasi To-Do List Berbasis Cloud Firestore
> **Praktikum Pemrograman Mobile - Modul 3: Basis Data Cloud dengan Firestore**  
> **Nama Pengembang:** Adam Bimantara  
> **NIM:** 2300016021  
> **Program Studi:** Informatika, Universitas Ahmad Dahlan  

---

## 🌟 Tentang Proyek

Aplikasi **To-Do List Praktikum 3** adalah aplikasi manajemen tugas (*task management*) modern yang dibangun menggunakan **Flutter** dan terintegrasi penuh dengan **Firebase Cloud Firestore** serta **Firebase Authentication**.

Aplikasi ini mengimplementasikan isolasi data multi-pengguna dengan struktur subkoleksi `users/{uid}/tasks`, memastikan privasi dan keamanan data setiap pengguna terjaga secara ketat melalui **Firestore Security Rules**.

---

## ✨ Fitur Unggulan

1. **Autentikasi Pengguna (Firebase Auth)**:
   * Pendaftaran akun baru (*Sign Up*) dengan nama lengkap, email mahasiswa, dan kata sandi.
   * Masuk akun (*Sign In*) dengan validasi kredensial dan pesan kesalahan berbahasa Indonesia yang informatif.
   * Keluar akun (*Sign Out*) dengan konfirmasi dialog aman.
   * Pengalihan rute otomatis secara *real-time* menggunakan `StreamBuilder<User?>`.

2. **Manajemen Tugas Lengkap (CRUD)**:
   * **Create**: Menambah tugas baru lengkap dengan judul, deskripsi opsional, kategori (*Kuliah*, *Praktikum*, *Pribadi*, *Organisasi*), prioritas (*Tinggi*, *Sedang*, *Rendah*), dan tenggat waktu (*Due Date*).
   * **Read**: Menampilkan daftar tugas secara *real-time* menggunakan `StreamBuilder<List<Task>>` dari Firestore.
   * **Update**: Mengedit data tugas yang telah dibuat serta menandai status penyelesaian (*toggle isDone*) secara langsung melalui *checkbox* interaktif.
   * **Delete**: Menghapus tugas dengan konfirmasi dialog pencegah penghapusan tidak sengaja.

3. **Pencarian & Penyaringan Cerdas**:
   * Pencarian judul tugas secara langsung (*live search*).
   * Filter status tugas: **Semua**, **Aktif**, dan **Selesai**.
   * Kartu ringkasan kemajuan (*Progress Summary Card*) dengan persentase penyelesaian dinamis.

4. **Desain UI/UX Kelas Dunia**:
   * Palet warna profesional: *Deep Midnight Navy* (`#0A192F`), *Electric Blue* (`#2563EB`), dan *Soft Background* (`#F8FAFD`).
   * Tipografi modern menggunakan **Plus Jakarta Sans** via Google Fonts.
   * *Card elevation*, gradien halus, *chip selector*, dan transisi mikro yang memanjakan mata.

5. **Keamanan Data Maksimal (Firestore Security Rules)**:
   * Struktur data: `users/{uid}/tasks/{taskId}`.
   * Setiap pengguna hanya dapat membaca, membuat, memperbarui, dan menghapus tugas miliknya sendiri (`request.auth.uid == uid`).

---

## 🏗️ Struktur Arsitektur Proyek

```text
lib/
├── firebase_options.dart      # Konfigurasi otomatis dari FlutterFire CLI
├── main.dart                  # Titik masuk aplikasi, inisialisasi Firebase & auth routing
├── models/
│   └── task.dart              # Model data Task dengan parser Firestore Timestamp
├── pages/
│   ├── add_task_page.dart     # Halaman formulir tambah tugas baru
│   ├── edit_task_page.dart    # Halaman formulir ubah data tugas
│   ├── home_page.dart         # Halaman utama (daftar tugas, ringkasan, filter & search)
│   ├── login_page.dart        # Halaman autentikasi masuk akun
│   └── register_page.dart     # Halaman pendaftaran akun mahasiswa baru
├── services/
│   ├── auth_service.dart      # Layanan Firebase Authentication (singleton)
│   └── firestore_service.dart # Layanan Cloud Firestore CRUD & Stream
└── theme/
    └── app_theme.dart         # Sistem desain, warna, gradien, dan tema komponen
```

---

## 🔒 Aturan Keamanan Firestore (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🚀 Cara Menjalankan Aplikasi Secara Lokal

### Prasyarat
* Flutter SDK (versi $\ge$ 3.0.0)
* Dart SDK (versi $\ge$ 3.0.0)
* Akun Firebase dengan proyek terkonfigurasi

### Langkah-langkah

1. **Clone repositori ini**:
   ```bash
   git clone https://github.com/USERNAME/todo_firestore.git
   cd todo_firestore
   ```

2. **Unduh dependensi proyek**:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase (opsional jika mengkloning)**:
   ```bash
   flutterfire configure --project=todo-firestore-praktikum3
   ```

4. **Jalankan aplikasi**:
   * Pada browser Chrome:
     ```bash
     flutter run -d chrome
     ```
   * Pada emulator / perangkat Android fisik:
     ```bash
     flutter run -d android
     ```

---

## 👥 Pengujian Isolasi Data Pengguna
Aplikasi ini telah diuji secara nyata dengan 2 akun berbeda:
1. **Akun 1**: `adam1@student.uad.ac.id` (UID: `3yvOdU1iY6higztuyaDH0UcY5Ox2`)
2. **Akun 2**: `adam2@student.uad.ac.id` (UID: `BgfOTSPMTlc9Xp1J8ewb1TTRok42`)

Hasil pengujian membuktikan bahwa tugas yang dibuat oleh Akun 1 sama sekali tidak terlihat oleh Akun 2, menegaskan keberhasilan penerapan aturan isolasi data subkoleksi Firestore.
