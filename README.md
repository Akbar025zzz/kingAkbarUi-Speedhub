# 👑 King Akbar UI

> Modern, customizable UI library untuk Roblox — dibuat untuk scripting hub & tool.

![Version](https://img.shields.io/badge/Version-2.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Language](https://img.shields.io/badge/Language-Lua-red)

---

## 🆕 What's New in v2.0

| Kategori | Perubahan |
|---|---|
| 🎹 **Keybind System** | Komponen keybind baru + hotkey toggle UI (default `RightShift`) |
| 🎨 **ColorPicker** | SV picker + hue bar + preset swatch |
| ⚠️ **Dialog System** | Confirm dialog untuk aksi destruktif |
| 💬 **Tooltip** | Semua komponen support tooltip |
| 🎭 **Theme Runtime** | Ganti tema **SETELAH** `CreateWindow` — real-time! |
| 💾 **Save Built-in** | `EnableSave()` + `SaveKey` — tanpa wrapper! |
| 📊 **Progress Bar** | Notifikasi punya progress bar countdown |
| 🔊 **Sound Effects** | Feedback audio (optional, default OFF) |
| 🎚️ **Slider Upgrade** | Fill bar + drag track + input manual |
| 📬 **Notif Queue** | Max 5 notif bersamaan, sisanya antri |
| 🐛 **Bug Fixes** | Toggle callback saat init, notif overflow, memory leak |

---

## ✨ Fitur

* 🎨 **Fully customizable** — tema, font, ukuran, background, icon
* 🖼️ **Background image support** + tint & transparency
* 🪟 **Window auto-center** di semua device (PC & mobile)
* 📦 **12 komponen** — Button, Toggle, Slider, Input, Dropdown (multi + search), Keybind, ColorPicker, Panel, Paragraph, Seperator, Line, Dialog
* 🔔 **Notification system** + progress bar + queue
* 🖱️ **Draggable** window & floating button
* 📱 **Touch support** (mobile-friendly)
* 🎯 **Anti-AFK** otomatis (bisa dimatikan, lazy-connect)
* 🎨 **27 preset tema** + generate tema dari 1 warna
* 🎹 **Keybind system** + UI toggle hotkey
* 💬 **Tooltip** di semua komponen
* 💾 **Config save/load** built-in ATAU via wrapper
* 🔊 **Sound effects** optional

---

## 🚀 Instalasi

### Cara 1 — `loadstring` (recommended)

```lua
local Library = loadstring(game:HttpGet(
  "[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua)"
))()
```

### Cara 2 — Clone repo

```bash
git clone [https://github.com/Akbar025zzz/kingAkbarUi-Speedhub.git](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub.git)
```

---

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet(
  "[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua)"
))()

-- Optional: aktifkan config save
Library:EnableSave("MyHub.json")

local Window = Library:CreateWindow({
  Title       = "My Hub",
  Description = "v2.0",
  ToggleKey   = Enum.KeyCode.RightShift,  -- hotkey show/hide UI
  Search      = true,   -- kolom search di daftar tab
  Profile     = true,   -- avatar + welcome text
})

local Tab     = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local Section = Tab:AddSection("Farming", true)

Section:AddToggle({
  Title    = "Auto Farm",
  Content  = "Aktifkan auto farming",
  Tooltip  = "Farming berjalan 24/7",
  SaveKey  = "auto_farm",        -- auto-save & load!
  Default  = false,
  Callback = function(state)
    print("Auto Farm:", state)
  end,
})

Section:AddKeybind({
  Title   = "Farm Hotkey",
  Default = Enum.KeyCode.E,
  SaveKey = "farm_hotkey",
  Callback = function(key)
    print("Hotkey:", key.Name)
  end,
})

Section:AddButton({
  Title    = "Reset Character",
  Content  = "Dengan konfirmasi",
  Callback = function()
    Library:Dialog({
      Title   = "Konfirmasi",
      Content = "Yakin reset character?",
      Buttons = {
        { "Ya", function()
          game.Players.LocalPlayer.Character:BreakJoints()
        end, true },
        { "Batal", function() end },
      },
    })
  end,
})

Library:SetNotification({
  Title = "Success", Description = "Loaded",
  Content = "Tekan [RightShift] untuk toggle UI",
})
```

---

## 🎨 Themes

### Pakai Preset (27 tema)

```lua
local Themes = loadstring(game:HttpGet(
  "[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua)"
))()

Themes.Apply(Library, "Neon")   -- ✅ recommended: validasi + auto-bg
-- atau cara lama: Library:SetTheme(Themes.Neon)
```

**Tersedia:** Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset, Violet, Emerald, Forest, Sakura, Rose, Cherry, Midnight, Amoled, Monochrome, Coffee, Arctic, Steel, Discord, Nord, Dracula, Catppuccin, TokyoNight

### 🔥 Runtime Theme Switcher (BARU!)

```lua
-- Ganti tema SETELAH CreateWindow — langsung berubah!
Section:AddDropdown({
  Title   = "Pilih Tema",
  Options = Themes.DropdownOptions(),  -- 27 tema otomatis
  Default = "Dark",
  Callback = function(name)
    Themes.Apply(Library, name)
  end,
})
```

### Generate Tema dari 1 Warna

```lua
-- Auto-generate tema lengkap dari 1 warna primary!
local Orange = Themes.Generate(Color3.fromRGB(255, 100, 0))
Library:SetTheme(Orange)

-- Atau register jadi permanen (masuk ke List/Dropdown!)
Themes.Register("MyOrange", Color3.fromRGB(255, 100, 0))
```

### API Themes

| Method | Deskripsi |
|---|---|
| `Themes.List()` | Array nama semua tema |
| `Themes.Count()` | Jumlah tema |
| `Themes.Get(name)` | Ambil tema (case-insensitive) |
| `Themes.Apply(Library, name)` | Apply aman + validasi + auto-bg Light |
| `Themes.Random(Library)` | Tema random (tidak berulang 2x) |
| `Themes.Generate(color, opts)` | Generate tema dari 1 Color3 |
| `Themes.Register(name, data)` | Register tema custom |
| `Themes.Merge(base, overrides)` | Kombinasi tema |
| `Themes.Validate(name)` | Cek field yang kurang |
| `Themes.DropdownOptions()` | Opsi siap pakai untuk Dropdown |

---

## 🎨 Customization Lainnya

### Ganti Tema Manual

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

> 💡 Di v2.0, `SetTheme` bisa dipanggil **kapan saja** — semua elemen yang sudah dibuat ikut berubah!

### Ganti Font

```lua
Library:SetFont({
  Bold    = Enum.Font.FredokaOne,
  Regular = Enum.Font.Gotham,
})
```

### Background Image

```lua
local Cfg = Library:GetConfig()
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3
```

### Sound Effects

```lua
Library:SetSound(true)   -- aktifkan click/toggle/notif sounds
```

---

## 📖 API Reference

### 🔹 `Library`

| Method | Deskripsi |
|---|---|
| `CreateWindow(config)` | Buat window utama |
| `SetTheme(table)` | Ganti tema (**runtime!**) |
| `SetFont(table)` | Ganti font |
| `SetNotification(config)` | Tampilkan notifikasi |
| `Notify(config)` | Alias `SetNotification` |
| `Dialog(config)` | Confirm dialog |
| `SetSound(bool)` | ON/OFF sound effects |
| `EnableSave(fileName)` | Aktifkan save built-in |
| `DisableSave()` | Matikan save |
| `SetToggleKey(key)` | Ganti hotkey toggle UI |
| `GetConfig()` | Ambil CONFIG internal |
| `Destroy()` | Hapus semua UI |

### 🔹 `CreateWindow(config)`

| Field | Type | Default | Deskripsi |
|---|---|---|---|
| `Title` | string | `""` | Judul window |
| `Description` | string | `""` | Sub-judul |
| `TabWidth` | number | `100` | Lebar panel tab |
| `SizeUi` | UDim2 | `420x280` | Ukuran window |
| `Search` | bool | `false` | Kolom search di daftar tab |
| `Profile` | bool | `false` | Avatar + welcome di footer |
| `Logo` | string | `""` | Icon di sebelah judul |
| `HideName` | bool | `true` | Sensor nama user (abc***) |
| `ToggleKey` | KeyCode | `RightShift` | Hotkey show/hide UI |

### 🔹 `Window`

| Method | Deskripsi |
|---|---|
| `CreateTab({ Name, Icon })` | Buat tab baru |
| `Show()` / `Hide()` / `Toggle()` | Kontrol visibility |
| `Destroy()` | Hapus window |

### 🔹 Item Components

Semua komponen support **format array** (`{ "Title", "Content", ... }`) **atau named** (`{ Title = "..." }`), dan punya method umum: `SetTitle(text)`, `SetContent(text)`, `SetVisible(bool)`, `Destroy()`.

| Method | Field | Extra Methods |
|---|---|---|
| `AddButton` | `Title, Content, Icon, Callback, Tooltip` | `Set(config)` |
| `AddToggle` | `Title, Content, Default, Callback, Tooltip, SaveKey` | `Set(bool, fire?)`, `.Value` |
| `AddSlider` | `Title, Content, Increment, Min, Max, Default, Callback, Tooltip, SaveKey` | `Set(number, fire?)`, `.Value` |
| `AddInput` | `Title, Content, Default, Placeholder, Callback, Tooltip, SaveKey` | `Set(text, fire?)` |
| `AddDropdown` | `Title, Content, Multi, Options, Default, Callback, Search, Tooltip, SaveKey` | `Set(v)`, `Refresh(list, sel)`, `AddOption(name)`, `Clear()` |
| `AddKeybind` 🆕 | `Title, Content, Default, Callback, Tooltip, SaveKey` | `Set(key)`, `Get()` |
| `AddColorPicker` 🆕 | `Title, Content, Default, Callback, Presets, Tooltip, SaveKey` | `Set(color)`, `Get()` |
| `AddPanel` | `Title, Content, Tooltip` | sub: `AddButton`, `AddToggle` |
| `AddParagraph` | `Title, Content, Tooltip` | `Set(config)` |
| `AddSeperator` | `Title, Tooltip` | `Set(config)` |
| `AddLine` | — | `Destroy()` |

> **`SaveKey`** — jika diisi, nilai item otomatis dimuat saat script dijalankan & tersimpan saat berubah (butuh `EnableSave()` atau wrapper). **`fire`** — `Set(value, false)` mengubah visual tanpa memanggil callback.

### 🔹 `SetNotification(config)`

| Field | Type | Default |
|---|---|---|
| `Title` | string | `""` |
| `Description` | string | `""` |
| `Content` | string | `""` |
| `Time` | number | `0.5` |
| `Delay` | number | `5` |
| `Progress` 🆕 | bool | `true` |

> Max 5 notif bersamaan — sisanya otomatis antri (queue system).

### 🔹 `Dialog(config)` 🆕

```lua
Library:Dialog({
  Title   = "Konfirmasi",
  Content = "Yakin lanjut?",
  Buttons = {
    { "Ya", function() end, true },   -- true = tombol primary
    { "Batal", function() end },
  },
})
```

---

## 🔥 Wrapper (FuncsV3)

`wrapper.lua` = shortcut pemakaian + auto-save. **v2.0: tanpa callback manual — otomatis simpan ke file JSON!**

```lua
local FuncsV3 = loadstring(game:HttpGet(
  "[https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua](https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua)"
))()

FuncsV3:BindLibrary(Library)             -- unlock FuncsV3:Notify()
FuncsV3:SetFile("MyHub.json")            -- opsional
getgenv().MyConfig = getgenv().MyConfig or {}
FuncsV3:SetTable(getgenv().MyConfig)     -- auto-load + auto-save!
```

### Wrapper Components

Semua wrapper menerima **positional** (cara lama) **atau table**:

```lua
-- Cara lama (tetap jalan):
FuncsV3:Toggle(Sec, "Auto Farm", "Deskripsi", "Save", callback)

-- Cara baru (lebih rapi):
FuncsV3:Toggle(Sec, {
  Title = "Auto Farm",
  Default = "Save",          -- magic value "Save"
  Key = "main_autofarm",     -- ← kunci unik, bebas nama sama!
  Tooltip = "Farm 24/7",
  Callback = function(v) end,
})
```

| Wrapper | Komponen |
|---|---|
| `Toggle` | AddToggle |
| `Button` | AddButton |
| `Dropdown` | AddDropdown |
| `Textbox` / `Input` | AddInput |
| `Slider` | AddSlider |
| `Keybind` 🆕 | AddKeybind |
| `ColorPicker` 🆕 | AddColorPicker |
| `Panel` 🆕 | AddPanel |
| `Paragraph` | AddParagraph |
| `Seperator` / `Separator` | AddSeperator |
| `Line` | AddLine |

### Wrapper API

| Method | Deskripsi |
|---|---|
| `SetTable(path, storeFn?)` | Setup config — `storeFn` **opsional** sekarang |
| `SetFile(name)` | Nama file JSON (panggil sebelum `SetTable`) |
| `SetVersion(ver, migrateFn?)` | Versioning + migrasi config |
| `Get(key, fallback?)` | Baca nilai config |
| `Set(key, value)` | Tulis nilai (auto-save) |
| `Save()` / `Load()` / `Reset()` | Kontrol manual |
| `SetAutoSave(bool)` | ON/OFF auto-save |
| `BindLibrary(lib)` | Untuk `Notify()` |
| `Notify(config)` | Shortcut notifikasi |

### Magic Value `"Save"`

* `Default = "Save"` → otomatis load nilai tersimpan + auto-save saat berubah
* Default eksplisit selalu dipakai apa adanya (tidak load)
* Kunci simpanan = **nama item**, atau **`Key`** kalau diberikan
* Debounce 0.5 detik, Color3/EnumItem auto-serialize (JSON-safe)

---

## 📁 Contoh Lengkap

Lihat folder [`examples/`](examples/):

| File | Isi |
|---|---|
| `basic.lua` | Paling simpel — window, toggle, button |
| `with-save.lua` | Wrapper + auto-save + versioning |
| `customize.lua` | Runtime theme switcher, font, background |
| `advanced.lua` | **Semua** komponen + API demo |

---

## 📦 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua              ← library utama (v2.0)
├── wrapper.lua           ← shortcut + auto-save (v2.0)
├── themes.lua            ← 27 preset tema (v2.0)
├── README.md
├── LICENSE
└── examples/
    ├── basic.lua
    ├── with-save.lua
    ├── customize.lua
    └── advanced.lua
```

---

## 🔄 Migrasi dari v1.4

| v1.4 | v2.0 | Aksi |
|---|---|---|
| `SetTheme` sebelum `CreateWindow` wajib | Runtime — kapan saja | ✅ Opsional, script lama tetap jalan |
| Toggle callback terpanggil saat init | Tidak lagi | ⚠️ Cek script yang rely on ini |
| Wrapper multi-dropdown "Save" | 🐛 **Bug fix** — sekarang benar tersimpan | Update `wrapper.lua` |
| Wrapper dropdown `Default = "A"` | 🐛 **Bug fix** — tidak dipaksa jadi table | Update `wrapper.lua` |
| Icon Button wrapper hardcoded | Dihapus | Tambah `Icon = "rbxassetid://16932740082"` manual |
| `Library:SetTheme(Themes.X)` | Tetap jalan | Rekomendasi: `Themes.Apply(Library, "X")` |

---

## 💡 Tips

* **Anti-AFK** bisa dimatikan: `Library:GetConfig().Behavior.AntiAFK = false`
* **Tema Light** otomatis matikan background image saat di-apply via `Themes.Apply()`
* Menjalankan script dua kali aman — UI lama otomatis dibersihkan
* **Background image** lebih bagus resolusi **1280x720** ke atas
* **Icon floating button** sebaiknya PNG transparan **128x128**
* **SaveKey** di library vs **wrapper** — pilih salah satu gaya per script, jangan campur
* Slider bisa diklik angkanya untuk **input manual**
* Hover item yang punya Tooltip untuk info tambahan

---

## 🐛 Bug Report

Buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues) baru dengan:
1. Nama executor & versi
2. Langkah reproduksi
3. Error message / screenshot

---

## 📜 License

MIT — bebas dipakai, diubah, dan dibagikan. Lihat [LICENSE](LICENSE).

---

## 🙏 Credit

Made with ❤️ by **King Akbar**

**v2.0 Changelog:** Keybind • ColorPicker • Dialog • Tooltip • Runtime Theme • Built-in Save • Progress Bar • Sound • Slider Upgrade • Notif Queue • Viewport Clamp • 27 Themes • Wrapper v2 (bug fixes + file storage + versioning)
