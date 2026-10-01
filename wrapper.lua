--[[
  ╔══════════════════════════════════════════════════╗
  ║      KING AKBAR UI — FUNCSV3 WRAPPER v2.0        ║
  ║  github.com/Akbar025zzz/kingAkbarUi-Speedhub     ║
  ╚══════════════════════════════════════════════════╝

  NEW IN v2.0:
  • FIX BUG: Multi-dropdown sekarang benar-benar tersimpan
    setiap berubah (dulu: referensi table sama → tidak pernah save lagi)
  • FIX BUG: Dropdown single-select Default string tidak dipaksa jadi table
  • Default storeFn: otomatis simpan ke FILE JSON (writefile) —
    tidak perlu callback manual. Auto-load saat SetTable.
  • Wrapper baru: Keybind, ColorPicker, Panel
  • FuncsV3:Load() / Save() / Reset() / Get() / Set()
  • Parameter Key opsional di semua wrapper → hindari tabrakan nama antar tab
  • Config versioning + migrasi: SetVersion("1.1", migrateFn)
  • Bentuk config TABLE didukung (sama seperti library):
      FuncsV3:Toggle(Tab, { Title = "...", Default = "Save", Key = "x" })
  • Icon Button bisa di-override (atau "" untuk tanpa icon)
  • Tooltip & Placeholder passthrough
  • BindLibrary(Lib) → FuncsV3:Notify() langsung jalan
  • Auto-serialize Color3 & EnumItem → aman untuk JSON

  CATATAN:
  * "Save" tetap jadi magic value untuk load otomatis dari config.
  * Keybind: tersimpan saat key ditekan atau di-set via Obj:Set().
  * Di Studio / executor tanpa writefile: config hanya hidup di memori
    (tidak error, cuma tidak persist).

  Usage:
    local FuncsV3 = loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/"
      .."Akbar025zzz/kingAkbarUi-Speedhub/main/wrapper.lua"))()

    getgenv().MyConfig = getgenv().MyConfig or {}
    FuncsV3:SetTable(getgenv().MyConfig)   -- auto load + auto save ke file
]]

local FuncsV3 = {}
FuncsV3.Version = "2.0"

local HttpService = game:GetService("HttpService")

-- ───────────────────────────────────────────────────
--  INTERNAL STATE
-- ───────────────────────────────────────────────────
local SaveConfig   = nil
local Store        = nil
local UseFile      = false
local AutoSave     = true
local SavePending  = false
local FileName     = "KingAkbarUI_Wrapper.json"
local Lib          = nil
local ConfigVersion, MigrationFn = nil, nil

-- ───────────────────────────────────────────────────
--  HELPERS
-- ───────────────────────────────────────────────────
local function Checker(Val, ValType, Fallback)
  if typeof(Val) == ValType then return Val end
  return Fallback
end

-- Ambil argumen dari bentuk array ATAU named (sama seperti library)
local function Arg(Cfg, Idx, Key, Default)
  if type(Cfg) ~= "table" then
    if Idx == 1 and Cfg ~= nil then return Cfg end
    return Default
  end
  local v = Cfg[Idx]
  if v == nil then v = Cfg[Key] end
  if v == nil then return Default end
  return v
end

local function SafeGet(key, fallback)
  if type(SaveConfig) ~= "table" then return fallback end
  local v = SaveConfig[key]
  if v == nil then return fallback end
  return v
end

-- Bandingkan ISI array (bukan referensi) — inti fix bug multi-dropdown
local function ArrayEquals(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  if #a ~= #b then return false end
  for i, v in ipairs(a) do
    if type(v) == "table" then
      if not ArrayEquals(v, b[i]) then return false end
    elseif b[i] ~= v then
      return false
    end
  end
  return true
end

-- Pastikan nilai aman untuk JSONEncode
local function SerializeForSave(v)
  local t = typeof(v)
  if t == "Color3" then
    return { math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5) }
  elseif t == "EnumItem" then
    return v.Name
  end
  return v
end

-- ── Default file storage (executor) ──
local function DefaultStore(cfg)
  if type(cfg) ~= "table" or not writefile then return end
  local ok, err = pcall(function()
    writefile(FileName, HttpService:JSONEncode(cfg))
  end)
  if not ok then
    warn("[FuncsV3] Gagal menyimpan ke file: " .. tostring(err))
  end
end

local function DefaultLoad()
  if not (isfile and readfile) then return nil end
  local ok, data = pcall(function()
    if isfile(FileName) then return readfile(FileName) end
    return nil
  end)
  if not ok or type(data) ~= "string" or data == "" then return nil end
  local ok2, decoded = pcall(function()
    return HttpService:JSONDecode(data)
  end)
  if ok2 and type(decoded) == "table" then return decoded end
  return nil
end

local function FlushSave()
  SavePending = false
  if not AutoSave then return end
  if type(Store) == "function" then
    local ok, err = pcall(Store, SaveConfig)
    if not ok then warn("[FuncsV3] Gagal menyimpan config: " .. tostring(err)) end
  elseif UseFile then
    DefaultStore(SaveConfig)
  end
end

-- FIX v2.0: table dibandingkan per-ISI + disimpan sebagai COPY
-- (dulu: referensi sama → perubahan berikutnya tidak pernah tersimpan)
local function SafeSet(key, value)
  if type(SaveConfig) ~= "table" then return end
  if key == nil or key == "" then return end
  value = SerializeForSave(value)

  local changed
  if type(value) == "table" then
    changed = not ArrayEquals(SaveConfig[key], value)
    if changed then
      local copy = {}
      for i, v in ipairs(value) do copy[i] = v end
      SaveConfig[key] = copy
    end
  else
    changed = (SaveConfig[key] ~= value)
    if changed then SaveConfig[key] = value end
  end

  if changed and not SavePending then
    SavePending = true
    task.delay(0.5, FlushSave) -- debounce 0.5 detik
  end
end

-- Bersihkan tabel dari nilai nil/kosong (untuk opsi multi-dropdown)
local function CleanTable(t)
  local out = {}
  if type(t) ~= "table" then
    if t ~= nil and t ~= "" then table.insert(out, t) end
    return out
  end
  for _, v in ipairs(t) do
    if v ~= nil and v ~= "" then table.insert(out, v) end
  end
  return out
end

-- String/EnumItem → Enum.KeyCode (dukung "E" dan format lama "KeyCode.E")
local function ParseKeyCode(v)
  if typeof(v) == "EnumItem" then
    if v.EnumType == Enum.KeyCode then return v end
    return nil
  end
  if type(v) == "string" and v ~= "" then
    local kc = Enum.KeyCode[v]
    if kc then return kc end
    local name = string.match(v, "%.([^%.]+)$")
    if name then return Enum.KeyCode[name] end
  end
  return nil
end

-- Table {r,g,b} / {R=,G=,B=} / Color3 → Color3
local function ParseColor(v)
  if typeof(v) == "Color3" then return v end
  if type(v) == "table" then
    return Color3.fromRGB(
      tonumber(v[1]) or tonumber(v.R) or 255,
      tonumber(v[2]) or tonumber(v.G) or 255,
      tonumber(v[3]) or tonumber(v.B) or 255)
  end
  return nil
end

-- Config versioning + migrasi
local function CheckVersion(cfg)
  if not ConfigVersion or type(cfg) ~= "table" then return end
  local stored = cfg.__version
  if stored == ConfigVersion then return end
  if stored ~= nil or MigrationFn then
    if MigrationFn then
      local ok, err = pcall(MigrationFn, cfg, ConfigVersion, stored)
      if not ok then warn("[FuncsV3] Migrasi config gagal: " .. tostring(err)) end
    else
      warn("[FuncsV3] Config version berubah (" .. tostring(stored)
        .. " → " .. ConfigVersion .. ") tanpa fungsi migrasi — data lama dipertahankan")
    end
  end
  cfg.__version = ConfigVersion
end

local function ResolveKey(Key, Name)
  if Key ~= nil and Key ~= "" then return tostring(Key) end
  return Name
end

-- ───────────────────────────────────────────────────
--  PUBLIC SETUP
-- ───────────────────────────────────────────────────

--- path    : table, contoh: getgenv().MyHubConfig
--- storeFn : OPTIONAL function(config). Kalau nil → otomatis
---           pakai file JSON (writefile) + auto-load.
function FuncsV3:SetTable(path, storeFn)
  SaveConfig = Checker(path, "table", {})
  Store = storeFn
  UseFile = (storeFn == nil)

  if UseFile then
    local saved = DefaultLoad()
    if type(saved) == "table" then
      for k, v in pairs(saved) do
        if k ~= "__version" then SaveConfig[k] = v end
      end
    end
  end
  CheckVersion(SaveConfig)
  return FuncsV3
end

--- Ganti nama file untuk default storage (panggil SEBELUM SetTable)
function FuncsV3:SetFile(name)
  FileName = tostring(name or FileName)
  return FuncsV3
end

function FuncsV3:GetTable() return SaveConfig or {} end

function FuncsV3:SetAutoSave(state)
  AutoSave = not not state
end

--- Set versi config + fungsi migrasi (opsional)
--- FuncsV3:SetVersion("1.1", function(cfg, newVer, oldVer) ... end)
function FuncsV3:SetVersion(version, migrateFn)
  ConfigVersion = tostring(version)
  MigrationFn = migrateFn
  if type(SaveConfig) == "table" then CheckVersion(SaveConfig) end
  return FuncsV3
end

--- Muat ulang config dari file (hanya mode default storage)
function FuncsV3:Load()
  if not UseFile then return false end
  if type(SaveConfig) ~= "table" then SaveConfig = {} end
  local saved = DefaultLoad()
  if type(saved) ~= "table" then return false end
  for k, v in pairs(saved) do
    if k ~= "__version" then SaveConfig[k] = v end
  end
  CheckVersion(SaveConfig)
  return true
end

--- Simpan manual (abaikan AutoSave)
function FuncsV3:Save()
  SavePending = false
  if type(SaveConfig) ~= "table" then return end
  if type(Store) == "function" then
    local ok, err = pcall(Store, SaveConfig)
    if not ok then warn("[FuncsV3] Gagal menyimpan config: " .. tostring(err)) end
  elseif UseFile then
    DefaultStore(SaveConfig)
  end
end

--- Hapus semua config + file (reset ke default)
function FuncsV3:Reset()
  if type(SaveConfig) == "table" then table.clear(SaveConfig) end
  pcall(function()
    if isfile and isfile(FileName) then delfile(FileName) end
  end)
end

--- Akses langsung ke config
function FuncsV3:Get(key, fallback)
  if key == nil then return SaveConfig or {} end
  return SafeGet(key, fallback)
end

function FuncsV3:Set(key, value)
  SafeSet(key, value)
end

--- Bind library → unlock FuncsV3:Notify()
function FuncsV3:BindLibrary(library)
  Lib = library
  return FuncsV3
end

function FuncsV3:Notify(Config)
  if Lib and type(Lib.SetNotification) == "function" then
    return Lib:SetNotification(Config)
  end
  warn("[FuncsV3] Panggil FuncsV3:BindLibrary(Library) dulu untuk memakai Notify")
  return nil
end

-- ───────────────────────────────────────────────────
--  WRAPPERS
--  Semua menerima bentuk positional (lama) ATAU table (baru):
--    FuncsV3:Toggle(Tab, "Nama", "Desk", "Save", cb)
--    FuncsV3:Toggle(Tab, { Title="Nama", Default="Save", Key="unik" })
-- ───────────────────────────────────────────────────

-- ── Toggle ─────────────────────────────────────────
-- Default: boolean ATAU "Save"
function FuncsV3:Toggle(Tab, Name, Content, Default, Callback, Key)
  local Tooltip
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Default  = Arg(C, 3, "Default", false)
    Callback = Arg(C, 4, "Callback", nil)
    Key      = C.Key or C.SaveKey
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(SaveKey, false), "boolean", false)
  else
    _default = Checker(Default, "boolean", false)
  end

  local cfg = {
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(value)
      SafeSet(SaveKey, value)
      Callback(value)
    end,
  }
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddToggle(cfg)
end

-- ── Button ─────────────────────────────────────────
-- Icon opsional: ID custom, atau "" untuk TANPA icon.
-- (Catatan: icon hardcoded versi lama dihapus — pakai
--  Icon = "rbxassetid://16932740082" untuk tampilan lama)
function FuncsV3:Button(Tab, Name, Content, Callback, Icon)
  local Tooltip
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Callback = Arg(C, 3, "Callback", nil)
    Icon     = Arg(C, 4, "Icon", nil)
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)

  local cfg = { Title = Name, Content = Content, Callback = Callback }
  if Icon ~= nil then cfg.Icon = tostring(Icon) end
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddButton(cfg)
end

-- ── Dropdown ───────────────────────────────────────
-- Default: string (single) / table (multi) ATAU "Save"
function FuncsV3:Dropdown(Tab, Name, Content, Multi, Options, Default, Callback, Key)
  local Tooltip
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Multi    = Arg(C, 3, "Multi", false) == true
    Options  = Arg(C, 4, "Options", {})
    Default  = Arg(C, 5, "Default", nil)
    Callback = Arg(C, 6, "Callback", nil)
    Key      = C.Key or C.SaveKey
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Multi    = Checker(Multi, "boolean", false)
  Options  = Checker(Options, "table", {})
  Callback = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    local saved = SafeGet(SaveKey, nil)
    if Multi then
      _default = CleanTable(saved)
    else
      -- FIX v2.0: single-select = string (dulu dipaksa jadi table)
      _default = (type(saved) == "table")
        and tostring(saved[1] or "")
        or Checker(saved, "string", "")
    end
  else
    if Multi then
      _default = CleanTable(Default)
    else
      _default = (type(Default) == "table")
        and tostring(Default[1] or "")
        or Checker(Default, "string", "")
    end
  end

  local cfg = {
    Title    = Name,
    Content  = Content,
    Multi    = Multi,
    Options  = Options,
    Default  = _default,
    Callback = function(value)
      SafeSet(SaveKey, value)
      Callback(value)
    end,
  }
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddDropdown(cfg)
end

-- ── Textbox ────────────────────────────────────────
-- Default: string ATAU "Save"
function FuncsV3:Textbox(Tab, Name, Content, Default, Callback, Key)
  local Tooltip, Placeholder
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip     = Arg(C, nil, "Tooltip", "")
    Placeholder = Arg(C, nil, "Placeholder", nil)
    Name        = Arg(C, 1, "Title", "")
    Content     = Arg(C, 2, "Content", "")
    Default     = Arg(C, 3, "Default", "")
    Callback    = Arg(C, 4, "Callback", nil)
    Key         = C.Key or C.SaveKey
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(SaveKey, ""), "string", "")
  else
    _default = Checker(Default, "string", "")
  end

  local cfg = {
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(value)
      SafeSet(SaveKey, value)
      Callback(value)
    end,
  }
  if Placeholder ~= nil then cfg.Placeholder = tostring(Placeholder) end
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddInput(cfg)
end

-- ── Slider ─────────────────────────────────────────
-- Default: number ATAU "Save". Increment opsional (default 1)
function FuncsV3:Slider(Tab, Name, Content, Min, Max, Default, Callback, Increment, Key)
  local Tooltip
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Min      = Arg(C, 3, "Min", 0)
    Max      = Arg(C, 4, "Max", 100)
    Default  = Arg(C, 5, "Default", nil)
    Callback = Arg(C, 6, "Callback", nil)
    Increment = Arg(C, 7, "Increment", 1)
    Key       = C.Key or C.SaveKey
  end

  Name      = Checker(Name, "string", tostring(Name))
  Content   = Checker(Content, "string", tostring(Content))
  Min       = Checker(Min, "number", 0)
  Max       = Checker(Max, "number", 100)
  if Max <= Min then Max = Min + 1 end
  Increment = Checker(Increment, "number", 1)
  if Increment <= 0 then Increment = 1 end
  Callback  = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    _default = tonumber(SafeGet(SaveKey, nil)) or Min
  else
    _default = tonumber(Default) or Min
  end
  _default = math.clamp(_default, Min, Max)

  local cfg = {
    Title     = Name,
    Content   = Content,
    Increment = Increment,
    Min       = Min,
    Max       = Max,
    Default   = _default,
    Callback  = function(value)
      SafeSet(SaveKey, value)
      Callback(value)
    end,
  }
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddSlider(cfg)
end

-- ── Keybind (BARU v2.0) ────────────────────────────
-- Default: Enum.KeyCode ATAU "Save"
-- Tersimpan otomatis sebagai nama key (string, JSON-safe).
-- Simpan terjadi saat key ditekan atau via Obj:Set().
function FuncsV3:Keybind(Tab, Name, Content, Default, Callback, Key)
  local Tooltip
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Default  = Arg(C, 3, "Default", nil)
    Callback = Arg(C, 4, "Callback", nil)
    Key      = C.Key or C.SaveKey
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    _default = ParseKeyCode(SafeGet(SaveKey, nil)) or Enum.KeyCode.Unknown
  else
    _default = ParseKeyCode(Default) or Enum.KeyCode.Unknown
  end

  local cfg = {
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(key)
      SafeSet(SaveKey, key and key.Name or "")
      Callback(key)
    end,
  }
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end

  local Obj = Tab:AddKeybind(cfg)

  -- simpan juga saat key diganti programatik lewat Obj:Set()
  if type(Obj) == "table" and type(Obj.Set) == "function" then
    local RawSet = Obj.Set
    Obj.Set = function(self, NewKey, fire)
      RawSet(self, NewKey, fire)
      if typeof(NewKey) == "EnumItem" then
        SafeSet(SaveKey, NewKey.Name)
      end
    end
  end

  return Obj
end

-- ── ColorPicker (BARU v2.0) ────────────────────────
-- Default: Color3 ATAU "Save"
-- Warna tersimpan otomatis sebagai {R, G, B} (JSON-safe).
function FuncsV3:ColorPicker(Tab, Name, Content, Default, Callback, Key)
  local Tooltip, Presets
  if type(Name) == "table" and Content == nil then
    local C = Name
    Tooltip  = Arg(C, nil, "Tooltip", "")
    Presets  = Arg(C, nil, "Presets", nil)
    Name     = Arg(C, 1, "Title", "")
    Content  = Arg(C, 2, "Content", "")
    Default  = Arg(C, 3, "Default", nil)
    Callback = Arg(C, 4, "Callback", nil)
    Key      = C.Key or C.SaveKey
  end

  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)
  local SaveKey = ResolveKey(Key, Name)

  local _default
  if Default == "Save" then
    _default = ParseColor(SafeGet(SaveKey, nil)) or Color3.fromRGB(255, 0, 0)
  else
    _default = Checker(Default, "Color3", Color3.fromRGB(255, 0, 0))
  end

  local cfg = {
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(color)
      SafeSet(SaveKey, color) -- auto-serialize Color3 → {R,G,B}
      Callback(color)
    end,
  }
  if Presets ~= nil then cfg.Presets = Presets end
  if Tooltip and Tooltip ~= "" then cfg.Tooltip = Tooltip end
  return Tab:AddColorPicker(cfg)
end

-- ── Panel (BARU v2.0) ──────────────────────────────
function FuncsV3:Panel(Tab, Title, Content)
  if type(Title) == "table" and Content == nil then
    local C = Title
    Title, Content = Arg(C, 1, "Title", ""), Arg(C, 2, "Content", "")
  end
  return Tab:AddPanel({
    Title   = tostring(Title or ""),
    Content = tostring(Content or ""),
  })
end

-- ── Paragraph ──────────────────────────────────────
function FuncsV3:Paragraph(Tab, Title, Content)
  if type(Title) == "table" and Content == nil then
    local C = Title
    Title, Content = Arg(C, 1, "Title", ""), Arg(C, 2, "Content", "")
  end
  return Tab:AddParagraph({
    Title   = tostring(Title or ""),
    Content = tostring(Content or ""),
  })
end

-- ── Seperator ──────────────────────────────────────
function FuncsV3:Seperator(Tab, Title)
  if type(Title) == "table" then
    Title = Arg(Title, 1, "Title", "")
  end
  return Tab:AddSeperator({ Title = tostring(Title or "") })
end

-- ── Line ───────────────────────────────────────────
function FuncsV3:Line(Tab)
  return Tab:AddLine()
end

-- ───────────────────────────────────────────────────
--  ALIASES
-- ───────────────────────────────────────────────────
FuncsV3.Input        = FuncsV3.Textbox     -- nama alternatif
FuncsV3.Separator    = FuncsV3.Seperator   -- ejaan benar
FuncsV3.Notification = FuncsV3.Notify

return FuncsV3
