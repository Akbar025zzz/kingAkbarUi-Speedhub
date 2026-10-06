# Wrapper (FuncsV3)

`wrapper.lua` = shortcut pemakaian + auto-save. Di v2.0 tanpa callback manual, otomatis simpan ke file JSON.

## Setup

```lua
local FuncsV3 = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua"
))()

FuncsV3:BindLibrary(Library)             -- unlock FuncsV3:Notify()
FuncsV3:SetFile("MyHub.json")            -- opsional
getgenv().MyConfig = getgenv().MyConfig or {}
FuncsV3:SetTable(getgenv().MyConfig)     -- auto-load + auto-save
```

## Pemakaian Komponen

Semua wrapper menerima positional (cara lama) atau table:

```lua
-- Cara lama (tetap jalan):
FuncsV3:Toggle(Sec, "Auto Farm", "Deskripsi", "Save", callback)

-- Cara baru (lebih rapi):
FuncsV3:Toggle(Sec, {
  Title = "Auto Farm",
  Default = "Save",
  Key = "main_autofarm",   -- kunci unik, nama item boleh sama
  Tooltip = "Farm 24/7",
  Callback = function(v) end,
})
```

| Wrapper | Komponen |
| --- | --- |
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

## Wrapper API

| Method | Deskripsi |
| --- | --- |
| `SetTable(path, storeFn?)` | Setup config; `storeFn` opsional |
| `SetFile(name)` | Nama file JSON (panggil sebelum `SetTable`) |
| `SetVersion(ver, migrateFn?)` | Versioning + migrasi config |
| `Get(key, fallback?)` | Baca nilai config |
| `Set(key, value)` | Tulis nilai (auto-save) |
| `Save()` / `Load()` / `Reset()` | Kontrol manual |
| `SetAutoSave(bool)` | ON/OFF auto-save |
| `BindLibrary(lib)` | Untuk `Notify()` |
| `Notify(config)` | Shortcut notifikasi |

## Magic Value `"Save"`

- `Default = "Save"`: otomatis load nilai tersimpan + auto-save saat berubah
- Default eksplisit selalu dipakai apa adanya (tidak load)
- Kunci simpanan = nama item, atau `Key` kalau diberikan
- Debounce 0.5 detik; Color3/EnumItem auto-serialize (JSON-safe)
