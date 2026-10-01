--[[
  ╔══════════════════════════════════════════════════╗
  ║        KING AKBAR UI — THEME PRESETS v2.0        ║
  ║  github.com/Akbar025zzz/kingAkbarUi-Speedhub     ║
  ╚══════════════════════════════════════════════════╝

  NEW IN v2.0:
  • 27 tema (sebelumnya 10) + Violet + tema populer:
    Dracula, Nord, Catppuccin, Tokyo Night, Discord, dll.
  • Metadata tema (Type = "Dark"/"Light", Description)
  • Tema Light OTOMATIS mematikan background image (tidak manual lagi)
  • Helper functions:
      Themes.List()                → daftar nama semua tema
      Themes.Get("neon")           → ambil tema (case-insensitive)
      Themes.Apply(Lib, "Neon")    → apply aman + validasi + auto background
      Themes.Random(Lib)           → tema random (tidak berulang 2x)
      Themes.Generate(color)       → bikin tema lengkap dari 1 WARNA!
      Themes.Register("My", ...)   → register tema custom
      Themes.Merge("Dark", {...})  → kombinasi/override tema
      Themes.Validate("Neon")      → cek field yang kurang
      Themes.Count()               → jumlah tema
  • Kompatibel runtime theming (library v2.0) — tidak harus
    sebelum CreateWindow lagi

  CATATAN:
  * Panel = warna overlay transparan untuk kartu/item.
    Tema gelap pakai PUTIH, tema terang pakai HITAM.
  * Tema dengan Type = "Light" otomatis mematikan BackgroundImage
    saat di-apply via Themes.Apply() (opsi: { AutoBackground = false })
  * Pakai Themes.Apply(Library, Nama) daripada Library:SetTheme(Themes[Nama])
    supaya validasi + auto-background jalan.
]]

local Themes = {}
Themes.Version = "2.0"

-- ═══════════════════════════════════════════════════
--  FIELD WARNA YANG DIPAKAI LIBRARY
-- ═══════════════════════════════════════════════════
local COLOR_FIELDS = {
  "Primary", "Panel", "Background", "Secondary",
  "Text", "SubText", "Stroke", "Divider", "LineColor",
}

-- ═══════════════════════════════════════════════════
--  THEME DEFINITIONS (27 tema)
-- ═══════════════════════════════════════════════════

-- ─────────── Original 10 ───────────

Themes.Dark = {
  Type = "Dark", Description = "Gelap minimalis (default)",
  Primary    = Color3.fromRGB(255, 255, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(10, 10, 10),
  Secondary  = Color3.fromRGB(25, 25, 25),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(160, 160, 160),
  Stroke     = Color3.fromRGB(70, 70, 70),
  Divider    = Color3.fromRGB(80, 80, 80),
  LineColor  = Color3.fromRGB(110, 110, 110),
}

Themes.Neon = {
  Type = "Dark", Description = "Hijau neon cyber",
  Primary    = Color3.fromRGB(0, 255, 180),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(10, 10, 20),
  Secondary  = Color3.fromRGB(20, 20, 40),
  Text       = Color3.fromRGB(0, 255, 180),
  SubText    = Color3.fromRGB(120, 200, 180),
  Stroke     = Color3.fromRGB(0, 200, 140),
  Divider    = Color3.fromRGB(0, 180, 130),
  LineColor  = Color3.fromRGB(0, 220, 160),
}

Themes.Cyberpunk = {
  Type = "Dark", Description = "Magenta neon gelap",
  Primary    = Color3.fromRGB(255, 0, 200),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(15, 5, 30),
  Secondary  = Color3.fromRGB(40, 10, 60),
  Text       = Color3.fromRGB(255, 200, 255),
  SubText    = Color3.fromRGB(180, 130, 220),
  Stroke     = Color3.fromRGB(255, 0, 200),
  Divider    = Color3.fromRGB(200, 0, 180),
  LineColor  = Color3.fromRGB(220, 50, 220),
}

Themes.BloodRed = {
  Type = "Dark", Description = "Merah darah",
  Primary    = Color3.fromRGB(255, 30, 30),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(10, 5, 5),
  Secondary  = Color3.fromRGB(30, 10, 10),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(180, 120, 120),
  Stroke     = Color3.fromRGB(150, 30, 30),
  Divider    = Color3.fromRGB(100, 20, 20),
  LineColor  = Color3.fromRGB(180, 40, 40),
}

Themes.Gold = {
  Type = "Dark", Description = "Emas mewah",
  Primary    = Color3.fromRGB(255, 200, 50),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(15, 12, 5),
  Secondary  = Color3.fromRGB(35, 28, 15),
  Text       = Color3.fromRGB(255, 240, 200),
  SubText    = Color3.fromRGB(200, 170, 100),
  Stroke     = Color3.fromRGB(200, 160, 40),
  Divider    = Color3.fromRGB(150, 120, 30),
  LineColor  = Color3.fromRGB(200, 170, 60),
}

Themes.Purple = {
  Type = "Dark", Description = "Ungu klasik",
  Primary    = Color3.fromRGB(180, 100, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(15, 10, 25),
  Secondary  = Color3.fromRGB(35, 20, 55),
  Text       = Color3.fromRGB(240, 230, 255),
  SubText    = Color3.fromRGB(170, 140, 200),
  Stroke     = Color3.fromRGB(120, 70, 180),
  Divider    = Color3.fromRGB(100, 60, 150),
  LineColor  = Color3.fromRGB(140, 90, 200),
}

Themes.Ocean = {
  Type = "Dark", Description = "Biru laut",
  Primary    = Color3.fromRGB(0, 200, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(5, 15, 25),
  Secondary  = Color3.fromRGB(15, 35, 55),
  Text       = Color3.fromRGB(220, 240, 255),
  SubText    = Color3.fromRGB(120, 180, 220),
  Stroke     = Color3.fromRGB(0, 130, 200),
  Divider    = Color3.fromRGB(20, 100, 160),
  LineColor  = Color3.fromRGB(40, 140, 200),
}

Themes.Light = {
  Type = "Light", Description = "Terang minimalis",
  Primary    = Color3.fromRGB(0, 100, 220),
  Panel      = Color3.fromRGB(0, 0, 0),
  Background = Color3.fromRGB(240, 240, 245),
  Secondary  = Color3.fromRGB(210, 210, 220),
  Text       = Color3.fromRGB(20, 20, 30),
  SubText    = Color3.fromRGB(100, 100, 110),
  Stroke     = Color3.fromRGB(180, 180, 190),
  Divider    = Color3.fromRGB(200, 200, 210),
  LineColor  = Color3.fromRGB(160, 160, 170),
}

Themes.Matrix = {
  Type = "Dark", Description = "Hijau terminal",
  Primary    = Color3.fromRGB(0, 255, 0),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(0, 8, 0),
  Secondary  = Color3.fromRGB(0, 25, 0),
  Text       = Color3.fromRGB(0, 255, 0),
  SubText    = Color3.fromRGB(0, 180, 0),
  Stroke     = Color3.fromRGB(0, 150, 0),
  Divider    = Color3.fromRGB(0, 100, 0),
  LineColor  = Color3.fromRGB(0, 200, 0),
}

Themes.Sunset = {
  Type = "Dark", Description = "Oranye senja",
  Primary    = Color3.fromRGB(255, 130, 30),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(25, 10, 15),
  Secondary  = Color3.fromRGB(50, 20, 25),
  Text       = Color3.fromRGB(255, 230, 200),
  SubText    = Color3.fromRGB(220, 160, 130),
  Stroke     = Color3.fromRGB(180, 80, 40),
  Divider    = Color3.fromRGB(130, 60, 30),
  LineColor  = Color3.fromRGB(200, 100, 50),
}

-- ─────────── Violet (dari repo, sempat hilang di file ini) ───────────

Themes.Violet = {
  Type = "Dark", Description = "Violet lembut",
  Primary    = Color3.fromRGB(170, 110, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(16, 10, 26),
  Secondary  = Color3.fromRGB(32, 20, 50),
  Text       = Color3.fromRGB(238, 232, 255),
  SubText    = Color3.fromRGB(168, 148, 210),
  Stroke     = Color3.fromRGB(108, 76, 180),
  Divider    = Color3.fromRGB(88, 62, 150),
  LineColor  = Color3.fromRGB(132, 98, 200),
}

-- ─────────── Tema Baru ───────────

Themes.Emerald = {
  Type = "Dark", Description = "Hijau zamrud modern",
  Primary    = Color3.fromRGB(16, 185, 129),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(6, 14, 11),
  Secondary  = Color3.fromRGB(13, 34, 26),
  Text       = Color3.fromRGB(220, 255, 240),
  SubText    = Color3.fromRGB(125, 190, 160),
  Stroke     = Color3.fromRGB(18, 120, 90),
  Divider    = Color3.fromRGB(14, 92, 70),
  LineColor  = Color3.fromRGB(28, 158, 120),
}

Themes.Forest = {
  Type = "Dark", Description = "Hijau hutan pekat",
  Primary    = Color3.fromRGB(105, 200, 115),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(8, 14, 8),
  Secondary  = Color3.fromRGB(14, 30, 16),
  Text       = Color3.fromRGB(225, 244, 228),
  SubText    = Color3.fromRGB(140, 180, 145),
  Stroke     = Color3.fromRGB(60, 125, 70),
  Divider    = Color3.fromRGB(45, 92, 52),
  LineColor  = Color3.fromRGB(85, 160, 95),
}

Themes.Sakura = {
  Type = "Dark", Description = "Pink bunga sakura",
  Primary    = Color3.fromRGB(255, 140, 170),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(24, 10, 17),
  Secondary  = Color3.fromRGB(44, 18, 31),
  Text       = Color3.fromRGB(255, 235, 242),
  SubText    = Color3.fromRGB(212, 152, 176),
  Stroke     = Color3.fromRGB(198, 108, 148),
  Divider    = Color3.fromRGB(148, 80, 112),
  LineColor  = Color3.fromRGB(218, 128, 163),
}

Themes.Rose = {
  Type = "Dark", Description = "Merah rose modern",
  Primary    = Color3.fromRGB(244, 63, 94),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(24, 8, 12),
  Secondary  = Color3.fromRGB(44, 14, 21),
  Text       = Color3.fromRGB(255, 235, 238),
  SubText    = Color3.fromRGB(220, 138, 152),
  Stroke     = Color3.fromRGB(188, 48, 73),
  Divider    = Color3.fromRGB(138, 34, 54),
  LineColor  = Color3.fromRGB(213, 78, 103),
}

Themes.Cherry = {
  Type = "Dark", Description = "Merah cherry gelap",
  Primary    = Color3.fromRGB(255, 82, 120),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(20, 5, 10),
  Secondary  = Color3.fromRGB(37, 11, 19),
  Text       = Color3.fromRGB(255, 230, 235),
  SubText    = Color3.fromRGB(198, 128, 143),
  Stroke     = Color3.fromRGB(158, 50, 78),
  Divider    = Color3.fromRGB(113, 36, 56),
  LineColor  = Color3.fromRGB(188, 70, 100),
}

Themes.Midnight = {
  Type = "Dark", Description = "Biru indigo malam",
  Primary    = Color3.fromRGB(110, 125, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(8, 10, 24),
  Secondary  = Color3.fromRGB(15, 19, 42),
  Text       = Color3.fromRGB(225, 230, 255),
  SubText    = Color3.fromRGB(138, 148, 198),
  Stroke     = Color3.fromRGB(62, 72, 158),
  Divider    = Color3.fromRGB(46, 54, 128),
  LineColor  = Color3.fromRGB(82, 95, 188),
}

Themes.Amoled = {
  Type = "Dark", Description = "Hitam pekat (hemat baterai)",
  Primary    = Color3.fromRGB(255, 255, 255),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(0, 0, 0),
  Secondary  = Color3.fromRGB(14, 14, 14),
  Text       = Color3.fromRGB(255, 255, 255),
  SubText    = Color3.fromRGB(148, 148, 148),
  Stroke     = Color3.fromRGB(52, 52, 52),
  Divider    = Color3.fromRGB(58, 58, 58),
  LineColor  = Color3.fromRGB(98, 98, 98),
}

Themes.Monochrome = {
  Type = "Dark", Description = "Grayscale murni",
  Primary    = Color3.fromRGB(200, 200, 200),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(12, 12, 12),
  Secondary  = Color3.fromRGB(24, 24, 24),
  Text       = Color3.fromRGB(230, 230, 230),
  SubText    = Color3.fromRGB(140, 140, 140),
  Stroke     = Color3.fromRGB(70, 70, 70),
  Divider    = Color3.fromRGB(60, 60, 60),
  LineColor  = Color3.fromRGB(110, 110, 110),
}

Themes.Coffee = {
  Type = "Dark", Description = "Coklat kopi hangat",
  Primary    = Color3.fromRGB(200, 160, 120),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(17, 12, 8),
  Secondary  = Color3.fromRGB(31, 22, 15),
  Text       = Color3.fromRGB(240, 225, 210),
  SubText    = Color3.fromRGB(182, 152, 127),
  Stroke     = Color3.fromRGB(128, 93, 68),
  Divider    = Color3.fromRGB(92, 67, 48),
  LineColor  = Color3.fromRGB(162, 122, 92),
}

Themes.Arctic = {
  Type = "Light", Description = "Biru es terang",
  Primary    = Color3.fromRGB(0, 145, 215),
  Panel      = Color3.fromRGB(0, 0, 0),
  Background = Color3.fromRGB(235, 245, 250),
  Secondary  = Color3.fromRGB(200, 224, 238),
  Text       = Color3.fromRGB(18, 38, 52),
  SubText    = Color3.fromRGB(88, 118, 138),
  Stroke     = Color3.fromRGB(168, 198, 214),
  Divider    = Color3.fromRGB(188, 214, 226),
  LineColor  = Color3.fromRGB(148, 184, 205),
}

Themes.Steel = {
  Type = "Dark", Description = "Abu kebiruan metalik",
  Primary    = Color3.fromRGB(140, 165, 190),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(13, 16, 21),
  Secondary  = Color3.fromRGB(25, 31, 39),
  Text       = Color3.fromRGB(225, 235, 245),
  SubText    = Color3.fromRGB(142, 158, 173),
  Stroke     = Color3.fromRGB(73, 88, 108),
  Divider    = Color3.fromRGB(58, 70, 86),
  LineColor  = Color3.fromRGB(103, 124, 149),
}

-- ─────────── Tema Populer (editor/brand style) ───────────

Themes.Discord = {
  Type = "Dark", Description = "Style Discord (Blurple)",
  Primary    = Color3.fromRGB(88, 101, 242),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(30, 31, 34),
  Secondary  = Color3.fromRGB(43, 45, 49),
  Text       = Color3.fromRGB(219, 222, 225),
  SubText    = Color3.fromRGB(148, 155, 164),
  Stroke     = Color3.fromRGB(66, 69, 76),
  Divider    = Color3.fromRGB(58, 60, 66),
  LineColor  = Color3.fromRGB(94, 100, 110),
}

Themes.Nord = {
  Type = "Dark", Description = "Palet Nord",
  Primary    = Color3.fromRGB(136, 192, 208),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(46, 52, 64),
  Secondary  = Color3.fromRGB(59, 66, 82),
  Text       = Color3.fromRGB(236, 239, 244),
  SubText    = Color3.fromRGB(160, 170, 188),
  Stroke     = Color3.fromRGB(67, 76, 94),
  Divider    = Color3.fromRGB(76, 86, 106),
  LineColor  = Color3.fromRGB(94, 108, 130),
}

Themes.Dracula = {
  Type = "Dark", Description = "Palet Dracula",
  Primary    = Color3.fromRGB(189, 147, 249),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(40, 42, 54),
  Secondary  = Color3.fromRGB(68, 71, 90),
  Text       = Color3.fromRGB(248, 248, 242),
  SubText    = Color3.fromRGB(98, 114, 164),
  Stroke     = Color3.fromRGB(68, 71, 90),
  Divider    = Color3.fromRGB(90, 95, 120),
  LineColor  = Color3.fromRGB(128, 135, 165),
}

Themes.Catppuccin = {
  Type = "Dark", Description = "Catppuccin Mocha",
  Primary    = Color3.fromRGB(203, 166, 247),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(30, 30, 46),
  Secondary  = Color3.fromRGB(49, 50, 68),
  Text       = Color3.fromRGB(205, 214, 244),
  SubText    = Color3.fromRGB(166, 173, 200),
  Stroke     = Color3.fromRGB(69, 71, 90),
  Divider    = Color3.fromRGB(88, 91, 112),
  LineColor  = Color3.fromRGB(128, 132, 158),
}

Themes.TokyoNight = {
  Type = "Dark", Description = "Tokyo Night",
  Primary    = Color3.fromRGB(122, 162, 247),
  Panel      = Color3.fromRGB(255, 255, 255),
  Background = Color3.fromRGB(26, 27, 38),
  Secondary  = Color3.fromRGB(41, 46, 66),
  Text       = Color3.fromRGB(192, 202, 245),
  SubText    = Color3.fromRGB(148, 158, 200),
  Stroke     = Color3.fromRGB(65, 72, 104),
  Divider    = Color3.fromRGB(56, 63, 92),
  LineColor  = Color3.fromRGB(94, 104, 142),
}

-- ═══════════════════════════════════════════════════
--  INTERNAL HELPER
-- ═══════════════════════════════════════════════════

-- Color3 → HSV (dengan fallback manual kalau Color3.toHSV tidak ada)
local function ToHSV(c)
  local ok, h, s, v = pcall(Color3.toHSV, c)
  if ok and h then return h, s, v end
  local max = math.max(c.R, c.G, c.B)
  local min = math.min(c.R, c.G, c.B)
  local delta = max - min
  local hue = 0
  if delta > 0 then
    if max == c.R then
      hue = ((c.G - c.B) / delta) % 6
    elseif max == c.G then
      hue = (c.B - c.R) / delta + 2
    else
      hue = (c.R - c.G) / delta + 4
    end
    hue = hue / 6
  end
  return hue, (max == 0 and 0 or delta / max), max
end

-- ═══════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════

--- Daftar nama semua tema (terurut alfabetis)
function Themes.List()
  local list = {}
  for k, v in pairs(Themes) do
    if type(v) == "table" and typeof(v.Primary) == "Color3" then
      table.insert(list, k)
    end
  end
  table.sort(list)
  return list
end

--- Jumlah tema terdaftar
function Themes.Count()
  return #Themes.List()
end

--- Ambil tema by nama (case-insensitive). Return nil kalau tidak ada.
function Themes.Get(Name)
  if type(Name) ~= "string" then return nil end
  local direct = Themes[Name]
  if type(direct) == "table" and typeof(direct.Primary) == "Color3" then
    return direct
  end
  local lower = string.lower(Name)
  for k, v in pairs(Themes) do
    if type(v) == "table" and typeof(v.Primary) == "Color3"
      and string.lower(k) == lower then
      return v
    end
  end
  return nil
end

--- Cek apakah tema gelap (Type ~= "Light")
function Themes.IsDark(NameOrTheme)
  local Theme = NameOrTheme
  if type(NameOrTheme) == "string" then
    Theme = Themes.Get(NameOrTheme)
  end
  if type(Theme) ~= "table" then return nil end
  return Theme.Type ~= "Light"
end

--- Validasi field warna. Return array field yang kurang (kosong = valid)
function Themes.Validate(NameOrTheme)
  local Theme = NameOrTheme
  if type(NameOrTheme) == "string" then
    Theme = Themes.Get(NameOrTheme)
  end
  if type(Theme) ~= "table" then
    return { "(tema tidak ditemukan)" }
  end
  local missing = {}
  for _, Field in ipairs(COLOR_FIELDS) do
    if typeof(Theme[Field]) ~= "Color3" then
      table.insert(missing, Field)
    end
  end
  return missing
end

--- Apply tema ke Library — aman, tervalidasi, auto-handle tema Light.
--- Return: success (bool), themeTable
function Themes.Apply(Library, Name, Options)
  Options = Options or {}

  if type(Library) ~= "table" or type(Library.SetTheme) ~= "function" then
    warn("[KingAkbarUI] Themes.Apply: Library tidak valid (butuh objek Library dengan SetTheme)")
    return false
  end

  local Theme = Themes.Get(Name)
  if not Theme then
    warn("[KingAkbarUI] Tema tidak ditemukan: '" .. tostring(Name) .. "'")
    warn("[KingAkbarUI] Tersedia: " .. table.concat(Themes.List(), ", "))
    return false
  end

  local missing = Themes.Validate(Theme)
  if #missing > 0 then
    warn("[KingAkbarUI] Tema '" .. tostring(Name) .. "' kurang field: "
      .. table.concat(missing, ", ") .. " — field tsb pakai default library")
  end

  -- Kirim HANYA field warna (metadata tidak ikut ke CONFIG.Theme)
  local Clean = {}
  for _, Field in ipairs(COLOR_FIELDS) do
    Clean[Field] = Theme[Field]
  end

  -- Tema terang: otomatis matikan background image + tint
  if Theme.Type == "Light" and Options.AutoBackground ~= false then
    pcall(function()
      local Cfg = Library:GetConfig()
      if Cfg and Cfg.Window then
        Cfg.Window.BackgroundImage     = ""
        Cfg.Window.BackgroundTintTrans = 0
      end
    end)
  end

  Library:SetTheme(Clean)
  return true, Theme
end

--- Tema random. Kalau Library diberikan → langsung di-apply.
--- Tidak mengulang tema yang sama 2x berturut-turut.
function Themes.Random(Library, Options)
  local list = Themes.List()
  if #list == 0 then return nil end

  local name = list[math.random(1, #list)]
  if Themes._lastRandom and #list > 1 then
    local tries = 0
    while name == Themes._lastRandom and tries < 10 do
      name = list[math.random(1, #list)]
      tries += 1
    end
  end
  Themes._lastRandom = name

  if Library then
    if Themes.Apply(Library, name, Options) then
      return name
    end
    return nil
  end
  return name
end

--- ✨ Generate tema lengkap dari 1 warna primary!
--- Themes.Generate(Color3.fromRGB(255,100,0))            → tema Dark otomatis
--- Themes.Generate(Color3.fromRGB(0,150,255), {Light=true}) → tema Light
function Themes.Generate(Primary, Options)
  Options = Options or {}
  if typeof(Primary) ~= "Color3" then
    warn("[KingAkbarUI] Themes.Generate: Primary harus Color3")
    return nil
  end

  local h, s, v = ToHSV(Primary)

  if Options.Light == true then
    return {
      Type = "Light",
      Description = "Auto-generated (Light)",
      Primary    = Primary,
      Panel      = Color3.fromRGB(0, 0, 0),
      Background = Color3.fromHSV(h, math.min(s * 0.12, 0.10), 0.96),
      Secondary  = Color3.fromHSV(h, math.min(s * 0.18, 0.16), 0.88),
      Text       = Color3.fromRGB(20, 20, 28),
      SubText    = Color3.fromHSV(h, 0.12, 0.42),
      Stroke     = Color3.fromHSV(h, 0.10, 0.74),
      Divider    = Color3.fromHSV(h, 0.09, 0.81),
      LineColor  = Color3.fromHSV(h, 0.12, 0.66),
    }
  end

  -- Dark: turunkan background/secondary dari hue primary
  local bgS = math.min(s * 0.45, 0.32)
  local bgV = 0.045
  return {
    Type = "Dark",
    Description = "Auto-generated (Dark)",
    Primary    = Primary,
    Panel      = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromHSV(h, bgS, bgV),
    Secondary  = Color3.fromHSV(h, bgS * 1.2, bgV * 2.3),
    Text       = Color3.fromHSV(h, math.min(s * 0.25, 0.20), 0.96),
    SubText    = Color3.fromHSV(h, math.min(s * 0.40, 0.30), 0.60),
    Stroke     = Color3.fromHSV(h, math.min(s * 0.70, 0.55), 0.40),
    Divider    = Color3.fromHSV(h, math.min(s * 0.60, 0.50), 0.30),
    LineColor  = Color3.fromHSV(h, math.min(s * 0.70, 0.55), 0.52),
  }
end

--- Register tema custom ke daftar.
--- Bisa 3 bentuk:
---   Themes.Register("Mine", FullThemeTable)
---   Themes.Register("Mine", Color3.fromRGB(255,100,0))        → auto-generate
---   Themes.Register("Mine", { Primary = ..., Stroke = ... })  → generate + override
function Themes.Register(Name, ThemeData)
  if type(Name) ~= "string" or Name == "" then
    warn("[KingAkbarUI] Themes.Register: Nama harus string tidak kosong")
    return false
  end

  -- Bentuk 2: langsung Color3
  if typeof(ThemeData) == "Color3" then
    ThemeData = Themes.Generate(ThemeData)
  end

  -- Bentuk 3: partial table → auto-generate lalu override
  if type(ThemeData) == "table" and typeof(ThemeData.Primary) == "Color3" then
    local gen = Themes.Generate(ThemeData.Primary, { Light = ThemeData.Type == "Light" })
    for k, val in pairs(gen) do
      if ThemeData[k] == nil then ThemeData[k] = val end
    end
  end

  if type(ThemeData) ~= "table" then
    warn("[KingAkbarUI] Themes.Register: ThemeData harus table atau Color3")
    return false
  end

  local missing = Themes.Validate(ThemeData)
  if #missing > 0 then
    warn("[KingAkbarUI] Themes.Register('" .. Name .. "'): kurang field: "
      .. table.concat(missing, ", "))
    return false
  end

  ThemeData.Type = ThemeData.Type == "Light" and "Light" or "Dark"
  ThemeData.Description = ThemeData.Description or "Custom theme"
  ThemeData.Custom = true
  Themes[Name] = ThemeData
  return true
end

--- Merge tema dasar dengan override (tidak mengubah aslinya)
function Themes.Merge(BaseName, Overrides)
  local Base = Themes.Get(BaseName)
  if not Base then
    warn("[KingAkbarUI] Themes.Merge: tema dasar tidak ditemukan: " .. tostring(BaseName))
    return nil
  end
  local Merged = {}
  for k, v in pairs(Base) do Merged[k] = v end
  if type(Overrides) == "table" then
    for k, v in pairs(Overrides) do Merged[k] = v end
  end
  Merged.Description = "Merged dari '" .. tostring(BaseName) .. "'"
  return Merged
end

--- Opsi siap pakai untuk komponen Dropdown library
function Themes.DropdownOptions()
  return Themes.List()
end

return Themes
