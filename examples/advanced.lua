--[[
  ╔══════════════════════════════════════════════════╗
  ║   KING AKBAR UI — CONTOH 4: ADVANCED             ║
  ║   github.com/Akbar025zzz/kingAkbarUi-Speedhub    ║
  ╚══════════════════════════════════════════════════╝

  Semua komponen library v2.0 dalam satu script.

  Komponen: Toggle, Button, Slider (drag + fill bar + input
  manual), Input, Dropdown (multi + search), Keybind,
  ColorPicker (SV + hue + preset), Panel, Paragraph,
  Seperator, Line, Dialog, Tooltip, Notification queue.
]]

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

Library:EnableSave("AdvancedDemo.json")  -- built-in config save (tanpa wrapper!)

-- ═══ WINDOW lengkap semua opsi ═══
local Window = Library:CreateWindow({
  Title       = "Advanced Hub",
  Description = "v2.0 — all components",
  TabWidth    = 110,
  SizeUi      = UDim2.fromOffset(520, 340),
  Search      = true,
  Profile     = true,
  Logo        = "rbxassetid://7734010488",
  HideName    = false,
  ToggleKey   = Enum.KeyCode.RightShift,
})

-- ═══════════ TAB: COMPONENTS ═══════════
local Tab = Window:CreateTab({ "Components", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("All Components", true)

-- Toggle + Tooltip + SaveKey
Sec:AddToggle({
  Title    = "Toggle",
  Content  = "Dengan tooltip & auto-save",
  Tooltip  = "Status tersimpan otomatis di AdvancedDemo.json",
  Default  = false,
  SaveKey  = "demo_toggle",
  Callback = function(v) print("Toggle:", v) end,
})

-- Button + Dialog confirm
Sec:AddButton({
  Title    = "Danger Button",
  Content  = "Dengan konfirmasi dialog",
  Tooltip  = "Klik untuk lihat Dialog system",
  Callback = function()
    Library:Dialog({
      Title   = "Konfirmasi",
      Content = "Aksi ini tidak bisa dibatalkan. Lanjutkan?",
      Buttons = {
        { "Lanjut", function()
          Library:SetNotification({ Title = "Dialog", Description = "Confirmed", Content = "Aksi dijalankan!" })
        end, true },
        { "Batal", function() end },
      },
    })
  end,
})

-- Slider: drag + fill bar + klik angka untuk ketik manual
Sec:AddSlider({
  Title     = "Slider",
  Content   = "Drag track / klik angka untuk input manual",
  Increment = 1, Min = 0, Max = 100, Default = 50,
  SaveKey   = "demo_slider",
  Callback  = function(v) print("Slider:", v) end,
})

-- Input + Placeholder
Sec:AddInput({
  Title       = "Input",
  Content     = "Placeholder support",
  Placeholder = "Tulis sesuatu...",
  Default     = "",
  SaveKey     = "demo_input",
  Callback    = function(text) print("Input:", text) end,
})

-- Dropdown single + search
Sec:AddDropdown({
  Title   = "Dropdown (Single)",
  Content = "Dengan search box",
  Multi   = false,
  Options = { "Apple", "Banana", "Cherry", "Durian", "Grape", "Mango" },
  Default = "Apple",
  Search  = true,
  SaveKey = "demo_dropdown_single",
  Callback = function(v) print("Single:", v) end,
})

-- Dropdown multi + search
Sec:AddDropdown({
  Title   = "Dropdown (Multi)",
  Content = "Pilih beberapa sekaligus",
  Multi   = true,
  Options = { "ESP Player", "ESP Box", "ESP Name", "ESP Health", "ESP Tracer" },
  Default = { "ESP Player" },
  Search  = true,
  SaveKey = "demo_dropdown_multi",
  Callback = function(v)
    print("Multi (" .. #v .. "):", table.concat(v, ", "))
  end,
})

-- ── KEYBIND (BARU) ──
local KeySec = Tab:AddSection("Keybind & ColorPicker", true)

local FlyEnabled = false
KeySec:AddKeybind({
  Title    = "Fly Hotkey",
  Content  = "Tekan tombol untuk toggle",
  Default  = Enum.KeyCode.F,
  SaveKey  = "demo_flykey",
  Callback = function(key)
    FlyEnabled = not FlyEnabled
    print("Fly:", FlyEnabled, "(via", key.Name .. ")")
  end,
})

-- ColorPicker + Presets (BARU)
KeySec:AddColorPicker({
  Title    = "ESP Color",
  Content  = "SV picker + hue bar + preset swatch",
  Default  = Color3.fromRGB(255, 60, 60),
  Presets  = {
    Color3.fromRGB(255, 60, 60),
    Color3.fromRGB(60, 255, 120),
    Color3.fromRGB(60, 130, 255),
    Color3.fromRGB(255, 220, 60),
    Color3.fromRGB(255, 60, 220),
    Color3.fromRGB(255, 255, 255),
  },
  SaveKey = "demo_espcolor",
  Callback = function(c) print("ESP Color:", c) end,
})

-- ── PANEL ──
local PanelSec = Tab:AddSection("Panel", true)
local Panel = PanelSec:AddPanel({
  Title   = "Quick Actions",
  Content = "Sub-komponen di dalam panel",
  Tooltip = "Panel bisa berisi button & toggle sendiri",
})

Panel:AddButton({ "Panic", function()
  print("PANIC!")
end })
Panel:AddToggle({ "Safe Mode", false, function(v)
  print("Safe Mode:", v)
end })

-- ── PARAGRAPH / SEPERATOR / LINE ──
local Sec2 = Tab:AddSection("Text Elements", false)

Sec2:AddParagraph({
  Title   = "Paragraph",
  Content = "Teks panjang otomatis wrap & item otomatis tinggi.\nBaris kedua.",
  Tooltip = "Hover untuk lihat tooltip ini!",
})
Sec2:AddSeperator({ Title = "Divider di bawah" })
Sec2:AddLine()

-- ═══════════ TAB: API DEMO ═══════════
local Tab2 = Window:CreateTab({ "API", "rbxassetid://7734010488" })
local Sec3 = Tab2:AddSection("Object Methods", true)

-- Demo method runtime: Set, SetTitle, SetContent, SetVisible, Destroy
local DemoToggle
DemoToggle = Sec3:AddToggle({
  Title   = "Demo Toggle",
  Content = "Akan dimodifikasi dari bawah",
  Default = false,
  Callback = function(v) print("Demo:", v) end,
})

Sec3:AddButton({
  Title = "DemoToggle:Set(true)",
  Callback = function() DemoToggle:Set(true) end,   -- fire callback
})
Sec3:AddButton({
  Title = "DemoToggle:Set(false, tanpa fire)",
  Callback = function() DemoToggle:Set(false, false) end,  -- visual saja
})
Sec3:AddButton({
  Title = "SetTitle + SetContent",
  Callback = function()
    DemoToggle:SetTitle("Judul Baru")
    DemoToggle:SetContent("Konten diganti runtime")
  end,
})
Sec3:AddButton({
  Title = "SetVisible(false/true)",
  Callback = function()
    DemoToggle:SetVisible(not DemoToggle.SetVisible_Hidden)
    DemoToggle.SetVisible_Hidden = not DemoToggle.SetVisible_Hidden
  end,
})
Sec3:AddButton({
  Title = "Destroy DemoToggle",
  Callback = function()
    Library:Dialog({
      Title = "Hapus?", Content = "DemoToggle akan dihapus permanen.",
      Buttons = {
        { "Hapus", function() DemoToggle:Destroy() end, true },
        { "Batal", function() end },
      },
    })
  end,
})

-- ── Notification stress test (queue system) ──
local Sec4 = Tab2:AddSection("Notifications", false)

Sec4:AddButton({
  Title   = "Spam 8 Notifications",
  Content = "Test queue system (max 5 bersamaan)",
  Callback = function()
    for i = 1, 8 do
      Library:SetNotification({
        Title       = "Notif " .. i,
        Description = "Queue #" .. i,
        Content     = "Yang kelebihan otomatis antri.",
        Delay       = 2,
      })
    end
  end,
})

Sec4:AddButton({
  Title   = "Notification Tanpa Progress Bar",
  Callback = function()
    Library:SetNotification({
      Title = "Clean", Description = "No progress", Content = "Progress bar dimatikan.",
      Delay = 3, Progress = false,
    })
  end,
})

-- ── Window methods ──
local Sec5 = Tab2:AddSection("Window", false)

Sec5:AddButton({ Title = "Hide Window", Callback = function() Window:Hide() end })
Sec5:AddButton({ Title = "Show Window",  Callback = function() Window:Show() end })
Sec5:AddButton({ Title = "Toggle Window",Callback = function() Window:Toggle() end })
Sec5:AddButton({
  Title = "Destroy UI",
  Callback = function()
    Library:Dialog({
      Title = "Tutup UI?", Content = "Semua UI akan dihapus. Re-execute untuk membuka lagi.",
      Buttons = {
        { "Tutup", function() Window:Destroy() end, true },
        { "Batal", function() end },
      },
    })
  end,
})

-- ═══════════ TAB: SAVE DEMO ═══════════
local Tab3 = Window:CreateTab({ "Save", "rbxassetid://7734010488" })
local Sec6 = Tab3:AddSection("Built-in Save (tanpa wrapper!)", true)

Sec6:AddParagraph({
  Title   = "SaveKey",
  Content = "Semua item di tab Components pakai SaveKey — nilainya otomatis dimuat saat re-execute & tersimpan saat berubah.",
})

Sec6:AddButton({
  Title   = "Cek Saved Values",
  Callback = function()
    local saved = {
      demo_toggle, demo_slider, demo_input,
    }
    -- Akses via library save system:
    local S = Library.Save
    Library:SetNotification({
      Title = "Saved Config",
      Description = "Values",
      Content = "Toggle: " .. tostring(S.Get("demo_toggle"))
        .. "\nSlider: " .. tostring(S.Get("demo_slider"))
        .. "\nInput: " .. tostring(S.Get("demo_input")),
      Delay = 8,
    })
  end,
})

-- ═══ DONE ═══
Library:SetNotification({
  Title       = "Advanced Hub",
  Description = "Loaded!",
  Content     = "Semua komponen siap.\nHover item untuk tooltip!\n[RightShift] toggle UI.",
  Delay       = 6,
})
