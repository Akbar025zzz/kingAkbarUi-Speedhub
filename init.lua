--[[
  ╔══════════════════════════════════════════════════╗
  ║          KING AKBAR UI LIBRARY  v2.2             ║
  ║    github.com/Akbar025zzz/kingAkbarUi-Speedhub   ║
  ╚══════════════════════════════════════════════════╝

  v2.2 — AUTO-FIT SIZING (UI tidak pernah kebesaran):
  • Window default 520x340, otomatis mengecil di layar kecil
  • SizeUi apapun (bahkan 2000x1500) auto-scale ke max 92% layar
  • SizeUi support Scale: UDim2.fromScale(0.5, 0.6) → dihitung dari viewport
  • Min size 380x280 (dibatasi ukuran layar — tidak memaksa di HP)
  • Rotate/resize layar → window mengecil otomatis + posisi di-clamp
  • Dialog & ColorPicker auto-fit via UIScale
  • Notifikasi & floating button clamp ke viewport
  • TabWidth otomatis dibatasi max 38% lebar window

  v2.1 — Modern design (topbar tombol bulat, tab accent bar,
  item 40px, toggle iOS, slider premium, scrollbar halus).
  v2.0 — Keybind • ColorPicker • Dialog • Tooltip • Theme Runtime •
  SaveKey • Notif Queue • Sound • ToggleKey • Viewport Clamp.

  CONTOH:
    local Lib = loadstring(game:HttpGet("URL_RAW_INIT_LUA"))()
    local Win = Lib:CreateWindow({ Title = "My Hub" })  -- otomatis pas ukurannya
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")
local SoundService     = game:GetService("SoundService")
local CoreGui          = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
  Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
  Player = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════
--  CLEANUP
-- ═══════════════════════════════════════════════════
local Env = (getgenv and getgenv()) or _G
if type(Env.KingAkbarUI_Cleanup) == "function" then
  pcall(Env.KingAkbarUI_Cleanup)
end

local LibConnections, LibGuis = {}, {}
local ThemedElements = {}

local function BindLib(Signal, Fn)
  local c = Signal:Connect(Fn)
  table.insert(LibConnections, c)
  return c
end

Env.KingAkbarUI_Cleanup = function()
  for _, c in ipairs(LibConnections) do pcall(function() c:Disconnect() end) end
  for _, g in ipairs(LibGuis) do pcall(function() g:Destroy() end) end
  table.clear(LibConnections)
  table.clear(LibGuis)
  table.clear(ThemedElements)
end

pcall(function()
  local roots = {}
  if Player:FindFirstChild("PlayerGui") then table.insert(roots, Player.PlayerGui) end
  pcall(function() table.insert(roots, CoreGui) end)
  pcall(function() if gethui then table.insert(roots, gethui()) end end)
  for _, root in ipairs(roots) do
    for _, child in ipairs(root:GetChildren()) do
      if child:IsA("ScreenGui") and child.Name:sub(1, 11) == "KingAkbarUI" then
        child:Destroy()
      end
    end
  end
end)

-- ═══════════════════════════════════════════════════
--  CONFIG
-- ═══════════════════════════════════════════════════
local CONFIG = {
  Theme = {
    Primary    = Color3.fromRGB(0, 170, 255),
    Background = Color3.fromRGB(12, 12, 16),
    Secondary  = Color3.fromRGB(24, 24, 30),
    Panel      = Color3.fromRGB(255, 255, 255),
    Text       = Color3.fromRGB(255, 255, 255),
    SubText    = Color3.fromRGB(155, 155, 165),
    Stroke     = Color3.fromRGB(60, 60, 72),
    Divider    = Color3.fromRGB(75, 75, 88),
    LineColor  = Color3.fromRGB(100, 100, 115),
  },
  Font = { Bold = Enum.Font.GothamBold, Regular = Enum.Font.Gotham },
  Layout = {
    -- ── SIZING (v2.2 auto-fit) ──
    MaxScreenRatio = 0.92,  -- window max 92% dari viewport
    MinWindowW     = 380,   -- min lebar window (auto-dibatasi ukuran layar)
    MinWindowH     = 280,   -- min tinggi window (auto-dibatasi ukuran layar)
    ScreenMargin   = 8,     -- margin popup (dialog/colorpicker) dari tepi layar
    -- ── KOMPONEN ──
    TopbarHeight  = 44,
    SidebarOffset = 10,
    ContentGap    = 24,
    TabHeight     = 32,
    TabRadius     = 6,
    ItemHeight    = 40,
    ItemSpacing   = 4,
    ItemRadius    = 5,
    ItemPadX      = 12,
    ToggleW       = 40, ToggleH   = 20, ToggleKnob = 16,
    SliderTrackH  = 6,  SliderKnob = 14, ValueBoxW = 54, ValueBoxH = 22,
    DropW         = 120, DropH    = 24,
    KeyW          = 64,  KeyH     = 22,
    SwatchW       = 48,  SwatchH  = 22,
    InputW        = 150, InputH   = 24,
    ScrollThick   = 3,
  },
  Window = {
    Size                   = UDim2.fromOffset(520, 340), -- desktop default
    SmallSize              = UDim2.fromOffset(460, 310), -- layar sedang (<900px)
    TabWidth               = 112,
    CornerRadius           = 8,
    BackgroundImage        = "rbxassetid://110409843085547",
    BackgroundTransparency = 0.55,
    BackgroundTint         = Color3.fromRGB(10, 10, 14),
    BackgroundTintTrans    = 0.35,
    ToggleKey              = Enum.KeyCode.RightShift,
  },
  Notification = { Width = 330, Duration = 5, AnimateTime = 0.45, MaxVisible = 5 },
  Assets = {
    ArrowIcon      = "rbxassetid://125609963478878",
    DefaultIcon    = "rbxassetid://7734010488",
    FloatingButton = "rbxassetid://91115084979317",
  },
  Behavior = {
    AntiAFK      = true,
    SoundEnabled = false,
    SaveEnabled  = false,
    SaveFile     = "KingAkbarUI_Config.json",
    SaveDebounce = 0.5,
  },
  Sounds = {
    Click        = "rbxassetid://6042053626",
    ToggleOn     = "rbxassetid://6042053626",
    ToggleOff    = "rbxassetid://6042053626",
    Notification = "rbxassetid://180877191",
  },
}

local Z = {
  Background = 0, Base = 1, Content = 2, Control = 3, Overlay = 4,
  Dropdown = 5, Popup = 60, Tooltip = 90, Dialog = 100, Notification = 110,
}
local L = CONFIG.Layout

-- ═══════════════════════════════════════════════════
--  HELPER
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
  if not ok then warn("[KingAkbarUI] Callback error: " .. tostring(err)) end
end

local function Tween(Inst, Props, Time, Style, Dir)
  if not Time or Time <= 0 then
    for k, v in pairs(Props) do Inst[k] = v end
    return nil
  end
  local tw = TweenService:Create(Inst,
    TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Dir or Enum.EasingDirection.Out), Props)
  tw:Play()
  return tw
end

local function TextWidth(Text, Size, Font)
  local ok, b = pcall(TextService.GetTextSize, TextService,
    tostring(Text or ""), Size, Font, Vector2.new(1000, 100))
  if ok and b then return b.X end
  return #tostring(Text or "") * Size * 0.55
end

local function ContrastColor(C)
  local lum = 0.299 * C.R + 0.587 * C.G + 0.114 * C.B
  return lum > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end

local function PlaySound(Name)
  if not CONFIG.Behavior.SoundEnabled then return end
  local id = CONFIG.Sounds[Name]
  if not id or id == "" then return end
  pcall(function()
    local s = Instance.new("Sound")
    s.SoundId, s.Volume, s.Parent = id, 0.35, SoundService
    s:Play()
    s.Ended:Once(function() s:Destroy() end)
    task.delay(5, function() if s.Parent then s:Destroy() end end)
  end)
end

local function HoverT(Inst, NormalT, HoverT)
  Inst.MouseEnter:Connect(function() Tween(Inst, { BackgroundTransparency = HoverT }, 0.12) end)
  Inst.MouseLeave:Connect(function() Tween(Inst, { BackgroundTransparency = NormalT }, 0.12) end)
end

local function Themed(Inst, Prop, Key)
  table.insert(ThemedElements, { Inst = Inst, Prop = Prop, Key = Key })
end

local function ApplyTheme()
  local alive = {}
  for _, e in ipairs(ThemedElements) do
    if e.Inst and e.Inst.Parent then
      pcall(function()
        if type(e.Prop) == "function" then
          e.Prop(e.Key and CONFIG.Theme[e.Key] or nil, CONFIG.Theme)
        else
          e.Inst[e.Prop] = CONFIG.Theme[e.Key]
        end
      end)
      table.insert(alive, e)
    end
  end
  ThemedElements = alive
end

-- ═══════════════════════════════════════════════════
--  VIEWPORT & AUTO-FIT (inti v2.2)
-- ═══════════════════════════════════════════════════
local function GetViewport()
  local cam = workspace.CurrentCamera
  if cam and cam.ViewportSize.X > 0 then return cam.ViewportSize end
  return Vector2.new(1280, 720)
end

-- Fit w×h ke viewport: jaga rasio, patuhi min & max
local function FitWindowWH(w, h)
  local vp = GetViewport()
  local maxW = math.max(200, math.floor(vp.X * L.MaxScreenRatio))
  local maxH = math.max(150, math.floor(vp.Y * L.MaxScreenRatio))
  -- min dibatasi max (supaya tidak memaksa besar di layar kecil)
  w = math.max(w, math.min(L.MinWindowW, maxW))
  h = math.max(h, math.min(L.MinWindowH, maxH))
  if w > maxW or h > maxH then
    local s = math.min(maxW / w, maxH / h)
    w, h = math.floor(w * s), math.floor(h * s)
  end
  return w, h, maxW, maxH
end

-- Auto-fit popup (dialog/colorpicker) via UIScale — semua isi ikut mengecil proporsional
local function FitPopup(Frame, W, H)
  local vp = GetViewport()
  local m = L.ScreenMargin
  local s = math.min(1, (vp.X - m * 2) / W, (vp.Y - m * 2) / H)
  if s < 1 then
    Custom = Custom -- (forward declare tidak perlu; fungsi dipanggil setelah Custom ada)
    local sc = Instance.new("UIScale")
    sc.Scale = s
    sc.Parent = Frame
  end
end

-- ── Watcher viewport (rotate device / resize window game) ──
local ViewportWatchers = {}
local function OnViewportChange(Fn)
  table.insert(ViewportWatchers, Fn)
end

local CameraConn = nil
local function WatchViewport()
  if CameraConn then pcall(function() CameraConn:Disconnect() end) CameraConn = nil end
  local cam = workspace.CurrentCamera
  if cam then
    CameraConn = BindLib(cam:GetPropertyChangedSignal("ViewportSize"), function()
      for _, fn in ipairs(ViewportWatchers) do pcall(fn) end
    end)
  end
end
BindLib(workspace:GetPropertyChangedSignal("CurrentCamera"), WatchViewport)
WatchViewport()

-- ═══════════════════════════════════════════════════
--  SAVE SYSTEM
-- ═══════════════════════════════════════════════════
local Save = {}
do
  local Table, StoreFn, PendingToken = {}, nil, nil

  local function Flush()
    PendingToken = nil
    if not CONFIG.Behavior.SaveEnabled then return end
    if StoreFn then
      pcall(StoreFn, Table)
    elseif writefile then
      pcall(function()
        writefile(CONFIG.Behavior.SaveFile, HttpService:JSONEncode(Table))
      end)
    end
  end

  function Save.SetTable(Tbl, StoreFn_)
    Table = (type(Tbl) == "table") and Tbl or {}
    StoreFn = StoreFn_
    return Table
  end

  function Save.Get(Key, Default)
    if Key == nil then return Table end
    local v = Table[Key]
    if v == nil then return Default end
    return v
  end

  function Save.Set(Key, Value)
    if Key == nil or Key == "" then return end
    local t = typeof(Value)
    if t == "Color3" then
      Value = { math.floor(Value.R * 255 + 0.5), math.floor(Value.G * 255 + 0.5), math.floor(Value.B * 255 + 0.5) }
    elseif t == "EnumItem" then
      Value = Value.Name
    end
    Table[Key] = Value
    if PendingToken then PendingToken.Alive = false end
    local token = { Alive = true }
    PendingToken = token
    task.delay(CONFIG.Behavior.SaveDebounce, function()
      if token.Alive then Flush() end
    end)
  end

  function Save.Load()
    if not (isfile and readfile) then return end
    pcall(function()
      if isfile(CONFIG.Behavior.SaveFile) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG.Behavior.SaveFile))
        if type(decoded) == "table" then
          for k, v in pairs(decoded) do Table[k] = v end
        end
      end
    end)
  end

  function Save.Save() Flush() end

  function Save.Clear()
    Table = {}
    pcall(function()
      if isfile and isfile(CONFIG.Behavior.SaveFile) then delfile(CONFIG.Behavior.SaveFile) end
    end)
  end
end

-- ═══════════════════════════════════════════════════
--  CORE
-- ═══════════════════════════════════════════════════
local Custom = {}
Custom.Config = CONFIG

function Custom:Create(Class, Props, Parent)
  local inst = Instance.new(Class)
  for k, v in pairs(Props) do inst[k] = v end
  if Parent then inst.Parent = Parent end
  return inst
end

BindLib(Player.Idled, function()
  if not CONFIG.Behavior.AntiAFK then return end
  pcall(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
  end)
end)

function Custom:SetTheme(t)
  for k, v in pairs(t) do
    if CONFIG.Theme[k] ~= nil then CONFIG.Theme[k] = v end
  end
  ApplyTheme()
end

function Custom:SetFont(f)
  for k, v in pairs(f) do
    if CONFIG.Font[k] ~= nil then CONFIG.Font[k] = v end
  end
end

-- ═══════════════════════════════════════════════════
--  SCREENGUI FACTORY
-- ═══════════════════════════════════════════════════
local function NewScreenGui(Name, Order)
  local gui = Instance.new("ScreenGui")
  gui.Name, gui.ZIndexBehavior = Name, Enum.ZIndexBehavior.Sibling
  gui.ResetOnSpawn, gui.IgnoreGuiInset = false, true
  gui.DisplayOrder = Order or 10

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
--  TOOLTIP
-- ═══════════════════════════════════════════════════
local TooltipGui, CurrentTooltip

local function HideTooltip()
  if CurrentTooltip then CurrentTooltip:Destroy() CurrentTooltip = nil end
end

local function ShowTooltip(Text, Pos)
  HideTooltip()
  if not Text or Text == "" then return end
  if not (TooltipGui and TooltipGui.Parent) then
    TooltipGui = NewScreenGui("KingAkbarUI_Tooltip", Z.Tooltip)
  end
  local vp = GetViewport()
  local ok, size = pcall(TextService.GetTextSize, TextService, Text, 12,
    CONFIG.Font.Regular, Vector2.new(240, math.huge))
  if not ok then size = Vector2.new(120, 16) end
  local w, h = math.floor(size.X) + 16, math.floor(size.Y) + 10
  w = math.min(w, vp.X - 16)
  local x = math.clamp(Pos.X + 14, 8, math.max(8, vp.X - w - 8))
  local y = Pos.Y - h - 10
  if y < 8 then y = Pos.Y + 20 end

  local Tip = Custom:Create("Frame", {
    BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.05,
    BorderSizePixel = 0, Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h), ZIndex = Z.Tooltip,
  }, TooltipGui)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Tip)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, Tip)
  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = Text, TextColor3 = CONFIG.Theme.Text,
    TextSize = 12, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(1, -12, 1, 0),
    ZIndex = Z.Tooltip + 1,
  }, Tip)
  CurrentTooltip = Tip
end

local function AttachTooltip(Inst, TextOrFn)
  Inst.MouseEnter:Connect(function()
    local t = type(TextOrFn) == "function" and TextOrFn() or TextOrFn
    if t and t ~= "" then ShowTooltip(t, UserInputService:GetMouseLocation()) end
  end)
  Inst.MouseLeave:Connect(HideTooltip)
end

local function AttachTooltipOpt(Inst, Text)
  if type(Text) == "string" and Text ~= "" then AttachTooltip(Inst, Text) end
end

-- ═══════════════════════════════════════════════════
--  DRAGGABLE
-- ═══════════════════════════════════════════════════
local function MakeDraggable(Handle, Object, Bind)
  local Dragging, DragInput, DragStart, StartPos, Moved = false, nil, nil, nil, false

  Handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      Dragging, Moved = true, false
      DragInput, DragStart = input, input.Position
      StartPos = Object.Position
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
--  FLOATING BUTTON (auto-clamp ke viewport)
-- ═══════════════════════════════════════════════════
local function CreateFloatingButton()
  local Gui = NewScreenGui("KingAkbarUI_Floating", 20)
  local Btn = Custom:Create("ImageButton", {
    Name = "OpenCloseButton",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.35, BorderSizePixel = 0,
    AutoButtonColor = false,
    Position = UDim2.new(0.85, 0, 0.05, 0),
    Size = UDim2.fromOffset(46, 46),
    Image = CONFIG.Assets.FloatingButton,
    Visible = false,
  }, Gui)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, Btn)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.4 }, Btn)
  local DidMove = MakeDraggable(Btn, Btn, BindLib)

  -- clamp saat layar berubah (rotate/resize)
  OnViewportChange(function()
    if not (Btn and Btn.Parent and Btn.Visible) then return end
    local vp = GetViewport()
    local sz, abs = Btn.AbsoluteSize, Btn.AbsolutePosition
    if abs.X < 0 or abs.Y < 0 or abs.X + sz.X > vp.X or abs.Y + sz.Y > vp.Y then
      local x = math.clamp(abs.X, 4, math.max(4, vp.X - sz.X - 4))
      local y = math.clamp(abs.Y, 4, math.max(4, vp.Y - sz.Y - 4))
      Btn.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
    end
  end)

  return Btn, DidMove
end

local Open_Close, Open_Close_Moved = CreateFloatingButton()

-- ═══════════════════════════════════════════════════
--  RIPPLE
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
      BackgroundTransparency = 0.8, BorderSizePixel = 0,
      Position = UDim2.fromOffset(rel.X, rel.Y),
      Size = UDim2.fromOffset(0, 0), ZIndex = Z.Control + 5,
    }, Button)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Circle)
    Tween(Circle, {
      Size = UDim2.fromOffset(math.max(W, H) * 2.2, math.max(W, H) * 2.2),
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
    Name = "Item", BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.94, BorderSizePixel = 0,
    LayoutOrder = Order, Size = UDim2.new(1, 0, 0, L.ItemHeight), ZIndex = Z.Base,
  }, Parent)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, L.ItemRadius) }, Frame)
  Themed(Frame, "BackgroundColor3", "Panel")
  HoverT(Frame, 0.94, 0.90)

  local TitleLabel = Custom:Create("TextLabel", {
    Name = "ItemTitle", Font = CONFIG.Font.Bold,
    Text = tostring(Title), TextSize = 14,
    TextColor3 = CONFIG.Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, L.ItemPadX, 0, 11),
    Size = UDim2.new(1, -Reserve, 0, 15), ZIndex = Z.Content,
  }, Frame)
  Themed(TitleLabel, "TextColor3", "Text")

  local ContentLabel = Custom:Create("TextLabel", {
    Name = "ItemContent", Font = CONFIG.Font.Regular,
    Text = tostring(Content), TextSize = 12,
    TextColor3 = CONFIG.Theme.SubText,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0, L.ItemPadX, 0, 28),
    Size = UDim2.new(1, -Reserve, 0, 0), ZIndex = Z.Content,
  }, Frame)
  Themed(ContentLabel, "TextColor3", "SubText")

  Base.Frame, Base.Title, Base.Content = Frame, TitleLabel, ContentLabel
  Base.Height, Base.Apply = L.ItemHeight, nil

  function Base.Refit()
    local hasContent = ContentLabel.Text ~= ""
    ContentLabel.Visible = hasContent
    local h
    if hasContent then
      TitleLabel.Position = UDim2.new(0, L.ItemPadX, 0, 10)
      h = 30 + math.max(ContentLabel.AbsoluteSize.Y, 14) + 8
    else
      TitleLabel.Position = UDim2.new(0, L.ItemPadX, 0.5, 0)
      h = L.ItemHeight
    end
    Base.Height = h
    if Base.Apply then Base.Apply(h) else Frame.Size = UDim2.new(1, 0, 0, h) end
  end

  ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(Base.Refit)
  ContentLabel:GetPropertyChangedSignal("Text"):Connect(Base.Refit)
  Base.Refit()
  return Base
end

local function AttachCommon(Funcs, Base, Clear)
  function Funcs:SetTitle(Text) Base.Title.Text = tostring(Text) end
  function Funcs:SetContent(Text) Base.Content.Text = tostring(Text) end
  function Funcs:SetVisible(State) Base.Frame.Visible = State and true or false end
  function Funcs:Destroy()
    if Clear then Clear() end
    Base.Frame:Destroy()
  end
end

local function NewBinder(Registry)
  local conns = {}
  local function Bind(Signal, Fn)
    local c = Signal:Connect(Fn)
    table.insert(conns, c)
    if Registry then table.insert(Registry, c) end
    return c
  end
  local function Clear()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    table.clear(conns)
  end
  return Bind, Clear
end

-- ═══════════════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════════════
local Speed_Library = { Version = "2.2", Unloaded = false, Save = Save }
Speed_Library._bgImages = {}

function Speed_Library:SetBackgroundImage(ImageId, Transparency)
  CONFIG.Window.BackgroundImage = tostring(ImageId or "")
  if Transparency ~= nil then CONFIG.Window.BackgroundTransparency = Transparency end
  for _, bg in ipairs(Speed_Library._bgImages) do
    if bg.Image and bg.Image.Parent then
      bg.Image.Image = CONFIG.Window.BackgroundImage
      bg.Image.ImageTransparency = CONFIG.Window.BackgroundTransparency
      bg.Image.Visible = CONFIG.Window.BackgroundImage ~= ""
    end
    if bg.Tint and bg.Tint.Parent then
      bg.Tint.Visible = CONFIG.Window.BackgroundImage ~= ""
    end
  end
end

-- ─────────────── Notification (auto-fit lebar) ───────────────
local NotifGui, NotifHolder
local NotifCounter = 0
local ActiveNotifs, NotifQueue = {}, {}

local function NotifWidth()
  local vp = GetViewport()
  return math.min(CONFIG.Notification.Width, math.max(200, vp.X - 32))
end

local function EnsureNotifHolder()
  if NotifGui and NotifGui.Parent and NotifHolder and NotifHolder.Parent then
    return NotifHolder
  end
  NotifGui = NewScreenGui("KingAkbarUI_Notification", Z.Notification)
  NotifHolder = Custom:Create("Frame", {
    Name = "Holder", AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, NotifWidth(), 1, -32),
  }, NotifGui)
  Custom:Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding = UDim.new(0, 8),
  }, NotifHolder)
  return NotifHolder
end

-- lebar notifikasi ikut mengecil saat layar berubah
OnViewportChange(function()
  if NotifHolder and NotifHolder.Parent then
    NotifHolder.Size = UDim2.new(0, NotifWidth(), 1, -32)
  end
end)

local function ProcessNotifQueue()
  if #NotifQueue == 0 then return end
  if #ActiveNotifs >= CONFIG.Notification.MaxVisible then return end
  local fn = table.remove(NotifQueue, 1)
  if fn then fn() end
end

function Speed_Library:SetNotification(Config)
  local Title = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local Content = tostring(Get(Config, 3, "Content", ""))
  local Time = tonumber(Get(Config, 5, "Time", CONFIG.Notification.AnimateTime)) or 0.45
  local Delay = tonumber(Get(Config, 6, "Delay", CONFIG.Notification.Duration)) or 5
  local ShowProgress = Get(Config, 7, "Progress", true) == true
  NotifCounter += 1

  local function Spawn()
    local Holder = EnsureNotifHolder()
    local Container = Custom:Create("Frame", {
      Name = "Notification", BackgroundTransparency = 1, BorderSizePixel = 0,
      LayoutOrder = NotifCounter, Size = UDim2.new(1, 0, 0, 44),
    }, Holder)

    local Card = Custom:Create("Frame", {
      BackgroundColor3 = CONFIG.Theme.Background, BackgroundTransparency = 0.03,
      BorderSizePixel = 0, Position = UDim2.new(1, 40, 0, 0),
      Size = UDim2.new(1, 0, 1, 0),
    }, Container)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 9) }, Card)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2, Transparency = 0.2 }, Card)
    Themed(Card, "BackgroundColor3", "Background")

    local TitleWidth = math.min(TextWidth(Title, 13, CONFIG.Font.Bold), 140)

    local TitleLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
      BorderSizePixel = 0, Position = UDim2.new(0, 12, 0, 0),
      Size = UDim2.new(0, TitleWidth + 4, 0, 40),
    }, Card)
    Themed(TitleLabel, "TextColor3", "Text")

    local DescLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
      BorderSizePixel = 0, Position = UDim2.new(0, TitleWidth + 16, 0, 0),
      Size = UDim2.new(1, -(TitleWidth + 16 + 34), 0, 40),
    }, Card)
    Themed(DescLabel, "TextColor3", "Primary")

    local CloseBtn = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = "×", TextColor3 = CONFIG.Theme.SubText,
      TextSize = 16, AnchorPoint = Vector2.new(1, 0),
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(24, 24),
    }, Card)

    local ContentLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Regular, Text = Content, TextColor3 = CONFIG.Theme.SubText,
      TextSize = 12, TextWrapped = true,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      AutomaticSize = Enum.AutomaticSize.Y,
      Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 0),
      Visible = Content ~= "",
    }, Card)
    Themed(ContentLabel, "TextColor3", "SubText")

    local function Refit()
      if Content == "" then
        Container.Size = UDim2.new(1, 0, 0, 44)
      else
        Container.Size = UDim2.new(1, 0, 0, 34 + math.max(ContentLabel.AbsoluteSize.Y, 13) + 12)
      end
    end
    ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(Refit)
    Refit()

    local ProgressTween
    if ShowProgress then
      local Bar = Custom:Create("Frame", {
        Name = "ProgressBar", BackgroundColor3 = CONFIG.Theme.Primary,
        BackgroundTransparency = 0.25, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2.5), ZIndex = Z.Content + 1,
      }, Card)
      Custom:Create("UICorner", {}, Bar)
      Themed(Bar, "BackgroundColor3", "Primary")
      ProgressTween = Tween(Bar, { Size = UDim2.new(0, 0, 0, 2.5) }, Delay, Enum.EasingStyle.Linear)
    end

    local Closed = false
    local N = {}
    function N:Close()
      if Closed then return end
      Closed = true
      if ProgressTween then pcall(function() ProgressTween:Cancel() end) end
      for i, n in ipairs(ActiveNotifs) do
        if n == N then table.remove(ActiveNotifs, i) break end
      end
      Tween(Card, { Position = UDim2.new(1, 40, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.In)
      task.delay(Time + 0.05, function()
        if Container then Container:Destroy() end
      end)
      ProcessNotifQueue()
    end

    CloseBtn.Activated:Connect(function() N:Close() end)
    Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.delay(Delay, function() N:Close() end)

    table.insert(ActiveNotifs, N)
    PlaySound("Notification")
    return N
  end

  if #ActiveNotifs >= CONFIG.Notification.MaxVisible then
    table.insert(NotifQueue, Spawn)
    local ph = {}
    function ph:Close()
      for i, f in ipairs(NotifQueue) do
        if f == Spawn then table.remove(NotifQueue, i) break end
      end
    end
    return ph
  end
  return Spawn()
end

function Speed_Library:Notify(Config) return Speed_Library:SetNotification(Config) end

-- ─────────────── Dialog (auto-fit via UIScale) ───────────────
function Speed_Library:Dialog(Config)
  local Title = tostring(Get(Config, 1, "Title", "Confirm"))
  local Content = tostring(Get(Config, 2, "Content", "Are you sure?"))
  local Buttons = Get(Config, 3, "Buttons", { { "OK", function() end } })
  if type(Buttons) ~= "table" then Buttons = { { "OK", function() end } } end

  local Gui = NewScreenGui("KingAkbarUI_Dialog", Z.Dialog)
  local Overlay = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5,
    BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Dialog,
  }, Gui)

  local DW = 340
  local ok, cs = pcall(TextService.GetTextSize, TextService, Content, 13,
    CONFIG.Font.Regular, Vector2.new(DW - 60, math.huge))
  if not ok then cs = Vector2.new(280, 40) end
  local H = math.max(160, math.floor(cs.Y) + 104)

  local Frame = Custom:Create("Frame", {
    BackgroundColor3 = CONFIG.Theme.Background, BackgroundTransparency = 0.02,
    BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(DW - 10, H - 14),
    ZIndex = Z.Dialog + 1,
  }, Overlay)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, Frame)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4, Transparency = 0.2 }, Frame)
  Themed(Frame, "BackgroundColor3", "Background")

  -- v2.2: auto-fit di layar kecil
  do
    local vp = GetViewport()
    local m = L.ScreenMargin
    local s = math.min(1, (vp.X - m * 2) / DW, (vp.Y - m * 2) / H)
    if s < 1 then
      local sc = Instance.new("UIScale")
      sc.Scale = s
      sc.Parent = Frame
    end
  end

  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 16, 0, 14), Size = UDim2.new(1, -32, 0, 20),
    ZIndex = Z.Dialog + 2,
  }, Frame)

  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = Content, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 13, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 16, 0, 42), Size = UDim2.new(1, -32, 1, -92),
    ZIndex = Z.Dialog + 2,
  }, Frame)

  local BtnHolder = Custom:Create("Frame", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 32), ZIndex = Z.Dialog + 2,
  }, Frame)
  Custom:Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
  }, BtnHolder)

  local function Close()
    Tween(Overlay, { BackgroundTransparency = 1 }, 0.12)
    Tween(Frame, { Size = UDim2.fromOffset(DW - 20, H - 8) }, 0.12)
    task.delay(0.15, function() if Gui then Gui:Destroy() end end)
  end

  for i, btnData in ipairs(Buttons) do
    local Text = type(btnData) == "table" and (btnData[1] or btnData.Text) or tostring(btnData)
    local Cb = type(btnData) == "table" and (btnData[2] or btnData.Callback) or function() end
    local Primary = type(btnData) == "table" and (btnData[3] or btnData.Primary) == true

    local Btn = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = tostring(Text), TextSize = 13,
      BackgroundColor3 = Primary and CONFIG.Theme.Primary or CONFIG.Theme.Secondary,
      TextColor3 = Primary and ContrastColor(CONFIG.Theme.Primary) or CONFIG.Theme.Text,
      BackgroundTransparency = Primary and 0 or 0.25,
      BorderSizePixel = 0, Size = UDim2.fromOffset(90, 30),
      LayoutOrder = i, ZIndex = Z.Dialog + 3,
    }, BtnHolder)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 7) }, Btn)
    if Primary then
      Themed(Btn, function(p) Btn.BackgroundColor3 = p; Btn.TextColor3 = ContrastColor(p) end, "Primary")
    else
      Themed(Btn, "BackgroundColor3", "Secondary")
    end

    Btn.Activated:Connect(function()
      CircleClick(Btn)
      PlaySound("Click")
      SafeCall(Cb)
      Close()
    end)
  end

  Tween(Overlay, { BackgroundTransparency = 0.5 }, 0.15)
  Tween(Frame, { Size = UDim2.fromOffset(DW, H) }, 0.18, Enum.EasingStyle.Back)
  PlaySound("Click")
end

-- ─────────────── CreateWindow (AUTO-FIT SIZING) ───────────────
function Speed_Library:CreateWindow(Config)
  if Speed_Library.Unloaded then
    warn("[KingAkbarUI] Library sudah di-Destroy — re-execute script")
    return nil
  end

  local Title = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local TabWidth = tonumber(Get(Config, 3, "TabWidth", CONFIG.Window.TabWidth)) or CONFIG.Window.TabWidth

  -- ═══ v2.2: HITUNG UKURAN WINDOW (auto-fit) ═══
  local vp = GetViewport()
  local reqW, reqH

  local SizeUi = Get(Config, 4, "SizeUi", nil)
  if typeof(SizeUi) == "UDim2" then
    -- support Offset + Scale (Scale dihitung dari viewport)
    reqW = SizeUi.X.Offset + SizeUi.X.Scale * vp.X
    reqH = SizeUi.Y.Offset + SizeUi.Y.Scale * vp.Y
  else
    -- default pintar berdasarkan ukuran layar
    if vp.X <= 620 then
      -- layar sempit / mobile landscape
      reqW = math.floor(vp.X * 0.94)
      reqH = math.floor(vp.Y * 0.72)
    elseif vp.X <= 900 then
      reqW, reqH = CONFIG.Window.SmallSize.X.Offset, CONFIG.Window.SmallSize.Y.Offset
    else
      reqW = CONFIG.Window.Size.X.Offset
      reqH = CONFIG.Window.Size.Y.Offset
    end
  end

  -- fit: min dibatasi layar, max 92% layar, jaga rasio
  local W, H = FitWindowWH(reqW, reqH)

  -- TabWidth dibatasi max 38% lebar window
  TabWidth = math.clamp(math.floor(TabWidth), 86, math.max(86, math.floor(W * 0.38)))

  local UseSearch = Get(Config, 5, "Search", false) == true
  local UseProfile = Get(Config, 6, "Profile", false) == true
  local Logo = Get(Config, 7, "Logo", "")
  if type(Logo) ~= "string" then Logo = "" end
  local HideName = Get(Config, 8, "HideName", true) ~= false
  local ToggleKey = Get(Config, 9, "ToggleKey", CONFIG.Window.ToggleKey)
  if typeof(ToggleKey) ~= "EnumItem" or ToggleKey.EnumType ~= Enum.KeyCode then
    ToggleKey = CONFIG.Window.ToggleKey
  end

  local WindowConns = {}
  local function BindGlobal(Signal, Fn)
    local c = Signal:Connect(Fn)
    table.insert(WindowConns, c)
    table.insert(LibConnections, c)
    return c
  end

  local WindowGui = NewScreenGui("KingAkbarUI_Window", 10)
  Open_Close.Image = CONFIG.Assets.FloatingButton

  local Holder = Custom:Create("Frame", {
    Name = "Holder", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromOffset(W, H), ZIndex = Z.Background,
  }, WindowGui)

  local Main = Custom:Create("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CONFIG.Theme.Background, BackgroundTransparency = 0.04,
    BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, ZIndex = Z.Base,
  }, Holder)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Main)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4, Transparency = 0.25 }, Main)
  Themed(Main, "BackgroundColor3", "Background")

  -- Background image
  do
    local BgRef = { Image = nil, Tint = nil }
    if CONFIG.Window.BackgroundImage ~= "" then
      local BgImage = Custom:Create("ImageLabel", {
        Name = "BackgroundImage", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0), Image = CONFIG.Window.BackgroundImage,
        ImageTransparency = CONFIG.Window.BackgroundTransparency,
        ScaleType = Enum.ScaleType.Crop, ZIndex = Z.Background,
      }, Main)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, BgImage)
      BgRef.Image = BgImage
      local Tint = Custom:Create("Frame", {
        Name = "BackgroundTint", BackgroundColor3 = CONFIG.Window.BackgroundTint,
        BackgroundTransparency = CONFIG.Window.BackgroundTintTrans,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Background,
      }, Main)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Tint)
      BgRef.Tint = Tint
    end
    table.insert(Speed_Library._bgImages, BgRef)
  end

  -- ═══ TOPBAR ═══
  local Top = Custom:Create("Frame", {
    Name = "Top", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, L.TopbarHeight), ZIndex = Z.Control,
  }, Main)

  local TitleWidth = TextWidth(Title, 15, CONFIG.Font.Bold)
  local TitleX = L.ItemPadX + ((Logo ~= "") and 28 or 0)

  if Logo ~= "" then
    Custom:Create("ImageLabel", {
      Image = Logo, BackgroundTransparency = 1, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, L.ItemPadX, 0.5, 0),
      Size = UDim2.fromOffset(20, 20), ZIndex = Z.Control,
    }, Top)
  end

  local TitleLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, TitleWidth + 8, 1, 0), Position = UDim2.new(0, TitleX, 0, 0),
    ZIndex = Z.Control,
  }, Top)
  Themed(TitleLabel, "TextColor3", "Text")

  local DescLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = Description, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
    BorderSizePixel = 0, Size = UDim2.new(1, -(TitleX + TitleWidth + 12 + 130), 1, 0),
    Position = UDim2.new(0, TitleX + TitleWidth + 12, 0, 0), ZIndex = Z.Control,
  }, Top)
  Themed(DescLabel, "TextColor3", "SubText")

  local function TopButton(XOff, Glyph)
    local B = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = Glyph, TextSize = 16,
      TextColor3 = CONFIG.Theme.SubText,
      BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 1,
      BorderSizePixel = 0, AutoButtonColor = false,
      AnchorPoint = Vector2.new(1, 0.5),
      Position = UDim2.new(1, XOff, 0.5, 0), Size = UDim2.fromOffset(28, 28),
      ZIndex = Z.Control + 1,
    }, Top)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, B)
    B.MouseEnter:Connect(function()
      Tween(B, { BackgroundTransparency = 0.88, TextColor3 = CONFIG.Theme.Text }, 0.12)
    end)
    B.MouseLeave:Connect(function()
      Tween(B, { BackgroundTransparency = 1, TextColor3 = CONFIG.Theme.SubText }, 0.12)
    end)
    return B
  end

  local Close = TopButton(-10, "×")
  local Min = TopButton(-44, "–")

  local KeyHint = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = "[" .. ToggleKey.Name .. "]",
    TextColor3 = CONFIG.Theme.SubText, TextTransparency = 0.35, TextSize = 10,
    AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -82, 0.5, 0), Size = UDim2.fromOffset(56, 12),
    ZIndex = Z.Control + 1,
  }, Top)

  Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.82, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, L.TopbarHeight), Size = UDim2.new(1, 0, 0, 1),
    ZIndex = Z.Control,
  }, Main)

  -- ═══ SIDEBAR ═══
  local SideY = L.TopbarHeight + 10
  local LayersTab = Custom:Create("Frame", {
    Name = "LayersTab", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, L.SidebarOffset, 0, SideY),
    Size = UDim2.new(0, TabWidth, 1, -(SideY + 10)), ZIndex = Z.Control,
  }, Main)

  local ScrollTab = Custom:Create("ScrollingFrame", {
    Name = "ScrollTab", CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 2, ScrollBarImageColor3 = CONFIG.Theme.SubText,
    ScrollBarImageTransparency = 0.5,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Control,
  }, LayersTab)
  Custom:Create("UIListLayout", {
    Padding = UDim.new(0, L.ItemSpacing), SortOrder = Enum.SortOrder.LayoutOrder,
  }, ScrollTab)

  local TopPad = UseSearch and 40 or 0
  local BotPad = UseProfile and 56 or 0
  ScrollTab.Position = UDim2.new(0, 0, 0, TopPad)
  ScrollTab.Size = UDim2.new(1, 0, 1, -(TopPad + BotPad))

  local TabSearchBox
  if UseSearch then
    local SearchFrame = Custom:Create("Frame", {
      Name = "TabSearch", BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = 0.92, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 32), ZIndex = Z.Control,
    }, LayersTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 7) }, SearchFrame)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.4 }, SearchFrame)
    TabSearchBox = Custom:Create("TextBox", {
      Font = CONFIG.Font.Regular, PlaceholderText = "Search...",
      PlaceholderColor3 = CONFIG.Theme.SubText, Text = "",
      TextColor3 = CONFIG.Theme.Text, TextSize = 12, ClearTextOnFocus = false,
      TextXAlignment = Enum.TextXAlignment.Left,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
      ZIndex = Z.Control + 1,
    }, SearchFrame)
  end

  if UseProfile then
    local Profile = Custom:Create("Frame", {
      Name = "Profile", AnchorPoint = Vector2.new(0, 1),
      BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.93,
      BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, 0),
      Size = UDim2.new(1, 0, 0, 48), ZIndex = Z.Control,
    }, LayersTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 7) }, Profile)
    local Avatar = Custom:Create("ImageLabel", {
      BackgroundColor3 = CONFIG.Theme.Secondary, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 6, 0.5, 0),
      Size = UDim2.fromOffset(34, 34), ZIndex = Z.Control + 1,
    }, Profile)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Avatar)
    local AvStroke = Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 1.5 }, Avatar)
    Themed(AvStroke, "Color", "Primary")

    local shown = (Player.DisplayName ~= "" and Player.DisplayName) or Player.Name
    if HideName then shown = shown:sub(1, 3) .. "***" end
    Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = "Welcome,",
      TextColor3 = CONFIG.Theme.SubText, TextSize = 10,
      TextXAlignment = Enum.TextXAlignment.Left,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 46, 0, 7), Size = UDim2.new(1, -50, 0, 12),
      ZIndex = Z.Control + 1,
    }, Profile)
    Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = shown,
      TextColor3 = CONFIG.Theme.Text, TextSize = 12,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
      BorderSizePixel = 0, Position = UDim2.new(0, 46, 0, 20),
      Size = UDim2.new(1, -50, 0, 14), ZIndex = Z.Control + 1,
    }, Profile)

    task.spawn(function()
      local ok, img = pcall(Players.GetUserThumbnailAsync, Players, Player.UserId,
        Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
      if ok and Avatar.Parent then Avatar.Image = img end
    end)
  end

  -- ═══ AREA KONTEN ═══
  local Layers = Custom:Create("Frame", {
    Name = "Layers", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, TabWidth + L.ContentGap, 0, SideY),
    Size = UDim2.new(1, -(TabWidth + L.ContentGap + 10), 1, -(SideY + 10)),
    ZIndex = Z.Control,
  }, Main)

  local NameTab = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
    TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 26), ZIndex = Z.Control,
  }, Layers)
  Themed(NameTab, "TextColor3", "Text")

  local LayersReal = Custom:Create("Frame", {
    Name = "Pages", AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
    Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 1, -32),
    ZIndex = Z.Control,
  }, Layers)

  -- ═══ Show / Hide / Destroy ═══
  local Destroyed = false
  local function ShowWindow()
    Holder.Visible = true
    Open_Close.Visible = false
  end
  local function HideWindow()
    Holder.Visible = false
    Open_Close.Visible = true
  end
  local function DestroyWindow()
    if Destroyed then return end
    Destroyed = true
    for _, c in ipairs(WindowConns) do pcall(function() c:Disconnect() end) end
    Open_Close.Visible = false
    WindowGui:Destroy()
  end

  Min.Activated:Connect(function()
    CircleClick(Min)
    HideWindow()
  end)
  BindGlobal(Open_Close.Activated, function()
    if Open_Close_Moved() then return end
    if not Holder.Visible then ShowWindow() end
  end)
  Close.Activated:Connect(function()
    CircleClick(Close)
    DestroyWindow()
  end)

  BindGlobal(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    if input.KeyCode == ToggleKey then
      if Holder.Visible then HideWindow() else ShowWindow() end
    end
  end)

  MakeDraggable(Top, Holder, BindGlobal)

  -- ═══ v2.2: REFIT saat layar berubah (resize + clamp posisi) ═══
  local CurW, CurH = W, H
  local function RefitWindow()
    if Destroyed then return end
    local vpNow = GetViewport()
    local maxW = math.max(200, math.floor(vpNow.X * L.MaxScreenRatio))
    local maxH = math.max(150, math.floor(vpNow.Y * L.MaxScreenRatio))
    if CurW > maxW or CurH > maxH then
      local s = math.min(maxW / CurW, maxH / CurH)
      CurW, CurH = math.floor(CurW * s), math.floor(CurH * s)
      Holder.Size = UDim2.fromOffset(CurW, CurH)
    end
    local p = Holder.Position
    local cx = p.X.Scale * vpNow.X + p.X.Offset
    local cy = p.Y.Scale * vpNow.Y + p.Y.Offset
    local hw, hh = CurW / 2, CurH / 2
    if vpNow.X >= CurW then cx = math.clamp(cx, hw, vpNow.X - hw) else cx = vpNow.X / 2 end
    if vpNow.Y >= CurH then cy = math.clamp(cy, hh, vpNow.Y - hh) else cy = vpNow.Y / 2 end
    Holder.Position = UDim2.new(0, math.floor(cx), 0, math.floor(cy))
  end
  OnViewportChange(RefitWindow)

  -- Registry keybind (satu listener utk semua)
  local Keybinds, ListeningKeybind = {}, nil
  BindGlobal(UserInputService.InputBegan, function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Unknown then return end
    if ListeningKeybind then
      local kb = ListeningKeybind
      ListeningKeybind = nil
      if input.KeyCode == Enum.KeyCode.Escape then
        kb.SetKey(Enum.KeyCode.Unknown)
      else
        kb.SetKey(input.KeyCode)
      end
      return
    end
    for _, kb in ipairs(Keybinds) do
      if kb.Key == input.KeyCode then
        SafeCall(kb.Fn, input.KeyCode)
      end
    end
  end)

  -- ═══ OVERLAY DROPDOWN ═══
  local DropdownOpen = false
  local DropToken = 0

  local MoreBlur = Custom:Create("Frame", {
    Name = "DropdownOverlay", AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ClipsDescendants = true,
    Position = UDim2.new(1, 8, 1, 8), Size = UDim2.new(1, 164, 1, 54),
    Visible = false, ZIndex = Z.Dropdown,
  }, Layers)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, MoreBlur)

  local ConnectButton = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "", BackgroundTransparency = 1,
    BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Dropdown + 1,
  }, MoreBlur)

  local DropdownSelect = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = CONFIG.Theme.Background,
    BackgroundTransparency = 0.02, BorderSizePixel = 0, Active = true,
    Position = UDim2.new(1, 182, 0.5, 0), Size = UDim2.new(0, 170, 1, -18),
    ClipsDescendants = true, ZIndex = Z.Dropdown + 1,
  }, MoreBlur)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, DropdownSelect)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4, Transparency = 0.25 }, DropdownSelect)
  Themed(DropdownSelect, "BackgroundColor3", "Background")

  local DropdownSelectReal = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
    BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, -10, 1, -10), ZIndex = Z.Dropdown + 2,
  }, DropdownSelect)

  local function OpenDropdownPanel(Page)
    if DropdownOpen then return end
    DropdownOpen = true
    DropToken += 1
    for _, p in ipairs(DropdownSelectReal:GetChildren()) do
      if p:IsA("ScrollingFrame") then p.Visible = (p == Page) end
    end
    MoreBlur.Visible = true
    Tween(MoreBlur, { BackgroundTransparency = 0.68 }, 0.12)
    Tween(DropdownSelect, { Position = UDim2.new(1, -11, 0.5, 0) }, 0.14, Enum.EasingStyle.Back)
  end

  local function CloseDropdownPanel()
    if not DropdownOpen then return end
    DropdownOpen = false
    DropToken += 1
    local token = DropToken
    Tween(MoreBlur, { BackgroundTransparency = 1 }, 0.18)
    Tween(DropdownSelect, { Position = UDim2.new(1, 182, 0.5, 0) }, 0.18)
    task.delay(0.2, function()
      if token == DropToken and MoreBlur then MoreBlur.Visible = false end
    end)
  end

  ConnectButton.Activated:Connect(CloseDropdownPanel)

  -- ═══════════ TABS ═══════════
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

  local function ApplyTabVisual(T, sel, Instant)
    local t = Instant and 0 or 0.2
    if sel then
      Tween(T.Frame, {
        BackgroundColor3 = CONFIG.Theme.Primary, BackgroundTransparency = 0.86,
      }, t)
      Tween(T.Label, { TextColor3 = CONFIG.Theme.Text }, t)
      Tween(T.Bar, { Size = UDim2.new(0, 3, 0, 16), BackgroundTransparency = 0 }, t)
    else
      Tween(T.Frame, {
        BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 1,
      }, t)
      Tween(T.Label, { TextColor3 = CONFIG.Theme.SubText }, t)
      Tween(T.Bar, { Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 1 }, t)
    end
  end

  local function SelectTab(Target, Instant)
    if CurrentTab == Target then return end
    if CurrentTab then ApplyTabVisual(CurrentTab, false, Instant) end
    CurrentTab = Target
    ApplyTabVisual(Target, true, Instant)
    NameTab.Text = Target.Name
  end

  function Tabs:CreateTab(TabConfig)
    local Name = tostring(Get(TabConfig, 1, "Name", ""))
    local Icon = Get(TabConfig, 2, "Icon", "")
    if type(Icon) ~= "string" then Icon = "" end
    local TabIndex = #AllTabs + 1

    local Page = Custom:Create("ScrollingFrame", {
      Name = "Page_" .. Name, CanvasSize = UDim2.new(),
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      ScrollingDirection = Enum.ScrollingDirection.Y,
      ScrollBarThickness = L.ScrollThick,
      ScrollBarImageColor3 = CONFIG.Theme.SubText,
      ScrollBarImageTransparency = 0.35,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, -2, 1, 0), Position = UDim2.new(0, 0, 0, 0),
      Visible = false, ZIndex = Z.Control,
    }, LayersReal)
    Themed(Page, "ScrollBarImageColor3", "SubText")
    Custom:Create("UIListLayout", {
      Padding = UDim.new(0, L.ItemSpacing + 1), SortOrder = Enum.SortOrder.LayoutOrder,
    }, Page)
    Custom:Create("UIPadding", {
      PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2),
    }, Page)

    local Tab = Custom:Create("Frame", {
      Name = "Tab", BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      LayoutOrder = TabIndex, Size = UDim2.new(1, 0, 0, L.TabHeight), ZIndex = Z.Control,
    }, ScrollTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, L.TabRadius) }, Tab)

    local TabButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Regular, Text = "", BackgroundTransparency = 1,
      BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Control + 2,
    }, Tab)

    local TabLabel = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = Name, TextColor3 = CONFIG.Theme.SubText,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
      BorderSizePixel = 0, Size = UDim2.new(1, Icon ~= "" and -38 or -14, 1, 0),
      Position = UDim2.new(0, Icon ~= "" and 38 or 14, 0, 0), ZIndex = Z.Control + 1,
    }, Tab)

    if Icon ~= "" then
      Custom:Create("ImageLabel", {
        Image = Icon, BackgroundTransparency = 1, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(18, 18), ZIndex = Z.Control + 1,
      }, Tab)
    end

    local Bar = Custom:Create("Frame", {
      Name = "ChooseFrame", AnchorPoint = Vector2.new(0, 0.5),
      BackgroundColor3 = CONFIG.Theme.Primary, BackgroundTransparency = 1,
      BorderSizePixel = 0, Position = UDim2.new(0, 4, 0.5, 0),
      Size = UDim2.new(0, 3, 0, 0), ZIndex = Z.Control + 1,
    }, Tab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Bar)
    Themed(Bar, "BackgroundColor3", "Primary")

    local TabObj = { Name = Name, Frame = Tab, Page = Page, Bar = Bar, Label = TabLabel }
    table.insert(AllTabs, TabObj)

    Themed(Tab, function()
      if CurrentTab == TabObj then ApplyTabVisual(TabObj, true, true) end
    end, "Primary")

    TabButton.MouseEnter:Connect(function()
      if CurrentTab ~= TabObj then
        Tween(Tab, { BackgroundTransparency = 0.96 }, 0.12)
      end
    end)
    TabButton.MouseLeave:Connect(function()
      if CurrentTab ~= TabObj then
        Tween(Tab, { BackgroundTransparency = 1 }, 0.12)
      end
    end)

    if TabIndex == 1 then SelectTab(TabObj, true) end

    TabButton.Activated:Connect(function()
      CircleClick(TabButton)
      PlaySound("Click")
      CloseDropdownPanel()
      SelectTab(TabObj, false)
    end)

    -- ═══════════ SECTIONS ═══════════
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
        Name = "Section", BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true, LayoutOrder = CountSection,
        Size = UDim2.new(1, 0, 0, 32), ZIndex = Z.Base,
      }, Page)

      local SectionReal = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = CONFIG.Theme.Panel,
        BackgroundTransparency = 0.93, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 0, 0, 32),
        ZIndex = Z.Base,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, L.ItemRadius + 1) }, SectionReal)
      Themed(SectionReal, "BackgroundColor3", "Panel")

      local SectionButton = Custom:Create("TextButton", {
        Font = CONFIG.Font.Regular, Text = "", BackgroundTransparency = 1,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Control + 2,
      }, SectionReal)

      local FeatureFrame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1,
        BorderSizePixel = 0, Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(22, 22), ZIndex = Z.Control + 1,
      }, SectionReal)
      local Arrow = Custom:Create("ImageLabel", {
        Image = CONFIG.Assets.ArrowIcon, AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -90,
        Size = UDim2.fromOffset(14, 14), ZIndex = Z.Control + 1,
      }, FeatureFrame)

      local SectionLabel = Custom:Create("TextLabel", {
        Font = CONFIG.Font.Bold, Text = SectionTitle,
        TextColor3 = CONFIG.Theme.Text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
        BorderSizePixel = 0, Position = UDim2.new(0, L.ItemPadX, 0.5, 0),
        Size = UDim2.new(1, -52, 0, 14), ZIndex = Z.Control + 1,
      }, SectionReal)
      Themed(SectionLabel, "TextColor3", "Text")

      local SectionDecide = Custom:Create("Frame", {
        BackgroundColor3 = CONFIG.Theme.Panel, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 36),
        Size = UDim2.new(0, 0, 0, 2), ZIndex = Z.Base,
      }, Section)
      Custom:Create("UICorner", {}, SectionDecide)
      Custom:Create("UIGradient", {
        Color = ColorSequence.new {
          ColorSequenceKeypoint.new(0, CONFIG.Theme.Background),
          ColorSequenceKeypoint.new(0.5, CONFIG.Theme.Primary),
          ColorSequenceKeypoint.new(1, CONFIG.Theme.Background),
        },
      }, SectionDecide)

      local SectionAdd = Custom:Create("Frame", {
        Name = "SectionContent", AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0, 40), Size = UDim2.new(1, 0, 0, 0),
        ZIndex = Z.Base,
      }, Section)
      local SectionList = Custom:Create("UIListLayout", {
        Padding = UDim.new(0, L.ItemSpacing), SortOrder = Enum.SortOrder.LayoutOrder,
      }, SectionAdd)

      local function ApplyLayout(Animate)
        local t = Animate and 0.16 or 0
        local contentH = SectionList.AbsoluteContentSize.Y
        SectionAdd.Size = UDim2.new(1, 0, 0, contentH)
        Tween(Arrow, { Rotation = OpenSection and 0 or -90 }, t)
        Tween(Section, { Size = UDim2.new(1, 0, 0, OpenSection and (40 + contentH + 2) or 32) }, t)
        Tween(SectionDecide, {
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

      -- ═══════════ ITEMS ═══════════
      local Item = {}
      local ItemCount = 0
      local function NextOrder()
        ItemCount += 1
        return ItemCount
      end

      -- ── Paragraph ──
      function Item:AddParagraph(P)
        local Base = NewItemBase(SectionAdd, NextOrder(),
          Get(P, 1, "Title", ""), Get(P, 2, "Content", ""), 20)
        local F = {}
        AttachCommon(F, Base)
        AttachTooltipOpt(Base.Frame, Get(P, nil, "Tooltip", ""))
        function F:Set(C)
          Base.Title.Text = tostring(Get(C, 1, "Title", Base.Title.Text))
          Base.Content.Text = tostring(Get(C, 2, "Content", Base.Content.Text))
        end
        return F
      end

      -- ── Seperator ──
      function Item:AddSeperator(S)
        local Title = tostring(Get(S, 1, "Title", ""))
        local F = {}
        local Sep = Custom:Create("Frame", {
          Name = "Seperator", BackgroundColor3 = CONFIG.Theme.Divider,
          BackgroundTransparency = 0.35, BorderSizePixel = 0,
          LayoutOrder = NextOrder(), Size = UDim2.new(1, 0, 0, 30), ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Sep)
        Themed(Sep, "BackgroundColor3", "Divider")
        local SepLabel = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
          TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Center, BackgroundTransparency = 1,
          BorderSizePixel = 0, Position = UDim2.new(0, 12, 0, 0),
          Size = UDim2.new(1, -18, 1, 0), ZIndex = Z.Content,
        }, Sep)
        Themed(SepLabel, "TextColor3", "Text")
        AttachTooltipOpt(Sep, Get(S, nil, "Tooltip", ""))
        function F:Set(C) SepLabel.Text = tostring(Get(C, 1, "Title", "")) end
        function F:SetVisible(State) Sep.Visible = State and true or false end
        function F:Destroy() Sep:Destroy() end
        return F
      end

      -- ── Line ──
      function Item:AddLine()
        local F = {}
        local Line = Custom:Create("Frame", {
          Name = "Line", BackgroundColor3 = CONFIG.Theme.LineColor,
          BackgroundTransparency = 0.4, BorderSizePixel = 0,
          LayoutOrder = NextOrder(), Size = UDim2.new(1, 0, 0, 6), ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Line)
        Themed(Line, "BackgroundColor3", "LineColor")
        function F:Destroy() Line:Destroy() end
        return F
      end

      -- ── Button ──
      function Item:AddButton(B)
        local Title = Get(B, 1, "Title", "")
        local Content = Get(B, 2, "Content", "")
        local Icon = Get(B, 3, "Icon", "")
        local Callback = Get(B, 4, "Callback", function() end)
        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          (type(Icon) == "string" and Icon ~= "") and 58 or 20)
        local F = {}
        AttachCommon(F, Base)
        AttachTooltipOpt(Base.Frame, Get(B, nil, "Tooltip", ""))

        local Btn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "", BackgroundTransparency = 1,
          BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Control,
        }, Base.Frame)
        if type(Icon) == "string" and Icon ~= "" then
          Custom:Create("ImageLabel", {
            Image = Icon, AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(24, 24),
            ZIndex = Z.Content,
          }, Base.Frame)
        end
        Btn.Activated:Connect(function()
          CircleClick(Btn)
          PlaySound("Click")
          SafeCall(Callback)
        end)
        function F:Set(C)
          if Get(C, 1, "Title", nil) ~= nil then F:SetTitle(Get(C, 1, "Title", "")) end
          if Get(C, 2, "Content", nil) ~= nil then F:SetContent(Get(C, 2, "Content", "")) end
        end
        return F
      end

      -- ── Toggle ──
      function Item:AddToggle(T)
        local Title = Get(T, 1, "Title", "")
        local Content = Get(T, 2, "Content", "")
        local Default = Get(T, 3, "Default", false)
        local Callback = Get(T, 4, "Callback", function() end)
        local SaveKey = tostring(Get(T, nil, "SaveKey", ""))
        local F = { Value = Default == true }
        if SaveKey ~= "" then
          local sv = Save.Get(SaveKey)
          if sv ~= nil then F.Value = sv == true end
        end

        local Reserve = L.ToggleW + L.ItemPadX + 8
        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content, Reserve)
        AttachCommon(F, Base)
        AttachTooltipOpt(Base.Frame, Get(T, nil, "Tooltip", ""))

        local Track = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = CONFIG.Theme.Secondary,
          BackgroundTransparency = 0.25, BorderSizePixel = 0,
          Position = UDim2.new(1, -L.ItemPadX, 0.5, 0),
          Size = UDim2.fromOffset(L.ToggleW, L.ToggleH), ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Track)
        Themed(Track, "BackgroundColor3", "Secondary")

        local Knob = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BorderSizePixel = 0, Position = UDim2.new(0, 2, 0.5, 0),
          Size = UDim2.fromOffset(L.ToggleKnob, L.ToggleKnob), ZIndex = Z.Control,
        }, Track)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, Knob)

        local Btn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "", BackgroundTransparency = 1,
          BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Control,
        }, Base.Frame)

        local function Render(on)
          Tween(Base.Title, { TextColor3 = on and CONFIG.Theme.Primary or CONFIG.Theme.Text }, 0.2)
          Tween(Knob, {
            Position = UDim2.new(0, on and (L.ToggleW - L.ToggleKnob - 2) or 2, 0.5, 0),
          }, 0.22, Enum.EasingStyle.Back)
          Tween(Track, {
            BackgroundColor3 = on and CONFIG.Theme.Primary or CONFIG.Theme.Secondary,
            BackgroundTransparency = on and 0 or 0.25,
          }, 0.2)
        end

        function F:Set(Value, Fire)
          F.Value = Value == true
          Render(F.Value)
          if Fire ~= false then
            SafeCall(Callback, F.Value)
            if SaveKey ~= "" then Save.Set(SaveKey, F.Value) end
          end
        end

        Btn.Activated:Connect(function()
          CircleClick(Btn)
          PlaySound(not F.Value and "ToggleOn" or "ToggleOff")
          F:Set(not F.Value)
        end)

        F:Set(F.Value, false)
        return F
      end

      -- ── Slider ──
      function Item:AddSlider(S)
        local Title = Get(S, 1, "Title", "")
        local Content = Get(S, 2, "Content", "")
        local Increment = tonumber(Get(S, 3, "Increment", 1)) or 1
        local Min = tonumber(Get(S, 4, "Min", 0)) or 0
        local Max = tonumber(Get(S, 5, "Max", 100)) or 100
        local Default = tonumber(Get(S, 6, "Default", Min)) or Min
        local Callback = Get(S, 7, "Callback", function() end)
        local SaveKey = tostring(Get(S, nil, "SaveKey", ""))
        if Increment <= 0 then Increment = 1 end
        if Max <= Min then Max = Min + 1 end

        local Bind, Clear = NewBinder(WindowConns)
        local F = { Value = Default }
        if SaveKey ~= "" then
          local sv = tonumber(Save.Get(SaveKey, nil))
          if sv then F.Value = math.clamp(sv, Min, Max) end
        end

        local decimals = 0
        local frac = tostring(Increment):match("%.(%d+)")
        if frac then decimals = #frac end

        local function Snap(n)
          n = Min + math.floor((n - Min) / Increment + 0.5) * Increment
          n = math.clamp(n, Min, Max)
          if decimals > 0 then
            n = tonumber(string.format("%." .. decimals .. "f", n)) or n
          end
          return n
        end
        local function Fmt(n)
          if decimals > 0 then return string.format("%." .. decimals .. "f", n) end
          return tostring(math.floor(n + 0.5))
        end
        F.Value = Snap(F.Value)

        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          L.ValueBoxW + L.ItemPadX + 6)
        AttachCommon(F, Base, Clear)
        AttachTooltipOpt(Base.Frame, Get(S, nil, "Tooltip", ""))

        Base.Apply = function(h)
          Base.Frame.Size = UDim2.new(1, 0, 0, h + 18)
        end
        Base.Refit()

        local ValueBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold, Text = Fmt(F.Value), TextSize = 12,
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -L.ItemPadX, 0, 9),
          Size = UDim2.fromOffset(L.ValueBoxW, L.ValueBoxH), ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, ValueBtn)
        Themed(ValueBtn, function(p)
          ValueBtn.BackgroundColor3 = p
          ValueBtn.TextColor3 = ContrastColor(p)
        end, "Primary")
        ValueBtn.TextColor3 = ContrastColor(CONFIG.Theme.Primary)

        local Track = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = CONFIG.Theme.Secondary,
          BackgroundTransparency = 0.2, BorderSizePixel = 0,
          Position = UDim2.new(0, L.ItemPadX, 1, -10),
          Size = UDim2.new(1, -(L.ItemPadX * 2), 0, L.SliderTrackH), ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Track)
        Themed(Track, "BackgroundColor3", "Secondary")

        local Fill = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Size = UDim2.new(0, 0, 1, 0), ZIndex = Z.Content + 1,
        }, Track)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Fill)
        Themed(Fill, "BackgroundColor3", "Primary")

        local Knob = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
          BorderSizePixel = 0, Position = UDim2.new(0, 0, 0.5, 0),
          Size = UDim2.fromOffset(L.SliderKnob, L.SliderKnob), ZIndex = Z.Control,
        }, Track)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Knob)
        local KnobStroke = Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Primary, Thickness = 2,
        }, Knob)
        Themed(KnobStroke, "Color", "Primary")

        local function UpdateVisual()
          local a = (Max == Min) and 0 or (F.Value - Min) / (Max - Min)
          Fill.Size = UDim2.new(a, 0, 1, 0)
          Knob.Position = UDim2.new(a, 0, 0.5, 0)
          ValueBtn.Text = Fmt(F.Value)
        end

        local function Apply(v, Fire)
          v = Snap(tonumber(v) or Min)
          local changed = (v ~= F.Value)
          F.Value = v
          UpdateVisual()
          if changed and Fire ~= false then
            SafeCall(Callback, v)
            if SaveKey ~= "" then Save.Set(SaveKey, v) end
          end
        end

        local Dragging = false
        Track.InputBegan:Connect(function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            local a = math.clamp((input.Position.X - Track.AbsolutePosition.X)
              / math.max(Track.AbsoluteSize.X, 1), 0, 1)
            Apply(Min + (Max - Min) * a)
          end
        end)
        Bind(UserInputService.InputChanged, function(input)
          if not Dragging then return end
          local t = input.UserInputType
          if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local a = math.clamp((input.Position.X - Track.AbsolutePosition.X)
              / math.max(Track.AbsoluteSize.X, 1), 0, 1)
            Apply(Min + (Max - Min) * a)
          end
        end)
        Bind(UserInputService.InputEnded, function(input)
          if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
          end
        end)

        ValueBtn.Activated:Connect(function()
          local Edit = Custom:Create("TextBox", {
            Font = CONFIG.Font.Bold, Text = Fmt(F.Value), TextSize = 12,
            TextColor3 = ContrastColor(CONFIG.Theme.Primary),
            BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -L.ItemPadX, 0, 9),
            Size = UDim2.fromOffset(L.ValueBoxW, L.ValueBoxH), ZIndex = Z.Control,
            ClearTextOnFocus = true,
          }, Base.Frame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Edit)
          ValueBtn.Visible = false
          Edit:CaptureFocus()
          Edit.FocusLost:Connect(function()
            local n = tonumber(Edit.Text)
            if n then Apply(math.clamp(n, Min, Max)) end
            Edit:Destroy()
            ValueBtn.Visible = true
          end)
        end)

        function F:Set(v, Fire)
          if tonumber(v) then Apply(tonumber(v), Fire) end
        end
        Apply(F.Value, false)
        return F
      end

      -- ── Input ──
      function Item:AddInput(I)
        local Title = Get(I, 1, "Title", "")
        local Content = Get(I, 2, "Content", "")
        local Default = Get(I, 3, "Default", "")
        local Placeholder = tostring(Get(I, 4, "Placeholder", "Type here..."))
        local Callback = Get(I, 5, "Callback", function() end)
        local SaveKey = tostring(Get(I, nil, "SaveKey", ""))
        local F = { Value = tostring(Default) }
        if SaveKey ~= "" then
          local sv = Save.Get(SaveKey, nil)
          if sv ~= nil then F.Value = tostring(sv) end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          L.InputW + L.ItemPadX + 6)
        AttachCommon(F, Base)
        AttachTooltipOpt(Base.Frame, Get(I, nil, "Tooltip", ""))

        local Box = Custom:Create("TextBox", {
          Font = CONFIG.Font.Regular, Text = F.Value, PlaceholderText = Placeholder,
          PlaceholderColor3 = CONFIG.Theme.SubText, TextColor3 = CONFIG.Theme.Text,
          TextSize = 12, BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92, BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -L.ItemPadX, 0.5, 0),
          Size = UDim2.fromOffset(L.InputW, L.InputH), ZIndex = Z.Content,
          ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
          ClipsDescendants = true,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Box)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, Box)
        Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, Box)

        Box.FocusLost:Connect(function()
          F.Value = Box.Text
          SafeCall(Callback, Box.Text)
          if SaveKey ~= "" then Save.Set(SaveKey, Box.Text) end
        end)

        function F:Set(Text, Fire)
          F.Value = tostring(Text)
          Box.Text = F.Value
          if Fire ~= false then SafeCall(Callback, F.Value) end
        end
        return F
      end

      -- ── Dropdown ──
      function Item:AddDropdown(D)
        local Title = Get(D, 1, "Title", "")
        local Content = Get(D, 2, "Content", "")
        local Multi = Get(D, 3, "Multi", false) == true
        local Options = Get(D, 4, "Options", {})
        if type(Options) ~= "table" then Options = {} end
        local Default = Get(D, 5, "Default", Multi and {} or "")
        local Callback = Get(D, 6, "Callback", function() end)
        local Searchable = Get(D, nil, "Search", true) == true
        local SaveKey = tostring(Get(D, nil, "SaveKey", ""))

        local F = Multi and { Value = {} } or { Value = "" }
        if SaveKey ~= "" then
          local sv = Save.Get(SaveKey, nil)
          if sv ~= nil then F.Value = sv end
        end
        if Multi then
          if type(F.Value) ~= "table" then
            F.Value = (type(F.Value) == "string" and F.Value ~= "") and { F.Value } or {}
          end
        else
          if type(F.Value) == "table" then F.Value = tostring(F.Value[1] or "") end
          F.Value = tostring(F.Value)
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          L.DropW + L.ItemPadX + 6)
        AttachCommon(F, Base)
        AttachTooltipOpt(Base.Frame, Get(D, nil, "Tooltip", ""))

        local DropBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
          TextSize = 12, BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92, BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -L.ItemPadX, 0.5, 0),
          Size = UDim2.fromOffset(L.DropW, L.DropH), ZIndex = Z.Content,
          TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, DropBtn)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, DropBtn)
        Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 18) }, DropBtn)
        Custom:Create("ImageLabel", {
          Image = CONFIG.Assets.ArrowIcon, AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(12, 12),
          Rotation = 180, ZIndex = Z.Control,
        }, DropBtn)

        local PageFrame = Custom:Create("ScrollingFrame", {
          Name = "DropPage", BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(),
          AutomaticCanvasSize = Enum.AutomaticSize.Y,
          ScrollBarThickness = 2, ScrollBarImageColor3 = CONFIG.Theme.SubText,
          ScrollBarImageTransparency = 0.4,
          Visible = false, ZIndex = Z.Dropdown + 3,
        }, DropdownSelectReal)
        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder,
        }, PageFrame)
        Custom:Create("UIPadding", {
          PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
          PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
        }, PageFrame)

        local function IsSel(name)
          if Multi then
            for _, v in ipairs(F.Value) do if v == name then return true end end
            return false
          end
          return F.Value == name
        end

        local function UpdateText()
          if Multi then
            DropBtn.Text = (#F.Value > 0) and (#F.Value .. " selected") or "None"
          else
            DropBtn.Text = (F.Value ~= "") and F.Value or "None"
          end
        end

        local function Emit()
          if Multi then
            local copy = {}
            for i, v in ipairs(F.Value) do copy[i] = v end
            SafeCall(Callback, copy)
            if SaveKey ~= "" then Save.Set(SaveKey, copy) end
          else
            SafeCall(Callback, F.Value)
            if SaveKey ~= "" then Save.Set(SaveKey, F.Value) end
          end
        end

        local OptionButtons = {}
        local function StyleBtn(Btn, sel)
          Btn.BackgroundColor3 = sel and CONFIG.Theme.Primary or CONFIG.Theme.Panel
          Btn.BackgroundTransparency = sel and 0.8 or 0.92
          Btn.TextColor3 = sel and ContrastColor(CONFIG.Theme.Primary) or CONFIG.Theme.Text
        end

        local function MakeOption(name, order)
          local sel = IsSel(name)
          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold, Text = tostring(name), TextSize = 12,
            BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.92,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 26),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = order, ZIndex = Z.Dropdown + 4,
          }, PageFrame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Btn)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, Btn)
          StyleBtn(Btn, sel)

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            PlaySound("Click")
            if Multi then
              local found = false
              for i, v in ipairs(F.Value) do
                if v == name then
                  table.remove(F.Value, i)
                  found = true
                  break
                end
              end
              if not found then table.insert(F.Value, name) end
              StyleBtn(Btn, IsSel(name))
              UpdateText()
              Emit()
            else
              F.Value = name
              for _, b in ipairs(OptionButtons) do
                if b:IsDescendantOf(PageFrame) then b:Destroy() end
              end
              UpdateText()
              Emit()
              CloseDropdownPanel()
            end
          end)
          table.insert(OptionButtons, Btn)
          return Btn
        end

        local function Rebuild(Filter)
          for _, b in ipairs(OptionButtons) do
            if b.Parent then b:Destroy() end
          end
          OptionButtons = {}
          local order = 1
          for _, name in ipairs(Options) do
            local n = tostring(name)
            if not Filter or Filter == ""
              or string.find(string.lower(n), string.lower(Filter), 1, true) then
              MakeOption(n, order)
              order += 1
            end
          end
        end

        if Searchable then
          local SearchBox = Custom:Create("TextBox", {
            Font = CONFIG.Font.Regular, Text = "", PlaceholderText = "Search...",
            PlaceholderColor3 = CONFIG.Theme.SubText, TextColor3 = CONFIG.Theme.Text,
            TextSize = 11, BackgroundColor3 = CONFIG.Theme.Panel,
            BackgroundTransparency = 0.9, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 24), ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0,
            ZIndex = Z.Dropdown + 4,
          }, PageFrame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, SearchBox)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 7) }, SearchBox)
          SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            Rebuild(SearchBox.Text)
          end)
        end

        DropBtn.Activated:Connect(function()
          CircleClick(DropBtn)
          PlaySound("Click")
          Rebuild("")
          OpenDropdownPanel(PageFrame)
        end)

        function F:Set(value, Fire)
          F.Value = value
          if Multi and type(F.Value) ~= "table" then F.Value = {} end
          if not Multi and type(F.Value) == "table" then F.Value = tostring(F.Value[1] or "") end
          UpdateText()
          if Fire ~= false then Emit() end
        end
        function F:Refresh(newOptions, selected)
          Options = (type(newOptions) == "table") and newOptions or Options
          if selected ~= nil then F.Value = selected end
          Rebuild("")
          UpdateText()
        end
        function F:AddOption(name)
          table.insert(Options, name)
          Rebuild("")
        end
        function F:Clear()
          Options = {}
          F.Value = Multi and {} or ""
          Rebuild("")
          UpdateText()
        end

        UpdateText()
        return F
      end

      -- ── Keybind ──
      function Item:AddKeybind(K)
        local Title = Get(K, 1, "Title", "")
        local Content = Get(K, 2, "Content", "")
        local Default = Get(K, 3, "Default", Enum.KeyCode.Unknown)
        local Callback = Get(K, 4, "Callback", function() end)
        local SaveKey = tostring(Get(K, nil, "SaveKey", ""))

        local Key = (typeof(Default) == "EnumItem" and Default.EnumType == Enum.KeyCode)
          and Default or Enum.KeyCode.Unknown
        if SaveKey ~= "" then
          local sv = Save.Get(SaveKey, nil)
          if type(sv) == "string" and sv ~= "" and Enum.KeyCode[sv] then
            Key = Enum.KeyCode[sv]
          end
        end

        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          L.KeyW + L.ItemPadX + 6)
        local F = { Value = Key }
        local entry = {}
        local function RemoveFromRegistry()
          local i = table.find(Keybinds, entry)
          if i then table.remove(Keybinds, i) end
        end
        AttachCommon(F, Base, RemoveFromRegistry)
        AttachTooltipOpt(Base.Frame, Get(K, nil, "Tooltip", ""))

        local KeyBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
          TextSize = 11, BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92, BorderSizePixel = 0,
          AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -L.ItemPadX, 0.5, 0),
          Size = UDim2.fromOffset(L.KeyW, L.KeyH), ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, KeyBtn)
        Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.5,
        }, KeyBtn)

        local function Render()
          KeyBtn.Text = (Key ~= Enum.KeyCode.Unknown) and Key.Name or "None"
          KeyBtn.TextColor3 = CONFIG.Theme.Text
        end

        function entry.SetKey(newKey)
          if typeof(newKey) == "EnumItem" and newKey.EnumType == Enum.KeyCode then
            Key = newKey
          else
            Key = Enum.KeyCode.Unknown
          end
          F.Value = Key
          entry.Key = Key
          Render()
          if SaveKey ~= "" then
            Save.Set(SaveKey, (Key ~= Enum.KeyCode.Unknown) and Key.Name or "")
          end
        end

        entry.Key = Key
        entry.Fn = function(kc) SafeCall(Callback, kc) end
        table.insert(Keybinds, entry)

        KeyBtn.Activated:Connect(function()
          CircleClick(KeyBtn)
          PlaySound("Click")
          ListeningKeybind = entry
          KeyBtn.Text = "..."
          KeyBtn.TextColor3 = CONFIG.Theme.Primary
        end)

        function F:Set(newKey, Fire)
          if typeof(newKey) == "EnumItem" then
            entry.SetKey(newKey)
            if Fire ~= false then SafeCall(Callback, Key) end
          end
        end
        function F:Get() return Key end
        Render()
        return F
      end

      -- ── ColorPicker (auto-fit via UIScale) ──
      function Item:AddColorPicker(C)
        local Title = Get(C, 1, "Title", "")
        local Content = Get(C, 2, "Content", "")
        local Default = Get(C, 3, "Default", Color3.fromRGB(255, 0, 0))
        local Callback = Get(C, 4, "Callback", function() end)
        local Presets = Get(C, 5, "Presets", nil)
        local SaveKey = tostring(Get(C, nil, "SaveKey", ""))

        local F = { Value = (typeof(Default) == "Color3") and Default or Color3.fromRGB(255, 0, 0) }
        if SaveKey ~= "" then
          local sv = Save.Get(SaveKey, nil)
          if type(sv) == "table" then
            F.Value = Color3.fromRGB(
              tonumber(sv[1]) or 255, tonumber(sv[2]) or 0, tonumber(sv[3]) or 0)
          end
        end

        local Bind, Clear = NewBinder(WindowConns)
        local Base = NewItemBase(SectionAdd, NextOrder(), Title, Content,
          L.SwatchW + L.ItemPadX + 6)
        AttachCommon(F, Base, Clear)
        AttachTooltipOpt(Base.Frame, Get(C, nil, "Tooltip", ""))

        local Swatch = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "", BackgroundColor3 = F.Value,
          BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0),
          Position = UDim2.new(1, -L.ItemPadX, 0, 9),
          Size = UDim2.fromOffset(L.SwatchW, L.SwatchH), ZIndex = Z.Content,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Swatch)
        Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.4 }, Swatch)

        local Open = false

        local function OpenPicker()
          if Open then return end
          Open = true
          local gui = NewScreenGui("KingAkbarUI_ColorPicker", Z.Popup)

          local h, s, v = 0, 1, 1
          do
            local ok, hh, ss, vv = pcall(Color3.toHSV, F.Value)
            if ok and hh then h, s, v = hh, ss, vv end
          end

          local PW, PH = 238, (Presets and 230 or 200)

          local Frame = Custom:Create("Frame", {
            Name = "Picker", BackgroundColor3 = CONFIG.Theme.Background,
            BackgroundTransparency = 0.02, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(PW, PH), ZIndex = Z.Popup,
          }, gui)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 10) }, Frame)
          Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4, Transparency = 0.2 }, Frame)

          -- v2.2: auto-fit di layar kecil
          do
            local vpNow = GetViewport()
            local m = L.ScreenMargin
            local ps = math.min(1, (vpNow.X - m * 2) / PW, (vpNow.Y - m * 2) / PH)
            if ps < 1 then
              local sc = Instance.new("UIScale")
              sc.Scale = ps
              sc.Parent = Frame
            end
          end

          local Back = Custom:Create("TextButton", {
            Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Popup - 1,
          }, gui)

          Custom:Create("TextLabel", {
            Font = CONFIG.Font.Bold, Text = "Pick Color",
            TextColor3 = CONFIG.Theme.Text, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
            BorderSizePixel = 0, Position = UDim2.new(0, 14, 0, 10),
            Size = UDim2.new(1, -28, 0, 18), ZIndex = Z.Popup + 1,
          }, Frame)

          local CloseBtn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold, Text = "×", TextColor3 = CONFIG.Theme.SubText,
            TextSize = 15, BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 6),
            Size = UDim2.fromOffset(24, 24), ZIndex = Z.Popup + 2,
          }, Frame)

          local SV = Custom:Create("ImageButton", {
            BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0,
            AutoButtonColor = false,
            Position = UDim2.new(0, 14, 0, 36), Size = UDim2.fromOffset(164, 122),
            ZIndex = Z.Popup + 1,
          }, Frame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, SV)
          local SVGrad = Custom:Create("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1)),
          }, SV)
          local SVDark = Custom:Create("Frame", {
            BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = Z.Popup + 1,
          }, SV)
          Custom:Create("UIGradient", {
            Transparency = NumberSequence.new({
              NumberSequenceKeypoint.new(0, 1),
              NumberSequenceKeypoint.new(1, 0),
            }),
            Rotation = 90,
          }, SVDark)
          local SVCursor = Custom:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Size = UDim2.fromOffset(10, 10), ZIndex = Z.Popup + 3,
          }, SV)
          Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SVCursor)
          Custom:Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, SVCursor)

          local HueBar = Custom:Create("ImageButton", {
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            AutoButtonColor = false,
            Position = UDim2.new(0, 190, 0, 36), Size = UDim2.fromOffset(18, 122),
            ZIndex = Z.Popup + 1,
          }, Frame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, HueBar)
          Custom:Create("UIGradient", {
            Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
              ColorSequenceKeypoint.new(0.17, Color3.fromHSV(1/6, 1, 1)),
              ColorSequenceKeypoint.new(0.33, Color3.fromHSV(2/6, 1, 1)),
              ColorSequenceKeypoint.new(0.50, Color3.fromHSV(3/6, 1, 1)),
              ColorSequenceKeypoint.new(0.67, Color3.fromHSV(4/6, 1, 1)),
              ColorSequenceKeypoint.new(0.83, Color3.fromHSV(5/6, 1, 1)),
              ColorSequenceKeypoint.new(1.00, Color3.fromHSV(0, 1, 1)),
            }),
            Rotation = 90,
          }, HueBar)
          local HueCursor = Custom:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            Size = UDim2.fromOffset(22, 6), ZIndex = Z.Popup + 3,
          }, HueBar)
          Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, HueCursor)
          Custom:Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, HueCursor)

          local Preview = Custom:Create("Frame", {
            BackgroundColor3 = F.Value, BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0, 166), Size = UDim2.fromOffset(34, 22),
            ZIndex = Z.Popup + 1,
          }, Frame)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Preview)
          local RGB = Custom:Create("TextLabel", {
            Font = CONFIG.Font.Regular, Text = "", TextColor3 = CONFIG.Theme.SubText,
            TextSize = 11, BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 56, 0, 166), Size = UDim2.new(1, -66, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = Z.Popup + 1,
          }, Frame)

          local function Render()
            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            HueCursor.Position = UDim2.new(0.5, 0, h, 0)
            local c = Color3.fromHSV(h, s, v)
            F.Value = c
            Swatch.BackgroundColor3 = c
            Preview.BackgroundColor3 = c
            RGB.Text = string.format("R:%d G:%d B:%d",
              math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
          end

          local function SetHue(nh)
            h = nh
            SVGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
            SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Render()
          end

          local function Emit(SaveNow)
            SafeCall(Callback, F.Value)
            if SaveNow and SaveKey ~= "" then Save.Set(SaveKey, F.Value) end
          end

          local DragSV, DragHue = false, false
          SV.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              DragSV = true
              s = math.clamp((input.Position.X - SV.AbsolutePosition.X) / math.max(SV.AbsoluteSize.X, 1), 0, 1)
              v = 1 - math.clamp((input.Position.Y - SV.AbsolutePosition.Y) / math.max(SV.AbsoluteSize.Y, 1), 0, 1)
              Render()
              Emit(false)
            end
          end)
          HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              DragHue = true
              SetHue(math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / math.max(HueBar.AbsoluteSize.Y, 1), 0, 1))
              Emit(false)
            end
          end)
          Bind(UserInputService.InputChanged, function(input)
            local t = input.UserInputType
            if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
            if DragSV then
              s = math.clamp((input.Position.X - SV.AbsolutePosition.X) / math.max(SV.AbsoluteSize.X, 1), 0, 1)
              v = 1 - math.clamp((input.Position.Y - SV.AbsolutePosition.Y) / math.max(SV.AbsoluteSize.Y, 1), 0, 1)
              Render()
              Emit(false)
            elseif DragHue then
              SetHue(math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / math.max(HueBar.AbsoluteSize.Y, 1), 0, 1))
              Emit(false)
            end
          end)
          Bind(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
              if DragSV or DragHue then Emit(true) end
              DragSV, DragHue = false, false
            end
          end)

          if type(Presets) == "table" then
            local PHolder = Custom:Create("Frame", {
              BackgroundTransparency = 1, BorderSizePixel = 0,
              Position = UDim2.new(0, 14, 0, 196), Size = UDim2.new(1, -28, 0, 24),
              ZIndex = Z.Popup + 1,
            }, Frame)
            Custom:Create("UIListLayout", {
              FillDirection = Enum.FillDirection.Horizontal,
              Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
            }, PHolder)
            for i, pc in ipairs(Presets) do
              if typeof(pc) == "Color3" then
                local PBtn = Custom:Create("TextButton", {
                  Text = "", BackgroundColor3 = pc, BorderSizePixel = 0,
                  Size = UDim2.fromOffset(22, 22), LayoutOrder = i, ZIndex = Z.Popup + 2,
                }, PHolder)
                Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, PBtn)
                Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1, Transparency = 0.4 }, PBtn)
                PBtn.Activated:Connect(function()
                  local ok, hh, ss, vv = pcall(Color3.toHSV, pc)
                  if ok and hh then
                    s, v = ss, vv
                    SetHue(hh)
                  end
                  Emit(true)
                end)
              end
            end
          end

          local function Close()
            if not Open then return end
            Open = false
            gui:Destroy()
          end
          CloseBtn.Activated:Connect(Close)
          Back.Activated:Connect(Close)

          Render()
        end

        Swatch.Activated:Connect(function()
          CircleClick(Swatch)
          PlaySound("Click")
          OpenPicker()
        end)

        function F:Set(c, Fire)
          if typeof(c) == "Color3" then
            F.Value = c
            Swatch.BackgroundColor3 = c
            if Fire ~= false then
              SafeCall(Callback, c)
              if SaveKey ~= "" then Save.Set(SaveKey, c) end
            end
          end
        end
        function F:Get() return F.Value end
        return F
      end

      -- ── Panel ──
      function Item:AddPanel(P)
        local Title = Get(P, 1, "Title", "")
        local Content = Get(P, 2, "Content", "")

        local Panel = Custom:Create("Frame", {
          Name = "Panel", BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.93, BorderSizePixel = 0,
          LayoutOrder = NextOrder(), Size = UDim2.new(1, 0, 0, 42), ZIndex = Z.Base,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, L.ItemRadius + 1) }, Panel)
        Themed(Panel, "BackgroundColor3", "Panel")

        local TitleL = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = tostring(Title), TextSize = 14,
          TextColor3 = CONFIG.Theme.Text,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1,
          BorderSizePixel = 0, Position = UDim2.new(0, L.ItemPadX, 0, 8),
          Size = UDim2.new(1, -20, 0, 14), ZIndex = Z.Content,
        }, Panel)
        Themed(TitleL, "TextColor3", "Text")

        local ContentL = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Regular, Text = tostring(Content), TextSize = 12,
          TextColor3 = CONFIG.Theme.SubText, TextWrapped = true,
          TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
          BorderSizePixel = 0, Position = UDim2.new(0, L.ItemPadX, 0, 24),
          Size = UDim2.new(1, -20, 0, 0), ZIndex = Z.Content,
        }, Panel)

        local List = Custom:Create("Frame", {
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, L.ItemPadX, 0, 28), Size = UDim2.new(1, -20, 0, 0),
          ZIndex = Z.Base,
        }, Panel)
        local ListLayout = Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
        }, List)

        local function Refit()
          local contentH = (Content ~= "" and ContentL.Text ~= "") and ContentL.AbsoluteSize.Y or 0
          List.Position = UDim2.new(0, L.ItemPadX, 0, 28 + contentH)
          Panel.Size = UDim2.new(1, 0, 0, 32 + contentH + ListLayout.AbsoluteContentSize.Y + 10)
        end
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Refit)
        ContentL:GetPropertyChangedSignal("AbsoluteSize"):Connect(Refit)
        task.defer(Refit)

        local PanelObj = {}
        local Count = 0
        local function NextOrderP()
          Count += 1
          return Count
        end

        function PanelObj:AddButton(B)
          local BTitle = Get(B, 1, "Title", "")
          local Callback = Get(B, 2, "Callback", function() end)
          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold, Text = tostring(BTitle), TextSize = 12,
            TextColor3 = CONFIG.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.8,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 28),
            LayoutOrder = NextOrderP(), ZIndex = Z.Content,
          }, List)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Btn)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 9) }, Btn)
          Btn.Activated:Connect(function()
            CircleClick(Btn)
            PlaySound("Click")
            SafeCall(Callback)
          end)
          return { Destroy = function() Btn:Destroy() end }
        end

        function PanelObj:AddToggle(T)
          local TTitle = Get(T, 1, "Title", "")
          local Default = Get(T, 2, "Default", false) == true
          local Callback = Get(T, 3, "Callback", function() end)
          local Obj = { Value = Default }
          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold, Text = tostring(TTitle), TextSize = 12,
            TextColor3 = CONFIG.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.8,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 28),
            LayoutOrder = NextOrderP(), ZIndex = Z.Content,
          }, List)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Btn)
          Custom:Create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 22) }, Btn)
          local Dot = Custom:Create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5), BorderSizePixel = 0,
            Position = UDim2.new(1, -9, 0.5, 0), Size = UDim2.fromOffset(8, 8),
            ZIndex = Z.Content + 1,
          }, Btn)
          Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Dot)
          local function Render()
            Dot.BackgroundColor3 = Obj.Value and CONFIG.Theme.Primary or CONFIG.Theme.Stroke
            Btn.TextColor3 = Obj.Value and CONFIG.Theme.Primary or CONFIG.Theme.Text
          end
          Btn.Activated:Connect(function()
            CircleClick(Btn)
            Obj.Value = not Obj.Value
            Render()
            PlaySound(Obj.Value and "ToggleOn" or "ToggleOff")
            SafeCall(Callback, Obj.Value)
          end)
          function Obj:Set(v, Fire)
            Obj.Value = v == true
            Render()
            if Fire ~= false then SafeCall(Callback, Obj.Value) end
          end
          Render()
          return Obj
        end

        function PanelObj:SetTitle(Text) TitleL.Text = tostring(Text) end
        function PanelObj:SetContent(Text) ContentL.Text = tostring(Text) end
        function PanelObj:SetVisible(State) Panel.Visible = State and true or false end
        function PanelObj:Destroy() Panel:Destroy() end
        return PanelObj
      end

      return Item
    end

    return Sections
  end

  local WindowObj = {
    CreateTab = function(_, ...) return Tabs:CreateTab(...) end,
    Show = ShowWindow,
    Hide = HideWindow,
    Toggle = function()
      if Holder.Visible then HideWindow() else ShowWindow() end
    end,
    SetToggleKey = function(_, Key)
      if typeof(Key) == "EnumItem" and Key.EnumType == Enum.KeyCode then
        ToggleKey = Key
        KeyHint.Text = "[" .. Key.Name .. "]"
      end
    end,
    Destroy = DestroyWindow,
  }
  return WindowObj
end

-- ─────────────── Library API ───────────────
function Speed_Library:Destroy()
  if Env.KingAkbarUI_Cleanup then pcall(Env.KingAkbarUI_Cleanup) end
  Speed_Library.Unloaded = true
end

function Speed_Library:SetTheme(t) Custom:SetTheme(t) end
function Speed_Library:SetFont(f) Custom:SetFont(f) end
function Speed_Library:GetConfig() return CONFIG end
function Speed_Library:SetSound(State) CONFIG.Behavior.SoundEnabled = State == true end

function Speed_Library:EnableSave(FileName)
  CONFIG.Behavior.SaveEnabled = true
  if FileName then CONFIG.Behavior.SaveFile = tostring(FileName) end
  Save.Load()
end

function Speed_Library:DisableSave() CONFIG.Behavior.SaveEnabled = false end
function Speed_Library:SetToggleKey(Key) CONFIG.Window.ToggleKey = Key end

return Speed_Library
