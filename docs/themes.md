# Tema & Konfigurasi

## Warna

Panggil `SetTheme` **sebelum** `CreateWindow`. Warna dibaca saat komponen dibuat, jadi elemen yang sudah tampil tidak ikut berubah.

```lua
Lib:SetTheme({
  Primary    = Color3.fromRGB(0, 170, 255),
  Background = Color3.fromRGB(10, 10, 10),
  Secondary  = Color3.fromRGB(25, 25, 25),
  Panel      = Color3.fromRGB(255, 255, 255),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(160, 160, 160),
  Stroke     = Color3.fromRGB(70, 70, 70),
  Divider    = Color3.fromRGB(80, 80, 80),
  LineColor  = Color3.fromRGB(110, 110, 110),
})
```

Field yang tidak diisi tetap memakai nilai bawaan.

## Font

```lua
Lib:SetFont({ Bold = Enum.Font.GothamBold, Regular = Enum.Font.SourceSans })
```

## Konfigurasi lain (`Lib:GetConfig()`)

```lua
local Cfg = Lib:GetConfig()
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3
Cfg.Behavior.AntiAFK              = false   -- matikan Anti-AFK
```

Panggil sebelum `CreateWindow` agar berlaku.

## Preset tema

Preset ada di `themes.lua` (file terpisah). Lihat isi file itu untuk daftar dan cara pakainya.
