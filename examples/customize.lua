--[[
  CONTOH CUSTOMIZE — ganti tema, font, background, icon
]]

local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"

local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()

-- ── Pilih preset tema ──
Library:SetTheme(Themes.Neon)
-- Tersedia: Dark, Neon, Cyberpunk, BloodRed, Gold, Purple, Ocean, Light, Matrix, Sunset

-- ── Atau bikin sendiri ──
-- Library:SetTheme({
--   Primary    = Color3.fromRGB(0, 170, 255),
--   Background = Color3.fromRGB(15, 15, 20),
--   Secondary  = Color3.fromRGB(30, 30, 40),
-- })

-- ── Ganti font ──
Library:SetFont({
  Bold    = Enum.Font.GothamBold,
  Regular = Enum.Font.Gotham,
})

-- ── Ganti icon floating ──
local Cfg = Library:GetConfig()
Cfg.Assets.FloatingButton = "rbxassetid://91115084979317"

-- ── Ganti background image ──
Cfg.Window.BackgroundImage        = "rbxassetid://7838809599"
Cfg.Window.BackgroundTransparency = 0.55
Cfg.Window.BackgroundTint         = Color3.fromRGB(0, 0, 0)
Cfg.Window.BackgroundTintTrans    = 0.3

-- ── Bikin window ──
local Window = Library:CreateWindow({
  Title    = "Custom UI",
  Description = "v1.0",
  TabWidth = 100,
  SizeUi   = UDim2.fromOffset(450, 300),
})

local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local S = Tab:AddSection("Test", true)

S:AddToggle({ Title = "Contoh", Default = false, Callback = function(v) print(v) end })
