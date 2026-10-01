--[[
  ╔══════════════════════════════════════════════════════════╗
  ║                       AKBAR UI v1.0                      ║
  ║          Modern • Premium • Minimal • Responsive         ║
  ║   github.com/Akbar025zzz/kingAkbarUi-Speedhub            ║
  ╚══════════════════════════════════════════════════════════╝

  API:
    local AKBARUI = loadstring(game:HttpGet("URL"))()
    local Window  = AKBARUI:CreateWindow({...})
    local Tab     = Window:Tab({...})
    local Section = Tab:Section({...})
    local Group   = Section:Group({ Columns = 2 })
    Section:Button({...}) Section:Toggle({...}) etc.
    AKBARUI:Notify({...}) AKBARUI:Popup({...})
]]

-- ══════════════════════════════════════════════════════════
--  A. SERVICES & SETUP
-- ══════════════════════════════════════════════════════════
if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Stats            = game:GetService("Stats")

local Player = Players.LocalPlayer
if not Player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- Cleanup sisa execute ulang
local Env = (getgenv and getgenv()) or _G
if type(Env.AKBARUI_Cleanup) == "function" then pcall(Env.AKBARUI_Cleanup) end

local _Conns, _Guis = {}, {}
local function Track(c) table.insert(_Conns, c); return c end
local function TrackGui(g) table.insert(_Guis, g); return g end

Env.AKBARUI_Cleanup = function()
    for _, c in ipairs(_Conns) do pcall(function() c:Disconnect() end) end
    for _, g in ipairs(_Guis)  do pcall(function() g:Destroy() end) end
    table.clear(_Conns); table.clear(_Guis)
end

pcall(function()
    local roots = { Player:FindFirstChild("PlayerGui") }
    pcall(function() table.insert(roots, CoreGui) end)
    pcall(function() if gethui then table.insert(roots, gethui()) end end)
    for _, r in ipairs(roots) do
        if r then
            for _, c in ipairs(r:GetChildren()) do
                if c:IsA("ScreenGui") and string.sub(c.Name, 1, 8) == "AKBARUI_" then
                    c:Destroy()
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--  B. THEME SYSTEM
-- ══════════════════════════════════════════════════════════
local Themes = {
    Dark = {
        Background    = Color3.fromRGB(14, 14, 18),
        Surface       = Color3.fromRGB(20, 20, 26),
        SurfaceHover  = Color3.fromRGB(28, 28, 36),
        Sidebar       = Color3.fromRGB(16, 16, 22),
        Topbar        = Color3.fromRGB(18, 18, 24),
        Accent        = Color3.fromRGB(122, 162, 255),
        AccentDim     = Color3.fromRGB(80, 110, 190),
        Text          = Color3.fromRGB(240, 240, 245),
        SubText       = Color3.fromRGB(150, 155, 170),
        MutedText     = Color3.fromRGB(100, 105, 120),
        Border        = Color3.fromRGB(38, 38, 48),
        BorderLight   = Color3.fromRGB(55, 55, 70),
        Success       = Color3.fromRGB(80, 200, 120),
        Warning       = Color3.fromRGB(240, 180, 60),
        Error         = Color3.fromRGB(220, 90, 90),
        Shadow        = Color3.fromRGB(0, 0, 0),
    },
}

local function Clone(t) local n = {} for k,v in pairs(t) do n[k]=v end return n end

local ActiveTheme = Clone(Themes.Dark)
local ThemesLookup = Themes  -- users can register more

-- ══════════════════════════════════════════════════════════
--  C. UTILITIES
-- ══════════════════════════════════════════════════════════
local Fonts = {
    Regular = Enum.Font.Gotham,
    Medium  = Enum.Font.GothamMedium,
    Bold    = Enum.Font.GothamBold,
    Semi    = Enum.Font.GothamSemibold,
}

local Assets = {
    Check        = "rbxassetid://6031090990",
    Chevron      = "rbxassetid://6031094678",
    Search       = "rbxassetid://3926305904",
    Close        = "rbxassetid://6031091004",
    Minimize     = "rbxassetid://6031090994",
    Lock         = "rbxassetid://6031090986",
    Menu         = "rbxassetid://6031090996",
    DefaultIcon  = "rbxassetid://7734010488",
}

local function New(cls, props, parent)
    local o = Instance.new(cls)
    if props then for k, v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function Corner(parent, r)
    return New("UICorner", { CornerRadius = r or UDim.new(0, 8) }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or ActiveTheme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function Pad(parent, t, b, l, r)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, parent)
end

local function Tween(o, props, time, style, dir)
    if not time or time <= 0 then
        for k, v in pairs(props) do o[k] = v end
        return
    end
    TweenService:Create(o,
        TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function TextWidth(t, size, font)
    local ok, b = pcall(function()
        return TextService:GetTextSize(t, size, font or Fonts.Medium, Vector2.new(1000, 100))
    end)
    return ok and b.X or (#t * size * 0.55)
end

local function Contrast(c)
    local l = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
    return l > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then warn("[AKBARUI] Callback error: " .. tostring(err)) end
end

local function Debounce(fn, wait)
    local last = 0
    return function(...)
        local now = tick()
        if now - last >= wait then last = now; return fn(...) end
    end
end

-- Viewport size
local function GetViewport()
    local cam = workspace.CurrentCamera
    if cam then
        local v = cam.ViewportSize
        return v.X, v.Y
    end
    return 1280, 720
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function NewScreenGui(name, order)
    local g = New("ScreenGui", {
        Name = name,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = order or 10,
    })
    local parented = false
    if not RunService:IsStudio() then
        if syn and syn.protect_gui then pcall(syn.protect_gui, g) end
        local ok = pcall(function()
            if gethui then g.Parent = gethui()
            elseif cloneref then g.Parent = cloneref(CoreGui)
            else g.Parent = CoreGui end
        end)
        parented = ok and g.Parent ~= nil
    end
    if not parented then g.Parent = Player:WaitForChild("PlayerGui") end
    TrackGui(g)
    return g
end

-- ══════════════════════════════════════════════════════════
--  D. RIPPLE + DRAG
-- ══════════════════════════════════════════════════════════
local function Ripple(btn, color)
    task.spawn(function()
        if not btn or not btn.Parent then return end
        btn.ClipsDescendants = true
        local w, h = btn.AbsoluteSize.X, btn.AbsoluteSize.Y
        local rel = UserInputService:GetMouseLocation() - btn.AbsolutePosition
        if rel.X < 0 or rel.Y < 0 or rel.X > w or rel.Y > h then
            rel = Vector2.new(w / 2, h / 2)
        end
        local circle = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(rel.X, rel.Y),
            Size = UDim2.fromOffset(0, 0),
            ZIndex = 50,
        }, btn)
        Corner(circle, UDim.new(1, 0))
        local size = math.max(w, h) * 2.4
        Tween(circle, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }, 0.55)
        task.wait(0.6)
        if circle then circle:Destroy() end
    end)
end

local function Draggable(handle, obj, conns)
    local drag, input, start, pos = false, nil, nil, nil
    table.insert(conns, handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag, input, start, pos = true, i, i.Position, obj.Position
        end
    end))
    table.insert(conns, UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        local t = i.UserInputType
        if t == Enum.UserInputType.MouseMovement
        or (t == Enum.UserInputType.Touch and i == input) then
            local d = i.Position - start
            obj.Position = UDim2.new(
                pos.X.Scale, pos.X.Offset + d.X,
                pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end))
    table.insert(conns, UserInputService.InputEnded:Connect(function(i)
        local t = i.UserInputType
        if t == Enum.UserInputType.MouseButton1
        or (t == Enum.UserInputType.Touch and i == input) then
            drag = false
        end
    end))
end

-- ══════════════════════════════════════════════════════════
--  E. CONFIG SYSTEM
-- ══════════════════════════════════════════════════════════
local ConfigFile = "AKBARUI_Config.json"
local ConfigData = {}
local HasFS = (type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function")

local function LoadConfigFile()
    if not HasFS then return {} end
    if not isfile(ConfigFile) then return {} end
    local ok, d = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    return (ok and type(d) == "table") and d or {}
end

local function SaveConfigFile(data)
    if not HasFS then return end
    local ok, enc = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then pcall(writefile, ConfigFile, enc) end
end

ConfigData = LoadConfigFile()
local ConfigDirty = false

local function SaveFlag(key, val)
    if not key then return end
    ConfigData[key] = val
    if not ConfigDirty then
        ConfigDirty = true
        task.delay(0.5, function()
            ConfigDirty = false
            SaveConfigFile(ConfigData)
        end)
    end
end

-- ══════════════════════════════════════════════════════════
--  F. NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════
local NotifGui, NotifHolder, NotifOrder

local function EnsureNotif()
    if NotifGui and NotifGui.Parent then return end
    NotifGui = NewScreenGui("AKBARUI_Notification", 100)
    NotifHolder = New("Frame", {
        Name = "Holder",
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 1, -32),
    }, NotifGui)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
    }, NotifHolder)
    NotifOrder = 0
end

local function Notify(cfg)
    EnsureNotif()
    NotifOrder += 1

    local title    = tostring(cfg.Title    or "Notification")
    local content  = tostring(cfg.Content  or "")
    local icon     = cfg.Icon
    local duration = tonumber(cfg.Duration) or 5
    local kind     = cfg.Type or "info"
    local canClose = cfg.CanClose ~= false

    local color = ActiveTheme.Accent
    if kind == "success" then color = ActiveTheme.Success end
    if kind == "warning" then color = ActiveTheme.Warning end
    if kind == "error"   then color = ActiveTheme.Error   end

    local card = New("Frame", {
        Name = "Notif",
        BackgroundColor3 = ActiveTheme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = NotifOrder,
        Size = UDim2.new(1, 0, 0, 64),
        Position = UDim2.new(1, 320, 0, 0),
    }, NotifHolder)
    Corner(card, UDim.new(0, 10))
    Stroke(card, ActiveTheme.Border, 1)

    -- accent bar
    local bar = New("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 10, 0, 8),
    }, card)
    Corner(bar, UDim.new(1, 0))

    -- icon
    local iconX = 22
    if icon and icon ~= "" then
        New("ImageLabel", {
            Image = icon,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageColor3 = color,
            Position = UDim2.new(0, 22, 0, 14),
            Size = UDim2.fromOffset(20, 20),
        }, card)
        iconX = 50
    end

    New("TextLabel", {
        Font = Fonts.Bold,
        Text = title,
        TextColor3 = ActiveTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, iconX, 0, 12),
        Size = UDim2.new(1, -iconX - 40, 0, 18),
    }, card)

    New("TextLabel", {
        Font = Fonts.Regular,
        Text = content,
        TextColor3 = ActiveTheme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, iconX, 0, 32),
        Size = UDim2.new(1, -iconX - 24, 0, 26),
    }, card)

    if canClose then
        local close = New("TextButton", {
            Font = Fonts.Bold,
            Text = "×",
            TextColor3 = ActiveTheme.MutedText,
            TextSize = 20,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -8, 0, 6),
            Size = UDim2.fromOffset(24, 24),
        }, card)
        close.MouseEnter:Connect(function()
            Tween(close, { TextColor3 = ActiveTheme.Error }, 0.15)
        end)
        close.MouseLeave:Connect(function()
            Tween(close, { TextColor3 = ActiveTheme.MutedText }, 0.15)
        end)
        Track(close.Activated:Connect(function()
            Tween(card, { Position = UDim2.new(1, 320, 0, 0) }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.3, function() card:Destroy() end)
        end))
    end

    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Quint)
    task.delay(duration, function()
        if card and card.Parent then
            Tween(card, { Position = UDim2.new(1, 320, 0, 0) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.35, function() if card then card:Destroy() end end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════
--  G. POPUP SYSTEM
-- ══════════════════════════════════════════════════════════
local function Popup(cfg)
    local title   = tostring(cfg.Title   or "Popup")
    local content = tostring(cfg.Content or "")
    local icon    = cfg.Icon
    local buttons = cfg.Buttons or { { Title = "OK", Variant = "Primary" } }

    local gui = NewScreenGui("AKBARUI_Popup", 200)

    local dim = New("Frame", {
        Name = "Dim",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
    }, gui)
    Tween(dim, { BackgroundTransparency = 0.5 }, 0.2)

    local box = New("Frame", {
        Name = "Box",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ActiveTheme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(380, 200),
        ZIndex = 2,
    }, gui)
    Corner(box, UDim.new(0, 12))
    Stroke(box, ActiveTheme.Border, 1)

    -- Scale in
    box.Size = UDim2.fromOffset(340, 180)
    Tween(box, { Size = UDim2.fromOffset(380, 200) }, 0.25, Enum.EasingStyle.Back)

    if icon and icon ~= "" then
        New("ImageLabel", {
            Image = icon,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ImageColor3 = ActiveTheme.Accent,
            Position = UDim2.new(0.5, 0, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.fromOffset(36, 36),
            ZIndex = 3,
        }, box)
    end

    New("TextLabel", {
        Font = Fonts.Bold,
        Text = title,
        TextColor3 = ActiveTheme.Text,
        TextSize = 18,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, icon and 68 or 30),
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = 3,
    }, box)

    New("TextLabel", {
        Font = Fonts.Regular,
        Text = content,
        TextColor3 = ActiveTheme.SubText,
        TextSize = 13,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, icon and 98 or 60),
        Size = UDim2.new(1, -48, 0, 60),
        ZIndex = 3,
    }, box)

    local function close()
        Tween(dim, { BackgroundTransparency = 1 }, 0.2)
        Tween(box, { Size = UDim2.fromOffset(340, 180) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.25, function() if gui then gui:Destroy() end end)
    end

    -- Buttons row
    local row = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, -18),
        Size = UDim2.new(1, -32, 0, 34),
        ZIndex = 3,
    }, box)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, row)

    local variants = {
        Primary   = { ActiveTheme.Accent, Color3.fromRGB(255,255,255) },
        Secondary = { ActiveTheme.SurfaceHover, ActiveTheme.Text },
        Tertiary  = { ActiveTheme.Background, ActiveTheme.SubText },
        Danger    = { ActiveTheme.Error, Color3.fromRGB(255,255,255) },
        Success   = { ActiveTheme.Success, Color3.fromRGB(255,255,255) },
    }

    for i, b in ipairs(buttons) do
        local v = variants[b.Variant or "Secondary"] or variants.Secondary
        local btn = New("TextButton", {
            Font = Fonts.Medium,
            Text = tostring(b.Title or "OK"),
            TextColor3 = v[2],
            TextSize = 13,
            BackgroundColor3 = v[1],
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = i,
            Size = UDim2.fromOffset(math.max(TextWidth(b.Title or "OK", 13) + 40, 90), 34),
            ZIndex = 4,
        }, row)
        Corner(btn, UDim.new(0, 8))
        Track(btn.Activated:Connect(function()
            Ripple(btn, Color3.fromRGB(255,255,255))
            SafeCall(b.Callback)
            close()
        end))
    end

    -- Click outside to close
    local clickCatch = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
    }, gui)
    Track(clickCatch.Activated:Connect(close))

    return { Close = close }
end

-- ══════════════════════════════════════════════════════════
--  H. COMPONENT BUILDERS
-- ══════════════════════════════════════════════════════════
local Registry = {}  -- For search

local function RegisterSearch(entry)
    table.insert(Registry, entry)
end

-- Base wrapper for every widget: title label + desc + content
local function BuildWidgetBase(parent, order, cfg)
    local title = tostring(cfg.Title or "")
    local desc  = tostring(cfg.Desc or cfg.Description or "")
    local locked = cfg.Locked == true
    local lockedTitle = cfg.LockedTitle or "This element is locked"

    local row = New("Frame", {
        Name = "Widget",
        BackgroundColor3 = ActiveTheme.Surface,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 40),
    }, parent)
    Corner(row, UDim.new(0, 8))
    local stroke = Stroke(row, ActiveTheme.Border, 1, 0.3)

    local titleLbl = New("TextLabel", {
        Name = "Title",
        Font = Fonts.Medium,
        Text = title,
        TextColor3 = locked and ActiveTheme.MutedText or ActiveTheme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -180, 1, 0),
        AnchorPoint = Vector2.new(0, 0.5),
    }, row)

    if desc ~= "" then
        titleLbl.Position = UDim2.new(0, 14, 0, 8)
        titleLbl.Size = UDim2.new(1, -180, 0, 16)
        titleLbl.AnchorPoint = Vector2.new(0, 0)
        New("TextLabel", {
            Name = "Desc",
            Font = Fonts.Regular,
            Text = desc,
            TextColor3 = ActiveTheme.MutedText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0, 24),
            Size = UDim2.new(1, -180, 0, 14),
        }, row)
        row.Size = UDim2.new(1, 0, 0, 44)
    end

    return row, titleLbl, stroke, locked
end

-- ═══════════ BUTTON ═══════════
local function BuildButton(parent, order, cfg, ctx)
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)
    local cb = cfg.Callback or function() end
    local color = cfg.Color or ActiveTheme.Accent

    local btn = New("TextButton", {
        Font = Fonts.Medium,
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 5,
    }, row)

    local iconX = -14
    if cfg.Icon and cfg.Icon ~= "" then
        New("ImageLabel", {
            Image = cfg.Icon,
            ImageColor3 = locked and ActiveTheme.MutedText or color,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ZIndex = 6,
        }, row)
        iconX = -42
    end

    if locked then
        New("ImageLabel", {
            Image = Assets.Lock,
            ImageColor3 = ActiveTheme.MutedText,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, iconX, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 6,
        }, row)
    end

    local api = {}

    if not locked then
        Track(btn.MouseEnter:Connect(function()
            Tween(row, { BackgroundTransparency = 0.1 }, 0.15)
            Tween(stroke, { Color = color, Transparency = 0.3 }, 0.15)
        end))
        Track(btn.MouseLeave:Connect(function()
            Tween(row, { BackgroundTransparency = 0.4 }, 0.15)
            Tween(stroke, { Color = ActiveTheme.Border, Transparency = 0.3 }, 0.15)
        end))
        Track(btn.Activated:Connect(function()
            Ripple(btn, color)
            SafeCall(cb)
        end))
    end

    function api:SetTitle(t) titleLbl.Text = tostring(t) end
    function api:SetCallback(fn) cb = fn end
    function api:Lock(msg)
        titleLbl.TextColor3 = ActiveTheme.MutedText
    end
    function api:Unlock()
        titleLbl.TextColor3 = ActiveTheme.Text
    end
    function api:Highlight()
        local orig = row.BackgroundColor3
        row.BackgroundColor3 = color
        task.delay(0.3, function() row.BackgroundColor3 = orig end)
    end
    function api:Destroy() row:Destroy() end

    RegisterSearch({ Kind = "Button", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ TOGGLE / CHECKBOX ═══════════
local function BuildToggle(parent, order, cfg, ctx)
    local isCheckbox = cfg.Type == "Checkbox"
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)

    local default = cfg.Default == true
    local sk = cfg.SaveKey
    if sk and ConfigData[sk] ~= nil then default = ConfigData[sk] == true end

    local value = { state = default }
    local cb = cfg.Callback or function() end

    local hit = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 5,
    }, row)

    local box
    local knob

    if isCheckbox then
        box = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = value.state and ActiveTheme.Accent or ActiveTheme.Background,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, row)
        Corner(box, UDim.new(0, 6))
        Stroke(box, ActiveTheme.BorderLight, 1, value.state and 1 or 0.3)

        knob = New("ImageLabel", {
            Image = Assets.Check,
            ImageColor3 = Color3.fromRGB(255,255,255),
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(14, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ImageTransparency = value.state and 0 or 1,
            ZIndex = 7,
        }, box)
    else
        box = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(40, 22),
            BackgroundColor3 = value.state and ActiveTheme.Accent or ActiveTheme.Background,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, row)
        Corner(box, UDim.new(1, 0))
        Stroke(box, ActiveTheme.BorderLight, 1, 0.3)

        knob = New("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.fromOffset(16, 16),
            Position = value.state and UDim2.new(0, 22, 0, 3) or UDim2.new(0, 3, 0, 3),
            BorderSizePixel = 0,
            ZIndex = 7,
        }, box)
        Corner(knob, UDim.new(1, 0))
    end

    local function render(anim)
        local t = anim and 0.2 or 0
        if isCheckbox then
            Tween(box, { BackgroundColor3 = value.state and ActiveTheme.Accent or ActiveTheme.Background }, t)
            Tween(knob, { ImageTransparency = value.state and 0 or 1 }, t)
        else
            Tween(box, { BackgroundColor3 = value.state and ActiveTheme.Accent or ActiveTheme.Background }, t)
            Tween(knob, { Position = value.state and UDim2.new(0, 22, 0, 3) or UDim2.new(0, 3, 0, 3) }, t)
        end
        Tween(titleLbl, { TextColor3 = value.state and ActiveTheme.Text or (locked and ActiveTheme.MutedText or ActiveTheme.Text) }, t)
    end

    local api = {}

    function api:Set(v, fire)
        if locked then return end
        value.state = v == true
        render(true)
        if sk then SaveFlag(sk, value.state) end
        if fire ~= false then SafeCall(cb, value.state) end
    end
    function api:Get() return value.state end
    function api:Lock()
        locked = true
        titleLbl.TextColor3 = ActiveTheme.MutedText
    end
    function api:Unlock()
        locked = false
        titleLbl.TextColor3 = ActiveTheme.Text
    end
    function api:Destroy() row:Destroy() end

    if not locked then
        Track(hit.Activated:Connect(function()
            Ripple(hit, ActiveTheme.Accent)
            api:Set(not value.state)
        end))
    end

    render(false)
    RegisterSearch({ Kind = isCheckbox and "Checkbox" or "Toggle", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ INPUT / TEXTAREA ═══════════
local function BuildInput(parent, order, cfg, ctx)
    local isArea = cfg.Type == "Textarea"
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)

    local default = tostring(cfg.Default or "")
    local sk = cfg.SaveKey
    if sk and type(ConfigData[sk]) == "string" then default = ConfigData[sk] end
    local cb = cfg.Callback or function() end

    if isArea then row.Size = UDim2.new(1, 0, 0, 110) end

    local box = New("Frame", {
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        AnchorPoint = isArea and Vector2.new(0, 0) or Vector2.new(1, 0.5),
        Position = isArea and UDim2.new(0, 14, 0, 46) or UDim2.new(1, -14, 0.5, 0),
        Size = isArea and UDim2.new(1, -28, 0, 56) or UDim2.fromOffset(180, 30),
        ZIndex = 5,
    }, row)
    Corner(box, UDim.new(0, 6))
    Stroke(box, ActiveTheme.Border, 1, 0.3)

    local input = New("TextBox", {
        Font = Fonts.Regular,
        Text = default,
        PlaceholderText = cfg.Placeholder or "Enter text...",
        PlaceholderColor3 = ActiveTheme.MutedText,
        TextColor3 = ActiveTheme.Text,
        TextSize = 12,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = isArea and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
        BackgroundTransparency = 1,
        MultiLine = isArea,
        TextWrapped = isArea,
        Position = UDim2.new(0, 10, 0, isArea and 6 or 0),
        Size = UDim2.new(1, -20, 1, isArea and -12 or 0),
        ZIndex = 6,
    }, box)

    local api = {}
    function api:Set(v, fire)
        input.Text = tostring(v or "")
        if sk then SaveFlag(sk, input.Text) end
        if fire ~= false then SafeCall(cb, input.Text) end
    end
    function api:Get() return input.Text end
    function api:Lock() locked = true; titleLbl.TextColor3 = ActiveTheme.MutedText end
    function api:Unlock() locked = false; titleLbl.TextColor3 = ActiveTheme.Text end
    function api:Destroy() row:Destroy() end

    if not locked then
        Track(input.FocusLost:Connect(function()
            api:Set(input.Text)
        end))
    end

    RegisterSearch({ Kind = "Input", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ SLIDER ═══════════
local function BuildSlider(parent, order, cfg, ctx)
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)

    local v = cfg.Value or {}
    local min     = tonumber(v.Min)     or 0
    local max     = tonumber(v.Max)     or 100
    local default = tonumber(v.Default) or min
    local step    = tonumber(cfg.Step)  or 1
    local sk = cfg.SaveKey
    if sk and type(ConfigData[sk]) == "number" then default = ConfigData[sk] end
    local cb = cfg.Callback or function() end

    if max <= min then max = min + 1 end
    if step <= 0 then step = 1 end

    local state = { value = default }
    local function snap(x)
        x = min + math.floor((x - min) / step + 0.5) * step
        return math.clamp(x, min, max)
    end

    -- value display
    local display = New("TextLabel", {
        Font = Fonts.Medium,
        Text = tostring(default),
        TextColor3 = ActiveTheme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(60, 20),
        ZIndex = 6,
    }, row)

    -- track
    local trackW = cfg.Width or 160
    local track = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -86, 0.5, 0),
        Size = UDim2.fromOffset(trackW, 6),
        ZIndex = 5,
    }, row)
    Corner(track, UDim.new(1, 0))

    local fill = New("Frame", {
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale((default - min) / (max - min), 1),
        ZIndex = 6,
    }, track)
    Corner(fill, UDim.new(1, 0))

    local dot = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        BorderSizePixel = 0,
        ZIndex = 7,
    }, fill)
    Corner(dot, UDim.new(1, 0))

    -- hitbox
    local hit = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -86, 0.5, 0),
        Size = UDim2.fromOffset(trackW + 12, 28),
        ZIndex = 8,
    }, row)

    local dragging = false
    local function updateFromX(x)
        local w = track.AbsoluteSize.X
        if w <= 0 then return end
        local s = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
        api:Set(min + (max - min) * s, false)
    end

    local api = {}
    function api:Set(val, fire)
        val = snap(tonumber(val) or state.value)
        state.value = val
        display.Text = tostring(val)
        fill.Size = UDim2.fromScale((val - min) / (max - min), 1)
        if sk then SaveFlag(sk, val) end
        if fire ~= false then SafeCall(cb, val) end
    end
    function api:Get() return state.value end
    function api:Lock() locked = true; titleLbl.TextColor3 = ActiveTheme.MutedText end
    function api:Unlock() locked = false; titleLbl.TextColor3 = ActiveTheme.Text end
    function api:Destroy() row:Destroy() end

    if not locked then
        Track(hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(i.Position.X)
            end
        end))
        Track(UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(i.Position.X)
            end
        end))
        Track(UserInputService.InputEnded:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                SafeCall(cb, state.value)
            end
        end))
    end

    api:Set(default, false)
    RegisterSearch({ Kind = "Slider", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ DROPDOWN ═══════════
local function BuildDropdown(parent, order, cfg, ctx)
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)
    local multi = cfg.Multi == true
    local allowNone = cfg.AllowNone == true

    local values = {}
    for _, v in ipairs(cfg.Values or {}) do
        if type(v) == "table" then
            table.insert(values, { Title = v.Title or "", Desc = v.Desc or "", Icon = v.Icon, Callback = v.Callback })
        else
            table.insert(values, { Title = tostring(v) })
        end
    end

    local default = cfg.Value
    local sk = cfg.SaveKey
    if sk and type(ConfigData[sk]) == "table" then default = ConfigData[sk] end

    local selected = {}
    if multi then
        if type(default) == "table" then
            for _, v in ipairs(default) do selected[v] = true end
        end
    else
        if type(default) == "number" then selected[default] = true
        elseif type(default) == "string" then
            for i, o in ipairs(values) do if o.Title == default then selected[i] = true end end
        end
    end

    local cb = cfg.Callback or function() end

    local box = New("Frame", {
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(160, 30),
        ZIndex = 5,
    }, row)
    Corner(box, UDim.new(0, 6))
    Stroke(box, ActiveTheme.Border, 1, 0.3)

    local selLabel = New("TextLabel", {
        Font = Fonts.Regular,
        Text = "Select...",
        TextColor3 = ActiveTheme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        ZIndex = 6,
    }, box)

    New("ImageLabel", {
        Image = Assets.Chevron,
        ImageColor3 = ActiveTheme.SubText,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Rotation = -90,
        ZIndex = 6,
    }, box)

    local hit = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 7,
    }, box)

    -- Popup list (appended to row, absolute position)
    local panel
    local function closePanel()
        if panel then
            local p = panel
            panel = nil
            Tween(p, { Size = UDim2.new(0, 160, 0, 0) }, 0.15)
            task.delay(0.2, function() if p then p:Destroy() end end)
        end
    end

    local function openPanel()
        if panel then return end
        panel = New("Frame", {
            BackgroundColor3 = ActiveTheme.Surface,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 1, 6),
            Size = UDim2.new(0, 220, 0, 0),
            ClipsDescendants = true,
            ZIndex = 100,
        }, row.Parent.Parent) -- to content area so it overlays others
        Corner(panel, UDim.new(0, 8))
        Stroke(panel, ActiveTheme.Border, 1)
        panel.ZIndex = 100

        local scroll = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ActiveTheme.BorderLight,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 101,
        }, panel)
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        }, scroll)
        Pad(scroll, 6, 6, 6, 6)

        for i, opt in ipairs(values) do
            local optBtn = New("TextButton", {
                Text = "",
                BackgroundColor3 = ActiveTheme.Surface,
                BackgroundTransparency = 0.999,
                BorderSizePixel = 0,
                LayoutOrder = i,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 102,
            }, scroll)
            Corner(optBtn, UDim.new(0, 6))

            if opt.Icon and opt.Icon ~= "" then
                New("ImageLabel", {
                    Image = opt.Icon,
                    ImageColor3 = ActiveTheme.Text,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 7),
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 103,
                }, optBtn)
            end

            New("TextLabel", {
                Font = Fonts.Medium,
                Text = opt.Title,
                TextColor3 = ActiveTheme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, opt.Icon and 34 or 12, 0, 0),
                Size = UDim2.new(1, opt.Icon and -40 or -24, 1, 0),
                ZIndex = 103,
            }, optBtn)

            local check = New("ImageLabel", {
                Image = Assets.Check,
                ImageColor3 = ActiveTheme.Accent,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ImageTransparency = selected[i] and 0 or 1,
                ZIndex = 103,
            }, optBtn)

            Track(optBtn.MouseEnter:Connect(function()
                Tween(optBtn, { BackgroundTransparency = 0.85 }, 0.1)
            end))
            Track(optBtn.MouseLeave:Connect(function()
                Tween(optBtn, { BackgroundTransparency = 0.999 }, 0.1)
            end))
            Track(optBtn.Activated:Connect(function()
                if multi then
                    selected[i] = not selected[i] or nil
                    check.ImageTransparency = selected[i] and 0 or 1
                else
                    if allowNone and selected[i] then
                        selected = {}
                    else
                        selected = { [i] = true }
                    end
                    for j, child in ipairs(scroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            local c = child:FindFirstChildOfClass("ImageLabel")
                            -- skip icon, find check
                            for _, g in ipairs(child:GetChildren()) do
                                if g:IsA("ImageLabel") and g.Image == Assets.Check then
                                    g.ImageTransparency = selected[j] and 0 or 1
                                end
                            end
                        end
                    end
                    closePanel()
                end
                api:Update()
                SafeCall(opt.Callback)
                SafeCall(cb, api:Get())
            end))
        end

        -- Animate
        local targetH = math.min(#values * 32 + 12, 220)
        Tween(panel, { Size = UDim2.new(0, 220, 0, targetH) }, 0.2)
    end

    local api = {}
    function api:Update()
        local names = {}
        for i, opt in ipairs(values) do
            if selected[i] then table.insert(names, opt.Title) end
        end
        if #names == 0 then
            selLabel.Text = "Select..."
            selLabel.TextColor3 = ActiveTheme.SubText
        else
            selLabel.Text = table.concat(names, ", ")
            selLabel.TextColor3 = ActiveTheme.Text
        end
        if sk then SaveFlag(sk, api:Get()) end
    end
    function api:Get()
        if multi then
            local out = {}
            for i, opt in ipairs(values) do
                if selected[i] then table.insert(out, opt.Title) end
            end
            return out
        else
            for i, opt in ipairs(values) do
                if selected[i] then return opt.Title end
            end
            return nil
        end
    end
    function api:Set(v, fire)
        selected = {}
        if multi then
            if type(v) == "table" then
                for _, val in ipairs(v) do
                    for i, opt in ipairs(values) do
                        if opt.Title == val then selected[i] = true end
                    end
                end
            end
        else
            for i, opt in ipairs(values) do
                if opt.Title == v or i == v then selected[i] = true end
            end
        end
        api:Update()
        if fire then SafeCall(cb, api:Get()) end
    end
    function api:Lock() locked = true; titleLbl.TextColor3 = ActiveTheme.MutedText end
    function api:Unlock() locked = false; titleLbl.TextColor3 = ActiveTheme.Text end
    function api:Destroy() row:Destroy() end

    if not locked then
        Track(hit.Activated:Connect(function()
            if panel then closePanel() else openPanel() end
        end))
    end

    api:Update()
    RegisterSearch({ Kind = "Dropdown", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ COLORPICKER ═══════════
local function BuildColorpicker(parent, order, cfg, ctx)
    local row, titleLbl, stroke, locked = BuildWidgetBase(parent, order, cfg)

    local default = cfg.Default or Color3.fromRGB(255, 255, 255)
    local sk = cfg.SaveKey
    if sk and type(ConfigData[sk]) == "table" then
        default = Color3.new(ConfigData[sk][1] or 1, ConfigData[sk][2] or 1, ConfigData[sk][3] or 1)
    end
    local cb = cfg.Callback or function() end
    local state = { value = default }

    local preview = New("TextButton", {
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(48, 24),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 6,
    }, row)
    Corner(preview, UDim.new(0, 6))
    Stroke(preview, ActiveTheme.Border, 1)

    local panel
    local function close()
        if panel then local p = panel; panel = nil
            Tween(p, { Size = UDim2.new(0, 220, 0, 0) }, 0.15)
            task.delay(0.2, function() if p then p:Destroy() end end)
        end
    end

    local function open()
        if panel then return end
        panel = New("Frame", {
            BackgroundColor3 = ActiveTheme.Surface,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 1, 6),
            Size = UDim2.new(0, 220, 0, 0),
            ClipsDescendants = true,
            ZIndex = 100,
        }, row.Parent.Parent)
        Corner(panel, UDim.new(0, 8))
        Stroke(panel, ActiveTheme.Border, 1)

        -- hex input
        local hex = New("TextBox", {
            Font = Fonts.Medium,
            Text = string.format("#%02X%02X%02X",
                math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)),
            TextColor3 = ActiveTheme.Text,
            TextSize = 12,
            BackgroundColor3 = ActiveTheme.Background,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 0, 26),
            ZIndex = 101,
        }, panel)
        Corner(hex, UDim.new(0, 6))

        local sliders = {}
        local function mkSlider(label, y, val)
            New("TextLabel", {
                Font = Fonts.Bold,
                Text = label,
                TextColor3 = ActiveTheme.SubText,
                TextSize = 11,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, y),
                Size = UDim2.fromOffset(18, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 101,
            }, panel)
            local bar = New("Frame", {
                BackgroundColor3 = ActiveTheme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 36, 0, y + 8),
                Size = UDim2.new(1, -48, 0, 4),
                ZIndex = 101,
            }, panel)
            Corner(bar, UDim.new(1, 0))
            local fill = New("Frame", {
                BackgroundColor3 = ActiveTheme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(val, 1),
                ZIndex = 102,
            }, bar)
            Corner(fill, UDim.new(1, 0))
            local hit = New("TextButton", {
                Text = "",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 36, 0, y),
                Size = UDim2.new(1, -48, 0, 20),
                ZIndex = 103,
            }, panel)
            sliders[label] = { bar = bar, fill = fill, val = val }
            local drag = false
            Track(hit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = true
                end
            end))
            Track(UserInputService.InputChanged:Connect(function(i)
                if not drag then return end
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                    local w = bar.AbsoluteSize.X
                    if w <= 0 then return end
                    local s = math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1)
                    sliders[label].val = s
                    sliders[label].fill.Size = UDim2.fromScale(s, 1)
                    api.Apply()
                end
            end))
            Track(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag = false
                end
            end))
        end

        mkSlider("R", 44, default.R)
        mkSlider("G", 74, default.G)
        mkSlider("B", 104, default.B)

        Tween(panel, { Size = UDim2.new(0, 220, 0, 140) }, 0.2)

        api._hex = hex
    end

    local api = {}
    function api.Apply()
        local r, g, b = sliders.R.val, sliders.G.val, sliders.B.val
        state.value = Color3.new(r, g, b)
        preview.BackgroundColor3 = state.value
        if api._hex then
            api._hex.Text = string.format("#%02X%02X%02X",
                math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
        end
        if sk then SaveFlag(sk, { r, g, b }) end
        SafeCall(cb, state.value)
    end
    function api:Get() return state.value end
    function api:Set(c, fire)
        state.value = c or Color3.fromRGB(255, 255, 255)
        preview.BackgroundColor3 = state.value
        if panel and sliders.R then
            sliders.R.val = state.value.R; sliders.R.fill.Size = UDim2.fromScale(state.value.R, 1)
            sliders.G.val = state.value.G; sliders.G.fill.Size = UDim2.fromScale(state.value.G, 1)
            sliders.B.val = state.value.B; sliders.B.fill.Size = UDim2.fromScale(state.value.B, 1)
        end
        if sk then SaveFlag(sk, { state.value.R, state.value.G, state.value.B }) end
        if fire then SafeCall(cb, state.value) end
    end
    function api:Lock() locked = true; titleLbl.TextColor3 = ActiveTheme.MutedText end
    function api:Unlock() locked = false; titleLbl.TextColor3 = ActiveTheme.Text end
    function api:Destroy() row:Destroy() end

    if not locked then
        Track(preview.Activated:Connect(function()
            if panel then close() else open() end
        end))
    end

    RegisterSearch({ Kind = "Colorpicker", Title = cfg.Title, Root = row, Tab = ctx.Tab })
    return api
end

-- ═══════════ IMAGE ═══════════
local function BuildImage(parent, order, cfg, ctx)
    local ar = cfg.AspectRatio or "16:9"
    local wRatio, hRatio = ar:match("(%d+):(%d+)")
    wRatio = tonumber(wRatio) or 16
    hRatio = tonumber(hRatio) or 9

    local container = New("Frame", {
        BackgroundColor3 = ActiveTheme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 0),
    }, parent)
    Corner(container, UDim.new(0, cfg.Radius or 9))
    Stroke(container, ActiveTheme.Border, 1, 0.3)

    local img = New("ImageLabel", {
        Image = cfg.Image or "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 1,
    }, container)
    Corner(img, UDim.new(0, cfg.Radius or 9))

    container.Size = UDim2.new(1, 0, 0, TextWidth("A", 100) * 0) -- placeholder, set via layout update

    -- Use aspect ratio to compute size
    local function updateSize()
        local w = container.AbsoluteSize.X
        if w > 0 then
            container.Size = UDim2.new(1, 0, 0, (w * hRatio) / wRatio)
        end
    end
    container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local w = container.AbsoluteSize.X
        if w > 0 and math.abs((container.AbsoluteSize.Y * wRatio / hRatio) - w) > 5 then
            container.Size = UDim2.new(1, 0, 0, (w * hRatio) / wRatio)
        end
    end)
    task.defer(updateSize)

    if img.Image ~= "" then
        img:GetPropertyChangedSignal("IsLoaded"):Connect(function()
            if img.IsLoaded then Tween(img, { ImageTransparency = 0 }, 0.3) end
        end)
        task.delay(1, function()
            if not img.IsLoaded then img.Image = Assets.DefaultIcon end
        end)
    end

    local api = {}
    function api:Set(image) img.Image = image end
    function api:Destroy() container:Destroy() end
    function api:Lock() end
    function api:Unlock() end

    RegisterSearch({ Kind = "Image", Title = cfg.Title, Root = container, Tab = ctx.Tab })
    return api
end

-- ═══════════ TAG / BADGE ═══════════
local function BuildTag(parent, order, cfg)
    local title = tostring(cfg.Title or "TAG")
    local color = cfg.Color or ActiveTheme.Accent
    local w = TextWidth(title, 11, Fonts.Bold) + (cfg.Icon and 34 or 20)

    local tag = New("Frame", {
        BackgroundColor3 = color,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.fromOffset(w, 22),
    }, parent)
    Corner(tag, UDim.new(0, 5))
    if cfg.Border ~= false then Stroke(tag, color, 1, 0.3) end

    if cfg.Icon and cfg.Icon ~= "" then
        New("ImageLabel", {
            Image = cfg.Icon,
            ImageColor3 = color,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -7),
            Size = UDim2.fromOffset(14, 14),
        }, tag)
    end

    New("TextLabel", {
        Font = Fonts.Bold,
        Text = title,
        TextColor3 = color,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, cfg.Icon and 26 or 0, 0, 0),
        Size = UDim2.new(1, cfg.Icon and -30 or 0, 1, 0),
    }, tag)

    return { Destroy = function() tag:Destroy() end }
end

-- ═══════════ SPACE ═══════════
local function BuildSpace(parent, order, cfg)
    local h = tonumber(cfg and cfg.Height) or 8
    local s = New("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, h),
    }, parent)
    return { Destroy = function() s:Destroy() end }
end

-- ══════════════════════════════════════════════════════════
--  I. CONTAINERS: Group, Section, Tab, Window
-- ══════════════════════════════════════════════════════════
local function BuildGroup(parent, order, cfg, ctx)
    local cols = tonumber(cfg.Columns) or 1
    local wrapper = New("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)

    local layout = New("UIGridLayout", {
        CellSize = UDim2.new(1 / cols, -4, 0, 40),
        CellPadding = UDim2.new(0, 8, 0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirectionMaxCells = cols,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, wrapper)

    -- auto height
    local childCount = 0
    local function updateHeight()
        local rows = math.ceil(childCount / cols)
        wrapper.Size = UDim2.new(1, 0, 0, rows * 46)
    end

    -- Some widgets use their own LayoutOrder; grid handles it
    local group = {}
    group._layout = layout

    -- Components go straight into wrapper as children of grid
    return group, wrapper, layout, updateHeight
end

local function BuildSection(parent, order, cfg, ctx)
    local title    = tostring(cfg.Title or "")
    local desc     = tostring(cfg.Desc or "")
    local textSize = tonumber(cfg.TextSize) or 16
    local box      = cfg.Box ~= false
    local boxBorder = cfg.BoxBorder ~= false
    local opened   = cfg.Opened ~= false

    local section = New("Frame", {
        Name = "Section",
        BackgroundColor3 = ActiveTheme.Surface,
        BackgroundTransparency = box and 0.4 or 1,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    if box then
        Corner(section, UDim.new(0, 10))
        if boxBorder then Stroke(section, ActiveTheme.Border, 1, 0.5) end
    end
    Pad(section, 12, 12, 12, 12)

    local header = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 1,
    }, section)

    local titleLbl = New("TextLabel", {
        Font = Fonts.Bold,
        Text = title,
        TextColor3 = ActiveTheme.Text,
        TextSize = textSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -30, 0, 20),
    }, header)

    if desc ~= "" then
        New("TextLabel", {
            Font = Fonts.Regular,
            Text = desc,
            TextColor3 = ActiveTheme.MutedText,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 14),
        }, header)
        header.Size = UDim2.new(1, 0, 0, 36)
    end

    -- chevron
    local chev = New("ImageLabel", {
        Image = Assets.Chevron,
        ImageColor3 = ActiveTheme.SubText,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 4),
        Size = UDim2.fromOffset(14, 14),
        Rotation = opened and 0 or -90,
    }, header)

    local headerHit = New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
    }, header)

    local content = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, header.Size.Y.Offset + 8),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        LayoutOrder = 2,
    }, section)
    local list = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)

    -- When section's automaticSize recalculates, content height = automatic
    local function applyOpen(anim)
        local t = anim and 0.25 or 0
        chev.Rotation = opened and 0 or -90
        Tween(chev, { Rotation = opened and 0 or -90 }, t)
        content.Visible = opened
    end

    Track(headerHit.Activated:Connect(function()
        opened = not opened
        applyOpen(true)
    end))
    applyOpen(false)

    -- Section API returns builder functions
    local sectionAPI = {}
    local childOrder = 0
    local function nextOrder() childOrder += 1; return childOrder end

    local ctx2 = { Tab = ctx.Tab, Section = sectionAPI }

    function sectionAPI:Button(c)    return BuildButton(content, nextOrder(), c, ctx2) end
    function sectionAPI:Toggle(c)    return BuildToggle(content, nextOrder(), c, ctx2) end
    function sectionAPI:Checkbox(c)  local c2 = c or {}; c2.Type = "Checkbox"; return BuildToggle(content, nextOrder(), c2, ctx2) end
    function sectionAPI:Input(c)     return BuildInput(content, nextOrder(), c, ctx2) end
    function sectionAPI:Textarea(c)  local c2 = c or {}; c2.Type = "Textarea"; return BuildInput(content, nextOrder(), c2, ctx2) end
    function sectionAPI:Slider(c)    return BuildSlider(content, nextOrder(), c, ctx2) end
    function sectionAPI:Dropdown(c)  return BuildDropdown(content, nextOrder(), c, ctx2) end
    function sectionAPI:Colorpicker(c) return BuildColorpicker(content, nextOrder(), c, ctx2) end
    function sectionAPI:Image(c)     return BuildImage(content, nextOrder(), c, ctx2) end
    function sectionAPI:Tag(c)       return BuildTag(content, nextOrder(), c) end
    function sectionAPI:Space(c)     return BuildSpace(content, nextOrder(), c) end
    function sectionAPI:Divider()
        return BuildSpace(content, nextOrder(), { Height = 1 })
    end

    function sectionAPI:Group(c)
        local g, wrap, layout, updH = BuildGroup(content, nextOrder(), c or {}, ctx2)
        -- expose methods that add widgets into the group wrapper
        local gc = { Tab = ctx.Tab, Section = sectionAPI, Group = wrap }
        local orderInGroup = 0
        local function no() orderInGroup += 1; updH(orderInGroup); return orderInGroup end
        function g:Button(c2)   return BuildButton(wrap, no(), c2, gc) end
        function g:Toggle(c2)   return BuildToggle(wrap, no(), c2, gc) end
        function g:Checkbox(c2) local x=c2 or {}; x.Type="Checkbox"; return BuildToggle(wrap, no(), x, gc) end
        function g:Input(c2)    return BuildInput(wrap, no(), c2, gc) end
        function g:Slider(c2)   return BuildSlider(wrap, no(), c2, gc) end
        function g:Dropdown(c2) return BuildDropdown(wrap, no(), c2, gc) end
        function g:Colorpicker(c2) return BuildColorpicker(wrap, no(), c2, gc) end
        function g:Space(c2)    return BuildSpace(wrap, no(), c2) end
        function g:Tag(c2)      return BuildTag(wrap, no(), c2) end
        return g
    end

    function sectionAPI:SetTitle(t) titleLbl.Text = tostring(t) end
    function sectionAPI:Destroy() section:Destroy() end
    function sectionAPI:SetOpen(s)
        opened = s
        applyOpen(true)
    end

    return sectionAPI
end

-- ══════════════════════════════════════════════════════════
--  J. WINDOW
-- ══════════════════════════════════════════════════════════
local function CreateWindow(cfg)
    cfg = cfg or {}
    local title  = tostring(cfg.Title or "AKBAR UI")
    local author = tostring(cfg.Author or cfg.Subtitle or "")
    local folder = cfg.Folder  -- optional

    -- Theme
    if cfg.Theme and ThemesLookup[cfg.Theme] then
        ActiveTheme = Clone(ThemesLookup[cfg.Theme])
    end

    -- Viewport
    local vpX, vpY = GetViewport()
    local windowW = math.min(560, vpX - 60)
    local windowH = math.min(360, vpY - 100)
    if IsMobile() then
        windowW = vpX - 30
        windowH = vpY - 60
    end

    local gui = NewScreenGui("AKBARUI_Window", 10)

    -- Window scale for small screens
    local scale = 1
    local minVp = math.min(vpX, vpY)
    if vpX < 700 then scale = 0.85 end
    if vpX < 500 then scale = 0.75 end

    local root = New("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(windowW, windowH),
        ZIndex = 1,
    }, gui)

    if scale ~= 1 then
        New("UIScale", { Scale = scale }, root)
    end

    -- Main container
    local main = New("Frame", {
        Name = "Main",
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
    }, root)
    Corner(main, UDim.new(0, 12))
    Stroke(main, ActiveTheme.Border, 1)

    local shadow = New("ImageLabel", {
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.4,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = 0,
    }, root)
    shadow.ZIndex = 0
    main.ZIndex = 1
    shadow.Parent = root
    main.Parent = root
    shadow.Visible = true

    -- Topbar
    local topbar = New("Frame", {
        Name = "Topbar",
        BackgroundColor3 = ActiveTheme.Topbar,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2,
    }, main)
    Corner(topbar, UDim.new(0, 12))

    -- Topbar bottom line for nice separation
    New("Frame", {
        BackgroundColor3 = ActiveTheme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 2,
    }, main)

    -- Logo/brand dot
    local dot = New("Frame", {
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(10, 10),
        ZIndex = 3,
    }, topbar)
    Corner(dot, UDim.new(1, 0))

    local titleLbl = New("TextLabel", {
        Font = Fonts.Bold,
        Text = title,
        TextColor3 = ActiveTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        ZIndex = 3,
    }, topbar)

    if author ~= "" then
        local tW = TextWidth(title, 14, Fonts.Bold)
        New("TextLabel", {
            Font = Fonts.Regular,
            Text = "·  " .. author,
            TextColor3 = ActiveTheme.MutedText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42 + tW, 0, 0),
            Size = UDim2.new(0, 260, 1, 0),
            ZIndex = 3,
        }, topbar)
    end

    -- Topbar buttons (Mac-style: minimize + close)
    local closeBtn = New("TextButton", {
        Font = Fonts.Bold,
        Text = "×",
        TextColor3 = ActiveTheme.SubText,
        TextSize = 18,
        BackgroundColor3 = ActiveTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        ZIndex = 3,
    }, topbar)
    Corner(closeBtn, UDim.new(0, 6))

    local minBtn = New("TextButton", {
        Font = Fonts.Bold,
        Text = "−",
        TextColor3 = ActiveTheme.SubText,
        TextSize = 18,
        BackgroundColor3 = ActiveTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -44, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        ZIndex = 3,
    }, topbar)
    Corner(minBtn, UDim.new(0, 6))

    -- Search bar (optional)
    local showSearch = cfg.HideSearchBar ~= true
    local searchBox
    if showSearch then
        searchBox = New("Frame", {
            BackgroundColor3 = ActiveTheme.Surface,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -80, 0.5, 0),
            Size = UDim2.fromOffset(180, 26),
            ZIndex = 3,
        }, topbar)
        Corner(searchBox, UDim.new(0, 6))
        Stroke(searchBox, ActiveTheme.Border, 1, 0.5)

        New("ImageLabel", {
            Image = Assets.Search,
            ImageColor3 = ActiveTheme.MutedText,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -7),
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 4,
        }, searchBox)

        local searchInput = New("TextBox", {
            Font = Fonts.Regular,
            Text = "",
            PlaceholderText = "Search...",
            PlaceholderColor3 = ActiveTheme.MutedText,
            TextColor3 = ActiveTheme.Text,
            TextSize = 11,
            ClearTextOnFocus = false,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -34, 1, 0),
            ZIndex = 4,
        }, searchBox)
        searchInput._input = true
    end

    -- Sidebar
    local sidebarW = 140
    if IsMobile() then sidebarW = 60 end

    local sidebar = New("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = ActiveTheme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 43),
        Size = UDim2.new(0, sidebarW, 1, -43),
        ZIndex = 2,
    }, main)

    local sidebarScroll = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
    }, sidebar)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, sidebarScroll)
    Pad(sidebarScroll, 6, 6, 6, 6)

    -- Content area
    local content = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, sidebarW + 1, 0, 43),
        Size = UDim2.new(1, -sidebarW - 1, 1, -43),
        ZIndex = 2,
    }, main)

    -- Content scroll
    local contentScroll = New("ScrollingFrame", {
        Name = "Scroll",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = ActiveTheme.BorderLight,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
    }, content)
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    }, contentScroll)
    Pad(contentScroll, 12, 12, 12, 12)

    -- Status footer
    local footer = New("Frame", {
        Name = "Footer",
        BackgroundColor3 = ActiveTheme.Topbar,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 22),
        ZIndex = 4,
    }, main)
    New("TextLabel", {
        Font = Fonts.Regular,
        Text = "AKBAR UI · v1.0",
        TextColor3 = ActiveTheme.MutedText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        ZIndex = 4,
    }, footer)

    -- Adjust content/footer positions
    content.Size = UDim2.new(1, -sidebarW - 1, 1, -43 - 22)

    local conns = {}
    Draggable(topbar, root, conns)

    -- Float button
    local floatGui = NewScreenGui("AKBARUI_Float", 20)
    local floatBtn = New("TextButton", {
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "A",
        Font = Fonts.Bold,
        TextColor3 = ActiveTheme.Accent,
        TextSize = 20,
        Position = cfg.OpenButtonPosition or UDim2.new(0, 20, 0, 120),
        Size = UDim2.fromOffset(44, 44),
        Visible = false,
        ZIndex = 3,
    }, floatGui)
    Corner(floatBtn, UDim.new(0, cfg.OpenButtonCornerRadius or 12))
    Stroke(floatBtn, ActiveTheme.Accent, 2, 0.3)

    local floatMoved = false
    Draggable(floatBtn, floatBtn, conns)

    -- Show / Hide
    local hidden = false
    local function showWindow()
        hidden = false
        root.Visible = true
        floatBtn.Visible = false
    end
    local function hideWindow()
        hidden = true
        root.Visible = false
        floatBtn.Visible = true
    end

    Track(minBtn.Activated:Connect(function() Ripple(minBtn); hideWindow() end))
    Track(closeBtn.Activated:Connect(function()
        for _, c in ipairs(conns) do c:Disconnect() end
        gui:Destroy()
        floatGui:Destroy()
    end))
    Track(floatBtn.Activated:Connect(function() showWindow() end))

    -- Tabs
    local tabs = {}
    local allTabs = {}
    local currentTab = nil

    local function switchTab(t)
        if currentTab == t then return end
        for _, tt in ipairs(allTabs) do
            local sel = (tt == t)
            tt.Page.Visible = sel
            Tween(tt.Frame, {
                BackgroundColor3 = sel and ActiveTheme.SurfaceHover or ActiveTheme.Sidebar,
            }, 0.2)
            Tween(tt.Bar, {
                Size = sel and UDim2.new(0, 3, 0, 18) or UDim2.new(0, 3, 0, 0),
            }, 0.2)
            Tween(tt.Icon, { ImageColor3 = sel and ActiveTheme.Accent or ActiveTheme.SubText }, 0.2)
            Tween(tt.Label, { TextColor3 = sel and ActiveTheme.Text or ActiveTheme.SubText }, 0.2)
        end
        currentTab = t
    end

    local window = {}

    function window:Tab(cfgTab)
        cfgTab = cfgTab or {}
        local tName = tostring(cfgTab.Title or "Tab")
        local tDesc = tostring(cfgTab.Desc or "")
        local tIcon = cfgTab.Icon
        local tColor = cfgTab.IconColor or ActiveTheme.Accent
        local tBorder = cfgTab.Border ~= false

        local idx = #allTabs + 1

        -- Sidebar tab button
        local tabBtn = New("TextButton", {
            Name = "Tab_" .. tName,
            BackgroundColor3 = ActiveTheme.Sidebar,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = idx,
            Size = UDim2.new(1, 0, 0, 34),
            Text = "",
            ZIndex = 4,
        }, sidebarScroll)
        Corner(tabBtn, UDim.new(0, 6))

        local indicator = New("Frame", {
            BackgroundColor3 = ActiveTheme.Accent,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 0),
            ZIndex = 5,
        }, tabBtn)
        Corner(indicator, UDim.new(1, 0))

        local iconLbl
        if tIcon and tIcon ~= "" then
            iconLbl = New("ImageLabel", {
                Image = tIcon,
                ImageColor3 = ActiveTheme.SubText,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, IsMobile() and 0 or 14, 0.5, -8),
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 5,
            }, tabBtn)
            if IsMobile() then
                iconLbl.Position = UDim2.new(0.5, -8, 0.5, 0)
            end
        else
            iconLbl = New("ImageLabel", {
                Image = "",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 0, 0, 0),
            }, tabBtn)
        end

        local tabLabel = New("TextLabel", {
            Font = Fonts.Medium,
            Text = IsMobile() and "" or tName,
            TextColor3 = ActiveTheme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            ZIndex = 5,
        }, tabBtn)

        Track(tabBtn.MouseEnter:Connect(function()
            if currentTab ~= allTabs[idx] then
                Tween(tabBtn, { BackgroundColor3 = ActiveTheme.SurfaceHover }, 0.15)
            end
        end))
        Track(tabBtn.MouseLeave:Connect(function()
            if currentTab ~= allTabs[idx] then
                Tween(tabBtn, { BackgroundColor3 = ActiveTheme.Sidebar }, 0.15)
            end
        end))

        -- Content page
        local page = New("ScrollingFrame", {
            Name = "Page_" .. tName,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ActiveTheme.BorderLight,
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
        }, content)

        local pageList = New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }, page)
        Pad(page, 12, 12, 12, 12)

        local tabObj = {
            Name = tName, Frame = tabBtn, Page = page,
            Bar = indicator, Icon = iconLbl, Label = tabLabel,
        }
        table.insert(allTabs, tabObj)

        Track(tabBtn.Activated:Connect(function()
            Ripple(tabBtn, tColor)
            switchTab(tabObj)
        end))

        if idx == 1 then switchTab(tabObj) end

        -- Tab API
        local tabAPI = {}
        local secCount = 0
        local function nextOrder() secCount += 1; return secCount end

        local ctx = { Tab = tName }

        function tabAPI:Section(c)
            local sec = BuildSection(page, nextOrder(), c or {}, ctx)
            return sec
        end

        function tabAPI:Space(c)
            return BuildSpace(page, nextOrder(), c)
        end

        function tabAPI:Tag(c)
            return BuildTag(page, nextOrder(), c)
        end

        function tabAPI:Group(c)
            local g, wrap, layout, updH = BuildGroup(page, nextOrder(), c or {}, ctx)
            local gc = { Tab = tName, Group = wrap }
            local orderInGroup = 0
            local function no() orderInGroup += 1; return orderInGroup end
            function g:Button(c2)   return BuildButton(wrap, no(), c2, gc) end
            function g:Toggle(c2)   return BuildToggle(wrap, no(), c2, gc) end
            function g:Checkbox(c2) local x=c2 or {}; x.Type="Checkbox"; return BuildToggle(wrap, no(), x, gc) end
            function g:Input(c2)    return BuildInput(wrap, no(), c2, gc) end
            function g:Slider(c2)   return BuildSlider(wrap, no(), c2, gc) end
            function g:Dropdown(c2) return BuildDropdown(wrap, no(), c2, gc) end
            function g:Colorpicker(c2) return BuildColorpicker(wrap, no(), c2, gc) end
            function g:Space(c2)    return BuildSpace(wrap, no(), c2) end
            return g
        end

        function tabAPI:Select() switchTab(tabObj) end
        function tabAPI:Destroy() tabBtn:Destroy(); page:Destroy() end

        return tabAPI
    end

    function window:Notify(c) return Notify(c) end
    function window:Popup(c) return Popup(c) end
    function window:SelectTab(i)
        if allTabs[i] then switchTab(allTabs[i]) end
    end
    function window:Show() showWindow() end
    function window:Hide() hideWindow() end
    function window:Toggle()
        if hidden then showWindow() else hideWindow() end
    end
    function window:Destroy()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        gui:Destroy()
        floatGui:Destroy()
    end

    return window
end

-- ══════════════════════════════════════════════════════════
--  K. PUBLIC API
-- ══════════════════════════════════════════════════════════
local AKBARUI = {}
AKBARUI.Version = "1.0.0"
AKBARUI.Themes = ThemesLookup

function AKBARUI:CreateWindow(cfg) return CreateWindow(cfg) end
function AKBARUI:Notify(cfg) return Notify(cfg) end
function AKBARUI:Popup(cfg) return Popup(cfg) end

function AKBARUI:RegisterTheme(name, theme)
    ThemesLookup[name] = theme
end
function AKBARUI:SetTheme(name)
    if ThemesLookup[name] then
        ActiveTheme = Clone(ThemesLookup[name])
    end
end
function AKBARUI:GetTheme() return Clone(ActiveTheme) end
function AKBARUI:ListThemes()
    local out = {}
    for k in pairs(ThemesLookup) do table.insert(out, k) end
    table.sort(out)
    return out
end

function AKBARUI:SaveConfig()
    SaveConfigFile(ConfigData)
    return true
end
function AKBARUI:LoadConfig()
    ConfigData = LoadConfigFile()
    return ConfigData
end
function AKBARUI:ResetConfig()
    ConfigData = {}
    SaveConfigFile(ConfigData)
end
function AKBARUI:GetConfig() return ConfigData end

function AKBARUI:Destroy()
    if Env.AKBARUI_Cleanup then Env.AKBARUI_Cleanup() end
end

return AKBARUI
