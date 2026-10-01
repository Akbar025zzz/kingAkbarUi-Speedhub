-- 04-auto-save.lua — wrapper FuncsV3 + simpan config ke file JSON
local Http = game:GetService("HttpService")
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib     = loadstring(game:HttpGet(BASE .. "init.lua"))()
local FuncsV3 = loadstring(game:HttpGet(BASE .. "wrapper.lua"))()

local FILE = "kingakbar_autosave.json"
local cfg = {}
if isfile and isfile(FILE) then
	local ok, data = pcall(readfile, FILE)
	if ok then pcall(function() cfg = Http:JSONDecode(data) end) end
end
FuncsV3:SetTable(cfg, function(t)
	if writefile then writefile(FILE, Http:JSONEncode(t)) end
end)

local Win = Lib:CreateWindow({ "Auto Save", "config tersimpan", 112, UDim2.fromOffset(460, 300) })
local Tab = Win:CreateTab({ "Settings" })
local Sec = Tab:AddSection("Tersimpan otomatis", true)

FuncsV3:Toggle(Sec, "Auto Farm", "boolean", "Save", function(v) print(v) end)
FuncsV3:Slider(Sec, "WalkSpeed", "number", 16, 200, "Save", function(v) end)
FuncsV3:Dropdown(Sec, "Mode", "string", false, { "Normal", "Turbo" }, "Save", function(v) end)
FuncsV3:Textbox(Sec, "Username", "string", "Save", function(t) end)
FuncsV3:ColorPicker(Sec, "ESP Color", "hex", "Save", function(c) end)
FuncsV3:Keybind(Sec, "Fly Hotkey", "keycode", "Save", function() print("fly") end)

Lib:Notify({ "Auto Save", "Aktif", "Semua perubahan otomatis tersimpan." })
