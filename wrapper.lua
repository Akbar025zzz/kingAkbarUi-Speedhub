--[[
  ╔══════════════════════════════════════════════════╗
  ║         KING AKBAR UI — FUNCSV3 WRAPPER          ║
  ║       github.com/Akbar025zzz/kingAkbarUi-Speedhub ║
  ║                                                  ║
  ║  Shortcut untuk pemakaian library + auto-save    ║
  ║  konfigurasi user.                               ║
  ║                                                  ║
  ║  Usage:                                          ║
  ║    local FuncsV3 = loadstring(game:HttpGet(      ║
  ║      "https://raw.githubusercontent.com/"        ║
  ║      .."Akbar025zzz/kingAkbarUi-Speedhub/"       ║
  ║      .."main/wrapper.lua"))()                    ║
  ╚══════════════════════════════════════════════════╝
]]

local FuncsV3 = {}

-- ───────────────────────────────────────────────────
--  INTERNAL STATE
-- ───────────────────────────────────────────────────
local SaveConfig = nil
local Store      = nil
local AutoSave   = true

-- ───────────────────────────────────────────────────
--  HELPERS
-- ───────────────────────────────────────────────────
local function Checker(Val, ValType, Fallback)
  if typeof(Val) == ValType then return Val end
  return Fallback
end

local function SafeGet(key, fallback)
  if type(SaveConfig) ~= "table" then return fallback end
  local v = SaveConfig[key]
  if v == nil then return fallback end
  return v
end

local SavePending = false

local function SafeSet(key, value)
  if type(SaveConfig) ~= "table" then return end
  if SaveConfig[key] == value then return end -- tidak berubah, tidak perlu simpan
  SaveConfig[key] = value
  -- debounce: banyak perubahan beruntun (mis. saat load) cukup 1x simpan
  if AutoSave and type(Store) == "function" and not SavePending then
    SavePending = true
    task.delay(0.5, function()
      SavePending = false
      local ok, err = pcall(Store, SaveConfig)
      if not ok then warn("[FuncsV3] Gagal menyimpan config: " .. tostring(err)) end
    end)
  end
end

-- Bersihkan tabel dari nilai nil / kosong
local function CleanTable(t)
  local out = {}
  if type(t) ~= "table" then
    if t ~= nil and t ~= "" then
      table.insert(out, t)
    end
    return out
  end
  for _, v in ipairs(t) do
    if v ~= nil and v ~= "" then
      table.insert(out, v)
    end
  end
  return out
end

-- ───────────────────────────────────────────────────
--  PUBLIC SETUP
-- ───────────────────────────────────────────────────
-- path    : table, contoh: getgenv().MyHubConfig atau shared.Config
-- storeFn : optional function(config) → dipanggil setiap kali config berubah
function FuncsV3:SetTable(path, storeFn)
  SaveConfig = Checker(path, "table", {})
  Store = storeFn
  return FuncsV3
end

function FuncsV3:GetTable()
  return SaveConfig or {}
end

function FuncsV3:SetAutoSave(state)
  AutoSave = not not state
end

-- ───────────────────────────────────────────────────
--  WRAPPERS
-- ───────────────────────────────────────────────────

-- ── Toggle ─────────────────────────────────────────
-- Default: boolean ATAU "Save"
function FuncsV3:Toggle(Tab, Name, Content, Default, Callback)
  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Name, false), "boolean", false)
  else
    _default = Checker(Default, "boolean", false)
  end

  return Tab:AddToggle({
    Title   = Name,
    Content = Content,
    Default = _default,
    Callback = function(value)
      SafeSet(Name, value)
      Callback(value)
    end,
  })
end

-- ── Button ─────────────────────────────────────────
function FuncsV3:Button(Tab, Name, Content, Callback)
  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)

  return Tab:AddButton({
    Title    = Name,
    Content  = Content,
    Icon     = "rbxassetid://16932740082",
    Callback = Callback,
  })
end

-- ── Dropdown ───────────────────────────────────────
-- Default: table/string ATAU "Save"
function FuncsV3:Dropdown(Tab, Name, Content, Multi, Options, Default, Callback)
  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Multi    = Checker(Multi, "boolean", false)
  Options  = Checker(Options, "table", {})
  Callback = Checker(Callback, "function", function() end)

  -- hanya "Save" yang memuat data tersimpan; Default eksplisit selalu dihormati
  local _default
  if Default == "Save" then
    _default = CleanTable(SafeGet(Name, nil))
  else
    _default = CleanTable(Default)
  end

  return Tab:AddDropdown({
    Title    = Name,
    Content  = Content,
    Multi    = Multi,
    Options  = Options,
    Default  = _default,
    Callback = function(value)
      SafeSet(Name, value)
      Callback(value)
    end,
  })
end

-- ── Textbox ────────────────────────────────────────
-- Default: string ATAU "Save"
function FuncsV3:Textbox(Tab, Name, Content, Default, Callback)
  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Callback = Checker(Callback, "function", function() end)

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Name, ""), "string", "")
  else
    _default = Checker(Default, "string", "")
  end

  return Tab:AddInput({
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(value)
      SafeSet(Name, value)
      Callback(value)
    end,
  })
end

-- ── Slider ─────────────────────────────────────────
-- Default: number ATAU "Save"
-- Increment (opsional, argumen terakhir) default 1
function FuncsV3:Slider(Tab, Name, Content, Min, Max, Default, Callback, Increment)
  Name     = Checker(Name, "string", tostring(Name))
  Content  = Checker(Content, "string", tostring(Content))
  Min      = Checker(Min, "number", 0)
  Max      = Checker(Max, "number", 100)
  Increment = Checker(Increment, "number", 1)
  Callback = Checker(Callback, "function", function() end)

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Name, Min), "number", Min)
  else
    _default = Checker(Default, "number", Min)
  end

  _default = math.clamp(_default, Min, Max)

  return Tab:AddSlider({
    Title    = Name,
    Content  = Content,
    Increment = Increment,
    Min      = Min,
    Max      = Max,
    Default  = _default,
    Callback = function(value)
      SafeSet(Name, value)
      Callback(value)
    end,
  })
end

-- ── Paragraph ──────────────────────────────────────
function FuncsV3:Paragraph(Tab, Title, Content)
  return Tab:AddParagraph({
    Title   = Checker(Title,   "string", ""),
    Content = Checker(Content, "string", ""),
  })
end

-- ── Seperator ──────────────────────────────────────
function FuncsV3:Seperator(Tab, Title)
  return Tab:AddSeperator({
    Title = Checker(Title, "string", ""),
  })
end

-- ── Line ───────────────────────────────────────────
function FuncsV3:Line(Tab)
  return Tab:AddLine()
end

return FuncsV3
