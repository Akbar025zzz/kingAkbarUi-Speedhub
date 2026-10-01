--[[
  ╔══════════════════════════════════════════════════╗
  ║         KING AKBAR UI — FUNCSV3 WRAPPER          ║
  ║                  v1.1 (FIXED)                    ║
  ╚══════════════════════════════════════════════════╝
]]

local FuncsV3 = {}

-- ───────────────────────────────────────────────────
--  INTERNAL STATE
-- ───────────────────────────────────────────────────
local SaveConfig = nil
local Store      = nil
local AutoSave   = true
local SavePending = false

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

-- banding dua value (deep compare buat table)
local function DeepEqual(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for k, v in pairs(a) do
    if not DeepEqual(v, b[k]) then return false end
  end
  for k in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

local function DoStore()
  if not AutoSave then return end
  if type(Store) == "function" and type(SaveConfig) == "table" then
    local ok, err = pcall(Store, SaveConfig)
    if not ok then warn("[FuncsV3] Gagal menyimpan config: " .. tostring(err)) end
  end
end

local function SafeSet(key, value)
  if type(SaveConfig) ~= "table" then return end
  if DeepEqual(SaveConfig[key], value) then return end
  SaveConfig[key] = value
  if AutoSave and not SavePending then
    SavePending = true
    task.delay(0.5, function()
      SavePending = false
      DoStore()
    end)
  end
end

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

-- ───────────────────────────────────────────────────
--  PUBLIC SETUP
-- ───────────────────────────────────────────────────
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
  if AutoSave then DoStore() end -- ✅ flush saat nyala
end

function FuncsV3:Flush()
  DoStore()
end

-- ───────────────────────────────────────────────────
--  WRAPPERS
-- ───────────────────────────────────────────────────
function FuncsV3:Toggle(Tab, Name, Content, Default, Callback, Flag)
  Name     = Checker(Name,     "string",   tostring(Name or ""))
  Content  = Checker(Content,  "string",   tostring(Content or ""))
  Callback = Checker(Callback, "function", function() end)
  local Key = Flag or Name

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Key, false), "boolean", false)
  else
    _default = Checker(Default, "boolean", false)
  end

  return Tab:AddToggle({
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(value)
      SafeSet(Key, value)
      Callback(value)
    end,
  })
end

function FuncsV3:Button(Tab, Name, Content, Callback)
  Name     = Checker(Name,     "string",   tostring(Name or ""))
  Content  = Checker(Content,  "string",   tostring(Content or ""))
  Callback = Checker(Callback, "function", function() end)

  return Tab:AddButton({
    Title    = Name,
    Content  = Content,
    Icon     = "rbxassetid://16932740082",
    Callback = Callback,
  })
end

function FuncsV3:Dropdown(Tab, Name, Content, Multi, Options, Default, Callback, Flag)
  Name     = Checker(Name,     "string",   tostring(Name or ""))
  Content  = Checker(Content,  "string",   tostring(Content or ""))
  Multi    = Checker(Multi,    "boolean",  false)
  Options  = Checker(Options,  "table",    {})
  Callback = Checker(Callback, "function", function() end)
  local Key = Flag or Name

  local _default
  if Default == "Save" then
    _default = CleanTable(SafeGet(Key, nil))
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
      SafeSet(Key, CleanTable(value))
      Callback(value)
    end,
  })
end

function FuncsV3:Textbox(Tab, Name, Content, Default, Callback, Flag)
  Name     = Checker(Name,     "string",   tostring(Name or ""))
  Content  = Checker(Content,  "string",   tostring(Content or ""))
  Callback = Checker(Callback, "function", function() end)
  local Key = Flag or Name

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Key, ""), "string", "")
  else
    _default = Checker(Default, "string", "")
  end

  return Tab:AddInput({
    Title    = Name,
    Content  = Content,
    Default  = _default,
    Callback = function(value)
      SafeSet(Key, value)
      Callback(value)
    end,
  })
end

function FuncsV3:Slider(Tab, Name, Content, Min, Max, Default, Callback, Increment, Flag)
  Name      = Checker(Name,      "string",   tostring(Name or ""))
  Content   = Checker(Content,   "string",   tostring(Content or ""))
  Min       = Checker(Min,       "number",   0)
  Max       = Checker(Max,       "number",   100)
  Increment = Checker(Increment, "number",   1)
  Callback  = Checker(Callback,  "function", function() end)
  local Key = Flag or Name

  local _default
  if Default == "Save" then
    _default = Checker(SafeGet(Key, Min), "number", Min)
  else
    _default = Checker(Default, "number", Min)
  end

  _default = math.clamp(_default, Min, Max)

  return Tab:AddSlider({
    Title     = Name,
    Content   = Content,
    Increment = Increment,
    Min       = Min,
    Max       = Max,
    Default   = _default,
    Callback  = function(value)
      SafeSet(Key, value)
      Callback(value)
    end,
  })
end

function FuncsV3:Paragraph(Tab, Title, Content)
  return Tab:AddParagraph({
    Title   = Checker(Title,   "string", ""),
    Content = Checker(Content, "string", ""),
  })
end

function FuncsV3:Seperator(Tab, Title)
  return Tab:AddSeperator({
    Title = Checker(Title, "string", ""),
  })
end

function FuncsV3:Line(Tab)
  return Tab:AddLine()
end

return FuncsV3
