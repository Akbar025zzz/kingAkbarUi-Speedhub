-- 02-all-components.lua — menampilkan SEMUA komponen library (init v1.5+)
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib = loadstring(game:HttpGet(BASE .. "init.lua"))()

local Win = Lib:CreateWindow({
	Title = "Showcase", Description = "semua komponen",
	TabWidth = 112, SizeUi = UDim2.fromOffset(470, 320),
	Search = true, Profile = true,
})
Win:AddBadge("v1.5")
Win:AddBadge("Showcase")

local Tab = Win:CreateTab({ "Components", "rbxassetid://7734010488" })

local Info = Tab:AddSection("Info", true)
Info:AddParagraph({ "Selamat datang", "Contoh ini menampilkan semua item yang tersedia." })
Info:AddSeperator({ "Visual" })
Info:AddLine()

local Basic = Tab:AddSection("Basic", true)
Basic:AddButton({ "Button", "Klik untuk notifikasi", "rbxassetid://16932740082", function()
	Lib:Notify({ "Button", "Klik!", "Tombol berfungsi dengan baik." })
end })
Basic:AddToggle({ "Toggle", "iOS style 40x20", false, function(v) print("toggle", v) end })
Basic:AddSlider({ Title = "Slider", Content = "kotak nilai + track",
	Min = 0, Max = 100, Default = 25, Increment = 1, Callback = function(v) end })
Basic:AddInput({ Title = "Input", Content = "teks bebas", Default = "", Callback = function(t) end })
Basic:AddDropdown({ Title = "Dropdown", Content = "single select",
	Multi = false, Options = { "A", "B", "C" }, Default = { "A" }, Callback = function(v) end })
Basic:AddDropdown({ Title = "Multi", Content = "multi select",
	Multi = true, Options = { "Red", "Green", "Blue" }, Callback = function(v) end })

local Adv = Tab:AddSection("Advanced", true)
Adv:AddColorPicker({ Title = "ColorPicker", Content = "swatch 48x22",
	Default = Color3.fromRGB(168, 120, 255), Callback = function(c) print(c) end })
Adv:AddKeybind({ Title = "Keybind", Content = "64x22, tekan untuk bind",
	Default = Enum.KeyCode.F,
	Callback = function() print("hotkey ditekan") end,
	OnChange = function(k) print("bind baru:", k) end })
local Panel = Adv:AddPanel({ "Panel", "bisa diperluas" })
Panel:AddButton({ "Sub Button", function() print("sub") end })
Panel:AddToggle({ "Sub Toggle", false, function(v) end })

local Tab2 = Win:CreateTab({ "Kedua" }) -- untuk demo tab search
Tab2:AddSection("Kosong", false):AddParagraph({ "Tab kedua", "Coba kolom Search di sidebar." })
