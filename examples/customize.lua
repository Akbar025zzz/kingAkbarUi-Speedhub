--[[
  CONTOH KUSTOMISASI
  Semua pengaturan tema/font/config HARUS dilakukan SEBELUM CreateWindow.
]]

local KA = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/loader.lua"))()
local Library, Themes = KA.Library, KA.Themes

-- Tema preset: Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset, Violet
Library:SetTheme(Themes.Violet)

-- Tema buatan sendiri (sebagian key saja juga boleh)
-- Library:SetTheme({ Primary = Color3.fromRGB(255, 120, 0), Background = Color3.fromRGB(14, 12, 10) })

-- Font
Library:SetFont({ Bold = Enum.Font.GothamBold, Regular = Enum.Font.Gotham })

-- Config lanjutan
local Cfg = Library:GetConfig()
Cfg.Window.CornerRadius    = 12                      -- sudut window
Cfg.Window.TabWidth        = 120                     -- lebar sidebar (default 112)
Cfg.Window.TopbarHeight    = 44
Cfg.Window.BackgroundImage = ""                      -- kosongkan = tanpa gambar latar
-- Cfg.Window.BackgroundImage = "rbxassetid://ID"    -- atau pakai gambar sendiri
Cfg.Assets.FloatingButton  = "rbxassetid://7734010488" -- ikon tombol saat window di-minimize
Cfg.Behavior.AntiAFK       = true                    -- bisa diubah kapan saja
Cfg.Notification.Duration  = 4

local Window = Library:CreateWindow({
  Title     = "Custom UI",
  Description = "| Violet",
  Search    = true,
  Profile   = true,
  HideName  = true,                       -- nama disensor: abc***
  Logo      = "rbxassetid://7734010488",
  ToggleKey = Enum.KeyCode.RightControl,  -- hotkey buka/tutup
  -- SizeUi = UDim2.fromOffset(520, 300), -- kosongkan = otomatis sesuai layar
})

Window:AddBadge("v1.0.0")
Window:AddBadge("Executor: " .. tostring((identifyexecutor and (identifyexecutor())) or "Unknown"))

local Tab = Window:CreateTab({ "Tema" })
local Section = Tab:AddSection("Ganti Tema (butuh jalankan ulang)", true)

Section:AddParagraph({
  Title   = "Catatan",
  Content = "Tema diterapkan saat elemen dibuat. Untuk berganti tema, jalankan ulang script dengan tema lain.",
})

Section:AddColorPicker({ Title = "Contoh Warna", Default = Color3.fromRGB(168, 120, 255),
  Callback = function(c) print("Warna:", c) end })
Section:AddKeybind({ Title = "Contoh Hotkey", Default = "G",
  Callback = function(k) print("Hotkey:", k.Name) end })
