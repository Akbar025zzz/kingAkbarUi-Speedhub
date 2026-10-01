# 👑 King Akbar UI

> Modern, customizable UI library untuk Roblox — dibikin buat scripting hub & tool.

![Lua](https://img.shields.io/badge/Lua-5.1-blue)
![Roblox](https://img.shields.io/badge/Roblox-Exploit-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/version-1.6-blueviolet)

---

## 📑 Daftar Isi

- [Fitur](#-fitur)
- [Instalasi](#-instalasi)
- [Quick Start](#-quick-start)
- [Komponen](#-komponen)
  - [Window](#-window)
  - [Tab](#-tab)
  - [Section](#-section)
  - [Item Components](#-item-components)
- [Tema](#-tema)
  - [Preset Tema](#-preset-tema)
  - [Live Theme Switching](#-live-theme-switching)
  - [Custom Theme](#-custom-theme)
  - [themes.lua (Extended)](#-themeslua-extended)
- [Auto-Save](#-auto-save)
- [Wrapper (FuncsV3)](#-wrapper-funcsv3)
- [API Reference](#-api-reference)
- [Contoh Lengkap](#-contoh-lengkap)
- [Tips & Troubleshooting](#-tips--troubleshooting)
- [Changelog](#-changelog)
- [Struktur Repo](#-struktur-repo)
- [License](#-license)

---

## ✨ Fitur

| Fitur | Deskripsi |
|---|---|
| 🎨 **Theme Registry** | 17+ preset tema siap pakai + **live switching** tanpa recreate UI |
| 💾 **Auto-Save** | Toggle, slider, input, dropdown otomatis tersimpan & load |
| 📦 **Komponen Lengkap** | Button, Toggle, Slider, Input, Dropdown (multi + search), Panel |
| 🔄 **Dynamic Dropdown** | Update daftar opsi kapan saja (contoh: scan garasi kendaraan) |
| 🖼️ **Background Image** | Support image + tint overlay |
| 🪟 **Auto-Center** | Window selalu center di semua device (PC & mobile) |
| 🔔 **Notification** | Sistem notifikasi sliding dengan close button |
| 🖱️ **Draggable** | Window & floating button bisa dipindah |
| 📱 **Touch Support** | Optimized buat mobile |
| 🎯 **Anti-AFK** | Otomatis, bisa dimatikan |
| 🧹 **Anti-Dup** | Execute ulang aman, UI lama dibersihkan otomatis |

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

Contoh paling minimal — 30 detik langsung jalan:

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

-- 1. Buat Window
local Window = Library:CreateWindow({
  "My Hub",           -- Title
  "v1.0",             -- Description
  100,                -- Tab Width
  UDim2.fromOffset(500, 320),  -- Size
})

-- 2. Buat Tab
local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })

-- 3. Buat Section
local Section = Tab:AddSection("Farming", true)   -- true = open by default

-- 4. Tambah Toggle
Section:AddToggle({
  "Auto Farm",                 -- Title
  "Aktifkan auto farming",     -- Content
  false,                       -- Default
  function(state)              -- Callback
    print("Auto Farm:", state)
  end,
})

-- 5. Tambah Button
Section:AddButton({
  "Reset Character",
  "Klik untuk reset",
  "rbxassetid://7734010488",   -- Icon
  function()
    Library:SetNotification({
      "Success", "•", "Character di-reset"
    })
  end,
})

-- 6. Notif sambutan
Library:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat 🚀" })
```

---

## 🧩 Komponen

### 🔹 Window

```lua
local Window = Library:CreateWindow({
  "My Hub",                    -- Title
  "v1.0",                      -- Description
  100,                         -- Tab Width (opsional)
  UDim2.fromOffset(500, 320),  -- Size (opsional)
})
```

Format array `{ Title, Description, TabWidth, SizeUi }` atau named:
```lua
Library:CreateWindow({
  Title = "My Hub",
  Description = "v1.0",
  TabWidth = 100,
  SizeUi = UDim2.fromOffset(500, 320),
})
```

**Method:**
| Method | Deskripsi |
|---|---|
| `Window:Show()` | Tampilkan window |
| `Window:Hide()` | Sembunyikan (muncul floating button) |
| `Window:Toggle()` | Toggle show/hide |
| `Window:Destroy()` | Tutup permanen + flush save |

---

### 🔹 Tab

```lua
local Tab = Window:CreateTab({
  "Main",                       -- Nama tab
  "rbxassetid://7734010488",    -- Icon (opsional)
})
```

---

### 🔹 Section

```lua
local Section = Tab:AddSection("Farming", true)
```
- Argumen 2 = `true` → section langsung terbuka
- Argumen 2 = `false` / kosong → section tertutup default

---

### 🔹 Item Components

Semua item bisa pakai **format array** atau **named table**.

#### 📌 `Section:AddButton(config)`

```lua
Section:AddButton({
  "Reset",                     -- Title
  "Reset karakter",            -- Content
  "rbxassetid://7734010488",   -- Icon
  function()                   -- Callback
    print("clicked")
  end,
})
```

#### 📌 `Section:AddToggle(config)`

```lua
local MyToggle = Section:AddToggle({
  "Auto Farm",
  "Farm otomatis",
  false,                       -- Default state
  function(state)              -- Callback(value)
    print("Auto Farm:", state)
  end,
  "autofarm_flag",             -- Flag (opsional, buat auto-save key)
})

MyToggle:Set(true)             -- Set manual
print(MyToggle.Value)          -- Baca value
```

#### 📌 `Section:AddSlider(config)`

```lua
local MySlider = Section:AddSlider({
  "WalkSpeed",                 -- Title
  "",                          -- Content
  1,                           -- Increment
  16,                          -- Min
  300,                         -- Max
  16,                          -- Default
  function(value)              -- Callback(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
  end,
  "walkspeed_flag",            -- Flag (opsional)
})

MySlider:Set(100, true)        -- Set + fire callback
```

#### 📌 `Section:AddInput(config)`

```lua
local MyInput = Section:AddInput({
  "Webhook URL",
  "Discord webhook",
  "",                          -- Default text
  function(text)               -- Callback(text)
    print("Input:", text)
  end,
  "webhook_flag",              -- Flag (opsional)
})
```

#### 📌 `Section:AddDropdown(config)`

```lua
local MyDrop = Section:AddDropdown({
  "Pilih Motor",               -- Title
  "Kendaraan yang dipakai",    -- Content
  false,                       -- Multi-select?
  { "Vespa", "Supra", "Ninja" },   -- Options
  { "Vespa" },                 -- Default selected
  function(picked)             -- Callback(table)
    print("Picked:", picked[1])
  end,
  "motor_flag",                -- Flag (opsional)
})
```

**Method dropdown:**
| Method | Deskripsi |
|---|---|
| `Drop:Set(value)` | Set pilihan (string atau table) |
| `Drop:GetValue()` | Ambil pilihan aktif (table) |
| `Drop:GetOptions()` | Ambil daftar opsi |
| `Drop:SetOptions(list, selecting?, opts?)` | Ganti seluruh opsi (dynamic) |
| `Drop:SetPlaceholder("text")` | Ubah placeholder |
| `Drop:AddOption("item")` | Tambah 1 opsi |
| `Drop:Clear()` | Hapus semua opsi |

**Contoh dynamic update** (kasus scan garasi):
```lua
MyDrop:SetPlaceholder("Pindai garasi...")

-- Setelah scan selesai:
MyDrop:SetOptions(
  { "Vespa", "Supra", "Ninja" },
  nil,                                    -- nil = auto-keep selection
  { KeepSelection = true, NoCallback = true }
)
MyDrop:SetPlaceholder("Pilih motor...")
```

#### 📌 `Section:AddParagraph(config)`

```lua
Section:AddParagraph({
  "Info",
  "Ini paragraf panjang yang auto-wrap dan auto-height.",
})
```

#### 📌 `Section:AddSeperator(title)`

```lua
Section:AddSeperator("─── Advanced ───")
```

#### 📌 `Section:AddLine()`

Garis pemisah tipis.
```lua
Section:AddLine()
```

#### 📌 `Section:AddPanel(config)`

Panel collapsible dengan sub-item:

```lua
local Panel = Section:AddPanel({ "Advanced Options", "Klik untuk buka" })

Panel:AddButton({ "Reset All", function() print("reset") end })
Panel:AddToggle({ "Debug Mode", false, function(v) print(v) end })
```

---

## 🎨 Tema

### 🎯 Preset Tema

10 preset bawaan:

```
Dark, Neon, Cyberpunk, BloodRed, Gold,
Purple, Ocean, Light, Matrix, Sunset
```

```lua
-- SEBELUM CreateWindow
Library:SetPreset("Cyberpunk")

local Window = Library:CreateWindow({ "My Hub", "v1.0" })

-- Cek daftar lengkap
print(table.concat(Library:GetThemes(), ", "))
```

### 🔄 Live Theme Switching

Ganti tema **kapan saja** — semua elemen langsung update tanpa recreate UI:

```lua
local Window = Library:CreateWindow({ "My Hub", "v1.0" })
local Tab = Window:CreateTab({ "Main", "" })
local Section = Tab:AddSection("Farm", true)

Section:AddToggle({ "Auto Farm", "", false, function(v) end })
Section:AddSlider({ "Speed", "", 1, 16, 300, 16, function(v) end })

-- Ganti tema runtime
task.wait(3)
Library:SetPreset("Neon")     -- ✅ semua berubah live

task.wait(3)
Library:SetPreset("Light")    -- ✅ ganti lagi

task.wait(3)
Library:SetPreset("BloodRed") -- ✅ smooth
```

### 🎨 Custom Theme

```lua
Library:SetTheme({
  Primary    = Color3.fromRGB(0, 170, 255),
  Background = Color3.fromRGB(20, 20, 25),
  Secondary  = Color3.fromRGB(35, 35, 45),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(150, 150, 150),
  Stroke     = Color3.fromRGB(60, 60, 70),
  Divider    = Color3.fromRGB(80, 80, 80),
  LineColor  = Color3.fromRGB(110, 110, 110),
  Panel      = Color3.fromRGB(255, 255, 255),   -- overlay item
  BackgroundTint = Color3.fromRGB(0, 0, 0),
  BackgroundTintTrans = 0.3,
})
```

### 🧰 themes.lua (Extended)

File `themes.lua` (v2) menyediakan **7 tema bonus** + helper utility:

```lua
local Themes = loadstring(game:HttpGet("URL/themes.lua"))()

-- Daftarkan semua tema bonus ke library
Themes.RegisterAll(Library)
Library:SetPreset("MidnightBlue")   -- sekarang tersedia
```

Tema bonus: `MidnightBlue, Rose, Mono, Forest, Void, Ice, Fire`

**Helper utility:**

| Function | Deskripsi |
|---|---|
| `Themes.New({Base="Dark", Primary=...})` | Bikin theme inherit dari base |
| `Themes.FromColor(color, "dark"/"light")` | Auto-generate theme dari 1 warna |
| `Themes.Blend(A, B, t)` | Blend 2 theme (t: 0..1) |
| `Themes.Get(name)` | Ambil theme by name |
| `Themes.List()` | List semua nama theme |
| `Themes.Random()` | Theme random |
| `Themes.Preview(theme)` | Print warna + hex code |
| `Themes.Validate(theme)` | Cek kelengkapan theme |

**Contoh generate dari 1 warna:**
```lua
Library:SetTheme(Themes.FromColor(Color3.fromRGB(255, 100, 180), "dark"))
```

**Contoh blend:**
```lua
local Blended = Themes.Blend(Themes.Neon, Themes.Cyberpunk, 0.5)
Library:SetTheme(Blended)
```

---

## 💾 Auto-Save

Toggle, slider, input, dan dropdown **otomatis tersimpan & load** saat script di-execute ulang.

**Cara kerja:**
1. Execute script → baca file JSON
2. Bikin item → cek apakah ada value tersimpan
3. User ganti value → auto-save (debounce 0.6 detik)
4. Tutup UI → flush save
5. Execute ulang → semua value balik ke posisi terakhir ✅

**File lokasi:** `workspace/KingAkbarUI_<PlaceId>.json`

**API:**
```lua
Library:SetAutoSave(true)       -- Aktif/matikan (default: true)
Library:SaveNow()               -- Paksa save sekarang
Library:ClearSave()             -- Hapus semua data tersimpan
Library:SetSaveFile("custom")   -- Ganti nama file (SEBELUM CreateWindow)
Library:GetSaveData()           -- Lihat isi save (table)
```

**Contoh:**
```lua
Library:SetSaveFile("MyFarmSettings")   -- sebelum CreateWindow

local Window = Library:CreateWindow({ "My Hub", "v1.0" })
local Tab = Window:CreateTab({ "Main", "" })
local Section = Tab:AddSection("Farm", true)

-- Ini otomatis ke-save & load
Section:AddToggle({ "Auto Farm", "", false, function(v) end })
Section:AddSlider({ "Speed", "", 1, 16, 300, 16, function(v) end })

-- Tombol clear semua save
Section:AddButton({ "Reset Settings", "", "", function()
  Library:ClearSave()
  Library:SetNotification({ "Save", "All reset", "" })
end })
```

> **Flag** — kalau punya 2 item dengan judul sama di section berbeda, tetap aman karena ada prefix namespace. Flag cuma dipakai kalau perlu key custom (misal judul sering berubah):
> ```lua
> Section:AddToggle({ "Anti AFK", "", true, function(v) end, "antiafk_v1" })
> ```

> **Catatan:** executor tanpa `writefile`/`readfile` → auto-fallback ke memory (persist antar execute dalam 1 sesi, hilang kalau Roblox di-restart).

---

## 🔧 Wrapper (FuncsV3)

Wrapper bikin kode lebih pendek + auto-save via storeFn eksternal.

```lua
local FuncsV3 = loadstring(game:HttpGet("URL/wrapper.lua"))()

-- Setup storage
getgenv().MyConfig = getgenv().MyConfig or {}
FuncsV3:SetTable(getgenv().MyConfig, function(cfg)
  -- opsional: simpan ke file
  writefile("MyHub.json", game:GetService("HttpService"):JSONEncode(cfg))
end)

-- Pakai "Save" buat auto-load & auto-save
FuncsV3:Toggle(Section, "Auto Farm", "Farm otomatis", "Save", function(v)
  print(v)
end)

FuncsV3:Slider(Section, "Speed", "", 16, 300, "Save", function(v)
  print(v)
end)

FuncsV3:Dropdown(Section, "Motor", "", false,
  { "Vespa", "Supra" }, "Save", function(v) end)

FuncsV3:Textbox(Section, "Webhook", "", "Save", function(t) end)

-- Flush manual
FuncsV3:Flush()
```

**Kapan pakai wrapper vs auto-save built-in?**
| | Wrapper | Built-in Auto-Save |
|---|---|---|
| Cocok untuk | Library v1.3 ke bawah | Library v1.5+ |
| Key pattern | Judul item | Namespace + judul |
| Fleksibel | Bisa custom storeFn | Fixed JSON file |

> ⚠️ **Jangan pakai keduanya sekaligus** — bisa double-write.

---

## 📖 API Reference

### Window Methods

| Method | Deskripsi |
|---|---|
| `Window:Show()` | Tampilkan window |
| `Window:Hide()` | Sembunyikan |
| `Window:Toggle()` | Toggle visibility |
| `Window:Destroy()` | Tutup permanen |
| `Window:CreateTab({Name, Icon})` | Buat tab baru |

### Tab Methods

| Method | Deskripsi |
|---|---|
| `Tab:AddSection(Title, OpenDefault)` | Buat section |

### Section Methods

| Method | Deskripsi |
|---|---|
| `AddButton` | Button item |
| `AddToggle` | Toggle item |
| `AddSlider` | Slider item |
| `AddInput` | Text input |
| `AddDropdown` | Dropdown (multi + search) |
| `AddPanel` | Collapsible panel |
| `AddParagraph` | Paragraf teks |
| `AddSeperator` | Divider dengan judul |
| `AddLine` | Garis tipis |

### Item Common Methods

Semua item punya:
- `SetTitle(text)`
- `SetContent(text)`
- `SetVisible(bool)`
- `Destroy()`

### Notification

```lua
Library:SetNotification({
  "Title",          -- Judul
  "Description",    -- Deskripsi (warna primary)
  "Content",        -- Konten panjang (opsional)
  0.5,              -- Animation time (opsional)
  5,                -- Auto-close delay (opsional)
})

-- Alias
Library:Notify({ ... })
```

### Library API

```lua
Library:SetTheme(themeTable)         -- Custom theme
Library:SetPreset("Neon")            -- Preset by name
Library:GetThemes()                  -- List preset
Library.Themes                       -- Akses table theme langsung
Library:SetFont({ Bold=..., Regular=... })
Library:GetConfig()                  -- Akses CONFIG global
Library:SetAutoSave(bool)
Library:SaveNow()
Library:ClearSave()
Library:SetSaveFile(name)
Library:GetSaveData()
Library:Destroy()
```

### Config Access

```lua
local Cfg = Library:GetConfig()

-- Background image
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5

-- Floating button icon
Cfg.Assets.FloatingButton = "rbxassetid://91115084979317"

-- Anti-AFK
Cfg.Behavior.AntiAFK = false
```

---

## 📝 Contoh Lengkap

### Contoh 1 — Basic Farm Hub

```lua
local Library = loadstring(game:HttpGet("URL_INIT"))()

local Window = Library:CreateWindow({ "Farm Hub", "v1.0", 110, UDim2.fromOffset(520, 320) })
local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local Section = Tab:AddSection("Auto Farm", true)

Section:AddToggle({
  "Enable Farm", "Auto farm aktif", false,
  function(v) print("Farm:", v) end
})

Section:AddSlider({
  "Radius", "Jarak farm", 5, 10, 200, 50,
  function(v) print("Radius:", v) end
})

Section:AddButton({
  "Refresh Target", "Scan ulang target", "rbxassetid://7734010488",
  function() print("refreshed") end
})

Library:SetNotification({ "Farm Hub", "Loaded", "v1.0 ready 🚀" })
```

### Contoh 2 — Theme Switcher Tab

```lua
local Library = loadstring(game:HttpGet("URL_INIT"))()

local Window = Library:CreateWindow({ "Theme Demo", "v1.0" })
local Tab = Window:CreateTab({ "Themes", "" })
local Section = Tab:AddSection("Pilih Tema", true)

for _, name in ipairs(Library:GetThemes()) do
  Section:AddButton({
    name, "", "",
    function()
      Library:SetPreset(name)
      Library:SetNotification({ "Theme", "Changed", name })
    end,
  })
end
```

### Contoh 3 — Dynamic Dropdown (Scan Garasi)

```lua
local Library = loadstring(game:HttpGet("URL_INIT"))()

local Window = Library:CreateWindow({ "Garage", "v1.0" })
local Tab = Window:CreateTab({ "Kendaraan", "" })
local Section = Tab:AddSection("Motor", true)

local MotorDrop = Section:AddDropdown({
  "Pilih Motor", "Kendaraan yang dipakai",
  false, {}, {},
  function(picked)
    if #picked > 0 then print("Selected:", picked[1]) end
  end,
})
MotorDrop:SetPlaceholder("Pindai garasi...")

local function ScanGarage()
  MotorDrop:SetPlaceholder("Memindai...")
  task.wait(1.5)

  local hasil = { "Vespa", "Supra", "Ninja" }   -- simulasi hasil scan

  MotorDrop:SetOptions(hasil, nil,
    { KeepSelection = true, NoCallback = true })
  MotorDrop:SetPlaceholder("Pilih motor...")

  Library:SetNotification({
    "Garasi Terdeteksi",
    "Ditemukan " .. #hasil .. " kendaraan!",
    table.concat(hasil, ", ")
  })
end

Section:AddButton({
  "Refresh Garasi", "Scan ulang", "",
  function() ScanGarage() end
})

task.spawn(function()
  task.wait(2)
  ScanGarage()
end)
```

### Contoh 4 — Auto-Save + Custom Save File

```lua
local Library = loadstring(game:HttpGet("URL_INIT"))()

Library:SetSaveFile("MyFarmSettings")   -- SEBELUM CreateWindow

local Window = Library:CreateWindow({ "Farm", "v1.0" })
local Tab = Window:CreateTab({ "Main", "" })
local Section = Tab:AddSection("Farm", true)

-- Semua ini otomatis persist
Section:AddToggle({ "Auto Farm", "", false, function(v) end })
Section:AddSlider({ "Speed", "", 1, 16, 300, 16, function(v) end })
Section:AddInput({ "Webhook", "", "", function(v) end })

Section:AddButton({ "Reset Save", "", "", function()
  Library:ClearSave()
  Library:SetNotification({ "Save", "All data cleared", "" })
end })
```

---

## 💡 Tips & Troubleshooting

### ✅ Best Practices

- **Set tema SEBELUM `CreateWindow`** kalau mau semua elemen konsisten. Tapi **live switching** juga didukung setelah window dibuat.
- Pakai **flag** untuk item dengan judul generik (mis. `"Speed"`, `"Enable"`) biar nggak konflik save.
- **Light theme** → matikan background image biar nggak tertutup tint:
  ```lua
  Library:GetConfig().Window.BackgroundImage = ""
  ```
- **Background image** optimal di resolusi **1280×720** ke atas.
- **Icon floating button** sebaiknya PNG transparan ukuran **128×128**.
- Kalau `loadstring` gagal, cek URL raw — pakai `raw.githubusercontent.com`, bukan `github.com`.

### 🐛 Troubleshooting

| Masalah | Solusi |
|---|---|
| UI muncul dobel | Execute ulang aman, tapi pastikan versi library sama |
| Save nggak jalan | Cek `writefile` support. Pakai executor yang support file IO |
| Tema nggak berubah | Pastikan panggil `SetPreset` dengan nama yang ada di `Lib:GetThemes()` |
| Slider berat di mobile | Kecilkan `Max` atau pakai `Increment` lebih besar |
| Dropdown nggak ke-update | Pakai `SetOptions` bukan `Refresh` (yang lama reset callback) |

---

## 📋 Changelog

### v1.6 *(current)*
- ✨ **Theme Registry built-in** (10 preset)
- ✨ **Live theme switching** — ganti tema runtime tanpa recreate UI
- ✨ **Auto-Save built-in** — toggle/slider/input/dropdown persist
- ✨ **Dynamic Dropdown** — `SetOptions`, `SetPlaceholder`, `GetOptions`, `GetValue`
- ✨ Tab kotak profesional (idle/active state berbeda)
- 🐛 Fix `Time` & `Delay` di notification

### v1.5
- ✨ Auto-save internal + config file

### v1.4
- ✨ Dynamic dropdown refresh
- ✨ Tab kotak

### v1.3
- 🎉 Initial release
- Komponen dasar: Button, Toggle, Slider, Input, Dropdown, Panel
- 10 preset tema

---

## 📦 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua              ← library utama (v1.6)
├── wrapper.lua           ← shortcut + auto-save eksternal
├── themes.lua            ← extended themes (v2)
├── README.md
├── LICENSE
└── examples/
    ├── basic.lua
    ├── with-save.lua
    ├── customize.lua
    └── advanced.lua
```

---

## 🤝 Kontribusi

Pull request & issue welcome! Kalau nemu bug atau punya saran fitur, buka [issue](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub/issues).

---

## 📜 License

MIT — bebas dipakai, diubah, dan dibagikan. Lihat [LICENSE](LICENSE).

---

## 🙏 Credit

Made with ❤️ by **King Akbar**

- GitHub: [@Akbar025zzz](https://github.com/Akbar025zzz)
- Repo: [kingAkbarUi-Speedhub](https://github.com/Akbar025zzz/kingAkbarUi-Speedhub)
