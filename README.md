# 👑 King Akbar UI

> Modern, customizable UI library untuk Roblox — dibuat untuk scripting hub & tool.

![Version](https://img.shields.io/badge/Version-2.0-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Language](https://img.shields.io/badge/Language-Lua-red)

## ✨ Fitur

- 🎨 Fully customizable — tema, font, ukuran, background, icon
- 🪟 Window auto-center di PC & mobile, draggable, touch support
- 📦 12 komponen — Button, Toggle, Slider, Input, Dropdown, Keybind, ColorPicker, Panel, Paragraph, Seperator, Line, Dialog
- 🔔 Notifikasi + progress bar + queue
- 🎨 27 preset tema + generate tema dari 1 warna + ganti tema runtime
- 💾 Save config built-in (`EnableSave` + `SaveKey`) atau lewat wrapper
- 🎹 Keybind & hotkey toggle UI, 💬 tooltip, 🔊 sound effects (opsional)
- 🎯 Anti-AFK otomatis (bisa dimatikan)

## 🚀 Instalasi

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
```

Atau clone repo:

```bash
git clone https://github.com/Akbar025zzz/kingAkbarUi-Speedhub.git
```

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

Library:EnableSave("MyHub.json")

local Window = Library:CreateWindow({
  Title       = "My Hub",
  Description = "v2.0",
  ToggleKey   = Enum.KeyCode.RightShift,
  Search      = true,
  Profile     = true,
})

local Tab     = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local Section = Tab:AddSection("Farming", true)

Section:AddToggle({
  Title    = "Auto Farm",
  Content  = "Aktifkan auto farming",
  SaveKey  = "auto_farm",
  Default  = false,
  Callback = function(state) print("Auto Farm:", state) end,
})

Library:SetNotification({
  Title = "Success", Description = "Loaded",
  Content = "Tekan [RightShift] untuk toggle UI",
})
```

## 📚 Dokumentasi

| Dokumen | Isi |
| --- | --- |
| [docs/api.md](docs/api.md) | API Reference: Library, Window, komponen, notifikasi, dialog |
| [docs/themes.md](docs/themes.md) | Preset tema, runtime switcher, generate tema, kustomisasi |
| [docs/wrapper.md](docs/wrapper.md) | Wrapper FuncsV3 + auto-save |
| [docs/migration.md](docs/migration.md) | Migrasi dari v1.4 ke v2.0 |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat perubahan |
| [examples/](examples) | `basic`, `with-save`, `customize`, `advanced` |

## 📦 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua          ← library utama (v2.0)
├── wrapper.lua       ← shortcut + auto-save
├── themes.lua        ← 27 preset tema
├── docs/
│   ├── api.md
│   ├── themes.md
│   ├── wrapper.md
│   └── migration.md
├── examples/
│   ├── basic.lua
│   ├── with-save.lua
│   ├── customize.lua
│   └── advanced.lua
├── CHANGELOG.md
├── README.md
└── LICENSE
```

## 💡 Tips

- Anti-AFK bisa dimatikan: `Library:GetConfig().Behavior.AntiAFK = false`
- Menjalankan script dua kali aman — UI lama otomatis dibersihkan
- Background image lebih bagus resolusi 1280x720 ke atas
- Icon floating button sebaiknya PNG transparan 128x128
- `SaveKey` di library vs wrapper — pilih satu gaya per script, jangan campur

## 🐛 Bug Report

Buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues) dengan: nama executor & versi, langkah reproduksi, error message / screenshot.

## 📜 License

MIT — bebas dipakai, diubah, dan dibagikan. Lihat [LICENSE](LICENSE).

Made with ❤️ by **King Akbar**
