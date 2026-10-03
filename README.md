# 👑 King Akbar UI

> Modern, customizable UI library untuk Roblox — dibuat untuk scripting hub & tool.

![Version](https://img.shields.io/badge/Version-2.0-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Language](https://img.shields.io/badge/Language-Lua-red)

**Daftar isi:** [Fitur](#-fitur) · [Instalasi](#-instalasi) · [Template Hub](#-template-hub-model-standar) · [Quick Start](#-quick-start) · [Pakai AI?](#-pakai-ai) · [Themes](#-themes) · [API Reference](#-api-reference) · [Wrapper](#-wrapper-funcsv3) · [Contoh](#-contoh-lengkap) · [Tips](#-tips)

---

## ✨ Fitur

- 🎨 **Fully customizable** — tema, font, ukuran, background, icon
- 🖼️ **Background image support** + tint & transparency
- 🪟 **Window auto-center** di semua device (PC & mobile)
- 📦 **12 komponen** — Button, Toggle, Slider, Input, Dropdown (multi + search), Keybind, ColorPicker, Panel, Paragraph, Seperator, Line, Dialog
- 🔔 **Notification system** + progress bar + queue
- 🖱️ **Draggable** window & floating button
- 📱 **Touch support** (mobile-friendly)
- 🎯 **Anti-AFK** otomatis (bisa dimatikan)
- 🎨 **27 preset tema** + generate tema dari 1 warna
- 🎹 **Keybind system** + hotkey buka/tutup UI
- 💬 **Tooltip** di semua komponen
- 💾 **Config save/load** built-in ATAU via wrapper
- 🔊 **Sound effects** optional
- 🧩 **Template hub siap pakai** + 🤖 **panduan AI**

### 🆕 Yang baru di v2.0

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

## 🚀 Instalasi

### Cara 1 — `loadstring` (recommended)

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
```

### Cara 2 — `loader.lua` (memuat init + themes + wrapper sekaligus, dengan retry)

```lua
local KA = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/loader.lua"
))()
local Library, Themes, FuncsV3 = KA.Library, KA.Themes, KA.Wrapper
```

### Cara 3 — Clone repo

```bash
git clone https://github.com/Akbar025zzz/kingAkbarUi-Speedhub.git
```

---

## 🧩 Template Hub (Model Standar)

Mau bikin hub sendiri? **Mulai dari template, jangan dari nol.**
File lengkapnya: [`examples/template.lua`](examples/template.lua)

**Cara pakai (4 langkah):**

1. Salin `examples/template.lua`.
2. Ubah blok `HUB` di bagian atas: nama, game, versi, tema, logo, link Discord, hotkey.
3. Isi logika fitur di bagian yang bertanda `TODO`.
4. Jalankan. Tab **Info** dan **Settings** (ganti tema, hotkey UI, Anti-AFK, tutup UI) sudah jadi.

**Yang sudah ada di template:**

- 🖥️ tampilan hub modern: sidebar + search, profil, section yang bisa dibuka/tutup
- 🔁 helper `Loop()` untuk fitur "auto" — tidak dobel, berhenti saat dimatikan, error tidak mematikan hub
- 💾 `SaveKey` di tiap item supaya pilihan user tersimpan
- ⚙️ tab Settings siap pakai dengan konfirmasi sebelum menutup UI

<details>
<summary><b>👀 Lihat template ringkas (±80 baris)</b></summary>

```lua
-- ═══ PENGATURAN HUB ═══
local HUB = {
  Name = "Nama Hub", Tagline = "|  Komunitas", Game = "Nama Game", Version = "v1.0.0",
  Theme = "Violet", Logo = "rbxassetid://7734010488", ToggleKey = Enum.KeyCode.RightShift,
  SaveFile = "NamaHub.json",
}

-- ═══ LOAD ═══
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"
local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ═══ TEMA & SAVE ═══
if type(Themes.Apply) == "function" then Themes.Apply(Library, HUB.Theme)
elseif Themes[HUB.Theme] then Library:SetTheme(Themes[HUB.Theme]) end
Library:GetConfig().Window.BackgroundImage = ""
if type(Library.EnableSave) == "function" then Library:EnableSave(HUB.SaveFile) end

-- ═══ WINDOW ═══
local Window = Library:CreateWindow({
  Title = HUB.Name, Description = HUB.Tagline,
  Search = true, Profile = true, HideName = true,
  Logo = HUB.Logo, ToggleKey = HUB.ToggleKey,
})

-- ═══ HELPER ═══
local State, Loops = {}, {}
local function Loop(Flag, Interval, Fn)          -- fitur "auto": jalan selama State[Flag] == true
  if Loops[Flag] then return end
  Loops[Flag] = true
  task.spawn(function()
    while State[Flag] do
      local ok, err = pcall(Fn)
      if not ok then warn(Flag .. ": " .. tostring(err)) end
      task.wait(Interval)
    end
    Loops[Flag] = nil
  end)
end
local function Notify(Title, Text)
  Library:SetNotification({ Title = Title, Description = "•", Content = Text, Delay = 3 })
end

-- ═══ TAB ═══
local MainTab     = Window:CreateTab({ "Main" })
local SettingsTab = Window:CreateTab({ "Settings" })

-- ═══ FITUR ═══
local Farm = MainTab:AddSection("Farming", true)

Farm:AddToggle({
  Title = "Auto Farm", Content = "Deskripsi singkat", Default = false, SaveKey = "auto_farm",
  Callback = function(on)
    State.AutoFarm = on
    if on then
      Loop("AutoFarm", 0.5, function()
        -- logika fitur di sini
      end)
    end
  end,
})

Farm:AddDropdown({
  Title = "Target", Multi = false, Options = { "A", "B", "C" }, Default = "A", SaveKey = "target",
  Callback = function(x)
    State.Target = (type(x) == "table") and x[1] or x
  end,
})

-- ═══ SETTINGS ═══
local Misc = SettingsTab:AddSection("Lainnya", true)
Misc:AddButton({
  Title = "Tutup UI", Content = "Hapus UI & hentikan semua fitur",
  Callback = function()
    for k in pairs(State) do State[k] = false end
    Library:Destroy()
  end,
})

Notify(HUB.Name, "Loaded — tekan [" .. HUB.ToggleKey.Name .. "] untuk buka/tutup UI")
```

</details>

---

## ⚡ Quick Start

```lua
local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
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

> **Hierarki:** `Library → Window → Tab → Section → Komponen`. Komponen (`AddToggle`, `AddButton`, dll.) selalu dipanggil dari **Section**, bukan dari Tab atau Window.

---

## 🤖 Pakai AI?

Banyak orang membuat script lewat AI (Claude, ChatGPT, Gemini, dll.). Supaya hasilnya benar dan tidak membingungkan:

1. **Salin [`AI_GUIDE.md`](AI_GUIDE.md)** ke AI — satu file berisi aturan, referensi API, dan template.
2. Lanjutkan dengan permintaanmu, misalnya:

> Pakai panduan di atas. Buatkan script hub untuk game **[nama game]** dengan fitur: auto collect coin, auto sell, WalkSpeed slider, dan pilihan lokasi teleport (dropdown). Ikuti TEMPLATE persis dan isi logikanya.

3. Salin hasilnya ke executor. Kalau error, kirim **pesan error dari console (F9)** + script-nya ke AI, lalu minta diperbaiki.

<details>
<summary><b>📋 Aturan yang dipatuhi AI (ringkasan)</b></summary>

1. Selalu pakai struktur **template** — jangan bikin struktur sendiri.
2. Hanya pakai method yang ada di [API Reference](#-api-reference) — tidak mengarang.
3. Hierarki wajib: `Library → Window → Tab → Section → Komponen`.
4. Semua parameter pakai **format bernama** (`{ Title = "...", Callback = ... }`).
5. Fitur "auto" wajib lewat helper `Loop()` — bukan `while true do` tanpa flag.
6. Status fitur disimpan di tabel `State`, bukan variabel global.
7. Callback Dropdown dinormalisasi: `local v = (type(x) == "table") and x[1] or x`.
8. Tema & font diatur **sebelum** `CreateWindow` (di v1.x wajib; di v2.0 opsional).
9. `SaveKey` harus unik per item.

**Kesalahan umum AI yang dihindari:**

| ❌ Salah | ✅ Benar |
|---|---|
| `Tab:AddToggle({...})` | `Tab:AddSection("X", true):AddToggle({...})` |
| `Window:AddTab("Main")` | `Window:CreateTab({ "Main" })` |
| `Library.new("Judul")` | `Library:CreateWindow({ Title = "Judul" })` |
| `while true do ... end` untuk fitur auto | `Loop("Flag", detik, function() ... end)` |
| `_G.AutoFarm = true` | `State.AutoFarm = true` |

</details>

---

## 🎨 Themes

### Pakai Preset (27 tema)

```lua
local Themes = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua"
))()

Themes.Apply(Library, "Neon")   -- ✅ recommended: validasi + auto-bg
-- atau cara lama: Library:SetTheme(Themes.Neon)
```

**Tersedia:** Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset, Violet, Emerald, Forest, Sakura, Rose, Cherry, Midnight, Amoled, Monochrome, Coffee, Arctic, Steel, Discord, Nord, Dracula, Catppuccin, TokyoNight

### 🔥 Runtime Theme Switcher

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
| `HideName` | bool | `true` | Sensor nama user (abc\*\*\*) |
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
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua"
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

- `Default = "Save"` → otomatis load nilai tersimpan + auto-save saat berubah
- Default eksplisit selalu dipakai apa adanya (tidak load)
- Kunci simpanan = **nama item**, atau **`Key`** kalau diberikan
- Debounce 0.5 detik, Color3/EnumItem auto-serialize (JSON-safe)

---

## 📁 Contoh Lengkap

Lihat folder [`examples/`](examples/):

| File | Isi |
|---|---|
| `template.lua` ⭐ | **Model standar hub** — salin & ubah blok `HUB` |
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
├── loader.lua            ← memuat init + themes + wrapper sekaligus
├── AI_GUIDE.md           ← panduan untuk AI (salin ke AI)
├── README.md
├── LICENSE
└── examples/
    ├── template.lua      ← model standar hub
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

- **Anti-AFK** bisa dimatikan: `Library:GetConfig().Behavior.AntiAFK = false`
- **Tema Light** otomatis matikan background image saat di-apply via `Themes.Apply()`
- Menjalankan script dua kali aman — UI lama otomatis dibersihkan
- **Background image** lebih bagus resolusi **1280x720** ke atas
- **Icon floating button** sebaiknya PNG transparan **128x128**
- **SaveKey** di library vs **wrapper** — pilih salah satu gaya per script, jangan campur
- Slider bisa diklik angkanya untuk **input manual**
- Hover item yang punya Tooltip untuk info tambahan

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
