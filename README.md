<div align="center">

# ⚡ kingAkbarUi-Speedhub

**Library UI Roblox yang ringan, rapi, dan mobile-friendly.**
Dibuat untuk executor modern (Delta, Wave, Solara, Fluxus, dll) — aman di-execute ulang tanpa UI dobel.

![Version](https://img.shields.io/badge/version-1.5-blueviolet?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Luau](https://img.shields.io/badge/bahasa-Luau-navy?style=for-the-badge)

</div>

---

## ✨ Fitur (v1.5 "Rapih Edition")

| Kategori | Detail |
|---|---|
| **Layout** | Topbar 44px · Sidebar 112px · Section 34px · Item 40px · Scrollbar halus 3px |
| **Kontrol** | Toggle iOS 40×20 · Slider (kotak nilai + track) · Dropdown 120×24 (+ search) · Input · Button · ColorPicker 48×22 · Keybind 64×22 · Panel expandable |
| **Window** | Draggable, tombol minimize/close bulat, floating button, background image + tint, badge/pill |
| **Sidebar** | Kolom search tab, profil player (avatar + nama disensor) |
| **Themes** | 11 preset + `Themes.Apply()` + override otomatis untuk tema terang |
| **Wrapper** | `FuncsV3`: shortcut item + **auto-save config** (`"Save"`) + ThemePicker |
| **Stabilitas** | Cleanup otomatis saat execute ulang, semua callback dibungkus `pcall`, Anti-AFK bawaan |

---

## 🚀 Quick Start

### Cara 1 — Satu baris (disarankan, pakai `loader.lua`)

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/loader.lua"))()

local Win = UI:QuickHub({ Title = "My Hub", Desc = "v1.5", File = "my_hub.json", Theme = "Violet" })
local Sec = Win:CreateTab({ "Main" }):AddSection("Features", true)

UI.FuncsV3:Toggle(Sec, "Auto Farm", "Farm otomatis", "Save", function(v) print(v) end)
UI.FuncsV3:ColorPicker(Sec, "ESP Color", "Warna ESP", "Save", function(c) print(c) end)
```

> `loader.lua` menarik `init.lua` + `themes.lua` + `wrapper.lua` sekaligus,
> memuat config tersimpan, dan menerapkan theme otomatis.

### Cara 2 — Manual (tanpa loader)

```lua
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/init.lua"))()

local Win = Lib:CreateWindow({ "King Akbar", "v1.5", 112, UDim2.fromOffset(460, 300) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("Farm", true)

Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print(v) end })
Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print(v) end })

Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
```

---

## 📁 Struktur Repo

```
kingAkbarUi-Speedhub/
├── init.lua        ← library utama (v1.5)
├── wrapper.lua     ← FuncsV3: shortcut + auto-save
├── themes.lua      ← 11 preset tema
├── loader.lua      ← 1-click loader (opsional tapi disarankan)
├── README.md
├── LICENSE
└── examples/
    ├── basic.lua       ← paling simpel
    ├── with-save.lua   ← pakai wrapper + save config
    ├── customize.lua   ← ganti tema, font, background
    └── advanced.lua    ← semua komponen
```

---

## 📘 Dokumentasi API

### Library (`Lib`)

| Method | Keterangan |
|---|---|
| `Lib:CreateWindow(cfg)` | `cfg` array/named: `Title, Description, TabWidth, SizeUi, Search, Profile, Logo, HideName` |
| `Lib:SetNotification(cfg)` | `{ Title, Description, Content, _, Time, Delay }` (alias: `Lib:Notify`) |
| `Lib:SetTheme(t)` / `Lib:SetFont(f)` | **Wajib sebelum** `CreateWindow` agar terpakai penuh |
| `Lib:GetConfig()` | Akses `CONFIG` (Theme, Window, Item, Behavior, Assets) |
| `Lib:Destroy()` | Bersihkan semua GUI + koneksi |

### Window (`Win`)

`CreateTab({Name, Icon})` · `AddBadge(text)` · `Show()` · `Hide()` · `Toggle()` · `Destroy()`

### Section & Items (`Tab:AddSection(judul, terbuka)`)

| Item | Argumen (array / named) |
|---|---|
| `AddToggle` | Title, Content, Default, Callback |
| `AddSlider` | Title, Content, Increment, Min, Max, Default, Callback |
| `AddDropdown` | Title, Content, Multi, Options, Default, Callback |
| `AddInput` | Title, Content, Default, Callback |
| `AddButton` | Title, Content, Icon, Callback |
| `AddColorPicker` | Title, Content, Default(Color3), Callback |
| `AddKeybind` | Title, Content, Default(KeyCode), Callback(tekan), OnChange(ganti bind) |
| `AddPanel` | Title, Content → punya `:AddButton(cfg)`, `:AddToggle(cfg)` |
| `AddParagraph` / `AddSeperator` / `AddLine` | — |

Semua item punya: `:Set()`, `:SetTitle()`, `:SetContent()`, `:SetVisible()`, `:Destroy()`.
Dropdown tambahan: `:AddOption()`, `:Refresh(list, select)`, `:Clear()`.

### Wrapper (`FuncsV3`)

```lua
local FuncsV3 = loadstring(game:HttpGet(".../wrapper.lua"))()
FuncsV3:SetTable(getgenv().MyConfig, function(cfg) writefile("cfg.json", Http:JSONEncode(cfg)) end)

FuncsV3:Toggle(Sec, "Auto Farm", "", "Save", function(v) end)   -- "Save" = load & simpan otomatis
FuncsV3:Slider(Sec, "WalkSpeed", "", 16, 200, "Save", function(v) end)
FuncsV3:Dropdown(Sec, "Mode", "", false, {"A","B"}, "Save", function(v) end)
FuncsV3:Textbox(Sec, "Nama", "", "Save", function(t) end)
FuncsV3:ColorPicker(Sec, "ESP Color", "", "Save", function(c) end)  -- tersimpan sebagai hex
FuncsV3:Keybind(Sec, "Fly Hotkey", "", "Save", function() end)      -- tersimpan sebagai nama key
FuncsV3:ThemePicker(Sec, Lib, Themes, function(name) end)           -- dropdown ganti tema
```

### Themes (`themes.lua`)

`Dark` · `Neon` · `Cyberpunk` · `BloodRed` · `Gold` · `Purple` · `Ocean` · `Light` · `Matrix` · `Sunset` · `Violet`

```lua
local Themes = loadstring(game:HttpGet(".../themes.lua"))()
Themes.Apply(Lib, "Neon")            -- sebelum CreateWindow
Themes.Apply(Lib, FuncsV3:GetSavedTheme())  -- kombinasi dengan auto-save
```

---

## 📚 Contoh

Lihat folder [`examples/`](examples/):

| File | Isi |
|---|---|
| `basic.lua` | Window + tab + section minimal |
| `with-save.lua` | Wrapper `FuncsV3` + auto-save config ke file |
| `customize.lua` | Ganti tema, font, dan background via `GetConfig()` |
| `advanced.lua` | Semua komponen: dropdown, colorpicker, keybind, panel |

---

## ❓ FAQ

- **UI dobel saat execute ulang?** Sudah otomatis cleanup. Kalau masih, panggil `Lib:Destroy()` dulu.
- **Theme tidak terpakai?** `SetTheme` / `Themes.Apply` wajib dipanggil **sebelum** `CreateWindow`.
- **Theme Light terlihat gelap?** Sudah ditangani: `Themes.Apply` otomatis mematikan background image untuk tema terang.
- **Executor tanpa `writefile`?** Auto-save otomatis dilewati dengan aman (pcall), script tetap jalan.
- **Callback error?** Semua callback dibungkus `pcall`; pesan error muncul di console sebagai `[KingAkbarUI]`.

---

## 🤝 Kontribusi

Pull request terbuka! Lihat gaya kode di `init.lua` (indent tab, callback via `SafeCall`).
Laporan bug: buka Issue sertakan executor, game, dan screenshot error.

## 📜 Lisensi

[MIT](LICENSE) — bebas dipakai & dimodifikasi, tetap sertakan kredit.

---

<div align="center">
Dibuat dengan ❤ oleh <b>Akbar025zzz</b> — <i>King Akbar UI</i>
</div>
