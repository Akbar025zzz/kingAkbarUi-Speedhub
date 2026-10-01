# 👑 King Akbar UI

> Modern, customizable UI library untuk Roblox — dibuat untuk scripting hub & tool.

![Lua](https://img.shields.io/badge/Lua-5.1-blue)
![Roblox](https://img.shields.io/badge/Roblox-Exploit-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/version-1.2-blueviolet)

---

## ✨ Fitur

- 🎨 **Fully customizable** — ganti warna, font, ukuran, background, icon tanpa edit source
- 🖼️ **Background image support**
- 🪟 **Window auto-center** di semua device (PC & mobile)
- 📦 **Komponen lengkap** — Button, Toggle, Slider, Input, Dropdown (multi + search), Panel
- 🔔 **Notification system**
- 🖱️ **Draggable** window & floating button
- 📱 **Touch support** (mobile-friendly)
- 🎯 **Anti-AFK** otomatis
- 🎨 **10+ preset tema** siap pakai

---

## 🚀 Instalasi

### Cara 1 — Pakai `loadstring` (recommended)

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
```

### Cara 2 — Clone repo

```bash
git clone https://github.com/Akbar025zzz/kingAkbarUi-Speedhub.git
```

---

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

-- Buat Window
local Window = Library:CreateWindow({
  Title = "My Hub",
  Description = "v1.0",
})

-- Buat Tab
local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })

-- Buat Section
local Section = Tab:AddSection("Farming", true)

-- Tambah Toggle
Section:AddToggle({
  Title    = "Auto Farm",
  Content  = "Aktifkan auto farming",
  Default  = false,
  Callback = function(state)
    print("Auto Farm:", state)
  end,
})

-- Tambah Button
Section:AddButton({
  Title    = "Reset Character",
  Content  = "Klik untuk reset",
  Callback = function()
    Library:SetNotification({
      Title       = "Success",
      Description = "•",
      Content     = "Character di-reset",
    })
  end,
})
```

---

## 🎨 Customization

### Ganti Tema

```lua
Library:SetTheme({
  Primary    = Color3.fromRGB(0, 170, 255),
  Background = Color3.fromRGB(20, 20, 25),
  Secondary  = Color3.fromRGB(35, 35, 45),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(150, 150, 150),
  Stroke     = Color3.fromRGB(60, 60, 70),
})
```

### Pakai Preset Tema

```lua
local Themes = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua"
))()

Library:SetTheme(Themes.Neon)
-- Tersedia: Dark, Neon, Cyberpunk, BloodRed, Gold,
--           Purple, Ocean, Light, Matrix, Sunset
```

### Ganti Font

```lua
Library:SetFont({
  Bold    = Enum.Font.FredokaOne,
  Regular = Enum.Font.Gotham,
})
```

### Ganti Background Image

```lua
local Cfg = Library:GetConfig()
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3
```

### Ganti Icon Floating Button

```lua
local Cfg = Library:GetConfig()
Cfg.Assets.FloatingButton = "rbxassetid://91115084979317"
```

### Ganti Ukuran Window

```lua
local Window = Library:CreateWindow({
  Title    = "My Hub",
  TabWidth = 110,
  SizeUi   = UDim2.fromOffset(500, 320),
})
```

---

## 📖 API Reference

### 🔹 `Library:CreateWindow(config)`

| Field | Type | Default | Deskripsi |
|---|---|---|---|
| `Title` | string | `""` | Judul window |
| `Description` | string | `""` | Sub-judul |
| `TabWidth` | number | `100` | Lebar panel tab |
| `SizeUi` | UDim2 | `420x280` | Ukuran window |

### 🔹 `Window:CreateTab({ Name, Icon })`

| Param | Type | Deskripsi |
|---|---|---|
| `Name` | string | Nama tab |
| `Icon` | string | `rbxassetid://...` |

### 🔹 `Tab:AddSection(Title, OpenByDefault)`

### 🔹 Item Components

| Method | Field |
|---|---|
| `AddButton` | `Title, Content, Icon, Callback` |
| `AddToggle` | `Title, Content, Default, Callback(state)` |
| `AddSlider` | `Title, Content, Increment, Min, Max, Default, Callback(value)` |
| `AddInput` | `Title, Content, Default, Callback(text)` |
| `AddDropdown` | `Title, Content, Multi, Options, Default, Callback(value)` |
| `AddPanel` | `Title, Content` → sub: `AddButton`, `AddToggle` |
| `AddParagraph` | `Title, Content` |
| `AddSeperator` | `Title` |
| `AddLine` | – |

### 🔹 `Library:SetNotification(config)`

| Field | Type | Default |
|---|---|---|
| `Title` | string | `""` |
| `Description` | string | `""` |
| `Content` | string | `""` |
| `Time` | number | `0.5` |
| `Delay` | number | `5` |

---

## 🔥 Wrapper (Auto-Save)

Ada `wrapper.lua` yang bikin pemakaian lebih simpel + auto-save config.

```lua
local FuncsV3 = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua"
))()

getgenv().MyConfig = getgenv().MyConfig or {}
FuncsV3:SetTable(getgenv().MyConfig)

FuncsV3:Toggle(Section, "Auto Farm", "Deskripsi", "Save", function(v)
  print(v)
end)
```

**Magic value `"Save"`** → otomatis load dari config & auto-save saat berubah.

---

## 📁 Contoh Lengkap

Lihat folder [`examples/`](examples/) untuk referensi:

- `basic.lua` — paling simpel
- `with-save.lua` — pakai wrapper + save
- `customize.lua` — ganti tema, font, background
- `advanced.lua` — semua komponen

---

## 📦 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua              ← library utama
├── wrapper.lua           ← shortcut + auto-save
├── themes.lua            ← 10+ preset tema
├── README.md
├── LICENSE
└── examples/
    ├── basic.lua
    ├── with-save.lua
    ├── customize.lua
    └── advanced.lua
```

---

## 💡 Tips

- **Ganti tema** bisa sebelum **atau** sesudah `CreateWindow` — tapi lebih baik sebelum
- **Background image** lebih bagus pakai resolusi **1280x720** ke atas
- **Icon floating button** sebaiknya PNG transparan ukuran **128x128**
- **Font custom** bisa pakai `rbxasset://fonts/...` atau asset ID sendiri
- **Anti-AFK** bisa dimatikan via `Library:GetConfig().Behavior.AntiAFK = false`

---

## 🐛 Bug Report

Buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues) baru.

---

## 📜 License

MIT — bebas dipakai, diubah, dan dibagikan. Lihat [LICENSE](LICENSE).

---

## 🙏 Credit

Made with ❤️ by **King Akbar**
