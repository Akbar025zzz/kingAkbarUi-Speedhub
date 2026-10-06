# 👑 King Akbar UI

> UI library Roblox (Luau) bergaya dark modern, untuk script hub dan tool. Mobile friendly.

**Versi:** 1.6 · **Lisensi:** MIT

## ✨ Fitur

- Window auto-fit layar (PC & HP), draggable, tombol floating, hotkey tampil/sembunyi
- Hierarki: Window → Tab → Section / TabBox → Komponen
- Komponen: Button, Toggle, Slider, Input, Dropdown (multi), Keybind, ColorPicker, Panel, Paragraph, Seperator, Line
- **TabBox** (baru v1.6): satu kotak dengan beberapa halaman, bisa swipe di HP
- Notifikasi, badge di topbar, search tab, profil user
- Tema lewat `SetTheme`, font lewat `SetFont`, background image, Anti-AFK (bisa dimatikan)
- Aman dijalankan ulang: UI lama otomatis dibersihkan

## 🚀 Instalasi

```lua
local Lib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
```

## ⚡ Quick Start

```lua
local Win = Lib:CreateWindow({ "King Akbar", "v1.6", 100, UDim2.fromOffset(420, 280) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("Farm", true)

Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print(v) end })
Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print(v) end })

Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
```

Semua komponen menerima format **array** (`{ "Judul", "Isi", ... }`) atau **named** (`{ Title = "Judul", ... }`).

## 📚 Dokumentasi

| Dokumen | Isi |
| --- | --- |
| [docs/api.md](docs/api.md) | Semua method: Library, Window, Tab, komponen, notifikasi |
| [docs/tabbox.md](docs/tabbox.md) | TabBox dan Page |
| [docs/themes.md](docs/themes.md) | Warna, font, background, konfigurasi |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat perubahan |
| [examples/](examples) | Contoh pemakaian |

## 📦 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua          ← library utama (v1.6)
├── wrapper.lua       ← wrapper + auto-save
├── themes.lua        ← preset tema
├── docs/
│   ├── api.md
│   ├── tabbox.md
│   └── themes.md
├── examples/
│   ├── basic.lua
│   └── tabbox.lua
├── CHANGELOG.md
├── README.md
└── LICENSE
```

## 🐛 Bug Report

Buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues) dengan: nama executor & versi, langkah reproduksi, error message / screenshot.

## 📜 Lisensi

MIT. Made with ❤️ by **King Akbar**
