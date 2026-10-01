--[[
  ╔══════════════════════════════════════════════════╗
  ║          KING AKBAR UI LIBRARY v2.0              ║
  ║    github.com/Akbar025zzz/kingAkbarUi-Speedhub   ║
  ╚══════════════════════════════════════════════════╝

  NEW IN v2.0:
  • Keybind System + UI Toggle Hotkey (default: RightShift)
  • ColorPicker Component (HSV wheel + presets)
  • Confirm Dialog System
  • Tooltip Support (semua komponen)
  • Theme Runtime Switching (ganti tema SETELAH CreateWindow)
  • Config Save/Load Built-in (auto-save ke file JSON)
  • Progress Bar di Notification
  • Sound Effects (optional, default OFF)
  • Slider Fill Bar + Drag Support
  • Notification Queue System (max 5, sisanya antri)
  • Window Viewport Clamping
  • Bug Fix: Toggle callback tidak terpanggil saat init
  • Bug Fix: Notification overflow dengan title panjang
  • Bug Fix: Memory leak cleanup

  CONTOH PEMAKAIAN:
    local Lib = loadstring(game:HttpGet("URL_RAW_FILE_INI"))()
    local Win = Lib:CreateWindow({ Title = "My Hub", Description = "v2.0" })
    local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
    local Sec = Tab:AddSection("Farming", true)
    
    Sec:AddToggle({ Title = "Auto Farm", Content = "Farm otomatis", Default = false, Tooltip = "Aktifkan farming otomatis", Callback = function(v) print(v) end })
    Sec:AddKeybind({ Title = "Toggle Farm Key", Default = Enum.KeyCode.E, Callback = function() print("Key pressed!") end })
    Sec:AddColorPicker({ Title = "ESP Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) print(c) end })
    Sec:AddButton({ Title = "Reset", Content = "Reset character", Callback = function()
      Lib:Dialog({ Title = "Confirm", Content = "Reset character?", Buttons = { { "Yes", function() game.Players.LocalPlayer.Character:BreakJoints() end }, { "No", function() end } } })
    end })
    
    Lib:SetNotification({ Title = "Loaded", Description = "Success", Content = "Script loaded successfully!" })
]]

-- ═══════════════════════════════════════════════════
--  INITIALIZATION
-- ═══════════════════════════════════════════════════
if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Camera           = workspace.CurrentCamera

local Player = Players.LocalPlayer
if not Player then
  Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
  Player = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════
--  CLEANUP SYSTEM (v2.0 — lebih menyeluruh)
-- ═══════════════════════════════════════════════════
local Env = (getgenv and getgenv()) or _G

if type(Env.KingAkbarUI_Cleanup) == "function" then
  pcall(Env.KingAkbarUI_Cleanup)
end

local LibConnections = {}
local LibGuis        = {}
local LibTweens      = {}  -- v2.0: track tweens untuk cancel
local LibTimers      = {}  -- v2.0: track task.delay untuk cancel
local ThemedElements = {}  -- v2.0: untuk theme runtime switching
local LibWindows     = {}  -- v2.0: track semua window

local function TrackLib(Conn)
  table.insert(LibConnections, Conn)
  return Conn
end

local function BindLib(Signal, Fn)
  return TrackLib(Signal:Connect(Fn))
end

local function TrackTween(TweenObj)
  table.insert(LibTweens, TweenObj)
  return TweenObj
end

local function TrackTimer(Time, Fn)
  local token = {}
  table.insert(LibTimers, token)
  task.delay(Time, function()
    -- Hapus token dari list
    for i, t in ipairs(LibTimers) do
      if t == token then table.remove(LibTimers, i) break end
    end
    if token.Alive ~= false then Fn() end
  end)
  return token
end

local function CancelTimer(token)
  if type(token) == "table" then token.Alive = false end
end

Env.KingAkbarUI_Cleanup = function()
  -- Cancel semua timers
  for _, t in ipairs(LibTimers) do
    if type(t) == "table" then t.Alive = false end
  end
  -- Cancel semua tweens
  for _, tw in ipairs(LibTweens) do
    pcall(function() tw:Cancel() end)
  end
  -- Disconnect semua connections
  for _, c in ipairs(LibConnections) do
    pcall(function() c:Disconnect() end)
  end
  -- Destroy semua GUIs
  for _, g in ipairs(LibGuis) do
    pcall(function() g:Destroy() end)
  end
  table.clear(LibConnections)
  table.clear(LibGuis)
  table.clear(LibTweens)
  table.clear(LibTimers)
  table.clear(ThemedElements)
  table.clear(LibWindows)
end

-- Bersihkan sisa UI dari versi lama
pcall(function()
  local roots = { Player:FindFirstChild("PlayerGui") }
  pcall(function() table.insert(roots, CoreGui) end)
  pcall(function() if gethui then table.insert(roots, gethui()) end end)
  for _, root in ipairs(roots) do
    if root then
      for _, child in ipairs(root:GetChildren()) do
        if child:IsA("ScreenGui") and string.sub(child.Name, 1, 11) == "KingAkbarUI" then
          child:Destroy()
        end
      end
    end
  end
end)

-- ═══════════════════════════════════════════════════
--  GLOBAL CONFIG
-- ═══════════════════════════════════════════════════
local CONFIG = {
  Theme = {
    Primary    = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(10, 10, 10),
    Secondary  = Color3.fromRGB(25, 25, 25),
    Panel      = Color3.fromRGB(255, 255, 255),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(160, 160, 160),
    Stroke     = Color3.fromRGB(70, 70, 70),
    Divider    = Color3.fromRGB(80, 80, 80),
    LineColor  = Color3.fromRGB(110, 110, 110),
  },
  Font = {
    Bold    = Enum.Font.GothamBold,
    Regular = Enum.Font.SourceSans,
  },
  Window = {
    Size                   = UDim2.fromOffset(420, 280),
    TabWidth               = 100,
    CornerRadius           = 6,
    BackgroundImage        = "rbxassetid://110409843085547",
    BackgroundTransparency = 0.6,
    BackgroundTint         = Color3.fromRGB(0, 0, 0),
    BackgroundTintTrans    = 0.3,
    ToggleKey              = Enum.KeyCode.RightShift,  -- v2.0: UI toggle hotkey
  },
  Notification = {
    Width       = 320,
    Duration    = 5,
    AnimateTime = 0.5,
    MaxVisible  = 5,  -- v2.0: max notif yang tampil bersamaan
  },
  Assets = {
    ShadowImage    = "rbxassetid://1316045217",
    RippleImage    = "rbxassetid://106471194043211",
    ArrowIcon      = "rbxassetid://125609963478878",
    DropdownArrow  = "rbxassetid://90200523188815",
    DefaultIcon    = "rbxassetid://7734010488",
    FloatingButton = "rbxassetid://91115084979317",
  },
  Behavior = {
    AntiAFK      = true,
    SoundEnabled = false,  -- v2.0: sound effects
    SaveEnabled  = false,  -- v2.0: config auto-save
    SaveFile     = "KingAkbarUI_Config.json",
    SaveDebounce = 0.5,
  },
  Sounds = {  -- v2.0: sound IDs
    Click        = "rbxassetid://6042053626",
    ToggleOn     = "rbxassetid://6042053626",
    ToggleOff    = "rbxassetid://6042053626",
    Notification = "rbxassetid://180877191",
    Open         = "rbxassetid://6042053626",
    Close        = "rbxassetid://6042053626",
  },
}

-- ═══════════════════════════════════════════════════
--  ZINDEX CONSTANTS (v2.0 — tidak hardcoded lagi)
-- ═══════════════════════════════════════════════════
local Z = {
  Background = 0,
  Base       = 1,
  Content    = 2,
  Control    = 3,
  Overlay    = 4,
  Dropdown   = 5,
  Tooltip    = 100,
  Dialog     = 200,
  Notification = 250,
}

-- ═══════════════════════════════════════════════════
--  HELPER UMUM
-- ═══════════════════════════════════════════════════
local function Get(Cfg, Idx, Key, Default)
  if type(Cfg) ~= "table" then
    if Idx == 1 and Cfg ~= nil then return Cfg end
    return Default
  end
  local v = Cfg[Idx]
  if v == nil then v = Cfg[Key] end
  if v == nil then return Default end
  return v
end

local function SafeCall(Fn, ...)
  if type(Fn) ~= "function" then return end
  local ok, err = pcall(Fn, ...)
  if not ok then
    warn("[KingAkbarUI] Callback error: " .. tostring(err))
  end
end

local function Tween(Inst, Props, Time, Style, Dir)
  if not Time or Time <= 0 then
    for k, v in pairs(Props) do Inst[k] = v end
    return nil
  end
  local tw = TweenService:Create(Inst,
    TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Dir or Enum.EasingDirection.Out),
    Props)
  tw:Play()
  TrackTween(tw)
  return tw
end

local function TextWidth(Text, Size, Font)
  local ok, bounds = pcall(function()
    return TextService:GetTextSize(Text or "", Size, Font, Vector2.new(1000, 100))
  end)
  if ok and bounds then return bounds.X end
  return #tostring(Text or "") * Size * 0.55
end

local function ContrastColor(C)
  local lum = 0.299 * C.R + 0.587 * C.G + 0.114 * C.B
  return lum > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end

-- v2.0: Sound system
local function PlaySound(soundType)
  if not CONFIG.Behavior.SoundEnabled then return end
  local soundId = CONFIG.Sounds[soundType]
  if not soundId or soundId == "" then return end
  pcall(function()
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.3
    sound.Parent = workspace
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
    -- Fallback cleanup
    task.delay(5, function() if sound then sound:Destroy() end end)
  end)
end

-- v2.0: Register element untuk theme runtime switching
-- Property bisa berupa string atau function yang menerima value
local function RegisterThemed(element, property, themeKey)
  table.insert(ThemedElements, {
    Element = element,
    Property = property,
    ThemeKey = themeKey,
  })
end

local function ApplyThemeToAll()
  for _, data in ipairs(ThemedElements) do
    if data.Element and data.Element.Parent then
      pcall(function()
        if type(data.Property) == "function" then
          data.Property(CONFIG.Theme[data.ThemeKey])
        else
          data.Element[data.Property] = CONFIG.Theme[data.ThemeKey]
        end
      end)
    end
  end
end

-- ═══════════════════════════════════════════════════
--  CONFIG SAVE/LOAD SYSTEM (v2.0)
-- ═══════════════════════════════════════════════════
local SaveSystem = {}
local SaveTable = {}
local SaveFn = nil
local SaveTimer = nil
local SaveDebounce = CONFIG.Behavior.SaveDebounce

function SaveSystem.SetTable(tbl, writeFn)
  SaveTable = tbl or {}
  SaveFn = writeFn or function(cfg)
    pcall(function()
      if writefile then
        writefile(CONFIG.Behavior.SaveFile, HttpService:JSONEncode(cfg))
      end
    end)
  end
end

function SaveSystem.Get(key, default)
  if SaveTable[key] == nil then return default end
  return SaveTable[key]
end

function SaveSystem.Set(key, value)
  SaveTable[key] = value
  SaveSystem.Save()
end

function SaveSystem.Save()
  if not CONFIG.Behavior.SaveEnabled then return end
  -- Debounce save
  if SaveTimer then CancelTimer(SaveTimer) end
  SaveTimer = TrackTimer(SaveDebounce, function()
    if SaveFn then pcall(SaveFn, SaveTable) end
  end)
end

function SaveSystem.Load()
  pcall(function()
    if isfile and isfile(CONFIG.Behavior.SaveFile) then
      local data = readfile(CONFIG.Behavior.SaveFile)
      if data and data ~= "" then
        local decoded = HttpService:JSONDecode(data)
        if type(decoded) == "table" then
          for k, v in pairs(decoded) do SaveTable[k] = v end
        end
      end
    end
  end)
end

function SaveSystem.Clear()
  SaveTable = {}
  pcall(function()
    if isfile and isfile(CONFIG.Behavior.SaveFile) then
      delfile(CONFIG.Behavior.SaveFile)
    end
  end)
end

-- ═══════════════════════════════════════════════════
--  LIBRARY CORE OBJECT
-- ═══════════════════════════════════════════════════
local Custom = {} do
  Custom.ColorRGB = CONFIG.Theme.Primary
  Custom.Config   = CONFIG

  function Custom:Create(Name, Properties, Parent)
    local _instance = Instance.new(Name)
    for i, v in pairs(Properties) do
      _instance[i] = v
    end
    if Parent then _instance.Parent = Parent end
    return _instance
  end

  -- v2.0: Anti-AFK dengan lazy connect
  local antiAFKConn = nil
  function Custom:EnabledAFK()
    if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
    if CONFIG.Behavior.AntiAFK then
      antiAFKConn = BindLib(Player.Idled, function()
        pcall(function()
          VirtualUser:CaptureController()
          VirtualUser:ClickButton2(Vector2.new())
        end)
      end)
    end
  end

  -- v2.0: Theme switching runtime (update semua elemen terdaftar)
  function Custom:SetTheme(t)
    for k, v in pairs(t) do CONFIG.Theme[k] = v end
    Custom.ColorRGB = CONFIG.Theme.Primary
    ApplyThemeToAll()  -- Apply ke semua elemen yang sudah dibuat
  end

  function Custom:SetFont(f)
    for k, v in pairs(f) do CONFIG.Font[k] = v end
  end

  function Custom:GetConfig() return CONFIG end
end

Custom:EnabledAFK()

-- ═══════════════════════════════════════════════════
--  SCREENGUI FACTORY
-- ═══════════════════════════════════════════════════
local function NewScreenGui(Name, Order)
  local gui = Instance.new("ScreenGui")
  gui.Name            = Name
  gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
  gui.ResetOnSpawn    = false
  gui.IgnoreGuiInset  = true
  gui.DisplayOrder    = Order or 10

  local parented = false
  if not RunService:IsStudio() then
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    local ok = pcall(function()
      if gethui then
        gui.Parent = gethui()
      elseif cloneref then
        gui.Parent = cloneref(CoreGui)
      else
        gui.Parent = CoreGui
      end
    end)
    parented = ok and gui.Parent ~= nil
  end
  if not parented then
    gui.Parent = Player:WaitForChild("PlayerGui")
  end

  table.insert(LibGuis, gui)
  return gui
end

-- ═══════════════════════════════════════════════════
--  TOOLTIP SYSTEM (v2.0)
-- ═══════════════════════════════════════════════════
local TooltipGui = nil
local CurrentTooltip = nil

local function EnsureTooltipGui()
  if TooltipGui and TooltipGui.Parent then return TooltipGui end
  TooltipGui = NewScreenGui("KingAkbarUI_Tooltip", Z.Tooltip)
  return TooltipGui
end

local function ShowTooltip(text, position)
  if not text or text == "" then return end
  local gui = EnsureTooltipGui()
  
  -- Hapus tooltip lama
  if CurrentTooltip then CurrentTooltip:Destroy() CurrentTooltip = nil end
  
  local textSize = TextService:GetTextSize(text, 12, CONFIG.Font.Bold, Vector2.new(200, math.huge))
  local width = math.min(textSize.X + 16, 220)
  local height = math.max(textSize.Y + 10, 24)
  
  local Tooltip = Custom:Create("Frame", {
    Name = "Tooltip",
    BackgroundColor3 = CONFIG.Theme.Background,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, position.X + 15, 0, position.Y - height - 5),
    Size = UDim2.fromOffset(width, height),
    ZIndex = Z.Tooltip,
  }, gui)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Tooltip)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, Tooltip)
  
  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold,
    Text = text,
    TextColor3 = CONFIG.Theme.Text,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 8, 0, 0),
    Size = UDim2.new(1, -16, 1, 0),
    ZIndex = Z.Tooltip + 1,
  }, Tooltip)
  
  -- Animasi fade in
  Tooltip.BackgroundTransparency = 1
  Tween(Tooltip, { BackgroundTransparency = 0.1 }, 0.15)
  
  CurrentTooltip = Tooltip
  return Tooltip
end

local function HideTooltip()
  if CurrentTooltip then
    CurrentTooltip:Destroy()
    CurrentTooltip = nil
  end
end

-- Helper untuk attach tooltip ke element
local function AttachTooltip(element, getTextFn)
  if not element then return end
  element.MouseEnter:Connect(function()
    local text = type(getTextFn) == "function" and getTextFn() or getTextFn
    if text and text ~= "" then
      local mousePos = UserInputService:GetMouseLocation()
      ShowTooltip(text, mousePos)
    end
  end)
  element.MouseLeave:Connect(function()
    HideTooltip()
  end)
end

-- ═══════════════════════════════════════════════════
--  DRAGGABLE
-- ═══════════════════════════════════════════════════
local function MakeDraggable(Handle, Object, Bind)
  local Dragging, DragInput, DragStart, StartPos, Moved = false, nil, nil, nil, false

  Handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      Dragging  = true
      Moved     = false
      DragInput = input
      DragStart = input.Position
      StartPos  = Object.Position
    end
  end)

  Bind(UserInputService.InputChanged, function(input)
    if not Dragging then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement
      or (t == Enum.UserInputType.Touch and input == DragInput) then
      local delta = input.Position - DragStart
      if delta.Magnitude > 4 then Moved = true end
      Object.Position = UDim2.new(
        StartPos.X.Scale, StartPos.X.Offset + delta.X,
        StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
  end)

  Bind(UserInputService.InputEnded, function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1
      or (t == Enum.UserInputType.Touch and input == DragInput) then
      Dragging = false
    end
  end)

  return function() return Moved end
end

-- ═══════════════════════════════════════════════════
--  FLOATING OPEN/CLOSE BUTTON
-- ═══════════════════════════════════════════════════
local function CreateFloatingButton()
  local Gui = NewScreenGui("KingAkbarUI_Floating", 20)

  local Btn = Custom:Create("ImageButton", {
    Name = "OpenCloseButton",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Position = UDim2.new(0.85, 0, 0.05, 0),
    Size = UDim2.fromOffset(45, 45),
    Image = CONFIG.Assets.FloatingButton,
    Visible = false,
  }, Gui)

  Custom:Create("UICorner", { Name = "MainCorner", CornerRadius = UDim.new(0, 9) }, Btn)

  local DidMove = MakeDraggable(Btn, Btn, BindLib)
  return Btn, DidMove
end

local Open_Close, Open_Close_Moved = CreateFloatingButton()

-- ═══════════════════════════════════════════════════
--  RIPPLE CLICK
-- ═══════════════════════════════════════════════════
local function CircleClick(Button)
  task.spawn(function()
    if not Button or not Button.Parent then return end
    Button.ClipsDescendants = true

    local W, H = Button.AbsoluteSize.X, Button.AbsoluteSize.Y
    local rel = UserInputService:GetMouseLocation() - Button.AbsolutePosition
    if rel.X < 0 or rel.Y < 0 or rel.X > W or rel.Y > H then
      rel = Vector2.new(W / 2, H / 2)
    end

    local Circle = Custom:Create("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundColor3 = Color3.fromRGB(150, 150, 150),
      BackgroundTransparency = 0.8,
      BorderSizePixel = 0,
      Position = UDim2.fromOffset(rel.X, rel.Y),
      Size = UDim2.fromOffset(0, 0),
      ZIndex = Z.Control + 5,
    }, Button)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Circle)

    local Size = math.max(W, H) * 2.2
    Tween(Circle, {
      Size = UDim2.fromOffset(Size, Size),
      BackgroundTransparency = 1,
    }, 0.5)

    task.wait(0.55)
    if Circle then Circle:Destroy() end
  end)
end

-- ═══════════════════════════════════════════════════
--  ITEM BASE
-- ═══════════════════════════════════════════════════
local function NewItemBase(Parent, Order, Title, Content, Reserve)
  local Base = {}

  local Frame = Custom:Create("Frame", {
    Name = "Item",
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.935, BorderSizePixel = 0,
    LayoutOrder = Order,
    Size = UDim2.new(1, 0, 0, 35),
    ZIndex = Z.Base,
  }, Parent)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Frame)
  RegisterThemed(Frame, "BackgroundColor3", "Panel")

  local TitleLabel = Custom:Create("TextLabel", {
    Name = "ItemTitle",
    Font = CONFIG.Font.Bold, Text = tostring(Title), TextSize = 13,
    TextColor3 = CONFIG.Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0, 10),
    Size = UDim2.new(1, -Reserve, 0, 13),
    ZIndex = Z.Content,
  }, Frame)
  RegisterThemed(TitleLabel, "TextColor3", "Text")

  local ContentLabel = Custom:Create("TextLabel", {
    Name = "ItemContent",
    Font = CONFIG.Font.Regular, Text = tostring(Content), TextSize = 12,
    TextColor3 = CONFIG.Theme.Text, TextTransparency = 0.6,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0, 10, 0, 25),
    Size = UDim2.new(1, -Reserve, 0, 0),
    ZIndex = Z.Content,
  }, Frame)
  RegisterThemed(ContentLabel, "TextColor3", "Text")

  Base.Frame   = Frame
  Base.Title   = TitleLabel
  Base.Content = ContentLabel
  Base.Height  = 35
  Base.Apply   = nil

  function Base.Refit()
    local hasContent = ContentLabel.Text ~= ""
    ContentLabel.Visible = hasContent
    local h
    if hasContent then
      TitleLabel.AnchorPoint = Vector2.new(0, 0)
      TitleLabel.Position = UDim2.new(0, 10, 0, 10)
      h = 25 + math.max(ContentLabel.AbsoluteSize.Y, 12) + 10
    else
      TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
      TitleLabel.Position = UDim2.new(0, 10, 0.5, 0)
      h = 35
    end
    Base.Height = h
    if Base.Apply then
      Base.Apply(h)
    else
      Frame.Size = UDim2.new(1, 0, 0, h)
    end
  end

  ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(Base.Refit)
  ContentLabel:GetPropertyChangedSignal("Text"):Connect(Base.Refit)
  Base.Refit()

  return Base
end

local function AttachCommon(Funcs, Base)
  function Funcs:SetTitle(Text) Base.Title.Text = tostring(Text) end
  function Funcs:SetContent(Text) Base.Content.Text = tostring(Text) end
  function Funcs:SetVisible(State) Base.Frame.Visible = State and true or false end
  function Funcs:Destroy() Base.Frame:Destroy() end
end

-- ═══════════════════════════════════════════════════
--  MAIN LIBRARY
-- ═══════════════════════════════════════════════════
local Speed_Library = {}
Speed_Library.Unloaded = false
Speed_Library.Version = "2.0"

-- Expose SaveSystem
Speed_Library.Save = SaveSystem

-- ─────────────────── Notification (v2.0 dengan Queue & Progress Bar) ───────────────────
local NotifGui, NotifHolder
local NotifCounter = 0
local ActiveNotifs = {}  -- v2.0: track notif aktif
local NotifQueue = {}    -- v2.0: queue untuk notif yang menunggu

local function EnsureNotifHolder()
  if NotifGui and NotifGui.Parent and NotifHolder and NotifHolder.Parent then
    return NotifHolder
  end
  NotifGui = NewScreenGui("KingAkbarUI_Notification", Z.Notification)
  NotifHolder = Custom:Create("Frame", {
    Name = "Holder",
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, CONFIG.Notification.Width, 1, -40),
  }, NotifGui)
  Custom:Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding = UDim.new(0, 8),
  }, NotifHolder)
  return NotifHolder
end

local function ProcessNotifQueue()
  if #NotifQueue == 0 then return end
  if #ActiveNotifs >= CONFIG.Notification.MaxVisible then return end
  local queued = table.remove(NotifQueue, 1)
  if queued then queued() end
end

function Speed_Library:SetNotification(Config)
  local Title       = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local Content     = tostring(Get(Config, 3, "Content", ""))
  local Time        = tonumber(Get(Config, 5, "Time", CONFIG.Notification.AnimateTime)) or 0.5
  local Delay       = tonumber(Get(Config, 6, "Delay", CONFIG.Notification.Duration)) or 5
  local ShowProgress = Get(Config, 7, "Progress", true) == true  -- v2.0: progress bar

  NotifCounter += 1
  
  local function CreateNotif()
    local Holder = EnsureNotifHolder()
    
    local Container = Custom:Create("Frame", {
      Name = "Notification",
      BackgroundTransparency = 1, BorderSizePixel = 0,
      LayoutOrder = NotifCounter,
      Size = UDim2.new(1, 0, 0, 65),
    }, Holder)

    local Card = Custom:Create("Frame", {
      BackgroundColor3 = CONFIG.Theme.Background,
      BackgroundTransparency = 0.05,
      BorderSizePixel = 0,
      Position = UDim2.new(1, 40, 0, 0),
      Size = UDim2.new(1, 0, 1, 0),
    }, Container)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Card)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, Card)
    RegisterThemed(Card, "BackgroundColor3", "Background")

    -- v2.0: Clamp title width untuk mencegah overflow
    local TitleWidth = math.min(TextWidth(Title, 14, CONFIG.Font.Bold), 150)

    local TitleLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
      TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 10, 0, 0),
      Size = UDim2.new(0, TitleWidth + 4, 0, 36),
    }, Card)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Text, Thickness = 0.3 }, TitleLabel)
    RegisterThemed(TitleLabel, "TextColor3", "Text")

    local DescLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
      TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, TitleWidth + 15, 0, 0),
      Size = UDim2.new(1, -(TitleWidth + 15 + 35), 0, 36),
    }, Card)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 0.4 }, DescLabel)
    RegisterThemed(DescLabel, "TextColor3", "Primary")

    local CloseBtn = Custom:Create("TextButton", {
      Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
      TextSize = 18, AnchorPoint = Vector2.new(1, 0),
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(1, -5, 0, 5), Size = UDim2.fromOffset(25, 25),
    }, Card)

    local ContentLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Regular, Text = Content, TextColor3 = CONFIG.Theme.SubText,
      TextSize = 13, TextWrapped = true,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      AutomaticSize = Enum.AutomaticSize.Y,
      Position = UDim2.new(0, 10, 0, 30),
      Size = UDim2.new(1, -20, 0, 0),
      Visible = Content ~= "",
    }, Card)
    RegisterThemed(ContentLabel, "TextColor3", "SubText")

    local function Refit()
      if Content == "" then
        Container.Size = UDim2.new(1, 0, 0, 40)
      else
        Container.Size = UDim2.new(1, 0, 0, 30 + math.max(ContentLabel.AbsoluteSize.Y, 13) + 12)
      end
    end
    ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(Refit)
    Refit()

    -- v2.0: Progress Bar
    local ProgressBar = nil
    if ShowProgress then
      ProgressBar = Custom:Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = CONFIG.Theme.Primary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = Z.Content + 1,
      }, Card)
      Custom:Create("UICorner", {}, ProgressBar)
      RegisterThemed(ProgressBar, "BackgroundColor3", "Primary")
      
      -- Animasi progress bar (linear)
      Tween(ProgressBar, {
        Size = UDim2.new(0, 0, 0, 2),
      }, Delay, Enum.EasingStyle.Linear)
    end

    local Closed = false
    local Notification = {}

    function Notification:Close()
      if Closed then return end
      Closed = true
      
      -- Hapus dari active list
      for i, n in ipairs(ActiveNotifs) do
        if n == Notification then
          table.remove(ActiveNotifs, i)
          break
        end
      end
      
      Tween(Card, { Position = UDim2.new(1, 40, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.In)
      task.delay(Time + 0.05, function()
        if Container then Container:Destroy() end
      end)
      
      -- Process queue
      ProcessNotifQueue()
    end

    CloseBtn.Activated:Connect(function() Notification:Close() end)

    Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TrackTimer(Delay, function() Notification:Close() end)

    table.insert(ActiveNotifs, Notification)
    PlaySound("Notification")
    
    return Notification
  end

  -- v2.0: Check jika perlu queue
  if #ActiveNotifs >= CONFIG.Notification.MaxVisible then
    table.insert(NotifQueue, CreateNotif)
    -- Return placeholder object
    local placeholder = { Close = function() end }
    return placeholder
  else
    return CreateNotif()
  end
end

function Speed_Library:Notify(Config) return Speed_Library:SetNotification(Config) end

-- ─────────────────── Dialog System (v2.0) ───────────────────
function Speed_Library:Dialog(Config)
  local Title   = tostring(Get(Config, 1, "Title", "Confirm"))
  local Content = tostring(Get(Config, 2, "Content", "Are you sure?"))
  local Buttons = Get(Config, 3, "Buttons", {
    { "OK", function() end }
  })

  local Gui = NewScreenGui("KingAkbarUI_Dialog", Z.Dialog)

  -- Overlay backdrop
  local Overlay = Custom:Create("Frame", {
    Name = "Overlay",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = Z.Dialog,
  }, Gui)

  local Dialog = Custom:Create("Frame", {
    Name = "Dialog",
    BackgroundColor3 = CONFIG.Theme.Background,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(300, 0),
    ZIndex = Z.Dialog + 1,
  }, Overlay)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Dialog)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.5 }, Dialog)

  -- Title
  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold,
    Text = Title,
    TextColor3 = CONFIG.Theme.Text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 15, 0, 12),
    Size = UDim2.new(1, -30, 0, 20),
    ZIndex = Z.Dialog + 2,
  }, Dialog)

  -- Content
  local ContentLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular,
    Text = Content,
    TextColor3 = CONFIG.Theme.SubText,
    TextSize = 14,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 15, 0, 38),
    Size = UDim2.new(1, -30, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    ZIndex = Z.Dialog + 2,
  }, Dialog)

  -- Calculate height based on content
  local contentHeight = math.max(TextService:GetTextSize(Content, 14, CONFIG.Font.Regular, Vector2.new(270, math.huge)).Y, 20)
  local totalHeight = 38 + contentHeight + 55
  Dialog.Size = UDim2.fromOffset(300, totalHeight)

  -- Button container
  local BtnHolder = Custom:Create("Frame", {
    Name = "Buttons",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 35),
    ZIndex = Z.Dialog + 2,
  }, Dialog)
  Custom:Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
  }, BtnHolder)

  -- Animate in
  Overlay.BackgroundTransparency = 1
  Tween(Overlay, { BackgroundTransparency = 0.5 }, 0.2)
  
  Dialog.Position = UDim2.new(0.5, 0, 0.5, 20)
  Dialog.BackgroundTransparency = 1
  Dialog.Size = UDim2.fromOffset(280, totalHeight - 20)
  Tween(Dialog, { Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(300, totalHeight) }, 0.2, Enum.EasingStyle.Back)

  local function Close()
    Tween(Overlay, { BackgroundTransparency = 1 }, 0.15)
    Tween(Dialog, { Position = UDim2.new(0.5, 0, 0.5, 20) }, 0.15)
    task.delay(0.2, function()
      if Gui then Gui:Destroy() end
    end)
  end

  -- Create buttons
  for i, btnData in ipairs(Buttons) do
    local btnText = type(btnData) == "table" and (btnData[1] or btnData.Text) or tostring(btnData)
    local btnCallback = type(btnData) == "table" and (btnData[2] or btnData.Callback) or function() end
    local isPrimary = type(btnData) == "table" and (btnData[3] or btnData.Primary) == true

    local Btn = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold,
      Text = tostring(btnText),
      TextColor3 = isPrimary and ContrastColor(CONFIG.Theme.Primary) or CONFIG.Theme.Text,
      TextSize = 13,
      BackgroundColor3 = isPrimary and CONFIG.Theme.Primary or CONFIG.Theme.Secondary,
      BackgroundTransparency = 0,
      BorderSizePixel = 0,
      Size = UDim2.fromOffset(80, 32),
      LayoutOrder = i,
      ZIndex = Z.Dialog + 3,
    }, BtnHolder)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Btn)
    
    if isPrimary then
      RegisterThemed(Btn, "BackgroundColor3", "Primary")
      RegisterThemed(Btn, "TextColor3", "Text")  -- Note: ContrastColor akan di-handle di ApplyThemeToAll
    end

    Btn.Activated:Connect(function()
      CircleClick(Btn)
      PlaySound("Click")
      SafeCall(btnCallback)
      Close()
    end)
  end

  PlaySound("Open")
end

-- ─────────────────── CreateWindow ───────────────────
function Speed_Library:CreateWindow(Config)
  local Title       = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local TabWidth    = tonumber(Get(Config, 3, "TabWidth", CONFIG.Window.TabWidth)) or CONFIG.Window.TabWidth
  local SizeUi      = Get(Config, 4, "SizeUi", CONFIG.Window.Size)
  if typeof(SizeUi) ~= "UDim2" then SizeUi = CONFIG.Window.Size end
  
  -- Clamp minimum size (v2.0)
  local MinW, MinH = 350, 220
  local w = math.max(SizeUi.X.Offset, MinW)
  local h = math.max(SizeUi.Y.Offset, MinH)
  SizeUi = UDim2.fromOffset(w, h)

  local UseSearch  = Get(Config, 5, "Search", false) == true
  local UseProfile = Get(Config, 6, "Profile", false) == true
  local Logo       = Get(Config, 7, "Logo", "")
  local HideName   = Get(Config, 8, "HideName", true) == true
  local ToggleKey  = Get(Config, 9, "ToggleKey", CONFIG.Window.ToggleKey)
  if typeof(ToggleKey) ~= "EnumItem" then ToggleKey = CONFIG.Window.ToggleKey end

  local WindowConns = {}
  local function BindGlobal(Signal, Fn)
    local c = Signal:Connect(Fn)
    table.insert(WindowConns, c)
    table.insert(LibConnections, c)
    return c
  end

  local WindowGui = NewScreenGui("KingAkbarUI_Window", 10)
  Open_Close.Image = CONFIG.Assets.FloatingButton

  local DropShadowHolder = Custom:Create("Frame", {
    Name = "Holder",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = SizeUi,
    ZIndex = Z.Background,
  }, WindowGui)

  local Main = Custom:Create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CONFIG.Theme.Background,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 1, 0),
    ClipsDescendants = true,
    ZIndex = Z.Base,
  }, DropShadowHolder)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Main)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.6 }, Main)
  RegisterThemed(Main, "BackgroundColor3", "Background")

  -- Background Image
  if CONFIG.Window.BackgroundImage ~= "" then
    local BgImage = Custom:Create("ImageLabel", {
      Name = "BackgroundImage",
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      Image = CONFIG.Window.BackgroundImage,
      ImageTransparency = CONFIG.Window.BackgroundTransparency,
      ScaleType = Enum.ScaleType.Crop,
      ZIndex = Z.Background,
    }, Main)
    Custom:Create("UICorner", {
      CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius),
    }, BgImage)

    local Tint = Custom:Create("Frame", {
      Name = "BackgroundTint",
      BackgroundColor3 = CONFIG.Window.BackgroundTint,
      BackgroundTransparency = CONFIG.Window.BackgroundTintTrans,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = Z.Background,
    }, Main)
    Custom:Create("UICorner", {
      CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius),
    }, Tint)
  end

  -- Top bar
  local Top = Custom:Create("Frame", {
    Name = "Top",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 38),
    ZIndex = Z.Control,
  }, Main)

  local TitleWidth = TextWidth(Title, 14, CONFIG.Font.Bold)
  local TitleX = 10 + ((Logo ~= "") and 28 or 0)

  if Logo ~= "" then
    Custom:Create("ImageLabel", {
      Image = Logo, BackgroundTransparency = 1, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
      Size = UDim2.fromOffset(22, 22), ZIndex = Z.Control,
    }, Top)
  end

  local TitleLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, TitleWidth + 8, 1, 0), Position = UDim2.new(0, TitleX, 0, 0),
    ZIndex = Z.Control,
  }, Top)
  RegisterThemed(TitleLabel, "TextColor3", "Primary")

  local DescLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = Description, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + 80), 1, 0),
    Position = UDim2.new(0, TitleX + TitleWidth + 14, 0, 0),
    ZIndex = Z.Control,
  }, Top)
  RegisterThemed(DescLabel, "TextColor3", "SubText")

  -- Badge holder
  local BadgeHolder = Custom:Create("Frame", {
    Name = "Badges",
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.X,
    Position = UDim2.new(1, -78, 0.5, 0),
    Size = UDim2.fromOffset(0, 24),
    ZIndex = Z.Control + 1,
  }, Top)
  Custom:Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
  }, BadgeHolder)

  BadgeHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    DescLabel.Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + 80 + BadgeHolder.AbsoluteSize.X + 6), 1, 0)
  end)

  local Close = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(25, 25),
    ZIndex = Z.Control + 1,
  }, Top)

  local Min = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "-", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -42, 0.5, 0), Size = UDim2.fromOffset(25, 25),
    ZIndex = Z.Control + 1,
  }, Top)

  -- Keybind hint (v2.0)
  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular,
    Text = "[" .. ToggleKey.Name .. "]",
    TextColor3 = CONFIG.Theme.SubText,
    TextTransparency = 0.5,
    TextSize = 10,
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -72, 0, 3),
    Size = UDim2.fromOffset(40, 12),
    ZIndex = Z.Control + 1,
  }, Top)

  Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, 38),
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = Z.Control,
  }, Main)

  -- Tab column & content area
  local LayersTab = Custom:Create("Frame", {
    Name = "LayersTab",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 9, 0, 50),
    Size = UDim2.new(0, TabWidth, 1, -59),
    ZIndex = Z.Control,
  }, Main)

  local ScrollTab = Custom:Create("ScrollingFrame", {
    Name = "ScrollTab",
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 0, Active = true,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = Z.Control,
  }, LayersTab)

  Custom:Create("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
  }, ScrollTab)

  local TopPad = UseSearch and 40 or 0
  local BotPad = UseProfile and 52 or 0
  ScrollTab.Position = UDim2.new(0, 0, 0, TopPad)
  ScrollTab.Size = UDim2.new(1, 0, 1, -(TopPad + BotPad))

  local TabSearchBox
  if UseSearch then
    local SearchFrame = Custom:Create("Frame", {
      Name = "TabSearch",
      BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = 0.92, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 32),
      ZIndex = Z.Control,
    }, LayersTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, SearchFrame)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, SearchFrame)
    TabSearchBox = Custom:Create("TextBox", {
      Font = CONFIG.Font.Bold, PlaceholderText = "Search...",
      PlaceholderColor3 = CONFIG.Theme.SubText,
      Text = "", TextColor3 = CONFIG.Theme.Text, TextSize = 13,
      ClearTextOnFocus = false,
      TextXAlignment = Enum.TextXAlignment.Left,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 10, 0, 0),
      Size = UDim2.new(1, -20, 1, 0),
      ZIndex = Z.Control + 1,
    }, SearchFrame)
  end

  if UseProfile then
    local Profile = Custom:Create("Frame", {
      Name = "Profile",
      AnchorPoint = Vector2.new(0, 1),
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 0, 1, 0),
      Size = UDim2.new(1, 0, 0, 44),
      ZIndex = Z.Control,
    }, LayersTab)

    local Avatar = Custom:Create("ImageLabel", {
      BackgroundColor3 = CONFIG.Theme.Secondary, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5),
      Position = UDim2.new(0, 2, 0.5, 0),
      Size = UDim2.fromOffset(36, 36),
      ZIndex = Z.Control + 1,
    }, Profile)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Avatar)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 1.5 }, Avatar)

    local shown = Player.DisplayName ~= "" and Player.DisplayName or Player.Name
    if HideName then shown = string.sub(shown, 1, 3) .. "***" end

    Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = ".. Welcome, " .. shown,
      TextColor3 = CONFIG.Theme.SubText, TextSize = 12,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 44, 0, 0),
      Size = UDim2.new(1, -44, 1, 0),
      ZIndex = Z.Control + 1,
    }, Profile)

    task.spawn(function()
      local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId,
          Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
      end)
      if ok and Avatar.Parent then Avatar.Image = img end
    end)
  end

  local Layers = Custom:Create("Frame", {
    Name = "Layers",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, TabWidth + 18, 0, 50),
    Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59),
    ZIndex = Z.Control,
  }, Main)

  local NameTab = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
    TextSize = 24, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 30),
    ZIndex = Z.Control,
  }, Layers)
  RegisterThemed(NameTab, "TextColor3", "Text")

  local LayersReal = Custom:Create("Frame", {
    Name = "Pages",
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ClipsDescendants = true,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 1, -33),
    ZIndex = Z.Control,
  }, Layers)

  -- ═══ Show/Hide/Close ═══
  local Destroyed = false

  local function ShowWindow()
    DropShadowHolder.Visible = true
    Open_Close.Visible = false
    PlaySound("Open")
  end

  local function HideWindow()
    DropShadowHolder.Visible = false
    Open_Close.Visible = true
    PlaySound("Close")
  end

  local function DestroyWindow()
    if Destroyed then return end
    Destroyed = true
    for _, c in ipairs(WindowConns) do
      pcall(function() c:Disconnect() end)
    end
    Open_Close.Visible = false
    WindowGui:Destroy()
    Speed_Library.Unloaded = true
    
    -- v2.0: Remove from tracked windows
    for i, win in ipairs(LibWindows) do
      if win == self then table.remove(LibWindows, i) break end
    end
  end

  Min.Activated:Connect(function()
    CircleClick(Min)
    HideWindow()
  end)

  BindGlobal(Open_Close.Activated, function()
    if Open_Close_Moved() then return end
    if DropShadowHolder.Visible then return end
    ShowWindow()
  end)

  Close.Activated:Connect(function()
    CircleClick(Close)
    DestroyWindow()
  end)

  -- v2.0: UI Toggle Keybind
  BindGlobal(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ToggleKey then
      if DropShadowHolder.Visible then
        HideWindow()
      else
        ShowWindow()
      end
    end
  end)

  MakeDraggable(Top, DropShadowHolder, BindGlobal)

  -- v2.0: Viewport clamping — keep window visible
  BindGlobal(Camera:GetPropertyChangedSignal("ViewportSize"), function()
    local viewport = Camera.ViewportSize
    local winSize = DropShadowHolder.Size
    local pos = DropShadowHolder.Position
    
    -- Calculate absolute position
    local absX = pos.X.Offset + (pos.X.Scale * viewport.X)
    local absY = pos.Y.Offset + (pos.Y.Scale * viewport.Y)
    local winW = winSize.X.Offset + (winSize.X.Scale * viewport.X)
    local winH = winSize.Y.Offset + (winSize.Y.Scale * viewport.Y)
    
    -- Clamp
    local newX = math.clamp(absX, 0, math.max(0, viewport.X - winW))
    local newY = math.clamp(absY, 0, math.max(0, viewport.Y - winH))
    
    DropShadowHolder.Position = UDim2.new(0, newX, 0, newY)
  end)

  -- ═══ Dropdown Overlay ═══
  local DropdownOpen = false
  local DropToken = 0

  local MoreBlur = Custom:Create("Frame", {
    Name = "DropdownOverlay",
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ClipsDescendants = true,
    Position = UDim2.new(1, 8, 1, 8),
    Size = UDim2.new(1, 154, 1, 54),
    Visible = false,
    ZIndex = Z.Dropdown,
  }, Layers)
  Custom:Create("UICorner", {}, MoreBlur)

  local ConnectButton = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = Z.Dropdown + 1,
  }, MoreBlur)

  local DropdownSelect = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = CONFIG.Theme.Secondary,
    BorderSizePixel = 0,
    Active = true,
    Position = UDim2.new(1, 172, 0.5, 0),
    Size = UDim2.new(0, 160, 1, -16),
    ClipsDescendants = true,
    ZIndex = Z.Dropdown + 1,
  }, MoreBlur)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, DropdownSelect)
  Custom:Create("UIStroke", {
    Color = CONFIG.Theme.Stroke, Thickness = 2, Transparency = 0.3,
  }, DropdownSelect)

  local DropdownSelectReal = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, -10, 1, -10),
    ZIndex = Z.Dropdown + 2,
  }, DropdownSelect)

  local function OpenDropdownPanel(Page)
    if DropdownOpen then return end
    DropdownOpen = true
    DropToken += 1
    for _, p in ipairs(DropdownSelectReal:GetChildren()) do
      if p:IsA("ScrollingFrame") then p.Visible = (p == Page) end
    end
    MoreBlur.Visible = true
    Tween(MoreBlur, { BackgroundTransparency = 0.7 }, 0.1)
    Tween(DropdownSelect, { Position = UDim2.new(1, -11, 0.5, 0) }, 0.1)
  end

  local function CloseDropdownPanel()
    if not DropdownOpen then return end
    DropdownOpen = false
    DropToken += 1
    local token = DropToken
    Tween(MoreBlur, { BackgroundTransparency = 1 }, 0.2)
    Tween(DropdownSelect, { Position = UDim2.new(1, 172, 0.5, 0) }, 0.2)
    task.delay(0.2, function()
      if token == DropToken and MoreBlur then MoreBlur.Visible = false end
    end)
  end

  ConnectButton.Activated:Connect(CloseDropdownPanel)

  -- ═══════════ CreateTab ═══════════
  local Tabs = {}
  local AllTabs = {}
  local CurrentTab = nil

  if TabSearchBox then
    TabSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
      local q = string.lower(TabSearchBox.Text)
      for _, T in ipairs(AllTabs) do
        T.Frame.Visible = (q == "") or (string.find(string.lower(T.Name), q, 1, true) ~= nil)
      end
    end)
  end

  local function SelectTab(Target, Instant)
    if CurrentTab == Target then return end
    CurrentTab = Target
    local t = Instant and 0 or 0.25
    for _, T in ipairs(AllTabs) do
      local sel = (T == Target)
      T.Page.Visible = sel
      Tween(T.Frame, { BackgroundTransparency = sel and 0.92 or 0.999 }, t)
      Tween(T.Bar, { Size = sel and UDim2.new(0, 1, 0, 14) or UDim2.new(0, 1, 0, 0) }, t)
      Tween(T.Stroke, { Transparency = sel and 0 or 1 }, t)
    end
    NameTab.Text = Target.Name
  end

  function Tabs:CreateTab(TabConfig)
    local _Name = tostring(Get(TabConfig, 1, "Name", ""))
    local Icon  = Get(TabConfig, 2, "Icon", "")
    if type(Icon) ~= "string" then Icon = "" end

    local TabIndex = #AllTabs + 1

    local ScrolLayers = Custom:Create("ScrollingFrame", {
      Name = "Page_" .. _Name,
      CanvasSize = UDim2.new(0, 0, 0, 0),
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      ScrollingDirection = Enum.ScrollingDirection.Y,
      ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
      ScrollBarThickness = 0, Active = true,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      Visible = false,
      ZIndex = Z.Control,
    }, LayersReal)

    Custom:Create("UIListLayout", {
      Padding = UDim.new(0, 3),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, ScrolLayers)

    local Tab = Custom:Create("Frame", {
      Name = "Tab",
      BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = 0.999,
      BorderSizePixel = 0,
      LayoutOrder = TabIndex,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = Z.Control,
    }, ScrollTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Tab)

    local TabButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = "",
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = Z.Control + 2,
    }, Tab)

    local TabLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = _Name, TextColor3 = CONFIG.Theme.Text,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, Icon ~= "" and -30 or -10, 1, 0),
      Position = UDim2.new(0, Icon ~= "" and 30 or 10, 0, 0),
      ZIndex = Z.Control + 1,
    }, Tab)
    RegisterThemed(TabLabel, "TextColor3", "Text")

    if Icon ~= "" then
      Custom:Create("ImageLabel", {
        Image = Icon, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0, 7), Size = UDim2.fromOffset(16, 16),
        ZIndex = Z.Control + 1,
      }, Tab)
    end

    local Bar = Custom:Create("Frame", {
      Name = "ChooseFrame",
      AnchorPoint = Vector2.new(0, 0.5),
      BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
      Position = UDim2.new(0, 2, 0.5, 0),
      Size = UDim2.new(0, 1, 0, 0),
      ZIndex = Z.Control + 1,
    }, Tab)
    local BarStroke = Custom:Create("UIStroke", {
      Color = CONFIG.Theme.Primary, Thickness = 1.6, Transparency = 1,
    }, Bar)
    Custom:Create("UICorner", {}, Bar)
    RegisterThemed(Bar, "BackgroundColor3", "Primary")
    RegisterThemed(BarStroke, "Color", "Primary")

    local TabObj = {
      Name = _Name, Frame = Tab, Page = ScrolLayers, Bar = Bar, Stroke = BarStroke,
    }
    table.insert(AllTabs, TabObj)

    if TabIndex == 1 then
      SelectTab(TabObj, true)
    end

    TabButton.Activated:Connect(function()
      CircleClick(TabButton)
      PlaySound("Click")
      CloseDropdownPanel()
      SelectTab(TabObj, false)
    end)

    -- ═══════════ Sections ═══════════
    local Sections, CountSection = {}, 0

    function Sections:AddSection(SectionTitle, OpenDefault)
      if type(SectionTitle) == "table" then
        OpenDefault = SectionTitle[2]
        if OpenDefault == nil then OpenDefault = SectionTitle.Open end
        SectionTitle = SectionTitle[1] or SectionTitle.Title
      end
      SectionTitle = tostring(SectionTitle or "")
      local OpenSection = OpenDefault == true
      CountSection += 1

      local Section = Custom:Create("Frame", {
        Name = "Section",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = CountSection,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = Z.Base,
      }, ScrolLayers)

      local SectionReal = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = CONFIG.Theme.Panel,
        BackgroundTransparency = 0.935, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = Z.Base,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SectionReal)
      RegisterThemed(SectionReal, "BackgroundColor3", "Panel")

      local SectionButton = Custom:Create("TextButton", {
        Font = CONFIG.Font.Regular, Text = "",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = Z.Control + 2,
      }, SectionReal)

      local FeatureFrame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = Z.Control + 1,
      }, SectionReal)

      Custom:Create("ImageLabel", {
        Image = CONFIG.Assets.ArrowIcon,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = -90, Size = UDim2.new(1, 6, 1, 6),
        ZIndex = Z.Control + 1,
      }, FeatureFrame)

      local SectionLabel = Custom:Create("TextLabel", {
        Font = CONFIG.Font.Bold, Text = SectionTitle,
        TextColor3 = CONFIG.Theme.Text, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -50, 0, 13),
        ZIndex = Z.Control + 1,
      }, SectionReal)
      RegisterThemed(SectionLabel, "TextColor3", "Text")

      local SectionDecideFrame = Custom:Create("Frame", {
        BackgroundColor3 = CONFIG.Theme.Panel, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 33),
        Size = UDim2.new(0, 0, 0, 2),
        ZIndex = Z.Base,
      }, Section)
      Custom:Create("UICorner", {}, SectionDecideFrame)
      Custom:Create("UIGradient", {
        Color = ColorSequence.new {
          ColorSequenceKeypoint.new(0, CONFIG.Theme.Background),
          ColorSequenceKeypoint.new(0.5, CONFIG.Theme.Primary),
          ColorSequenceKeypoint.new(1, CONFIG.Theme.Background),
        },
      }, SectionDecideFrame)

      local SectionAdd = Custom:Create("Frame", {
        Name = "SectionContent",
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = Z.Base,
      }, Section)

      local SectionList = Custom:Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
      }, SectionAdd)

      local function ApplyLayout(Animate)
        local t = Animate and 0.15 or 0
        local contentH = SectionList.AbsoluteContentSize.Y
        SectionAdd.Size = UDim2.new(1, 0, 0, contentH)
        Tween(FeatureFrame, { Rotation = OpenSection and 90 or 0 }, t)
        Tween(Section, { Size = UDim2.new(1, 0, 0, OpenSection and (38 + contentH + 2) or 30) }, t)
        Tween(SectionDecideFrame, {
          Size = OpenSection and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 2),
        }, t)
      end

      SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ApplyLayout(true)
      end)

      SectionButton.Activated:Connect(function()
        CircleClick(SectionButton)
        PlaySound("Click")
        OpenSection = not OpenSection
        ApplyLayout(true)
      end)

      ApplyLayout(false)

      -- ═══════════ Items ═══════════
      local Item = {}
      local ItemCount = 0
      local function NextOrder()
        ItemCount += 1
        return ItemCount
      end

      function Item:AddParagraph(PConfig)
        local PTitle   = Get(PConfig, 1, "Title", "")
        local PContent = Get(PConfig, 2, "Content", "")
        local Tooltip  = Get(PConfig, 3, "Tooltip", "")
        local Base = NewItemBase(SectionAdd, NextOrder(), PTitle, PContent, 16)
        local Funcs = {}
        AttachCommon(Funcs, Base)
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        function Funcs:Set(SConfig)
          Base.Title.Text = tostring(Get(SConfig, 1, "Title", Base.Title.Text))
          Base.Content.Text = tostring(Get(SConfig, 2, "Content", Base.Content.Text))
        end

        return Funcs
      end

      function Item:AddSeperator(SConfig)
        local STitle  = tostring(Get(SConfig, 1, "Title", ""))
        local Tooltip = Get(SConfig, 2, "Tooltip", "")
        local Funcs = {}

        local Seperator = Custom:Create("Frame", {
          Name = "Seperator",
          BackgroundColor3 = CONFIG.Theme.Divider,
          BackgroundTransparency = 0.1, BorderSizePixel = 0,
          LayoutOrder = NextOrder(),
          Size = UDim2.new(1, 0, 0, 30),
          ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Seperator)
        RegisterThemed(Seperator, "BackgroundColor3", "Divider")

        local SepLabel = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = STitle,
          TextColor3 = CONFIG.Theme.Text,
          TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
          TextStrokeTransparency = 0.8, TextSize = 14,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Center,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 12, 0, 0),
          Size = UDim2.new(1, -16, 1, 0),
          Name = "SeperatorTitle",
          ZIndex = Z.Content,
        }, Seperator)
        RegisterThemed(SepLabel, "TextColor3", "Text")
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Seperator, Tooltip)
        end

        function Funcs:Set(NConfig)
          SepLabel.Text = tostring(Get(NConfig, 1, "Title", ""))
        end
        function Funcs:SetVisible(State) Seperator.Visible = State and true or false end
        function Funcs:Destroy() Seperator:Destroy() end

        return Funcs
      end

      function Item:AddLine()
        local Funcs = {}
        local Line = Custom:Create("Frame", {
          Name = "Line",
          BackgroundColor3 = CONFIG.Theme.LineColor,
          BackgroundTransparency = 0.2, BorderSizePixel = 0,
          LayoutOrder = NextOrder(),
          Size = UDim2.new(1, 0, 0, 7),
          ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Line)
        RegisterThemed(Line, "BackgroundColor3", "LineColor")
        function Funcs:Destroy() Line:Destroy() end
        return Funcs
      end

      function Item:AddButton(BConfig)
        local BTitle   = Get(BConfig, 1, "Title", "")
        local BContent = Get(BConfig, 2, "Content", "")
        local Icon     = Get(BConfig, 3, "Icon", CONFIG.Assets.DefaultIcon)
        local Callback = Get(BConfig, 4, "Callback", function() end)
        local Tooltip  = Get(BConfig, 5, "Tooltip", "")
        local Funcs = {}

        local Base = NewItemBase(SectionAdd, NextOrder(), BTitle, BContent, 70)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        local ButtonButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = Z.Control + 2,
        }, Base.Frame)

        if type(Icon) == "string" and Icon ~= "" then
          Custom:Create("ImageLabel", {
            Image = Icon,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(1, -15, 0.5, 0),
            Size = UDim2.fromOffset(25, 25),
            ZIndex = Z.Content,
          }, Base.Frame)
        end

        ButtonButton.Activated:Connect(function()
          CircleClick(ButtonButton)
          PlaySound("Click")
          SafeCall(Callback)
        end)

        function Funcs:Set(NConfig)
          if Get(NConfig, 1, "Title", nil) ~= nil then Funcs:SetTitle(Get(NConfig, 1, "Title", "")) end
          if Get(NConfig, 2, "Content", nil) ~= nil then Funcs:SetContent(Get(NConfig, 2, "Content", "")) end
        end

        return Funcs
      end

      function Item:AddToggle(TConfig)
        local TTitle   = Get(TConfig, 1, "Title", "")
        local TContent = Get(TConfig, 2, "Content", "")
        local Default  = Get(TConfig, 3, "Default", false)
        local Callback = Get(TConfig, 4, "Callback", function() end)
        local Tooltip  = Get(TConfig, 5, "Tooltip", "")
        local SaveKey  = Get(TConfig, 6, "SaveKey", "")  -- v2.0: auto-save key
        local Funcs = { Value = Default == true }

        -- v2.0: Load dari save jika ada
        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved ~= nil then Funcs.Value = saved == true end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), TTitle, TContent, 70)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end
        
        local Toggle = Base.Frame

        local ToggleButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = Z.Control + 2,
        }, Toggle)

        local FeatureFrame2 = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92, BorderSizePixel = 0,
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(30, 15),
          ZIndex = Z.Content,
        }, Toggle)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, FeatureFrame2)
        RegisterThemed(FeatureFrame2, "BackgroundColor3", "Panel")

        local UIStroke8 = Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Text, Thickness = 2, Transparency = 0.9,
        }, FeatureFrame2)

        local ToggleCircle = Custom:Create("Frame", {
          BackgroundColor3 = ContrastColor(CONFIG.Theme.Primary),
          BorderSizePixel = 0,
          Size = UDim2.fromOffset(14, 14),
          Position = UDim2.new(0, 0, 0, 0),
          ZIndex = Z.Control,
        }, FeatureFrame2)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 15) }, ToggleCircle)

        local currentTween = nil
        local function ToggleAnimation(isOn)
          if currentTween then currentTween:Cancel() end
          Tween(Base.Title, {
            TextColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text,
          }, 0.2)
          Tween(ToggleCircle, {
            Position = isOn and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0),
          }, 0.2)
          Tween(UIStroke8, {
            Color = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text,
            Transparency = isOn and 0 or 0.9,
          }, 0.2)
          currentTween = Tween(FeatureFrame2, {
            BackgroundColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Panel,
            BackgroundTransparency = isOn and 0 or 0.92,
          }, 0.2)
          PlaySound(isOn and "ToggleOn" or "ToggleOff")
        end

        -- v2.0: FIX — Pisahkan visual update dari callback
        function Funcs:Set(Value, fire)
          Funcs.Value = Value == true
          ToggleAnimation(Funcs.Value)
          if fire ~= false then
            SafeCall(Callback, Funcs.Value)
            -- v2.0: Auto-save
            if SaveKey ~= "" then
              SaveSystem.Set(SaveKey, Funcs.Value)
            end
          end
        end

        ToggleButton.Activated:Connect(function()
          CircleClick(ToggleButton)
          Funcs:Set(not Funcs.Value)  -- fire = true (default)
        end)

        -- v2.0: Init tanpa fire callback
        Funcs:Set(Funcs.Value, false)

        return Funcs
      end

      function Item:AddKeybind(KConfig)
        local KTitle   = Get(KConfig, 1, "Title", "")
        local KContent = Get(KConfig, 2, "Content", "")
        local Default  = Get(KConfig, 3, "Default", Enum.KeyCode.Unknown)
        local Callback = Get(KConfig, 4, "Callback", function() end)
        local Tooltip  = Get(KConfig, 5, "Tooltip", "")
        local SaveKey  = Get(KConfig, 6, "SaveKey", "")
        
        local Funcs = { Value = Default }
        local CurrentKey = Default
        local Listening = false

        -- v2.0: Load dari save
        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved and typeof(saved) == "string" then
            local keyCode = Enum.KeyCode[saved]
            if keyCode then CurrentKey = keyCode end
          end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), KTitle, KContent, 70)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        -- Keybind display button
        local KeyBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold,
          Text = CurrentKey ~= Enum.KeyCode.Unknown and CurrentKey.Name or "...",
          TextColor3 = CONFIG.Theme.Text,
          TextSize = 11,
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92,
          BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5),
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(50, 20),
          ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, KeyBtn)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, KeyBtn)
        RegisterThemed(KeyBtn, "TextColor3", "Text")

        -- Input handler untuk keybind
        BindGlobal(UserInputService.InputBegan, function(input, gameProcessed)
          if gameProcessed then return end
          
          if Listening then
            -- Sedang menunggu input key baru
            if input.KeyCode ~= Enum.KeyCode.Unknown then
              CurrentKey = input.KeyCode
              KeyBtn.Text = CurrentKey.Name
              KeyBtn.TextColor3 = CONFIG.Theme.Text
              Listening = false
              -- Save
              if SaveKey ~= "" then
                SaveSystem.Set(SaveKey, CurrentKey.Name)
              end
            end
          else
            -- Normal key press
            if input.KeyCode == CurrentKey then
              SafeCall(Callback, CurrentKey)
            end
          end
        end)

        KeyBtn.Activated:Connect(function()
          CircleClick(KeyBtn)
          PlaySound("Click")
          Listening = true
          KeyBtn.Text = "..."
          KeyBtn.TextColor3 = CONFIG.Theme.Primary
        end)

        function Funcs:Set(NewKey, fire)
          if typeof(NewKey) == "EnumItem" then
            CurrentKey = NewKey
            KeyBtn.Text = NewKey.Name
            if fire ~= false then
              SafeCall(Callback, CurrentKey)
            end
          end
        end

        function Funcs:Get()
          return CurrentKey
        end

        Funcs.Value = CurrentKey
        return Funcs
      end

      function Item:AddColorPicker(CConfig)
        local CTitle   = Get(CConfig, 1, "Title", "")
        local CContent = Get(CConfig, 2, "Content", "")
        local Default  = Get(CConfig, 3, "Default", Color3.fromRGB(255, 0, 0))
        local Callback = Get(CConfig, 4, "Callback", function() end)
        local Presets  = Get(CConfig, 5, "Presets", nil)
        local Tooltip  = Get(CConfig, 6, "Tooltip", "")
        local SaveKey  = Get(CConfig, 7, "SaveKey", "")
        
        local Funcs = { Value = Default }

        -- v2.0: Load dari save
        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved and type(saved) == "table" then
            pcall(function()
              Funcs.Value = Color3.fromRGB(saved[1], saved[2], saved[3])
            end)
          end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), CTitle, CContent, 70)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        -- Color preview button
        local ColorBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundColor3 = Funcs.Value,
          BackgroundTransparency = 0,
          BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5),
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(40, 20),
          ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, ColorBtn)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, ColorBtn)

        -- v2.0: Simple color picker popup
        local PickerGui, PickerFrame, HueSlider, SVPicker = nil, nil, nil, nil
        local IsOpen = false

        local function OpenPicker()
          if IsOpen then return end
          IsOpen = true

          PickerGui = Custom:Create("Frame", {
            Name = "ColorPicker",
            BackgroundColor3 = CONFIG.Theme.Background,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(220, 200),
            ZIndex = Z.Dialog,
          }, Base.Frame:FindFirstAncestorOfClass("ScreenGui"))
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, PickerGui)
          Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.5 }, PickerGui)

          -- Title
          Custom:Create("TextLabel", {
            Font = CONFIG.Font.Bold, Text = "Pick Color",
            TextColor3 = CONFIG.Theme.Text, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -24, 0, 18),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)

          -- SV (Saturation-Value) Picker
          SVPicker = Custom:Create("ImageButton", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 0, 32),
            Size = UDim2.fromOffset(160, 120),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SVPicker)

          -- Hue Slider (vertical bar)
          HueSlider = Custom:Create("ImageButton", {
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 185, 0, 32),
            Size = UDim2.fromOffset(20, 120),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, HueSlider)

          -- Current color preview
          local PreviewLabel = Custom:Create("TextLabel", {
            Font = CONFIG.Font.Bold, Text = "Current",
            TextColor3 = CONFIG.Theme.Text, TextSize = 12,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 0, 160),
            Size = UDim2.new(0, 50, 0, 20),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)

          local PreviewBox = Custom:Create("Frame", {
            BackgroundColor3 = Funcs.Value,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 70, 0, 160),
            Size = UDim2.fromOffset(30, 20),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, PreviewBox)

          -- RGB Display
          local RGBLabel = Custom:Create("TextLabel", {
            Font = CONFIG.Font.Regular,
            Text = string.format("R:%d G:%d B:%d", Funcs.Value.R * 255, Funcs.Value.G * 255, Funcs.Value.B * 255),
            TextColor3 = CONFIG.Theme.SubText, TextSize = 11,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 110, 0, 160),
            Size = UDim2.new(1, -120, 0, 20),
            ZIndex = Z.Dialog + 1,
          }, PickerGui)

          -- Close button
          local CloseBtn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Regular, Text = "X",
            TextColor3 = CONFIG.Theme.Text, TextSize = 14,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -5, 0, 5),
            Size = UDim2.fromOffset(25, 25),
            ZIndex = Z.Dialog + 2,
          }, PickerGui)

          -- Presets (jika ada)
          if Presets and type(Presets) == "table" then
            local PresetHolder = Custom:Create("Frame", {
              BackgroundTransparency = 1, BorderSizePixel = 0,
              Position = UDim2.new(0, 12, 0, 185),
              Size = UDim2.new(1, -24, 0, 0),
              AutomaticSize = Enum.AutomaticSize.Y,
              ZIndex = Z.Dialog + 1,
            }, PickerGui)
            Custom:Create("UIListLayout", {
              FillDirection = Enum.FillDirection.Horizontal,
              HorizontalAlignment = Enum.HorizontalAlignment.Left,
              Padding = UDim.new(0, 4),
              SortOrder = Enum.SortOrder.LayoutOrder,
            }, PresetHolder)

            for i, presetColor in ipairs(Presets) do
              local PresetBtn = Custom:Create("TextButton", {
                BackgroundColor3 = presetColor,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(24, 24),
                LayoutOrder = i,
                ZIndex = Z.Dialog + 2,
                Text = "",
              }, PresetHolder)
              Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, PresetBtn)

              PresetBtn.Activated:Connect(function()
                Funcs.Value = presetColor
                ColorBtn.BackgroundColor3 = presetColor
                PreviewBox.BackgroundColor3 = presetColor
                RGBLabel.Text = string.format("R:%d G:%d B:%d", presetColor.R * 255, presetColor.G * 255, presetColor.B * 255)
                SafeCall(Callback, presetColor)
                if SaveKey ~= "" then
                  SaveSystem.Set(SaveKey, {presetColor.R * 255, presetColor.G * 255, presetColor.B * 255})
                end
              end)
            end
          end

          -- State variables
          local currentHue = 0
          local currentSat = 1
          local currentVal = 1
          local updatingSV = false
          local updatingHue = false

          -- Convert Color3 to HSV
          local function Color3ToHSV(c)
            local h, s, v
            local max = math.max(c.R, c.G, c.B)
            local min = math.min(c.R, c.G, c.B)
            local delta = max - min
            
            if delta == 0 then
              h = 0
            elseif max == c.R then
              h = ((c.G - c.B) / delta) % 6
            elseif max == c.G then
              h = (c.B - c.R) / delta + 2
            else
              h = (c.R - c.G) / delta + 4
            end
            h = h / 6
            
            s = max == 0 and 0 or delta / max
            v = max
            return h, s, v
          end

          currentHue, currentSat, currentVal = Color3ToHSV(Funcs.Value)

          local function UpdateSVGradient()
            -- Update background color of SV picker based on hue
            local hueColor = Color3.fromHSV(currentHue, 1, 1)
            SVPicker.BackgroundColor3 = Color3.fromHSV(currentHue, 0, 1)
            -- Apply gradient
            local existing = SVPicker:FindFirstChild("SVGradient")
            if existing then existing:Destroy() end
            Custom:Create("UIGradient", {
              Name = "SVGradient",
              Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, hueColor),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(currentHue, 0, 1)),
              }),
            }, SVPicker)
          end

          local function UpdateColor()
            local newColor = Color3.fromHSV(currentHue, currentSat, currentVal)
            Funcs.Value = newColor
            ColorBtn.BackgroundColor3 = newColor
            PreviewBox.BackgroundColor3 = newColor
            RGBLabel.Text = string.format("R:%d G:%d B:%d", newColor.R * 255, newColor.G * 255, newColor.B * 255)
            SafeCall(Callback, newColor)
          end

          UpdateSVGradient()

          -- SV Picker input
          SVPicker.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              updatingSV = true
              local relPos = input.Position - SVPicker.AbsolutePosition
              currentSat = math.clamp(relPos.X / SVPicker.AbsoluteSize.X, 0, 1)
              currentVal = 1 - math.clamp(relPos.Y / SVPicker.AbsoluteSize.Y, 0, 1)
              UpdateColor()
            end
          end)

          BindGlobal(UserInputService.InputChanged, function(input)
            if updatingSV then
              if input.UserInputType == Enum.UserInputType.MouseMovement then
                local relPos = UserInputService:GetMouseLocation() - SVPicker.AbsolutePosition
                currentSat = math.clamp(relPos.X / SVPicker.AbsoluteSize.X, 0, 1)
                currentVal = 1 - math.clamp(relPos.Y / SVPicker.AbsoluteSize.Y, 0, 1)
                UpdateColor()
              end
            elseif updatingHue then
              if input.UserInputType == Enum.UserInputType.MouseMovement then
                local relPos = UserInputService:GetMouseLocation() - HueSlider.AbsolutePosition
                currentHue = math.clamp(relPos.Y / HueSlider.AbsoluteSize.Y, 0, 1)
                UpdateSVGradient()
                UpdateColor()
              end
            end
          end)

          BindGlobal(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              updatingSV = false
              updatingHue = false
              -- Save on release
              if SaveKey ~= "" then
                SaveSystem.Set(SaveKey, {Funcs.Value.R * 255, Funcs.Value.G * 255, Funcs.Value.B * 255})
              end
            end
          end)

          -- Hue slider input
          HueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              updatingHue = true
              local relPos = input.Position - HueSlider.AbsolutePosition
              currentHue = math.clamp(relPos.Y / HueSlider.AbsoluteSize.Y, 0, 1)
              UpdateSVGradient()
              UpdateColor()
            end
          end)

          local function ClosePicker()
            IsOpen = false
            if PickerGui then
              Tween(PickerGui, { BackgroundTransparency = 1 }, 0.15)
              task.delay(0.2, function()
                if PickerGui then PickerGui:Destroy() end
              end)
            end
          end

          CloseBtn.Activated:Connect(ClosePicker)
        end

        ColorBtn.Activated:Connect(function()
          CircleClick(ColorBtn)
          PlaySound("Click")
          OpenPicker()
        end)

        function Funcs:Set(color, fire)
          if typeof(color) == "Color3" then
            Funcs.Value = color
            ColorBtn.BackgroundColor3 = color
            if fire ~= false then
              SafeCall(Callback, color)
            end
          end
        end

        function Funcs:Get()
          return Funcs.Value
        end

        return Funcs
      end

      function Item:AddSlider(SConfig)
        local STitle    = Get(SConfig, 1, "Title", "")
        local SContent  = Get(SConfig, 2, "Content", "")
        local Increment = tonumber(Get(SConfig, 3, "Increment", 1)) or 1
        local Min       = tonumber(Get(SConfig, 4, "Min", 0)) or 0
        local Max       = tonumber(Get(SConfig, 5, "Max", 100)) or 100
        local Default   = tonumber(Get(SConfig, 6, "Default", Min)) or Min
        local Callback  = Get(SConfig, 7, "Callback", function() end)
        local Tooltip   = Get(SConfig, 8, "Tooltip", "")
        local SaveKey   = Get(SConfig, 9, "SaveKey", "")

        if Increment <= 0 then Increment = 1 end
        if Max <= Min then Max = Min + 1 end

        local Funcs = { Value = Default }

        -- v2.0: Load dari save
        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved ~= nil then
            local num = tonumber(saved)
            if num then Funcs.Value = math.clamp(num, Min, Max) end
          end
        end

        local decimals = 0
        local frac = tostring(Increment):match("%.(%d+)")
        if frac then decimals = #frac end

        local function Snap(v)
          v = Min + math.floor((v - Min) / Increment + 0.5) * Increment
          v = math.clamp(v, Min, Max)
          if decimals > 0 then
            v = tonumber(string.format("%." .. decimals .. "f", v)) or v
          end
          return v
        end
        Funcs.Value = Snap(Funcs.Value)

        local Base = NewItemBase(SectionAdd, NextOrder(), STitle, SContent, 190)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end
        
        local Slider = Base.Frame

        -- v2.0: Slider fill bar + track
        local SliderTrack = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92,
          BorderSizePixel = 0,
          Position = UDim2.new(1, -185, 0.5, 12),
          Size = UDim2.fromOffset(100, 5),
          ZIndex = Z.Content,
        }, Slider)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SliderTrack)

        local SliderFill = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary,
          BackgroundTransparency = 0,
          BorderSizePixel = 0,
          Position = UDim2.new(0, 0, 0.5, 0),
          Size = UDim2.new(0, 0, 1, 0),
          ZIndex = Z.Content + 1,
        }, SliderTrack)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SliderFill)
        RegisterThemed(SliderFill, "BackgroundColor3", "Primary")

        -- Slider input display (click to edit)
        local SliderInput = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold,
          Text = tostring(Funcs.Value),
          TextColor3 = ContrastColor(CONFIG.Theme.Primary),
          TextSize = 12,
          BackgroundColor3 = CONFIG.Theme.Primary,
          BackgroundTransparency = 0,
          BorderSizePixel = 0,
          AnchorPoint = Vector2.new(0, 0.5),
          Position = UDim2.new(1, -75, 0.5, 12),
          Size = UDim2.fromOffset(50, 20),
          ZIndex = Z.Content,
        }, Slider)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, SliderInput)
        RegisterThemed(SliderInput, "BackgroundColor3", "Primary")

        -- Slider knob (draggable)
        local SliderKnob = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0.5, 0.5),
          BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BorderSizePixel = 0,
          Position = UDim2.new(0, 0, 0.5, 0),
          Size = UDim2.fromOffset(12, 12),
          ZIndex = Z.Control,
        }, SliderTrack)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SliderKnob)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Primary, Thickness = 2,
        }, SliderKnob)

        local function UpdateVisual()
          local alpha = (Funcs.Value - Min) / (Max - Min)
          SliderFill.Size = UDim2.new(alpha, 0, 1, 0)
          SliderKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
          SliderInput.Text = tostring(Funcs.Value)
        end

        local function SetValue(v, fire)
          v = Snap(v)
          if v ~= Funcs.Value then
            Funcs.Value = v
            UpdateVisual()
            if fire ~= false then
              SafeCall(Callback, v)
              if SaveKey ~= "" then
                SaveSystem.Set(SaveKey, v)
              end
            end
          end
        end

        -- Drag handling
        local dragging = false
        SliderTrack.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local relPos = input.Position - SliderTrack.AbsolutePosition
            local alpha = math.clamp(relPos.X / SliderTrack.AbsoluteSize.X, 0, 1)
            local v = Min + (Max - Min) * alpha
            SetValue(v)
          end
        end)

        SliderKnob.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
          end
        end)

        BindGlobal(UserInputService.InputChanged, function(input)
          if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local relPos = mousePos - SliderTrack.AbsolutePosition
            local alpha = math.clamp(relPos.X / SliderTrack.AbsoluteSize.X, 0, 1)
            local v = Min + (Max - Min) * alpha
            SetValue(v)
          end
        end)

        BindGlobal(UserInputService.InputEnded, function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
          end
        end)

        -- Click on input to type value
        SliderInput.Activated:Connect(function()
          -- Convert to TextBox for editing
          local textBox = Custom:Create("TextBox", {
            Font = CONFIG.Font.Bold,
            Text = tostring(Funcs.Value),
            TextColor3 = ContrastColor(CONFIG.Theme.Primary),
            TextSize = 12,
            BackgroundColor3 = CONFIG.Theme.Primary,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, -75, 0.5, 12),
            Size = UDim2.fromOffset(50, 20),
            ZIndex = Z.Control,
            ClearTextOnFocus = true,
          }, Slider)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, textBox)

          SliderInput.Visible = false
          textBox:CaptureFocus()

          textBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
              local num = tonumber(textBox.Text)
              if num then
                SetValue(math.clamp(num, Min, Max))
              end
            end
            textBox:Destroy()
            SliderInput.Visible = true
          end)
        end)

        function Funcs:Set(v, fire)
          if tonumber(v) then
            SetValue(tonumber(v), fire)
          end
        end

        UpdateVisual()
        return Funcs
      end

      function Item:AddInput(IConfig)
        local ITitle    = Get(IConfig, 1, "Title", "")
        local IContent  = Get(IConfig, 2, "Content", "")
        local Default   = Get(IConfig, 3, "Default", "")
        local Placeholder = Get(IConfig, 4, "Placeholder", "Type here...")
        local Callback  = Get(IConfig, 5, "Callback", function() end)
        local Tooltip   = Get(IConfig, 6, "Tooltip", "")
        local SaveKey   = Get(IConfig, 7, "SaveKey", "")

        local Funcs = { Value = tostring(Default) }

        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved ~= nil then Funcs.Value = tostring(saved) end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), ITitle, IContent, 190)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        local TextBox = Custom:Create("TextBox", {
          Font = CONFIG.Font.Bold,
          Text = Funcs.Value,
          PlaceholderText = tostring(Placeholder),
          PlaceholderColor3 = CONFIG.Theme.SubText,
          TextColor3 = CONFIG.Theme.Text,
          TextSize = 12,
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92,
          BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5),
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(150, 25),
          ZIndex = Z.Content,
          ClearTextOnFocus = false,
          TextXAlignment = Enum.TextXAlignment.Left,
          ClipsDescendants = true,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, TextBox)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, TextBox)
        Custom:Create(" UIPadding", { -- Space from left
          PaddingLeft = UDim.new(0, 8),
        }, TextBox)

        TextBox.FocusLost:Connect(function(enterPressed)
          Funcs.Value = TextBox.Text
          if enterPressed or true then  -- Fire on focus lost too
            SafeCall(Callback, TextBox.Text)
            if SaveKey ~= "" then
              SaveSystem.Set(SaveKey, TextBox.Text)
            end
          end
        end)

        function Funcs:Set(text, fire)
          Funcs.Value = tostring(text)
          TextBox.Text = Funcs.Value
          if fire ~= false then
            SafeCall(Callback, Funcs.Value)
          end
        end

        return Funcs
      end

      function Item:AddDropdown(DConfig)
        local DTitle    = Get(DConfig, 1, "Title", "")
        local DContent  = Get(DConfig, 2, "Content", "")
        local Multi     = Get(DConfig, 3, "Multi", false) == true
        local Options   = Get(DConfig, 4, "Options", {})
        local Default   = Get(DConfig, 5, "Default", Multi and {} or "")
        local Callback  = Get(DConfig, 6, "Callback", function() end)
        local Searchable = Get(DConfig, 7, "Search", true) == true
        local Tooltip   = Get(DConfig, 8, "Tooltip", "")
        local SaveKey   = Get(DConfig, 9, "SaveKey", "")

        local Funcs = { Value = Default }

        if SaveKey ~= "" then
          local saved = SaveSystem.Get(SaveKey, nil)
          if saved ~= nil then Funcs.Value = saved end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), DTitle, DContent, 190)
        AttachCommon(Funcs, Base)
        
        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Base.Frame, Tooltip)
        end

        -- Dropdown button
        local DropBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold,
          Text = Multi and (type(Funcs.Value) == "table" and #Funcs.Value > 0 and tostring(#Funcs.Value) .. " selected" or "None") or tostring(Funcs.Value),
          TextColor3 = CONFIG.Theme.Text,
          TextSize = 11,
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92,
          BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5),
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(100, 22),
          ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, DropBtn)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, DropBtn)

        -- Dropdown panel
        local DropPanel = Custom:Create("ScrollingFrame", {
          Name = "Dropdown_" .. tostring(DTitle),
          BackgroundColor3 = CONFIG.Theme.Background,
          BackgroundTransparency = 0.05,
          BorderSizePixel = 0,
          Size = UDim2.new(1, -10, 1, -10),
          CanvasSize = UDim2.new(0, 0, 0, 0),
          AutomaticCanvasSize = Enum.AutomaticSize.Y,
          ScrollBarThickness = 2,
          ScrollBarImageColor3 = CONFIG.Theme.SubText,
          Visible = false,
          ZIndex = Z.Dropdown + 2,
        }, DropdownSelectReal)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, DropPanel)
        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 2),
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, DropPanel)

        -- Search box (if searchable)
        local SearchBox = nil
        if Searchable then
          SearchBox = Custom:Create("TextBox", {
            Font = CONFIG.Font.Bold,
            Text = "",
            PlaceholderText = "Search...",
            PlaceholderColor3 = CONFIG.Theme.SubText,
            TextColor3 = CONFIG.Theme.Text,
            TextSize = 11,
            BackgroundColor3 = CONFIG.Theme.Panel,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 24),
            ZIndex = Z.Dropdown + 3,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 0,
          }, DropPanel)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SearchBox)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 6) }, SearchBox)
        end

        local OptionButtons = {}

        local function UpdateButtonText()
          if Multi then
            if type(Funcs.Value) == "table" then
              DropBtn.Text = #Funcs.Value > 0 and tostring(#Funcs.Value) .. " selected" or "None"
            end
          else
            DropBtn.Text = tostring(Funcs.Value)
          end
        end

        local function CreateOptionButton(name, order)
          local OptionBtn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = tostring(name),
            TextColor3 = CONFIG.Theme.Text,
            TextSize = 12,
            BackgroundColor3 = CONFIG.Theme.Panel,
            BackgroundTransparency = 0.92,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -8, 0, 26),
            ZIndex = Z.Dropdown + 3,
            LayoutOrder = order,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.None,
          }, DropPanel)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, OptionBtn)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, OptionBtn)

          -- Highlight if selected
          local isSelected = false
          if Multi and type(Funcs.Value) == "table" then
            for _, v in ipairs(Funcs.Value) do
              if v == name then isSelected = true break end
            end
          elseif not Multi and Funcs.Value == name then
            isSelected = true
          end
          if isSelected then
            OptionBtn.BackgroundColor3 = CONFIG.Theme.Primary
            OptionBtn.TextColor3 = ContrastColor(CONFIG.Theme.Primary)
            OptionBtn.BackgroundTransparency = 0.8
          end

          OptionBtn.Activated:Connect(function()
            CircleClick(OptionBtn)
            PlaySound("Click")
            if Multi then
              if type(Funcs.Value) ~= "table" then Funcs.Value = {} end
              local found = false
              for i, v in ipairs(Funcs.Value) do
                if v == name then
                  table.remove(Funcs.Value, i)
                  found = true
                  break
                end
              end
              if not found then
                table.insert(Funcs.Value, name)
              end
              SafeCall(Callback, Funcs.Value)
              if SaveKey ~= "" then SaveSystem.Set(SaveKey, Funcs.Value) end
              -- Update visual
              if isSelected then
                OptionBtn.BackgroundColor3 = CONFIG.Theme.Panel
                OptionBtn.TextColor3 = CONFIG.Theme.Text
                OptionBtn.BackgroundTransparency = 0.92
              else
                OptionBtn.BackgroundColor3 = CONFIG.Theme.Primary
                OptionBtn.TextColor3 = ContrastColor(CONFIG.Theme.Primary)
                OptionBtn.BackgroundTransparency = 0.8
              end
            else
              Funcs.Value = name
              SafeCall(Callback, Funcs.Value)
              if SaveKey ~= "" then SaveSystem.Set(SaveKey, name) end
              UpdateButtonText()
              CloseDropdownPanel()
            end
          end)

          return OptionBtn
        end

        local function RefreshOptions(filter)
          -- Clear existing options (except search box)
          for _, btn in ipairs(OptionButtons) do
            if btn and btn.Parent then btn:Destroy() end
          end
          OptionButtons = {}

          local order = 1
          for _, name in ipairs(Options) do
            if not filter or filter == "" or string.find(string.lower(tostring(name)), string.lower(filter), 1, true) then
              local btn = CreateOptionButton(name, order)
              table.insert(OptionButtons, btn)
              order += 1
            end
          end
        end

        RefreshOptions("")

        if SearchBox then
          SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            RefreshOptions(SearchBox.Text)
          end)
        end

        DropBtn.Activated:Connect(function()
          CircleClick(DropBtn)
          PlaySound("Click")
          RefreshOptions(SearchBox and SearchBox.Text or "")
          OpenDropdownPanel(DropPanel)
        end)

        function Funcs:Set(value)
          Funcs.Value = value
          UpdateButtonText()
          SafeCall(Callback, value)
        end

        function Funcs:Refresh(newOptions, selected)
          Options = newOptions or Options
          if selected ~= nil then
            Funcs.Value = selected
          end
          RefreshOptions("")
          UpdateButtonText()
        end

        function Funcs:AddOption(name)
          table.insert(Options, name)
          RefreshOptions("")
        end

        function Funcs:Clear()
          Options = {}
          Funcs.Value = Multi and {} or ""
          RefreshOptions("")
          UpdateButtonText()
        end

        UpdateButtonText()
        return Funcs
      end

      function Item:AddPanel(PConfig)
        local PTitle    = Get(PConfig, 1, "Title", "")
        local PContent  = Get(PConfig, 2, "Content", "")
        local Tooltip   = Get(PConfig, 3, "Tooltip", "")

        local Panel = Custom:Create("Frame", {
          Name = "Panel",
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = NextOrder(),
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Panel)
        RegisterThemed(Panel, "BackgroundColor3", "Panel")

        local PanelTitle = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = tostring(PTitle), TextSize = 13,
          TextColor3 = CONFIG.Theme.Text,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Center,
          TextTruncate = Enum.TextTruncate.AtEnd,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 5),
          Size = UDim2.new(1, -20, 0, 15),
          ZIndex = Z.Content,
        }, Panel)
        RegisterThemed(PanelTitle, "TextColor3", "Text")

        local PanelContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Regular, Text = tostring(PContent), TextSize = 12,
          TextColor3 = CONFIG.Theme.Text, TextTransparency = 0.6,
          TextWrapped = true,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          AutomaticSize = Enum.AutomaticSize.Y,
          Position = UDim2.new(0, 10, 0, 20),
          Size = UDim2.new(1, -20, 0, 0),
          ZIndex = Z.Content,
        }, Panel)
        RegisterThemed(PanelContent, "TextColor3", "Text")

        -- Panel content holder for sub-items
        local PanelHolder = Custom:Create("Frame", {
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 20),
          Size = UDim2.new(1, -20, 0, 0),
          ZIndex = Z.Base,
        }, Panel)
        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 3),
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, PanelHolder)

        local PanelObj = {}
        local PanelCount = 0

        -- Sub-items dalam panel
        function PanelObj:AddButton(BConfig)
          PanelCount += 1
          local BTitle = Get(BConfig, 1, "Title", "")
          local Callback = Get(BConfig, 2, "Callback", function() end)
          
          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = tostring(BTitle),
            TextColor3 = CONFIG.Theme.Text,
            TextSize = 12,
            BackgroundColor3 = CONFIG.Theme.Secondary,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            ZIndex = Z.Content,
            LayoutOrder = PanelCount,
          }, PanelHolder)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Btn)

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            PlaySound("Click")
            SafeCall(Callback)
          end)

          return { Destroy = function() Btn:Destroy() end }
        end

        function PanelObj:AddToggle(TConfig)
          PanelCount += 1
          local TTitle = Get(TConfig, 1, "Title", "")
          local Default = Get(TConfig, 2, "Default", false)
          local Callback = Get(TConfig, 3, "Callback", function() end)

          local isOn = Default == true
          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = tostring(TTitle) .. (isOn and " [ON]" or " [OFF]"),
            TextColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text,
            TextSize = 12,
            BackgroundColor3 = CONFIG.Theme.Secondary,
            BackgroundTransparency = 0.9,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 28),
            ZIndex = Z.Content,
            LayoutOrder = PanelCount,
          }, PanelHolder)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Btn)

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            isOn = not isOn
            Btn.Text = tostring(TTitle) .. (isOn and " [ON]" or " [OFF]")
            Btn.TextColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text
            PlaySound(isOn and "ToggleOn" or "ToggleOff")
            SafeCall(Callback, isOn)
          end)

          return {
            Set = function(v)
              isOn = v == true
              Btn.Text = tostring(TTitle) .. (isOn and " [ON]" or " [OFF]")
              Btn.TextColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text
            end,
            Destroy = function() Btn:Destroy() end,
          }
        end

        -- Auto-resize panel
        local function RefitPanel()
          local contentH = 20 + PanelHolder.AbsoluteContentSize.Y + 10
          local textH = 20
          if PContent and PContent ~= "" then
            textH = textH + 15
          end
          PanelHolder.Position = UDim2.new(0, 10, 0, textH)
          Panel.Size = UDim2.new(1, 0, 0, textH + contentH)
        end
        
        -- Listen for changes
        PanelHolder:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefitPanel)
        task.delay(0.1, RefitPanel)

        if Tooltip and Tooltip ~= "" then
          AttachTooltip(Panel, Tooltip)
        end

        PanelObj.SetTitle = function(text) PanelTitle.Text = tostring(text) end
        PanelObj.SetContent = function(text) PanelContent.Text = tostring(text) end
        PanelObj.SetVisible = function(state) Panel.Visible = state and true or false end
        PanelObj.Destroy = function() Panel:Destroy() end

        return PanelObj
      end

      return Item
    end

    return Sections
  end

  -- Return window object
  local WindowObj = {
    CreateTab = Tabs.CreateTab,
    Show = ShowWindow,
    Hide = HideWindow,
    Toggle = function()
      if DropShadowHolder.Visible then HideWindow() else ShowWindow() end
    end,
    Destroy = DestroyWindow,
  }

  table.insert(LibWindows, WindowObj)
  return WindowObj
end

-- ─────────────────── Additional Library Functions ───────────────────
function Speed_Library:Destroy()
  if Env.KingAkbarUI_Cleanup then
    pcall(Env.KingAkbarUI_Cleanup)
  end
  Speed_Library.Unloaded = true
end

function Speed_Library:SetTheme(t)
  Custom:SetTheme(t)
end

function Speed_Library:SetFont(f)
  Custom:SetFont(f)
end

function Speed_Library:GetConfig()
  return CONFIG
end

-- v2.0: Enable/Disable Sound
function Speed_Library:SetSound(enabled)
  CONFIG.Behavior.SoundEnabled = enabled == true
end

-- v2.0: Enable/Disable Config Save
function Speed_Library:EnableSave(fileName)
  CONFIG.Behavior.SaveEnabled = true
  if fileName then CONFIG.Behavior.SaveFile = fileName end
  SaveSystem.Load()
end

function Speed_Library:DisableSave()
  CONFIG.Behavior.SaveEnabled = false
end

-- v2.0: Set UI Toggle Key globally
function Speed_Library:SetToggleKey(keyCode)
  CONFIG.Window.ToggleKey = keyCode
end

-- Load saved config on init if enabled
SaveSystem.Load()

return Speed_Library
