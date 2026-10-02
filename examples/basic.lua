--[[ CONTOH DASAR — window, 1 tab, 1 section, komponen utama ]]

local KA = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/loader.lua"))()
local Library = KA.Library

local Window = Library:CreateWindow({ Title = "King Akbar", Description = "Basic" })
local Tab    = Window:CreateTab({ "Main" })
local Section = Tab:AddSection("Contoh", true)

Section:AddParagraph({ Title = "Halo!", Content = "Ini contoh paling sederhana." })

Section:AddButton({
  Title = "Tombol", Content = "Klik untuk notifikasi",
  Callback = function()
    Library:SetNotification({ "King Akbar", "•", "Tombol ditekan", nil, 0.4, 3 })
  end,
})

Section:AddToggle({ Title = "Toggle", Default = false,
  Callback = function(v) print("Toggle:", v) end })

Section:AddSlider({ Title = "Slider", Content = "Min 0 – Max 100", Min = 0, Max = 100, Default = 50,
  Callback = function(v) print("Slider:", v) end })

Section:AddInput({ Title = "Input", Default = "",
  Callback = function(v) print("Input:", v) end })

Section:AddDropdown({ Title = "Dropdown", Options = { "A", "B", "C" }, Default = { "A" },
  Callback = function(v) print("Dropdown:", v[1]) end })
