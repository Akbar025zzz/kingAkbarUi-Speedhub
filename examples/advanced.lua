--[[
┌────────────────────────────────────────────────────────┐
│  CONTOH 04: ADVANCED — SEMUA KOMPONEN                  │
│  Showcase semua item yang tersedia di library.         │
│  Butuh init.lua v1.5+ untuk ColorPicker & Keybind.     │
└────────────────────────────────────────────────────────┘
]]

local Players = game:GetService("Players")

-- Load library lengkap
local UI = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/loader.lua"
))()

-- ─────────── WINDOW ───────────
local Win = UI.Lib:CreateWindow({
	Title       = "Advanced Showcase",
	Description = "semua komponen library",
	TabWidth    = 112,
	SizeUi      = UDim2.fromOffset(480, 330),
	Search      = true,
	Profile     = true,
})

Win:AddBadge("v1.5")
Win:AddBadge("Showcase")

-- ─────────── TAB 1: KONTROL DASAR ───────────
local Basic = Win:CreateTab({ "Basic", "rbxassetid://7734010488" })

local s1 = Basic:AddSection("Informasi", true)
s1:AddParagraph({
	"Advanced Showcase",
	"Contoh ini menampilkan SEMUA item yang tersedia di library."
})
s1:AddSeperator({ "Visual Elements" })
s1:AddLine()

local s2 = Basic:AddSection("Kontrol Dasar", true)

s2:AddButton({
	"Klik Aku",
	"Tombol dengan ikon",
	"rbxassetid://16932740082",
	function()
		UI.Lib:Notify({ "Button", "Diklik!", "Tombol berfungsi dengan baik." })
	end
})

s2:AddToggle({
	"Auto Farm",
	"iOS style 40x20",
	false,
	function(v) print("toggle:", v) end
})

s2:AddSlider({
	Title     = "WalkSpeed",
	Content   = "kotak nilai + track",
	Min       = 16,
	Max       = 200,
	Default   = 50,
	Increment = 1,
	Callback  = function(v) print("speed:", v) end
})

s2:AddInput({
	Title    = "Username",
	Content  = "ketik teks bebas",
	Default  = "Akbar",
	Callback = function(t) print("input:", t) end
})

s2:AddDropdown({
	Title    = "Mode",
	Content  = "single select",
	Multi    = false,
	Options  = { "Normal", "Turbo", "Extreme" },
	Default  = { "Normal" },
	Callback = function(v) print("dropdown:", v[1]) end
})

s2:AddDropdown({
	Title    = "Warna Favorit",
	Content  = "multi select",
	Multi    = true,
	Options  = { "Red", "Green", "Blue", "Yellow", "Purple" },
	Callback = function(v) print("multi:", table.concat(v, ", ")) end
})

-- ─────────── TAB 2: KOMPONEN LANJUTAN (butuh v1.5+) ───────────
local Adv = Win:CreateTab({ "Advanced" })

local s3 = Adv:AddSection("Komponen Baru v1.5", true)

-- ColorPicker (swatch 48x22)
local ok1, cp = pcall(function()
	return s3:AddColorPicker({
		Title    = "ESP Color",
		Content  = "klik swatch untuk buka panel RGB",
		Default  = Color3.fromRGB(168, 120, 255),
		Callback = function(c) print("warna:", c) end
	})
end)
if not ok1 then
	s3:AddParagraph({ "ColorPicker", "Butuh init.lua v1.5+ untuk fitur ini." })
end

-- Keybind (64x22)
local ok2, kb = pcall(function()
	return s3:AddKeybind({
		Title    = "Fly Hotkey",
		Content  = "klik kotak lalu tekan tombol",
		Default  = Enum.KeyCode.F,
		Callback = function()
			UI.Lib:Notify({ "Keybind", "Aktif", "Hotkey F ditekan!" })
		end,
		OnChange = function(k)
			print("bind baru:", k.Name)
		end
	})
end)
if not ok2 then
	s3:AddParagraph({ "Keybind", "Butuh init.lua v1.5+ untuk fitur ini." })
end

-- ─────────── PANEL (item dalam item) ───────────
local s4 = Adv:AddSection("Panel", true)
local Panel = s4:AddPanel({
	"Sub Menu",
	"klik untuk memperluas"
})
Panel:AddButton({ "Sub Button 1", function() print("sub 1") end })
Panel:AddButton({ "Sub Button 2", function() print("sub 2") end })
Panel:AddToggle({ "Sub Toggle", false, function(v) print("sub toggle:", v) end })

-- ─────────── TAB 3: DROPDOWN LIVE ───────────
local Live = Win:CreateTab({ "Live" })
local s5 = Live:AddSection("Dropdown Dinamis", true)

-- Dropdown daftar player (auto refresh)
local ddPlayer = s5:AddDropdown({
	Title    = "Target Player",
	Content  = "auto refresh saat player join/leave",
	Options  = {},
	Callback = function(v) print("target:", v[1]) end
})

local function refreshPlayers()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(names, p.Name)
	end
	table.sort(names)
	ddPlayer:Refresh(names, ddPlayer.Value)
end
refreshPlayers()

Players.PlayerAdded:Connect(function()
	task.delay(0.3, refreshPlayers)
end)
Players.PlayerRemoving:Connect(function()
	task.delay(0.3, refreshPlayers)
end)

s5:AddButton({
	Title    = "Refresh Manual",
	Content  = "paksa muat ulang daftar player",
	Callback = refreshPlayers
})

-- Dropdown dengan option tambahan on-the-fly
local ddFruit = s5:AddDropdown({
	Title    = "Fruit Filter",
	Content  = "tambah option via tombol",
	Multi    = true,
	Options  = { "Apple", "Banana", "Cherry" },
	Callback = function(v) print("fruit:", table.concat(v, ", ")) end
})

s5:AddButton({
	Title    = "Add 'Dragon Fruit'",
	Content  = "tambah option baru",
	Callback = function()
		ddFruit:AddOption("Dragon Fruit")
		UI.Lib:Notify({ "Added", "Option", "Dragon Fruit ditambahkan!" })
	end
})

-- ─────────── TAB 4: STRESS TEST ───────────
local Stress = Win:CreateTab({ "Stress" })

for i = 1, 5 do
	local sec = Stress:AddSection("Section " .. i, i == 1)
	for j = 1, 3 do
		sec:AddToggle({
			"Item " .. i .. "." .. j,
			"stress test scroll & layout",
			false,
			function() end
		})
	end
end

-- ─────────── NOTIFIKASI PEMBUKA ───────────
UI.Lib:Notify({
	"Advanced",
	"Showcase",
	"Semua komponen library berhasil dimuat. Jelajahi setiap tab!"
})
