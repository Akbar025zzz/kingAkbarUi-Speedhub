-- Contoh dasar King Akbar UI v1.6
local Lib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

local Win = Lib:CreateWindow({ "King Akbar", "v1.6", 100, UDim2.fromOffset(420, 280) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("Farm", true)

Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print("Auto Farm:", v) end })
Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print("WalkSpeed:", v) end })
Sec:AddDropdown({ "Mode", "", false, { "A", "B" }, { "A" }, function(v) print("Mode:", v[1]) end })
Sec:AddButton({ Title = "Halo", Callback = function() print("Halo!") end })

Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
