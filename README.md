# kingAkbarUi-Speedhub

Library UI Roblox yang **ringan, rapi, dan mobile-friendly**. Dibuat untuk executor modern (Delta, Wave, Solara, dll) dan aman di-execute ulang.

## ✨ Fitur
- Layout konsisten: topbar 44px · sidebar 112px · section 34px · item 40px · scrollbar 3px
- Toggle model iOS (40×20), slider dengan kotak nilai, ColorPicker, Keybind
- 11 preset tema (`themes.lua`) + override otomatis untuk tema terang
- Wrapper `FuncsV3` dengan **auto-save config** (default `"Save"`)
- Notifikasi animasi, badge/pill, tab search, profil player, draggable, floating button
- Cleanup otomatis saat execute ulang (anti UI dobel)
- Anti-AFK bawaan (bisa dimatikan via `GetConfig().Behavior.AntiAFK = false`)

## 📁 Struktur
```
kingAkbarUi-Speedhub/
├── init.lua        -- library inti (v1.5)
├── wrapper.lua     -- FuncsV3: shortcut + auto-save
├── themes.lua      -- 11 preset tema
├── README.md
├── LICENSE
└── examples/       -- 7 contoh siap pakai
~~~

## 🚀 Quick Start
```lua
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib = loadstring(game:HttpGet(BASE .. "init.lua"))()

local Win = Lib:CreateWindow({ "King Akbar", "v1.5", 112, UDim2.fromOffset(460, 300) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("Farm", true)

Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print(v) end })
Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
```

## 📘 API Singkat

### Library (`Lib`)
| Method | Keterangan |
|---|---|
| `Lib:CreateWindow(cfg)` | `cfg` array/named: `Title, Description, TabWidth, SizeUi, Search, Profile, Logo, HideName` |
| `Lib:SetNotification(cfg)` | `{ Title, Description, Content, _, Time, Delay }` |
| `Lib:SetTheme(t)` / `Lib:SetFont(f)` | **Sebelum** `CreateWindow` untuk hasil penuh |
| `Lib:GetConfig()` | Akses `CONFIG` (Theme, Window, Behavior, dll) |
| `Lib:Destroy()` | Bersihkan semua GUI + koneksi |

### Window (`Win`)
`CreateTab({Name, Icon})` · `AddBadge(text)` · `Show()` · `Hide()` · `Toggle()` · `Destroy()`

### Section (`Tab:AddSection(judul, terbuka)`)
| Item | Argumen utama |
|---|---|
| `AddToggle` | Title, Content, Default, Callback |
| `AddSlider` | Title, Content, Increment, Min, Max, Default, Callback |
| `AddDropdown` | Title, Content, Multi, Options, Default, Callback |
| `AddInput` | Title, Content, Default, Callback |
| `AddButton` | Title, Content, Icon, Callback |
| `AddColorPicker` | Title, Content, Default(Color3), Callback |
| `AddKeybind` | Title, Content, Default(KeyCode), Callback(tekan), OnChange(ganti bind) |
| `AddPanel` | Title, Content → `:AddButton`, `:AddToggle` |
| `AddParagraph / AddSeperator / AddLine` | — |

Semua item punya: `:Set()`, `:SetTitle()`, `:SetContent()`, `:SetVisible()`, `:Destroy()`.
Dropdown tambahan: `:AddOption()`, `:Refresh(list, select)`, `:Clear()`.

## 🎨 Themes
`Dark · Neon · Cyberpunk · BloodRed · Gold · Purple · Ocean · Light · Matrix · Sunset · Violet`
```lua
local Themes = loadstring(game:HttpGet(BASE .. "themes.lua"))()
Themes.Apply(Lib, "Neon")          -- sebelum CreateWindow
```

## 💾 Wrapper (FuncsV3)
```lua
local FuncsV3 = loadstring(game:HttpGet(BASE .. "wrapper.lua"))()
FuncsV3:SetTable(getgenv().Cfg, function(cfg) writefile("cfg.json", Http:JSONEncode(cfg)) end)
FuncsV3:Toggle(Sec, "Auto Farm", "", "Save", function(v) end)  -- default "Save" = auto-load
```

## 📚 Examples
| File | Isi |
|---|---|
| `01-basic.lua` | Window + tab + section minimal |
| `02-all-components.lua` | Semua komponen |
| `03-theme-switcher.lua` | Ganti tema + rebuild window |
| `04-auto-save.lua` | Wrapper + simpan config ke file |
| `05-dynamic-dropdown.lua` | Dropdown yang di-refresh runtime |
| `06-full-hub.lua` | Contoh hub lengkap (Farm/Player/Settings) |
| `07-mega-showcase.lua` | Semua fitur sekaligus |

## 📜 License
[MIT](LICENSE) — bebas dipakai, tetap sertakan kredit.
