--[[
╔══════════════════════════════════════════════════════╗
║    KING AKBAR UI — LOADER (SATU LINK, SEMUA FILE)    ║
║    github.com/Akbar025zzz/kingAkbarUi-Speedhub       ║
╚══════════════════════════════════════════════════════╝
PAKAI (cukup satu baris):

  local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/loader.lua"
  ))()

Hasil:
  UI.Lib      → library inti (CreateWindow, Notify, SetTheme...)
  UI.Themes   → preset tema (Apply, Names...)
  UI.FuncsV3  → wrapper auto-save (Toggle, Slider, ThemePicker...)
  UI:QuickHub() → shortcut config + theme + window sekaligus
]]

local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"

local function pull(name)
	local ok, src = pcall(game.HttpGet, game, BASE .. name)
	if not ok or type(src) ~= "string" or #src < 32 then
		error("[KingAkbarUI] Gagal download " .. name, 2)
	end
	local fn, err = (loadstring or load)(src, "@" .. name)
	if not fn then
		error("[KingAkbarUI] Syntax error di " .. name .. ": " .. tostring(err), 2)
	end
	return fn()
end

local UI = {}
UI.Base    = BASE
UI.Lib     = pull("init.lua")
UI.Themes  = pull("themes.lua")
UI.FuncsV3 = pull("wrapper.lua")

function UI:Notify(title, desc, content)
	return UI.Lib:SetNotification({ title, desc, content })
end

-- ═══ Shortcut: auto-save + theme tersimpan + window ═══
function UI:QuickHub(opts)
	opts = type(opts) == "table" and opts or {}
	local Http = game:GetService("HttpService")
	local file = opts.File or "kingakbar_config.json"

	-- muat config tersimpan
	local cfg = {}
	if isfile and isfile(file) then
		local ok, d = pcall(readfile, file)
		if ok then pcall(function() cfg = Http:JSONDecode(d) end) end
	end
	UI.FuncsV3:SetTable(cfg, function(t)
		if writefile then writefile(file, Http:JSONEncode(t)) end
	end)

	-- theme sesuai save-an (WAJIB sebelum CreateWindow)
	UI.FuncsV3:ApplySavedTheme(UI.Lib, UI.Themes, opts.Theme or "Dark")

	local winCfg = opts.Window or {
		opts.Title or "King Akbar", opts.Desc or "v1.5",
		112, UDim2.fromOffset(460, 300),
	}
	return UI.Lib:CreateWindow(winCfg)
end

return UI
