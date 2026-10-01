--[[
  ╔══════════════════════════════════════════════════╗
  ║         KING AKBAR UI — THEME PRESETS v2         ║
  ║  github.com/Akbar025zzz/kingAkbarUi-Speedhub     ║
  ╚══════════════════════════════════════════════════╝

  CATATAN:
    * Panel = warna overlay transparan untuk kartu/item.
      - Tema gelap → putih
      - Tema terang → hitam
    * BackgroundTint dipakai untuk overlay di atas background image.
    * BackgroundTintTrans: 0 = solid, 1 = transparan total.

  CARA PAKAI:

    -- A) Ganti ke preset built-in (dari init.lua)
    Lib:SetPreset("Cyberpunk")

    -- B) Load file ini buat theme tambahan
    local Themes = loadstring(game:HttpGet("URL/themes.lua"))()
    Themes.RegisterAll(Lib)           -- daftarkan semua ke library
    Lib:SetPreset("MidnightBlue")     -- sekarang tersedia

    -- C) Bikin theme custom
    local MyTheme = Themes.New({
      Primary = Color3.fromRGB(255, 100, 100),
      Base = "Dark",                  -- inherits dari Dark
    })
    Lib:SetTheme(MyTheme)

    -- D) Theme random
    Lib:SetTheme(Themes.Random())

    -- E) List semua theme
    print(Themes.List())
]]

local Themes = {}

-- ═══════════════════════════════════════════════════
--  BASE THEMES (10 preset default)
--  (sama dengan yang ada di init.lua v1.6)
-- ═══════════════════════════════════════════════════

Themes.Dark = {
  Primary = Color3.fromRGB(255,255,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(10,10,10), Secondary = Color3.fromRGB(25,25,25),
  Text = Color3.fromRGB(255,255,255), SubText = Color3.fromRGB(160,160,160),
  Stroke = Color3.fromRGB(70,70,70), Divider = Color3.fromRGB(80,80,80),
  LineColor = Color3.fromRGB(110,110,110),
  BackgroundTint = Color3.fromRGB(0,0,0), BackgroundTintTrans = 0.3,
}

Themes.Neon = {
  Primary = Color3.fromRGB(0,255,180), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(10,10,20), Secondary = Color3.fromRGB(20,20,40),
  Text = Color3.fromRGB(0,255,180), SubText = Color3.fromRGB(120,200,180),
  Stroke = Color3.fromRGB(0,200,140), Divider = Color3.fromRGB(0,180,130),
  LineColor = Color3.fromRGB(0,220,160),
  BackgroundTint = Color3.fromRGB(0,20,15), BackgroundTintTrans = 0.35,
}

Themes.Cyberpunk = {
  Primary = Color3.fromRGB(255,0,200), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(15,5,30), Secondary = Color3.fromRGB(40,10,60),
  Text = Color3.fromRGB(255,200,255), SubText = Color3.fromRGB(180,130,220),
  Stroke = Color3.fromRGB(255,0,200), Divider = Color3.fromRGB(200,0,180),
  LineColor = Color3.fromRGB(220,50,220),
  BackgroundTint = Color3.fromRGB(30,0,20), BackgroundTintTrans = 0.35,
}

Themes.BloodRed = {
  Primary = Color3.fromRGB(255,30,30), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(10,5,5), Secondary = Color3.fromRGB(30,10,10),
  Text = Color3.fromRGB(255,255,255), SubText = Color3.fromRGB(180,120,120),
  Stroke = Color3.fromRGB(150,30,30), Divider = Color3.fromRGB(100,20,20),
  LineColor = Color3.fromRGB(180,40,40),
  BackgroundTint = Color3.fromRGB(20,0,0), BackgroundTintTrans = 0.3,
}

Themes.Gold = {
  Primary = Color3.fromRGB(255,200,50), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(15,12,5), Secondary = Color3.fromRGB(35,28,15),
  Text = Color3.fromRGB(255,240,200), SubText = Color3.fromRGB(200,170,100),
  Stroke = Color3.fromRGB(200,160,40), Divider = Color3.fromRGB(150,120,30),
  LineColor = Color3.fromRGB(200,170,60),
  BackgroundTint = Color3.fromRGB(20,15,0), BackgroundTintTrans = 0.3,
}

Themes.Purple = {
  Primary = Color3.fromRGB(180,100,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(15,10,25), Secondary = Color3.fromRGB(35,20,55),
  Text = Color3.fromRGB(240,230,255), SubText = Color3.fromRGB(170,140,200),
  Stroke = Color3.fromRGB(120,70,180), Divider = Color3.fromRGB(100,60,150),
  LineColor = Color3.fromRGB(140,90,200),
  BackgroundTint = Color3.fromRGB(15,0,30), BackgroundTintTrans = 0.35,
}

Themes.Ocean = {
  Primary = Color3.fromRGB(0,200,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(5,15,25), Secondary = Color3.fromRGB(15,35,55),
  Text = Color3.fromRGB(220,240,255), SubText = Color3.fromRGB(120,180,220),
  Stroke = Color3.fromRGB(0,130,200), Divider = Color3.fromRGB(20,100,160),
  LineColor = Color3.fromRGB(40,140,200),
  BackgroundTint = Color3.fromRGB(0,10,25), BackgroundTintTrans = 0.35,
}

Themes.Light = {
  Primary = Color3.fromRGB(0,100,220), Panel = Color3.fromRGB(0,0,0),
  Background = Color3.fromRGB(240,240,245), Secondary = Color3.fromRGB(210,210,220),
  Text = Color3.fromRGB(20,20,30), SubText = Color3.fromRGB(100,100,110),
  Stroke = Color3.fromRGB(180,180,190), Divider = Color3.fromRGB(200,200,210),
  LineColor = Color3.fromRGB(160,160,170),
  BackgroundTint = Color3.fromRGB(255,255,255), BackgroundTintTrans = 0.15,
}

Themes.Matrix = {
  Primary = Color3.fromRGB(0,255,0), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(0,8,0), Secondary = Color3.fromRGB(0,25,0),
  Text = Color3.fromRGB(0,255,0), SubText = Color3.fromRGB(0,180,0),
  Stroke = Color3.fromRGB(0,150,0), Divider = Color3.fromRGB(0,100,0),
  LineColor = Color3.fromRGB(0,200,0),
  BackgroundTint = Color3.fromRGB(0,15,0), BackgroundTintTrans = 0.35,
}

Themes.Sunset = {
  Primary = Color3.fromRGB(255,130,30), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(25,10,15), Secondary = Color3.fromRGB(50,20,25),
  Text = Color3.fromRGB(255,230,200), SubText = Color3.fromRGB(220,160,130),
  Stroke = Color3.fromRGB(180,80,40), Divider = Color3.fromRGB(130,60,30),
  LineColor = Color3.fromRGB(200,100,50),
  BackgroundTint = Color3.fromRGB(30,5,0), BackgroundTintTrans = 0.35,
}

-- ═══════════════════════════════════════════════════
--  EXTRA THEMES (bonus)
-- ═══════════════════════════════════════════════════

Themes.MidnightBlue = {
  Primary = Color3.fromRGB(100,150,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(5,8,20), Secondary = Color3.fromRGB(15,20,40),
  Text = Color3.fromRGB(220,230,255), SubText = Color3.fromRGB(130,150,200),
  Stroke = Color3.fromRGB(40,60,120), Divider = Color3.fromRGB(30,45,90),
  LineColor = Color3.fromRGB(60,90,160),
  BackgroundTint = Color3.fromRGB(0,5,20), BackgroundTintTrans = 0.35,
}

Themes.Rose = {
  Primary = Color3.fromRGB(255,120,170), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(25,10,18), Secondary = Color3.fromRGB(50,20,35),
  Text = Color3.fromRGB(255,220,235), SubText = Color3.fromRGB(210,150,180),
  Stroke = Color3.fromRGB(180,70,120), Divider = Color3.fromRGB(140,50,90),
  LineColor = Color3.fromRGB(200,90,140),
  BackgroundTint = Color3.fromRGB(30,0,15), BackgroundTintTrans = 0.35,
}

Themes.Mono = {
  Primary = Color3.fromRGB(200,200,200), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(20,20,20), Secondary = Color3.fromRGB(40,40,40),
  Text = Color3.fromRGB(240,240,240), SubText = Color3.fromRGB(150,150,150),
  Stroke = Color3.fromRGB(90,90,90), Divider = Color3.fromRGB(60,60,60),
  LineColor = Color3.fromRGB(120,120,120),
  BackgroundTint = Color3.fromRGB(0,0,0), BackgroundTintTrans = 0.4,
}

Themes.Forest = {
  Primary = Color3.fromRGB(80,200,120), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(8,15,10), Secondary = Color3.fromRGB(20,35,25),
  Text = Color3.fromRGB(220,255,230), SubText = Color3.fromRGB(130,180,150),
  Stroke = Color3.fromRGB(50,120,70), Divider = Color3.fromRGB(35,90,55),
  LineColor = Color3.fromRGB(70,150,95),
  BackgroundTint = Color3.fromRGB(0,20,5), BackgroundTintTrans = 0.35,
}

Themes.Void = {
  Primary = Color3.fromRGB(120,0,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(5,0,10), Secondary = Color3.fromRGB(20,5,35),
  Text = Color3.fromRGB(230,200,255), SubText = Color3.fromRGB(150,100,200),
  Stroke = Color3.fromRGB(60,0,120), Divider = Color3.fromRGB(45,0,90),
  LineColor = Color3.fromRGB(90,20,160),
  BackgroundTint = Color3.fromRGB(10,0,20), BackgroundTintTrans = 0.4,
}

Themes.Ice = {
  Primary = Color3.fromRGB(150,220,255), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(10,18,25), Secondary = Color3.fromRGB(25,40,55),
  Text = Color3.fromRGB(230,245,255), SubText = Color3.fromRGB(140,180,210),
  Stroke = Color3.fromRGB(80,140,180), Divider = Color3.fromRGB(50,100,140),
  LineColor = Color3.fromRGB(100,170,210),
  BackgroundTint = Color3.fromRGB(0,10,20), BackgroundTintTrans = 0.35,
}

Themes.Fire = {
  Primary = Color3.fromRGB(255,80,20), Panel = Color3.fromRGB(255,255,255),
  Background = Color3.fromRGB(20,8,5), Secondary = Color3.fromRGB(45,15,10),
  Text = Color3.fromRGB(255,230,210), SubText = Color3.fromRGB(210,140,100),
  Stroke = Color3.fromRGB(180,60,20), Divider = Color3.fromRGB(130,40,15),
  LineColor = Color3.fromRGB(200,80,30),
  BackgroundTint = Color3.fromRGB(25,5,0), BackgroundTintTrans = 0.35,
}

-- ═══════════════════════════════════════════════════
--  META
-- ═══════════════════════════════════════════════════

Themes._Order = {
  "Dark", "Neon", "Cyberpunk", "BloodRed", "Gold",
  "Purple", "Ocean", "Light", "Matrix", "Sunset",
  "MidnightBlue", "Rose", "Mono", "Forest", "Void",
  "Ice", "Fire",
}

Themes._BaseKeys = {
  "Primary", "Panel", "Background", "Secondary",
  "Text", "SubText", "Stroke", "Divider", "LineColor",
  "BackgroundTint", "BackgroundTintTrans",
}

-- ═══════════════════════════════════════════════════
--  HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════

-- Validasi theme: semua key wajib ada & tipe benar
function Themes.Validate(theme)
  if type(theme) ~= "table" then return false, "theme bukan table" end
  for _, k in ipairs(Themes._BaseKeys) do
    if theme[k] == nil then
      return false, "key '" .. k .. "' hilang"
    end
    if k == "BackgroundTintTrans" then
      if type(theme[k]) ~= "number" then
        return false, "BackgroundTintTrans harus number"
      end
    else
      if typeof(theme[k]) ~= "Color3" then
        return false, "key '" .. k .. "' harus Color3"
      end
    end
  end
  return true
end

-- Bikin theme baru dengan inherit dari base
-- opts = { Primary=Color3, Base="Dark", Text=..., dll }
function Themes.New(opts)
  opts = type(opts) == "table" and opts or {}
  local baseName = opts.Base or "Dark"
  local base = Themes[baseName] or Themes.Dark

  local theme = {}
  for _, k in ipairs(Themes._BaseKeys) do
    theme[k] = base[k]
  end
  for k, v in pairs(opts) do
    if k ~= "Base" and k ~= "_Name" then
      theme[k] = v
    end
  end

  -- auto-contrast: kalau Primary di-set tapi Text/SubText tidak, sesuaikan
  if opts.Primary and not opts.Text then
    local lum = 0.299*opts.Primary.R + 0.587*opts.Primary.G + 0.114*opts.Primary.B
    if lum > 0.55 and base == Themes.Light then
      -- biarkan
    end
  end

  local ok, err = Themes.Validate(theme)
  if not ok then
    warn("[Themes] Theme invalid: " .. tostring(err))
  end
  return theme
end

-- Register semua theme ke library
-- lib = Speed_Library instance
function Themes.RegisterAll(lib, overwrite)
  if not lib or not lib.Themes then
    warn("[Themes] Library tidak valid — pastikan pakai init.lua v1.6+")
    return false
  end
  local count = 0
  for name, theme in pairs(Themes) do
    if type(theme) == "table" and name:sub(1,1) ~= "_" then
      if not lib.Themes[name] or overwrite then
        lib.Themes[name] = theme
        count += 1
      end
    end
  end
  return count
end

-- Register satu theme dengan nama custom
function Themes.Register(lib, name, theme)
  if not lib or not lib.Themes then
    warn("[Themes] Library tidak valid")
    return false
  end
  local ok, err = Themes.Validate(theme)
  if not ok then
    warn("[Themes] Tidak bisa register '" .. name .. "': " .. tostring(err))
    return false
  end
  lib.Themes[name] = theme
  return true
end

-- List semua nama theme (terurut)
function Themes.List(includeMeta)
  local out = {}
  local seen = {}
  for _, name in ipairs(Themes._Order) do
    if Themes[name] then
      table.insert(out, name)
      seen[name] = true
    end
  end
  -- tambahkan theme yang belum di _Order
  local rest = {}
  for name, v in pairs(Themes) do
    if type(v) == "table" and not seen[name] and name:sub(1,1) ~= "_" then
      table.insert(rest, name)
    end
  end
  table.sort(rest)
  for _, name in ipairs(rest) do table.insert(out, name) end
  return out
end

-- Ambil theme by name (case-insensitive)
function Themes.Get(name)
  if type(name) ~= "string" then return nil end
  if Themes[name] then return Themes[name] end
  local lower = name:lower()
  for k, v in pairs(Themes) do
    if type(v) == "table" and k:lower() == lower and k:sub(1,1) ~= "_" then
      return v
    end
  end
  return nil
end

-- Theme random
function Themes.Random()
  local list = Themes.List()
  local name = list[math.random(1, #list)]
  return Themes[name], name
end

-- Blend 2 theme (t = 0..1, 0 = theme A, 1 = theme B)
function Themes.Blend(themeA, themeB, t)
  t = math.clamp(tonumber(t) or 0.5, 0, 1)
  local function lerpColor(a, b)
    return Color3.new(
      a.R + (b.R - a.R) * t,
      a.G + (b.G - a.G) * t,
      a.B + (b.B - a.B) * t
    )
  end
  local out = {}
  for _, k in ipairs(Themes._BaseKeys) do
    if k == "BackgroundTintTrans" then
      out[k] = (themeA[k] or 0) + ((themeB[k] or 0) - (themeA[k] or 0)) * t
    else
      out[k] = lerpColor(themeA[k], themeB[k])
    end
  end
  return out
end

-- Preview theme: print warna + hex
function Themes.Preview(theme)
  if type(theme) == "string" then theme = Themes.Get(theme) end
  if type(theme) ~= "table" then
    print("[Themes] Preview: theme tidak ditemukan")
    return
  end
  local function hex(c)
    return string.format("#%02X%02X%02X",
      math.floor(c.R * 255 + 0.5),
      math.floor(c.G * 255 + 0.5),
      math.floor(c.B * 255 + 0.5))
  end
  print("── Theme Preview ──")
  for _, k in ipairs(Themes._BaseKeys) do
    if k == "BackgroundTintTrans" then
      print(string.format("  %-20s = %.2f", k, theme[k] or 0))
    else
      print(string.format("  %-20s = %s", k, hex(theme[k])))
    end
  end
end

-- Generate theme dari warna tunggal (auto-derive semua)
function Themes.FromColor(primary, mode)
  mode = mode or "dark"
  local function clampC(c)
    return Color3.new(
      math.clamp(c.R, 0, 1),
      math.clamp(c.G, 0, 1),
      math.clamp(c.B, 0, 1)
    )
  end
  local function mix(a, b, t)
    return clampC(Color3.new(
      a.R + (b.R - a.R) * t,
      a.G + (b.G - a.G) * t,
      a.B + (b.B - a.B) * t
    ))
  end

  local black = Color3.fromRGB(0, 0, 0)
  local white = Color3.fromRGB(255, 255, 255)

  if mode == "light" then
    return {
      Primary = primary,
      Panel = black,
      Background = mix(white, primary, 0.08),
      Secondary = mix(white, primary, 0.18),
      Text = mix(black, primary, 0.15),
      SubText = mix(black, white, 0.45),
      Stroke = mix(white, primary, 0.35),
      Divider = mix(white, primary, 0.25),
      LineColor = mix(white, primary, 0.30),
      BackgroundTint = white,
      BackgroundTintTrans = 0.2,
    }
  else
    return {
      Primary = primary,
      Panel = white,
      Background = mix(black, primary, 0.05),
      Secondary = mix(black, primary, 0.12),
      Text = mix(white, primary, 0.1),
      SubText = mix(white, primary, 0.4),
      Stroke = mix(black, primary, 0.35),
      Divider = mix(black, primary, 0.25),
      LineColor = mix(black, primary, 0.45),
      BackgroundTint = mix(black, primary, 0.3),
      BackgroundTintTrans = 0.3,
    }
  end
end

return Themes
