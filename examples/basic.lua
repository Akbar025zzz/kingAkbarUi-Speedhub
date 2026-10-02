--[[
┌────────────────────────────────────────────────────────┐
│  CONTOH 01: BASIC SETUP                                │
│  Paling simpel, cocok untuk pemula.                    │
└────────────────────────────────────────────────────────┘
]]

-- Load library (1 baris, tarik semua file sekaligus)
local UI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/loader.lua"
))()

-- Buat window
local Win = UI.Lib:CreateWindow({
	"My First Hub",          -- judul
	"v1.0",                  -- deskripsi
	112,                     -- lebar sidebar
	UDim2.fromOffset(460, 300) -- ukuran window
})

-- Buat tab
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })

-- Buat section (terbuka secara default)
local Sec = Tab:AddSection("Features", true)

-- Toggle sederhana
Sec:AddToggle({
	"Auto Farm",
	"Farm otomatis tanpa henti",
	false,
	function(value)
		print("Auto Farm:", value and "ON" or "OFF")
	end
})

-- Slider
Sec:AddSlider({
	"WalkSpeed",
	"Kecepatan jalan",
	1,    -- increment
	16,   -- min
	200,  -- max
	16,   -- default
	function(value)
		print("WalkSpeed:", value)
	end
})

-- Notifikasi pembuka
UI.Lib:Notify({ "Welcome", "Basic", "Script berhasil dimuat!" })
