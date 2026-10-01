--[[
╔══════════════════════════════════════════════════╗
║     KING AKBAR UI — FUNCSV3 WRAPPER (v1.5)       ║
║       github.com/Akbar025zzz/kingAkbarUi-Speedhub ║
║                                                  ║
║  Shortcut pemakaian library + auto-save config.  ║
║  Baru v1.5: wrapper ColorPicker & Keybind        ║
║  (ikut ke-save), ThemePicker + ApplySavedTheme.  ║
╚══════════════════════════════════════════════════╝
]]
local FuncsV3 = {}

-- ─────────── INTERNAL STATE ───────────
local SaveConfig = nil
local Store      = nil
local AutoSave   = true

-- ─────────── HELPERS ───────────
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
	if SaveConfig[key] == value then return end
	SaveConfig[key] = value
	if AutoSave and type(Store) == "function" and not SavePending then
		SavePending = true
		task.delay(0.5, function()
			SavePending = false
			local ok, err = pcall(Store, SaveConfig)
			if not ok then warn("[FuncsV3] Gagal menyimpan config: " .. tostring(err)) end
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
-- serialisasi Color3 <-> hex (biar bisa masuk JSON)
local function ColorToHex(c)
	if typeof(c) ~= "Color3" then return nil end
	return string.format("#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end
local function HexToColor(hex)
	if type(hex) ~= "string" then return nil end
	local r, g, b = hex:upper():match("^#?(%x%x)(%x%x)(%x%x)$")
	if not r then return nil end
	return Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end

-- ─────────── PUBLIC SETUP ───────────
function FuncsV3:SetTable(path, storeFn)
	SaveConfig = Checker(path, "table", {})
	Store = storeFn
	return FuncsV3
end
function FuncsV3:GetTable() return SaveConfig or {} end
function FuncsV3:SetAutoSave(state) AutoSave = not not state end

-- ─────────── THEME INTEGRATION ───────────
-- ambil nama theme tersimpan (panggil SEBELUM CreateWindow)
function FuncsV3:GetSavedTheme(fallback)
	local t = SafeGet("__Theme", nil)
	if type(t) == "string" and t ~= "" then return t end
	return fallback or "Dark"
end
-- terapkan theme tersimpan ke library (sebelum CreateWindow)
function FuncsV3:ApplySavedTheme(Lib, ThemesTable, fallback)
	if type(ThemesTable) ~= "table" or type(ThemesTable.Apply) ~= "function" then return false end
	local name = FuncsV3:GetSavedTheme(fallback)
	return ThemesTable.Apply(Lib, name)
end
-- dropdown pemilih theme (disave; aktif penuh di execute berikutnya)
function FuncsV3:ThemePicker(Tab, Lib, ThemesTable, OnPick)
	ThemesTable = Checker(ThemesTable, "table", {})
	local names = (type(ThemesTable.Names) == "function") and ThemesTable.Names() or {}
	if #names == 0 then
		for k, v in pairs(ThemesTable) do
			if type(v) == "table" and v.Primary then table.insert(names, k) end
		end
		table.sort(names)
	end
	local saved = FuncsV3:GetSavedTheme()
	return Tab:AddDropdown({
		Title   = "Theme",
		Content = "Aktif penuh saat execute berikutnya",
		Multi   = false,
		Options = names,
		Default = { saved },
		Callback = function(value)
			local name = value[1]
			if not name then return end
			SafeSet("__Theme", name)
			if type(ThemesTable.Apply) == "function" then ThemesTable.Apply(Lib, name) end
			if type(OnPick) == "function" then OnPick(name) end
		end,
	})
end

-- ─────────── WRAPPERS ───────────
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
		Title = Name, Content = Content, Default = _default,
		Callback = function(value) SafeSet(Name, value) Callback(value) end,
	})
end
function FuncsV3:Button(Tab, Name, Content, Callback)
	Name     = Checker(Name, "string", tostring(Name))
	Content  = Checker(Content, "string", tostring(Content))
	Callback = Checker(Callback, "function", function() end)
	return Tab:AddButton({
		Title = Name, Content = Content,
		Icon = "rbxassetid://16932740082", Callback = Callback,
	})
end
function FuncsV3:Dropdown(Tab, Name, Content, Multi, Options, Default, Callback)
	Name     = Checker(Name, "string", tostring(Name))
	Content  = Checker(Content, "string", tostring(Content))
	Multi    = Checker(Multi, "boolean", false)
	Options  = Checker(Options, "table", {})
	Callback = Checker(Callback, "function", function() end)
	local _default
	if Default == "Save" then
		_default = CleanTable(SafeGet(Name, nil))
	else
		_default = CleanTable(Default)
	end
	return Tab:AddDropdown({
		Title = Name, Content = Content, Multi = Multi,
		Options = Options, Default = _default,
		Callback = function(value) SafeSet(Name, value) Callback(value) end,
	})
end
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
		Title = Name, Content = Content, Default = _default,
		Callback = function(value) SafeSet(Name, value) Callback(value) end,
	})
end
function FuncsV3:Slider(Tab, Name, Content, Min, Max, Default, Callback, Increment)
	Name      = Checker(Name, "string", tostring(Name))
	Content   = Checker(Content, "string", tostring(Content))
	Min       = Checker(Min, "number", 0)
	Max       = Checker(Max, "number", 100)
	Increment = Checker(Increment, "number", 1)
	Callback  = Checker(Callback, "function", function() end)
	local _default
	if Default == "Save" then
		_default = Checker(SafeGet(Name, Min), "number", Min)
	else
		_default = Checker(Default, "number", Min)
	end
	_default = math.clamp(_default, Min, Max)
	return Tab:AddSlider({
		Title = Name, Content = Content, Increment = Increment,
		Min = Min, Max = Max, Default = _default,
		Callback = function(value) SafeSet(Name, value) Callback(value) end,
	})
end
-- BARU v1.5: ColorPicker (disave sebagai hex)
function FuncsV3:ColorPicker(Tab, Name, Content, Default, Callback)
	Name     = Checker(Name, "string", tostring(Name))
	Content  = Checker(Content, "string", tostring(Content))
	Callback = Checker(Callback, "function", function() end)
	local _default
	if Default == "Save" then
		_default = HexToColor(SafeGet(Name, nil)) or Color3.fromRGB(255, 255, 255)
	elseif typeof(Default) == "Color3" then
		_default = Default
	else
		_default = Color3.fromRGB(255, 255, 255)
	end
	return Tab:AddColorPicker({
		Title = Name, Content = Content, Default = _default,
		Callback = function(c) SafeSet(Name, ColorToHex(c)) Callback(c) end,
	})
end
-- BARU v1.5: Keybind (disave sebagai nama keycode, "" = none)
function FuncsV3:Keybind(Tab, Name, Content, Default, Callback, OnChange)
	Name     = Checker(Name, "string", tostring(Name))
	Content  = Checker(Content, "string", tostring(Content))
	Callback = Checker(Callback, "function", function() end)
	local _default = Enum.KeyCode.Unknown
	if Default == "Save" then
		local saved = SafeGet(Name, "")
		if type(saved) == "string" and saved ~= "" then
			local ok, kc = pcall(function() return Enum.KeyCode[saved] end)
			if ok and kc then _default = kc end
		end
	elseif typeof(Default) == "EnumItem" then
		_default = Default
	end
	return Tab:AddKeybind({
		Title = Name, Content = Content, Default = _default, Callback = Callback,
		OnChange = function(k)
			SafeSet(Name, (k == Enum.KeyCode.Unknown) and "" or k.Name)
			if type(OnChange) == "function" then OnChange(k) end
		end,
	})
end
function FuncsV3:Paragraph(Tab, Title, Content)
	return Tab:AddParagraph({
		Title   = Checker(Title, "string", ""),
		Content = Checker(Content, "string", ""),
	})
end
function FuncsV3:Seperator(Tab, Title)
	return Tab:AddSeperator({ Title = Checker(Title, "string", "") })
end
function FuncsV3:Line(Tab) return Tab:AddLine() end
return FuncsV3
