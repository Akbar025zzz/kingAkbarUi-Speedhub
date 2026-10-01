--[[
  ╔══════════════════════════════════════════════════╗
  ║              KING AKBAR UI LIBRARY v1.2          ║
  ║       github.com/Akbar025zzz/kingAkbarUi-Speedhub ║
  ╚══════════════════════════════════════════════════╝
]]

local Players          = game:GetService("Players")
local Player           = Players.LocalPlayer
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser      = game:GetService("VirtualUser")

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
    BackgroundImage        = "",                              -- isi dengan rbxassetid://... kalau mau gambar
    BackgroundTransparency = 0.55,
    BackgroundTint         = Color3.fromRGB(0, 0, 0),
    BackgroundTintTrans    = 0.4,
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
    FloatingButton = "rbxassetid://136890595976124",
  },
  Behavior = {
    AntiAFK = true,
  },
}

-- ═══════════════════════════════════════════════════
--  CORE HELPER
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

  function Custom:EnabledAFK()
    if not CONFIG.Behavior.AntiAFK then return end
    Player.Idled:Connect(function()
      VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
      task.wait(1)
      VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
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
--  UI ROOT HELPER
-- ═══════════════════════════════════════════════════
local function GetRoot()
  if RunService:IsStudio() then
    return Player:WaitForChild("PlayerGui")
  end
  local ok, gui = pcall(function()
    return gethui and gethui()
      or cloneref and cloneref(game:GetService("CoreGui"))
      or game:GetService("CoreGui")
  end)
  return ok and gui or Player:WaitForChild("PlayerGui")
end

-- ═══════════════════════════════════════════════════
--  FLOATING OPEN/CLOSE BUTTON
-- ═══════════════════════════════════════════════════
local function OpenClose()
  local ScreenGui = Custom:Create("ScreenGui", {
    Name = "KingAkbarUI_Floating",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
  }, GetRoot())

  local Close_ImageButton = Custom:Create("ImageButton", {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.85, 0, 0.05, 0),
    Size = UDim2.new(0, 45, 0, 45),
    Image = CONFIG.Assets.FloatingButton,
    Visible = false,
    Name = "OpenCloseButton",
  }, ScreenGui)

  Custom:Create("UICorner", { Name = "MainCorner", CornerRadius = UDim.new(0, 9) }, Close_ImageButton)

  local dragging, dragStart, startPos = false, nil, nil

  Close_ImageButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
      or input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragStart = input.Position
      startPos = Close_ImageButton.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
      end)
    end
  end)

  Close_ImageButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
      or input.UserInputType == Enum.UserInputType.Touch) then
      local delta = input.Position - dragStart
      Close_ImageButton.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
  end)

  return Close_ImageButton
end

local Open_Close = OpenClose()

-- ═══════════════════════════════════════════════════
--  DRAGGABLE
-- ═══════════════════════════════════════════════════
local function MakeDraggable(topbarobject, object)
  local dragging, dragStart, startPos = false, nil, nil

  topbarobject.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true
      dragStart = input.Position
      startPos = object.Position
      input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
      end)
    end
  end)

  topbarobject.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
      or input.UserInputType == Enum.UserInputType.Touch) then
      local delta = input.Position - dragStart
      object.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
  end)
end

-- ═══════════════════════════════════════════════════
--  RIPPLE CLICK
-- ═══════════════════════════════════════════════════
local function CircleClick(Button, X, Y)
  task.spawn(function()
    Button.ClipsDescendants = true
    local Circle = Instance.new("ImageLabel")
    Circle.Image = CONFIG.Assets.RippleImage
    Circle.ImageColor3 = Color3.fromRGB(150, 150, 150)
    Circle.ImageTransparency = 0.85
    Circle.BackgroundTransparency = 1
    Circle.ZIndex = 10
    Circle.Parent = Button

    Circle.Position = UDim2.new(0, X - Button.AbsolutePosition.X, 0, Y - Button.AbsolutePosition.Y)
    local Size = math.max(Button.AbsoluteSize.X, Button.AbsoluteSize.Y) * 1.5
    local Tween = TweenService:Create(Circle,
      TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, Size, 0, Size),
        Position = UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
      })
    Tween:Play()
    Tween.Completed:Connect(function()
      for _ = 1, 10 do
        Circle.ImageTransparency = Circle.ImageTransparency + 0.01
        task.wait(0.05)
      end
      Circle:Destroy()
    end)
  end)
end

-- ═══════════════════════════════════════════════════
--  LIBRARY OBJECT
-- ═══════════════════════════════════════════════════
local Speed_Library = {}
Speed_Library.Unloaded = false

-- ─────────────────────── Notification ───────────────────────
function Speed_Library:SetNotification(Config)
  local Title       = Config[1] or Config.Title or ""
  local Description = Config[2] or Config.Description or ""
  local Content     = Config[3] or Config.Content or ""
  local Time        = Config[5] or Config.Time or CONFIG.Notification.AnimateTime
  local Delay       = Config[6] or Config.Delay or CONFIG.Notification.Duration

  local NotificationGui = Custom:Create("ScreenGui", {
    Name = "KingAkbarUI_Notification",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
  }, GetRoot())

  local NotificationLayout = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -30, 1, -30),
    Size = UDim2.new(0, CONFIG.Notification.Width, 1, 0),
  }, NotificationGui)

  NotificationLayout.ChildRemoved:Connect(function()
    local Count = 0
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    for _, v in ipairs(NotificationLayout:GetChildren()) do
      TweenService:Create(v, tweenInfo, {
        Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))
      }):Play()
      Count = Count + 1
    end
  end)

  local _Count = 0
  for _, v in ipairs(NotificationLayout:GetChildren()) do
    _Count = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
  end

  local NotificationFrame = Custom:Create("Frame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 150),
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, -(_Count)),
  }, NotificationLayout)

  local NotificationFrameReal = Custom:Create("Frame", {
    BackgroundColor3 = CONFIG.Theme.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 400, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
  }, NotificationFrame)

  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, NotificationFrameReal)
  Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, NotificationFrameReal)

  local Top = Custom:Create("Frame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 36),
  }, NotificationFrameReal)

  local TextLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0),
  }, Top)

  Custom:Create("UIStroke", { Color = CONFIG.Theme.Text, Thickness = 0.3 }, TextLabel)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Top)

  local TextLabel1 = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0),
  }, Top)

  Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 0.4 }, TextLabel1)

  local Close = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.new(0, 25, 0, 25),
  }, Top)

  local TextLabel2 = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Content, TextColor3 = CONFIG.Theme.SubText,
    TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0, 27), Size = UDim2.new(1, -20, 0, 13),
  }, NotificationFrameReal)

  TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
  TextLabel2.TextWrapped = true

  NotificationFrame.Size = UDim2.new(1, 0, 0,
    TextLabel2.AbsoluteSize.Y < 27 and 65 or TextLabel2.AbsoluteSize.Y + 40)

  local Waitted = false
  local Notification = {}

  function Notification:Close()
    if Waitted then return end
    Waitted = true
    TweenService:Create(NotificationFrameReal,
      TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
      { Position = UDim2.new(0, 400, 0, 0) }):Play()
    task.wait(tonumber(Time) / 1.2)
    NotificationFrame:Destroy()
    Waitted = false
  end

  Close.Activated:Connect(function() Notification:Close() end)

  TweenService:Create(NotificationFrameReal,
    TweenInfo.new(tonumber(Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
    { Position = UDim2.new(0, 0, 0, 0) }):Play()
  task.delay(tonumber(Delay), function() Notification:Close() end)

  return Notification
end

-- ─────────────────────── CreateWindow ───────────────────────
function Speed_Library:CreateWindow(Config)
  local Title       = Config[1] or Config.Title or ""
  local Description = Config[2] or Config.Description or ""
  local TabWidth    = Config[3] or Config["Tab Width"] or CONFIG.Window.TabWidth
  local SizeUi      = Config[4] or Config.SizeUi or CONFIG.Window.Size

  local SpeedHubXGui = Custom:Create("ScreenGui", {
    Name = "KingAkbarUI_Window",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
  }, GetRoot())

  local DropShadowHolder = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = SizeUi,
    ZIndex = 0,
  }, SpeedHubXGui)

  local Main = Custom:Create("Frame", {
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

  local Top = Custom:Create("Frame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 38),
    ZIndex = 5,
  }, Main)

  local TextLabel = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    ZIndex = 5,
  }, Top)

  local TextLabel1 = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, -(TextLabel.TextBounds.X + 104), 1, 0),
    Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0),
    ZIndex = 5,
  }, Top)

  local Close = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "X", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 25, 0, 25),
    ZIndex = 5,
  }, Top)

  local Min = Custom:Create("TextButton", {
    Font = CONFIG.Font.Regular, Text = "-", TextColor3 = CONFIG.Theme.Text,
    TextSize = 18, AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(1, -42, 0.5, 0), Size = UDim2.new(0, 25, 0, 25),
    ZIndex = 5,
  }, Top)

  local LayersTab = Custom:Create("Frame", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, 9, 0, 50),
    Size = UDim2.new(0, TabWidth, 1, -59),
    ZIndex = 5,
  }, Main)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, LayersTab)

  Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = CONFIG.Theme.Panel,
    BackgroundTransparency = 0.85, BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, 38),
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = 5,
  }, Main)

  local Layers = Custom:Create("Frame", {
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.new(0, TabWidth + 18, 0, 50),
    Size = UDim2.new(1, -(TabWidth + 9 + 18), 1, -59),
    ZIndex = 5,
  }, Main)
  Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, Layers)

  local NameTab = Custom:Create("TextLabel", {
    Font = CONFIG.Font.Bold, Text = "", TextColor3 = CONFIG.Theme.Text,
    TextSize = 24, TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 30),
    ZIndex = 5,
  }, Layers)

  local LayersReal = Custom:Create("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ClipsDescendants = true,
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 1, -33),
    ZIndex = 5,
  }, Layers)

  local LayersFolder = Custom:Create("Folder", { Name = "LayersFolder" }, LayersReal)

  local LayersPageLayout = Custom:Create("UIPageLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    TweenTime = 0.5,
    EasingDirection = Enum.EasingDirection.InOut,
    EasingStyle = Enum.EasingStyle.Quad,
  }, LayersFolder)

  local ScrollTab = Custom:Create("ScrollingFrame", {
    CanvasSize = UDim2.new(0, 0, 2.1, 0),
    ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
    ScrollBarThickness = 0, Active = true,
    BackgroundTransparency = 1, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, -10),
    ZIndex = 5,
  }, LayersTab)

  Custom:Create("UIListLayout", {
    Padding = UDim.new(0, 0),
    SortOrder = Enum.SortOrder.LayoutOrder,
  }, ScrollTab)

  local function UpdateSize()
    local Total = 0
    for _, v in pairs(ScrollTab:GetChildren()) do
      if v.Name ~= "UIListLayout" then
        Total = Total + 3 + v.Size.Y.Offset
      end
    end
    ScrollTab.CanvasSize = UDim2.new(0, 0, 0, Total)
  end
  ScrollTab.ChildAdded:Connect(UpdateSize)
  ScrollTab.ChildRemoved:Connect(UpdateSize)

  Min.Activated:Connect(function()
    CircleClick(Min, Player:GetMouse().X, Player:GetMouse().Y)
    DropShadowHolder.Visible = false
    if not Open_Close.Visible then Open_Close.Visible = true end
  end)

  Open_Close.Activated:Connect(function()
    DropShadowHolder.Visible = true
    if Open_Close.Visible then Open_Close.Visible = false end
  end)

  Close.Activated:Connect(function()
    CircleClick(Close, Player:GetMouse().X, Player:GetMouse().Y)
    if SpeedHubXGui then SpeedHubXGui:Destroy() end
    if not Speed_Library.Unloaded then Speed_Library.Unloaded = true end
  end)

  MakeDraggable(Top, DropShadowHolder)

  -- Dropdown overlay
  local MoreBlur = Custom:Create("Frame", {
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
    Position = UDim2.new(1, 172, 0.5, 0),
    Size = UDim2.new(0, 160, 1, -16),
    ClipsDescendants = true,
    ZIndex = 7,
  }, MoreBlur)

  ConnectButton.Activated:Connect(function()
    if MoreBlur.Visible then
      local tweenInfo = TweenInfo.new(0.2)
      TweenService:Create(MoreBlur, tweenInfo, { BackgroundTransparency = 0.999 }):Play()
      TweenService:Create(DropdownSelect, tweenInfo, { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
      task.wait(0.2)
      MoreBlur.Visible = false
    end
  end)

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

  local DropdownFolder = Custom:Create("Folder", { Name = "DropdownFolder" }, DropdownSelectReal)

  local DropPageLayout = Custom:Create("UIPageLayout", {
    EasingDirection = Enum.EasingDirection.InOut,
    EasingStyle = Enum.EasingStyle.Quad,
    TweenTime = 0.01,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Archivable = false,
  }, DropdownFolder)

  -- ═══════════ CreateTab ═══════════
  local Tabs = {}
  local CountTab = 0
  local CountDropdown = 0

  function Tabs:CreateTab(Config)
    local _Name = Config[1] or Config.Name or ""
    local Icon  = Config[2] or Config.Icon or ""

    local ScrolLayers = Custom:Create("ScrollingFrame", {
      ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
      ScrollBarThickness = 0, Active = true,
      LayoutOrder = CountTab,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 5,
    }, LayersFolder)

    Custom:Create("UIListLayout", {
      Padding = UDim.new(0, 3),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, ScrolLayers)

    local Tab = Custom:Create("Frame", {
      BackgroundColor3 = CONFIG.Theme.Panel,
      BackgroundTransparency = CountTab == 0 and 0.92 or 0.999,
      BorderSizePixel = 0,
      LayoutOrder = CountTab,
      Size = UDim2.new(1, 0, 0, 30),
      ZIndex = 5,
    }, ScrollTab)
    Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Tab)

    local TabButton = Custom:Create("TextButton", {
      Font = CONFIG.Font.Bold, Text = "",
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 6,
    }, Tab)

    Custom:Create("TextLabel", {
      Font = CONFIG.Font.Bold, Text = _Name, TextColor3 = CONFIG.Theme.Text,
      TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
      BackgroundTransparency = 1, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 30, 0, 0),
      ZIndex = 6,
    }, Tab)

    Custom:Create("ImageLabel", {
      Image = Icon, BackgroundTransparency = 1, BorderSizePixel = 0,
      Position = UDim2.new(0, 9, 0, 7), Size = UDim2.new(0, 16, 0, 16),
      ZIndex = 6,
    }, Tab)

    if CountTab == 0 then
      LayersPageLayout:JumpToIndex(0)
      NameTab.Text = _Name

      local ChooseFrame = Custom:Create("Frame", {
        BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0, 9),
        Size = UDim2.new(0, 1, 0, 12),
        ZIndex = 6,
      }, Tab)
      Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 1.6 }, ChooseFrame)
      Custom:Create("UICorner", {}, ChooseFrame)
    end

    TabButton.Activated:Connect(function()
      CircleClick(TabButton, Player:GetMouse().X, Player:GetMouse().Y)
      local FrameChoose
      for _, s in pairs(ScrollTab:GetChildren()) do
        for _, v in pairs(s:GetChildren()) do
          if v.Name == "ChooseFrame" then FrameChoose = v break end
        end
        if FrameChoose then break end
      end

      if FrameChoose and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
        for _, TabFrame in pairs(ScrollTab:GetChildren()) do
          if TabFrame.Name == "Tab" then
            TweenService:Create(TabFrame,
              TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
              { BackgroundTransparency = 0.999 }):Play()
          end
        end

        TweenService:Create(Tab,
          TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
          { BackgroundTransparency = 0.92 }):Play()
        TweenService:Create(FrameChoose,
          TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
          { Position = UDim2.new(0, 2, 0, 9 + (33 * Tab.LayoutOrder)) }):Play()

        LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
        task.wait(0.05)
        NameTab.Text = _Name
        TweenService:Create(FrameChoose,
          TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
          { Size = UDim2.new(0, 1, 0, 20) }):Play()
        task.wait(0.2)
        TweenService:Create(FrameChoose,
          TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
          { Size = UDim2.new(0, 1, 0, 12) }):Play()
      end
    end)

    -- ═══════════ Sections ═══════════
    local Sections, CountSection = {}, 0

    function Sections:AddSection(Title, OpenSection)
      Title = Title or ""
      OpenSection = OpenSection or false

      local Section = Custom:Create("Frame", {
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
        Size = UDim2.new(1, 1, 0, 30),
        ZIndex = 5,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SectionReal)

      local SectionButton = Custom:Create("TextButton", {
        Font = CONFIG.Font.Regular, Text = "",
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 6,
      }, SectionReal)

      local FeatureFrame = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
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
        Font = CONFIG.Font.Bold, Text = Title,
        TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
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
          ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
          ColorSequenceKeypoint.new(0.5, CONFIG.Theme.Primary),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
        },
      }, SectionDecideFrame)

      local SectionAdd = Custom:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 100),
        ZIndex = 5,
      }, Section)
      Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, SectionAdd)
      Custom:Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
      }, SectionAdd)

      local function UpdateSizeScroll()
        local OffsetY = 0
        for _, child in pairs(ScrolLayers:GetChildren()) do
          if child.Name ~= "UIListLayout" then
            OffsetY = OffsetY + 3 + child.Size.Y.Offset
          end
        end
        ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
      end

      local function UpdateSizeSection()
        if OpenSection then
          local SectionSizeYWidth = 38
          for _, v in pairs(SectionAdd:GetChildren()) do
            if v.Name ~= "UIListLayout" and v.Name ~= "UICorner" then
              SectionSizeYWidth = SectionSizeYWidth + v.Size.Y.Offset + 3
            end
          end
          TweenService:Create(FeatureFrame, TweenInfo.new(0.1), { Rotation = 90 }):Play()
          TweenService:Create(Section, TweenInfo.new(0.1),
            { Size = UDim2.new(1, 1, 0, SectionSizeYWidth) }):Play()
          TweenService:Create(SectionAdd, TweenInfo.new(0.1),
            { Size = UDim2.new(1, 0, 0, SectionSizeYWidth - 38) }):Play()
          TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1),
            { Size = UDim2.new(1, 0, 0, 2) }):Play()
          task.wait(0.5)
          UpdateSizeScroll()
        end
      end

      local function ToggleSection()
        CircleClick(SectionButton, Player:GetMouse().X, Player:GetMouse().Y)
        if OpenSection then
          TweenService:Create(FeatureFrame, TweenInfo.new(0.1), { Rotation = 0 }):Play()
          TweenService:Create(Section, TweenInfo.new(0.1),
            { Size = UDim2.new(1, 1, 0, 30) }):Play()
          TweenService:Create(SectionDecideFrame, TweenInfo.new(0.1),
            { Size = UDim2.new(0, 0, 0, 2) }):Play()
          OpenSection = false
          task.wait(0.1)
          UpdateSizeScroll()
        else
          OpenSection = true
          UpdateSizeSection()
        end
      end

      SectionButton.Activated:Connect(ToggleSection)
      SectionAdd.ChildAdded:Connect(UpdateSizeSection)
      SectionAdd.ChildRemoved:Connect(UpdateSizeSection)
      UpdateSizeScroll()

      -- ═══════════ Items ═══════════
      local Item, ItemCount = {}, 0

      function Item:AddParagraph(Config)
        local Title = Config[1] or Config.Title or ""
        local Content = Config[2] or Config.Content or ""
        local SettingFuncs = {}

        local Paragraph = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Paragraph)

        local ParagraphTitle = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(231, 231, 231), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -16, 0, 13),
          ZIndex = 6,
        }, Paragraph)

        local ParagraphContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          ZIndex = 6,
        }, Paragraph)

        local function UpdateParagraphSize()
          ParagraphContent.TextWrapped = false
          local lineCount = math.ceil(ParagraphContent.TextBounds.X / ParagraphContent.AbsoluteSize.X)
          ParagraphContent.Size = UDim2.new(1, -16, 0, 12 + (12 * lineCount))
          Paragraph.Size = UDim2.new(1, 0, 0, ParagraphContent.AbsoluteSize.Y + 33)
          ParagraphContent.TextWrapped = true
          UpdateSizeSection()
        end

        UpdateParagraphSize()
        ParagraphContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateParagraphSize)

        function SettingFuncs:Set(Config)
          ParagraphTitle.Text = Config[1] or Config.Title or ""
          ParagraphContent.Text = Config[2] or Config.Content or ""
          UpdateParagraphSize()
        end

        ItemCount += 1
        return SettingFuncs
      end

      function Item:AddSeperator(Config)
        local Title = Config[1] or Config.Title or ""
        local Sep_Funcs = {}

        local Seperator = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Divider,
          BackgroundTransparency = 0.1, BorderSizePixel = 1,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 30),
          ZIndex = 5,
        }, SectionAdd)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(231, 231, 231),
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
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 6) }, Seperator)

        function Sep_Funcs:Set(Config)
          Seperator:FindFirstChild("SeperatorTitle").Text = Config[1] or Config.Title or ""
        end

        ItemCount += 1
        return Sep_Funcs
      end

      function Item:AddLine()
        local LineFuncs = {}
        local Line = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.LineColor,
          BackgroundTransparency = 0.2, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 7),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Line)
        ItemCount += 1
        return LineFuncs
      end

      function Item:AddButton(Config)
        local Title    = Config[1] or Config.Title or ""
        local Content  = Config[2] or Config.Content or ""
        local Icon     = Config[3] or Config.Icon or CONFIG.Assets.DefaultIcon
        local Callback = Config[4] or Config.Callback or function() end
        local Funcs_Button = {}

        local Button = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Button)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(231, 231, 231), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -100, 0, 13),
          ZIndex = 6,
        }, Button)

        local ButtonContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -100, 0, 12),
          ZIndex = 6,
        }, Button)

        local function UpdateButtonSize()
          local _Height = 12 + (12 * (ButtonContent.TextBounds.X // ButtonContent.AbsoluteSize.X))
          ButtonContent.Size = UDim2.new(1, -100, 0, _Height)
          Button.Size = UDim2.new(1, 0, 0, ButtonContent.AbsoluteSize.Y + 33)
        end

        ButtonContent.TextWrapped = true
        UpdateButtonSize()
        ButtonContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
          ButtonContent.TextWrapped = false
          UpdateButtonSize()
          ButtonContent.TextWrapped = true
          UpdateSizeSection()
        end)

        local ButtonButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, Button)

        Custom:Create("ImageLabel", {
          Image = Icon,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, -15, 0.5, 0),
          Size = UDim2.new(0, 25, 0, 25),
          ZIndex = 6,
        }, Button)

        ButtonButton.Activated:Connect(function()
          CircleClick(ButtonButton, Player:GetMouse().X, Player:GetMouse().Y)
          Callback()
        end)

        ItemCount += 1
        return Funcs_Button
      end

      function Item:AddToggle(Config)
        local Title    = Config[1] or Config.Title or ""
        local Content  = Config[2] or Config.Content or ""
        local Default  = Config[3] or Config.Default or false
        local Callback = Config[4] or Config.Callback or function() end
        local Funcs_Toggle = { Value = Default }

        local Toggle = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Toggle)

        local ToggleTitle = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title, TextSize = 13,
          TextColor3 = Color3.fromRGB(231, 231, 231),
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -100, 0, 13),
          ZIndex = 6,
        }, Toggle)

        local ToggleContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content, TextSize = 12,
          TextColor3 = CONFIG.Theme.Text, TextTransparency = 0.6,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -100, 0, 12),
          ZIndex = 6,
        }, Toggle)

        local function UpdateToggleSize()
          ToggleContent.TextWrapped = false
          local Ratio = ToggleContent.TextBounds.X / ToggleContent.AbsoluteSize.X
          ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * math.ceil(Ratio)))
          Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)
          ToggleContent.TextWrapped = true
        end

        UpdateToggleSize()
        ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
          UpdateToggleSize()
          UpdateSizeSection()
        end)

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
          Size = UDim2.new(0, 30, 0, 15),
          ZIndex = 6,
        }, Toggle)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, FeatureFrame2)

        local UIStroke8 = Custom:Create("UIStroke", {
          Color = CONFIG.Theme.Text, Thickness = 2, Transparency = 0.9,
        }, FeatureFrame2)

        local ToggleCircle = Custom:Create("Frame", {
          BackgroundColor3 = Color3.fromRGB(20, 20, 20),
          BorderSizePixel = 0,
          Size = UDim2.new(0, 14, 0, 14),
          Position = UDim2.new(0, 0, 0, 0),
          ZIndex = 7,
        }, FeatureFrame2)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 15) }, ToggleCircle)

        local function ToggleAnimation(isOn)
          local TitleColor = isOn and CONFIG.Theme.Primary or Color3.fromRGB(230, 230, 230)
          local CirclePosition = isOn and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0)
          local StrokeColor = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Text
          local StrokeTransparency = isOn and 0 or 0.9
          local FrameColor = isOn and CONFIG.Theme.Primary or CONFIG.Theme.Panel
          local FrameTransparency = isOn and 0 or 0.92
          local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
          TweenService:Create(ToggleTitle, ti, { TextColor3 = TitleColor }):Play()
          TweenService:Create(ToggleCircle, ti, { Position = CirclePosition }):Play()
          TweenService:Create(UIStroke8, ti, { Color = StrokeColor, Transparency = StrokeTransparency }):Play()
          TweenService:Create(FeatureFrame2, ti, { BackgroundColor3 = FrameColor, BackgroundTransparency = FrameTransparency }):Play()
        end

        ToggleButton.Activated:Connect(function()
          CircleClick(ToggleButton, Player:GetMouse().X, Player:GetMouse().Y)
          Funcs_Toggle.Value = not Funcs_Toggle.Value
          Funcs_Toggle:Set(Funcs_Toggle.Value)
        end)

        function Funcs_Toggle:Set(Value)
          Funcs_Toggle.Value = Value
          Callback(Value)
          ToggleAnimation(Value)
        end
        Funcs_Toggle:Set(Funcs_Toggle.Value)

        ItemCount += 1
        return Funcs_Toggle
      end

      function Item:AddSlider(Config)
        local Title     = Config[1] or Config.Title or ""
        local Content   = Config[2] or Config.Content or ""
        local Increment = Config[3] or Config.Increment or 1
        local Min       = Config[4] or Config.Min or 0
        local Max       = Config[5] or Config.Max or 100
        local Default   = Config[6] or Config.Default or 50
        local Callback  = Config[7] or Config.Callback or function() end
        local Funcs_Slider = { Value = Default }

        local Slider = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Slider)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -180, 0, 13),
          ZIndex = 6,
        }, Slider)

        local SliderContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -180, 0, 12),
          ZIndex = 6,
        }, Slider)

        local function UpdateSliderSize()
          SliderContent.TextWrapped = false
          SliderContent.Size = UDim2.new(1, -180, 0, 12 + (12 * math.floor(SliderContent.TextBounds.X / SliderContent.AbsoluteSize.X)))
          Slider.Size = UDim2.new(1, 0, 0, SliderContent.AbsoluteSize.Y + 33)
          SliderContent.TextWrapped = true
        end
        SliderContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
          UpdateSliderSize() UpdateSizeSection()
        end)
        UpdateSliderSize()

        local SliderInput = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(1, -155, 0.5, 0),
          Size = UDim2.new(0, 28, 0, 20),
          ZIndex = 6,
        }, Slider)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 2) }, SliderInput)

        local TextBox = Custom:Create("TextBox", {
          Font = CONFIG.Font.Bold, Text = "90", TextColor3 = Color3.fromRGB(20, 20, 20),
          TextSize = 13, TextWrapped = true,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, -1, 0, 0),
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, SliderInput)

        local SliderFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.8, BorderSizePixel = 0,
          Position = UDim2.new(1, -20, 0.5, 0),
          Size = UDim2.new(0, 100, 0, 3),
          ZIndex = 6,
        }, Slider)
        Custom:Create("UICorner", {}, SliderFrame)

        local SliderDraggable = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(0, 0, 0.5, 0),
          Size = UDim2.new(0.9, 0, 0, 1),
          ZIndex = 7,
        }, SliderFrame)
        Custom:Create("UICorner", {}, SliderDraggable)

        local SliderCircle = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Primary, BorderSizePixel = 0,
          Position = UDim2.new(1, 4, 0.5, 0),
          Size = UDim2.new(0, 8, 0, 8),
          ZIndex = 8,
        }, SliderDraggable)
        Custom:Create("UICorner", {}, SliderCircle)
        Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary }, SliderCircle)

        local Dragging = false

        local function Round(Number, Factor)
          local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
          if Result < 0 then Result = Result + Factor end
          return Result
        end

        function Funcs_Slider:Set(Value)
          Value = math.clamp(Round(Value, Increment), Min, Max)
          Funcs_Slider.Value = Value
          TextBox.Text = tostring(Value)
          TweenService:Create(SliderDraggable,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale((Value - Min) / (Max - Min), 1) }):Play()
        end

        SliderFrame.InputBegan:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
          end
        end)

        SliderFrame.InputEnded:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            Callback(Funcs_Slider.Value)
          end
        end)

        local _LastX = nil
        UserInputService.InputChanged:Connect(function(Input)
          if Dragging then
            local CurrPosX = Input.Position.X
            if CurrPosX ~= _LastX then
              _LastX = CurrPosX
              local SizeScale = math.clamp(
                (CurrPosX - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
              Funcs_Slider:Set(Min + ((Max - Min) * SizeScale))
            end
          end
        end)

        TextBox:GetPropertyChangedSignal("Text"):Connect(function()
          local Valid = TextBox.Text:gsub("[^%d]", "")
          if Valid ~= "" then
            TextBox.Text = tostring(math.min(tonumber(Valid), Max))
          else
            TextBox.Text = "0"
          end
        end)

        TextBox.FocusLost:Connect(function()
          if TextBox.Text ~= "" then
            Funcs_Slider:Set(tonumber(TextBox.Text))
          else
            Funcs_Slider:Set(0)
          end
          Callback(Funcs_Slider.Value)
        end)

        Funcs_Slider:Set(tonumber(Default))
        Callback(Funcs_Slider.Value)

        ItemCount += 1
        return Funcs_Slider
      end

      function Item:AddInput(Config)
        local Title    = Config[1] or Config.Title or ""
        local Content  = Config[2] or Config.Content or ""
        local Default  = Config[3] or Config.Default or ""
        local Callback = Config[4] or Config.Callback or function() end
        local Funcs_Input = { Value = Default }

        local Input = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Input)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -180, 0, 13),
          ZIndex = 6,
        }, Input)

        local InputContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6, TextWrapped = true,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -180, 0, 12),
          ZIndex = 6,
        }, Input)

        local function UpdateInputSize()
          local Ratio = InputContent.TextBounds.X / InputContent.AbsoluteSize.X
          InputContent.Size = UDim2.new(1, -180, 0, 12 + (12 * math.floor(Ratio)))
          Input.Size = UDim2.new(1, 0, 0, InputContent.AbsoluteSize.Y + 33)
        end
        UpdateInputSize()
        InputContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
          InputContent.TextWrapped = false
          UpdateInputSize()
          InputContent.TextWrapped = true
          UpdateSizeSection()
        end)

        local InputFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.95, BorderSizePixel = 0,
          ClipsDescendants = true,
          Position = UDim2.new(1, -7, 0.5, 0),
          Size = UDim2.new(0, 148, 0, 30),
          ZIndex = 6,
        }, Input)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, InputFrame)

        local InputTextBox = Custom:Create("TextBox", {
          CursorPosition = -1,
          Font = CONFIG.Font.Bold,
          PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
          PlaceholderText = "Write here...",
          Text = "", TextColor3 = Color3.fromRGB(20, 20, 20), TextSize = 12,
          TextXAlignment = Enum.TextXAlignment.Left,
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 5, 0.5, 0),
          Size = UDim2.new(1, -10, 1, -8),
          ZIndex = 7,
        }, InputFrame)

        function Funcs_Input:Set(Value)
          InputTextBox.Text = Value
          Funcs_Input.Value = Value
          Callback(Value)
        end

        InputTextBox.FocusLost:Connect(function()
          Funcs_Input:Set(InputTextBox.Text)
        end)

        Funcs_Input:Set(Default)
        ItemCount += 1
        return Funcs_Input
      end

      function Item:AddDropdown(Config)
        local Title    = Config[1] or Config.Title or ""
        local Content  = Config[2] or Config.Content or ""
        local Multi    = Config[3] or Config.Multi or false
        local Options  = Config[4] or Config.Options or {}
        local Default  = Config[5] or Config.Default or {}
        local Callback = Config[6] or Config.Callback or function() end
        local Funcs_Dropdown = { Value = Default, Options = Options }

        local Dropdown = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 5,
        }, SectionAdd)

        local DropdownButton = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 7,
        }, Dropdown)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Dropdown)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -180, 0, 13),
          ZIndex = 6,
        }, Dropdown)

        local DropdownContent = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6, TextWrapped = true,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -180, 0, 12),
          ZIndex = 6,
        }, Dropdown)

        DropdownContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (DropdownContent.TextBounds.X // DropdownContent.AbsoluteSize.X)))
        DropdownContent.TextWrapped = true
        Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)

        DropdownContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
          DropdownContent.TextWrapped = false
          DropdownContent.Size = UDim2.new(1, -180, 0, 12 + (12 * (DropdownContent.TextBounds.X // DropdownContent.AbsoluteSize.X)))
          Dropdown.Size = UDim2.new(1, 0, 0, DropdownContent.AbsoluteSize.Y + 33)
          DropdownContent.TextWrapped = true
          UpdateSizeSection()
        end)

        local SelectOptionsFrame = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.95, BorderSizePixel = 0,
          Position = UDim2.new(1, -7, 0.5, 0),
          Size = UDim2.new(0, 148, 0, 30),
          LayoutOrder = CountDropdown,
          ZIndex = 6,
        }, Dropdown)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, SelectOptionsFrame)

        DropdownButton.Activated:Connect(function()
          if not MoreBlur.Visible then
            MoreBlur.Visible = true
            DropPageLayout:JumpToIndex(SelectOptionsFrame.LayoutOrder)
            local tweenInfo = TweenInfo.new(0.1)
            TweenService:Create(MoreBlur, tweenInfo, { BackgroundTransparency = 0.7 }):Play()
            TweenService:Create(DropdownSelect, tweenInfo, { Position = UDim2.new(1, -11, 0.5, 0) }):Play()
          end
        end)

        local OptionSelecting = Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = "",
          TextColor3 = Color3.fromRGB(20, 20, 20), TextSize = 12,
          TextTransparency = 0.3, TextWrapped = true,
          TextXAlignment = Enum.TextXAlignment.Left,
          AnchorPoint = Vector2.new(0, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 5, 0.5, 0),
          Size = UDim2.new(1, -30, 1, -8),
          ZIndex = 7,
        }, SelectOptionsFrame)

        Custom:Create("ImageLabel", {
          Image = CONFIG.Assets.DropdownArrow,
          ImageColor3 = Color3.fromRGB(20, 20, 20),
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, 0, 0.5, 0),
          Size = UDim2.new(0, 25, 0, 25),
          ZIndex = 7,
        }, SelectOptionsFrame)

        local ScrollSelect = Custom:Create("ScrollingFrame", {
          CanvasSize = UDim2.new(0, 0, 0, 0),
          ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
          ScrollBarThickness = 0, Active = true,
          LayoutOrder = CountDropdown,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 1, 0),
          ZIndex = 8,
        }, DropdownFolder)

        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 3),
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, ScrollSelect)

        local SearchBar = Custom:Create("TextBox", {
          Font = CONFIG.Font.Bold, PlaceholderText = "Search",
          PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
          Text = "", TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          BackgroundColor3 = Color3.fromRGB(0, 0, 0),
          BackgroundTransparency = 0.9,
          BorderColor3 = CONFIG.Theme.Primary, BorderSizePixel = 1,
          Size = UDim2.new(1, 0, 0, 20),
          ZIndex = 8,
        }, ScrollSelect)

        SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
          local SearchText = string.lower(SearchBar.Text)
          for _, v in pairs(ScrollSelect:GetChildren()) do
            if v:IsA("Frame") and v.Name == "Option" then
              local OptionText = v:FindFirstChild("OptionText")
              if OptionText then
                v.Visible = string.find(string.lower(OptionText.Text), SearchText) ~= nil
              end
            end
          end
        end)

        local DropCount = 0

        function Funcs_Dropdown:Clear()
          for _, DropFrame in pairs(ScrollSelect:GetChildren()) do
            if DropFrame.Name == "Option" then
              Funcs_Dropdown.Value = {}
              Funcs_Dropdown.Options = {}
              OptionSelecting.Text = "Select Options"
              DropFrame:Destroy()
            end
          end
        end

        function Funcs_Dropdown:Set(Value)
          Funcs_Dropdown.Value = Value or Funcs_Dropdown.Value
          for _, Drop in pairs(ScrollSelect:GetChildren()) do
            if Drop.Name ~= "UIListLayout" and Drop.Name ~= "SearchBar" then
              local isTextFound = table.find(Funcs_Dropdown.Value, Drop.OptionText.Text)
              local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
              local Size = isTextFound and UDim2.new(0, 1, 0, 12) or UDim2.new(0, 0, 0, 0)
              local BGTrans = isTextFound and 0.935 or 0.999
              local STTrans = isTextFound and 0 or 0.999
              TweenService:Create(Drop.ChooseFrame, ti, { Size = Size }):Play()
              TweenService:Create(Drop.ChooseFrame.UIStroke, ti, { Transparency = STTrans }):Play()
              TweenService:Create(Drop, ti, { BackgroundTransparency = BGTrans }):Play()
            end
          end
          local Text = table.concat(Funcs_Dropdown.Value, ", ")
          OptionSelecting.Text = Text ~= "" and Text or "Select Options"
          Callback(Funcs_Dropdown.Value)
        end

        function Funcs_Dropdown:AddOption(OptionName)
          OptionName = OptionName or "Option"
          local Option = Custom:Create("Frame", {
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
            ZIndex = 9,
          }, Option)

          Custom:Create("TextLabel", {
            Font = CONFIG.Font.Bold, Text = OptionName,
            TextSize = 13, TextColor3 = Color3.fromRGB(20, 20, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1, BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -100, 0, 13),
            Name = "OptionText",
            ZIndex = 9,
          }, Option)

          local ChooseFrame = Custom:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 9,
          }, Option)
          Custom:Create("UIStroke", {
            Color = Color3.fromRGB(20, 20, 20), Thickness = 1.6, Transparency = 0.999,
          }, ChooseFrame)
          Custom:Create("UICorner", {}, ChooseFrame)

          OptionButton.Activated:Connect(function()
            CircleClick(OptionButton, Player:GetMouse().X, Player:GetMouse().Y)
            local isOptionSelected = Option.BackgroundTransparency > 0.95
            if Multi then
              if isOptionSelected then
                if not table.find(Funcs_Dropdown.Value, OptionName) then
                  table.insert(Funcs_Dropdown.Value, OptionName)
                end
              else
                for i, v in ipairs(Funcs_Dropdown.Value) do
                  if v == OptionName then
                    table.remove(Funcs_Dropdown.Value, i) break
                  end
                end
              end
            else
              Funcs_Dropdown.Value = { OptionName }
            end
            Funcs_Dropdown:Set(Funcs_Dropdown.Value)
          end)

          local function UpdateCanvasSize()
            local OffsetY = 0
            for _, child in ipairs(ScrollSelect:GetChildren()) do
              if child.Name ~= "UIListLayout" and child.Name ~= "SearchBar" then
                OffsetY = OffsetY + 5 + child.Size.Y.Offset
              end
            end
            ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
          end
          UpdateCanvasSize()
          DropCount += 1
        end

        function Funcs_Dropdown:Refresh(RefreshList, Selecting)
          RefreshList = RefreshList or {}
          Selecting = Selecting or {}
          Funcs_Dropdown:Clear()
          for _, Drop in ipairs(RefreshList) do
            Funcs_Dropdown:AddOption(Drop)
          end
          Funcs_Dropdown.Options = RefreshList
          Funcs_Dropdown:Set(Selecting)
        end

        Funcs_Dropdown:Refresh(Funcs_Dropdown.Options, Funcs_Dropdown.Value)

        ItemCount += 1
        CountDropdown += 1
        return Funcs_Dropdown
      end

      -- ═══════════ AddPanel (Drop Panel) ═══════════
      function Item:AddPanel(Config)
        local Title    = Config[1] or Config.Title or ""
        local Content  = Config[2] or Config.Content or ""
        local Funcs_Panel = {}

        local Panel = Custom:Create("Frame", {
          BackgroundColor3 = CONFIG.Theme.Panel,
          BackgroundTransparency = 0.935, BorderSizePixel = 0,
          LayoutOrder = ItemCount,
          Size = UDim2.new(1, 0, 0, 35),
          ClipsDescendants = true,
          ZIndex = 5,
        }, SectionAdd)
        Custom:Create("UICorner", { CornerRadius = UDim.new(0, 4) }, Panel)

        local PanelHeader = Custom:Create("TextButton", {
          Font = CONFIG.Font.Regular, Text = "",
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 0, 35),
          ZIndex = 7,
        }, Panel)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Title,
          TextColor3 = Color3.fromRGB(231, 231, 231), TextSize = 13,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Top,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 10),
          Size = UDim2.new(1, -50, 0, 13),
          ZIndex = 6,
        }, PanelHeader)

        Custom:Create("TextLabel", {
          Font = CONFIG.Font.Bold, Text = Content,
          TextColor3 = CONFIG.Theme.Text, TextSize = 12,
          TextTransparency = 0.6,
          TextXAlignment = Enum.TextXAlignment.Left,
          TextYAlignment = Enum.TextYAlignment.Bottom,
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0, 10, 0, 23),
          Size = UDim2.new(1, -50, 0, 12),
          ZIndex = 6,
        }, PanelHeader)

        local Arrow = Custom:Create("ImageLabel", {
          Image = CONFIG.Assets.DropdownArrow,
          AnchorPoint = Vector2.new(1, 0.5),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(1, -10, 0.5, 0),
          Size = UDim2.new(0, 20, 0, 20),
          ZIndex = 7,
        }, PanelHeader)

        local PanelBody = Custom:Create("Frame", {
          AnchorPoint = Vector2.new(0.5, 0),
          BackgroundTransparency = 1, BorderSizePixel = 0,
          Position = UDim2.new(0.5, 0, 0, 40),
          Size = UDim2.new(1, 0, 0, 0),
          ZIndex = 6,
        }, Panel)
        Custom:Create("UIListLayout", {
          Padding = UDim.new(0, 3),
          SortOrder = Enum.SortOrder.LayoutOrder,
        }, PanelBody)

        local isOpen = false

        local function UpdatePanelSize()
          local total = 45
          for _, v in ipairs(PanelBody:GetChildren()) do
            if v.Name ~= "UIListLayout" then
              total = total + v.Size.Y.Offset + 3
            end
          end
          TweenService:Create(Panel, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, total)
          }):Play()
          PanelBody.Size = UDim2.new(1, 0, 0, total - 40)
          task.wait(0.2)
          UpdateSizeSection()
        end

        PanelHeader.Activated:Connect(function()
          CircleClick(PanelHeader, Player:GetMouse().X, Player:GetMouse().Y)
          isOpen = not isOpen
          TweenService:Create(Arrow, TweenInfo.new(0.2), {
            Rotation = isOpen and 180 or 0
          }):Play()

          if isOpen then
            UpdatePanelSize()
          else
            TweenService:Create(Panel, TweenInfo.new(0.2),
              { Size = UDim2.new(1, 0, 0, 35) }):Play()
            PanelBody.Size = UDim2.new(1, 0, 0, 0)
            task.wait(0.2)
            UpdateSizeSection()
          end
        end)

        local SubCount = 0

        function Funcs_Panel:AddButton(cfg)
          local t  = cfg.Title or cfg[1] or ""
          local cb = cfg.Callback or cfg[2] or function() end

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
            CircleClick(Btn, Player:GetMouse().X, Player:GetMouse().Y)
            cb()
          end)

          SubCount += 1
        end

        function Funcs_Panel:AddToggle(cfg)
          local t   = cfg.Title or cfg[1] or ""
          local def = cfg.Default or cfg[2] or false
          local cb  = cfg.Callback or cfg[3] or function() end
          local state = { Value = def }

          local Btn = Custom:Create("TextButton", {
            Font = CONFIG.Font.Bold,
            Text = "  " .. t .. "   [" .. (def and "ON" or "OFF") .. "]",
            TextColor3 = def and CONFIG.Theme.Primary or CONFIG.Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = CONFIG.Theme.Secondary,
            BackgroundTransparency = 0.3, BorderSizePixel = 0,
            LayoutOrder = SubCount,
            Size = UDim2.new(1, -10, 0, 28),
            ZIndex = 7,
          }, PanelBody)
          Custom:Create("UICorner", { CornerRadius = UDim.new(0, 3) }, Btn)

          Btn.Activated:Connect(function()
            state.Value = not state.Value
            Btn.Text = "  " .. t .. "   [" .. (state.Value and "ON" or "OFF") .. "]"
            Btn.TextColor3 = state.Value and CONFIG.Theme.Primary or CONFIG.Theme.Text
            cb(state.Value)
          end)

          SubCount += 1
          return state
        end

        ItemCount += 1
        return Funcs_Panel
      end

      ItemCount += 1
      return Item
    end

    CountTab += 1
    return Sections
  end

  return Tabs
end

-- ═══════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════
function Speed_Library:SetTheme(t) Custom:SetTheme(t) end
function Speed_Library:SetFont(f)  Custom:SetFont(f)  end
function Speed_Library:GetConfig() return Custom:GetConfig() end

return Speed_Library
