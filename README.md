# Mactive 📋✨

**Mactive** adalah aplikasi to-do list native yang ringan, cepat, dan minimalis khusus untuk macOS. Aplikasi ini bersemayam langsung di **Menu Bar atas MacBook** (sejajar dengan Wi-Fi, baterai, dan jam), sehingga kamu tidak perlu membuka jendela aplikasi besar atau memenuhi Dock.

---

## 🌟 Fitur Utama

- **Menu Bar Native**: Ikon checklist di menu bar atas dengan badge hitungan tugas yang belum selesai.
- **Tanpa Memenuhi Dock (`LSUIElement`)**: Tidak muncul di Dock atau Command+Tab, hanya muncul saat kamu membutuhkannya di Menu Bar.
- **Akses Instan & Auto-Focus**: Klik ikon di menu bar, jendela popover langsung terbuka dan kursor siap mengetik tugas baru.
- **Input Cepat**: Ketik tugas dan tekan **Enter / Return** untuk langsung menambahkan.
- **Tingkat Prioritas**: Pilihan prioritas tugas (**Biasa** atau **Penting**).
- **Filter Tugas**: Tab filter **Semua**, **Aktif**, dan **Selesai** lengkap dengan indikator progres.
- **Efek Suara Selesai**: Bunyi feedback halus khas Mac saat tugas ditandai selesai.
- **Penyimpanan Otomatis (Persistent)**: Semua data otomatis tersimpan di `~/Library/Application Support/Mactive/tasks.json`.
- **Jalankan saat Startup (Launch at Login)**: Opsi otomatis menyala saat MacBook dinyalakan (dapat diaktifkan langsung dari menu titik tiga).
- **Klik Kanan Cepat**: Klik kanan pada ikon di menu bar untuk melihat ringkasan cepat dan opsi keluar.

---

## 🚀 Cara Menjalankan & Memasang

Aplikasi sudah selesai dikompilasi dan dipasang di folder `/Applications/Mactive.app`.

### Jika ingin menginstal ulang atau mem-build ulang kapan saja:

```bash
# Di dalam folder project:
./install.sh
```

Atau cukup build saja tanpa memindahkan ke Applications:
```bash
./build_app.sh
open build/Mactive.app
```

---

## ⌨️ Pintasan & Navigasi

- **Klik Ikon Menu Bar**: Buka/tutup jendela Mactive.
- **Klik di Luar Jendela**: Jendela otomatis tertutup (transient popover).
- **Enter**: Simpan tugas baru.
- **Esc**: Menghapus teks yang sedang diketik atau menutup jendela.
- **Ikon Titik Tiga (`...`)**:
  - Ubah pengaturan badge angka di menu bar
  - Aktifkan/nonaktifkan suara
  - Atur jalankan saat startup Mac
  - Bersihkan tugas yang sudah selesai
  - Keluar dari aplikasi (Quit)
