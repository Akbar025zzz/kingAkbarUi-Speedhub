-- 06-full-hub.lua — contoh hub lengkap: wrapper + themes + auto-save
local Http = game:GetService("HttpService")
local Players = game:GetService("Players")
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib     = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()
local FuncsV3 = loadstring(game:HttpGet(BASE .. "wrapper.lua"))()

local FILE = "menghub.json"
local cfg = {}
if isfile and isfile(FILE) then
	local ok, d = pcall(readfile, FILE)
	if ok then pcall(function() cfg = Http:JSONDecode(d) end) end
end
FuncsV3:SetTable(cfg, function(t) if writefile then writefile(FILE, Http:JSONEncode(t)) end end)
FuncsV3:ApplySavedTheme(Lib, Themes, "Violet") -- theme tersimpan, sebelum CreateWindow

local Win = Lib:CreateWindow({ "Meng Hub", "Fish It", 112, UDim2.fromOffset(460, 300), true, true })
Win:AddBadge("v1.5")

local function hum()
	local c = Players.LocalPlayer.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local Farm = Win:CreateTab({ "Farm", "rbxassetid://7734010488" })
local s1 = Farm:AddSection("Fishing", true)
FuncsV3:Toggle(s1, "Auto Farm", "tangkap otomatis", "Save", function(v) print("farm", v) end)
FuncsV3:Toggle(s1, "Instant Catch", "", "Save", function(v) end)
FuncsV3:Slider(s1, "Catch Delay", "detik", 0, 5, "Save", function(v) end, 0.1)

local Plr = Win:CreateTab({ "Player" })
local s2 = Plr:AddSection("Stats", true)
FuncsV3:Slider(s2, "WalkSpeed", "", 16, 200, "Save", function(v)
	local h = hum() if h then h.WalkSpeed = v end
end)
FuncsV3:Slider(s2, "JumpPower", "", 50, 200, "Save", function(v)
	local h = hum() if h then h.JumpPower = v end
end)
FuncsV3:ColorPicker(s2, "ESP Color", "", "Save", function(c) print("esp", c) end)
FuncsV3:Keybind(s2, "Fly Hotkey", "", "Save", function() print("fly toggled") end)

local Set = Win:CreateTab({ "Settings" })
local s3 = Set:AddSection("Preferences", true)
FuncsV3:ThemePicker(s3, Lib, Themes, function(name)
	Lib:Notify({ "Theme", "Disimpan", "'" .. name .. "' aktif di execute berikutnya." })
end)
FuncsV3:Button(s3, "Close UI", "", function() Win:Hide() end)
