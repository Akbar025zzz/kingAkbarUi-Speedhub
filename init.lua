--[[
  ╔══════════════════════════════════════════════════╗
  ║          KING AKBAR UI LIBRARY v1.5             ║
  ║    github.com/Akbar025zzz/kingAkbarUi-Speedhub   ║
  ╚══════════════════════════════════════════════════╝

  CONTOH PEMAKAIAN:
    local Lib = loadstring(game:HttpGet("URL_RAW_FILE_INI"))()
    local Win = Lib:CreateWindow({ "King Akbar", "v1.3", 100, UDim2.fromOffset(420, 280) })
    local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
    local Sec = Tab:AddSection("Farm", true)
    Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) print(v) end })
    Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) print(v) end })
    Sec:AddDropdown({ "Mode", "", false, { "A", "B" }, { "A" }, function(v) print(v[1]) end })
    Lib:SetNotification({ "King Akbar", "Loaded", "Script berhasil dimuat" })
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")
local TextService      = game:GetService("TextService")
local CoreGui          = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then
  Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
  Player = Players.LocalPlayer
end

-- ═══════════════════════════════════════════════════
--  CLEANUP EXECUTE ULANG (hindari UI dobel)
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

-- Bersihkan sisa UI dari versi lama (v1.2 dst) yang tidak terlacak
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
    -- Size sengaja kosong: otomatis menyesuaikan layar (isi UDim2 bila ingin ukuran tetap)
    TabWidth               = 112,
    TopbarHeight           = 44,
    CornerRadius           = 10,
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
-- Ambil argumen dari format array ({a, b, c}) ATAU named ({Title = a}).
-- Aman untuk nilai false (tidak ketimpa default).
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

-- Panggil callback user tanpa merusak script kalau callback error
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

-- warna teks/knob yang kontras terhadap warna latar (agar semua tema terbaca)
local function ContrastColor(C)
  local lum = 0.299 * C.R + 0.587 * C.G + 0.114 * C.B
  return lum > 0.6 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
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
    -- selalu connect; cek config saat event terjadi (supaya AntiAFK = false dari GetConfig() berfungsi)
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
--  SCREENGUI FACTORY (aman di executor & Studio)
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
--  DRAGGABLE (drag lancar walau kursor keluar dari handle)
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

  -- fungsi untuk cek apakah tadi benar-benar di-drag (bukan klik)
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
--  RIPPLE CLICK (tanpa asset, pakai Frame bulat)
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
--  ITEM BASE (judul + deskripsi auto-tinggi)
-- ═══════════════════════════════════════════════════
local function NewItemBase(Parent, Order, Title, Content, Reserve)
  local Base = {}

  local Frame = Custom:Create("Frame", {
    Name = "Item",
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.935, BorderSizePixel = 0,
    LayoutOrder = Order,
    Size = UDim2.new(1, 0, 0, 40),
    ZIndex = 5,
  }, Parent)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Frame)

  local TitleLabel = Custom:Create("TextLabel", {
    Name = "ItemTitle",
    Font = CONFIG.Font.Bold, Text = tostring(Title), TextSize = 13,
    TextColor3 = CONFIG.Theme.Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 12, 0, 7),
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
    Position = UDim2.new(0, 12, 0, 21),
    Size = UDim2.new(1, -Reserve, 0, 0),
    ZIndex = 6,
  }, Frame)

  Base.Frame   = Frame
  Base.Title   = TitleLabel
  Base.Content = ContentLabel
  Base.Height  = 40
  Base.Apply   = nil

  function Base.Refit()
    local hasContent = ContentLabel.Text ~= ""
    ContentLabel.Visible = hasContent
    local h
    if hasContent then
      TitleLabel.AnchorPoint = Vector2.new(0, 0)
      TitleLabel.Position = UDim2.new(0, 12, 0, 7)
      h = math.max(40, 21 + math.max(ContentLabel.AbsoluteSize.Y, 12) + 8)
    else
      TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
      TitleLabel.Position = UDim2.new(0, 12, 0.5, 0)
      h = 40
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

-- fungsi umum yang ditempel ke semua item
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
  local Time        = tonumber(Get(Config, 5, "Time", CONFIG.Notification.AnimateTime)) or 0.5
  local Delay       = tonumber(Get(Config, 6, "Delay", CONFIG.Notification.Duration)) or 5

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
  if typeof(SizeUi) ~= "UDim2" then
    -- ukuran otomatis: ~62% lebar & ~80% tinggi layar, dibatasi agar tetap nyaman
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
    SizeUi = UDim2.fromOffset(math.clamp(vp.X * 0.62, 400, 560), math.clamp(vp.Y * 0.8, 250, 340))
  end
  local TopH = CONFIG.Window.TopbarHeight or 44

  -- opsi tampilan tambahan (semua opsional)
  local UseSearch  = Get(Config, 5, "Search", false) == true      -- kolom search di atas daftar tab
  local UseProfile = Get(Config, 6, "Profile", false) == true     -- avatar + "Welcome, nama" di bawah daftar tab
  local Logo       = Get(Config, 7, "Logo", "")                   -- ikon kecil di sebelah judul
  local HideName   = Get(Config, 8, "HideName", true) == true    -- sensor nama (abc***) di footer profil
  if type(Logo) ~= "string" then Logo = "" end
  local ToggleKey  = Get(Config, 9, "ToggleKey", Enum.KeyCode.RightShift)  -- hotkey buka/tutup window
  if typeof(ToggleKey) ~= "EnumItem" then ToggleKey = Enum.KeyCode.RightShift end
  local ShowKey    = UserInputService.KeyboardEnabled                       -- tombol [key] hanya di perangkat keyboard
  local RightBlock = 84 + (ShowKey and 76 or 0)                             -- ruang tombol kanan di topbar

  -- koneksi global milik window ini (di-disconnect saat window ditutup)
  local WindowConns = {}
  local function BindGlobal(Signal, Fn)
    local c = Signal:Connect(Fn)
    table.insert(WindowConns, c)
    table.insert(LibConnections, c)
    return c
  end

  local WindowGui = NewScreenGui("KingAkbarUI_Window", 10)
  Open_Close.Image = CONFIG.Assets.FloatingButton -- ikuti config terbaru (sebelum CreateWindow)

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

  -- ═══ Background Image ═══
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

  -- ═══ Top bar ═══
  local Top = Custom:Create("Frame", {
    Name = "Top",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, TopH),
    ZIndex = 5,
  }, Main)

  local TitleWidth = TextWidth(Title, 14, CONFIG.Font.Bold)
  local TitleX = 10 + ((Logo ~= "") and 28 or 0)

  if Logo ~= "" then
    Custom:Create("ImageLabel", {
      Image = Logo, BackgroundTransparency = 1, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0),
      Size = UDim2.fromOffset(22, 22), ZIndex = 5,
    }, Top)
  end

  Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(0, TitleWidth + 8, 1, 0), Position = UDim2.new(0, TitleX, 0, 0),
    ZIndex = 5,
  }, Top)

  local DescLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Regular, Text = Description, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + RightBlock), 1, 0),
    Position = UDim2.new(0, TitleX + TitleWidth + 14, 0, 0),
    ZIndex = 5,
  }, Top)

  -- badge/pill di kanan top bar (mis. nama game, versi, executor)
  local BadgeHolder = Custom:Create("Frame", {
    Name = "Badges",
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.X,
    Position = UDim2.new(1, -(RightBlock - 2), 0.5, 0),
    Size = UDim2.fromOffset(0, 24),
    ZIndex = 6,
  }, Top)
  Custom:Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6),
  }, BadgeHolder)

  BadgeHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    DescLabel.Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + RightBlock + BadgeHolder.AbsoluteSize.X + 6), 1, 0)
  end)

  local function RoundButton(Text, OffsetX)
    local B = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = Text, TextColor3 = CONFIG.Theme.Text, TextSize = 16,
      AnchorPoint = Vector2.new(1, 0.5),
      BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.25,
      BorderSizePixel = 0, AutoButtonColor = false,
      Position = UDim2.new(1, -OffsetX, 0.5, 0), Size = UDim2.fromOffset(26, 26),
      ZIndex = 6,
    }, Top)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, B)
    return B
  end

  local Close = RoundButton("×", 12)
  local Min   = RoundButton("–", 44)

  local KeyButton
  if ShowKey then
    KeyButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = ToggleKey.Name, TextSize = 11,
      TextColor3 = CONFIG.Theme.SubText, TextTruncate = Enum.TextTruncate.AtEnd,
      AnchorPoint = Vector2.new(1, 0.5),
      BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.25,
      BorderSizePixel = 0, AutoButtonColor = false,
      Position = UDim2.new(1, -76, 0.5, 0), Size = UDim2.fromOffset(64, 24),
      ZIndex = 6,
    }, Top)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, KeyButton)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, KeyButton)
  end

  -- garis pemisah bawah top bar
  Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, TopH),
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = 5,
  }, Main)

  -- ═══ Kolom tab & area konten ═══
  local LayersTab = Custom:Create("Frame", {
    Name = "LayersTab",
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 9, 0, TopH + 8),
    Size = UDim2.new(0, TabWidth, 1, -(TopH + 8 + 9)),
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
      ZIndex = 5,
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
      ZIndex = 6,
    }, SearchFrame)
  end

  if UseProfile then
    local Profile = Custom:Create("Frame", {
      Name = "Profile",
      AnchorPoint = Vector2.new(0, 1),
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 0, 1, 0),
      Size = UDim2.new(1, 0, 0, 44),
      ZIndex = 5,
    }, LayersTab)

    local Avatar = Custom:Create("ImageLabel", {
      BackgroundColor3 = CONFIG.Theme.Secondary, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(0, 0.5),
      Position = UDim2.new(0, 2, 0.5, 0),
      Size = UDim2.fromOffset(36, 36),
      ZIndex = 6,
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
      ZIndex = 6,
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
    Position = UDim2.new(0, TabWidth + 18, 0, TopH + 8),
    Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -(TopH + 8 + 9)),
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

  -- ═══ Tampil / sembunyi / tutup ═══
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
    if Open_Close_Moved() then return end -- barusan di-drag, bukan klik
    if DropShadowHolder.Visible then return end
    ShowWindow()
  end)

  Close.Activated:Connect(function()
    CircleClick(Close)
    DestroyWindow()
  end)

  MakeDraggable(Top, DropShadowHolder, BindGlobal)

  -- hotkey buka/tutup window (klik tombol [key] di topbar untuk mengganti)
  local Rebinding = false
  if KeyButton then
    KeyButton.Activated:Connect(function()
      CircleClick(KeyButton)
      Rebinding = true
      KeyButton.Text = "..."
    end)
  end
  BindGlobal(UserInputService.InputBegan, function(input, gpe)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if Rebinding then
      Rebinding = false
      if input.KeyCode ~= Enum.KeyCode.Escape then ToggleKey = input.KeyCode end
      if KeyButton then KeyButton.Text = ToggleKey.Name end
      return
    end
    if gpe then return end
    if input.KeyCode == ToggleKey then
      if DropShadowHolder.Visible then HideWindow() else ShowWindow() end
    end
  end)

  -- ═══ Overlay Dropdown ═══
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
    Active = true, -- supaya klik di dalam list tidak menutup overlay
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

  -- ═══ Overlay Color Picker ═══
  local PickerOverlay = Custom:Create("Frame", {
    Name = "PickerOverlay",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
    ZIndex = 11,
  }, Layers)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, PickerOverlay)

  local PickerBackdrop = Custom:Create("TextButton", {
    Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 11,
  }, PickerOverlay)

  local PickerPanel = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CONFIG.Theme.Secondary, BorderSizePixel = 0,
    Active = true,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(196, 156),
    ZIndex = 12,
  }, PickerOverlay)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, PickerPanel)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4 }, PickerPanel)

  local SVBox = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromHSV(0, 1, 1), BorderSizePixel = 0,
    Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(140, 100),
    ZIndex = 13,
  }, PickerPanel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SVBox)

  local WhiteOv = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 14,
  }, SVBox)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, WhiteOv)
  Custom:Create("UIGradient", { Transparency = NumberSequence.new(0, 1) }, WhiteOv)

  local BlackOv = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 15,
  }, SVBox)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, BlackOv)
  Custom:Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, BlackOv)

  local SVCursor = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.fromOffset(10, 10), ZIndex = 16,
  }, SVBox)
  Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, SVCursor)
  Custom:Create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2 }, SVCursor)

  local SVHit = Custom:Create("TextButton", {
    Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 17,
  }, SVBox)

  local HueBar = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
    Position = UDim2.fromOffset(158, 10), Size = UDim2.fromOffset(20, 100),
    ZIndex = 13,
  }, PickerPanel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, HueBar)
  Custom:Create("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0,     Color3.fromRGB(255, 0, 0)),
      ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
      ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
      ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(0, 255, 255)),
      ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
      ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
      ColorSequenceKeypoint.new(1,     Color3.fromRGB(255, 0, 0)),
    }),
  }, HueBar)

  local HueCursor = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 5), ZIndex = 16,
  }, HueBar)
  Custom:Create("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 2 }, HueCursor)

  local HueHit = Custom:Create("TextButton", {
    Text = "", BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 17,
  }, HueBar)

  local PreviewSwatch = Custom:Create("Frame", {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
    Position = UDim2.fromOffset(10, 120), Size = UDim2.fromOffset(24, 24),
    ZIndex = 13,
  }, PickerPanel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, PreviewSwatch)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, PreviewSwatch)

  local HexBox = Custom:Create("TextBox", {
    Font = CONFIG.Font.Bold, Text = "#FFFFFF", TextSize = 12,
    TextColor3 = CONFIG.Theme.Text, PlaceholderText = "#RRGGBB",
    PlaceholderColor3 = CONFIG.Theme.SubText, ClearTextOnFocus = false,
    BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(42, 120), Size = UDim2.fromOffset(108, 24),
    ZIndex = 13,
  }, PickerPanel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, HexBox)

  local PickerOk = Custom:Create("TextButton", {
    Font = CONFIG.Font.Bold, Text = "OK", TextSize = 12,
    TextColor3 = ContrastColor(CONFIG.Theme.Primary),
    AutoButtonColor = false,
    BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
    Position = UDim2.fromOffset(158, 120), Size = UDim2.fromOffset(28, 24),
    ZIndex = 13,
  }, PickerPanel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, PickerOk)

  local PH, PS, PV = 0, 0, 1
  local PickerCallback = nil
  local PickerDrag = nil

  local function RefreshPicker(Fire)
    local c = Color3.fromHSV(PH, PS, PV)
    SVBox.BackgroundColor3 = Color3.fromHSV(PH, 1, 1)
    SVCursor.Position = UDim2.fromScale(PS, 1 - PV)
    HueCursor.Position = UDim2.fromScale(0, PH)
    PreviewSwatch.BackgroundColor3 = c
    HexBox.Text = "#" .. string.upper(c:ToHex())
    if Fire and PickerCallback then PickerCallback(c) end
  end

  local function ClosePicker()
    PickerOverlay.Visible = false
    PickerCallback = nil
    PickerDrag = nil
  end

  local function OpenPicker(Color, Callback)
    CloseDropdownPanel()
    PickerCallback = nil
    PH, PS, PV = Color:ToHSV()
    RefreshPicker(false)
    PickerCallback = Callback
    PickerOverlay.Visible = true
  end

  local function UpdatePick()
    local m = UserInputService:GetMouseLocation()
    if PickerDrag == "sv" then
      local p, sz = SVBox.AbsolutePosition, SVBox.AbsoluteSize
      if sz.X <= 0 or sz.Y <= 0 then return end
      PS = math.clamp((m.X - p.X) / sz.X, 0, 1)
      PV = 1 - math.clamp((m.Y - p.Y) / sz.Y, 0, 1)
    elseif PickerDrag == "hue" then
      local p, sz = HueBar.AbsolutePosition, HueBar.AbsoluteSize
      if sz.Y <= 0 then return end
      PH = math.clamp((m.Y - p.Y) / sz.Y, 0, 0.999)
    else
      return
    end
    RefreshPicker(true)
  end

  local function IsPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch
  end

  SVHit.InputBegan:Connect(function(input)
    if IsPress(input) then PickerDrag = "sv"; UpdatePick() end
  end)
  HueHit.InputBegan:Connect(function(input)
    if IsPress(input) then PickerDrag = "hue"; UpdatePick() end
  end)
  BindGlobal(UserInputService.InputChanged, function(input)
    if PickerDrag and (input.UserInputType == Enum.UserInputType.MouseMovement
      or input.UserInputType == Enum.UserInputType.Touch) then
      UpdatePick()
    end
  end)
  BindGlobal(UserInputService.InputEnded, function(input)
    if PickerDrag and IsPress(input) then PickerDrag = nil end
  end)

  HexBox.FocusLost:Connect(function()
    local hex = string.gsub(HexBox.Text, "#", "")
    local ok, c = pcall(Color3.fromHex, hex)
    if ok and typeof(c) == "Color3" then
      PH, PS, PV = c:ToHSV()
      RefreshPicker(true)
    else
      RefreshPicker(false)
    end
  end)

  PickerBackdrop.Activated:Connect(ClosePicker)
  PickerOk.Activated:Connect(ClosePicker)

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
      ScrollBarImageColor3 = CONFIG.Theme.Primary,
      ScrollBarImageTransparency = 0.45,
      ScrollBarThickness = 3, VerticalScrollBarInset = Enum.ScrollBarInset.None,
      Active = true,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      Visible = false,
      ZIndex = 5,
    }, LayersReal)

    Custom:Create("UIListLayout", {
      Padding = UDim.new(0, 4),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, ScrolLayers)
    Custom:Create("UIPadding", { PaddingRight = UDim.new(0, 8) }, ScrolLayers)

    local Tab = Custom:Create("Frame", {
      Name = "Tab",
      BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = 0.999,
      BorderSizePixel = 0,
      LayoutOrder = TabIndex,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 5,
    }, ScrollTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Tab)

    local TabButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = "",
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 7,
    }, Tab)

    Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = _Name, TextColor3 = CONFIG.Theme.Text,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, Icon ~= "" and -30 or -10, 1, 0),
      Position = UDim2.new(0, Icon ~= "" and 30 or 10, 0, 0),
      ZIndex = 6,
    }, Tab)

    if Icon ~= "" then
      Custom:Create("ImageLabel", {
        Image = Icon, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0, 7), Size = UDim2.fromOffset(16, 16),
        ZIndex = 6,
      }, Tab)
    end

    -- indikator tab aktif (satu per tab, ikut scroll)
    local Bar = Custom:Create("Frame", {
      Name = "ChooseFrame",
      AnchorPoint = Vector2.new(0, 0.5),
      BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
      Position = UDim2.new(0, 2, 0.5, 0),
      Size = UDim2.new(0, 1, 0, 0),
      ZIndex = 6,
    }, Tab)
    local BarStroke = Custom:Create("UIStroke", {
      Color = CONFIG.Theme.Primary, Thickness = 1.6, Transparency = 1,
    }, Bar)
    Custom:Create("UICorner", {}, Bar)

    local TabObj = {
      Name = _Name, Frame = Tab, Page = ScrolLayers, Bar = Bar, Stroke = BarStroke,
    }
    table.insert(AllTabs, TabObj)

    if TabIndex == 1 then
      SelectTab(TabObj, true)
    end

    TabButton.Activated:Connect(function()
      CircleClick(TabButton)
      CloseDropdownPanel()
      ClosePicker()
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
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 5,
      }, ScrolLayers)

      local SectionReal = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = CONFIG.Theme.Panel,
        BackgroundTransparency = 0.935, BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 34),
        ZIndex = 5,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, SectionReal)

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
        Position = UDim2.new(0.5, 0, 0, 37),
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
        Position = UDim2.new(0.5, 0, 0, 42),
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 5,
      }, Section)

      local SectionList = Custom:Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
      }, SectionAdd)

      -- tinggi section otomatis mengikuti isi (tidak perlu hitung manual)
      local function ApplyLayout(Animate)
        local t = Animate and 0.15 or 0
        local contentH = SectionList.AbsoluteContentSize.Y
        SectionAdd.Size = UDim2.new(1, 0, 0, contentH)
        Tween(FeatureFrame, { Rotation = OpenSection and 90 or 0 }, t)
        Tween(Section, { Size = UDim2.new(1, 0, 0, OpenSection and (42 + contentH + 4) or 34) }, t)
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

      function Item:AddToggle(TConfig)
        local TTitle   = Get(TConfig, 1, "Title", "")
        local TContent = Get(TConfig, 2, "Content", "")
        local Default  = Get(TConfig, 3, "Default", false)
        local Callback = Get(TConfig, 4, "Callback", function() end)
        local Funcs = { Value = Default == true }

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
          BackgroundColor3 = CONFIG.Theme.Divider,
          BorderSizePixel = 0,
          Position = UDim2.new(1, -12, 0.5, 0),
          Size = UDim2.fromOffset(40, 20),
          ZIndex = 6,
        }, Toggle)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, FeatureFrame2)

        local ToggleCircle = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Text,
          BorderSizePixel = 0,
          Position = UDim2.new(0, 2, 0.5, 0),
          Size = UDim2.fromOffset(16, 16),
          ZIndex = 7,
        }, FeatureFrame2)
        Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, ToggleCircle)

        local function ToggleAnimation(isOn)
          Tween(Base.Title, {
            TextColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text,
          }, 0.2)
          Tween(ToggleCircle, {
            Position = isOn and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = isOn and ContrastColor(CONFIG.Theme.Primary) or CONFIG.Theme.Text,
          }, 0.2)
          Tween(FeatureFrame2, {
            BackgroundColor3 = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Divider,
          }, 0.2)
        end

        function Funcs:Set(Value)
          Funcs.Value = Value == true
          ToggleAnimation(Funcs.Value)
          SafeCall(Callback, Funcs.Value)
        end

        ToggleButton.Activated:Connect(function()
          CircleClick(ToggleButton)
          Funcs:Set(not Funcs.Value)
        end)

        Funcs:Set(Funcs.Value)
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

        if Increment <= 0 then Increment = 1 end
        if Max <= Min then Max = Min + 1 end

        local Funcs = { Value = Default }

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

        -- area sentuh lebih besar (mobile): track cuma setebal 3px
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
            ScrolLayers.ScrollingEnabled = false -- cegah halaman ikut scroll saat geser slider
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
            SafeCall(Callback, Funcs.Value)
          end
        end)

        -- hanya izinkan angka, minus, dan titik
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

        Funcs:Set(Default, true)
        return Funcs
      end

      function Item:AddInput(IConfig)
        local ITitle   = Get(IConfig, 1, "Title", "")
        local IContent = Get(IConfig, 2, "Content", "")
        local Default  = tostring(Get(IConfig, 3, "Default", ""))
        local Callback = Get(IConfig, 4, "Callback", function() end)
        local Funcs = { Value = Default }

        local Base = NewItemBase(SectionAdd, NextOrder(), ITitle, IContent, 150)
        AttachCommon(Funcs, Base)

        local InputFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.9, BorderSizePixel = 0,
          ClipsDescendants = true,
          Position = UDim2.new(1, -12, 0.5, 0),
          Size = UDim2.fromOffset(120, 24),
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
          SafeCall(Callback, Value)
        end

        InputTextBox.FocusLost:Connect(function()
          Funcs:Set(InputTextBox.Text)
        end)

        Funcs:Set(Default)
        return Funcs
      end

      function Item:AddDropdown(DConfig)
        local DTitle   = Get(DConfig, 1, "Title", "")
        local DContent = Get(DConfig, 2, "Content", "")
        local Multi    = Get(DConfig, 3, "Multi", false) == true
        local Options  = Get(DConfig, 4, "Options", {})
        local Default  = Get(DConfig, 5, "Default", {})
        local Callback = Get(DConfig, 6, "Callback", function() end)

        if type(Options) ~= "table" then Options = {} end
        if type(Default) == "string" and Default ~= "" then
          Default = { Default }
        elseif type(Default) ~= "table" then
          Default = {}
        end

        local Funcs = { Value = {}, Options = {} }

        local Base = NewItemBase(SectionAdd, NextOrder(), DTitle, DContent, 150)
        AttachCommon(Funcs, Base)
        local Dropdown = Base.Frame

        local SelectOptionsFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.9, BorderSizePixel = 0,
          Position = UDim2.new(1, -12, 0.5, 0),
          Size = UDim2.fromOffset(120, 24),
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

        function Funcs:Clear()
          for _, c in ipairs(ScrollSelect:GetChildren()) do
            if c.Name == "Option" then c:Destroy() end
          end
          Funcs.Value = {}
          Funcs.Options = {}
          DropCount = 0
          OptionSelecting.Text = "Select Options"
        end

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
          OptionSelecting.Text = Text ~= "" and Text or "Select Options"
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
            Font = CONFIG.Font.Bold, Text = "",
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

        function Funcs:Refresh(RefreshList, Selecting)
          RefreshList = type(RefreshList) == "table" and RefreshList or {}
          Selecting = Selecting or {}
          Funcs:Clear()
          for _, Drop in ipairs(RefreshList) do
            Funcs:AddOption(Drop)
          end
          Funcs:Set(Selecting)
        end

        Funcs:Refresh(Options, Default)
        return Funcs
      end

      -- ═══════════ AddKeybind ═══════════
      function Item:AddKeybind(KConfig)
        local KTitle   = Get(KConfig, 1, "Title", "")
        local KContent = Get(KConfig, 2, "Content", "")
        local Default  = Get(KConfig, 3, "Default", "F")
        local Callback = Get(KConfig, 4, "Callback", function() end) -- dipanggil saat hotkey DITEKAN
        local Changed  = Get(KConfig, 5, "Changed", function() end)  -- dipanggil saat key DIGANTI

        local function ToKey(v)
          if typeof(v) == "EnumItem" then return v end
          if type(v) == "string" then
            local ok, k = pcall(function() return Enum.KeyCode[v] end)
            if ok and k then return k end
          end
          return Enum.KeyCode.F
        end

        local Funcs = { Value = ToKey(Default) }
        local Base = NewItemBase(SectionAdd, NextOrder(), KTitle, KContent, 100)
        AttachCommon(Funcs, Base)

        local KeyBtn = Custom:Create("TextButton", {
          Font = CONFIG.Font.Bold, Text = Funcs.Value.Name, TextSize = 11,
          TextColor3 = CONFIG.Theme.Text, TextTruncate = Enum.TextTruncate.AtEnd,
          AutoButtonColor = false,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.9,
          BorderSizePixel = 0,
          Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(64, 22),
          ZIndex = 7,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, KeyBtn)
        Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, KeyBtn)

        local Listening = false

        function Funcs:Set(Key, NoCallback)
          Funcs.Value = ToKey(Key)
          KeyBtn.Text = Funcs.Value.Name
          if not NoCallback then SafeCall(Changed, Funcs.Value) end
        end

        KeyBtn.Activated:Connect(function()
          CircleClick(KeyBtn)
          Listening = true
          KeyBtn.Text = "..."
        end)

        BindGlobal(UserInputService.InputBegan, function(input, gpe)
          if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
          if Listening then
            Listening = false
            if input.KeyCode == Enum.KeyCode.Escape then
              KeyBtn.Text = Funcs.Value.Name -- batal
            else
              Funcs:Set(input.KeyCode)
            end
            return
          end
          if not gpe and input.KeyCode == Funcs.Value then
            SafeCall(Callback, Funcs.Value)
          end
        end)

        return Funcs
      end

      -- ═══════════ AddColorPicker ═══════════
      function Item:AddColorPicker(CConfig)
        local CTitle   = Get(CConfig, 1, "Title", "")
        local CContent = Get(CConfig, 2, "Content", "")
        local Default  = Get(CConfig, 3, "Default", Color3.fromRGB(255, 255, 255))
        local Callback = Get(CConfig, 4, "Callback", function() end)
        if typeof(Default) ~= "Color3" then Default = Color3.fromRGB(255, 255, 255) end

        local Funcs = { Value = Default }
        local Base = NewItemBase(SectionAdd, NextOrder(), CTitle, CContent, 90)
        AttachCommon(Funcs, Base)

        local Swatch = Custom:Create("TextButton", {
          Text = "", AutoButtonColor = false,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = Default, BorderSizePixel = 0,
          Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(48, 22),
          ZIndex = 7,
        }, Base.Frame)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Swatch)
        Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, Swatch)

        function Funcs:Set(Color, NoCallback)
          if typeof(Color) ~= "Color3" then return end
          Funcs.Value = Color
          Swatch.BackgroundColor3 = Color
          if not NoCallback then SafeCall(Callback, Color) end
        end

        Swatch.Activated:Connect(function()
          OpenPicker(Funcs.Value, function(c) Funcs:Set(c) end)
        end)

        Funcs:Set(Default)
        return Funcs
      end

      -- ═══════════ AddPanel (Drop Panel) ═══════════
      function Item:AddPanel(PConfig)
        local PTitle   = Get(PConfig, 1, "Title", "")
        local PContent = Get(PConfig, 2, "Content", "")
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
          local state = { Value = def }
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
            SafeCall(cb, state.Value)
          end

          Btn.Activated:Connect(function()
            CircleClick(Btn)
            state:Set(not state.Value)
          end)

          state:Set(def)
          return state
        end

        return Funcs_Panel
      end

      return Item
    end

    return Sections
  end

  -- ═══ Fungsi window ═══
  local BadgeCount = 0
  function Tabs:AddBadge(Text)
    BadgeCount += 1
    local Pill = Custom:Create("Frame", {
      Name = "Badge",
      BackgroundColor3 = CONFIG.Theme.Secondary,
      BackgroundTransparency = 0.15, BorderSizePixel = 0,
      AutomaticSize = Enum.AutomaticSize.X,
      LayoutOrder = BadgeCount,
      Size = UDim2.fromOffset(0, 24),
      ZIndex = 6,
    }, BadgeHolder)
    Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Pill)
    Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, Pill)
    Custom:Create("UIPadding", {
      PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    }, Pill)
    local Lbl = Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = tostring(Text), TextSize = 12,
      TextColor3 = CONFIG.Theme.Text,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      AutomaticSize = Enum.AutomaticSize.X,
      Size = UDim2.new(0, 0, 1, 0),
      ZIndex = 7,
    }, Pill)
    local Badge = {}
    function Badge:SetText(T) Lbl.Text = tostring(T) end
    function Badge:Destroy() Pill:Destroy() end
    return Badge
  end

  function Tabs:SetToggleKey(Key)
    if typeof(Key) == "EnumItem" then
      ToggleKey = Key
      if KeyButton then KeyButton.Text = Key.Name end
    end
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
function Speed_Library:Destroy()
  if Env.KingAkbarUI_Cleanup then Env.KingAkbarUI_Cleanup() end
  Speed_Library.Unloaded = true
end

return Speed_Library
