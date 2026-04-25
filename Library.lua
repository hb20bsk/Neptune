--[[

        Networph Neptune UI
        \ Made by @grclnttacidvrfivwjmtegcpewtlwtma | display is networph
        / Telegram: https://t.me/networph

    ]]

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local GuiInset = GuiService:GetGuiInset().Y
local NewVector2 = Vector2.new
local NewUDim2 = UDim2.new
local NewUDim = UDim.new
local NewColorSequence = ColorSequence.new
local NewColorSequenceKeypoint = ColorSequenceKeypoint.new
local NewNumberSequence = NumberSequence.new
local NewNumberSequenceKeypoint = NumberSequenceKeypoint.new
local FromOffset = UDim2.fromOffset
local FromRgb = Color3.fromRGB
local Hex = Color3.fromHex
local FromHsv = Color3.fromHSV
local MathMax = math.max
local MathFloor = math.floor
local MathMin = math.min
local MathAbs = math.abs
local MathClamp = math.clamp
local Insert = table.insert
local Concat = table.concat

local Library = {
	Flags = {},
	Toggles = {},
	Options = {},
	Connections = {},
	ConfigFlags = {},
	AccentUpdaters = {},
	Directory = "Erm",
	Folders = { "/Fonts", "/Configs" },
	CurrentlyOpen = nil,
	AnimationSpeed = 1,
	_ThemedProperties = {},
}

local function TweenNew(Inst, Info, Props)
	local Speed = Library.AnimationSpeed or 1
	if Speed < 0.05 then Speed = 0.05 end
	local Scale = 1 / Speed
	if Scale == 1 then
		return TweenService:Create(Inst, Info, Props)
	end
	local Scaled = TweenInfo.new(Info.Time * Scale, Info.EasingStyle, Info.EasingDirection, Info.RepeatCount, Info.Reverses, Info.DelayTime)
	return TweenService:Create(Inst, Scaled, Props)
end

local Palette = {
	Default = {
		Background = Hex("0F1014"),
		SubBackground = Hex("12141A"),
        TabBackground = Hex("171821"),
		Divider = Hex("1B1E28"),
		SubText = Hex("4A4C57"),
        Accent = Hex("70D5D4"),
        AccentTwo = Hex("437C82"),
        AccentBright = Hex("B5F0EF"),
        SectionBackground = Hex("12141A"),
        ColorBg = Hex("151720"),
        ColorBg2 = Hex("1E1F2A"),
	},
}

local KeyNames = {
	-- Mouse
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",

	-- Modifiers + common controls
	[Enum.KeyCode.LeftShift] = "LS",
	[Enum.KeyCode.RightShift] = "RS",
	[Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC",
	[Enum.KeyCode.LeftAlt] = "LA",
	[Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",

	-- Number row
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",

	-- Keypad
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",

	-- Symbols
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Backquote] = "`",
}

for _, FolderPath in ipairs(Library.Folders) do
	makefolder(Library.Directory .. FolderPath)
end

getgenv().Library = Library

Library._FlagSerializers = Library._FlagSerializers or {}

function Library:RegisterFlagSerializer(name, ser)
	if not name or name == "" then return end
	self._FlagSerializers[name] = ser
end

function Library:SerializeFlags()
	local lines = {}
	for name, s in pairs(self._FlagSerializers) do
		local value = s.serialize()
		if value ~= nil then
			Insert(lines, name .. "=" .. tostring(value))
		end
	end
	return Concat(lines, "\n")
end

function Library:DeserializeFlags(content)
	for line in string.gmatch(content or "", "[^\r\n]+") do
		local k, v = line:match("^([^=]+)=(.*)$")
		if k and self._FlagSerializers[k] then
			self._FlagSerializers[k].deserialize(v)
		end
	end
end

function Library:RegisterFlag(category, flag, obj, initialValue)
	if not flag or flag == "" then return function() end end
	obj.Flag = flag
	obj.Value = initialValue
	obj._changedListeners = {}
	function obj:OnChanged(cb)
		Insert(self._changedListeners, cb)
		return self
	end
	function obj:SetValue(...)
		return self:Set(...)
	end
	self[category][flag] = obj
	return function(newValue)
		obj.Value = newValue
		for _, cb in ipairs(obj._changedListeners) do
			cb(newValue)
		end
	end
end


-- Signals
function Library:Connection(Signal, Callback)
	local Conn = Signal:Connect(Callback)
	Insert(self.Connections, Conn)
	return Conn
end

-- Misc stuff
function Library:CreateInstance(ClassName, Properties)
	local Inst = Instance.new(ClassName)
	for k, v in next, (Properties or {}) do
		Inst[k] = v
		if typeof(v) == "Color3" then
			for paletteKey, paletteColor in pairs(Palette.Default) do
				if paletteColor == v then
					Insert(self._ThemedProperties, { Instance = Inst, Property = k, Key = paletteKey })
					break
				end
			end
		end
	end
	return Inst
end

Library._ThemedGradients = Library._ThemedGradients or {}
Library._ThemeRenderers = Library._ThemeRenderers or {}

function Library:BindThemedGradient(gradient, keys)
	Insert(self._ThemedGradients, { Gradient = gradient, Keys = keys })
end

function Library:RegisterThemeRenderer(fn)
	Insert(self._ThemeRenderers, fn)
end

local function BuildSequenceFromKeys(keys)
	local kps = {}
	local n = #keys
	for i, key in ipairs(keys) do
		local t = n <= 1 and 0 or (i - 1) / (n - 1)
		Insert(kps, NewColorSequenceKeypoint(t, Palette.Default[key] or FromRgb(255, 255, 255)))
	end
	return NewColorSequence(kps)
end

function Library:RefreshPalette()
	for i = #self._ThemedProperties, 1, -1 do
		local b = self._ThemedProperties[i]
		if not b.Instance or not b.Instance.Parent then
			table.remove(self._ThemedProperties, i)
		else
			local c = Palette.Default[b.Key]
			if c then b.Instance[b.Property] = c end
		end
	end
	for i = #self._ThemedGradients, 1, -1 do
		local b = self._ThemedGradients[i]
		if not b.Gradient or not b.Gradient.Parent then
			table.remove(self._ThemedGradients, i)
		else
			b.Gradient.Color = BuildSequenceFromKeys(b.Keys)
		end
	end
	for _, fn in ipairs(self._ThemeRenderers) do
		fn()
	end
end

-- Fonts
function Library:RegisterFont(Name, Url, Weight, Style)
	local Folder = self.Directory .. "/Fonts"
	local TtfPath = Folder .. "/" .. Name .. ".ttf"
	local DescPath = Folder .. "/" .. Name .. ".font"

	if not isfile(TtfPath) then
		writefile(TtfPath, game:HttpGet(Url))
	end
	if isfile(DescPath) then
		delfile(DescPath)
	end

	writefile(DescPath, HttpService:JSONEncode({
		name = Name,
		faces = {
			{ name = "Regular", weight = Weight or 400, style = Style or "Normal", assetId = getcustomasset(TtfPath) },
		},
	}))

	return getcustomasset(DescPath)
end

Library.Fonts = {
	Regular = Font.new(
		Library:RegisterFont("InterMedium", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-Medium.ttf", 200, "Normal"),
		Enum.FontWeight.Regular, Enum.FontStyle.Normal
	),
	SemiBold = Font.new(
		Library:RegisterFont("InterSemiBold", "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Inter_28pt-SemiBold.ttf", 200, "Normal"),
		Enum.FontWeight.Regular, Enum.FontStyle.Normal
	),
}

function Library:Draggable(TargetFrame, DragHandle)
	local Handle = DragHandle or TargetFrame
	local Dragging = false
	local DragStart, StartPosition

	self:Connection(Handle.InputBegan, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		if self._scrollbarDragging then
			return
		end
		Dragging = true
		DragStart = Input.Position
		StartPosition = TargetFrame.Position
	end)

	self:Connection(Handle.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
		end
	end)

	self:Connection(UserInputService.InputChanged, function(Input)
		if not Dragging or not DragStart or not StartPosition then
			return
		end
		if
			Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local Delta = Input.Position - DragStart
		local Vp = Camera.ViewportSize
		local NewX = MathClamp(StartPosition.X.Offset + Delta.X, 0, Vp.X - TargetFrame.AbsoluteSize.X)
		local NewY = MathClamp(StartPosition.Y.Offset + Delta.Y, 0, Vp.Y - TargetFrame.AbsoluteSize.Y)
		TargetFrame.Position = NewUDim2(0, NewX, 0, NewY)
	end)
end

function Library:Resizable(TargetFrame, Opts)
	Opts = typeof(Opts) == "table" and Opts or {}
	local GripPx = tonumber(Opts.GripPx) or 10
	local MinX = tonumber(Opts.MinX) or TargetFrame.Size.X.Offset
	local MinY = tonumber(Opts.MinY) or TargetFrame.Size.Y.Offset

	local Grip = self:CreateInstance("TextButton", {
		Name = "ResizeGrip",
		Parent = TargetFrame,
		AnchorPoint = NewVector2(1, 1),
		Position = NewUDim2(1, 0, 1, 0),
		Size = NewUDim2(0, GripPx, 0, GripPx),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Text = "",
		ZIndex = 999,
	})

	local Resizing = false
	local StartPos, StartSize

	self:Connection(Grip.InputBegan, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		Resizing = true
		StartPos = Input.Position
		StartSize = TargetFrame.Size
	end)

	self:Connection(Grip.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Resizing = false
		end
	end)

	self:Connection(UserInputService.InputChanged, function(Input)
		if not Resizing or not StartPos or not StartSize then
			return
		end
		if
			Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local Vp = Camera.ViewportSize
		local Dx = Input.Position.X - StartPos.X
		local Dy = Input.Position.Y - StartPos.Y
		TargetFrame.Size = NewUDim2(
			StartSize.X.Scale,
			MathClamp(StartSize.X.Offset + Dx, MinX, Vp.X),
			StartSize.Y.Scale,
			MathClamp(StartSize.Y.Offset + Dy, MinY, Vp.Y)
		)
	end)

	return Grip
end

function Library:EnsureColumns(Host)
	local existing = Host:FindFirstChild("ColumnsScroll")
	if existing then
		return existing:FindFirstChild("LeftColumn"), existing:FindFirstChild("RightColumn")
	end
	local Scroll = self:CreateInstance("ScrollingFrame", {
		Name = "ColumnsScroll",
		Parent = Host,
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = NewUDim2(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		ScrollingEnabled = false,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Active = true,
	})
	self:CreateInstance("UIListLayout", {
		Parent = Scroll,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 10),
	})
	local ScrollPadding = self:CreateInstance("UIPadding", {
		Parent = Scroll,
		PaddingRight = NewUDim(0, 20),
	})

	local ScrollbarTrack = self:CreateInstance("Frame", {
		Name = "ScrollbarTrack",
		Parent = Host,
		AnchorPoint = NewVector2(1, 0),
		Position = NewUDim2(1, -2, 0, 0),
		Size = NewUDim2(0, 8, 1, 0),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = ScrollbarTrack, CornerRadius = NewUDim(1, 0) })
	local ScrollbarThumb = self:CreateInstance("Frame", {
		Name = "ScrollbarThumb",
		Parent = ScrollbarTrack,
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, 0, 0, 0),
		BackgroundColor3 = Palette.Default.Accent,
		BorderSizePixel = 0,
		Visible = false,
	})
	self:CreateInstance("UICorner", { Parent = ScrollbarThumb, CornerRadius = NewUDim(1, 0) })

	local LibRef = self
	local function UpdateScrollbar()
		local viewH = Scroll.AbsoluteWindowSize.Y
		local canvasH = Scroll.AbsoluteCanvasSize.Y
		if canvasH <= viewH + 1 then
			ScrollbarThumb.Visible = false
			ScrollbarTrack.Visible = false
			ScrollPadding.PaddingRight = NewUDim(0, 0)
			return
		end
		ScrollbarTrack.Visible = true
		ScrollbarThumb.Visible = true
		ScrollPadding.PaddingRight = NewUDim(0, 20)
		local trackH = ScrollbarTrack.AbsoluteSize.Y
		local thumbH = MathMax(trackH * (viewH / canvasH), 20)
		local range = canvasH - viewH
		local t = range > 0 and (Scroll.CanvasPosition.Y / range) or 0
		local thumbY = (trackH - thumbH) * t
		ScrollbarThumb.Size = NewUDim2(1, 0, 0, thumbH)
		ScrollbarThumb.Position = NewUDim2(0, 0, 0, thumbY)
	end
	LibRef:Connection(Scroll:GetPropertyChangedSignal("CanvasPosition"), UpdateScrollbar)
	LibRef:Connection(Scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"), UpdateScrollbar)
	LibRef:Connection(Scroll:GetPropertyChangedSignal("AbsoluteWindowSize"), UpdateScrollbar)
	task.defer(UpdateScrollbar)

	local TargetY = 0
	local function ClampTarget()
		local viewH = Scroll.AbsoluteWindowSize.Y
		local canvasH = Scroll.AbsoluteCanvasSize.Y
		local maxY = MathMax(0, canvasH - viewH)
		if TargetY < 0 then TargetY = 0 end
		if TargetY > maxY then TargetY = maxY end
	end

	LibRef:Connection(Scroll.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
		TargetY = TargetY - input.Position.Z * 90
		ClampTarget()
	end)

	LibRef:Connection(RunService.Heartbeat, function(dt)
		ClampTarget()
		local current = Scroll.CanvasPosition.Y
		if MathAbs(current - TargetY) < 0.3 then
			if current ~= TargetY then
				Scroll.CanvasPosition = NewVector2(0, TargetY)
			end
			return
		end
		local alpha = 1 - math.exp(-dt * 14)
		local newY = current + (TargetY - current) * alpha
		Scroll.CanvasPosition = NewVector2(0, newY)
	end)

	local dragging = false
	local dragStartY, startScroll
	LibRef:Connection(ScrollbarThumb.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartY = input.Position.Y
			startScroll = Scroll.CanvasPosition.Y
			LibRef._scrollbarDragging = true
		end
	end)
	LibRef:Connection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			LibRef._scrollbarDragging = false
		end
	end)
	LibRef:Connection(UserInputService.InputChanged, function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local viewH = Scroll.AbsoluteWindowSize.Y
		local canvasH = Scroll.AbsoluteCanvasSize.Y
		local trackH = ScrollbarTrack.AbsoluteSize.Y
		local thumbH = MathMax(trackH * (viewH / canvasH), 20)
		local trackRange = trackH - thumbH
		if trackRange <= 0 then return end
		local dy = input.Position.Y - dragStartY
		local deltaScroll = (dy / trackRange) * (canvasH - viewH)
		TargetY = MathClamp(startScroll + deltaScroll, 0, canvasH - viewH)
	end)

	local function MakeCol(Name, Order)
		local Col = self:CreateInstance("Frame", {
			Name = Name,
			Parent = Scroll,
			LayoutOrder = Order,
			Size = NewUDim2(0.5, -5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		self:CreateInstance("UIListLayout", {
			Parent = Col,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 10),
		})
		return Col
	end
	return MakeCol("LeftColumn", 1), MakeCol("RightColumn", 2)
end

local KeybindModes = { "Hold", "Toggle", "Always" }
local function KeyDisplayName(k)
	if k == nil then return "None" end
	if KeyNames[k] then return KeyNames[k] end
	if typeof(k) == "EnumItem" then return k.Name end
	return tostring(k)
end
local function ParseKeyName(n)
	if n == nil or n == "" or n == "None" then return nil end
	for key, name in pairs(KeyNames) do
		if name == n then return key end
	end
	for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
		if item.Name == n then return item end
	end
	for _, item in ipairs(Enum.UserInputType:GetEnumItems()) do
		if item.Name == n then return item end
	end
	return nil
end

Library.KeybindList = Library.KeybindList or {
	Entries = {},
	OrderedIds = {},
	IsVisible = true,
	Gui = nil,
	Root = nil,
	Rows = nil,
}

local function EnsureKeybindList()
	local KL = Library.KeybindList
	if KL.Gui and KL.Gui.Parent then return end

	local Gui = Library:CreateInstance("ScreenGui", {
		Name = "\0",
		Parent = gethui and gethui() or CoreGui,
		Enabled = KL.IsVisible ~= false,
		DisplayOrder = 998,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local Root = Library:CreateInstance("Frame", {
		Name = "KeybindList",
		Parent = Gui,
		Position = NewUDim2(0, 20, 0, 160),
		Size = NewUDim2(0, 190, 0, 34),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Palette.Default.Background,
		BorderSizePixel = 0,
	})
	Library:CreateInstance("UICorner", { Parent = Root, CornerRadius = NewUDim(0, 8) })

	local Header = Library:CreateInstance("Frame", {
		Name = "Header",
		Parent = Root,
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, 0, 0, 34),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})
	Library:CreateInstance("UICorner", { Parent = Header, CornerRadius = NewUDim(0, 8) })
	local HeaderBottomCoverup = Library:CreateInstance("Frame", {
		Name = "HeaderBottomCoverup",
		Parent = Header,
		AnchorPoint = NewVector2(0, 1),
		Position = NewUDim2(0, 0, 1, 0),
		Size = NewUDim2(1, 0, 0, 6),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
		Visible = false,
	})
	local HeaderDivider = Library:CreateInstance("Frame", {
		Name = "HeaderDivider",
		Parent = Root,
		Position = NewUDim2(0, 0, 0, 34),
		Size = NewUDim2(1, 0, 0, 1),
		BackgroundColor3 = Palette.Default.Divider,
		BorderSizePixel = 0,
		Visible = false,
	})
	Library:CreateInstance("TextLabel", {
		Name = "Title",
		Parent = Header,
		AnchorPoint = NewVector2(0, 0.5),
		Position = NewUDim2(0, 14, 0.5, 0),
		Size = NewUDim2(1, -28, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.SemiBold,
		Text = "Keybinds",
		TextColor3 = FromRgb(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local Rows = Library:CreateInstance("Frame", {
		Name = "Rows",
		Parent = Root,
		Position = NewUDim2(0, 0, 0, 35),
		Size = NewUDim2(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
	})
	Library:CreateInstance("UIListLayout", {
		Parent = Rows,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 0),
	})
	Library:CreateInstance("UIPadding", {
		Parent = Rows,
		PaddingTop = NewUDim(0, 6),
		PaddingBottom = NewUDim(0, 8),
		PaddingLeft = NewUDim(0, 14),
		PaddingRight = NewUDim(0, 14),
	})

	KL.Gui = Gui
	KL.Root = Root
	KL.Header = Header
	KL.Rows = Rows
	KL.HeaderBottomCoverup = HeaderBottomCoverup
	KL.HeaderDivider = HeaderDivider
	KL.Items = {}

	Library:Draggable(Root, Header)
	Root.Active = true
	Header.Active = true
end

function Library.KeybindList:Refresh()
	EnsureKeybindList()
	self.Items = self.Items or {}

	local RowTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local ActiveSet = {}
	local Order = 0
	for _, Id in ipairs(self.OrderedIds) do
		local Entry = self.Entries[Id]
		if Entry and Entry.Active and Entry.Key ~= nil then
			Order = Order + 1
			ActiveSet[Id] = true
			local Item = self.Items[Id]
			if not Item then
				local Frame = Library:CreateInstance("CanvasGroup", {
					Name = "Entry",
					Parent = self.Rows,
					Size = NewUDim2(1, 0, 0, 20),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = Order,
					GroupTransparency = 1,
				})
				local NameLbl = Library:CreateInstance("TextLabel", {
					Name = "Name",
					Parent = Frame,
					AnchorPoint = NewVector2(0, 0.5),
					Position = NewUDim2(0, 0, 0.5, 0),
					Size = NewUDim2(1, -60, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.Regular,
					Text = tostring(Entry.Name or "Keybind"),
					TextColor3 = Palette.Default.SubText,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local KeyLbl = Library:CreateInstance("TextLabel", {
					Name = "Key",
					Parent = Frame,
					AnchorPoint = NewVector2(1, 0.5),
					Position = NewUDim2(1, 0, 0.5, 0),
					Size = NewUDim2(0, 0, 0, 18),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = "[" .. KeyDisplayName(Entry.Key) .. "]",
					TextColor3 = Palette.Default.Accent,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
				Item = { Frame = Frame, Name = NameLbl, Key = KeyLbl }
				self.Items[Id] = Item
				TweenNew(Frame, RowTween, { GroupTransparency = 0 }):Play()
			else
				Item.Frame.LayoutOrder = Order
				Item.Name.Text = tostring(Entry.Name or "Keybind")
				Item.Key.Text = "[" .. KeyDisplayName(Entry.Key) .. "]"
			end
		end
	end

	for Id, Item in pairs(self.Items) do
		if not ActiveSet[Id] then
			self.Items[Id] = nil
			local F = Item.Frame
			TweenNew(F, RowTween, { GroupTransparency = 1 }):Play()
			task.delay(RowTween.Time + 0.02, function()
				if F and F.Parent then F:Destroy() end
			end)
		end
	end

	local Visible = Order > 0
	self.Rows.Visible = Visible
	if self.HeaderBottomCoverup then self.HeaderBottomCoverup.Visible = Visible end
	if self.HeaderDivider then self.HeaderDivider.Visible = Visible end
end

function Library.KeybindList:Register(Id, Name, Key, Active)
	if not self.Entries[Id] then
		Insert(self.OrderedIds, Id)
	end
	self.Entries[Id] = {
		Name = Name or "Keybind",
		Key = Key,
		Active = Active == true,
	}
	self:Refresh()
end

function Library.KeybindList:Update(Id, Name, Key, Active)
	if not self.Entries[Id] then
		self:Register(Id, Name, Key, Active)
		return
	end
	local Entry = self.Entries[Id]
	if Name ~= nil then Entry.Name = Name end
	Entry.Key = Key
	if Active ~= nil then Entry.Active = Active == true end
	self:Refresh()
end

function Library.KeybindList:Unregister(Id)
	if not self.Entries[Id] then return end
	self.Entries[Id] = nil
	for i, v in ipairs(self.OrderedIds) do
		if v == Id then table.remove(self.OrderedIds, i) break end
	end
	self:Refresh()
end

function Library.KeybindList:SetVisible(bool)
	EnsureKeybindList()
	self.IsVisible = bool ~= false
	self.Gui.Enabled = self.IsVisible
end

Library.Notifications = Library.Notifications or {
	Queue = {},
	Gui = nil,
	Host = nil,
}

local NotifyTypeColors = {
	info = function() return Palette.Default.Accent end,
	success = function() return Hex("7ED382") end,
	warning = function() return Hex("E8B857") end,
	error = function() return Hex("E8575C") end,
}

local function EnsureNotifyHost()
	local N = Library.Notifications
	if N.Gui and N.Gui.Parent then return end

	local Gui = Library:CreateInstance("ScreenGui", {
		Name = "\0",
		Parent = gethui and gethui() or CoreGui,
		Enabled = true,
		DisplayOrder = 1000,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local Host = Library:CreateInstance("Frame", {
		Name = "NotifyHost",
		Parent = Gui,
		Position = NewUDim2(1, -20, 0, 0),
		AnchorPoint = NewVector2(1, 0),
		Size = NewUDim2(0, 360, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	N.Gui = Gui
	N.Host = Host
end

function Library.Notifications:Refresh(Animated)
	EnsureNotifyHost()
	local List = self.Queue
	for I = #List, 1, -1 do
		local Item = List[I]
		if not (Item and Item.Frame and Item.Frame.Parent) then
			table.remove(List, I)
		end
	end
	local Y = 60
	for _, Item in ipairs(List) do
		local Target = NewUDim2(0, 0, 0, Y)
		if Animated then
			TweenNew(Item.Frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = Target }):Play()
		else
			Item.Frame.Position = Target
		end
		Y = Y + Item.Frame.AbsoluteSize.Y + 10
	end
end

function Library:Notify(opts)
	opts = typeof(opts) == "table" and opts or {}
	local Title = tostring(opts.Title or opts.Name or "Message")
	local Desc = tostring(opts.Description or opts.Info or opts.Text or "")
	local Life = tonumber(opts.Duration) or 4
	if Life <= 0 then Life = 0.1 end
	local Type = tostring(opts.Type or "info"):lower()
	local AccentFn = NotifyTypeColors[Type] or NotifyTypeColors.info
	local Accent = AccentFn()

	EnsureNotifyHost()
	local Host = self.Notifications.Host

	local Card = self:CreateInstance("Frame", {
		Name = "Notify",
		Parent = Host,
		Size = NewUDim2(1, 0, 0, 96),
		Position = NewUDim2(1, 380, 0, 0),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 10,
	})
	self:CreateInstance("UICorner", { Parent = Card, CornerRadius = NewUDim(0, 8) })

	self:CreateInstance("ImageLabel", {
		Name = "TypeIcon",
		Parent = Card,
		AnchorPoint = NewVector2(0, 0.5),
		Position = NewUDim2(0, 14, 0, 21),
		Size = NewUDim2(0, 18, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://116166634119153",
		ImageColor3 = Accent,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 12,
	})

	local TitleLbl = self:CreateInstance("TextLabel", {
		Name = "Title",
		Parent = Card,
		Position = NewUDim2(0, 38, 0, 12),
		Size = NewUDim2(1, -70, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.SemiBold,
		Text = Title,
		TextColor3 = FromRgb(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 12,
	})

	self:CreateInstance("Frame", {
		Name = "TitleDivider",
		Parent = Card,
		Position = NewUDim2(0, 14, 0, 40),
		Size = NewUDim2(1, -28, 0, 1),
		BackgroundColor3 = Palette.Default.Divider,
		BorderSizePixel = 0,
		ZIndex = 12,
	})

	local DescLbl = self:CreateInstance("TextLabel", {
		Name = "Desc",
		Parent = Card,
		Position = NewUDim2(0, 14, 0, 50),
		Size = NewUDim2(1, -28, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.Regular,
		Text = Desc,
		TextColor3 = Palette.Default.SubText,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 12,
	})

	local CloseBtn = self:CreateInstance("TextButton", {
		Name = "Close",
		Parent = Card,
		AnchorPoint = NewVector2(1, 0),
		Position = NewUDim2(1, -10, 0, 8),
		Size = NewUDim2(0, 18, 0, 18),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Palette.Default.SubText,
		TextSize = 18,
		FontFace = Library.Fonts.SemiBold,
		ZIndex = 13,
	})

	local BarBg = self:CreateInstance("Frame", {
		Name = "BarBg",
		Parent = Card,
		AnchorPoint = NewVector2(0, 1),
		Position = NewUDim2(0, 14, 1, -10),
		Size = NewUDim2(1, -28, 0, 4),
		BackgroundColor3 = Palette.Default.TabBackground,
		BorderSizePixel = 0,
		ZIndex = 12,
	})
	self:CreateInstance("UICorner", { Parent = BarBg, CornerRadius = NewUDim(1, 0) })

	local BarFill = self:CreateInstance("Frame", {
		Name = "BarFill",
		Parent = BarBg,
		Size = NewUDim2(1, 0, 1, 0),
		BackgroundColor3 = Accent,
		BorderSizePixel = 0,
		ZIndex = 13,
	})
	self:CreateInstance("UICorner", { Parent = BarFill, CornerRadius = NewUDim(1, 0) })

	local Entry = { Frame = Card }
	Insert(self.Notifications.Queue, Entry)
	self.Notifications:Refresh(false)

	local Target = Card.Position
	Card.Position = NewUDim2(1, 380, 0, Target.Y.Offset)
	TweenNew(Card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = Target }):Play()
	TweenNew(BarFill, TweenInfo.new(Life, Enum.EasingStyle.Linear), { Size = NewUDim2(0, 0, 1, 0) }):Play()

	local Closed = false
	local function CloseNow()
		if Closed then return end
		Closed = true
		for I, Item in ipairs(self.Notifications.Queue) do
			if Item == Entry then table.remove(self.Notifications.Queue, I); break end
		end
		TweenNew(Card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = NewUDim2(1, 380, 0, Card.Position.Y.Offset),
		}):Play()
		task.delay(0.25, function()
			if Card and Card.Parent then Card:Destroy() end
			self.Notifications:Refresh(true)
		end)
	end

	self:Connection(CloseBtn.MouseButton1Click, CloseNow)
	task.delay(Life, CloseNow)

	return { Close = CloseNow }
end

function Library:MountKeybind(parent, opts)
	opts = typeof(opts) == "table" and opts or {}
	local Key = opts.Key
	local ModeIdx = 1
	for i, m in ipairs(KeybindModes) do
		if m == opts.Mode then ModeIdx = i break end
	end
	local Callback = typeof(opts.Callback) == "function" and opts.Callback or function() end
	local ListName = typeof(opts.Name) == "string" and opts.Name or nil
	local GearColor = Hex("494A54")

	local Row = self:CreateInstance("Frame", {
		Name = "KeybindWidget",
		Parent = parent,
		AnchorPoint = NewVector2(1, 0.5),
		Position = NewUDim2(1, 0, 0.5, 0),
		Size = NewUDim2(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UIListLayout", {
		Parent = Row,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 6),
	})

	local LabelColor = Hex("3F414A")
	local ModeBtn = self:CreateInstance("TextButton", {
		Name = "Mode",
		Parent = Row,
		LayoutOrder = 1,
		AutoButtonColor = false,
		Text = "[" .. KeybindModes[ModeIdx] .. "]",
		Size = NewUDim2(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.Regular,
		TextColor3 = LabelColor,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	local Sep = self:CreateInstance("TextLabel", {
		Name = "Sep",
		Parent = Row,
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = NewUDim2(0, 10, 1, 0),
		FontFace = Library.Fonts.Regular,
		Text = "\xE2\x86\x94",
		TextColor3 = LabelColor,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	local KeyBtn = self:CreateInstance("TextButton", {
		Name = "Key",
		Parent = Row,
		LayoutOrder = 3,
		AutoButtonColor = false,
		Text = "[" .. KeyDisplayName(Key) .. "]",
		Size = NewUDim2(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.Regular,
		TextColor3 = LabelColor,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	local Gear = self:CreateInstance("ImageButton", {
		Name = "Gear",
		Parent = Row,
		LayoutOrder = 4,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = NewUDim2(0, 16, 0, 16),
		Image = "rbxassetid://111187482009453",
		ImageColor3 = GearColor,
		ScaleType = Enum.ScaleType.Fit,
	})

	local LibRef = self
	local Listening = false

	local function Render()
		ModeBtn.Text = "[" .. KeybindModes[ModeIdx] .. "]"
		KeyBtn.Text = Listening and "[...]" or ("[" .. KeyDisplayName(Key) .. "]")
	end

	local KbObj = { Row = Row, Mode = ModeBtn, Key = KeyBtn, Gear = Gear }
	local ListId = tostring(KbObj)
	local Active = false
	local function IsListActive()
		if Key == nil then return false end
		if KeybindModes[ModeIdx] == "Always" then return true end
		return Active == true
	end
	local function SyncList()
		if ListName then
			Library.KeybindList:Update(ListId, ListName, Key, IsListActive())
		end
	end

	local function FireActive(newActive)
		if Active == newActive then return end
		Active = newActive
		SyncList()
		Callback(Active)
	end
	local function EvalMode()
		if KeybindModes[ModeIdx] == "Always" then
			FireActive(true)
		elseif KeybindModes[ModeIdx] == "Hold" and not Key then
			FireActive(false)
		end
		SyncList()
	end

	LibRef:Connection(ModeBtn.MouseButton1Click, function()
		ModeIdx = (ModeIdx % #KeybindModes) + 1
		Render()
		EvalMode()
	end)
	LibRef:Connection(KeyBtn.MouseButton1Click, function()
		Listening = true
		Render()
	end)
	LibRef:Connection(Gear.MouseButton1Click, function()
		Key = nil
		Listening = false
		Render()
		if KeybindModes[ModeIdx] == "Hold" then FireActive(false) end
		SyncList()
	end)
	LibRef:Connection(UserInputService.InputBegan, function(input, processed)
		if Listening then
			if processed then return end
			local t = input.UserInputType
			if t == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					Key = nil
				else
					Key = input.KeyCode
				end
			elseif t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
				Key = t
			else
				return
			end
			Listening = false
			Render()
			SyncList()
			return
		end
		if processed then return end
		if not Key or KeybindModes[ModeIdx] == "Always" then return end
		local pressed = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
		if pressed == Key then
			if KeybindModes[ModeIdx] == "Toggle" then
				FireActive(not Active)
			elseif KeybindModes[ModeIdx] == "Hold" then
				FireActive(true)
			end
		end
	end)
	LibRef:Connection(UserInputService.InputEnded, function(input, processed)
		if processed then return end
		if not Key or KeybindModes[ModeIdx] ~= "Hold" then return end
		local pressed = input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode or input.UserInputType
		if pressed == Key then
			FireActive(false)
		end
	end)

	Render()
	if ListName then
		Library.KeybindList:Register(ListId, ListName, Key, IsListActive())
	end
	if KeybindModes[ModeIdx] == "Always" then
		task.defer(function() FireActive(true) end)
	end

	function KbObj:Get() return Key, KeybindModes[ModeIdx], Active end
	function KbObj:Set(k, m)
		Key = k
		if m then
			for i, mm in ipairs(KeybindModes) do
				if mm == m then ModeIdx = i break end
			end
		end
		Render()
		EvalMode()
		SyncList()
	end
	return KbObj
end

function Library:MountColorpicker(Swatch, Default, Callback)
	local Color = typeof(Default) == "Color3" and Default or FromRgb(255, 255, 255)
	Callback = typeof(Callback) == "function" and Callback or function() end
	local h, s, v = Color:ToHSV()
	local a = 1

	Swatch.ImageColor3 = Color

	local Gui = Swatch:FindFirstAncestorOfClass("ScreenGui")

	local Panel = self:CreateInstance("CanvasGroup", {
		Name = "ColorpickerPanel",
		Parent = Gui,
		Size = NewUDim2(0, 234, 0, 254),
		BackgroundColor3 = Palette.Default.ColorBg,
		BorderSizePixel = 0,
		Visible = false,
		GroupTransparency = 1,
		ZIndex = 80,
	})
	self:CreateInstance("UICorner", { Parent = Panel, CornerRadius = NewUDim(0, 8) })
	self:CreateInstance("UIPadding", {
		Parent = Panel,
		PaddingTop = NewUDim(0, 10),
		PaddingBottom = NewUDim(0, 10),
		PaddingLeft = NewUDim(0, 10),
		PaddingRight = NewUDim(0, 10),
	})

	local SVBox = self:CreateInstance("TextButton", {
		Name = "SV",
		Parent = Panel,
		AutoButtonColor = false,
		Text = "",
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, -40, 1, -40),
		BackgroundColor3 = FromHsv(h, 1, 1),
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = SVBox, CornerRadius = NewUDim(0, 4) })
	local SatGrad = self:CreateInstance("Frame", {
		Name = "SatGradient",
		Parent = SVBox,
		Size = NewUDim2(1, 0, 1, 0),
		BackgroundColor3 = FromRgb(255, 255, 255),
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = SatGrad, CornerRadius = NewUDim(0, 4) })
	self:CreateInstance("UIGradient", {
		Parent = SatGrad,
		Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 0),
			NewNumberSequenceKeypoint(1, 1),
		}),
	})
	local ValGrad = self:CreateInstance("Frame", {
		Name = "ValGradient",
		Parent = SVBox,
		Size = NewUDim2(1, 0, 1, 0),
		BackgroundColor3 = FromRgb(0, 0, 0),
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = ValGrad, CornerRadius = NewUDim(0, 4) })
	self:CreateInstance("UIGradient", {
		Parent = ValGrad,
		Rotation = 90,
		Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 1),
			NewNumberSequenceKeypoint(1, 0),
		}),
	})
	local SVThumb = self:CreateInstance("Frame", {
		Name = "SVThumb",
		Parent = SVBox,
		AnchorPoint = NewVector2(0.5, 0.5),
		Position = NewUDim2(s, 0, 1 - v, 0),
		Size = NewUDim2(0, 10, 0, 10),
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
		ZIndex = 82,
	})
	self:CreateInstance("UICorner", { Parent = SVThumb, CornerRadius = NewUDim(1, 0) })
	self:CreateInstance("UIStroke", {
		Parent = SVThumb,
		Color = FromRgb(255, 255, 255),
		Thickness = 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})

	local HueBar = self:CreateInstance("TextButton", {
		Name = "Hue",
		Parent = Panel,
		AutoButtonColor = false,
		Text = "",
		AnchorPoint = NewVector2(1, 0),
		Position = NewUDim2(1, -18, 0, 0),
		Size = NewUDim2(0, 10, 1, -40),
		BackgroundColor3 = FromRgb(255, 255, 255),
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = HueBar, CornerRadius = NewUDim(0, 4) })
	self:CreateInstance("UIGradient", {
		Parent = HueBar,
		Rotation = 90,
		Color = NewColorSequence({
			NewColorSequenceKeypoint(0, FromRgb(255, 0, 0)),
			NewColorSequenceKeypoint(0.17, FromRgb(255, 255, 0)),
			NewColorSequenceKeypoint(0.33, FromRgb(0, 255, 0)),
			NewColorSequenceKeypoint(0.5, FromRgb(0, 255, 255)),
			NewColorSequenceKeypoint(0.67, FromRgb(0, 0, 255)),
			NewColorSequenceKeypoint(0.83, FromRgb(255, 0, 255)),
			NewColorSequenceKeypoint(1, FromRgb(255, 0, 0)),
		}),
	})
	local HueThumb = self:CreateInstance("Frame", {
		Name = "HueThumb",
		Parent = HueBar,
		AnchorPoint = NewVector2(0.5, 0.5),
		Position = NewUDim2(0.5, 0, h, 0),
		Size = NewUDim2(0, 14, 0, 14),
		BackgroundColor3 = FromRgb(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 82,
	})
	self:CreateInstance("UICorner", { Parent = HueThumb, CornerRadius = NewUDim(1, 0) })

	local AlphaBar = self:CreateInstance("TextButton", {
		Name = "Alpha",
		Parent = Panel,
		AutoButtonColor = false,
		Text = "",
		AnchorPoint = NewVector2(1, 0),
		Position = NewUDim2(1, 0, 0, 0),
		Size = NewUDim2(0, 10, 1, -40),
		BackgroundColor3 = FromRgb(0, 0, 0),
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = AlphaBar, CornerRadius = NewUDim(0, 4) })
	local AlphaColor = self:CreateInstance("Frame", {
		Name = "AlphaColor",
		Parent = AlphaBar,
		Size = NewUDim2(1, 0, 1, 0),
		BackgroundColor3 = Color,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = AlphaColor, CornerRadius = NewUDim(0, 4) })
	self:CreateInstance("UIGradient", {
		Parent = AlphaColor,
		Rotation = 90,
		Transparency = NewNumberSequence({
			NewNumberSequenceKeypoint(0, 1),
			NewNumberSequenceKeypoint(1, 0),
		}),
	})
	local AlphaThumb = self:CreateInstance("Frame", {
		Name = "AlphaThumb",
		Parent = AlphaBar,
		AnchorPoint = NewVector2(0.5, 0.5),
		Position = NewUDim2(0.5, 0, a, 0),
		Size = NewUDim2(0, 14, 0, 14),
		BackgroundColor3 = FromRgb(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 82,
	})
	self:CreateInstance("UICorner", { Parent = AlphaThumb, CornerRadius = NewUDim(1, 0) })

	local HexRow = self:CreateInstance("Frame", {
		Name = "HexRow",
		Parent = Panel,
		AnchorPoint = NewVector2(0, 1),
		Position = NewUDim2(0, 0, 1, 0),
		Size = NewUDim2(1, 0, 0, 32),
		BackgroundColor3 = Palette.Default.ColorBg2,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", { Parent = HexRow, CornerRadius = NewUDim(0, 6) })

	local HexLbl = self:CreateInstance("TextLabel", {
		Name = "HexText",
		Parent = HexRow,
		AnchorPoint = NewVector2(0, 0.5),
		Position = NewUDim2(0, 12, 0.5, 0),
		Size = NewUDim2(1, -40, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.SemiBold,
		Text = "",
		TextColor3 = FromRgb(255, 255, 255),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local CopyBtn = self:CreateInstance("ImageButton", {
		Name = "Copy",
		Parent = HexRow,
		AnchorPoint = NewVector2(1, 0.5),
		Position = NewUDim2(1, -10, 0.5, 0),
		Size = NewUDim2(0, 16, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Image = "rbxassetid://135705643707873",
		ImageColor3 = FromRgb(190, 190, 200),
		ScaleType = Enum.ScaleType.Fit,
	})

	local function HexString()
		local r = MathFloor(Color.R * 255 + 0.5)
		local g = MathFloor(Color.G * 255 + 0.5)
		local b = MathFloor(Color.B * 255 + 0.5)
		local op = MathFloor(a * 255 + 0.5)
		return string.format("#%02X%02X%02X%02X", r, g, b, op)
	end

	local function ApplyColor()
		Color = FromHsv(h, s, v)
		Swatch.ImageColor3 = Color
		SVBox.BackgroundColor3 = FromHsv(h, 1, 1)
		SVThumb.Position = NewUDim2(s, 0, 1 - v, 0)
		SVThumb.BackgroundColor3 = Color
		HueThumb.Position = NewUDim2(0.5, 0, h, 0)
		AlphaColor.BackgroundColor3 = Color
		AlphaThumb.Position = NewUDim2(0.5, 0, a, 0)
		HexLbl.Text = HexString()
		Callback(Color, 1 - a)
	end

	local LibRef = self
	LibRef:Connection(CopyBtn.MouseButton1Click, function()
		setclipboard(HexString())
		CopyBtn.Image = "rbxassetid://71724879216117"
		task.delay(1.2, function()
			if CopyBtn.Parent then
				CopyBtn.Image = "rbxassetid://135705643707873"
			end
		end)
	end)

	local DraggingSV, DraggingHue, DraggingAlpha = false, false, false
	local function UpdateSV(px, py)
		local ap = SVBox.AbsolutePosition
		local asz = SVBox.AbsoluteSize
		if asz.X <= 0 or asz.Y <= 0 then return end
		s = MathClamp((px - ap.X) / asz.X, 0, 1)
		v = 1 - MathClamp((py - ap.Y) / asz.Y, 0, 1)
		ApplyColor()
	end
	local function UpdateHue(py)
		local ap = HueBar.AbsolutePosition
		local asz = HueBar.AbsoluteSize
		if asz.Y <= 0 then return end
		h = MathClamp((py - ap.Y) / asz.Y, 0, 1)
		ApplyColor()
	end
	local function UpdateAlpha(py)
		local ap = AlphaBar.AbsolutePosition
		local asz = AlphaBar.AbsoluteSize
		if asz.Y <= 0 then return end
		a = MathClamp((py - ap.Y) / asz.Y, 0, 1)
		ApplyColor()
	end

	LibRef:Connection(SVBox.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			DraggingSV = true
			UpdateSV(input.Position.X, input.Position.Y)
		end
	end)
	LibRef:Connection(HueBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			DraggingHue = true
			UpdateHue(input.Position.Y)
		end
	end)
	LibRef:Connection(AlphaBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			DraggingAlpha = true
			UpdateAlpha(input.Position.Y)
		end
	end)
	LibRef:Connection(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if DraggingSV then UpdateSV(input.Position.X, input.Position.Y) end
		if DraggingHue then UpdateHue(input.Position.Y) end
		if DraggingAlpha then UpdateAlpha(input.Position.Y) end
	end)
	LibRef:Connection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			DraggingSV = false
			DraggingHue = false
			DraggingAlpha = false
		end
	end)

	local PanelTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Open = false
	local function SetOpen(o)
		Open = o
		if o then
			local sp = Swatch.AbsolutePosition
			local ss = Swatch.AbsoluteSize
			Panel.Position = NewUDim2(0, sp.X + ss.X - 234, 0, sp.Y + ss.Y + 33 - 6)
			Panel.Visible = true
			Panel.GroupTransparency = 1
			TweenNew(Panel, PanelTween, {
				GroupTransparency = 0,
				Position = NewUDim2(0, sp.X + ss.X - 234, 0, sp.Y + ss.Y + 33),
			}):Play()
		else
			TweenNew(Panel, PanelTween, { GroupTransparency = 1 }):Play()
			task.delay(PanelTween.Time, function()
				if Panel.GroupTransparency > 0.99 then
					Panel.Visible = false
				end
			end)
		end
	end

	LibRef:Connection(Swatch.MouseButton1Click, function()
		SetOpen(not Open)
	end)
	LibRef:Connection(UserInputService.InputBegan, function(input)
		if not Open then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local mx, my = input.Position.X, input.Position.Y
		local function inside(g)
			local p, s2 = g.AbsolutePosition, g.AbsoluteSize
			return mx >= p.X and mx <= p.X + s2.X and my >= p.Y and my <= p.Y + s2.Y
		end
		if not inside(Swatch) and not inside(Panel) then
			SetOpen(false)
		end
	end)

	ApplyColor()

	local CpObj = { Swatch = Swatch, Panel = Panel }
	function CpObj:Get() return Color, 1 - a end
	function CpObj:Set(c, transparency)
		if typeof(c) == "Color3" then
			h, s, v = c:ToHSV()
		end
		if typeof(transparency) == "number" then
			a = 1 - MathClamp(transparency, 0, 1)
		end
		ApplyColor()
	end
	return CpObj
end

function Library:CreateSection(Parent, Title)
	local Container = self:CreateInstance("Frame", {
		Name = "SectionContainer",
		Parent = Parent,
		Size = NewUDim2(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UIListLayout", {
		Parent = Container,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 6),
	})

	local TitleLbl = self:CreateInstance("TextLabel", {
		Name = "Title",
		Parent = Container,
		LayoutOrder = 1,
		Size = NewUDim2(1, 0, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.SemiBold,
		Text = tostring(Title or "Section"),
		TextColor3 = FromRgb(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local SectionFrame = self:CreateInstance("Frame", {
		Name = "Section",
		Parent = Container,
		LayoutOrder = 2,
		Size = NewUDim2(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Palette.Default.SectionBackground,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", {
		Parent = SectionFrame,
		CornerRadius = NewUDim(0, 8),
	})
	self:CreateInstance("UIPadding", {
		Parent = SectionFrame,
		PaddingTop = NewUDim(0, 14),
		PaddingBottom = NewUDim(0, 14),
		PaddingLeft = NewUDim(0, 14),
		PaddingRight = NewUDim(0, 14),
	})
	self:CreateInstance("UIListLayout", {
		Parent = SectionFrame,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 10),
	})

	local LibRef = self
	local GroupboxObj = {
		Name = tostring(Title or "Section"),
		Container = Container,
		Frame = SectionFrame,
		Title = TitleLbl,
	}

	local function PreElement(gb)
		if gb._needsDivider then
			LibRef:CreateInstance("Frame", {
				Name = "AutoDivider",
				Parent = gb.Frame,
				Size = NewUDim2(1, 0, 0, 1),
				BackgroundColor3 = Palette.Default.Divider,
				BorderSizePixel = 0,
			})
		end
		gb._needsDivider = true
	end

	function GroupboxObj:AddDivider()
		local Div = LibRef:CreateInstance("Frame", {
			Name = "Divider",
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 1),
			BackgroundColor3 = Palette.Default.Divider,
			BorderSizePixel = 0,
		})
		self._needsDivider = false
		return Div
	end

	function GroupboxObj:AddToggle(Name, Default, Callback)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Toggle"
			Default = o.Default
			Callback = o.Callback
			Flag = o.Flag
		end
		local State = Default == true
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		Callback = UserCallback

		local Btn = LibRef:CreateInstance("TextButton", {
			Name = "Toggle_" .. tostring(Name or "Toggle"),
			Parent = self.Frame,
			AutoButtonColor = false,
			Text = "",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = NewUDim2(1, 0, 0, 20),
		})

		local Box = LibRef:CreateInstance("Frame", {
			Name = "Box",
			Parent = Btn,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 0, 0.5, 0),
			Size = NewUDim2(0, 18, 0, 18),
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", {
			Parent = Box,
			CornerRadius = NewUDim(0, 4),
		})

		local Check = LibRef:CreateInstance("TextLabel", {
			Name = "Check",
			Parent = Box,
			Size = NewUDim2(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.SemiBold,
			Text = "✓",
			TextColor3 = Palette.Default.Background,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTransparency = 1,
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Btn,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 26, 0.5, 0),
			Size = NewUDim2(1, -56, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Toggle"),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local TweenColor = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local TweenPop = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local function Render()
			TweenNew(Box, TweenColor, {
				BackgroundColor3 = State and Palette.Default.Accent or Palette.Default.TabBackground,
			}):Play()
			TweenNew(Check, TweenPop, {
				TextTransparency = State and 0 or 1,
				TextSize = State and 14 or 10,
			}):Play()
			TweenNew(Lbl, TweenColor, {
				TextColor3 = State and FromRgb(255, 255, 255) or Palette.Default.SubText,
			}):Play()
		end

		local ToggleObj = { Name = tostring(Name or "Toggle"), Button = Btn, Box = Box, Check = Check, Label = Lbl }
		LibRef:RegisterThemeRenderer(function() if Btn.Parent then Render() end end)
		local NotifyFlag = LibRef:RegisterFlag("Toggles", Flag, ToggleObj, State)
		Callback = function(s) NotifyFlag(s); UserCallback(s) end
		function ToggleObj:Get() return State end
		function ToggleObj:Set(v)
			State = v == true
			Render()
			Callback(State)
		end

		function ToggleObj:AddColorpicker(Default, Cb)
			local CpFlag
			if typeof(Default) == "table" then
				local o = Default
				Default = o.Default
				Cb = o.Callback
				CpFlag = o.Flag
			end
			local Color = typeof(Default) == "Color3" and Default or FromRgb(255, 255, 255)
			local Swatch = LibRef:CreateInstance("ImageButton", {
				Name = "Swatch",
				Parent = Btn,
				AnchorPoint = NewVector2(1, 0.5),
				Position = NewUDim2(1, 0, 0.5, 0),
				Size = NewUDim2(0, 19, 0, 19),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Image = "rbxassetid://80230152894065",
				ImageColor3 = Color,
				ScaleType = Enum.ScaleType.Fit,
			})
			local UserCpCb = typeof(Cb) == "function" and Cb or function() end
			local Cp = LibRef:MountColorpicker(Swatch, Color, function(c, t)
				if Cp and Cp.Flag then
					Cp.Value = c
					Cp.Transparency = t
					for _, lcb in ipairs(Cp._changedListeners) do lcb(c, t) end
				end
				UserCpCb(c, t)
			end)
			if CpFlag and CpFlag ~= "" then
				Cp.Flag = CpFlag
				Cp.Value = Color
				Cp.Transparency = 0
				Cp._changedListeners = {}
				function Cp:OnChanged(cb) Insert(self._changedListeners, cb); return self end
				function Cp:SetValue(c, t) return self:Set(c, t) end
				LibRef.Options[CpFlag] = Cp
			end
			LibRef:RegisterFlagSerializer((GroupboxObj and GroupboxObj.Name or "Section") .. "::ToggleColor::" .. tostring(Name or "Toggle"), {
				serialize = function()
					local c, t = Cp:Get()
					return string.format("%d,%d,%d,%d",
						MathFloor(c.R * 255 + 0.5),
						MathFloor(c.G * 255 + 0.5),
						MathFloor(c.B * 255 + 0.5),
						MathFloor((t or 0) * 255 + 0.5))
				end,
				deserialize = function(s)
					local r, g, b, a = s:match("^(%d+),(%d+),(%d+),(%d+)$")
					if r then
						Cp:Set(FromRgb(tonumber(r), tonumber(g), tonumber(b)), tonumber(a) / 255)
					end
				end,
			})
			return Cp
		end

		function ToggleObj:AddKeybind(DefaultKey, DefaultMode, Cb)
			local KbFlag
			if typeof(DefaultKey) == "table" then
				local o = DefaultKey
				DefaultKey = o.Default or o.Key
				DefaultMode = o.Mode
				Cb = o.Callback
				KbFlag = o.Flag
			end
			local UserKbCb = typeof(Cb) == "function" and Cb or function() end
			local Kb
			Kb = LibRef:MountKeybind(Btn, {
				Key = DefaultKey,
				Mode = DefaultMode,
				Name = tostring(Name or "Toggle"),
				Callback = function(active)
					ToggleObj:Set(active)
					if Kb and Kb.Flag then
						Kb.Value = active
						for _, lcb in ipairs(Kb._changedListeners) do lcb(active) end
					end
					UserKbCb(active)
				end,
			})
			local _, _, initialActive = Kb:Get()
			ToggleObj:Set(initialActive == true)
			if KbFlag and KbFlag ~= "" then
				Kb.Flag = KbFlag
				Kb.Value = false
				Kb._changedListeners = {}
				function Kb:OnChanged(cb) Insert(self._changedListeners, cb); return self end
				function Kb:SetValue(k, m) Kb:Set(k, m) end
				LibRef.Options[KbFlag] = Kb
			end
			LibRef:RegisterFlagSerializer((GroupboxObj and GroupboxObj.Name or "Section") .. "::ToggleKeybind::" .. tostring(Name or "Toggle"), {
				serialize = function()
					local k, m = Kb:Get()
					return (m or "Hold") .. "|" .. KeyDisplayName(k)
				end,
				deserialize = function(s)
					local m, kn = s:match("^([^|]+)|(.*)$")
					if m then Kb:Set(ParseKeyName(kn or ""), m) end
				end,
			})
			return Kb
		end

		LibRef:Connection(Btn.MouseButton1Click, function()
			ToggleObj:Set(not State)
		end)

		LibRef:RegisterFlagSerializer(self.Name .. "::Toggle::" .. tostring(Name or "Toggle"), {
			serialize = function() return State and "1" or "0" end,
			deserialize = function(s) ToggleObj:Set(s == "1") end,
		})

		Render()
		return ToggleObj
	end

	function GroupboxObj:AddSlider(Name, Min, Max, Default, Callback, Type)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Slider"
			Min = o.Min
			Max = o.Max
			Default = o.Default
			Callback = o.Callback
			Type = o.Suffix or o.Type
			Flag = o.Flag
		end
		Min = tonumber(Min) or 0
		Max = tonumber(Max) or 100
		local Value = MathClamp(tonumber(Default) or Min, Min, Max)
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		Callback = UserCallback
		local Suffix = typeof(Type) == "string" and Type or ""

		local Container = LibRef:CreateInstance("Frame", {
			Name = "Slider_" .. tostring(Name or "Slider"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Container,
			Position = NewUDim2(0, 0, 0, 0),
			Size = NewUDim2(1, 0, 0, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Slider"),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Val = LibRef:CreateInstance("TextLabel", {
			Name = "Value",
			Parent = Container,
			AnchorPoint = NewVector2(1, 0),
			Position = NewUDim2(1, 0, 0, 0),
			Size = NewUDim2(0, 0, 0, 14),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = "( " .. Value .. Suffix .. " )",
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Track = LibRef:CreateInstance("TextButton", {
			Name = "Track",
			Parent = Container,
			AutoButtonColor = false,
			Text = "",
			Position = NewUDim2(0, 0, 1, -9),
			Size = NewUDim2(1, 0, 0, 7),
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", { Parent = Track, CornerRadius = NewUDim(1, 0) })

		local Fill = LibRef:CreateInstance("Frame", {
			Name = "Fill",
			Parent = Track,
			Size = NewUDim2(0, 0, 1, 0),
			BackgroundColor3 = Palette.Default.Accent,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", { Parent = Fill, CornerRadius = NewUDim(1, 0) })
		local FillGradient = LibRef:CreateInstance("UIGradient", {
			Parent = Fill,
			Color = NewColorSequence({
				NewColorSequenceKeypoint(0, Palette.Default.Accent),
				NewColorSequenceKeypoint(1, Palette.Default.AccentTwo),
			}),
		})
		LibRef:BindThemedGradient(FillGradient, { "Accent", "AccentTwo" })

		local Thumb = LibRef:CreateInstance("Frame", {
			Name = "Thumb",
			Parent = Track,
			AnchorPoint = NewVector2(0.5, 0.5),
			Position = NewUDim2(0, 0, 0.5, 0),
			Size = NewUDim2(0, 12, 0, 12),
			BackgroundColor3 = FromRgb(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 3,
		})
		LibRef:CreateInstance("UICorner", { Parent = Thumb, CornerRadius = NewUDim(1, 0) })

		local ThumbGlow = LibRef:CreateInstance("Frame", {
			Name = "ThumbGlow",
			Parent = Thumb,
			AnchorPoint = NewVector2(0.5, 0.5),
			Position = NewUDim2(0.5, 0, 0.5, 0),
			Size = NewUDim2(1, 4, 1, 4),
			BackgroundColor3 = FromRgb(255, 255, 255),
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			ZIndex = 2,
		})
		LibRef:CreateInstance("UICorner", { Parent = ThumbGlow, CornerRadius = NewUDim(1, 0) })

		local VisualT = (Value - Min) / (Max - Min)
		local TargetT = VisualT
		Fill.Size = NewUDim2(VisualT, 6 - 12 * VisualT, 1, 0)
		Thumb.Position = NewUDim2(VisualT, 6 - 12 * VisualT, 0.5, 0)
		local function Render()
			TargetT = (Value - Min) / (Max - Min)
			Val.Text = "( " .. tostring(Value) .. Suffix .. " )"
		end
		LibRef:Connection(RunService.Heartbeat, function(dt)
			if MathAbs(TargetT - VisualT) < 0.0005 then
				return
			end
			local alpha = 1 - math.exp(-dt * 9)
			VisualT = VisualT + (TargetT - VisualT) * alpha
			local offX = 6 - 12 * VisualT
			Fill.Size = NewUDim2(VisualT, offX, 1, 0)
			Thumb.Position = NewUDim2(VisualT, offX, 0.5, 0)
		end)

		local Dragging = false
		local function UpdateFromInput(px)
			local absX = Track.AbsolutePosition.X
			local absW = Track.AbsoluteSize.X
			if absW <= 0 then return end
			local t = MathClamp((px - absX) / absW, 0, 1)
			Value = MathFloor(Min + t * (Max - Min) + 0.5)
			Render()
			Callback(Value)
		end

		LibRef:Connection(Track.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				UpdateFromInput(input.Position.X)
			end
		end)
		LibRef:Connection(Track.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = false
			end
		end)
		LibRef:Connection(UserInputService.InputChanged, function(input)
			if not Dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				UpdateFromInput(input.Position.X)
			end
		end)

		Render()

		local SliderObj = { Name = tostring(Name or "Slider"), Container = Container, Track = Track, Fill = Fill, Thumb = Thumb, Label = Lbl, ValueLabel = Val }
		local NotifyFlag = LibRef:RegisterFlag("Options", Flag, SliderObj, Value)
		Callback = function(v) NotifyFlag(v); UserCallback(v) end
		function SliderObj:Get() return Value end
		function SliderObj:Set(v)
			Value = MathClamp(tonumber(v) or Value, Min, Max)
			Render()
			Callback(Value)
		end

		LibRef:RegisterFlagSerializer(self.Name .. "::Slider::" .. tostring(Name or "Slider"), {
			serialize = function() return tostring(Value) end,
			deserialize = function(s) SliderObj:Set(tonumber(s)) end,
		})
		return SliderObj
	end

	function GroupboxObj:AddRangeSlider(Name, Min, Max, DefaultLow, DefaultHigh, Callback, Type)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Range"
			Min = o.Min
			Max = o.Max
			if typeof(o.Default) == "table" then
				DefaultLow = o.Default.Min or o.Default[1]
				DefaultHigh = o.Default.Max or o.Default[2]
			else
				DefaultLow = o.DefaultLow
				DefaultHigh = o.DefaultHigh
			end
			Callback = o.Callback
			Type = o.Suffix or o.Type
			Flag = o.Flag
		end
		Min = tonumber(Min) or 0
		Max = tonumber(Max) or 100
		local Low = MathClamp(tonumber(DefaultLow) or Min, Min, Max)
		local High = MathClamp(tonumber(DefaultHigh) or Max, Min, Max)
		if Low > High then Low, High = High, Low end
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		Callback = UserCallback
		local Suffix = typeof(Type) == "string" and Type or ""

		local Container = LibRef:CreateInstance("Frame", {
			Name = "RangeSlider_" .. tostring(Name or "Slider"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Container,
			Position = NewUDim2(0, 0, 0, 0),
			Size = NewUDim2(1, 0, 0, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Range"),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Val = LibRef:CreateInstance("TextLabel", {
			Name = "Value",
			Parent = Container,
			AnchorPoint = NewVector2(1, 0),
			Position = NewUDim2(1, 0, 0, 0),
			Size = NewUDim2(0, 0, 0, 14),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = "( " .. Low .. Suffix .. " \xE2\x86\x94 " .. High .. Suffix .. " )",
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Track = LibRef:CreateInstance("TextButton", {
			Name = "Track",
			Parent = Container,
			AutoButtonColor = false,
			Text = "",
			Position = NewUDim2(0, 0, 1, -9),
			Size = NewUDim2(1, 0, 0, 7),
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", { Parent = Track, CornerRadius = NewUDim(1, 0) })

		local Fill = LibRef:CreateInstance("Frame", {
			Name = "Fill",
			Parent = Track,
			Position = NewUDim2(0, 0, 0, 0),
			Size = NewUDim2(0, 0, 1, 0),
			BackgroundColor3 = Palette.Default.Accent,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", { Parent = Fill, CornerRadius = NewUDim(1, 0) })
		local FillGradient = LibRef:CreateInstance("UIGradient", {
			Parent = Fill,
			Color = NewColorSequence({
				NewColorSequenceKeypoint(0, Palette.Default.Accent),
				NewColorSequenceKeypoint(1, Palette.Default.AccentTwo),
			}),
		})
		LibRef:BindThemedGradient(FillGradient, { "Accent", "AccentTwo" })

		local function MakeThumb(Name)
			local Thumb = LibRef:CreateInstance("Frame", {
				Name = Name,
				Parent = Track,
				AnchorPoint = NewVector2(0.5, 0.5),
				Position = NewUDim2(0, 0, 0.5, 0),
				Size = NewUDim2(0, 12, 0, 12),
				BackgroundColor3 = FromRgb(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 3,
			})
			LibRef:CreateInstance("UICorner", { Parent = Thumb, CornerRadius = NewUDim(1, 0) })
			local Glow = LibRef:CreateInstance("Frame", {
				Name = "Glow",
				Parent = Thumb,
				AnchorPoint = NewVector2(0.5, 0.5),
				Position = NewUDim2(0.5, 0, 0.5, 0),
				Size = NewUDim2(1, 4, 1, 4),
				BackgroundColor3 = FromRgb(255, 255, 255),
				BackgroundTransparency = 0.82,
				BorderSizePixel = 0,
				ZIndex = 2,
			})
			LibRef:CreateInstance("UICorner", { Parent = Glow, CornerRadius = NewUDim(1, 0) })
			return Thumb
		end

		local LowThumb = MakeThumb("LowThumb")
		local HighThumb = MakeThumb("HighThumb")

		local VisualLow = (Low - Min) / (Max - Min)
		local VisualHigh = (High - Min) / (Max - Min)
		local TargetLow, TargetHigh = VisualLow, VisualHigh
		Fill.Position = NewUDim2(VisualLow, 6 - 12 * VisualLow, 0, 0)
		Fill.Size = NewUDim2(VisualHigh - VisualLow, -12 * (VisualHigh - VisualLow), 1, 0)
		LowThumb.Position = NewUDim2(VisualLow, 6 - 12 * VisualLow, 0.5, 0)
		HighThumb.Position = NewUDim2(VisualHigh, 6 - 12 * VisualHigh, 0.5, 0)

		local function UpdateValues()
			Val.Text = "( " .. tostring(Low) .. Suffix .. " \xE2\x86\x94 " .. tostring(High) .. Suffix .. " )"
			TargetLow = (Low - Min) / (Max - Min)
			TargetHigh = (High - Min) / (Max - Min)
			Callback(Low, High)
		end

		LibRef:Connection(RunService.Heartbeat, function(dt)
			if MathAbs(TargetLow - VisualLow) + MathAbs(TargetHigh - VisualHigh) < 0.0005 then
				return
			end
			local alpha = 1 - math.exp(-dt * 9)
			VisualLow = VisualLow + (TargetLow - VisualLow) * alpha
			VisualHigh = VisualHigh + (TargetHigh - VisualHigh) * alpha
			Fill.Position = NewUDim2(VisualLow, 6 - 12 * VisualLow, 0, 0)
			Fill.Size = NewUDim2(VisualHigh - VisualLow, -12 * (VisualHigh - VisualLow), 1, 0)
			LowThumb.Position = NewUDim2(VisualLow, 6 - 12 * VisualLow, 0.5, 0)
			HighThumb.Position = NewUDim2(VisualHigh, 6 - 12 * VisualHigh, 0.5, 0)
		end)

		local DraggingThumb = nil
		local function GetT(px)
			local absX = Track.AbsolutePosition.X
			local absW = Track.AbsoluteSize.X
			if absW <= 0 then return 0 end
			return MathClamp((px - absX) / absW, 0, 1)
		end
		local function ValueFromT(t)
			return MathFloor(Min + t * (Max - Min) + 0.5)
		end

		LibRef:Connection(Track.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local t = GetT(input.Position.X)
				local lowT = (Low - Min) / (Max - Min)
				local highT = (High - Min) / (Max - Min)
				DraggingThumb = MathAbs(t - lowT) <= MathAbs(t - highT) and "low" or "high"
				if DraggingThumb == "low" then
					Low = MathMin(ValueFromT(t), High)
				else
					High = MathMax(ValueFromT(t), Low)
				end
				UpdateValues()
			end
		end)
		LibRef:Connection(Track.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				DraggingThumb = nil
			end
		end)
		LibRef:Connection(UserInputService.InputChanged, function(input)
			if not DraggingThumb then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local t = GetT(input.Position.X)
				if DraggingThumb == "low" then
					Low = MathMin(ValueFromT(t), High)
				else
					High = MathMax(ValueFromT(t), Low)
				end
				UpdateValues()
			end
		end)

		local RangeObj = { Name = tostring(Name or "Range"), Container = Container, Track = Track, Fill = Fill, LowThumb = LowThumb, HighThumb = HighThumb, Label = Lbl, ValueLabel = Val }
		local NotifyFlag = LibRef:RegisterFlag("Options", Flag, RangeObj, { Min = Low, Max = High })
		Callback = function(lo, hi) NotifyFlag({ Min = lo, Max = hi }); UserCallback(lo, hi) end
		function RangeObj:Get() return Low, High end
		function RangeObj:Set(lo, hi)
			if typeof(lo) == "table" then
				hi = lo.Max or lo[2]
				lo = lo.Min or lo[1]
			end
			Low = MathClamp(tonumber(lo) or Low, Min, Max)
			High = MathClamp(tonumber(hi) or High, Min, Max)
			if Low > High then Low, High = High, Low end
			UpdateValues()
		end

		LibRef:RegisterFlagSerializer(self.Name .. "::Range::" .. tostring(Name or "Range"), {
			serialize = function() return tostring(Low) .. "," .. tostring(High) end,
			deserialize = function(s)
				local l, hi = s:match("^([^,]+),([^,]+)$")
				if l and hi then RangeObj:Set(tonumber(l), tonumber(hi)) end
			end,
		})
		return RangeObj
	end

	function GroupboxObj:AddDropdown(Name, Options, Default, Callback)
		PreElement(self)
		local Flag, Multi
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Dropdown"
			Options = o.Values or o.Options
			Default = o.Default
			Callback = o.Callback
			Flag = o.Flag
			Multi = o.Multi == true
		end
		Options = typeof(Options) == "table" and Options or {}
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		Callback = UserCallback

		local SelectedSet = {}
		local SelectedOrder = {}
		local function AddSel(v)
			v = tostring(v)
			if SelectedSet[v] then return end
			SelectedSet[v] = true
			Insert(SelectedOrder, v)
		end
		local function RemoveSel(v)
			v = tostring(v)
			if not SelectedSet[v] then return end
			SelectedSet[v] = nil
			for i, item in ipairs(SelectedOrder) do
				if item == v then table.remove(SelectedOrder, i) break end
			end
		end
		if Multi then
			if typeof(Default) == "table" then
				for _, v in ipairs(Default) do AddSel(v) end
			end
		end
		local Selected = tostring(Default or Options[1] or "")

		local Container = LibRef:CreateInstance("Frame", {
			Name = "Dropdown_" .. tostring(Name or "Dropdown"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UIListLayout", {
			Parent = Container,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 6),
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Container,
			LayoutOrder = 1,
			Size = NewUDim2(1, 0, 0, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Dropdown"),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Btn = LibRef:CreateInstance("TextButton", {
			Name = "Button",
			Parent = Container,
			LayoutOrder = 2,
			AutoButtonColor = false,
			Text = "",
			Size = NewUDim2(1, 0, 0, 36),
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UICorner", { Parent = Btn, CornerRadius = NewUDim(0, 6) })
		LibRef:CreateInstance("UIPadding", {
			Parent = Btn,
			PaddingLeft = NewUDim(0, 14),
			PaddingRight = NewUDim(0, 14),
		})

		local function MultiDisplay()
			if #SelectedOrder == 0 then return "None" end
			return Concat(SelectedOrder, ", ")
		end

		local BtnLbl = LibRef:CreateInstance("TextLabel", {
			Name = "Text",
			Parent = Btn,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 0, 0.5, 0),
			Size = NewUDim2(1, -20, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.SemiBold,
			Text = Multi and MultiDisplay() or Selected,
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local Arrow = LibRef:CreateInstance("ImageLabel", {
			Name = "Arrow",
			Parent = Btn,
			AnchorPoint = NewVector2(1, 0.5),
			Position = NewUDim2(1, 0, 0.5, 0),
			Size = NewUDim2(0, 14, 0, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://116721412502091",
			ImageColor3 = FromRgb(255, 255, 255),
			ScaleType = Enum.ScaleType.Fit,
		})

		local Gui = self.Frame:FindFirstAncestorOfClass("ScreenGui")
		local List = LibRef:CreateInstance("CanvasGroup", {
			Name = "DropdownList_" .. tostring(Name or "Dropdown"),
			Parent = Gui,
			Size = NewUDim2(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
			Visible = false,
			GroupTransparency = 1,
			ZIndex = 50,
		})
		LibRef:CreateInstance("UICorner", { Parent = List, CornerRadius = NewUDim(0, 6) })
		LibRef:CreateInstance("UIListLayout", {
			Parent = List,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 0),
		})
		LibRef:CreateInstance("UIPadding", {
			Parent = List,
			PaddingTop = NewUDim(0, 4),
			PaddingBottom = NewUDim(0, 4),
		})

		local TweenDropdown = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Open = false
		local function SetOpen(o)
			Open = o
			if o then
				local bp = Btn.AbsolutePosition
				local bs = Btn.AbsoluteSize
				local finalY = bp.Y + bs.Y + 20
				List.Size = NewUDim2(0, bs.X, 0, 0)
				List.Position = NewUDim2(0, bp.X, 0, finalY - 6)
				List.Visible = true
				List.GroupTransparency = 1
				TweenNew(List, TweenDropdown, {
					GroupTransparency = 0,
					Position = NewUDim2(0, bp.X, 0, finalY),
				}):Play()
			else
				TweenNew(List, TweenDropdown, {
					GroupTransparency = 1,
				}):Play()
				task.delay(TweenDropdown.Time, function()
					if List.GroupTransparency > 0.99 then
						List.Visible = false
					end
				end)
			end
			Arrow.Image = o and "rbxassetid://125935884565724" or "rbxassetid://116721412502091"
		end

		LibRef:Connection(UserInputService.InputBegan, function(input)
			if not Open then return end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local mx, my = input.Position.X, input.Position.Y
			local function inside(g)
				local p, s = g.AbsolutePosition, g.AbsoluteSize
				return mx >= p.X and mx <= p.X + s.X and my >= p.Y and my <= p.Y + s.Y
			end
			if not inside(Btn) and not inside(List) then
				SetOpen(false)
			end
		end)

		local OptButtons = {}
		local OptColorTween = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local function IsActive(v)
			if Multi then return SelectedSet[tostring(v)] == true end
			return tostring(v) == Selected
		end
		local function RefreshOptColors()
			for _, entry in ipairs(OptButtons) do
				local on = IsActive(entry.Value)
				local target
				if Multi then
					target = on and Palette.Default.Accent or Palette.Default.SubText
				else
					target = on and FromRgb(255, 255, 255) or Palette.Default.SubText
				end
				TweenNew(entry.Label, OptColorTween, { TextColor3 = target }):Play()
			end
		end

		local function Select(val)
			if Multi then
				local v = tostring(val)
				if SelectedSet[v] then RemoveSel(v) else AddSel(v) end
				BtnLbl.Text = MultiDisplay()
				RefreshOptColors()
				Callback(SelectedOrder)
				return
			end
			Selected = tostring(val)
			BtnLbl.Text = Selected
			RefreshOptColors()
			Callback(Selected)
			SetOpen(false)
		end

		local function BuildOptions()
			for _, entry in ipairs(OptButtons) do
				if entry.Btn and entry.Btn.Parent then entry.Btn:Destroy() end
			end
			OptButtons = {}
			for i, opt in ipairs(Options) do
				local OptBtn = LibRef:CreateInstance("TextButton", {
					Name = "Opt_" .. tostring(i),
					Parent = List,
					LayoutOrder = i,
					AutoButtonColor = false,
					Text = "",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = NewUDim2(1, 0, 0, 28),
				})
				LibRef:CreateInstance("UIPadding", {
					Parent = OptBtn,
					PaddingLeft = NewUDim(0, 14),
					PaddingRight = NewUDim(0, 14),
				})

				local OptLbl = LibRef:CreateInstance("TextLabel", {
					Name = "Label",
					Parent = OptBtn,
					AnchorPoint = NewVector2(0, 0.5),
					Position = NewUDim2(0, 0, 0.5, 0),
					Size = NewUDim2(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.Regular,
					Text = tostring(opt),
					TextColor3 = IsActive(opt) and (Multi and Palette.Default.Accent or FromRgb(255, 255, 255)) or Palette.Default.SubText,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})

				local captured = opt
				Insert(OptButtons, { Btn = OptBtn, Label = OptLbl, Value = tostring(opt) })
				LibRef:Connection(OptBtn.MouseButton1Click, function()
					Select(captured)
				end)
			end
		end
		BuildOptions()

		LibRef:Connection(Btn.MouseButton1Click, function()
			SetOpen(not Open)
		end)

		local DropdownObj = { Name = tostring(Name or "Dropdown"), Container = Container, Button = Btn, Label = Lbl, List = List, Multi = Multi }
		local NotifyFlag = LibRef:RegisterFlag("Options", Flag, DropdownObj, Multi and SelectedOrder or Selected)
		Callback = function(v) NotifyFlag(v); UserCallback(v) end
		function DropdownObj:Get() return Multi and SelectedOrder or Selected end
		function DropdownObj:Set(v)
			if Multi then
				SelectedSet = {}
				SelectedOrder = {}
				if typeof(v) == "table" then
					for _, item in ipairs(v) do AddSel(item) end
				end
				BtnLbl.Text = MultiDisplay()
				RefreshOptColors()
				Callback(SelectedOrder)
			else
				Select(v)
			end
		end
		function DropdownObj:SetValues(newOptions)
			Options = typeof(newOptions) == "table" and newOptions or {}
			if Multi then
				local kept = {}
				for _, v in ipairs(SelectedOrder) do
					for _, opt in ipairs(Options) do
						if tostring(opt) == v then Insert(kept, v); break end
					end
				end
				SelectedSet = {}
				SelectedOrder = {}
				for _, v in ipairs(kept) do AddSel(v) end
				BtnLbl.Text = MultiDisplay()
			else
				local found = false
				for _, opt in ipairs(Options) do
					if tostring(opt) == Selected then found = true; break end
				end
				if not found then
					Selected = tostring(Options[1] or "")
					BtnLbl.Text = Selected
				end
			end
			BuildOptions()
		end

		LibRef:RegisterFlagSerializer(self.Name .. "::Dropdown::" .. tostring(Name or "Dropdown"), {
			serialize = function()
				if Multi then return Concat(SelectedOrder, "\31") end
				return Selected
			end,
			deserialize = function(s)
				if not s or s == "" then return end
				if Multi then
					local list = {}
					for item in string.gmatch(s, "[^\31]+") do Insert(list, item) end
					DropdownObj:Set(list)
				else
					Select(s)
				end
			end,
		})
		return DropdownObj
	end

	function GroupboxObj:AddInput(Name, Default, Placeholder, Callback)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Input"
			Default = o.Default
			Placeholder = o.Placeholder
			Callback = o.Callback
			Flag = o.Flag
		end
		local Value = tostring(Default or "")
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		Callback = UserCallback

		local Container = LibRef:CreateInstance("Frame", {
			Name = "Input_" .. tostring(Name or "Input"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UIListLayout", {
			Parent = Container,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 6),
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Container,
			LayoutOrder = 1,
			Size = NewUDim2(1, 0, 0, 14),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Input"),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Box = LibRef:CreateInstance("Frame", {
			Name = "Box",
			Parent = Container,
			LayoutOrder = 2,
			Size = NewUDim2(1, 0, 0, 36),
			BackgroundColor3 = Palette.Default.TabBackground,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		})
		LibRef:CreateInstance("UICorner", { Parent = Box, CornerRadius = NewUDim(0, 6) })
		LibRef:CreateInstance("UIPadding", {
			Parent = Box,
			PaddingLeft = NewUDim(0, 14),
			PaddingRight = NewUDim(0, 14),
		})

		local Input = LibRef:CreateInstance("TextBox", {
			Name = "TextBox",
			Parent = Box,
			Size = NewUDim2(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.SemiBold,
			Text = Value,
			PlaceholderText = tostring(Placeholder or ""),
			PlaceholderColor3 = Palette.Default.SubText,
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ClearTextOnFocus = false,
		})

		LibRef:Connection(Input.FocusLost, function(enter)
			Value = Input.Text
			Callback(Value, enter)
		end)

		local InputObj = { Name = tostring(Name or "Input"), Container = Container, Input = Input, Label = Lbl }
		local NotifyFlag = LibRef:RegisterFlag("Options", Flag, InputObj, Value)
		local WrappedCallback = Callback
		Callback = function(v, enter) NotifyFlag(v); WrappedCallback(v, enter) end
		function InputObj:Get() return Value end
		function InputObj:Set(v)
			Value = tostring(v or "")
			Input.Text = Value
			Callback(Value, false)
		end

		LibRef:RegisterFlagSerializer(self.Name .. "::Input::" .. tostring(Name or "Input"), {
			serialize = function() return (Value or ""):gsub("[\r\n]", " ") end,
			deserialize = function(s) InputObj:Set(s) end,
		})
		return InputObj
	end

	function GroupboxObj:AddLabel(Text)
		PreElement(self)
		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Text or ""),
			TextColor3 = Palette.Default.SubText,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		local LabelObj = { Label = Lbl }
		function LabelObj:Set(t) Lbl.Text = tostring(t or "") end
		function LabelObj:Get() return Lbl.Text end
		return LabelObj
	end

	function GroupboxObj:AddColorpicker(Name, Default, Callback)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Color"
			Default = o.Default
			Callback = o.Callback
			Flag = o.Flag
		end
		local Color = typeof(Default) == "Color3" and Default or FromRgb(255, 255, 255)

		local Row = LibRef:CreateInstance("Frame", {
			Name = "Colorpicker_" .. tostring(Name or "Color"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 22),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Row,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 0, 0.5, 0),
			Size = NewUDim2(1, -30, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Color"),
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Swatch = LibRef:CreateInstance("ImageButton", {
			Name = "Swatch",
			Parent = Row,
			AnchorPoint = NewVector2(1, 0.5),
			Position = NewUDim2(1, 0, 0.5, 0),
			Size = NewUDim2(0, 19, 0, 19),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Image = "rbxassetid://80230152894065",
			ImageColor3 = Color,
			ScaleType = Enum.ScaleType.Fit,
		})

		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		local WrappedCb
		local CpObj = LibRef:MountColorpicker(Swatch, Color, function(c, t) if WrappedCb then WrappedCb(c, t) end end)
		CpObj.Name = tostring(Name or "Color")
		CpObj.Row = Row
		CpObj.Label = Lbl
		if Flag and Flag ~= "" then
			CpObj.Flag = Flag
			CpObj.Value = Color
			CpObj.Transparency = 0
			CpObj._changedListeners = {}
			function CpObj:OnChanged(cb) Insert(self._changedListeners, cb); return self end
			function CpObj:SetValue(c, t) return self:Set(c, t) end
			LibRef.Options[Flag] = CpObj
		end
		WrappedCb = function(c, t)
			if CpObj.Flag then
				CpObj.Value = c
				CpObj.Transparency = t
				for _, cb in ipairs(CpObj._changedListeners) do cb(c, t) end
			end
			UserCallback(c, t)
		end

		LibRef:RegisterFlagSerializer(self.Name .. "::Color::" .. tostring(Name or "Color"), {
			serialize = function()
				local c, t = CpObj:Get()
				return string.format("%d,%d,%d,%d",
					MathFloor(c.R * 255 + 0.5),
					MathFloor(c.G * 255 + 0.5),
					MathFloor(c.B * 255 + 0.5),
					MathFloor((t or 0) * 255 + 0.5))
			end,
			deserialize = function(s)
				local r, g, b, a = s:match("^(%d+),(%d+),(%d+),(%d+)$")
				if r then
					CpObj:Set(FromRgb(tonumber(r), tonumber(g), tonumber(b)), tonumber(a) / 255)
				end
			end,
		})
		return CpObj
	end


	function GroupboxObj:AddKeybind(Name, DefaultKey, DefaultMode, Callback)
		PreElement(self)
		local Flag
		if typeof(Name) == "table" then
			local o = Name
			Name = o.Text or o.Flag or "Keybind"
			DefaultKey = o.Default or o.Key
			DefaultMode = o.Mode
			Callback = o.Callback
			Flag = o.Flag
		end
		local Row = LibRef:CreateInstance("Frame", {
			Name = "Keybind_" .. tostring(Name or "Keybind"),
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 22),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Row,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 0, 0.5, 0),
			Size = NewUDim2(1, -140, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.Regular,
			Text = tostring(Name or "Keybind"),
			TextColor3 = FromRgb(255, 255, 255),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		})
		local UserCallback = typeof(Callback) == "function" and Callback or function() end
		local KbObj = { Name = tostring(Name or "Keybind"), Row = Row, Label = Lbl }
		local Kb = LibRef:MountKeybind(Row, {
			Key = DefaultKey,
			Mode = DefaultMode,
			Name = tostring(Name or "Keybind"),
			Callback = function(active)
				if KbObj.Flag then
					KbObj.Value = active
					for _, cb in ipairs(KbObj._changedListeners) do cb(active) end
				end
				UserCallback(active)
			end,
		})
		KbObj.Keybind = Kb
		function KbObj:Get() return Kb:Get() end
		function KbObj:Set(k, m) Kb:Set(k, m) end
		if Flag and Flag ~= "" then
			KbObj.Flag = Flag
			KbObj.Value = false
			KbObj._changedListeners = {}
			function KbObj:OnChanged(cb) Insert(self._changedListeners, cb); return self end
			function KbObj:SetValue(k, m) Kb:Set(k, m) end
			LibRef.Options[Flag] = KbObj
		end
		LibRef:RegisterFlagSerializer(self.Name .. "::Keybind::" .. tostring(Name or "Keybind"), {
			serialize = function()
				local k, m = Kb:Get()
				return (m or "Hold") .. "|" .. KeyDisplayName(k)
			end,
			deserialize = function(s)
				local m, kn = s:match("^([^|]+)|(.*)$")
				if m then Kb:Set(ParseKeyName(kn or ""), m) end
			end,
		})
		return KbObj
	end

	function GroupboxObj:AddButton(Name, Callback)
		PreElement(self)

		local Row = LibRef:CreateInstance("Frame", {
			Name = "ButtonRow",
			Parent = self.Frame,
			Size = NewUDim2(1, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		LibRef:CreateInstance("UIListLayout", {
			Parent = Row,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 6),
		})

		local ClickTween = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		local function MakeBtn(BtnName, BtnCallback, Order)
			BtnCallback = typeof(BtnCallback) == "function" and BtnCallback or function() end
			local Btn = LibRef:CreateInstance("TextButton", {
				Name = "Btn_" .. tostring(BtnName or "Button"),
				Parent = Row,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = Order,
				Size = NewUDim2(1, 0, 1, 0),
				BackgroundColor3 = Palette.Default.TabBackground,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UICorner", { Parent = Btn, CornerRadius = NewUDim(0, 6) })
			LibRef:CreateInstance("UIFlexItem", {
				Parent = Btn,
				FlexMode = Enum.UIFlexMode.Fill,
			})

			local BtnLbl = LibRef:CreateInstance("TextLabel", {
				Name = "Label",
				Parent = Btn,
				Size = NewUDim2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.SemiBold,
				Text = tostring(BtnName or "Button"),
				TextColor3 = FromRgb(255, 255, 255),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})

			LibRef:Connection(Btn.MouseButton1Click, function()
				Btn.BackgroundColor3 = Palette.Default.Accent
				TweenNew(Btn, ClickTween, {
					BackgroundColor3 = Palette.Default.TabBackground,
				}):Play()
				BtnCallback()
			end)

			return Btn, BtnLbl
		end

		local count = 1
		local FirstBtn, FirstLbl = MakeBtn(Name, Callback, count)

		local ButtonObj = { Name = tostring(Name or "Button"), Row = Row, Button = FirstBtn, Label = FirstLbl }
		function ButtonObj:AddButton(SubName, SubCallback)
			count = count + 1
			local b, l = MakeBtn(SubName, SubCallback, count)
			return { Name = tostring(SubName or "Button"), Button = b, Label = l }
		end
		return ButtonObj
	end

	return GroupboxObj
end

function Library:Window(Title, Subtitle, Icon, Size)
	if self.CurrentlyOpen then
		self:Unload()
	end

	Title = tostring(Title or "")
	Subtitle = tostring(Subtitle or "")
	local WindowSize = typeof(Size) == "UDim2" and Size or FromOffset(720, 500)

	local Vp = Camera.ViewportSize
	local SpawnX = MathMax(0, MathFloor((Vp.X - WindowSize.X.Offset) / 2))
	local SpawnY = MathMax(0, MathFloor((Vp.Y - WindowSize.Y.Offset) / 2))

	local Gui = self:CreateInstance("ScreenGui", {
		Name = "\0",
		Parent = gethui and gethui() or CoreGui,
		Enabled = true,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local Main = self:CreateInstance("Frame", {
		Name = "Main",
		Parent = Gui,
		Size = WindowSize,
		Position = NewUDim2(0, SpawnX, 0, SpawnY),
		BackgroundColor3 = Palette.Default.Background,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", {
		Parent = Main,
		CornerRadius = NewUDim(0, 10),
	})

	local SubBackground = self:CreateInstance("Frame", {
		Name = "SubBackground",
		Parent = Main,
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, 0, 0, 50),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", {
		Parent = SubBackground,
		CornerRadius = NewUDim(0, 10),
	})
	self:CreateInstance("Frame", {
		Name = "SubBottomCoverup",
		Parent = SubBackground,
		Position = NewUDim2(0, 0, 1, -6),
		Size = NewUDim2(1, 0, 0, 6),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})

	local HasIcon = Icon ~= nil and tostring(Icon) ~= ""
	if HasIcon then
		self:CreateInstance("ImageLabel", {
			Name = "TopIcon",
			Parent = SubBackground,
			AnchorPoint = NewVector2(0, 0.5),
			Position = NewUDim2(0, 14, 0.5, 0),
			Size = NewUDim2(0, 34, 0, 34),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = tostring(Icon),
			ImageColor3 = Palette.Default.Accent,
			ScaleType = Enum.ScaleType.Fit,
		})
	end

	local TopTitleGroup = self:CreateInstance("Frame", {
		Name = "TopTitleGroup",
		Parent = SubBackground,
		AnchorPoint = NewVector2(0, 0.5),
		Position = NewUDim2(0, HasIcon and 54 or 14, 0.5, 0),
		Size = NewUDim2(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UIListLayout", {
		Parent = TopTitleGroup,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 6),
	})
	self:CreateInstance("TextLabel", {
		Name = "TopTitle",
		Parent = TopTitleGroup,
		LayoutOrder = 1,
		Size = NewUDim2(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.SemiBold,
		Text = Title,
		TextColor3 = FromRgb(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
	self:CreateInstance("TextLabel", {
		Name = "TopSubtitle",
		Parent = TopTitleGroup,
		LayoutOrder = 2,
		Size = NewUDim2(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.Regular,
		Text = Subtitle,
		TextColor3 = Palette.Default.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local MonthAbbr = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
	local T = os.date("*t")
	local DateString = string.format("%d %s %d", T.day, MonthAbbr[T.month], T.year)

	self:CreateInstance("TextLabel", {
		Name = "TopDate",
		Parent = SubBackground,
		AnchorPoint = NewVector2(1, 0.5),
		Position = NewUDim2(1, -14, 0.5, 0),
		Size = NewUDim2(0, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Library.Fonts.Regular,
		Text = DateString,
		TextColor3 = Palette.Default.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	self:CreateInstance("Frame", {
		Name = "TopDivider",
		Parent = Main,
		Position = NewUDim2(0, 0, 0, 50),
		Size = NewUDim2(1, 0, 0, 1),
		BackgroundColor3 = Palette.Default.Divider,
		BorderSizePixel = 0,
	})

	local Sidebar = self:CreateInstance("Frame", {
		Name = "Sidebar",
		Parent = Main,
		Position = NewUDim2(0, 0, 0, 51),
		Size = NewUDim2(0, 100, 1, -51),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})
	self:CreateInstance("UICorner", {
		Parent = Sidebar,
		CornerRadius = NewUDim(0, 10),
	})
	self:CreateInstance("Frame", {
		Name = "SidebarTopCoverup",
		Parent = Sidebar,
		Position = NewUDim2(0, 0, 0, 0),
		Size = NewUDim2(1, 0, 0, 6),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})
	self:CreateInstance("Frame", {
		Name = "SidebarBottomRightCoverup",
		Parent = Sidebar,
		AnchorPoint = NewVector2(1, 1),
		Position = NewUDim2(1, 0, 1, 0),
		Size = NewUDim2(0, 6, 0, 6),
		BackgroundColor3 = Palette.Default.SubBackground,
		BorderSizePixel = 0,
	})

	self:CreateInstance("Frame", {
		Name = "SidebarDivider",
		Parent = Main,
		Position = NewUDim2(0, 100, 0, 51),
		Size = NewUDim2(0, 1, 1, -51),
		BackgroundColor3 = Palette.Default.Divider,
		BorderSizePixel = 0,
	})

	local ContentArea = self:CreateInstance("Frame", {
		Name = "ContentArea",
		Parent = Main,
		Position = NewUDim2(0, 101, 0, 51),
		Size = NewUDim2(1, -101, 1, -51),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})

	self:CreateInstance("ImageLabel", {
		Name = "BottomIcon",
		Parent = Sidebar,
		AnchorPoint = NewVector2(0.5, 1),
		Position = NewUDim2(0.5, 0, 1, -14),
		Size = NewUDim2(0, 28, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxassetid://105367292738476",
		ScaleType = Enum.ScaleType.Fit,
	})

	local TabsContainer = self:CreateInstance("Frame", {
		Name = "TabsContainer",
		Parent = Sidebar,
		Position = NewUDim2(0, 0, 0, 10),
		Size = NewUDim2(1, 0, 1, -60),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	self:CreateInstance("UIListLayout", {
		Parent = TabsContainer,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = NewUDim(0, 18),
	})

	self:Draggable(Main, Main)
	self:Resizable(Main)

	Main.Active = true

	local WindowObject = {
		Gui = Gui,
		Main = Main,
		Sidebar = Sidebar,
		TabsContainer = TabsContainer,
		ContentArea = ContentArea,
		Tabs = {},
		ActiveTab = nil,
	}

	local LibRef = self
	local DefaultTabIcon = "rbxassetid://131734578740986"

	function WindowObject:AddTab(Name, Icon)
		local TabName = tostring(Name or "Tab")
		local TabIcon = Icon or DefaultTabIcon

		local Btn = LibRef:CreateInstance("TextButton", {
			Name = "Tab_" .. TabName,
			Parent = self.TabsContainer,
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = Palette.Default.TabBackground,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = NewUDim2(1, -30, 0, 66),
			LayoutOrder = #self.Tabs + 1,
		})
		LibRef:CreateInstance("UICorner", {
			Parent = Btn,
			CornerRadius = NewUDim(0, 6),
		})

		local Icn = LibRef:CreateInstance("ImageLabel", {
			Name = "Icon",
			Parent = Btn,
			AnchorPoint = NewVector2(0.5, 0),
			Position = NewUDim2(0.5, 0, 0, 10),
			Size = NewUDim2(0, 22, 0, 22),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = TabIcon,
			ImageColor3 = Palette.Default.SubText,
			ScaleType = Enum.ScaleType.Fit,
		})

		local Lbl = LibRef:CreateInstance("TextLabel", {
			Name = "Label",
			Parent = Btn,
			AnchorPoint = NewVector2(0.5, 0),
			Position = NewUDim2(0.5, 0, 0, 38),
			Size = NewUDim2(1, 0, 0, 16),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Library.Fonts.SemiBold,
			Text = TabName,
			TextColor3 = Palette.Default.SubText,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local Underline = LibRef:CreateInstance("Frame", {
			Name = "Underline",
			Parent = Btn,
			AnchorPoint = NewVector2(0.5, 1),
			Position = NewUDim2(0.5, 0, 1, 0),
			Size = NewUDim2(0, 0, 0, 2),
			BackgroundColor3 = Palette.Default.Accent,
			BorderSizePixel = 0,
		})

		local Page = LibRef:CreateInstance("CanvasGroup", {
			Name = "Page_" .. TabName,
			Parent = self.ContentArea,
			Size = NewUDim2(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			GroupTransparency = 1,
		})
		local SubTabBar = LibRef:CreateInstance("Frame", {
			Name = "SubTabBar",
			Parent = Page,
			Position = NewUDim2(0, 0, 0, 0),
			Size = NewUDim2(1, 0, 0, 49),
			BackgroundColor3 = Palette.Default.SubBackground,
			BorderSizePixel = 0,
			Visible = false,
		})
		LibRef:CreateInstance("UIListLayout", {
			Parent = SubTabBar,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = NewUDim(0, 14),
		})
		LibRef:CreateInstance("UIPadding", {
			Parent = SubTabBar,
			PaddingLeft = NewUDim(0, 14),
			PaddingRight = NewUDim(0, 14),
		})
		local SubTabDivider = LibRef:CreateInstance("Frame", {
			Name = "SubTabDivider",
			Parent = Page,
			Position = NewUDim2(0, 0, 0, 49),
			Size = NewUDim2(1, 0, 0, 1),
			BackgroundColor3 = Palette.Default.Divider,
			BorderSizePixel = 0,
			Visible = false,
		})
		local Content = LibRef:CreateInstance("Frame", {
			Name = "Content",
			Parent = Page,
			Position = NewUDim2(0, 0, 0, 0),
			Size = NewUDim2(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
		})


		local TabObj = {
			Name = TabName,
			Button = Btn,
			Icon = Icn,
			Label = Lbl,
			Underline = Underline,
			Page = Page,
			SubTabBar = SubTabBar,
			Content = Content,
			SubTabs = {},
			ActiveSubTab = nil,
		}

		local TweenInfoSwitch = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		function TabObj:SetActive(on)
			on = on == true
			if on then
				self.Page.Visible = true
			end
			TweenNew(self.Page, TweenInfoSwitch, {
				GroupTransparency = on and 0 or 1,
			}):Play()
			if not on then
				task.delay(TweenInfoSwitch.Time, function()
					if self.Page.GroupTransparency > 0.99 then
						self.Page.Visible = false
					end
				end)
			end
			TweenNew(self.Button, TweenInfoSwitch, {
				BackgroundTransparency = on and 0 or 1,
			}):Play()
			TweenNew(self.Icon, TweenInfoSwitch, {
				ImageColor3 = on and Palette.Default.Accent or Palette.Default.SubText,
			}):Play()
			TweenNew(self.Label, TweenInfoSwitch, {
				TextColor3 = on and FromRgb(255, 255, 255) or Palette.Default.SubText,
			}):Play()
			TweenNew(self.Underline, TweenInfoSwitch, {
				Size = NewUDim2(0, on and 22 or 0, 0, 2),
			}):Play()
		end

		LibRef:RegisterThemeRenderer(function()
			if Btn.Parent then
				TabObj:SetActive(WindowObject.ActiveTab == TabObj)
			end
		end)

		local function TabAddGroupbox(Tab, Name, Side)
			if #Tab.SubTabs > 0 then
				error("Tab '" .. Tab.Name .. "' has subtabs - call AddLeftGroupbox/AddRightGroupbox on the subtab", 2)
			end
			if not Tab._tabLayoutReady then
				Tab._tabLayoutReady = true
				LibRef:CreateInstance("UIPadding", {
					Parent = Tab.Content,
					PaddingTop = NewUDim(0, 12),
					PaddingBottom = NewUDim(0, 12),
					PaddingLeft = NewUDim(0, 12),
					PaddingRight = NewUDim(0, 12),
				})
			end
			Tab._hasSections = true
			local Left, Right = LibRef:EnsureColumns(Tab.Content)
			return LibRef:CreateSection(Side == "Right" and Right or Left, Name)
		end

		function TabObj:AddLeftGroupbox(Name)
			return TabAddGroupbox(self, Name, "Left")
		end

		function TabObj:AddRightGroupbox(Name)
			return TabAddGroupbox(self, Name, "Right")
		end

		function TabObj:ApplyHomePage(opts)
			opts = typeof(opts) == "table" and opts or {}
			if self._homeApplied then return end
			if #self.SubTabs > 0 then
				error("Tab '" .. self.Name .. "' has subtabs - ApplyHomePage is only for tabs without subtabs", 2)
			end
			if self._hasSections then
				error("Tab '" .. self.Name .. "' already has sections - call ApplyHomePage first", 2)
			end
			self._homeApplied = true

			LibRef:CreateInstance("UIPadding", {
				Parent = self.Content,
				PaddingTop = NewUDim(0, 14),
				PaddingBottom = NewUDim(0, 14),
				PaddingLeft = NewUDim(0, 14),
				PaddingRight = NewUDim(0, 14),
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = self.Content,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 10),
			})

			local PlayersSvc = game:GetService("Players")
			local LP = PlayersSvc.LocalPlayer or PlayersSvc.PlayerAdded:Wait()
			local Subtitle = tostring(opts.Subtitle or "Welcome to your dashboard")

			local Hero = LibRef:CreateInstance("Frame", {
				Name = "Hero",
				Parent = self.Content,
				LayoutOrder = 1,
				Size = NewUDim2(1, 0, 0, 104),
				BackgroundColor3 = Palette.Default.SectionBackground,
				BorderSizePixel = 0,
				ClipsDescendants = true,
			})
			LibRef:CreateInstance("UICorner", { Parent = Hero, CornerRadius = NewUDim(0, 10) })

			local HeroGlow = LibRef:CreateInstance("Frame", {
				Name = "Glow",
				Parent = Hero,
				Size = NewUDim2(1, 0, 1, 0),
				BackgroundColor3 = Palette.Default.Accent,
				BorderSizePixel = 0,
				ZIndex = 1,
			})
			LibRef:CreateInstance("UICorner", { Parent = HeroGlow, CornerRadius = NewUDim(0, 10) })
			local HeroGlowGrad = LibRef:CreateInstance("UIGradient", {
				Parent = HeroGlow,
				Rotation = 20,
				Transparency = NewNumberSequence({
					NewNumberSequenceKeypoint(0, 0.7),
					NewNumberSequenceKeypoint(0.5, 1),
					NewNumberSequenceKeypoint(1, 1),
				}),
				Color = NewColorSequence({
					NewColorSequenceKeypoint(0, Palette.Default.Accent),
					NewColorSequenceKeypoint(1, Palette.Default.AccentTwo),
				}),
			})
			LibRef:BindThemedGradient(HeroGlowGrad, { "Accent", "AccentTwo" })

			LibRef:Connection(RunService.Heartbeat, function()
				if not HeroGlowGrad.Parent then return end
				local T = os.clock() * 0.4
				HeroGlowGrad.Offset = NewVector2(math.sin(T) * 0.25, math.cos(T * 0.7) * 0.1)
				HeroGlowGrad.Rotation = 20 + math.sin(T * 0.5) * 6
			end)

			local AvatarRing = LibRef:CreateInstance("Frame", {
				Name = "AvatarRing",
				Parent = Hero,
				AnchorPoint = NewVector2(0, 0.5),
				Position = NewUDim2(0, 18, 0.5, 0),
				Size = NewUDim2(0, 68, 0, 68),
				BackgroundColor3 = FromRgb(115, 118, 130),
				BorderSizePixel = 0,
				ZIndex = 2,
			})
			LibRef:CreateInstance("UICorner", { Parent = AvatarRing, CornerRadius = NewUDim(1, 0) })

			local AvatarImg = LibRef:CreateInstance("ImageLabel", {
				Name = "Avatar",
				Parent = AvatarRing,
				AnchorPoint = NewVector2(0.5, 0.5),
				Position = NewUDim2(0.5, 0, 0.5, 0),
				Size = NewUDim2(1, -4, 1, -4),
				BackgroundColor3 = FromRgb(45, 47, 55),
				BorderSizePixel = 0,
				Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LP.UserId) .. "&w=150&h=150",
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 3,
			})
			LibRef:CreateInstance("UICorner", { Parent = AvatarImg, CornerRadius = NewUDim(1, 0) })

			local PillRow = LibRef:CreateInstance("Frame", {
				Name = "PillRow",
				Parent = Hero,
				AnchorPoint = NewVector2(1, 0.5),
				Position = NewUDim2(1, -18, 0.5, 0),
				Size = NewUDim2(0, 0, 0, 24),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 4,
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = PillRow,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 6),
			})

			local function MakePill(Order, Bg, Label, TextColor)
				local Pill = LibRef:CreateInstance("Frame", {
					Name = "Pill_" .. Label,
					Parent = PillRow,
					LayoutOrder = Order,
					Size = NewUDim2(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Bg,
					BorderSizePixel = 0,
					ZIndex = 5,
				})
				LibRef:CreateInstance("UICorner", { Parent = Pill, CornerRadius = NewUDim(1, 0) })
				LibRef:CreateInstance("UIPadding", {
					Parent = Pill,
					PaddingLeft = NewUDim(0, 10),
					PaddingRight = NewUDim(0, 10),
				})
				LibRef:CreateInstance("TextLabel", {
					Name = "Label",
					Parent = Pill,
					Size = NewUDim2(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = Label,
					TextColor3 = TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 6,
				})
				return Pill
			end

			MakePill(1, Hex("7ED382"), opts.StatusText or "Connected", Palette.Default.Background)
			MakePill(2, Palette.Default.Accent, tostring(opts.Version or "v0.01.0"), Palette.Default.Background)

			LibRef:CreateInstance("TextLabel", {
				Name = "Eyebrow",
				Parent = Hero,
				AnchorPoint = NewVector2(0, 0),
				Position = NewUDim2(0, 100, 0, 26),
				Size = NewUDim2(1, -116, 0, 14),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.Regular,
				Text = "Welcome back,",
				TextColor3 = FromRgb(195, 200, 215),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 4,
			})
			local RealName = tostring(LP.DisplayName or LP.Name)
			local TitleLbl = LibRef:CreateInstance("TextLabel", {
				Name = "Title",
				Parent = Hero,
				AnchorPoint = NewVector2(0, 0),
				Position = NewUDim2(0, 100, 0, 42),
				Size = NewUDim2(1, -116, 0, 24),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.SemiBold,
				Text = RealName,
				TextColor3 = FromRgb(255, 255, 255),
				TextSize = 22,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 4,
			})
			LibRef._HomeTitles = LibRef._HomeTitles or {}
			local TitleEntry = { Label = TitleLbl, RealName = RealName }
			Insert(LibRef._HomeTitles, TitleEntry)
			local function ApplyAnon()
				TitleLbl.Text = LibRef.AnonymousMode == true and "Hidden" or TitleEntry.RealName
			end
			TitleEntry.Apply = ApplyAnon
			ApplyAnon()
			LibRef:CreateInstance("TextLabel", {
				Name = "Subtitle",
				Parent = Hero,
				AnchorPoint = NewVector2(0, 0),
				Position = NewUDim2(0, 100, 0, 70),
				Size = NewUDim2(1, -116, 0, 16),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.Regular,
				Text = Subtitle,
				TextColor3 = FromRgb(135, 140, 155),
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 4,
			})

			local StatsRow = LibRef:CreateInstance("Frame", {
				Name = "StatsRow",
				Parent = self.Content,
				LayoutOrder = 2,
				Size = NewUDim2(1, 0, 0, 70),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = StatsRow,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 10),
			})

			local StatTiles = {}
			local function MakeStat(Order, Label, Getter)
				local Tile = LibRef:CreateInstance("Frame", {
					Name = "Stat_" .. Label,
					Parent = StatsRow,
					LayoutOrder = Order,
					Size = NewUDim2(1, 0, 1, 0),
					BackgroundColor3 = Palette.Default.SectionBackground,
					BorderSizePixel = 0,
				})
				LibRef:CreateInstance("UICorner", { Parent = Tile, CornerRadius = NewUDim(0, 8) })
				LibRef:CreateInstance("UIFlexItem", { Parent = Tile, FlexMode = Enum.UIFlexMode.Fill })
				LibRef:CreateInstance("TextLabel", {
					Name = "Label",
					Parent = Tile,
					Position = NewUDim2(0, 14, 0, 12),
					Size = NewUDim2(1, -28, 0, 14),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.Regular,
					Text = Label,
					TextColor3 = Palette.Default.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
				local ValueLbl = LibRef:CreateInstance("TextLabel", {
					Name = "Value",
					Parent = Tile,
					AnchorPoint = NewVector2(0, 1),
					Position = NewUDim2(0, 14, 1, -12),
					Size = NewUDim2(1, -28, 0, 22),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = tostring(Getter()),
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
				Insert(StatTiles, { Value = ValueLbl, Getter = Getter })
			end

			local StartTime = os.clock()
			local StatsService = game:GetService("Stats")

			local FpsAvg = 60
			LibRef:Connection(RunService.Heartbeat, function(Dt)
				if Dt > 0 then
					FpsAvg = FpsAvg * 0.9 + (1 / Dt) * 0.1
				end
			end)

			local function FormatDuration(S)
				S = MathFloor(S)
				if S < 60 then return S .. "s" end
				local M = MathFloor(S / 60)
				if M < 60 then return string.format("%dm %ds", M, S % 60) end
				local H = MathFloor(M / 60)
				return string.format("%dh %dm", H, M % 60)
			end

			MakeStat(1, "Players", function()
				return tostring(#PlayersSvc:GetPlayers()) .. "/" .. tostring(PlayersSvc.MaxPlayers)
			end)
			MakeStat(2, "FPS", function() return MathFloor(FpsAvg + 0.5) end)
			MakeStat(3, "Ping", function()
				local Item = StatsService:FindFirstChild("Network")
				if Item then
					local Sub = Item:FindFirstChild("ServerStatsItem")
					if Sub then
						local Ping = Sub:FindFirstChild("Data Ping")
						if Ping then return MathFloor(Ping:GetValue() + 0.5) .. "ms" end
					end
				end
				return "-"
			end)
			MakeStat(4, "Uptime", function() return FormatDuration(os.clock() - StartTime) end)

			task.spawn(function()
				while self.Content and self.Content.Parent do
					task.wait(0.5)
					for _, Tile in ipairs(StatTiles) do
						if Tile.Value and Tile.Value.Parent then
							Tile.Value.Text = tostring(Tile.Getter())
						end
					end
				end
			end)

			local BottomRow = LibRef:CreateInstance("Frame", {
				Name = "BottomRow",
				Parent = self.Content,
				LayoutOrder = 3,
				Size = NewUDim2(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = BottomRow,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 10),
			})

			local function MakeCard(Order, TitleText)
				local Card = LibRef:CreateInstance("Frame", {
					Name = "Card_" .. TitleText,
					Parent = BottomRow,
					LayoutOrder = Order,
					Size = NewUDim2(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Palette.Default.SectionBackground,
					BorderSizePixel = 0,
				})
				LibRef:CreateInstance("UICorner", { Parent = Card, CornerRadius = NewUDim(0, 8) })
				LibRef:CreateInstance("UIFlexItem", { Parent = Card, FlexMode = Enum.UIFlexMode.Fill })
				LibRef:CreateInstance("UIPadding", {
					Parent = Card,
					PaddingTop = NewUDim(0, 14),
					PaddingBottom = NewUDim(0, 14),
					PaddingLeft = NewUDim(0, 14),
					PaddingRight = NewUDim(0, 14),
				})
				LibRef:CreateInstance("UIListLayout", {
					Parent = Card,
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = NewUDim(0, 6),
				})
				LibRef:CreateInstance("TextLabel", {
					Name = "Title",
					Parent = Card,
					LayoutOrder = 1,
					Size = NewUDim2(1, 0, 0, 18),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = TitleText,
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})
				LibRef:CreateInstance("Frame", {
					Name = "TitleDivider",
					Parent = Card,
					LayoutOrder = 2,
					Size = NewUDim2(1, 0, 0, 1),
					BackgroundColor3 = Palette.Default.Divider,
					BorderSizePixel = 0,
				})
				return Card
			end

			local function AddCardLine(Card, Text, Order)
				LibRef:CreateInstance("TextLabel", {
					Name = "Line",
					Parent = Card,
					LayoutOrder = Order,
					Size = NewUDim2(1, 0, 0, 16),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.Regular,
					Text = tostring(Text),
					TextColor3 = Palette.Default.SubText,
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				})
			end

			local CreditsCard = MakeCard(1, "Credits")
			local CreditsLines = opts.Credits or {
				"Neptune UI",
				"Made by discord.gg/userinterfaces",
			}
			for I, Line in ipairs(CreditsLines) do
				AddCardLine(CreditsCard, Line, I + 2)
			end

			local KeyInfoCard = MakeCard(2, "Key Info")
			local KeyLines = opts.KeyInfo
			if not KeyLines then
				local LrmScriptName = rawget(getfenv(), "LRM_ScriptName") or "Neptune"
				local LrmScriptVersion = rawget(getfenv(), "LRM_ScriptVersion") or "0.01.0"
				local LrmDiscordId = rawget(getfenv(), "LRM_LinkedDiscordID") or "networph"
				local LrmExecutions = rawget(getfenv(), "LRM_TotalExecutions") or "42"
				local LrmSecondsLeft = rawget(getfenv(), "LRM_SecondsLeft")
				local DaysLeft = (LrmSecondsLeft and (LrmSecondsLeft == math.huge and "Lifetime" or tostring(MathFloor(LrmSecondsLeft / 86400)))) or "Lifetime"
				KeyLines = {
					"You have run " .. tostring(LrmScriptName),
					"Current version: " .. tostring(LrmScriptVersion),
					"Welcome " .. tostring(LrmDiscordId),
					"You have " .. tostring(LrmExecutions) .. " executions",
					"Your key has " .. DaysLeft .. " days remaining",
				}
			end
			for I, Line in ipairs(KeyLines) do
				AddCardLine(KeyInfoCard, Line, I + 2)
			end

			return {
				Hero = Hero,
				StatsRow = StatsRow,
				Credits = CreditsCard,
				KeyInfo = KeyInfoCard,
			}
		end

		function TabObj:ApplySettings()
			if self._settingsApplied then return end
			if #self.SubTabs > 0 then
				error("Tab '" .. self.Name .. "' has subtabs - ApplySettings is only for tabs without subtabs", 2)
			end
			self._settingsApplied = true

			local OptionsSub = self:AddSubTab("Options")
			local ConfigsSub = self:AddSubTab("Configs")

			local configFolder = LibRef.Directory .. "/Configs"
			local autoloadPath = LibRef.Directory .. "/autoload.txt"
			local function ReadAutoload()
				if isfile and isfile(autoloadPath) then
					local c = readfile(autoloadPath)
					return c and c:match("^%s*(.-)%s*$") or "None"
				end
				return "None"
			end
			local function WriteAutoload(name) writefile(autoloadPath, name or "None") end

			local ConfigNames = { "None", "Default" }
			if isfolder and isfolder(configFolder) then
				for _, path in ipairs(listfiles(configFolder)) do
					local shortname = path:match("([^/\\]+)%.cfg$")
					if shortname and shortname ~= "Default" then
						Insert(ConfigNames, shortname)
					end
				end
			end
			local AutoloadInitial = ReadAutoload()
			local AutoloadValid = false
			for _, nm in ipairs(ConfigNames) do
				if nm == AutoloadInitial then AutoloadValid = true break end
			end
			if not AutoloadValid then AutoloadInitial = "None" end

			local ThemeBox = OptionsSub:AddLeftGroupbox("Theme")
			local OtherBox = OptionsSub:AddRightGroupbox("Other")

			OtherBox:AddSlider({
				Flag = "AnimationSpeed",
				Text = "Animation speed",
				Min = 0, Max = 200, Default = 100,
				Suffix = "%",
				Callback = function(v) LibRef.AnimationSpeed = v / 100 end,
			})
			OtherBox:AddToggle({
				Flag = "Anonymous",
				Text = "Anonymous",
				Default = false,
				Callback = function(on)
					LibRef.AnonymousMode = on == true
					for _, entry in ipairs(LibRef._HomeTitles or {}) do
						if entry.Apply then entry.Apply() end
					end
				end,
			})
			local AutoloadDropdown = OtherBox:AddDropdown({
				Flag = "AutoloadConfig",
				Text = "Autoload",
				Values = ConfigNames,
				Default = AutoloadInitial,
				Callback = function(name) WriteAutoload(name) end,
			})

			local ThemePresets = {
				Default = {
					Background = Hex("0F1014"), SubBackground = Hex("12141A"),
					TabBackground = Hex("171821"), Divider = Hex("1B1E28"),
					SubText = Hex("4A4C57"), Accent = Hex("70D5D4"),
					AccentTwo = Hex("437C82"), AccentBright = Hex("B5F0EF"),
					SectionBackground = Hex("12141A"),
				},
				Crimson = {
					Background = Hex("100A0B"), SubBackground = Hex("1A1012"),
					TabBackground = Hex("221316"), Divider = Hex("2A171B"),
					SubText = Hex("574147"), Accent = Hex("E8575C"),
					AccentTwo = Hex("8A2E32"), AccentBright = Hex("FFA5A9"),
					SectionBackground = Hex("1A1012"),
				},
				Violet = {
					Background = Hex("0E0B14"), SubBackground = Hex("13101C"),
					TabBackground = Hex("1A1527"), Divider = Hex("201B2F"),
					SubText = Hex("4E4858"), Accent = Hex("B47AE0"),
					AccentTwo = Hex("6A4593"), AccentBright = Hex("E0C5FF"),
					SectionBackground = Hex("13101C"),
				},
				Forest = {
					Background = Hex("0B100D"), SubBackground = Hex("101A13"),
					TabBackground = Hex("13221A"), Divider = Hex("172A1D"),
					SubText = Hex("445548"), Accent = Hex("7ED382"),
					AccentTwo = Hex("3F7F42"), AccentBright = Hex("BFF0C1"),
					SectionBackground = Hex("101A13"),
				},
				Amber = {
					Background = Hex("110F09"), SubBackground = Hex("1A160D"),
					TabBackground = Hex("231C10"), Divider = Hex("2B2214"),
					SubText = Hex("574E3E"), Accent = Hex("E8B857"),
					AccentTwo = Hex("8A6A2E"), AccentBright = Hex("FFE2A5"),
					SectionBackground = Hex("1A160D"),
				},
				Mono = {
					Background = Hex("0F0F0F"), SubBackground = Hex("151515"),
					TabBackground = Hex("1E1E1E"), Divider = Hex("252525"),
					SubText = Hex("4A4A4A"), Accent = Hex("CCCCCC"),
					AccentTwo = Hex("7F7F7F"), AccentBright = Hex("FFFFFF"),
					SectionBackground = Hex("151515"),
				},
				OLED = {
					Background = Hex("000000"), SubBackground = Hex("000000"),
					TabBackground = Hex("0A0A0A"), Divider = Hex("141414"),
					SubText = Hex("555555"), Accent = Hex("FFFFFF"),
					AccentTwo = Hex("888888"), AccentBright = Hex("FFFFFF"),
					SectionBackground = Hex("050505"),
				},
			}

			local PaletteKeys = { "Background", "SubBackground", "TabBackground", "Divider", "SubText", "Accent", "AccentTwo", "AccentBright", "SectionBackground" }
			local ThemePickers = {}

			ThemeBox:AddDropdown({
				Flag = "ThemePreset",
				Text = "Preset",
				Values = { "Default", "Crimson", "Violet", "Forest", "Amber", "Mono", "OLED" },
				Default = "Default",
				Callback = function(name)
					local p = ThemePresets[name]
					if not p then return end
					for k, v in pairs(p) do
						Palette.Default[k] = v
						if ThemePickers[k] then ThemePickers[k]:Set(v, 0) end
					end
					LibRef:RefreshPalette()
				end,
			})

			for _, key in ipairs(PaletteKeys) do
				ThemePickers[key] = ThemeBox:AddColorpicker({
					Flag = "Theme_" .. key,
					Text = key,
					Default = Palette.Default[key],
					Callback = function(c)
						Palette.Default[key] = c
						LibRef:RefreshPalette()
					end,
				})
			end

			local ConfigHost = ConfigsSub.Content
			local SettingsRow = LibRef:CreateInstance("Frame", {
				Name = "SettingsRow",
				Parent = ConfigHost,
				Position = NewUDim2(0, 0, 0, 0),
				Size = NewUDim2(1, 0, 0, 40),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			})

			local Input = LibRef:CreateInstance("Frame", {
				Name = "ConfigName",
				Parent = SettingsRow,
				Position = NewUDim2(0, 0, 0, 0),
				Size = NewUDim2(1, -50, 1, 0),
				BackgroundColor3 = Palette.Default.TabBackground,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UICorner", { Parent = Input, CornerRadius = NewUDim(0, 6) })
			LibRef:CreateInstance("UIPadding", {
				Parent = Input,
				PaddingLeft = NewUDim(0, 14),
				PaddingRight = NewUDim(0, 40),
			})
			local Box = LibRef:CreateInstance("TextBox", {
				Name = "TextBox",
				Parent = Input,
				Size = NewUDim2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.SemiBold,
				Text = "",
				PlaceholderText = "new config name here..",
				PlaceholderColor3 = Palette.Default.SubText,
				TextColor3 = FromRgb(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ClearTextOnFocus = false,
			})
			local EditIcon = LibRef:CreateInstance("ImageLabel", {
				Name = "EditIcon",
				Parent = Input,
				AnchorPoint = NewVector2(1, 0.5),
				Position = NewUDim2(1, 26, 0.5, 0),
				Size = NewUDim2(0, 18, 0, 18),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://131168464498092",
				ImageColor3 = FromRgb(190, 190, 200),
				ScaleType = Enum.ScaleType.Fit,
			})

			local Widget = LibRef:CreateInstance("TextButton", {
				Name = "ConfigWidget",
				Parent = SettingsRow,
				AnchorPoint = NewVector2(1, 0),
				Position = NewUDim2(1, 0, 0, 0),
				Size = NewUDim2(0, 40, 1, 0),
				AutoButtonColor = false,
				Text = "",
				BackgroundColor3 = Palette.Default.TabBackground,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UICorner", { Parent = Widget, CornerRadius = NewUDim(0, 6) })
			LibRef:CreateInstance("ImageLabel", {
				Name = "Icon",
				Parent = Widget,
				AnchorPoint = NewVector2(0.5, 0.5),
				Position = NewUDim2(0.5, 0, 0.5, 0),
				Size = NewUDim2(0, 14, 0, 14),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://80753039158653",
				ImageColor3 = FromRgb(190, 190, 200),
				ScaleType = Enum.ScaleType.Fit,
			})

			local BarTween = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local CheckTween = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local ExpandTween = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

			local ConfigList = LibRef:CreateInstance("ScrollingFrame", {
				Name = "ConfigList",
				Parent = ConfigHost,
				Position = NewUDim2(0, 0, 0, 48),
				Size = NewUDim2(1, 0, 1, -48),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				CanvasSize = NewUDim2(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 5,
				ScrollBarImageColor3 = Palette.Default.Accent,
				ScrollBarImageTransparency = 0,
				ScrollingEnabled = true,
				ElasticBehavior = Enum.ElasticBehavior.Never,
				Active = true,
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = ConfigList,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 8),
			})

			local LoadedName = "Default"
			local ConfigBars = {}
			local RenderFns = {}
			local SetNameFns = {}
			local ConfigSelectedCallback = function(name) end

			local function WriteConfig(name, dateType, dateStr)
				local header = (dateType or "CR") .. " " .. (dateStr or os.date("%d.%m.%Y"))
				local body = LibRef:SerializeFlags()
				writefile(configFolder .. "/" .. name .. ".cfg", header .. "\n" .. body .. "\n")
			end
			local function RemoveConfig(name)
				local path = configFolder .. "/" .. name .. ".cfg"
				if isfile(path) then delfile(path) end
			end
			local function SetLoaded(newName)
				LoadedName = newName
				for nm, fn in pairs(RenderFns) do
					fn(nm == LoadedName)
				end
				local path = configFolder .. "/" .. newName .. ".cfg"
				if isfile(path) then
					local content = readfile(path)
					if content then
						local body = content:match("^[^\n]*\n(.*)$") or ""
						LibRef:DeserializeFlags(body)
					end
				end
				ConfigSelectedCallback(LoadedName)
			end

			local RefreshAutoloadList

			local function CreateConfigBar(name, dateType, dateStr, canDelete)
				if ConfigBars[name] then return end
				dateStr = dateStr or "01.01.2025"
				local currentName = name

				local Bar = LibRef:CreateInstance("TextButton", {
					Name = "ConfigBar_" .. name,
					Parent = ConfigList,
					Size = NewUDim2(1, 0, 0, 96),
					BackgroundColor3 = Palette.Default.Accent,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					AutoButtonColor = false,
					Text = "",
				})
				LibRef:CreateInstance("UICorner", { Parent = Bar, CornerRadius = NewUDim(0, 6) })

				local SubBar = LibRef:CreateInstance("Frame", {
					Name = "SubBar",
					Parent = Bar,
					AnchorPoint = NewVector2(1, 0),
					Position = NewUDim2(1, 0, 0, 0),
					Size = NewUDim2(1, -3, 1, 0),
					BackgroundColor3 = Palette.Default.SubBackground,
					BorderSizePixel = 0,
				})

				local TitleLbl = LibRef:CreateInstance("TextLabel", {
					Name = "Title",
					Parent = SubBar,
					Position = NewUDim2(0, 12, 0, 12),
					Size = NewUDim2(1, -52, 0, 18),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = name,
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})

				local CheckBox = LibRef:CreateInstance("TextButton", {
					Name = "CheckBox",
					Parent = SubBar,
					AnchorPoint = NewVector2(1, 0),
					Position = NewUDim2(1, -10, 0, 12),
					Size = NewUDim2(0, 18, 0, 18),
					AutoButtonColor = false,
					Text = "",
					BackgroundColor3 = Palette.Default.Accent,
					BorderSizePixel = 0,
				})
				LibRef:CreateInstance("UICorner", { Parent = CheckBox, CornerRadius = NewUDim(0, 4) })
				local CheckMark = LibRef:CreateInstance("TextLabel", {
					Name = "Check",
					Parent = CheckBox,
					Size = NewUDim2(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = "✓",
					TextColor3 = Palette.Default.Background,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				})

				LibRef:CreateInstance("Frame", {
					Name = "Divider",
					Parent = SubBar,
					Position = NewUDim2(0, 10, 0, 42),
					Size = NewUDim2(1, -20, 0, 1),
					BackgroundColor3 = Palette.Default.Divider,
					BorderSizePixel = 0,
				})

				local DateLbl = LibRef:CreateInstance("TextLabel", {
					Name = "Created",
					Parent = SubBar,
					AnchorPoint = NewVector2(0, 1),
					Position = NewUDim2(0, 12, 1, -20),
					Size = NewUDim2(0, 0, 0, 16),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.Regular,
					Text = (dateType == "MF" and "Modified - " or "Created - ") .. dateStr,
					TextColor3 = Palette.Default.SubText,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				})

				local DeleteBtn, DeleteIcon, DeleteLbl
				if canDelete then
					DeleteBtn = LibRef:CreateInstance("TextButton", {
						Name = "DeleteBtn",
						Parent = SubBar,
						AnchorPoint = NewVector2(1, 1),
						Position = NewUDim2(1, -178, 1, -10),
						Size = NewUDim2(0, 78, 0, 34),
						AutoButtonColor = false,
						Text = "",
						BackgroundColor3 = Palette.Default.TabBackground,
						BorderSizePixel = 0,
					})
					LibRef:CreateInstance("UICorner", { Parent = DeleteBtn, CornerRadius = NewUDim(0, 6) })
					LibRef:CreateInstance("UIListLayout", {
						Parent = DeleteBtn,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = NewUDim(0, 6),
					})
					DeleteIcon = LibRef:CreateInstance("ImageLabel", {
						Parent = DeleteBtn, LayoutOrder = 1,
						Size = NewUDim2(0, 11, 0, 11),
						BackgroundTransparency = 1, BorderSizePixel = 0,
						Image = "rbxassetid://127835493649148",
						ImageColor3 = FromRgb(255, 255, 255),
						ScaleType = Enum.ScaleType.Fit,
					})
					DeleteLbl = LibRef:CreateInstance("TextLabel", {
						Parent = DeleteBtn, LayoutOrder = 2,
						Size = NewUDim2(0, 0, 0, 14),
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1, BorderSizePixel = 0,
						FontFace = Library.Fonts.SemiBold,
						Text = "Delete",
						TextColor3 = FromRgb(255, 255, 255),
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
					})
				end

				local ModifyBtn = LibRef:CreateInstance("TextButton", {
					Name = "ModifyBtn",
					Parent = SubBar,
					AnchorPoint = NewVector2(1, 1),
					Position = NewUDim2(1, -94, 1, -10),
					Size = NewUDim2(0, 78, 0, 34),
					AutoButtonColor = false,
					Text = "",
					BackgroundColor3 = Palette.Default.TabBackground,
					BorderSizePixel = 0,
					ClipsDescendants = true,
				})
				LibRef:CreateInstance("UICorner", { Parent = ModifyBtn, CornerRadius = NewUDim(0, 6) })
				local ModifyRow = LibRef:CreateInstance("Frame", {
					Name = "Row",
					Parent = ModifyBtn,
					AnchorPoint = NewVector2(0.5, 0.5),
					Position = NewUDim2(0.5, 0, 0.5, 0),
					Size = NewUDim2(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				})
				LibRef:CreateInstance("UIListLayout", {
					Parent = ModifyRow,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = NewUDim(0, 6),
				})
				local ModifyIcon = LibRef:CreateInstance("ImageLabel", {
					Parent = ModifyRow, LayoutOrder = 1,
					Size = NewUDim2(0, 11, 0, 11),
					BackgroundTransparency = 1, BorderSizePixel = 0,
					Image = "rbxassetid://131168464498092",
					ImageColor3 = FromRgb(255, 255, 255),
					ScaleType = Enum.ScaleType.Fit,
				})
				local ModifyLbl = LibRef:CreateInstance("TextLabel", {
					Parent = ModifyRow, LayoutOrder = 2,
					Size = NewUDim2(0, 0, 0, 14),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1, BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = "Modify",
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				})

				local ModifyInput = LibRef:CreateInstance("TextBox", {
					Name = "Rename",
					Parent = ModifyBtn,
					Position = NewUDim2(0, 14, 0, 0),
					Size = NewUDim2(1, -28, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = "",
					PlaceholderText = "new config name here..",
					PlaceholderColor3 = Palette.Default.SubText,
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					ClearTextOnFocus = false,
					Visible = false,
				})

				local SaveBtn = LibRef:CreateInstance("TextButton", {
					Name = "SaveBtn",
					Parent = SubBar,
					AnchorPoint = NewVector2(1, 1),
					Position = NewUDim2(1, -10, 1, -10),
					Size = NewUDim2(0, 78, 0, 34),
					AutoButtonColor = false,
					Text = "",
					BackgroundColor3 = Palette.Default.TabBackground,
					BorderSizePixel = 0,
				})
				LibRef:CreateInstance("UICorner", { Parent = SaveBtn, CornerRadius = NewUDim(0, 6) })
				LibRef:CreateInstance("UIListLayout", {
					Parent = SaveBtn,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = NewUDim(0, 6),
				})
				local SaveIcon = LibRef:CreateInstance("ImageLabel", {
					Parent = SaveBtn, LayoutOrder = 1,
					Size = NewUDim2(0, 11, 0, 11),
					BackgroundTransparency = 1, BorderSizePixel = 0,
					Image = "rbxassetid://90921118572382",
					ImageColor3 = FromRgb(255, 255, 255),
					ScaleType = Enum.ScaleType.Fit,
				})
				local SaveLbl = LibRef:CreateInstance("TextLabel", {
					Parent = SaveBtn, LayoutOrder = 2,
					Size = NewUDim2(0, 0, 0, 14),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1, BorderSizePixel = 0,
					FontFace = Library.Fonts.SemiBold,
					Text = "Save",
					TextColor3 = FromRgb(255, 255, 255),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
				})


				local function RenderActive(on)
					TweenNew(Bar, BarTween, {
						BackgroundColor3 = on and Palette.Default.Accent or Palette.Default.TabBackground,
					}):Play()
					TweenNew(CheckBox, BarTween, {
						BackgroundColor3 = on and Palette.Default.Accent or Palette.Default.TabBackground,
					}):Play()
					TweenNew(CheckMark, CheckTween, {
						TextTransparency = on and 0 or 1,
						TextSize = on and 14 or 10,
					}):Play()
				end
				RenderFns[currentName] = RenderActive
				RenderActive(currentName == LoadedName)

				local Editing = false
				local function EnterEdit()
					if Editing then return end
					Editing = true
					ModifyInput.Text = currentName
					ModifyInput.Visible = true
					ModifyInput:CaptureFocus()
					TweenNew(ModifyBtn, ExpandTween, {
						Size = NewUDim2(1, -20, 0, 34),
						Position = NewUDim2(1, -10, 1, -10),
					}):Play()
					TweenNew(ModifyIcon, BarTween, { ImageTransparency = 1 }):Play()
					TweenNew(ModifyLbl, BarTween, { TextTransparency = 1 }):Play()
					if canDelete then
						TweenNew(DeleteBtn, BarTween, { BackgroundTransparency = 1 }):Play()
						TweenNew(DeleteIcon, BarTween, { ImageTransparency = 1 }):Play()
						TweenNew(DeleteLbl, BarTween, { TextTransparency = 1 }):Play()
					end
					TweenNew(SaveBtn, BarTween, { BackgroundTransparency = 1 }):Play()
					TweenNew(SaveIcon, BarTween, { ImageTransparency = 1 }):Play()
					TweenNew(SaveLbl, BarTween, { TextTransparency = 1 }):Play()
					TweenNew(DateLbl, BarTween, { TextTransparency = 1 }):Play()
				end
				local function ExitEdit()
					if not Editing then return end
					Editing = false
					ModifyInput.Visible = false
					TweenNew(ModifyBtn, ExpandTween, {
						Size = NewUDim2(0, 78, 0, 34),
						Position = NewUDim2(1, -94, 1, -10),
					}):Play()
					TweenNew(ModifyIcon, BarTween, { ImageTransparency = 0 }):Play()
					TweenNew(ModifyLbl, BarTween, { TextTransparency = 0 }):Play()
					if canDelete then
						TweenNew(DeleteBtn, BarTween, { BackgroundTransparency = 0 }):Play()
						TweenNew(DeleteIcon, BarTween, { ImageTransparency = 0 }):Play()
						TweenNew(DeleteLbl, BarTween, { TextTransparency = 0 }):Play()
					end
					TweenNew(SaveBtn, BarTween, { BackgroundTransparency = 0 }):Play()
					TweenNew(SaveIcon, BarTween, { ImageTransparency = 0 }):Play()
					TweenNew(SaveLbl, BarTween, { TextTransparency = 0 }):Play()
					TweenNew(DateLbl, BarTween, { TextTransparency = 0 }):Play()
				end
				local function SetName(newName)
					if newName == currentName or newName == "" or ConfigBars[newName] then return end
					local dt = os.date("%d.%m.%Y")
					if canDelete then
						local oldPath = configFolder .. "/" .. currentName .. ".cfg"
						local newPath = configFolder .. "/" .. newName .. ".cfg"
						local body = ""
						if isfile(oldPath) then
							local content = readfile(oldPath)
							body = content:match("^[^\n]*\n(.*)$") or ""
							delfile(oldPath)
						end
						writefile(newPath, "MF " .. dt .. "\n" .. body)
					end
					ConfigBars[newName] = ConfigBars[currentName]
					ConfigBars[currentName] = nil
					RenderFns[newName] = RenderFns[currentName]
					RenderFns[currentName] = nil
					SetNameFns[newName] = SetNameFns[currentName]
					SetNameFns[currentName] = nil
					if LoadedName == currentName then LoadedName = newName end
					currentName = newName
					TitleLbl.Text = newName
					if canDelete then DateLbl.Text = "Modified - " .. dt end
					Bar.Name = "ConfigBar_" .. newName
					if RefreshAutoloadList then RefreshAutoloadList() end
				end
				SetNameFns[currentName] = SetName

				LibRef:Connection(ModifyInput.FocusLost, function(enterPressed)
					local newName = ModifyInput.Text
					ExitEdit()
					if enterPressed and newName ~= "" then
						SetName(newName)
					end
				end)

				LibRef:Connection(CheckBox.MouseButton1Click, function()
					SetLoaded(currentName)
				end)
				LibRef:Connection(Bar.MouseButton1Click, function()
					if Editing then return end
					SetLoaded(currentName)
				end)
				LibRef:Connection(ModifyBtn.MouseButton1Click, function()
					if not Editing then EnterEdit() end
				end)
				LibRef:Connection(SaveBtn.MouseButton1Click, function()
					if Editing then return end
					SaveBtn.BackgroundColor3 = Palette.Default.Accent
					TweenNew(SaveBtn, BarTween, { BackgroundColor3 = Palette.Default.TabBackground }):Play()
					local dt = os.date("%d.%m.%Y")
					WriteConfig(currentName, "MF", dt)
					DateLbl.Text = "Modified - " .. dt
				end)
				if canDelete then
					LibRef:Connection(DeleteBtn.MouseButton1Click, function()
						if Editing then return end
						DeleteBtn.BackgroundColor3 = Palette.Default.Accent
						TweenNew(DeleteBtn, BarTween, { BackgroundColor3 = Palette.Default.TabBackground }):Play()
						task.delay(BarTween.Time, function()
							RemoveConfig(currentName)
							Bar:Destroy()
							ConfigBars[currentName] = nil
							RenderFns[currentName] = nil
							SetNameFns[currentName] = nil
							if LoadedName == currentName then
								SetLoaded("Default")
							end
							if RefreshAutoloadList then RefreshAutoloadList() end
						end)
					end)
				end

				ConfigBars[currentName] = Bar
				return Bar
			end

			CreateConfigBar("Default", "CR", os.date("%d.%m.%Y"), false)

			if isfolder and isfolder(configFolder) then
				for _, path in ipairs(listfiles(configFolder)) do
					local shortname = path:match("([^/\\]+)%.cfg$")
					if shortname and shortname ~= "Default" then
						local content = readfile(path)
						if content then
							local firstLine = content:match("^([^\n]*)") or ""
							local dtType, dtStr = firstLine:match("^(%S+)%s+(.+)$")
							CreateConfigBar(shortname, dtType or "CR", dtStr or "01.01.2025", true)
						end
					end
				end
			end

			RefreshAutoloadList = function()
				local names = { "None", "Default" }
				for nm, _ in pairs(ConfigBars) do
					if nm ~= "Default" then Insert(names, nm) end
				end
				AutoloadDropdown:SetValues(names)
			end

			LibRef:Connection(Widget.MouseButton1Click, function()
				local nm = Box.Text
				if nm == "" or ConfigBars[nm] then return end
				local dt = os.date("%d.%m.%Y")
				WriteConfig(nm, "CR", dt)
				CreateConfigBar(nm, "CR", dt, true)
				Box.Text = ""
				RefreshAutoloadList()
			end)

			if AutoloadInitial and AutoloadInitial ~= "None" and ConfigBars[AutoloadInitial] then
				task.defer(function() SetLoaded(AutoloadInitial) end)
			end

			return {
				Options = OptionsSub,
				Configs = ConfigsSub,
				Row = SettingsRow,
				Input = Box,
				Widget = Widget,
				EditIcon = EditIcon,
				ConfigList = ConfigList,
				OnConfigSelected = function(_, cb)
					ConfigSelectedCallback = typeof(cb) == "function" and cb or function() end
				end,
				GetLoaded = function() return LoadedName end,
			}
		end

		function TabObj:AddSubTab(Name, Icon)
			local SubName = tostring(Name or "SubTab")
			local HasIcon = Icon ~= nil and tostring(Icon) ~= ""

			if self._hasSections then
				error("Tab '" .. self.Name .. "' already has sections - can't add subtabs", 2)
			end

			if #self.SubTabs == 0 then
				SubTabBar.Visible = true
				SubTabDivider.Visible = true
				Content.Position = NewUDim2(0, 0, 0, 50)
				Content.Size = NewUDim2(1, 0, 1, -50)
			end

			local SubBtn = LibRef:CreateInstance("TextButton", {
				Name = "SubTab_" .. SubName,
				Parent = self.SubTabBar,
				AutoButtonColor = false,
				Text = "",
				BackgroundColor3 = Palette.Default.TabBackground,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = NewUDim2(0, 0, 1, -12),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = #self.SubTabs + 1,
			})
			LibRef:CreateInstance("UICorner", {
				Parent = SubBtn,
				CornerRadius = NewUDim(0, 6),
			})
			LibRef:CreateInstance("UIPadding", {
				Parent = SubBtn,
				PaddingLeft = NewUDim(0, 24),
				PaddingRight = NewUDim(0, 24),
			})

			local Row = LibRef:CreateInstance("Frame", {
				Name = "Row",
				Parent = SubBtn,
				AnchorPoint = NewVector2(0.5, 0.5),
				Position = NewUDim2(0.5, 0, 0.5, 0),
				Size = NewUDim2(0, 0, 0, 14),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			})
			LibRef:CreateInstance("UIListLayout", {
				Parent = Row,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = NewUDim(0, 6),
			})

			local SubIcn
			if HasIcon then
				SubIcn = LibRef:CreateInstance("ImageLabel", {
					Name = "Icon",
					Parent = Row,
					LayoutOrder = 1,
					Size = NewUDim2(0, 14, 0, 14),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = tostring(Icon),
					ImageColor3 = Palette.Default.SubText,
					ScaleType = Enum.ScaleType.Fit,
				})
			end

			local SubLbl = LibRef:CreateInstance("TextLabel", {
				Name = "Label",
				Parent = Row,
				LayoutOrder = 2,
				Size = NewUDim2(0, 0, 0, 14),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Library.Fonts.SemiBold,
				Text = SubName,
				TextColor3 = Palette.Default.SubText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})

			local SubUnderline = LibRef:CreateInstance("Frame", {
				Name = "Underline",
				Parent = SubBtn,
				AnchorPoint = NewVector2(0.5, 1),
				Position = NewUDim2(0.5, 0, 1, 7),
				Size = NewUDim2(0, 0, 0, 3),
				BackgroundColor3 = Palette.Default.Accent,
				BorderSizePixel = 0,
				ZIndex = 2,
			})

			local SubContent = LibRef:CreateInstance("CanvasGroup", {
				Name = "SubContent_" .. SubName,
				Parent = self.Content,
				Position = NewUDim2(0, 0, 0, 0),
				Size = NewUDim2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = false,
				GroupTransparency = 1,
			})
			LibRef:CreateInstance("UIPadding", {
				Parent = SubContent,
				PaddingTop = NewUDim(0, 12),
				PaddingBottom = NewUDim(0, 12),
				PaddingLeft = NewUDim(0, 12),
				PaddingRight = NewUDim(0, 12),
			})

			local SubTabObj = {
				Name = SubName,
				Button = SubBtn,
				Icon = SubIcn,
				Label = SubLbl,
				Underline = SubUnderline,
				Content = SubContent,
			}

			function SubTabObj:SetActive(on)
				on = on == true
				if on then
					self.Content.Visible = true
				end
				TweenNew(self.Content, TweenInfoSwitch, {
					GroupTransparency = on and 0 or 1,
				}):Play()
				if not on then
					task.delay(TweenInfoSwitch.Time, function()
						if self.Content.GroupTransparency > 0.99 then
							self.Content.Visible = false
						end
					end)
				end
				TweenNew(self.Button, TweenInfoSwitch, {
					BackgroundTransparency = on and 0 or 1,
				}):Play()
				if self.Icon then
					TweenNew(self.Icon, TweenInfoSwitch, {
						ImageColor3 = on and Palette.Default.Accent or Palette.Default.SubText,
					}):Play()
				end
			TweenNew(self.Label, TweenInfoSwitch, {
					TextColor3 = on and FromRgb(255, 255, 255) or Palette.Default.SubText,
				}):Play()
				TweenNew(self.Underline, TweenInfoSwitch, {
					Size = NewUDim2(0, on and 23 or 0, 0, 3),
				}):Play()
			end

			LibRef:RegisterThemeRenderer(function()
				if SubBtn.Parent then
					SubTabObj:SetActive(TabObj.ActiveSubTab == SubTabObj)
				end
			end)

			function SubTabObj:AddLeftGroupbox(Name)
				local Left = LibRef:EnsureColumns(self.Content)
				return LibRef:CreateSection(Left, Name)
			end

			function SubTabObj:AddRightGroupbox(Name)
				local _, Right = LibRef:EnsureColumns(self.Content)
				return LibRef:CreateSection(Right, Name)
			end

			LibRef:Connection(SubBtn.MouseButton1Click, function()
				if TabObj.ActiveSubTab == SubTabObj then
					return
				end
				if TabObj.ActiveSubTab then
					TabObj.ActiveSubTab:SetActive(false)
				end
				SubTabObj:SetActive(true)
				TabObj.ActiveSubTab = SubTabObj
			end)

			Insert(TabObj.SubTabs, SubTabObj)
			if not TabObj.ActiveSubTab then
				SubTabObj:SetActive(true)
				TabObj.ActiveSubTab = SubTabObj
			end

			return SubTabObj
		end

		LibRef:Connection(Btn.MouseButton1Click, function()
			if WindowObject.ActiveTab == TabObj then
				return
			end
			if WindowObject.ActiveTab then
				WindowObject.ActiveTab:SetActive(false)
			end
			TabObj:SetActive(true)
			WindowObject.ActiveTab = TabObj
		end)

		Insert(self.Tabs, TabObj)
		if not self.ActiveTab then
			TabObj:SetActive(true)
			self.ActiveTab = TabObj
		end

		return TabObj
	end

	self.CurrentlyOpen = WindowObject
	return WindowObject
end

-- Lifecycle

function Library:Unload()
	for _, Conn in ipairs(self.Connections) do
		if Conn ~= nil then Conn:Disconnect() end
	end
	self.Connections = {}

	if self.CurrentlyOpen and self.CurrentlyOpen.Gui then
		self.CurrentlyOpen.Gui:Destroy()
	end
	self.CurrentlyOpen = nil

	self.Toggles = {}
	self.Options = {}
	self.Flags = {}
	self.ConfigFlags = {}
	self.AccentUpdaters = {}
	self._ThemedProperties = {}
	self._ThemedGradients = {}
	self._ThemeRenderers = {}

	if self.KeybindList and self.KeybindList.Gui then
		self.KeybindList.Gui:Destroy()
		self.KeybindList.Entries = {}
		self.KeybindList.OrderedIds = {}
		self.KeybindList.Items = {}
	end

	if self.Notifications and self.Notifications.Gui then
		self.Notifications.Gui:Destroy()
		self.Notifications.Queue = {}
	end
end



return Library
