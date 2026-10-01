-- 05-dynamic-dropdown.lua — dropdown yang option-nya berubah saat runtime
local Players = game:GetService("Players")
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib = loadstring(game:HttpGet(BASE .. "init.lua"))()

local Win = Lib:CreateWindow({ "Dynamic", "dropdown live", 112, UDim2.fromOffset(460, 300) })
local Tab = Win:CreateTab({ "Live" })
local Sec = Tab:AddSection("Player & Filter", true)

local function names()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do table.insert(out, p.Name) end
	table.sort(out)
	return out
end

-- 1) dropdown daftar player, auto-refresh saat join/leave
local ddPlayer = Sec:AddDropdown({
	Title = "Target Player", Content = "auto refresh",
	Options = names(), Callback = function(v) print("target:", v[1]) end,
})
local function refresh() ddPlayer:Refresh(names(), ddPlayer.Value) end
Players.PlayerAdded:Connect(function() task.delay(0.2, refresh) end)
Players.PlayerRemoving:Connect(function() task.delay(0.2, refresh) end)
Sec:AddButton({ Title = "Refresh Now", Content = "paksa muat ulang daftar", Callback = refresh })

-- 2) multi-select + tambah option on-the-fly
local ddFruit = Sec:AddDropdown({
	Title = "Fruit Filter", Content = "multi + add option",
	Multi = true, Options = { "Apple", "Banana", "Cherry" },
	Callback = function(v) print("filter:", table.concat(v, ", ")) end,
})
Sec:AddButton({ Title = "Add 'Dragon'", Callback = function() ddFruit:AddOption("Dragon") end })
Sec:AddButton({ Title = "Reset Filter", Callback = function() ddFruit:Set({}) end })
