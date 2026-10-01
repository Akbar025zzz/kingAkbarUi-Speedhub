-- 07-mega-showcase.lua — SEMUA fitur sekaligus: badge, profil, panel,
-- colorpicker, keybind, dropdown live, notifikasi, config tweak.
local Players = game:GetService("Players")
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib    = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes = loadstring(game:HttpGet(BASE .. "themes.lua"))()

Themes.Apply(Lib, "Violet")
Lib:GetConfig().Behavior.AntiAFK = true -- bisa dimatikan

local Win = Lib:CreateWindow({
	Title = "Mega Showcase", Description = "semua fitur",
	TabWidth = 112, SizeUi = UDim2.fromOffset(480, 330),
	Search = true, Profile = true,
})
Win:AddBadge("v1.5") Win:AddBadge("Mega") Win:AddBadge(getExecutor and getExecutor() or "Delta")

-- ═══ HOME ══
local Home = Win:CreateTab({ "Home", "rbxassetid://7734010488" })
local hi = Home:AddSection("Intro", true)
hi:AddParagraph({ "Mega Showcase", "Semua fitur library dalam satu window." })
hi:AddSeperator({ "Window" })
hi:AddButton({ "Notify", "notifikasi animasi", "rbxassetid://16932740082", function()
	Lib:Notify({ "Halo", "Notifikasi", "Ini konten notifikasi multi-baris yang otomatis menyesuaikan tinggi." })
end })
hi:AddButton({ "Hide Window", "muncul floating button", Callback = function() Win:Hide() end })

-- ═══ CONTROLS ═══
local Ctl = Win:CreateTab({ "Controls" })
local cb = Ctl:AddSection("Semua Item", true)
cb:AddToggle({ "Toggle", "iOS 40x20", true, function(v) end })
cb:AddSlider({ Title = "Slider", Min = 0, Max = 1000, Default = 250, Increment = 10, Callback = function(v) end })
cb:AddInput({ Title = "Input", Default = "abc", Callback = function(t) end })
cb:AddDropdown({ Title = "Multi", Multi = true, Options = { "X", "Y", "Z" }, Callback = function(v) end })
cb:AddColorPicker({ Title = "Primary Preview", Default = Color3.fromRGB(168, 120, 255), Callback = function(c) end })
cb:AddKeybind({ Title = "Hotkey", Default = Enum.KeyCode.K, Callback = function()
	Lib:Notify({ "Keybind", "Aktif", "Hotkey ditekan!" })
end })
local pn = cb:AddPanel({ "Panel", "item di dalam item" })
pn:AddButton({ "Sub Button", function() end })
pn:AddToggle({ "Sub Toggle", false, function(v) end })

-- ═══ LIVE ═══
local Live = Win:CreateTab({ "Live" })
local lv = Live:AddSection("Dropdown Dinamis", true)
local dd = lv:AddDropdown({ Title = "Players", Options = {}, Callback = function(v) end })
local function rf()
	local n = {}
	for _, p in ipairs(Players:GetPlayers()) do table.insert(n, p.Name) end
	dd:Refresh(n, dd.Value)
end
rf()
Players.PlayerAdded:Connect(function() task.delay(0.2, rf) end)
Players.PlayerRemoving:Connect(function() task.delay(0.2, rf) end)

-- ═══ STRESS (scroll + scrollbar 3px) ═══
local St = Win:CreateTab({ "Stress" })
for i = 1, 6 do
	local s = St:AddSection("Section " .. i, i == 1)
	for j = 1, 4 do
		s:AddToggle({ "Item " .. i .. "." .. j, "stress test", false, function() end })
	end
end

Lib:Notify({ "Mega", "Showcase", "Semua fitur dimuat." })
