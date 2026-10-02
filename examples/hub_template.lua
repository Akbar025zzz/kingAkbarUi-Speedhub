--[[
  ╔══════════════════════════════════════════════════════════╗
  ║        KING AKBAR UI — TEMPLATE HUB (copy & pakai)       ║
  ╚══════════════════════════════════════════════════════════╝

  CARA PAKAI (3 langkah):
    1. Salin seluruh file ini ke script kamu.
    2. Edit bagian  [1] PENGATURAN HUB  (nama, game, versi, tema, link).
    3. Isi logika fitur di bagian  [4] FITUR  — cari tanda "TODO".

  Tampilan: sidebar + search, footer profil, badge di topbar, section yang bisa
  dibuka/tutup, toggle iOS, slider, dropdown, keybind, color picker, tab Settings.
  Semua callback di bawah hanya contoh (print) — ganti dengan logika kamu.
]]

-- ═══════════ [1] PENGATURAN HUB (edit di sini) ═══════════
local HUB = {
  Name      = "My Hub",                      -- judul window
  Tagline   = "|  Community",                -- teks kecil di samping judul
  Game      = "Nama Game",                   -- tampil di badge kiri
  Version   = "v1.0.0",                      -- tampil di badge kiri
  Theme     = "Violet",                      -- Dark, Neon, Violet, Ocean, Light, dst. (lihat themes.lua)
  Logo      = "rbxassetid://7734010488",     -- ikon kecil di judul & tombol floating
  Discord   = "https://discord.gg/xxxxxxx",  -- link komunitas (tombol Copy di tab Info)
  ToggleKey = Enum.KeyCode.RightShift,       -- hotkey buka/tutup window (PC)
  Search    = true,                          -- kolom search di sidebar
  Profile   = true,                          -- avatar + "Welcome, nama***"
  HideName  = true,                          -- sensor nama (abc***), aman untuk screenshot
  ShowExecutor = true,                       -- badge "Executor: ..."
}

-- ═══════════ [2] LOAD LIBRARY (jangan diubah) ═══════════
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"

local Library = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes  = loadstring(game:HttpGet(BASE .. "themes.lua"))()

local function Try(Fn, ...)
  local ok, err = pcall(Fn, ...)
  if not ok then warn("[Hub] " .. tostring(err)) end
  return ok
end

-- tema & tampilan (diatur SEBELUM CreateWindow supaya aman di semua versi library)
Try(function()
  if Themes.Apply then
    Themes.Apply(Library, HUB.Theme)
  elseif Themes[HUB.Theme] then
    Library:SetTheme(Themes[HUB.Theme])
  end
end)
Try(function()
  local Cfg = Library:GetConfig()
  Cfg.Window.BackgroundImage = ""            -- tampilan bersih tanpa gambar latar
  Cfg.Assets.FloatingButton  = HUB.Logo      -- ikon tombol saat window di-minimize
end)

-- ═══════════ [3] WINDOW ═══════════
local Window = Library:CreateWindow({
  Title       = HUB.Name,
  Description = HUB.Tagline,
  Search      = HUB.Search,
  Profile     = HUB.Profile,
  HideName    = HUB.HideName,
  Logo        = HUB.Logo,
  ToggleKey   = HUB.ToggleKey,
})

if Window.AddBadge then
  Window:AddBadge(HUB.Game .. " | " .. HUB.Version)
  if HUB.ShowExecutor then
    Window:AddBadge("Executor: " .. tostring((identifyexecutor and (identifyexecutor())) or "Unknown"))
  end
end

local function Notify(Text)
  Library:SetNotification({ HUB.Name, "•", Text, nil, 0.4, 3 })
end

-- ═══════════ [4] FITUR ═══════════
-- State = tempat menyimpan nilai semua fitur. Loop/logika kamu cukup membaca State.
local State = {
  AutoFarm = false,
  Speed    = 5,
  Targets  = { "Common" },
  Color    = Color3.fromRGB(168, 120, 255),
}

local Info     = Window:CreateTab({ "Info" })
local Main     = Window:CreateTab({ "Main" })
local Visual   = Window:CreateTab({ "Visual" })
local Settings = Window:CreateTab({ "Settings" })

-- ───── Info ─────
local About = Info:AddSection("About", true)
About:AddParagraph({
  Title   = HUB.Name .. " " .. HUB.Version,
  Content = "Hub untuk " .. HUB.Game .. ". Gunakan dengan bijak.",
})
About:AddButton({
  Title = "Copy Discord", Content = "Salin link komunitas",
  Callback = function()
    if setclipboard then setclipboard(HUB.Discord) end
    Notify("Link Discord disalin")
  end,
})

-- ───── Main ─────
local Farming = Main:AddSection("Farming", true)

Farming:AddToggle({ Title = "Auto Farm", Content = "Aktifkan fitur utama", Default = false,
  Callback = function(on)
    State.AutoFarm = on
    -- TODO: jalankan / hentikan logika farm kamu di sini.
    -- Pola loop yang aman:
    --   task.spawn(function()
    --     while State.AutoFarm do
    --       -- ... logika kamu ...
    --       task.wait(0.1)
    --     end
    --   end)
    print("Auto Farm:", on)
  end })

Farming:AddSlider({ Title = "Speed", Content = "Kecepatan 1 - 10", Increment = 1, Min = 1, Max = 10, Default = State.Speed,
  Callback = function(v)
    State.Speed = v
    -- TODO: pakai State.Speed di logika kamu
  end })

Farming:AddDropdown({ Title = "Target", Content = "Pilih satu atau lebih", Multi = true,
  Options = { "Common", "Rare", "Epic", "Legendary" }, Default = State.Targets,
  Callback = function(list)
    State.Targets = list
    -- TODO: filter target dengan State.Targets
  end })

local Misc = Main:AddSection("Misc", false) -- false = tertutup di awal
Misc:AddToggle({ Title = "Auto Collect", Default = false, Callback = function(on) print("Auto Collect:", on) end })
Misc:AddInput({ Title = "Nama Target", Content = "Ketik lalu Enter", Default = "",
  Callback = function(text) print("Target:", text) end })
Misc:AddKeybind({ Title = "Hotkey Farm", Content = "Klik lalu tekan tombol", Default = Enum.KeyCode.E,
  Callback = function(key) print("Hotkey:", key.Name) end })

-- ───── Visual ─────
local Colors = Visual:AddSection("Warna", true)
Colors:AddColorPicker({ Title = "ESP Color", Content = "Klik swatch untuk memilih",
  Default = State.Color,
  Callback = function(c)
    State.Color = c
    -- TODO: terapkan warna ke ESP kamu
  end })

-- ───── Settings (standar untuk semua hub) ─────
local UI = Settings:AddSection("UI", true)

-- pilihan tema langsung hanya muncul bila library mendukung ganti tema saat berjalan
if Themes.Apply and Themes.DropdownOptions then
  UI:AddDropdown({ Title = "Tema", Content = "Ganti tampilan UI", Multi = false,
    Options = Themes.DropdownOptions(), Default = { HUB.Theme },
    Callback = function(v)
      local name = type(v) == "table" and v[1] or v
      if name then Try(Themes.Apply, Library, name) end
    end })
end

UI:AddToggle({ Title = "Anti AFK", Content = "Cegah kick karena idle", Default = true,
  Callback = function(on)
    Try(function() Library:GetConfig().Behavior.AntiAFK = on end)
  end })

UI:AddButton({ Title = "Tutup UI", Content = "Hapus UI dan hentikan semua fitur",
  Callback = function()
    State.AutoFarm = false -- hentikan loop kamu
    Window:Destroy()
  end })

Notify("Berhasil dimuat — tekan " .. HUB.ToggleKey.Name .. " untuk buka/tutup")
