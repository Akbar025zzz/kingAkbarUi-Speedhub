## 🧩 Template Hub (untuk dipakai orang lain)

Mau bikin hub sendiri tanpa mulai dari nol? Salin [`examples/hub_template.lua`](examples/hub_template.lua):

1. **Edit `HUB`** di bagian atas — nama, game, versi, tema, logo, link Discord.
2. **Isi fitur** di bagian `[4] FITUR` — cari komentar `TODO` dan ganti dengan logika script kamu.
3. Jalankan di executor.

Hasilnya: window dengan sidebar + search, footer profil, badge game/versi/executor, section yang bisa dibuka-tutup, tab **Settings** standar (tema, Anti-AFK, tutup UI), hotkey buka/tutup, dan semua komponen (toggle iOS, slider, dropdown, keybind, color picker).

> Template ini sengaja ditulis defensif: fitur yang belum ada di versi library tertentu (mis. badge atau ganti tema runtime) otomatis dilewati, bukan error.
