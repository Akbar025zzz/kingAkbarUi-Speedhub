# Themes

## Pakai Preset (27 tema)

```lua
local Themes = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua"
))()

Themes.Apply(Library, "Neon")   -- direkomendasikan: validasi + auto-bg
-- atau cara lama: Library:SetTheme(Themes.Neon)
```

**Tersedia:** Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset, Violet, Emerald, Forest, Sakura, Rose, Cherry, Midnight, Amoled, Monochrome, Coffee, Arctic, Steel, Discord, Nord, Dracula, Catppuccin, TokyoNight

## Runtime Theme Switcher

```lua
Section:AddDropdown({
  Title   = "Pilih Tema",
  Options = Themes.DropdownOptions(),
  Default = "Dark",
  Callback = function(name) Themes.Apply(Library, name) end,
})
```

## Generate Tema dari 1 Warna

```lua
local Orange = Themes.Generate(Color3.fromRGB(255, 100, 0))
Library:SetTheme(Orange)

-- Register permanen (masuk ke List/Dropdown)
Themes.Register("MyOrange", Color3.fromRGB(255, 100, 0))
```

## API Themes

| Method | Deskripsi |
| --- | --- |
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

## Kustomisasi Lain

### Tema manual

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

Di v2.0 `SetTheme` bisa dipanggil kapan saja; semua elemen yang sudah dibuat ikut berubah.

### Font

```lua
Library:SetFont({
  Bold    = Enum.Font.FredokaOne,
  Regular = Enum.Font.Gotham,
})
```

### Background image

```lua
local Cfg = Library:GetConfig()
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3
```

### Sound effects

```lua
Library:SetSound(true)
```

Tema Light otomatis mematikan background image saat di-apply lewat `Themes.Apply()`.
