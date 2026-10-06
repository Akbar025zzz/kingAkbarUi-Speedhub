-- Contoh TabBox (King Akbar UI v1.6)
local Lib = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

local Win = Lib:CreateWindow({ "King Akbar", "TabBox demo", 100, UDim2.fromOffset(420, 280) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })

-- 1) Buat TabBox (Swipe = true: geser kiri/kanan di HP untuk pindah halaman)
local Box = Tab:AddTabBox({
  Tabs    = { "Farm", "Combat", "Misc" },
  Default = "Farm",
  Swipe   = true,
})

-- 2) Isi tiap halaman dengan komponen biasa
local Farm = Box:GetTab("Farm")
Farm:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print("Farm:", v) end })
Farm:AddSlider({ "Delay", "", 1, 0, 10, 1, function(v) print("Delay:", v) end })

local Combat = Box:GetTab("Combat")
Combat:AddDropdown({ "Mode", "", false, { "A", "B" }, { "A" }, function(v) print("Mode:", v[1]) end })

local Misc = Box:GetTab("Misc")
Misc:AddButton({
  Title    = "Tes Notifikasi",
  Callback = function()
    Lib:SetNotification({ "King Akbar", "TabBox", "Halaman aktif: " .. tostring(Box:GetValue()) })
  end,
})

-- 3) Halaman bisa juga ditambah belakangan
local Extra = Box:AddTab("Extra")
Extra:AddParagraph({ "Info", "Halaman ini dibuat lewat Box:AddTab()" })

-- 4) API standar
local conn = Box:OnChanged(function(nama, index)
  print("Pindah ke:", nama, index)
end)

Box:SetValue("Combat")          -- pindah halaman (memanggil OnChanged)
Box:SetValue(1, false)          -- pindah tanpa memanggil OnChanged
print(Box:GetValue())           --> "Farm"

Extra:SetVisible(false)         -- sembunyikan tombol halaman
-- Extra:Destroy()              -- hapus halaman
-- conn:Disconnect()            -- lepas listener
-- Box:SetVisible(false)        -- sembunyikan seluruh TabBox
-- Box:Destroy()                -- hapus TabBox + semua koneksinya
