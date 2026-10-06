-- Contoh GroupBox (King Akbar UI v1.7)
local Lib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

local Win = Lib:CreateWindow({ "King Akbar", "GroupBox demo", 100, UDim2.fromOffset(420, 280) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })

-- 1) Kotak sederhana
local Info = Tab:AddGroupBox("Info")
Info:AddParagraph({ "Halo", "Ini GroupBox biasa, selalu terbuka." })

-- 2) Collapsible
local Farm = Tab:AddGroupBox({ Title = "Farming", Collapsible = true, Open = true })
Farm:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print("Farm:", v) end })
Farm:AddSlider({ "Delay", "", 1, 0, 10, 1, function(v) print("Delay:", v) end })

-- 3) Daftar panjang dengan scroll sendiri (MaxHeight)
local Long = Tab:AddGroupBox({ Title = "Daftar Panjang", Collapsible = true, Open = false, MaxHeight = 140 })
for i = 1, 12 do
  Long:AddToggle({ "Opsi " .. i, "", false, function(v) print("Opsi", i, v) end })
end

-- 4) API standar
local conn = Farm:OnChanged(function(terbuka)
  print("Farming terbuka:", terbuka)
end)

Farm:SetValue(false)        -- tutup (memanggil OnChanged)
Farm:SetValue(true, false)  -- buka tanpa memanggil OnChanged
print(Farm:GetValue())      --> true
Farm:SetTitle("Farming v2")

-- conn:Disconnect()   -- lepas listener
-- Farm:SetVisible(false)
-- Farm:Destroy()
