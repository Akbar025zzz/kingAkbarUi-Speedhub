--[[
  King Akbar UI — LOADER
  Memuat init.lua, themes.lua, dan wrapper.lua sekaligus (dengan retry otomatis).

  PEMAKAIAN:
    local KA = loadstring(game:HttpGet("https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/loader.lua"))()
    local Library, Themes, FuncsV3 = KA.Library, KA.Themes, KA.Wrapper

  Ganti branch/versi dengan mengisi getgenv().KingAkbarUI_Base sebelum memanggil loader ini.
]]

local Env  = (getgenv and getgenv()) or _G
local BASE = Env.KingAkbarUI_Base
  or "https://raw.githubusercontent.com/Akbar025zzz/kingAkbarUi-Speedhub/refs/heads/main/"

local function Fetch(File)
  local lastErr
  for attempt = 1, 3 do
    local ok, result = pcall(function()
      local src = game:HttpGet(BASE .. File)
      local fn, compileErr = loadstring(src)
      assert(fn, compileErr)
      return fn()
    end)
    if ok and result ~= nil then return result end
    lastErr = result
    task.wait(0.5 * attempt)
  end
  error(("[KingAkbarUI] Gagal memuat %s: %s"):format(File, tostring(lastErr)), 0)
end

local Library = Fetch("init.lua")
local Themes  = Fetch("themes.lua")
local Wrapper = Fetch("wrapper.lua")

return {
  Library = Library,
  Themes  = Themes,
  Wrapper = Wrapper,
}
