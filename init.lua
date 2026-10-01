--[[
  ╔══════════════════════════════════════════════════╗
  ║          KING AKBAR UI LIBRARY v1.5              ║
  ║    github.com/Akbar025zzz/kingAkbarUi-Speedhub   ║
  ╚══════════════════════════════════════════════════╝

  FITUR v1.5:
    ✔ Auto Save / Auto Load (toggle, slider, input, dropdown)
    ✔ Dynamic Dropdown Refresh
    ✔ Tab kotak profesional
    ✔ Anti-dup execute

  CONTOH:
    local Lib = loadstring(game:HttpGet("URL_RAW_FILE_INI"))()
    local Win = Lib:CreateWindow({ "King Akbar", "v1.5", 100, UDim2.fromOffset(420, 280) })
    local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
    local Sec = Tab:AddSection("Farm", true)

    Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print(v) end })
    Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print(v) end })

    -- Method manual:
    Lib:SetAutoSave(true)      -- default true
    Lib:SaveNow()              -- paksa save sekarang
    Lib:ClearSave()            -- hapus semua data tersimpan
    Lib:SetSaveFile("custom")  -- ganti nama file (harus sebelum CreateWindow)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
  Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
  Player = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════
--  CLEANUP EXECUTE ULANG
-- ═══════════════════════════════════════════════════
local Env = (getgenv and getgenv()) or _G

if type(Env.KingAkbarUI_Cleanup) == "function" then
  pcall(Env.KingAkbarUI_Cleanup)
end

local LibConnections = {}
local LibGuis        = {}

local function TrackLib(Conn)
  table.insert(LibConnections, Conn)
  return Conn
end

local function BindLib(Signal, Fn)
  return TrackLib(Signal:Connect(Fn))
end

Env.KingAkbarUI_Cleanup = function()
  for _, c in ipairs(LibConnections) do
    pcall(function() c:Disconnect() end)
  end
  for _, g in ipairs(LibGuis) do
    pcall(function() g:Destroy() end)
  end
  table.clear(LibConnections)
  table.clear(LibGuis)
end

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
--  AUTO SAVE MANAGER
-- ═══════════════════════════════════════════════════
local AutoSave = {}
AutoSave.Enabled     = true
AutoSave.Data        = {}
AutoSave.FileName    = nil
AutoSave.SaveFile    = nil       -- custom nama file (opsional)
AutoSave._pending    = 0
AutoSave._saveDelay  = 0.6

local function HasFileIO()
  return type(writefile) == "function"
     and type(readfile)  == "function"
     and type(isfile)    == "function"
end

function AutoSave:Init()
  if self.FileName then return end -- sudah pernah init

  local name
  if self.SaveFile then
    name = tostring(self.SaveFile)
    if not name:match("%.json$") then name = name .. ".json" end
  else
    name = "KingAkbarUI_" .. tostring(game.PlaceId) .. ".json"
  end
  self.FileName = name

  if HasFileIO() then
    if isfile(name) then
      local ok, content = pcall(readfile, name)
      if ok and content and content ~= "" then
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if ok2 and type(decoded) == "table" then
          self.Data = decoded
        end
      end
    end
  else
    -- fallback: simpan di memory getgenv (persist antar execute dalam 1 sesi)
    local env = (getgenv and getgenv()) or _G
    self.Data = env.__KingAkbarUI_SaveData or {}
  end
end

function AutoSave:Get(key)
  if key == nil then return nil end
  return self.Data[key]
end

function AutoSave:Set(key, value)
  if not self.Enabled or key == nil then return end
  self.Data[key] = value
  self:QueueSave()
end

function AutoSave:QueueSave()
  self._pending += 1
  local token = self._pending
  task.delay(self._saveDelay, function()
    if token == self._pending then
      self:Flush()
    end
  end)
end

function AutoSave:Flush()
  if not self.Enabled then return end
  if HasFileIO() then
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, self.Data)
    if ok and encoded then
      pcall(writefile, self.FileName, encoded)
    end
  else
    local env = (getgenv and getgenv()) or _G
    env.__KingAkbarUI_SaveData = self.Data
  end
end

function AutoSave:Clear()
  self.Data = {}
  self:Flush()
end

function AutoSave:SetFile(name)
  self.SaveFile = name
  self.FileName = nil
  self.Data = {}
  self:Init()
end

-- ═══════════════════════════════════════════════════
--  GLOBAL CONFIG
-- ═══════════════════════════════════════════════════
local CONFIG = {
  Theme = {
    Primary    = Color3.fromRGB(255, 255, 255),
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
  },
  Notification = {
    Width       = 320,
    Duration    = 5,
    AnimateTime = 0.5,
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
    AntiAFK = true,
  },
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
    return
  end
  TweenService:Create(Inst,
    TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Dir or Enum.EasingDirection.Out),
    Props):Play()
end

local function TextWidth(Text, Size, Font)
  local ok, bounds = pcall(function()
    return TextService:GetTextSize(Text, Size, Font, Vector2.new(1000, 100))
  end)
  if ok and bounds then return bounds.X end
  return #Text * Size * 0.55
end

local function ContrastColor(C)
  local lum = 0.299 * C.R + 0.587 * C.G + 0.114 * C.B
  return lum > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
end

-- key builder (namespace + judul + tipe)
local function MakeKey(...)
  return table.concat({ ... }, "|")
end

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

  function Custom:EnabledAFK()
    BindLib(Player.Idled, function()
      if not CONFIG.Behavior.AntiAFK then return end
      pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
      end)
    end)
  end

  function Custom:SetTheme(t)
    for k, v in pairs(t) do CONFIG.Theme[k] = v end
    Custom.ColorRGB = CONFIG.Theme.Primary
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
--  FLOATING BUTTON
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
      ZIndex = 10,
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
    ZIndex = 5,
  }, Parent)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Frame)

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
    ZIndex = 6,
  }, Frame)

  local ContentLabel = Custom:Create("TextLabel", {
    Name = "ItemContent",
    Font = CONFIG.Font.Bold, Text = tostring(Content), TextSize = 12,
    TextColor3 = CONFIG.Theme.Text, TextTransparency = 0.6,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0, 10, 0, 25),
    Size = UDim2.new(1, -Reserve, 0, 0),
    ZIndex = 6,
  }, Frame)

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
--  LIBRARY OBJECT
-- ═══════════════════════════════════════════════════
local Speed_Library = {}
Speed_Library.Unloaded = false

AutoSave:Init()  -- load save file

-- ─────────────────────── Notification ───────────────────────
local NotifGui, NotifHolder
local NotifCounter = 0

local function EnsureNotifHolder()
  if NotifGui and NotifGui.Parent and NotifHolder and NotifHolder.Parent then
    return NotifHolder
  end
  NotifGui = NewScreenGui("KingAkbarUI_Notification", 50)
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

function Speed_Library:SetNotification(Config)
  local Title       = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local Content     = tostring(Get(Config, 3, "Content", ""))
  local Time        = tonumber(Get(Config, 4, "Time", CONFIG.Notification.AnimateTime)) or 0.5
  local Delay       = tonumber(Get(Config, 5, "Delay", CONFIG.Notification.Duration)) or 5

  local Holder = EnsureNotifHolder()
  NotifCounter += 1

  local Container = Custom:Create("Frame", {
    Name = "Notification",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    LayoutOrder = NotifCounter,
    Size = UDim2.new(1, 0, 0, 65),
  }, Holder)

  local Card = Custom:Create("Frame", {
    BackgroundColor3 = CONFIG.Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(1, 40, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
  }, Container)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Card)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, Card)

  local TitleWidth = TextWidth(Title, 14, CONFIG.Font.Bold)

  local TitleLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(0, TitleWidth + 4, 0, 36),
  }, Card)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Text, Thickness = 0.3 }, TitleLabel)

  local DescLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, TitleWidth + 15, 0, 0),
    Size = UDim2.new(1, -(TitleWidth + 15 + 35), 0, 36),
  }, Card)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 0.4 }, DescLabel)

  local CloseBtn = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -5, 0, 5), Size = UDim2.fromOffset(25, 25),
  }, Card)

  local ContentLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Content, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 13, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0, 10, 0, 30),
    Size = UDim2.new(1, -20, 0, 0),
    Visible = Content ~= "",
  }, Card)

  local function Refit()
    if Content == "" then
      Container.Size = UDim2.new(1, 0, 0, 40)
    else
      Container.Size = UDim2.new(1, 0, 0, 30 + math.max(ContentLabel.AbsoluteSize.Y, 13) + 12)
    end
  end
  ContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(Refit)
  Refit()

  local Closed = false
  local Notification = {}

  function Notification:Close()
    if Closed then return end
    Closed = true
    Tween(Card, { Position = UDim2.new(1, 40, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(Time + 0.05, function()
      if Container then Container:Destroy() end
    end)
  end

  CloseBtn.Activated:Connect(function() Notification:Close() end)

  Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
  task.delay(Delay, function() Notification:Close() end)

  return Notification
end

function Speed_Library:Notify(Config) return Speed_Library:SetNotification(Config) end

-- ─────────────────────── CreateWindow ───────────────────────
function Speed_Library:CreateWindow(Config)
  local Title       = tostring(Get(Config, 1, "Title", ""))
  local Description = tostring(Get(Config, 2, "Description", ""))
  local TabWidth    = tonumber(Get(Config, 3, "Tab Width", Get(Config, 3, "TabWidth", CONFIG.Window.TabWidth))) or CONFIG.Window.TabWidth
  local SizeUi      = Get(Config, 4, "SizeUi", CONFIG.Window.Size)
  if typeof(SizeUi) ~= "UDim2" then SizeUi = CONFIG.Window.Size end

  local WindowNamespace = Title ~= "" and Title or "Window"

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
    ZIndex = 0,
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
    ZIndex = 1,
  }, DropShadowHolder)

  Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Main)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.6 }, Main)

  if CONFIG.Window.BackgroundImage ~= "" then
    local BgImage = Custom:Create("ImageLabel", {
      Name = "BackgroundImage",
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      Image = CONFIG.Window.BackgroundImage,
      ImageTransparency = CONFIG.Window.BackgroundTransparency,
      ScaleType = Enum.ScaleType.Crop,
      ZIndex = 0,
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
      ZIndex = 0,
    }, Main)
    Custom:Create("UICorner", {
      CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius),
    }, Tint)
  end

  local Top = Custom:Create("Frame", {
    Name = "Top",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 38),
    ZIndex = 5,
  }, Main)

  local TitleWidth = TextWidth(Title, 14, CONFIG.Font.Bold)

  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, TitleWidth + 4, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    ZIndex = 5,
  }, Top)

  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, -(TitleWidth + 15 + 80), 1, 0),
    Position = UDim2.new(0, TitleWidth + 15, 0, 0),
    ZIndex = 5,
  }, Top)

  local Close = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(25, 25),
    ZIndex = 6,
  }, Top)

  local Min = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "-", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -42, 0.5, 0), Size = UDim2.fromOffset(25, 25),
    ZIndex = 6,
  }, Top)

  Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, 38),
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = 5,
  }, Main)

  local LayersTab = Custom:Create("Frame", {
    Name = "LayersTab",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 9, 0, 50),
    Size = UDim2.new(0, TabWidth, 1, -59),
    ZIndex = 5,
  }, Main)

  local ScrollTab = Custom:Create("ScrollingFrame", {
    Name = "ScrollTab",
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 0, Active = true,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 5,
  }, LayersTab)

  Custom:Create("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
  }, ScrollTab)

  local Layers = Custom:Create("Frame", {
    Name = "Layers",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, TabWidth + 18, 0, 50),
    Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59),
    ZIndex = 5,
  }, Main)

  local NameTab = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
    TextSize = 24, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 30),
    ZIndex = 5,
  }, Layers)

  local LayersReal = Custom:Create("Frame", {
    Name = "Pages",
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ClipsDescendants = true,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 1, -33),
    ZIndex = 5,
  }, Layers)

  local Destroyed = false

  local function ShowWindow()
    DropShadowHolder.Visible = true
    Open_Close.Visible = false
  end

  local function HideWindow()
    DropShadowHolder.Visible = false
    Open_Close.Visible = true
  end

  local function DestroyWindow()
    if Destroyed then return end
    Destroyed = true
    AutoSave:Flush()  -- save sebelum destroy
    for _, c in ipairs(WindowConns) do
      pcall(function() c:Disconnect() end)
    end
    Open_Close.Visible = false
    WindowGui:Destroy()
    Speed_Library.Unloaded = true
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

  MakeDraggable(Top, DropShadowHolder, BindGlobal)

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
    ZIndex = 6,
  }, Layers)
  Custom:Create("UICorner", {}, MoreBlur)

  local ConnectButton = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 7,
  }, MoreBlur)

  local DropdownSelect = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = CONFIG.Theme.Secondary,
    BorderSizePixel = 0,
    Active = true,
    Position = UDim2.new(1, 172, 0.5, 0),
    Size = UDim2.new(0, 160, 1, -16),
    ClipsDescendants = true,
    ZIndex = 7,
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
    ZIndex = 8,
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

  local function SelectTab(Target, Instant)
    if CurrentTab == Target then return end
    CurrentTab = Target
    local t = Instant and 0 or 0.25
    for _, T in ipairs(AllTabs) do
      local sel = (T == Target)
      T.Page.Visible = sel

      Tween(T.Frame, {
        BackgroundTransparency = sel and 0.72 or 0.9,
        Size = sel and UDim2.new(1, 0, 0, 34) or UDim2.new(1, 0, 0, 32),
      }, t)

      Tween(T.Bar, {
        Size = sel and UDim2.new(0, 3, 0, 20) or UDim2.new(0, 0, 0, 20),
      }, t)

      Tween(T.Stroke, {
        Color = sel and CONFIG.Theme.Primary or CONFIG.Theme.Stroke,
        Transparency = sel and 0.35 or 0.85,
      }, t)

      if T.Icon then
        Tween(T.Icon, {
          ImageColor3 = sel and CONFIG.Theme.Primary or CONFIG.Theme.Text,
        }, t)
      end
      if T.Label then
        Tween(T.Label, {
          TextColor3 = sel and CONFIG.Theme.Primary or CONFIG.Theme.Text,
        }, t)
      end
    end
    NameTab.Text = Target.Name
  end

  function Tabs:CreateTab(TabConfig)
    local _Name = tostring(Get(TabConfig, 1, "Name", ""))
    local Icon  = Get(TabConfig, 2, "Icon", "")
    if type(Icon) ~= "string" then Icon = "" end

    local TabNamespace = MakeKey(WindowNamespace, _Name)
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
      ZIndex = 5,
    }, LayersReal)

    Custom:Create("UIListLayout", {
      Padding = UDim.new(0, 3),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, ScrolLayers)

    local Tab = Custom:Create("Frame", {
      Name = "Tab",
      BackgroundColor3 = Color3.fromRGB(30, 30, 30),
      BackgroundTransparency = 0.9,
      BorderSizePixel = 0,
      LayoutOrder = TabIndex,
      Size = UDim2.new(1, 0, 0, 32),
      ClipsDescendants = false,
      ZIndex = 5,
    }, ScrollTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Tab)

    local TabStroke = Custom:Create("UIStroke", {
      Color = CONFIG.Theme.Stroke,
      Thickness = 1,
      Transparency = 0.85,
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, Tab)

    local TabButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Regular, Text = "",
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 7,
    }, Tab)

    local TabIcon = nil
    if Icon ~= "" then
      TabIcon = Custom:Create("ImageLabel", {
        Name = "TabIcon",
        Image = Icon,
        ImageColor3 = CONFIG.Theme.Text,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 8),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 6,
      }, Tab)
    end

    local TabLabel = Custom:Create("TextLabel", {
      Name = "TabLabel",
      Font = CONFIG.Font.Bold, Text = _Name, TextColor3 = CONFIG.Theme.Text,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, Icon ~= "" and -34 or -14, 1, 0),
      Position = UDim2.new(0, Icon ~= "" and 34 or 12, 0, 0),
      ZIndex = 6,
    }, Tab)

    local Bar = Custom:Create("Frame", {
      Name = "ChooseFrame",
      AnchorPoint = Vector2.new(0, 0.5),
      BackgroundColor3 = CONFIG.Theme.Primary,
      BorderSizePixel = 0,
      Position = UDim2.new(0, 3, 0.5, 0),
      Size = UDim2.new(0, 0, 0, 20),
      ZIndex = 6,
    }, Tab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Bar)

    local BarStroke = Custom:Create("UIStroke", {
      Color = CONFIG.Theme.Primary, Thickness = 1.6, Transparency = 1,
    }, Bar)

    local TabObj = {
      Name   = _Name,
      Frame  = Tab,
      Page   = ScrolLayers,
      Bar    = Bar,
      Stroke = TabStroke,
      Icon   = TabIcon,
      Label  = TabLabel,
    }
    table.insert(AllTabs, TabObj)

    if TabIndex == 1 then
      SelectTab(TabObj, true)
    end

    TabButton.Activated:Connect(function()
      CircleClick(TabButton)
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
      local SectionNamespace = MakeKey(TabNamespace, SectionTitle)

      local OpenSection = OpenDefault == true
      CountSection += 1

      local Section = Custom:Create("Frame", {
        Name = "Section",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = CountSection,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 5,
      }, ScrolLayers)

      local SectionReal = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = CONFIG.Theme.Panel,
        BackgroundTransparency = 0.935, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 5,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SectionReal)

      local SectionButton = Custom:Create("TextButton", {
        Font = CONFIG.Font.Regular, Text = "",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 7,
      }, SectionReal)

      local FeatureFrame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 6,
      }, SectionReal)

      Custom:Create("ImageLabel", {
        Image = CONFIG.Assets.ArrowIcon,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = -90, Size = UDim2.new(1, 6, 1, 6),
        ZIndex = 6,
      }, FeatureFrame)

      Custom:Create("TextLabel", {
        Font = CONFIG.Font.Bold, Text = SectionTitle,
        TextColor3 = CONFIG.Theme.Text, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(1, -50, 0, 13),
        ZIndex = 6,
      }, SectionReal)

      local SectionDecideFrame = Custom:Create("Frame", {
        BackgroundColor3 = CONFIG.Theme.Panel, BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 33),
        Size = UDim2.new(0, 0, 0, 2),
        ZIndex = 5,
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
        ZIndex = 5,
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

      -- helper: bikin key unik untuk save
      local function ItemKey(ItemTitle, ItemType, CustomFlag)
        if CustomFlag and type(CustomFlag) == "string" and CustomFlag ~= "" then
          return MakeKey(WindowNamespace, "FLAG", CustomFlag)
        end
        return MakeKey(SectionNamespace, ItemType, ItemTitle)
      end

      function Item:AddParagraph(PConfig)
        local PTitle   = Get(PConfig, 1, "Title", "")
        local PContent = Get(PConfig, 2, "Content", "")
        local Base = NewItemBase(SectionAdd, NextOrder(), PTitle, PContent, 16)
        local Funcs = {}
        AttachCommon(Funcs, Base)

        function Funcs:Set(SConfig)
          Base.Title.Text = tostring(Get(SConfig, 1, "Title", Base.Title.Text))
          Base.Content.Text = tostring(Get(SConfig, 2, "Content", Base.Content.Text))
        end

        return Funcs
      end

      function Item:AddSeperator(SConfig)
        local STitle = tostring(Get(SConfig, 1, "Title", ""))
        local Funcs = {}

        local Seperator = Custom:Create("Frame", {
          Name = "Seperator",
          BackgroundColor3 = CONFIG.Theme.Divider,
          BackgroundTransparency = 0.1, BorderSizePixel = 0,
          LayoutOrder = NextOrder(),
          Size = UDim2.new(1, 0, 0, 30),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Seperator)

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
          ZIndex = 6,
        }, Seperator)

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
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Line)
        function Funcs:Destroy() Line:Destroy() end
        return Funcs
      end

      function Item:AddButton(BConfig)
        local BTitle   = Get(BConfig, 1, "Title", "")
        local BContent = Get(BConfig, 2, "Content", "")
        local Icon     = Get(BConfig, 3, "Icon", CONFIG.Assets.DefaultIcon)
        local Callback = Get(BConfig, 4, "Callback", function() end)
        local Funcs = {}

        local Base = NewItemBase(SectionAdd, NextOrder(), BTitle, BContent, 70)
        AttachCommon(Funcs, Base)

        local ButtonButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, Base.Frame)

        if type(Icon) == "string" and Icon ~= "" then
          Custom:Create("ImageLabel", {
            Image = Icon,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(1, -15, 0.5, 0),
            Size = UDim2.fromOffset(25, 25),
            ZIndex = 6,
          }, Base.Frame)
        end

        ButtonButton.Activated:Connect(function()
          CircleClick(ButtonButton)
          SafeCall(Callback)
        end)

        function Funcs:Set(NConfig)
          if Get(NConfig, 1, "Title", nil) ~= nil then Funcs:SetTitle(Get(NConfig, 1, "Title", "")) end
          if Get(NConfig, 2, "Content", nil) ~= nil then Funcs:SetContent(Get(NConfig, 2, "Content", "")) end
        end

        return Funcs
      end

      -- ═══════ Toggle (dengan AutoSave) ═══════
      function Item:AddToggle(TConfig)
        local TTitle   = Get(TConfig, 1, "Title", "")
        local TContent = Get(TConfig, 2, "Content", "")
        local Default  = Get(TConfig, 3, "Default", false)
        local Callback = Get(TConfig, 4, "Callback", function() end)
        local Flag     = Get(TConfig, 5, "Flag", nil)

        local key = ItemKey(TTitle, "Toggle", Flag)
        local Saved = AutoSave:Get(key)
        local Initial = (Saved ~= nil) and (Saved == true) or (Default == true)

        local Funcs = { Value = Initial }
        local IsInitial = true

        local Base = NewItemBase(SectionAdd, NextOrder(), TTitle, TContent, 70)
        AttachCommon(Funcs, Base)
        local Toggle = Base.Frame

        local ToggleButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, Toggle)

        local FeatureFrame2 = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.92, BorderSizePixel = 0,
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.fromOffset(30, 15),
          ZIndex = 6,
        }, Toggle)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, FeatureFrame2)

        local UIStroke8 = Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Text, Thickness = 2, Transparency = 0.9,
        }, FeatureFrame2)

        local ToggleCircle = Custom:Create("Frame", {
          BackgroundColor3 = ContrastColor(CONFIG.Theme.Primary),
          BorderSizePixel = 0,
          Size = UDim2.fromOffset(14, 14),
          Position = UDim2.new(0, 0, 0, 0),
          ZIndex = 7,
        }, FeatureFrame2)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 15) }, ToggleCircle)

        local function ToggleAnimation(isOn)
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
          Tween(FeatureFrame2, {
            BackgroundColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Panel,
            BackgroundTransparency = isOn and 0 or 0.92,
          }, 0.2)
        end

        function Funcs:Set(Value, Silent)
          Funcs.Value = Value == true
          ToggleAnimation(Funcs.Value)
          if not IsInitial then
            AutoSave:Set(key, Funcs.Value)
          end
          if not Silent then
            SafeCall(Callback, Funcs.Value)
          end
        end

        ToggleButton.Activated:Connect(function()
          CircleClick(ToggleButton)
          Funcs:Set(not Funcs.Value)
        end)

        Funcs:Set(Funcs.Value)
        IsInitial = false
        return Funcs
      end

      -- ═══════ Slider (dengan AutoSave) ═══════
      function Item:AddSlider(SConfig)
        local STitle    = Get(SConfig, 1, "Title", "")
        local SContent  = Get(SConfig, 2, "Content", "")
        local Increment = tonumber(Get(SConfig, 3, "Increment", 1)) or 1
        local Min       = tonumber(Get(SConfig, 4, "Min", 0)) or 0
        local Max       = tonumber(Get(SConfig, 5, "Max", 100)) or 100
        local Default   = tonumber(Get(SConfig, 6, "Default", Min)) or Min
        local Callback  = Get(SConfig, 7, "Callback", function() end)
        local Flag      = Get(SConfig, 8, "Flag", nil)

        if Increment <= 0 then Increment = 1 end
        if Max <= Min then Max = Min + 1 end

        local key = ItemKey(STitle, "Slider", Flag)
        local Saved = tonumber(AutoSave:Get(key))
        local Initial = Saved or Default

        local Funcs = { Value = Initial, Min = Min, Max = Max, Increment = Increment }
        local IsInitial = true

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

        local Base = NewItemBase(SectionAdd, NextOrder(), STitle, SContent, 190)
        AttachCommon(Funcs, Base)
        local Slider = Base.Frame

        local SliderInput = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(1, -165, 0.5, 0),
          Size = UDim2.fromOffset(38, 20),
          ZIndex = 6,
        }, Slider)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, SliderInput)

        local TextBox = Custom:Create("TextBox", {
          Font = CONFIG.Font.Bold, Text = tostring(Default),
          TextColor3 = ContrastColor(CONFIG.Theme.Primary),
          TextSize = 12, ClearTextOnFocus = false,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, SliderInput)

        local SliderFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.8, BorderSizePixel = 0,
          Position = UDim2.new(1, -20, 0.5, 0),
          Size = UDim2.fromOffset(100, 3),
          ZIndex = 6,
        }, Slider)
        Custom:Create("UICorner", {}, SliderFrame)

        local SliderFill = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(0, 0, 0.5, 0),
          Size = UDim2.new(0, 0, 1, 0),
          ZIndex = 7,
        }, SliderFrame)
        Custom:Create("UICorner", {}, SliderFill)

        local SliderCircle = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0.5, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(1, 0, 0.5, 0),
          Size = UDim2.fromOffset(10, 10),
          ZIndex = 8,
        }, SliderFill)
        Custom:Create("UICorner", {}, SliderCircle)
        Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary }, SliderCircle)

        local SliderHit = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, -12, 0.5, 0),
          Size = UDim2.fromOffset(116, 26),
          ZIndex = 9,
        }, Slider)

        local Dragging = false

        function Funcs:Set(Value, Fire)
          Value = Snap(tonumber(Value) or Funcs.Value)
          Funcs.Value = Value
          TextBox.Text = tostring(Value)
          SliderFill.Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)
          if not IsInitial then
            AutoSave:Set(key, Value)
          end
          if Fire then SafeCall(Callback, Value) end
        end

        local function UpdateFromX(x)
          local w = SliderFrame.AbsoluteSize.X
          if w <= 0 then return end
          local scale = math.clamp((x - SliderFrame.AbsolutePosition.X) / w, 0, 1)
          Funcs:Set(Min + (Max - Min) * scale, false)
        end

        SliderHit.InputBegan:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            ScrolLayers.ScrollingEnabled = false
            UpdateFromX(Input.Position.X)
          end
        end)

        BindGlobal(UserInputService.InputChanged, function(Input)
          if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromX(Input.Position.X)
          end
        end)

        BindGlobal(UserInputService.InputEnded, function(Input)
          if Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = false
            ScrolLayers.ScrollingEnabled = true
            AutoSave:Set(key, Funcs.Value)
            SafeCall(Callback, Funcs.Value)
          end
        end)

        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
          local cleaned = TextBox.Text:gsub("[^%d%.%-]", "")
          if cleaned ~= TextBox.Text then TextBox.Text = cleaned end
        end)

        TextBox.FocusLost:Connect(function()
          local n = tonumber(TextBox.Text)
          if n then
            Funcs:Set(n, true)
          else
            TextBox.Text = tostring(Funcs.Value)
          end
        end)

        Funcs:Set(Initial, false)
        IsInitial = false
        SafeCall(Callback, Initial)
        return Funcs
      end

      -- ═══════ Input (dengan AutoSave) ═══════
      function Item:AddInput(IConfig)
        local ITitle   = Get(IConfig, 1, "Title", "")
        local IContent = Get(IConfig, 2, "Content", "")
        local Default  = tostring(Get(IConfig, 3, "Default", ""))
        local Callback = Get(IConfig, 4, "Callback", function() end)
        local Flag     = Get(IConfig, 5, "Flag", nil)

        local key = ItemKey(ITitle, "Input", Flag)
        local Saved = AutoSave:Get(key)
        local Initial = (Saved ~= nil) and tostring(Saved) or Default

        local Funcs = { Value = Initial }
        local IsInitial = true

        local Base = NewItemBase(SectionAdd, NextOrder(), ITitle, IContent, 180)
        AttachCommon(Funcs, Base)

        local InputFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.9, BorderSizePixel = 0,
          ClipsDescendants = true,
          Position = UDim2.new(1, -7, 0.5, 0),
          Size = UDim2.fromOffset(148, 30),
          ZIndex = 6,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, InputFrame)

        local InputTextBox = Custom:Create("TextBox", {
          Font = CONFIG.Font.Bold,
          PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
          PlaceholderText = "Write here...",
          Text = "", TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          ClearTextOnFocus = false,
          TextXAlignment = Enum.TextXAlignment.Left,
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 5, 0.5, 0),
          Size = UDim2.new(1, -10, 1, -8),
          ZIndex = 7,
        }, InputFrame)

        function Funcs:Set(Value)
          Value = tostring(Value or "")
          InputTextBox.Text = Value
          Funcs.Value = Value
          if not IsInitial then
            AutoSave:Set(key, Value)
          end
          SafeCall(Callback, Value)
        end

        InputTextBox.FocusLost:Connect(function()
          Funcs:Set(InputTextBox.Text)
        end)

        Funcs:Set(Initial)
        IsInitial = false
        return Funcs
      end

      -- ═══════ Dropdown (dengan AutoSave) ═══════
      function Item:AddDropdown(DConfig)
        local DTitle   = Get(DConfig, 1, "Title", "")
        local DContent = Get(DConfig, 2, "Content", "")
        local Multi    = Get(DConfig, 3, "Multi", false) == true
        local Options  = Get(DConfig, 4, "Options", {})
        local Default  = Get(DConfig, 5, "Default", {})
        local Callback = Get(DConfig, 6, "Callback", function() end)
        local Flag     = Get(DConfig, 7, "Flag", nil)

        if type(Options) ~= "table" then Options = {} end
        if type(Default) == "string" and Default ~= "" then
          Default = { Default }
        elseif type(Default) ~= "table" then
          Default = {}
        end

        local key = ItemKey(DTitle, "Dropdown", Flag)
        local SavedRaw = AutoSave:Get(key)
        local Saved = nil
        if type(SavedRaw) == "table" then
          Saved = {}
          for _, v in ipairs(SavedRaw) do
            if type(v) == "string" then table.insert(Saved, v) end
          end
        end

        local Funcs = { Value = {}, Options = {} }
        local IsInitial = true

        local Base = NewItemBase(SectionAdd, NextOrder(), DTitle, DContent, 180)
        AttachCommon(Funcs, Base)
        local Dropdown = Base.Frame

        local SelectOptionsFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.9, BorderSizePixel = 0,
          Position = UDim2.new(1, -7, 0.5, 0),
          Size = UDim2.fromOffset(148, 30),
          ZIndex = 6,
        }, Dropdown)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SelectOptionsFrame)

        local OptionSelecting = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = "Select Options",
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.2, TextWrapped = false,
          TextTruncate = Enum.TextTruncate.AtEnd,
          TextXAlignment = Enum.TextXAlignment.Left,
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 6, 0.5, 0),
          Size = UDim2.new(1, -32, 1, -8),
          ZIndex = 7,
        }, SelectOptionsFrame)

        Custom:Create("ImageLabel", {
          Image = CONFIG.Assets.DropdownArrow,
          ImageColor3 = CONFIG.Theme.Text,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, 0, 0.5, 0),
          Size = UDim2.fromOffset(25, 25),
          ZIndex = 7,
        }, SelectOptionsFrame)

        local ScrollSelect = Custom:Create("ScrollingFrame", {
          Name = "DropdownPage",
          CanvasSize = UDim2.new(0, 0, 0, 0),
          AutomaticCanvasSize = Enum.AutomaticSize.Y,
          ScrollingDirection = Enum.ScrollingDirection.Y,
          ScrollBarThickness = 0, Active = true,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          Visible = false,
          ZIndex = 8,
        }, DropdownSelectReal)

        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 3),
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, ScrollSelect)

        local SearchBar = Custom:Create("TextBox", {
          Name = "SearchBar",
          Font = CONFIG.Font.Bold, PlaceholderText = "Search",
          PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
          Text = "", TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          ClearTextOnFocus = false,
          BackgroundColor3 = CONFIG.Theme.Background,
          BackgroundTransparency = 0.3,
          BorderColor3 = CONFIG.Theme.Stroke, BorderSizePixel = 1,
          LayoutOrder = -1,
          Size = UDim2.new(1, 0, 0, 22),
          ZIndex = 8,
        }, ScrollSelect)

        SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
          local SearchText = string.lower(SearchBar.Text)
          for _, v in ipairs(ScrollSelect:GetChildren()) do
            if v:IsA("Frame") and v.Name == "Option" then
              local OptionText = v:FindFirstChild("OptionText")
              if OptionText then
                v.Visible = string.find(string.lower(OptionText.Text), SearchText, 1, true) ~= nil
              end
            end
          end
        end)

        local DropCount = 0

        local DropdownButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 9,
        }, Dropdown)

        DropdownButton.Activated:Connect(function()
          OpenDropdownPanel(ScrollSelect)
        end)

        local PlaceholderText = "Select Options"

        function Funcs:Clear()
          for _, c in ipairs(ScrollSelect:GetChildren()) do
            if c.Name == "Option" then c:Destroy() end
          end
          Funcs.Value = {}
          Funcs.Options = {}
          DropCount = 0
          OptionSelecting.Text = PlaceholderText
        end

        function Funcs:SetPlaceholder(Text)
          PlaceholderText = tostring(Text or "Select Options")
          if #Funcs.Value == 0 then
            OptionSelecting.Text = PlaceholderText
          end
        end

        function Funcs:GetOptions() return table.clone(Funcs.Options) end
        function Funcs:GetValue()   return table.clone(Funcs.Value)   end

        function Funcs:Set(Value, NoCallback)
          if Value == nil then Value = Funcs.Value end
          if type(Value) == "string" then Value = { Value } end
          if type(Value) ~= "table" then Value = {} end

          local newVal = {}
          for _, v in ipairs(Value) do
            if not table.find(newVal, v) then table.insert(newVal, v) end
          end
          if not Multi and #newVal > 1 then newVal = { newVal[1] } end
          Funcs.Value = newVal

          for _, Opt in ipairs(ScrollSelect:GetChildren()) do
            if Opt.Name == "Option" then
              local OptText = Opt:FindFirstChild("OptionText")
              local ChooseFrame = Opt:FindFirstChild("ChooseFrame")
              if OptText and ChooseFrame then
                local isSel = table.find(newVal, OptText.Text) ~= nil
                Tween(ChooseFrame, { Size = isSel and UDim2.fromOffset(2, 12) or UDim2.fromOffset(0, 0) }, 0.2)
                Tween(ChooseFrame.UIStroke, { Transparency = isSel and 0 or 1 }, 0.2)
                Tween(Opt, { BackgroundTransparency = isSel and 0.88 or 0.999 }, 0.2)
              end
            end
          end

          local Text = table.concat(newVal, ", ")
          OptionSelecting.Text = Text ~= "" and Text or PlaceholderText

          if not IsInitial then
            AutoSave:Set(key, Funcs.Value)
          end
          if not NoCallback then SafeCall(Callback, Funcs.Value) end
        end

        function Funcs:AddOption(OptionName)
          OptionName = tostring(OptionName or "Option")
          if table.find(Funcs.Options, OptionName) then return end
          table.insert(Funcs.Options, OptionName)

          local Option = Custom:Create("Frame", {
            Name = "Option",
            BackgroundColor3 = CONFIG.Theme.Panel,
            BackgroundTransparency = 0.999, BorderSizePixel = 0,
            LayoutOrder = DropCount,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 8,
          }, ScrollSelect)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Option)

          local OptionButton = Custom:Create("TextButton", {
            Font = CONFIG.Font.Regular, Text = "",
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10,
          }, Option)

          Custom:Create("TextLabel", {
            Name = "OptionText",
            Font = CONFIG.Font.Bold, Text = OptionName,
            TextSize = 13, TextColor3 = CONFIG.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -16, 1, 0),
            ZIndex = 9,
          }, Option)

          local ChooseFrame = Custom:Create("Frame", {
            Name = "ChooseFrame",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(0, 0),
            ZIndex = 9,
          }, Option)
          Custom:Create("UIStroke", {
            Color = CONFIG.Theme.Primary, Thickness = 1.2, Transparency = 1,
          }, ChooseFrame)
          Custom:Create("UICorner", {}, ChooseFrame)

          OptionButton.Activated:Connect(function()
            CircleClick(OptionButton)
            local cur = table.clone(Funcs.Value)
            if Multi then
              local idx = table.find(cur, OptionName)
              if idx then table.remove(cur, idx) else table.insert(cur, OptionName) end
            else
              cur = { OptionName }
            end
            Funcs:Set(cur)
            if not Multi then CloseDropdownPanel() end
          end)

          DropCount += 1
        end

        function Funcs:Refresh(NewList, Selecting, Opts)
          NewList = type(NewList) == "table" and NewList or {}
          Opts    = type(Opts) == "table" and Opts or {}

          if Selecting == nil and Opts.KeepSelection then
            Selecting = {}
            for _, v in ipairs(Funcs.Value) do
              if table.find(NewList, v) then table.insert(Selecting, v) end
            end
          end
          Selecting = Selecting or {}

          Funcs:Clear()
          for _, Drop in ipairs(NewList) do
            Funcs:AddOption(Drop)
          end
          Funcs:Set(Selecting, Opts.NoCallback == true)
        end

        function Funcs:SetOptions(NewList, Selecting, Opts)
          return Funcs:Refresh(NewList, Selecting, Opts)
        end

        -- pilih initial: saved dulu, kalau ngga ada pakai default
        local InitialSelect = Saved or Default
        Funcs:Refresh(Options, InitialSelect)
        IsInitial = false
        return Funcs
      end

      -- ═══════ AddPanel ═══════
      function Item:AddPanel(PConfig)
        local PTitle   = Get(PConfig, 1, "Title", "")
        local PContent = Get(PConfig, 2, "Content", "")
        local PanelNamespace = MakeKey(SectionNamespace, "Panel", PTitle)
        local Funcs_Panel = {}

        local Base = NewItemBase(SectionAdd, NextOrder(), PTitle, PContent, 50)
        AttachCommon(Funcs_Panel, Base)
        local Panel = Base.Frame
        Panel.ClipsDescendants = true

        local HeaderH = Base.Height
        local isOpen = false

        local PanelHeader = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 0, HeaderH),
          ZIndex = 7,
        }, Panel)

        local Arrow = Custom:Create("ImageLabel", {
          Image = CONFIG.Assets.DropdownArrow,
          ImageColor3 = CONFIG.Theme.Text,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, -10, 0, HeaderH / 2),
          Size = UDim2.fromOffset(20, 20),
          ZIndex = 8,
        }, Panel)

        local PanelBody = Custom:Create("Frame", {
          Name = "PanelBody",
          AnchorPoint = Vector2.new(0.5, 0),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0.5, 0, 0, HeaderH + 4),
          Size = UDim2.new(1, 0, 0, 0),
          ZIndex = 6,
        }, Panel)
        local BodyList = Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 3),
          HorizontalAlignment = Enum.HorizontalAlignment.Center,
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, PanelBody)

        local function Relayout(Animate)
          local t = Animate and 0.2 or 0
          local bodyH = BodyList.AbsoluteContentSize.Y
          PanelHeader.Size = UDim2.new(1, 0, 0, HeaderH)
          Arrow.Position = UDim2.new(1, -10, 0, HeaderH / 2)
          PanelBody.Position = UDim2.new(0.5, 0, 0, HeaderH + 4)
          PanelBody.Size = UDim2.new(1, 0, 0, bodyH)
          Tween(Panel, {
            Size = UDim2.new(1, 0, 0, isOpen and (HeaderH + 4 + bodyH + 6) or HeaderH),
          }, t)
        end

        Base.Apply = function(h)
          HeaderH = h
          Relayout(false)
        end
        Relayout(false)

        BodyList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
          Relayout(false)
        end)

        PanelHeader.Activated:Connect(function()
          CircleClick(PanelHeader)
          isOpen = not isOpen
          Tween(Arrow, { Rotation = isOpen and 180 or 0 }, 0.2)
          Relayout(true)
        end)

        local SubCount = 0

        function Funcs_Panel:AddButton(cfg)
          local t  = tostring(Get(cfg, 1, "Title", ""))
          local cb = Get(cfg, 2, "Callback", function() end)
          SubCount += 1

          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = "  " .. t,
            TextColor3 = CONFIG.Theme.Text, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CONFIG.Theme.Secondary,
            BackgroundTransparency = 0.3, BorderSizePixel = 0,
            LayoutOrder = SubCount,
            Size = UDim2.new(1, -10, 0, 28),
            ZIndex = 7,
          }, PanelBody)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Btn)

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            SafeCall(cb)
          end)
        end

        function Funcs_Panel:AddToggle(cfg)
          local t   = tostring(Get(cfg, 1, "Title", ""))
          local def = Get(cfg, 2, "Default", false) == true
          local cb  = Get(cfg, 3, "Callback", function() end)

          local key = MakeKey(PanelNamespace, "Toggle", t)
          local Saved = AutoSave:Get(key)
          local Initial = (Saved ~= nil) and (Saved == true) or def

          local state = { Value = Initial }
          local IsInitial = true
          SubCount += 1

          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = "",
            TextSize = 12,
            TextColor3 = CONFIG.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CONFIG.Theme.Secondary,
            BackgroundTransparency = 0.3, BorderSizePixel = 0,
            LayoutOrder = SubCount,
            Size = UDim2.new(1, -10, 0, 28),
            ZIndex = 7,
          }, PanelBody)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Btn)

          function state:Set(Value)
            state.Value = Value == true
            Btn.Text = "  " .. t .. "   [" .. (state.Value and "ON" or "OFF") .. "]"
            Btn.TextColor3 = state.Value and CONFIG.Theme.Primary or CONFIG.Theme.Text
            if not IsInitial then
              AutoSave:Set(key, state.Value)
            end
            SafeCall(cb, state.Value)
          end

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            state:Set(not state.Value)
          end)

          state:Set(Initial)
          IsInitial = false
          return state
        end

        return Funcs_Panel
      end

      return Item
    end

    return Sections
  end

  function Tabs:Show() ShowWindow() end
  function Tabs:Hide() HideWindow() end
  function Tabs:Toggle()
    if DropShadowHolder.Visible then HideWindow() else ShowWindow() end
  end
  function Tabs:Destroy() DestroyWindow() end

  return Tabs
end

-- ═══════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════
function Speed_Library:SetTheme(t) Custom:SetTheme(t) end
function Speed_Library:SetFont(f)  Custom:SetFont(f)  end
function Speed_Library:GetConfig() return Custom:GetConfig() end

-- API Auto Save
function Speed_Library:SetAutoSave(bool)
  AutoSave.Enabled = bool == true
  if AutoSave.Enabled then AutoSave:Flush() end
end

function Speed_Library:SaveNow()
  AutoSave:Flush()
end

function Speed_Library:ClearSave()
  AutoSave:Clear()
end

function Speed_Library:SetSaveFile(name)
  AutoSave:SetFile(name)
end

function Speed_Library:GetSaveData()
  return AutoSave.Data
end

function Speed_Library:Destroy()
  AutoSave:Flush()
  if Env.KingAkbarUI_Cleanup then Env.KingAkbarUI_Cleanup() end
  Speed_Library.Unloaded = true
end

return Speed_Library
