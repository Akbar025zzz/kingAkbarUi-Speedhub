--[[
  CONTOH LANJUTAN
  - banyak tab & section, panel, color picker, keybind
  - dropdown dinamis (Refresh), kontrol item lewat kode (Set / SetVisible / SetTitle)
  - notifikasi, kontrol window (Hide/Show/Toggle/Destroy)
]]

local KA = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/loader.lua"))()
local Library, Themes = KA.Library, KA.Themes
local Players = game:GetService("Players")

Library:SetTheme(Themes.Dark)

local Window = Library:CreateWindow({
  Title = "King Akbar", Description = "Advanced",
  Search = true, Profile = true,
})
Window:AddBadge("Advanced")

local Main   = Window:CreateTab({ "Main" })
local Visual = Window:CreateTab({ "Visual" })
local System = Window:CreateTab({ "System" })

-- ═══════════ Main ═══════════
local Control = Main:AddSection("Kontrol", true)

local Speed = Control:AddSlider({ Title = "Speed", Content = "Bisa diubah lewat kode",
  Increment = 1, Min = 1, Max = 100, Default = 20, Callback = function(v) print("Speed", v) end })

local Enabled = Control:AddToggle({ Title = "Enable", Default = false, Callback = function(v)
  -- menampilkan/menyembunyikan item lain mengikuti toggle
  Speed:SetVisible(v)
end })

Control:AddButton({ Title = "Set Speed = 50", Content = "Mengubah slider lewat kode",
  Callback = function() Speed:Set(50, true) end }) -- true = panggil callback

Control:AddSeperator({ Title = "Dropdown dinamis" })

local PlayerList = Control:AddDropdown({ Title = "Pemain", Content = "Daftar diperbarui otomatis",
  Options = {}, Default = {}, Callback = function(v) print("Pemain:", v[1]) end })

local function RefreshPlayers()
  local names = {}
  for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
  PlayerList:Refresh(names, {})
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(function() task.defer(RefreshPlayers) end)

local Quick = Main:AddSection("Aksi Cepat", false)
local Panel = Quick:AddPanel({ Title = "Panel", Content = "Klik untuk membuka" })
Panel:AddButton({ Title = "Aksi 1", Callback = function() print("Aksi 1") end })
Panel:AddToggle({ Title = "Opsi", Default = true, Callback = function(v) print("Opsi", v) end })

-- ═══════════ Visual ═══════════
local Colors = Visual:AddSection("Warna", true)
Colors:AddColorPicker({ Title = "ESP Color", Content = "Klik swatch",
  Default = Color3.fromRGB(0, 170, 255), Callback = function(c) print("ESP", c) end })
Colors:AddColorPicker({ Title = "Outline", Default = Color3.fromRGB(255, 255, 255),
  Callback = function(c) print("Outline", c) end })

-- ═══════════ System ═══════════
local Sys = System:AddSection("Sistem", true)

Sys:AddKeybind({ Title = "Hotkey Enable", Content = "Tekan untuk menyalakan/mematikan",
  Default = "E", Callback = function() Enabled:Set(not Enabled.Value) end })

Sys:AddButton({ Title = "Notifikasi x3", Callback = function()
  for i = 1, 3 do
    Library:SetNotification({ "Tes " .. i, "•", "Notifikasi bertumpuk", nil, 0.4, 4 })
  end
end })

Sys:AddButton({ Title = "Sembunyikan 3 detik", Content = "Window muncul lagi otomatis",
  Callback = function()
    Window:Hide()
    task.delay(3, function() Window:Show() end)
  end })

Sys:AddButton({ Title = "Tutup UI", Content = "Menghapus UI & semua koneksi",
  Callback = function() Window:Destroy() end })
