--[[
╔══════════════════════════════════════════════════════════╗
║          KING AKBAR UI LIBRARY v1.5 (RAPIH EDITION)      ║
║    github.com/Akbar025zzz/kingAkbarUi-Speedhub           ║
╚══════════════════════════════════════════════════════════╝
LAYOUT SPEC:
- Topbar 44px, tombol minimize/close bulat
- Sidebar 112px: search atas, tab list, profil bawah
- Section header 34px, item 40px
- Toggle iOS 40x20 | Slider: kotak nilai + track
- ColorPicker swatch 48x22 | Dropdown 120x24 | Keybind 64x22
- Scrollbar halus 3px di kanan konten

CONTOH:
local Lib = loadstring(game:HttpGet("URL"))()
local Win = Lib:CreateWindow({ "Meng Hub", "v1.5", 112, UDim2.fromOffset(460, 300) })
local Tab = Win:CreateTab({ "Main", "rbxassetid://7734010488" })
local Sec = Tab:AddSection("Farm", true)
Sec:AddToggle({ "Auto Farm", "Farm otomatis", false, function(v) end })
Sec:AddSlider({ "WalkSpeed", "", 1, 16, 200, 16, function(v) end })
Sec:AddColorPicker({ "ESP Color", "Warna ESP", Color3.fromRGB(255, 0, 0), function(c) end })
Sec:AddKeybind({ "Fly Hotkey", "Toggle fly", Enum.KeyCode.F, function() end })
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

-- ═══════════════ CLEANUP EXECUTE ULANG ═══════════════
local Env = (getgenv and getgenv()) or _G
if type(Env.KingAkbarUI_Cleanup) == "function" then
	pcall(Env.KingAkbarUI_Cleanup)
end
local LibConnections, LibGuis = {}, {}
local function TrackLib(c) table.insert(LibConnections, c) return c end
local function BindLib(sig, fn) return TrackLib(sig:Connect(fn)) end
Env.KingAkbarUI_Cleanup = function()
	for _, c in ipairs(LibConnections) do pcall(function() c:Disconnect() end) end
	for _, g in ipairs(LibGuis) do pcall(function() g:Destroy() end) end
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

-- ═══════════════ GLOBAL CONFIG ═══════════════
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
		Size                   = UDim2.fromOffset(460, 300),
		TabWidth               = 112,
		TopBarHeight           = 44,
		CornerRadius           = 8,
		ScrollbarThickness     = 3,
		BackgroundImage        = "rbxassetid://110409843085547",
		BackgroundTransparency = 0.6,
		BackgroundTint         = Color3.fromRGB(0, 0, 0),
		BackgroundTintTrans    = 0.3,
	},
	Item = {
		Height  = 40,
		Spacing = 4,
		ToggleW = 40, ToggleH = 20,
		SwatchW = 48, SwatchH = 22,
		DropW   = 120, DropH = 24,
		KeyW    = 64, KeyH = 22,
	},
	Notification = { Width = 320, Duration = 5, AnimateTime = 0.5 },
	Assets = {
		ShadowImage    = "rbxassetid://1316045217",
		ArrowIcon      = "rbxassetid://125609963478878",
		DropdownArrow  = "rbxassetid://90200523188815",
		DefaultIcon    = "rbxassetid://7734010488",
		FloatingButton = "rbxassetid://91115084979317",
	},
	Behavior = { AntiAFK = true },
}

-- ═══════════════ HELPER ═══════════════
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

local Custom = {} do
	Custom.ColorRGB = CONFIG.Theme.Primary
	Custom.Config   = CONFIG
	function Custom:Create(Name, Properties, Parent)
		local inst = Instance.new(Name)
		for i, v in pairs(Properties) do inst[i] = v end
		if Parent then inst.Parent = Parent end
		return inst
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

-- ═══════════════ SCREENGUI FACTORY ═══════════════
local function NewScreenGui(Name, Order)
	local gui = Instance.new("ScreenGui")
	gui.Name = Name
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = Order or 10
	local parented = false
	if not RunService:IsStudio() then
		if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
		local ok = pcall(function()
			if gethui then gui.Parent = gethui()
			elseif cloneref then gui.Parent = cloneref(CoreGui)
			else gui.Parent = CoreGui end
		end)
		parented = ok and gui.Parent ~= nil
	end
	if not parented then gui.Parent = Player:WaitForChild("PlayerGui") end
	table.insert(LibGuis, gui)
	return gui
end

-- ═══════════════ DRAGGABLE ═══════════════
local function MakeDraggable(Handle, Object, Bind)
	local Dragging, DragInput, DragStart, StartPos, Moved = false, nil, nil, nil, false
	Handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			Dragging, Moved = true, false
			DragInput, DragStart, StartPos = input, input.Position, Object.Position
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

-- ═══════════════ FLOATING BUTTON ═══════════════
local function CreateFloatingButton()
	local Gui = NewScreenGui("KingAkbarUI_Floating", 20)
	local Btn = Custom:Create("ImageButton", {
		Name = "OpenCloseButton",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0, AutoButtonColor = false,
		Position = UDim2.new(0.85, 0, 0.05, 0),
		Size = UDim2.fromOffset(45, 45),
		Image = CONFIG.Assets.FloatingButton,
		Visible = false,
	}, Gui)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 9) }, Btn)
	local DidMove = MakeDraggable(Btn, Btn, BindLib)
	return Btn, DidMove
end
local Open_Close, Open_Close_Moved = CreateFloatingButton()

-- ═══════════════ RIPPLE ═══════════════
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
			Size = UDim2.fromOffset(0, 0), ZIndex = 10,
		}, Button)
		Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Circle)
		local Size = math.max(W, H) * 2.2
		Tween(Circle, { Size = UDim2.fromOffset(Size, Size), BackgroundTransparency = 1 }, 0.5)
		task.wait(0.55)
		if Circle then Circle:Destroy() end
	end)
end

-- ═══════════════ ITEM BASE (40px, auto-tinggi) ═══════════════
local function NewItemBase(Parent, Order, Title, Content, Reserve)
	local Base = {}
	local H = CONFIG.Item.Height
	local Frame = Custom:Create("Frame", {
		Name = "Item",
		BackgroundColor3 = CONFIG.Theme.Panel,
		BackgroundTransparency = 0.935, BorderSizePixel = 0,
		LayoutOrder = Order,
		Size = UDim2.new(1, 0, 0, H), ZIndex = 5,
	}, Parent)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 5) }, Frame)
	local TitleLabel = Custom:Create("TextLabel", {
		Name = "ItemTitle",
		Font = CONFIG.Font.Bold, Text = tostring(Title), TextSize = 13,
		TextColor3 = CONFIG.Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 7),
		Size = UDim2.new(1, -Reserve, 0, 14), ZIndex = 6,
	}, Frame)
	local ContentLabel = Custom:Create("TextLabel", {
		Name = "ItemContent",
		Font = CONFIG.Font.Bold, Text = tostring(Content), TextSize = 11,
		TextColor3 = CONFIG.Theme.Text, TextTransparency = 0.55,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 10, 0, 23),
		Size = UDim2.new(1, -Reserve, 0, 0), ZIndex = 6,
	}, Frame)
	Base.Frame, Base.Title, Base.Content = Frame, TitleLabel, ContentLabel
	Base.Height, Base.Apply = H, nil
	function Base.Refit()
		local has = ContentLabel.Text ~= ""
		ContentLabel.Visible = has
		local h
		if has then
			TitleLabel.AnchorPoint = Vector2.new(0, 0)
			TitleLabel.Position = UDim2.new(0, 10, 0, 7)
			h = 23 + math.max(ContentLabel.AbsoluteSize.Y, 11) + 8
		else
			TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
			TitleLabel.Position = UDim2.new(0, 10, 0.5, 0)
			h = H
		end
		Base.Height = h
		if Base.Apply then Base.Apply(h) else Frame.Size = UDim2.new(1, 0, 0, h) end
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

-- ═══════════════ LIBRARY ═══════════════
local Speed_Library = {}
Speed_Library.Unloaded = false

-- ─────────── Notification ───────────
local NotifGui, NotifHolder, NotifCounter = nil, nil, 0
local function EnsureNotifHolder()
	if NotifGui and NotifGui.Parent and NotifHolder and NotifHolder.Parent then return NotifHolder end
	NotifGui = NewScreenGui("KingAkbarUI_Notification", 50)
	NotifHolder = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
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
		BackgroundTransparency = 1, BorderSizePixel = 0,
		LayoutOrder = NotifCounter, Size = UDim2.new(1, 0, 0, 65),
	}, Holder)
	local Card = Custom:Create("Frame", {
		BackgroundColor3 = CONFIG.Theme.Background, BorderSizePixel = 0,
		Position = UDim2.new(1, 40, 0, 0), Size = UDim2.new(1, 0, 1, 0),
	}, Container)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, Card)
	Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.2 }, Card)
	local TitleWidth = TextWidth(Title, 14, CONFIG.Font.Bold)
	Custom:Create("TextLabel", {
		Font = CONFIG.Font.Bold, Text = Title, TextColor3 = CONFIG.Theme.Text,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0, TitleWidth + 4, 0, 36),
	}, Card)
	Custom:Create("TextLabel", {
		Font = CONFIG.Font.Bold, Text = Description, TextColor3 = CONFIG.Theme.Primary,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, TitleWidth + 15, 0, 0),
		Size = UDim2.new(1, -(TitleWidth + 15 + 35), 0, 36),
	}, Card)
	local CloseBtn = Custom:Create("TextButton", {
		Font = CONFIG.Font.Regular, Text = "×", TextColor3 = CONFIG.Theme.SubText,
		TextSize = 18, AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(1, -5, 0, 5), Size = UDim2.fromOffset(25, 25),
	}, Card)
	local ContentLabel = Custom:Create("TextLabel", {
		Font = CONFIG.Font.Bold, Text = Content, TextColor3 = CONFIG.Theme.SubText,
		TextSize = 13, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 0),
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
		task.delay(Time + 0.05, function() if Container then Container:Destroy() end end)
	end
	CloseBtn.Activated:Connect(function() Notification:Close() end)
	Tween(Card, { Position = UDim2.new(0, 0, 0, 0) }, Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	task.delay(Delay, function() Notification:Close() end)
	return Notification
end
function Speed_Library:Notify(Config) return Speed_Library:SetNotification(Config) end

-- ─────────── CreateWindow ───────────
function Speed_Library:CreateWindow(Config)
	local Title       = tostring(Get(Config, 1, "Title", ""))
	local Description = tostring(Get(Config, 2, "Description", ""))
	local TabWidth    = tonumber(Get(Config, 3, "TabWidth", CONFIG.Window.TabWidth)) or CONFIG.Window.TabWidth
	local SizeUi      = Get(Config, 4, "SizeUi", CONFIG.Window.Size)
	if typeof(SizeUi) ~= "UDim2" then SizeUi = CONFIG.Window.Size end
	local UseSearch  = Get(Config, 5, "Search", false) == true
	local UseProfile = Get(Config, 6, "Profile", false) == true
	local Logo       = Get(Config, 7, "Logo", "")
	local HideName   = Get(Config, 8, "HideName", true) == true
	if type(Logo) ~= "string" then Logo = "" end

	local TOP = CONFIG.Window.TopBarHeight
	local IT  = CONFIG.Item

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
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = SizeUi, ZIndex = 0,
	}, WindowGui)
	local Main = Custom:Create("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONFIG.Theme.Background, BackgroundTransparency = 0.1,
		BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 1, 0), ClipsDescendants = true, ZIndex = 1,
	}, DropShadowHolder)
	Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Main)
	Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1.4 }, Main)

	if CONFIG.Window.BackgroundImage ~= "" then
		local BgImage = Custom:Create("ImageLabel", {
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Image = CONFIG.Window.BackgroundImage,
			ImageTransparency = CONFIG.Window.BackgroundTransparency,
			ScaleType = Enum.ScaleType.Crop, ZIndex = 0,
		}, Main)
		Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, BgImage)
		local Tint = Custom:Create("Frame", {
			BackgroundColor3 = CONFIG.Window.BackgroundTint,
			BackgroundTransparency = CONFIG.Window.BackgroundTintTrans,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = 0,
		}, Main)
		Custom:Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Window.CornerRadius) }, Tint)
	end

	-- ═══ Topbar 44px ═══
	local Top = Custom:Create("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, TOP), ZIndex = 5,
	}, Main)
	local TitleWidth = TextWidth(Title, 15, CONFIG.Font.Bold)
	local TitleX = 12 + ((Logo ~= "") and 28 or 0)
	if Logo ~= "" then
		Custom:Create("ImageLabel", {
			Image = Logo, BackgroundTransparency = 1, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
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
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + 96), 1, 0),
		Position = UDim2.new(0, TitleX + TitleWidth + 14, 0, 0), ZIndex = 5,
	}, Top)
	local BadgeHolder = Custom:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(1, -74, 0.5, 0), Size = UDim2.fromOffset(0, 22), ZIndex = 6,
	}, Top)
	Custom:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6),
	}, BadgeHolder)
	BadgeHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		DescLabel.Size = UDim2.new(1, -(TitleX + TitleWidth + 14 + 74 + BadgeHolder.AbsoluteSize.X + 6), 1, 0)
	end)
	local function RoundButton(Text, XOff)
		local b = Custom:Create("TextButton", {
			Font = CONFIG.Font.Regular, Text = Text, TextColor3 = CONFIG.Theme.SubText,
			TextSize = 14, AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONFIG.Theme.Secondary, BackgroundTransparency = 0.45,
			BorderSizePixel = 0, AutoButtonColor = false,
			Position = UDim2.new(1, XOff, 0.5, 0), Size = UDim2.fromOffset(24, 24), ZIndex = 6,
		}, Top)
		Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, b)
		b.MouseEnter:Connect(function() Tween(b, { BackgroundTransparency = 0.1 }, 0.15) end)
		b.MouseLeave:Connect(function() Tween(b, { BackgroundTransparency = 0.45 }, 0.15) end)
		return b
	end
	local Min   = RoundButton("–", -40)
	local Close = RoundButton("×", -12)
	Close.MouseEnter:Connect(function() Tween(Close, { TextColor3 = Color3.fromRGB(255, 90, 90) }, 0.15) end)
	Close.MouseLeave:Connect(function() Tween(Close, { TextColor3 = CONFIG.Theme.SubText }, 0.15) end)
	Custom:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.85,
		BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, TOP),
		Size = UDim2.new(1, 0, 0, 1), ZIndex = 5,
	}, Main)

	-- ═══ Sidebar 112px ═══
	local LayersTab = Custom:Create("Frame", {
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, TOP + 8),
		Size = UDim2.new(0, TabWidth, 1, -(TOP + 8 + 10)), ZIndex = 5,
	}, Main)
	local ScrollTab = Custom:Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0, Active = true,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0), ZIndex = 5,
	}, LayersTab)
	Custom:Create("UIListLayout", {
		Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder,
	}, ScrollTab)
	local TopPad = UseSearch and 36 or 0
	local BotPad = UseProfile and 46 or 0
	ScrollTab.Position = UDim2.new(0, 0, 0, TopPad)
	ScrollTab.Size = UDim2.new(1, 0, 1, -(TopPad + BotPad))
	local TabSearchBox
	if UseSearch then
		local SearchFrame = Custom:Create("Frame", {
			BackgroundColor3 = CONFIG.Theme.Panel, BackgroundTransparency = 0.92,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), ZIndex = 5,
		}, LayersTab)
		Custom:Create("UICorner", { CornerRadius = UDim.new(0, 8) }, SearchFrame)
		Custom:Create("UIStroke", { Color = CONFIG.Theme.Stroke, Thickness = 1 }, SearchFrame)
		TabSearchBox = Custom:Create("TextBox", {
			Font = CONFIG.Font.Bold, PlaceholderText = "Search...",
			PlaceholderColor3 = CONFIG.Theme.SubText,
			Text = "", TextColor3 = CONFIG.Theme.Text, TextSize = 12,
			ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), ZIndex = 6,
		}, SearchFrame)
	end
	if UseProfile then
		local Profile = Custom:Create("Frame", {
			AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 40), ZIndex = 5,
		}, LayersTab)
		local Avatar = Custom:Create("ImageLabel", {
			BackgroundColor3 = CONFIG.Theme.Secondary, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(32, 32), ZIndex = 6,
		}, Profile)
		Custom:Create("UICorner", { CornerRadius = UDim.new(1, 0) }, Avatar)
		Custom:Create("UIStroke", { Color = CONFIG.Theme.Primary, Thickness = 1.4 }, Avatar)
		local shown = Player
