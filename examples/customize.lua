--[[
  ╔══════════════════════════════════════════════════╗
  ║   KING AKBAR UI — CONTOH 3: CUSTOMIZE            ║
  ║   github.com/Akbar025zzz/kingAkbarUi-Speedhub    ║
  ╚══════════════════════════════════════════════════╝

  Kustomisasi: tema, font, background, icon.

  Baru di v2.0:
  • TEMA BISA DIGANTI SETELAH CreateWindow (runtime!)
  • 27 tema preset + Themes.Apply/Lis/Generate/Register
  • Tema Light otomatis matikan background image
]]

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
local Themes = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/themes.lua"
))()

-- ═══ CUSTOM SEBELUM WINDOW (cara lama, masih jalan) ═══
Library:SetTheme({
  Primary    = Color3.fromRGB(0, 170, 255),
  Background = Color3.fromRGB(20, 20, 25),
  Secondary  = Color3.fromRGB(35, 35, 45),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(150, 150, 150),
  Stroke     = Color3.fromRGB(60, 60, 70),
})

Library:SetFont({
  Bold    = Enum.Font.FredokaOne,
  Regular = Enum.Font.Gotham,
})

local Cfg = Library:GetConfig()
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.5
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3
Cfg.Assets.FloatingButton         = "rbxassetid://91115084979317"

-- ═══ WINDOW (dengan Search + Profile + Logo!) ═══
local Window = Library:CreateWindow({
  Title    = "Customize Demo",
  Logo     = "rbxassetid://7734010488",   -- icon di sebelah judul
  Search   = true,                         -- kolom search di daftar tab
  Profile  = true,                         -- avatar + "Welcome, abc***"
  HideName = true,                         -- sensor nama user
  SizeUi   = UDim2.fromOffset(500, 320),
})

-- ═══ DEMO RUNTIME THEME SWITCHER — fitur utama v2.0! ═══
local TabTheme = Window:CreateTab({ "Theme", "rbxassetid://7734010488" })
local SecTheme = TabTheme:AddSection("Tema", true)

-- Dropdown 27 tema — ganti LANGSUNG tanpa rejoin!
SecTheme:AddDropdown({
  Title    = "Preset Tema",
  Content  = "Real-time theme switching",
  Multi    = false,
  Options  = Themes.DropdownOptions(),
  Default  = "Dark",
  Callback = function(name)
    local ok = Themes.Apply(Library, name)
    if ok then
      Library:SetNotification({
        Title = "Theme", Description = "Applied", Content = name .. " aktif!"
      })
    end
  end,
})

-- Random theme (tidak berulang 2x)
SecTheme:AddButton({
  Title   = "Random Theme",
  Content = "Tema acak",
  Callback = function()
    local name = Themes.Random(Library)
    Library:SetNotification({
      Title = "Random", Description = "Applied", Content = "Tema: " .. tostring(name)
    })
  end,
})

-- Register tema custom dari 1 warna → langsung masuk daftar!
SecTheme:AddColorPicker({
  Title   = "Custom Primary",
  Content = "Generate tema dari 1 warna",
  Default = Color3.fromRGB(120, 80, 255),
  Callback = function(color)
    if not Themes.Get("MyCustom") then
      Themes.Register("MyCustom", color)
    else
      Themes.Register("MyCustom", color) -- overwrite
    end
    Themes.Apply(Library, "MyCustom")
  end,
})

-- ═══ BACKGROUND IMAGE SWITCHER ═══
local SecBg = TabTheme:AddSection("Background", false)

SecBg:AddToggle({
  Title   = "Background Image",
  Default = true,
  Callback = function(state)
    Library:GetConfig().Window.BackgroundImage = state
      and "rbxassetid://7838809599" or ""
  end,
})

SecBg:AddSlider({
  Title    = "Image Transparency",
  Content  = "0 = pekat, 1 = hilang",
  Min      = 0, Max = 1, Increment = 0.05, Default = 0.5,
  Callback = function(v)
    Library:GetConfig().Window.BackgroundTransparency = v
  end,
})

-- ═══ FONT SWITCHER ═══
local SecFont = TabTheme:AddSection("Font", false)

SecFont:AddDropdown({
  Title   = "Bold Font",
  Multi   = false,
  Options = { "GothamBold", "FredokaOne", "Bangers", "GothamBlack" },
  Default = "GothamBold",
  Callback = function(name)
    Library:SetFont({ Bold = Enum.Font[name] })
  end,
})

-- ═══ SOUND SETTINGS ═══
local SecSound = TabTheme:AddSection("Sound", false)

SecSound:AddToggle({
  Title   = "Sound Effects",
  Default = false,
  Callback = function(v)
    Library:SetSound(v)
  end,
})

print("[Customize] Tersedia", Themes.Count(), "tema:", table.concat(Themes.List(), ", "))
