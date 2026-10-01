-- 03-theme-switcher.lua — ganti tema dengan rebuild window otomatis
local BASE = "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/main/"
local Lib    = loadstring(game:HttpGet(BASE .. "init.lua"))()
local Themes = loadstring(game:HttpGet(BASE .. "themes.lua"))()

local CURRENT = nil
local function build(name)
	CURRENT = Themes.Apply(Lib, name) -- WAJIB sebelum CreateWindow
	local Win = Lib:CreateWindow({ "Theme Switcher", CURRENT, 112, UDim2.fromOffset(440, 300) })
	local Tab = Win:CreateTab({ "Theme" })
	local Sec = Tab:AddSection("Preset", true)
	Sec:AddParagraph({ "Aktif: " .. CURRENT, "Ganti tema = window di-rebuild." })
	Sec:AddDropdown({
		Title = "Theme", Content = tostring(#Themes.Names()) .. " preset",
		Multi = false, Options = Themes.Names(), Default = { CURRENT },
		Callback = function(v)
			local pick = v[1]
			if pick and pick ~= CURRENT then
				if getgenv then getgenv().KAU_Theme = pick end
				Win:Destroy()
				build(pick)
			end
		end,
	})
end
build((getgenv and getgenv().KAU_Theme) or "Dark")
