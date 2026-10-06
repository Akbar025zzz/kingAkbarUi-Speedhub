# 👑 King Akbar UI

UI library Roblox (Luau) bergaya dark modern untuk script hub dan tool. Nyaman dipakai di PC maupun HP.

**Versi:** 1.7 · **Lisensi:** MIT

## 📑 Daftar Isi

1. [Fitur](#1--fitur)
2. [Instalasi](#2--instalasi)
3. [Mulai Cepat (5 langkah)](#3--mulai-cepat-5-langkah)
4. [Memahami Susunan UI](#4--memahami-susunan-ui)
5. [Daftar Komponen](#5--daftar-komponen)
6. [Kotak Pengelompok](#6--kotak-pengelompok)
7. [Kustomisasi](#7--kustomisasi)
8. [Dokumentasi Lengkap & Struktur Repo](#8--dokumentasi-lengkap--struktur-repo)
9. [Bantuan & Lisensi](#9--bantuan--lisensi)

---

## 1. ✨ Fitur

- Window menyesuaikan ukuran layar, bisa digeser, punya tombol floating dan hotkey tampil/sembunyi
- 11 komponen siap pakai: Button, Toggle, Slider, Input, Dropdown, Keybind, ColorPicker, Panel, Paragraph, Seperator, Line
- Kotak pengelompok: Section, GroupBox, dan TabBox
- Notifikasi, badge di topbar, search tab, profil pemain
- Tema, font, dan background bisa diganti
- Aman dijalankan berulang kali: UI lama otomatis dibersihkan

---

## 2. 🚀 Instalasi

Tambahkan di awal script kamu:

```lua
local Lib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
```

`Lib` dipakai di semua contoh berikutnya.

---

## 3. ⚡ Mulai Cepat (5 langkah)

**Langkah 1: buat window**

```lua
local Win = Lib:CreateWindow({ "King Akbar", "v1.7", 100, UDim2.fromOffset(420, 280) })
```

Isinya berurutan: judul, sub-judul, lebar daftar tab, ukuran window.

**Langkah 2: buat tab**

```lua
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
```

Isinya: nama tab dan ikon.

**Langkah 3: buat section** (wadah untuk komponen)

```lua
local Sec = Tab:AddSection("Farm", true)   -- true = terbuka dari awal
```

**Langkah 4: isi dengan komponen**

```lua
Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print("Farm:", v) end })
Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print("Speed:", v) end })
```

**Langkah 5: tampilkan notifikasi**

```lua
Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
```

Selesai. Tekan **RightShift** untuk menampilkan/menyembunyikan window.

> 💡 Semua komponen menerima dua gaya penulisan, pilih yang kamu suka:
> - **Berurutan:** `{ "Auto Farm", "Farm otomatis", false, callback }`
> - **Bernama:** `{ Title = "Auto Farm", Content = "Farm otomatis", Default = false, Callback = callback }`

---

## 4. 🧭 Memahami Susunan UI

UI disusun bertingkat dari besar ke kecil:

```
Window                      ← jendela utama
 └─ Tab                     ← halaman di daftar kiri
     ├─ Section / GroupBox / TabBox   ← kotak pengelompok
     │    └─ Komponen       ← Toggle, Slider, Button, dst.
```

Cara membacanya: kamu membuat **Window**, di dalamnya **Tab**, di dalam Tab ada **kotak pengelompok**, dan komponen selalu dipasang ke kotak itu.

---

## 5. 🧩 Daftar Komponen

Semua dipasang ke Section, GroupBox, atau halaman TabBox. Contoh di bawah memakai `Sec`.

| Komponen | Contoh | Fungsi |
| --- | --- | --- |
| Paragraph | `Sec:AddParagraph({ "Judul", "Isi teks" })` | Teks informasi |
| Seperator | `Sec:AddSeperator("Judul")` | Pemisah berjudul |
| Line | `Sec:AddLine()` | Garis tipis |
| Button | `Sec:AddButton({ Title = "Klik", Callback = function() end })` | Tombol |
| Toggle | `Sec:AddToggle({ "Nama", "", false, function(v) end })` | Saklar on/off |
| Slider | `Sec:AddSlider({ "Nama", "", 1, 0, 100, 50, function(v) end })` | Angka dengan geseran. Urutan: judul, isi, kelipatan, min, maks, awal, callback |
| Input | `Sec:AddInput({ "Nama", "", "teks awal", function(t) end })` | Kolom teks |
| Dropdown | `Sec:AddDropdown({ "Mode", "", false, { "A", "B" }, { "A" }, function(v) end })` | Pilihan. Urutan: judul, isi, multi, daftar, terpilih, callback |
| Keybind | `Sec:AddKeybind({ "Hotkey", "", "F", function() end })` | Tombol keyboard yang bisa diganti pemain |
| ColorPicker | `Sec:AddColorPicker({ "Warna", "", Color3.fromRGB(255,0,0), function(c) end })` | Pemilih warna |
| Panel | `Sec:AddPanel({ "Judul", "Isi" })` | Panel lipat berisi tombol/toggle |

Semua komponen juga punya `SetTitle(text)`, `SetContent(text)`, `SetVisible(bool)`, dan `Destroy()`.
Detail lengkap tiap komponen ada di [docs/api.md](docs/api.md).

---

## 6. 📦 Kotak Pengelompok

Ada tiga jenis. Pilih sesuai kebutuhan:

| Kotak | Cocok untuk | Contoh |
| --- | --- | --- |
| **Section** | Kelompok biasa yang bisa dibuka/tutup | `Tab:AddSection("Farm", true)` |
| **GroupBox** | Kotak berjudul, opsional collapsible, opsional tinggi maksimum dengan scroll | `Tab:AddGroupBox({ Title = "Farm", Collapsible = true })` |
| **TabBox** | Satu kotak berisi beberapa halaman, bisa digeser di HP | `Tab:AddTabBox({ Tabs = { "Farm", "Combat" } })` |

**GroupBox**

```lua
local Box = Tab:AddGroupBox({ Title = "Farming", Collapsible = true })
Box:AddToggle({ "Auto Farm", "", false, function(v) end })
```

**TabBox**

```lua
local Box  = Tab:AddTabBox({ Tabs = { "Farm", "Combat" }, Default = "Farm" })
local Farm = Box:GetTab("Farm")
Farm:AddToggle({ "Auto Farm", "", false, function(v) end })
```

Keduanya punya `SetValue`, `GetValue`, `OnChanged(fn)`, `SetVisible`, dan `Destroy`.
Penjelasan lengkap: [docs/groupbox.md](docs/groupbox.md) dan [docs/tabbox.md](docs/tabbox.md).

---

## 7. 🎨 Kustomisasi

Lakukan **sebelum** `CreateWindow` supaya berlaku.

```lua
-- Warna
Lib:SetTheme({ Primary = Color3.fromRGB(0, 170, 255) })

-- Font
Lib:SetFont({ Bold = Enum.Font.GothamBold })

-- Pengaturan lain
local Cfg = Lib:GetConfig()
Cfg.Behavior.AntiAFK = false   -- matikan Anti-AFK
```

Daftar semua warna, background image, dan opsi lain: [docs/themes.md](docs/themes.md).

---

## 8. 📚 Dokumentasi Lengkap & Struktur Repo

**Dokumentasi**

| Dokumen | Isi |
| --- | --- |
| [docs/api.md](docs/api.md) | Semua method: Library, Window, Tab, komponen, notifikasi |
| [docs/groupbox.md](docs/groupbox.md) | GroupBox dan perbedaannya dengan Section |
| [docs/tabbox.md](docs/tabbox.md) | TabBox dan Page |
| [docs/themes.md](docs/themes.md) | Warna, font, background |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat perubahan |

**Contoh script:** [`examples/basic.lua`](examples/basic.lua), [`examples/groupbox.lua`](examples/groupbox.lua), [`examples/tabbox.lua`](examples/tabbox.lua)

**Struktur repo**

```
kingAkbarUi-Speedhub/
├── init.lua          ← library utama
├── wrapper.lua       ← wrapper + auto-save
├── themes.lua        ← preset tema
├── docs/             ← dokumentasi
├── examples/         ← contoh script
├── CHANGELOG.md
├── README.md
└── LICENSE
```

---

## 9. 🐛 Bantuan & Lisensi

**Menemukan bug?** Buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues) dan sertakan:
1. Nama executor dan versinya
2. Langkah untuk memunculkan bug
3. Pesan error atau screenshot

**Lisensi:** MIT, bebas dipakai, diubah, dan dibagikan.

Dibuat dengan ❤️ oleh **King Akbar**
