--[[
KING AKBAR UI — THEME PRESETS (v1.5)
github.com/Akbar025zzz/kingAkbarUi-Speedhub
]]
local Themes = {}
Themes.List = {}
local WindowOverrides = {}
local function Def(name, colors, ov)
	Themes[name] = colors
	WindowOverrides[name] = ov
	table.insert(Themes.List, name)
end

Def("Mono", {
	Primary = Color3.fromRGB(255, 255, 255), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(5, 5, 5), Secondary = Color3.fromRGB(22, 22, 22),
	Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(155, 155, 155),
	Stroke = Color3.fromRGB(255, 255, 255), Divider = Color3.fromRGB(120, 120, 120),
	LineColor = Color3.fromRGB(255, 255, 255),
})
Def("Dark", {
	Primary = Color3.fromRGB(255, 255, 255), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(10, 10, 10), Secondary = Color3.fromRGB(25, 25, 25),
	Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(160, 160, 160),
	Stroke = Color3.fromRGB(70, 70, 70), Divider = Color3.fromRGB(80, 80, 80),
	LineColor = Color3.fromRGB(110, 110, 110),
})
Def("Neon", {
	Primary = Color3.fromRGB(0, 255, 180), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(10, 10, 20), Secondary = Color3.fromRGB(20, 20, 40),
	Text = Color3.fromRGB(0, 255, 180), SubText = Color3.fromRGB(120, 200, 180),
	Stroke = Color3.fromRGB(0, 200, 140), Divider = Color3.fromRGB(0, 180, 130),
	LineColor = Color3.fromRGB(0, 220, 160),
})
Def("Cyberpunk", {
	Primary = Color3.fromRGB(255, 0, 200), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(15, 5, 30), Secondary = Color3.fromRGB(40, 10, 60),
	Text = Color3.fromRGB(255, 200, 255), SubText = Color3.fromRGB(180, 130, 220),
	Stroke = Color3.fromRGB(255, 0, 200), Divider = Color3.fromRGB(200, 0, 180),
	LineColor = Color3.fromRGB(220, 50, 220),
})
Def("BloodRed", {
	Primary = Color3.fromRGB(255, 30, 30), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(10, 5, 5), Secondary = Color3.fromRGB(30, 10, 10),
	Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(180, 120, 120),
	Stroke = Color3.fromRGB(150, 30, 30), Divider = Color3.fromRGB(100, 20, 20),
	LineColor = Color3.fromRGB(180, 40, 40),
})
Def("Gold", {
	Primary = Color3.fromRGB(255, 200, 50), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(15, 12, 5), Secondary = Color3.fromRGB(35, 28, 15),
	Text = Color3.fromRGB(255, 240, 200), SubText = Color3.fromRGB(200, 170, 100),
	Stroke = Color3.fromRGB(200, 160, 40), Divider = Color3.fromRGB(150, 120, 30),
	LineColor = Color3.fromRGB(200, 170, 60),
})
Def("Purple", {
	Primary = Color3.fromRGB(180, 100, 255), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(15, 10, 25), Secondary = Color3.fromRGB(35, 20, 55),
	Text = Color3.fromRGB(240, 230, 255), SubText = Color3.fromRGB(170, 140, 200),
	Stroke = Color3.fromRGB(120, 70, 180), Divider = Color3.fromRGB(100, 60, 150),
	LineColor = Color3.fromRGB(140, 90, 200),
})
Def("Ocean", {
	Primary = Color3.fromRGB(0, 200, 255), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(5, 15, 25), Secondary = Color3.fromRGB(15, 35, 55),
	Text = Color3.fromRGB(220, 240, 255), SubText = Color3.fromRGB(120, 180, 220),
	Stroke = Color3.fromRGB(0, 130, 200), Divider = Color3.fromRGB(20, 100, 160),
	LineColor = Color3.fromRGB(40, 140, 200),
})
Def("Light", {
	Primary = Color3.fromRGB(0, 100, 220), Panel = Color3.fromRGB(0, 0, 0),
	Background = Color3.fromRGB(240, 240, 245), Secondary = Color3.fromRGB(210, 210, 220),
	Text = Color3.fromRGB(20, 20, 30), SubText = Color3.fromRGB(100, 100, 110),
	Stroke = Color3.fromRGB(180, 180, 190), Divider = Color3.fromRGB(200, 200, 210),
	LineColor = Color3.fromRGB(160, 160, 170),
}, { BackgroundImage = "", BackgroundTintTrans = 0 })
Def("Matrix", {
	Primary = Color3.fromRGB(0, 255, 0), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(0, 8, 0), Secondary = Color3.fromRGB(0, 25, 0),
	Text = Color3.fromRGB(0, 255, 0), SubText = Color3.fromRGB(0, 180, 0),
	Stroke = Color3.fromRGB(0, 150, 0), Divider = Color3.fromRGB(0, 100, 0),
	LineColor = Color3.fromRGB(0, 200, 0),
})
Def("Sunset", {
	Primary = Color3.fromRGB(255, 130, 30), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(25, 10, 15), Secondary = Color3.fromRGB(50, 20, 25),
	Text = Color3.fromRGB(255, 230, 200), SubText = Color3.fromRGB(220, 160, 130),
	Stroke = Color3.fromRGB(180, 80, 40), Divider = Color3.fromRGB(130, 60, 30),
	LineColor = Color3.fromRGB(200, 100, 50),
})
Def("Violet", {
	Primary = Color3.fromRGB(168, 120, 255), Panel = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(16, 14, 22), Secondary = Color3.fromRGB(32, 28, 46),
	Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(150, 145, 175),
	Stroke = Color3.fromRGB(95, 75, 150), Divider = Color3.fromRGB(70, 60, 105),
	LineColor = Color3.fromRGB(110, 90, 165),
})

local COLOR_KEYS = { "Primary", "Background", "Secondary", "Panel", "Text", "SubText", "Stroke", "Divider", "LineColor" }
function Themes.Apply(Lib, name)
	local t = Themes[name] or Themes.Mono
	local clean = {}
	for _, k in ipairs(COLOR_KEYS) do
		if t[k] then clean[k] = t[k] end
	end
	Lib:SetTheme(clean)
	local cfg = Lib:GetConfig()
	local ov = WindowOverrides[name]
	if type(ov) == "table" and type(cfg.Window) == "table" then
		for k, v in pairs(ov) do cfg.Window[k] = v end
	end
	return (Themes[name] and name) or "Mono"
end
function Themes.Names() return Themes.List end
function Themes.Exists(name) return type(Themes[name]) == "table" end
return Themes
