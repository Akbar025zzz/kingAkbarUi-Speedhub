--[[
  ╔══════════════════════════════════════════════════╗
  ║   KING AKBAR UI — CONTOH 2: WITH-SAVE            ║
  ║   github.com/Akbar025zzz/kingAkbarUi-Speedhub    ║
  ╚══════════════════════════════════════════════════╝

  Pemakaian wrapper + auto-save config.

  Baru di v2.0:
  • Tidak perlu storeFn manual → otomatis simpan ke file JSON
  • FuncsV3:Keybind & ColorPicker juga ikut tersimpan
  • Parameter Key → bebas kasih nama sama di tab beda
  • Config versioning + migrasi
]]

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()
local FuncsV3 = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/wrapper.lua"
))()

-- ═══ SETUP (urutan penting: SetFile → SetVersion → SetTable) ═══
FuncsV3:BindLibrary(Library)               -- unlock FuncsV3:Notify()
FuncsV3:SetFile("MyHubConfig.json")        -- nama file simpanan
FuncsV3:SetVersion("1.0", function(cfg)   -- migrasi kalau versi ganti
  -- contoh: cfg.key_lama → cfg.key_baru
end)

getgenv().MyConfig = getgenv().MyConfig or {}
FuncsV3:SetTable(getgenv().MyConfig)       -- auto-load + auto-save ke file!

-- ═══ UI ═══
local Window = Library:CreateWindow({
  Title = "My Hub", Description = "with-save",
})

local Tab     = Window:CreateTab({ "Main", "rbxassetid://7734010488" })
local TabMisc = Window:CreateTab({ "Misc", "rbxassetid://7734010488"" })

local Farm = Tab:AddSection("Farming", true)
local Misc = TabMisc:AddSection("Settings", true)

-- ═══ TOGGLE — "Save" = load otomatis + auto-save ═══
FuncsV3:Toggle(Farm, "Auto Farm", "Farm otomatis", "Save", function(v)
  print("Auto Farm:", v)
end)

-- ═══ SLIDER — "Save" juga jalan ═══
FuncsV3:Slider(Farm, "WalkSpeed", "", 16, 200, "Save", function(v)
  local char = game.Players.LocalPlayer.Character
  if char and char:FindFirstChildOfClass("Humanoid") then
    char.Humanoid.WalkSpeed = v
  end
end, 1)

-- ═══ DROPDOWN multi + "Save" (BUG v1 DIPERBAIKI — sekarang benar tersimpan!) ═══
FuncsV3:Dropdown(Farm, "Fruit Filter", "Pilih buah", true,
  { "Apple", "Banana", "Orange", "Grape" }, "Save", function(v)
    print("Filter:", table.concat(v, ", "))
  end)

-- ═══ TEXTBOX ═══
FuncsV3:Textbox(Farm, "Webhook URL", "Kosongkan kalau tidak pakai", "Save", function(v)
  print("Webhook:", v)
end)

-- ═══ KEYBIND — BARU di v2.0, ikut tersimpan ═══
FuncsV3:Keybind(Farm, "Farm Hotkey", "Tekan keybind untuk toggle farm",
  "Save", function(key)
    print("Hotkey ditekan:", key.Name)
  end)

-- ═══ COLORPICKER — BARU di v2.0, tersimpan sebagai {R,G,B} ═══
FuncsV3:ColorPicker(Farm, "ESP Color", "Warna highlight ESP",
  "Save", function(color)
    print("ESP Color:", color)
  end)

-- ═══ KEY param — nama sama di tab beda, tidak tabrakan! ═══
FuncsV3:Toggle(Misc, "Auto Farm", "Versi misc (beda key)", "Save", function(v)
  print("[Misc] Auto Farm:", v)
end, "misc_autofarm")  -- ← kunci khusus, terpisah dari "Auto Farm" di Main

-- ═══ API langsung ═══
Misc:AddButton({
  Title   = "Save Sekarang",
  Content = "Paksa simpan config",
  Callback = function()
    FuncsV3:Save()
    FuncsV3:Notify({ Title = "Config", Description = "Saved", Content = "Config disimpan!" })
  end,
})

Misc:AddButton({
  Title   = "Reset Config",
  Content = "Hapus semua pengaturan tersimpan",
  Callback = function()
    Library:Dialog({
      Title   = "Konfirmasi",
      Content = "Hapus semua config tersimpan? Tidak bisa dibatalkan.",
      Buttons = {
        { "Ya, Hapus", function()
          FuncsV3:Reset()
          FuncsV3:Notify({ Title = "Config", Description = "Reset", Content = "Config dihapus!" })
        end, true },
        { "Batal", function() end },
      },
    })
  end,
})

FuncsV3:Notify({ Title = "My Hub", Description = "Loaded", Content = "Config dimuat otomatis!" })
