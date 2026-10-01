--[[
  CONTOH SEMUA KOMPONEN — King Akbar UI
]]

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

local Window = Library:CreateWindow({
  Title       = "Advanced",
  Description = "v2.0",
  SizeUi      = UDim2.fromOffset(500, 350),
})

local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local S = Tab:AddSection("Semua Komponen", true)

-- Paragraph
S:AddParagraph({ Title = "Header", Content = "Deskripsi panjang di sini" })

-- Seperator
S:AddSeperator({ Title = "Controls" })

-- Button
S:AddButton({
  Title    = "Klik Aku",
  Content  = "Contoh button",
  Callback = function() print("clicked") end,
})

-- Toggle
S:AddToggle({
  Title    = "Auto Farm",
  Content  = "Farming otomatis",
  Default  = false,
  Callback = function(v) print("Toggle:", v) end,
})

-- Slider
S:AddSlider({
  Title    = "WalkSpeed",
  Content  = "Kecepatan jalan",
  Min      = 16,
  Max      = 200,
  Default  = 16,
  Callback = function(v) print("Speed:", v) end,
})

-- Input
S:AddInput({
  Title    = "Player Name",
  Content  = "Target player",
  Default  = "",
  Callback = function(v) print("Input:", v) end,
})

-- Dropdown Single
S:AddDropdown({
  Title    = "Select Weapon",
  Content  = "Pilih senjata",
  Multi    = false,
  Options  = { "Sword", "Gun", "Bow", "Magic" },
  Default  = { "Sword" },
  Callback = function(v) print("Selected:", v[1]) end,
})

-- Dropdown Multi
S:AddDropdown({
  Title    = "Multi Select",
  Content  = "Pilih banyak",
  Multi    = true,
  Options  = { "A", "B", "C", "D", "E" },
  Default  = {},
  Callback = function(v) print(table.concat(v, ", ")) end,
})

-- Line
S:AddLine()

-- Panel
local Panel = S:AddPanel({
  Title   = "Advanced Options",
  Content = "Klik untuk buka",
})

Panel:AddButton({ Title = "Reset Character", Callback = function()
  game.Players.LocalPlayer.Character:BreakJoints()
end })

Panel:AddToggle({ Title = "Auto Heal", Default = false, Callback = function(v)
  print("Auto Heal:", v)
end })
