--[[
  CONTOH PAKAI WRAPPER + AUTO-SAVE
]]

local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"

local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local FuncsV3 = loadstring(game:HttpGet(BASE .. "wrapper.lua"))()

-- Setup save path
getgenv().KingAkbarConfig = getgenv().KingAkbarConfig or {}
FuncsV3:SetTable(getgenv().KingAkbarConfig, function(cfg)
  print("[Save] Config updated")
  -- (opsional) simpan ke file:
  -- if writefile then
  --   writefile("kingakbar_config.json", game:GetService("HttpService"):JSONEncode(cfg))
  -- end
end)

local Window = Library:CreateWindow({ Title = "With Save", Description = "v1.0" })
local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local S = Tab:AddSection("Farming", true)

-- Pakai wrapper (auto-save)
FuncsV3:Toggle(S, "Auto Farm", "Farming otomatis", "Save", function(v)
  print("Auto Farm:", v)
end)

FuncsV3:Button(S, "Reset Character", "Klik untuk reset", function()
  local char = game.Players.LocalPlayer.Character
  if char then char:BreakJoints() end
end)

FuncsV3:Dropdown(S, "Weapon", "Pilih senjata", false,
  { "Sword", "Gun", "Bow", "Magic" },
  "Save",
  function(v)
    print("Weapon:", v[1])
  end
)

FuncsV3:Textbox(S, "Player Name", "Target player", "Save", function(v)
  print("Target:", v)
end)

FuncsV3:Slider(S, "WalkSpeed", "Kecepatan", 16, 200, "Save", function(v)
  local char = game.Players.LocalPlayer.Character
  if char and char:FindFirstChildOfClass("Humanoid") then
    char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
  end
end)
