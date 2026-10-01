-- [[ UI WRAPPER & CONFIG HELPER ]] --
-- Kompatibel dengan SpeedHub / AkbarUI Library

local UIWrapper = {}
local SaveConfig = nil

-- Safe type checker
local function Check(val, expectedType, default)
    return typeof(val) == expectedType and val or default
end

-- Ambil nilai aman dari SaveConfig
local function GetSaved(key, default)
    if type(SaveConfig) == "table" and SaveConfig[key] ~= nil then
        return SaveConfig[key]
    end
    return default
end

-- Simpan nilai langsung ke SaveConfig
local function SetSaved(key, value)
    if type(SaveConfig) == "table" and key then
        SaveConfig[key] = value
    end
end

-- Inisialisasi tabel config yang akan dipakai
function UIWrapper:SetTable(targetTable)
    SaveConfig = type(targetTable) == "table" and targetTable or {}
    return SaveConfig
end

-- Mendapatkan referensi tabel config aktif
function UIWrapper:GetTable()
    return SaveConfig
end

-- ==================== WRAPPER ELEMEN ==================== --

-- Toggle
function UIWrapper:Toggle(Tab, Name, Content, Default, Callback, CustomKey)
    local key = CustomKey or Name
    Name = Check(Name, "string", tostring(Name or "Toggle"))
    Content = Check(Content, "string", tostring(Content or ""))
    Callback = Check(Callback, "function", function() end)

    local initial = (Default == "Save") and GetSaved(key, false) or Check(Default, "boolean", false)
    SetSaved(key, initial)

    return Tab:AddToggle({
        Title = Name,
        Content = Content,
        Default = initial,
        Flag = key,
        Callback = function(value)
            SetSaved(key, value)
            Callback(value)
        end
    })
end

-- Button
function UIWrapper:Button(Tab, Name, Content, Callback, Icon)
    Name = Check(Name, "string", tostring(Name or "Button"))
    Content = Check(Content, "string", tostring(Content or ""))
    Callback = Check(Callback, "function", function() end)
    Icon = Check(Icon, "string", "rbxassetid://16932740082")

    return Tab:AddButton({
        Title = Name,
        Content = Content,
        Icon = Icon,
        Callback = Callback
    })
end

-- Slider
function UIWrapper:Slider(Tab, Name, Content, Min, Max, Increment, Default, Callback, CustomKey)
    local key = CustomKey or Name
    Name = Check(Name, "string", tostring(Name or "Slider"))
    Content = Check(Content, "string", tostring(Content or ""))
    Min = Check(Min, "number", 0)
    Max = Check(Max, "number", 100)
    Increment = Check(Increment, "number", 1)
    Callback = Check(Callback, "function", function() end)

    local initial = (Default == "Save") and GetSaved(key, Min) or Check(Default, "number", Min)
    SetSaved(key, initial)

    return Tab:AddSlider({
        Title = Name,
        Content = Content,
        Min = Min,
        Max = Max,
        Increment = Increment,
        Default = initial,
        Flag = key,
        Callback = function(value)
            SetSaved(key, value)
            Callback(value)
        end
    })
end

-- Dropdown
function UIWrapper:Dropdown(Tab, Name, Content, Multi, Options, Default, Callback, CustomKey)
    local key = CustomKey or Name
    Name = Check(Name, "string", tostring(Name or "Dropdown"))
    Content = Check(Content, "string", tostring(Content or ""))
    Multi = Check(Multi, "boolean", false)
    Options = Check(Options, "table", {})
    Callback = Check(Callback, "function", function() end)

    local initial
    if Default == "Save" then
        local savedVal = GetSaved(key, Multi and {} or (Options[1] or ""))
        initial = type(savedVal) == "table" and savedVal or { tostring(savedVal) }
    else
        initial = type(Default) == "table" and Default or { tostring(Default or (Options[1] or "")) }
    end

    SetSaved(key, initial)

    return Tab:AddDropdown({
        Title = Name,
        Content = Content,
        Multi = Multi,
        Options = Options,
        Default = initial,
        Flag = key,
        Callback = function(value)
            SetSaved(key, value)
            Callback(value)
        end
    })
end

-- Textbox / Input
function UIWrapper:Textbox(Tab, Name, Content, Default, Callback, CustomKey)
    local key = CustomKey or Name
    Name = Check(Name, "string", tostring(Name or "Input"))
    Content = Check(Content, "string", tostring(Content or ""))
    Callback = Check(Callback, "function", function() end)

    local initial = (Default == "Save") and tostring(GetSaved(key, "")) or tostring(Default or "")
    SetSaved(key, initial)

    return Tab:AddInput({
        Title = Name,
        Content = Content,
        Default = initial,
        Flag = key,
        Callback = function(value)
            SetSaved(key, value)
            Callback(value)
        end
    })
end

-- Paragraph
function UIWrapper:Paragraph(Tab, Name, Content)
    return Tab:AddParagraph({
        Title = tostring(Name or "Info"),
        Content = tostring(Content or "")
    })
end

-- Alias backward compatibility
UIWrapper.FuncsV3 = UIWrapper

return UIWrapper
