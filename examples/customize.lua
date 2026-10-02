--[[
┌────────────────────────────────────────────────────────┐
│  CONTOH 03: CUSTOMIZE TAMPILAN                         │
│  Ganti tema, font, background, ukuran window, dan      │
│  perilaku library secara manual via GetConfig().       │
└────────────────────────────────────────────────────────┘
]]

-- Load library + themes (manual, tanpa loader)
local Lib    = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/init.lua"
))()
local Themes = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/themes.lua"
))()

-- ─────────── 1. GANTI TEMA (WAJIB sebelum CreateWindow) ───────────
-- Bisa pakai preset:
Themes.Apply(Lib, "Violet")

-- Atau custom manual:
-- Lib:SetTheme({
--     Primary   = Color3.fromRGB(255, 100, 200),
--     Background = Color3.fromRGB(20, 10, 30),
-- })

-- ─────────── 2. GANTI FONT ───────────
Lib:SetFont({
	Bold    = Enum.Font.GothamBlack,
	Regular = Enum.Font.Gotham,
})

-- ─────────── 3. GANTI CONFIG WINDOW ───────────
local cfg = Lib:GetConfig()
cfg.Window.Size = UDim2.fromOffset(500, 350)            -- ukuran window
cfg.Window.CornerRadius = 12                            -- sudut lebih bulat
cfg.Window.BackgroundImage = "rbxassetid://110409843085547" -- gambar latar
cfg.Window.BackgroundTransparency = 0.4                 -- lebih buram
cfg.Window.BackgroundTint = Color3.fromRGB(80, 40, 120) -- tint ungu
cfg.Window.BackgroundTintTrans = 0.5

-- ─────────── 4. MATIKAN ANTI-AFK (kalau mau) ───────────
cfg.Behavior.AntiAFK = false

-- ─────────── 5. GANTI ASSET (opsional) ───────────
cfg.Assets.FloatingButton = "rbxassetid://91115084979317"

-- ─────────── 6. BARU BIKIN WINDOW ───────────
local Win = Lib:CreateWindow({
	Title       = "Custom Hub",
	Description = "full kustomisasi",
	TabWidth    = 120,
	SizeUi      = UDim2.fromOffset(500, 350),
	Search      = true,
	Profile     = true,
	Logo        = "rbxassetid://7734010488",
	HideName    = false,  -- tampilkan nama lengkap (jangan sensor)
})

-- Tambah badge
Win:AddBadge("Custom")
Win:AddBadge("v1.5")

-- Tab demo
local Tab = Win:CreateTab({ "Demo" })
local Sec = Tab:AddSection("Hasil Kustomisasi", true)

Sec:AddParagraph({
	"Tampilan dikustom",
	"Tema Violet · Font GothamBlack · Corner 12px · Background custom"
})
Sec:AddToggle({ "Test Toggle", "Coba klik", false, function(v) end })
Sec:AddSlider({ "Test Slider", "", 1, 0, 100, 50, function(v) end })

-- Tab tema (ganti tema live dengan rebuild window)
local ThemeTab = Win:CreateTab({ "Ganti Tema" })
local TSec = ThemeTab:AddSection("Pilih Tema", true)
TSec:AddDropdown({
	Title   = "Preset Tema",
	Content = "Ganti tema & rebuild window",
	Multi   = false,
	Options = Themes.Names(),
	Default = { "Violet" },
	Callback = function(v)
		local name = v[1]
		if name then
			if getgenv then getgenv().DemoTheme = name end
			Win:Destroy()
			-- Rebuild dengan tema baru (script execute ulang)
			Themes.Apply(Lib, name)
			-- Di real script, kamu load ulang script-nya.
			-- Di sini kita cukup kasih notif
			Lib:Notify({ "Theme", "Diubah", "'"..name.."' aktif di execute berikutnya." })
		end
	end,
})

Lib:Notify({ "Custom", "Loaded", "Semua kustomisasi diterapkan!" })
