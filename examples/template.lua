--[[
  ╔══════════════════════════════════════════════════════════╗
  ║        KING AKBAR HUB — TEMPLATE (COPY & EDIT)           ║
  ╚══════════════════════════════════════════════════════════╝

  Ini model hub yang bisa langsung dipakai orang lain:
    1. Salin file ini.
    2. Ubah blok "PENGATURAN HUB" di bawah (nama, game, tema, discord).
    3. Isi logika fitur di bagian "ISI FITUR KAMU" (cari tulisan TODO).
    4. Selesai — tab Info & Settings sudah jadi.

  Fitur bawaan template:
    - tampilan hub modern (sidebar + search, profil, badge, section collapsible)
    - tab Settings: ganti tema, hotkey UI, Anti-AFK, tutup UI (dengan konfirmasi)
    - helper Loop() untuk fitur auto yang aman (tidak dobel, berhenti saat dimatikan)
    - otomatis kompatibel dengan King Akbar UI v1.5 maupun v2.0
]]

-- ═══════════════════════════════════════════════════
--  PENGATURAN HUB (ubah bagian ini saja)
-- ═══════════════════════════════════════════════════
local HUB = {
  Name      = "King Akbar",
  Tagline   = "|  Peaceful Community",
  Game      = "Nama Game",
  Version   = "v1.0.0",
  Theme     = "Violet",                           -- Dark, Neon, Violet, Ocean, Light, dst.
  Logo      = "rbxassetid://7734010488",
  Discord   = "https://discord.gg/example",
  SaveFile  = "KingAkbarHub.json",                -- file config (v2.0)
  ToggleKey = Enum.KeyCode.RightShift,            -- hotkey buka/tutup UI (PC)
}

local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"

-- ═══════════════════════════════════════════════════
--  LOAD LIBRARY
-- ═══════════════════════════════════════════════════
local function Load(File)
  local ok, result = pcall(function()
    return loadstring(game:HttpGet(BASE .. File))()
  end)
  if not ok or result == nil then
    error("[" .. HUB.Name .. "] Gagal memuat " .. File .. ": " .. tostring(result), 0)
  end
  return result
end

local Library = Load("init.lua")
local Themes  = Load("themes.lua")

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════
--  TEMA & SAVE (aman untuk v1.5 dan v2.0)
-- ═══════════════════════════════════════════════════
local function ApplyTheme(Name)
  if type(Themes.Apply) == "function" then
    pcall(Themes.Apply, Library, Name)        -- v2.0: validasi + runtime
  elseif Themes[Name] then
    Library:SetTheme(Themes[Name])            -- v1.5: berlaku untuk elemen berikutnya
  end
end

ApplyTheme(HUB.Theme)

local Cfg = Library:GetConfig()
if HUB.Theme ~= "Light" then Cfg.Window.BackgroundImage = "" end   -- tampilan bersih
Cfg.Assets.FloatingButton = HUB.Logo

if type(Library.EnableSave) == "function" then
  Library:EnableSave(HUB.SaveFile)            -- v2.0: item ber-SaveKey tersimpan otomatis
end

-- ═══════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════
local Window = Library:CreateWindow({
  Title       = HUB.Name,
  Description = HUB.Tagline,
  Search      = true,        -- kolom search tab
  Profile     = true,        -- avatar + "Welcome, nama***"
  HideName    = true,        -- sensor nama
  Logo        = HUB.Logo,
  ToggleKey   = HUB.ToggleKey,
})

if Window.AddBadge then
  Window:AddBadge(HUB.Game .. " | " .. HUB.Version)
  Window:AddBadge("Executor: " .. tostring((identifyexecutor and (identifyexecutor())) or "Unknown"))
end

local function Notify(Title, Text)
  Library:SetNotification({ Title = Title, Description = "•", Content = Text, Delay = 3 })
end

-- ═══════════════════════════════════════════════════
--  HELPER FITUR
-- ═══════════════════════════════════════════════════
local State = {}   -- status semua fitur: State.AutoFarm = true/false
local Loops = {}   -- penanda loop yang sedang jalan

-- Menjalankan fn berulang selama State[Flag] == true.
-- Aman: tidak membuat loop dobel, berhenti sendiri saat dimatikan, error tidak menghentikan hub.
local function Loop(Flag, Interval, Fn)
  if Loops[Flag] then return end
  Loops[Flag] = true
  task.spawn(function()
    while State[Flag] do
      local ok, err = pcall(Fn)
      if not ok then warn("[" .. HUB.Name .. "] " .. Flag .. ": " .. tostring(err)) end
      task.wait(Interval)
    end
    Loops[Flag] = nil
  end)
end

local function GetHumanoid()
  local char = LocalPlayer.Character
  return char and char:FindFirstChildOfClass("Humanoid")
end

-- ═══════════════════════════════════════════════════
--  TAB
-- ═══════════════════════════════════════════════════
local InfoTab      = Window:CreateTab({ "Info" })
local MainTab      = Window:CreateTab({ "Main" })
local AutomaticTab = Window:CreateTab({ "Automatic" })
local SettingsTab  = Window:CreateTab({ "Settings" })

-- ═══════════ INFO ═══════════
local About = InfoTab:AddSection("About", true)
About:AddParagraph({
  Title   = HUB.Name,
  Content = "Game: " .. HUB.Game .. "\nVersi: " .. HUB.Version,
})
About:AddButton({
  Title = "Copy Discord", Content = "Salin link komunitas ke clipboard",
  Callback = function()
    if setclipboard then
      setclipboard(HUB.Discord)
      Notify("Discord", "Link disalin ke clipboard")
    else
      Notify("Discord", HUB.Discord)
    end
  end,
})

-- ═══════════════════════════════════════════════════
--  ISI FITUR KAMU — MULAI DARI SINI
--  Pola yang dipakai:
--    Toggle  → State.Nama = value, lalu Loop("Nama", detik, function() ... end)
--    Slider  → simpan angka ke State atau langsung terapkan
--    Dropdown→ callback menerima nilai pilihan
--  Tambahkan SaveKey agar pilihan user tersimpan (v2.0).
-- ═══════════════════════════════════════════════════

-- ═══════════ MAIN ═══════════
local Player = MainTab:AddSection("Player", true)

Player:AddSlider({
  Title = "WalkSpeed", Content = "Kecepatan jalan karakter",
  Increment = 1, Min = 16, Max = 100, Default = 16, SaveKey = "walkspeed",
  Callback = function(v)
    State.WalkSpeed = v
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = v end
  end,
})

-- terapkan lagi setelah respawn
LocalPlayer.CharacterAdded:Connect(function(char)
  local hum = char:WaitForChild("Humanoid", 5)
  if hum and State.WalkSpeed then hum.WalkSpeed = State.WalkSpeed end
end)

local Farming = MainTab:AddSection("Farming", false)

Farming:AddToggle({
  Title = "Auto Farm", Content = "Isi logika di bagian TODO", Default = false, SaveKey = "auto_farm",
  Callback = function(on)
    State.AutoFarm = on
    if on then
      Loop("AutoFarm", 0.5, function()
        -- TODO: logika auto farm kamu di sini
      end)
    end
  end,
})

Farming:AddDropdown({
  Title = "Target", Content = "Pilih target farming", Multi = false,
  Options = { "Target A", "Target B", "Target C" }, Default = "Target A", SaveKey = "farm_target",
  Callback = function(v)
    State.Target = (type(v) == "table") and v[1] or v
  end,
})

-- ═══════════ AUTOMATIC ═══════════
local Auto = AutomaticTab:AddSection("Auto Tasks", true)

Auto:AddToggle({
  Title = "Auto Collect", Default = false, SaveKey = "auto_collect",
  Callback = function(on)
    State.AutoCollect = on
    if on then
      Loop("AutoCollect", 1, function()
        -- TODO: logika auto collect kamu di sini
      end)
    end
  end,
})

Auto:AddToggle({
  Title = "Auto Sell", Content = "Jual otomatis saat penuh", Default = false, SaveKey = "auto_sell",
  Callback = function(on)
    State.AutoSell = on
    if on then
      Loop("AutoSell", 2, function()
        -- TODO: logika auto sell kamu di sini
      end)
    end
  end,
})

-- ═══════════════════════════════════════════════════
--  ISI FITUR KAMU — SELESAI
-- ═══════════════════════════════════════════════════

-- ═══════════ SETTINGS ═══════════
local UISet = SettingsTab:AddSection("Tampilan", true)

UISet:AddDropdown({
  Title = "Tema", Content = "Ganti warna UI", Multi = false,
  Options = (type(Themes.DropdownOptions) == "function" and Themes.DropdownOptions())
    or { "Dark", "Neon", "Violet", "Ocean", "Sunset", "Light" },
  Default = HUB.Theme, SaveKey = "ui_theme",
  Callback = function(v)
    local name = (type(v) == "table") and v[1] or v
    if not name then return end
    ApplyTheme(name)
    if type(Themes.Apply) ~= "function" then
      Notify("Tema", "Tema baru berlaku setelah script dijalankan ulang")
    end
  end,
})

local function SetUiKey(Key)
  if typeof(Key) ~= "EnumItem" then return end
  if type(Library.SetToggleKey) == "function" then
    Library:SetToggleKey(Key)
  elseif Window.SetToggleKey then
    Window:SetToggleKey(Key)
  end
end

UISet:AddKeybind({
  Title = "Hotkey UI", Content = "Tombol buka/tutup window (PC)",
  Default = HUB.ToggleKey, SaveKey = "ui_key",
  Callback = SetUiKey,
  Changed  = SetUiKey,
})

local Misc = SettingsTab:AddSection("Lainnya", true)

Misc:AddToggle({
  Title = "Anti AFK", Content = "Cegah kick karena idle", Default = true, SaveKey = "anti_afk",
  Callback = function(on) Cfg.Behavior.AntiAFK = on end,
})

local function CloseHub()
  for k in pairs(State) do State[k] = false end   -- hentikan semua loop
  if type(Library.Destroy) == "function" then Library:Destroy() else Window:Destroy() end
end

Misc:AddButton({
  Title = "Tutup UI", Content = "Hapus UI & hentikan semua fitur",
  Callback = function()
    if type(Library.Dialog) == "function" then
      Library:Dialog({
        Title = "Konfirmasi", Content = "Tutup " .. HUB.Name .. " sekarang?",
        Buttons = {
          { "Ya", CloseHub, true },
          { "Batal", function() end },
        },
      })
    else
      CloseHub()
    end
  end,
})

Notify(HUB.Name, "Loaded — tekan [" .. HUB.ToggleKey.Name .. "] untuk buka/tutup UI")
