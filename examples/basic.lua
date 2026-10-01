
--[[
  ╔══════════════════════════════════════════════════╗
  ║   KING AKBAR UI — CONTOH 1: BASIC                ║
  ║   github.com/Akbar025zzz/kingAkbarUi-Speedhub    ║
  ╚══════════════════════════════════════════════════╝

  Paling simpel. Cukup: load library → buat window →
  isi tab → jalan.

  Baru di v2.0:
  • ToggleKey default (RightShift) langsung jalan —
    tekan RightShift untuk show/hide UI
]]

local Library = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/init.lua"
))()

-- ═══ WINDOW ═══
local Window = Library:CreateWindow({
  Title       = "King Akbar UI",
  Description = "v2.0",
  -- ToggleKey = Enum.KeyCode.RightShift,  -- (opsional) default sudah RightShift
  SizeUi      = UDim2.fromOffset(420, 280),
})

-- ═══ TAB ═══
local Tab = Window:CreateTab({ "Main", "rbxassetid://7734010488" })

-- ═══ SECTION ═══
local Section = Tab:AddSection("Farming", true)

-- ═══ TOGGLE (callback TIDAK terpanggil saat init — fix v2.0) ═══
Section:AddToggle({
  Title    = "Auto Farm",
  Content  = "Aktifkan auto farming",
  Default  = false,
  Callback = function(state)
    print("Auto Farm:", state)
  end,
})

-- ═══ BUTTON ═══
Section:AddButton({
  Title    = "Reset Character",
  Content  = "Klik untuk reset",
  Icon     = "rbxassetid://16932740082",
  Callback = function()
    local char = game.Players.LocalPlayer.Character
    if char then char:BreakJoints() end
  end,
})

-- ═══ NOTIFICATION (dengan progress bar) ═══
Library:SetNotification({
  Title       = "King Akbar",
  Description = "Loaded",
  Content     = "Script berhasil dimuat!\nTekan [RightShift] untuk toggle UI.",
  Delay       = 5,
})
