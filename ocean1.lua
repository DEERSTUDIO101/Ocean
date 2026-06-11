local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local lucide
pcall(function()
	lucide = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	lucide.SetIconsType("lucide")
end)

local function getLucide(iconName, size)
	if not lucide then return "" end
	local s, res = pcall(function()
		return lucide.GetIcon(iconName)
	end)
	return s and res or ""
end

local function isMobile()
	local vp = camera.ViewportSize
	return UIS.TouchEnabled and not UIS.MouseEnabled or vp.X < 600
end

local CORNER = 10

local THEMES = {
	Ocean = {
		black    = Color3.fromRGB(0,   0,   0  ),
		bg       = Color3.fromRGB(18,  18,  18 ),
		surface  = Color3.fromRGB(24,  24,  24 ),
		raised   = Color3.fromRGB(30,  30,  30 ),
		border   = Color3.fromRGB(48,  48,  48 ),
		borderHi = Color3.fromRGB(60,  60,  60 ),
		muted    = Color3.fromRGB(120, 120, 120),
		sub      = Color3.fromRGB(160, 160, 160),
		text     = Color3.fromRGB(250, 250, 250),
		white    = Color3.fromRGB(255, 255, 255),
		logoTop  = Color3.fromRGB(210, 210, 210),
		logoMid  = Color3.fromRGB(155, 155, 155),
		logoBot  = Color3.fromRGB(90,  90,  90 ),
	},

	DeepOcean = {
		black    = Color3.fromRGB(0,   5,   15 ),
		bg       = Color3.fromRGB(8,   18,  38 ),
		surface  = Color3.fromRGB(12,  26,  52 ),
		raised   = Color3.fromRGB(18,  38,  72 ),
		border   = Color3.fromRGB(30,  60,  110),
		borderHi = Color3.fromRGB(50,  90,  150),
		muted    = Color3.fromRGB(80,  130, 180),
		sub      = Color3.fromRGB(120, 170, 220),
		text     = Color3.fromRGB(220, 240, 255),
		white    = Color3.fromRGB(150, 210, 255),
		logoTop  = Color3.fromRGB(100, 200, 255),
		logoMid  = Color3.fromRGB(60,  140, 220),
		logoBot  = Color3.fromRGB(20,  70,  150),
	},

	Christmas = {
		black    = Color3.fromRGB(0,   0,   0  ),
		bg       = Color3.fromRGB(10,  30,  14 ),
		surface  = Color3.fromRGB(15,  40,  18 ),
		raised   = Color3.fromRGB(100, 20,  20 ),
		border   = Color3.fromRGB(160, 30,  30 ),
		borderHi = Color3.fromRGB(200, 50,  50 ),
		muted    = Color3.fromRGB(170, 130, 100),
		sub      = Color3.fromRGB(210, 170, 130),
		text     = Color3.fromRGB(255, 240, 220),
		white    = Color3.fromRGB(255, 215, 0  ),  -- gold accent
		logoTop  = Color3.fromRGB(255, 60,  60 ),
		logoMid  = Color3.fromRGB(30,  160, 60 ),
		logoBot  = Color3.fromRGB(10,  80,  30 ),
	},

	Easter = {
		black    = Color3.fromRGB(40,  0,   60 ),
		bg       = Color3.fromRGB(42,  18,  60 ),
		surface  = Color3.fromRGB(55,  28,  78 ),
		raised   = Color3.fromRGB(80,  50,  110),
		border   = Color3.fromRGB(160, 100, 200),
		borderHi = Color3.fromRGB(200, 140, 240),
		muted    = Color3.fromRGB(190, 160, 210),
		sub      = Color3.fromRGB(220, 190, 240),
		text     = Color3.fromRGB(255, 245, 255),
		white    = Color3.fromRGB(255, 240, 100),  -- pastel yellow accent
		logoTop  = Color3.fromRGB(255, 180, 200),
		logoMid  = Color3.fromRGB(180, 120, 240),
		logoBot  = Color3.fromRGB(100, 50,  160),
	},

	Blood = {
		black    = Color3.fromRGB(0,   0,   0  ),
		bg       = Color3.fromRGB(14,  4,   4  ),
		surface  = Color3.fromRGB(22,  6,   6  ),
		raised   = Color3.fromRGB(50,  8,   8  ),
		border   = Color3.fromRGB(100, 10,  10 ),
		borderHi = Color3.fromRGB(160, 20,  20 ),
		muted    = Color3.fromRGB(160, 80,  80 ),
		sub      = Color3.fromRGB(200, 110, 110),
		text     = Color3.fromRGB(255, 220, 220),
		white    = Color3.fromRGB(230, 30,  30 ),  -- blood-red accent
		logoTop  = Color3.fromRGB(220, 20,  20 ),
		logoMid  = Color3.fromRGB(140, 10,  10 ),
		logoBot  = Color3.fromRGB(60,  0,   0  ),
	},

	Camo = {
		black    = Color3.fromRGB(0,   0,   0  ),
		bg       = Color3.fromRGB(26,  30,  16 ),
		surface  = Color3.fromRGB(36,  42,  22 ),
		raised   = Color3.fromRGB(52,  62,  30 ),
		border   = Color3.fromRGB(80,  95,  45 ),
		borderHi = Color3.fromRGB(110, 130, 60 ),
		muted    = Color3.fromRGB(140, 160, 90 ),
		sub      = Color3.fromRGB(170, 190, 110),
		text     = Color3.fromRGB(230, 230, 200),
		white    = Color3.fromRGB(200, 220, 140),  -- khaki accent
		logoTop  = Color3.fromRGB(160, 200, 80 ),
		logoMid  = Color3.fromRGB(100, 130, 50 ),
		logoBot  = Color3.fromRGB(50,  70,  20 ),
	},

	OceanBlue = {
		black    = Color3.fromRGB(0,   10,  20 ),
		bg       = Color3.fromRGB(10,  30,  50 ),
		surface  = Color3.fromRGB(14,  40,  65 ),
		raised   = Color3.fromRGB(20,  60,  90 ),
		border   = Color3.fromRGB(30,  90,  130),
		borderHi = Color3.fromRGB(50,  120, 170),
		muted    = Color3.fromRGB(80,  160, 190),
		sub      = Color3.fromRGB(120, 190, 220),
		text     = Color3.fromRGB(220, 245, 255),
		white    = Color3.fromRGB(0,   210, 200),  -- teal accent
		logoTop  = Color3.fromRGB(0,   220, 210),
		logoMid  = Color3.fromRGB(0,   160, 180),
		logoBot  = Color3.fromRGB(0,   80,  120),
	},

	Neon = {
		black    = Color3.fromRGB(0,   0,   0  ),
		bg       = Color3.fromRGB(8,   6,   18 ),
		surface  = Color3.fromRGB(12,  10,  28 ),
		raised   = Color3.fromRGB(22,  16,  46 ),
		border   = Color3.fromRGB(80,  0,   160),
		borderHi = Color3.fromRGB(140, 0,   255),
		muted    = Color3.fromRGB(160, 80,  200),
		sub      = Color3.fromRGB(200, 120, 240),
		text     = Color3.fromRGB(240, 220, 255),
		white    = Color3.fromRGB(255, 0,   200),  -- hot-pink accent
		logoTop  = Color3.fromRGB(200, 0,   255),
		logoMid  = Color3.fromRGB(120, 0,   200),
		logoBot  = Color3.fromRGB(60,  0,   120),
	},

	Midnight = {
		black    = Color3.fromRGB(0,   0,   8  ),
		bg       = Color3.fromRGB(6,   6,   20 ),
		surface  = Color3.fromRGB(10,  10,  30 ),
		raised   = Color3.fromRGB(16,  16,  48 ),
		border   = Color3.fromRGB(40,  40,  100),
		borderHi = Color3.fromRGB(60,  60,  140),
		muted    = Color3.fromRGB(100, 100, 180),
		sub      = Color3.fromRGB(140, 140, 210),
		text     = Color3.fromRGB(220, 220, 255),
		white    = Color3.fromRGB(180, 180, 255),
		logoTop  = Color3.fromRGB(160, 160, 255),
		logoMid  = Color3.fromRGB(100, 100, 200),
		logoBot  = Color3.fromRGB(40,  40,  120),
	},

	RoseGold = {
		black    = Color3.fromRGB(20,  8,   12 ),
		bg       = Color3.fromRGB(32,  16,  20 ),
		surface  = Color3.fromRGB(44,  22,  28 ),
		raised   = Color3.fromRGB(70,  38,  46 ),
		border   = Color3.fromRGB(160, 90,  100),
		borderHi = Color3.fromRGB(200, 120, 130),
		muted    = Color3.fromRGB(200, 150, 155),
		sub      = Color3.fromRGB(230, 180, 185),
		text     = Color3.fromRGB(255, 235, 238),
		white    = Color3.fromRGB(255, 185, 140),  -- rose-gold accent
		logoTop  = Color3.fromRGB(255, 180, 130),
		logoMid  = Color3.fromRGB(200, 110, 100),
		logoBot  = Color3.fromRGB(120, 50,  60 ),
	},

	Light = {
		black    = Color3.fromRGB(220, 220, 220),
		bg       = Color3.fromRGB(245, 245, 248),
		surface  = Color3.fromRGB(235, 235, 240),
		raised   = Color3.fromRGB(210, 212, 220),
		border   = Color3.fromRGB(180, 182, 192),
		borderHi = Color3.fromRGB(140, 142, 155),
		muted    = Color3.fromRGB(110, 112, 125),
		sub      = Color3.fromRGB(70,  72,  85 ),
		text     = Color3.fromRGB(20,  20,  30 ),
		white    = Color3.fromRGB(50,  100, 220),  -- blue accent
		logoTop  = Color3.fromRGB(60,  80,  200),
		logoMid  = Color3.fromRGB(100, 120, 210),
		logoBot  = Color3.fromRGB(160, 175, 230),
	},
}

local activeThemeName = "Ocean"
local K = {}
for k, v in pairs(THEMES.Ocean) do
	K[k] = v
end

local themeUpdaters = {}
local function registerThemeUpdater(callback, targetInstance)
	table.insert(themeUpdaters, {cb = callback, target = targetInstance})
	pcall(callback)
end

local function setTheme(themeName)
	if not THEMES[themeName] then return end
	activeThemeName = themeName
	local theme = THEMES[themeName]
	for k, v in pairs(theme) do
		K[k] = v
	end
	
	local activeUpdaters = {}
	for _, item in ipairs(themeUpdaters) do
		local keep = true
		if item.target then
			if not item.target.Parent then
				keep = false
			end
		end
		if keep then
			table.insert(activeUpdaters, item)
			pcall(item.cb)
		end
	end
	themeUpdaters = activeUpdaters
end

local function inst(cls, props, parent)
	local o = Instance.new(cls)
	for k,v in pairs(props or {}) do o[k]=v end
	if parent then o.Parent=parent end
	return o
end

local function tw(obj, goals, t, style, dir)
	return TweenService:Create(obj,
		TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		goals)
end

local function rnd(p, r)
	return inst("UICorner",{CornerRadius=UDim.new(0,r or CORNER)},p)
end

local function pad(p,l,r,t,b)
	return inst("UIPadding",{
		PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
		PaddingTop=UDim.new(0,t or 0),  PaddingBottom=UDim.new(0,b or 0),
	},p)
end

local function brd(p, col, thick)
	local colorKey = "border"
	local color = col
	if typeof(col) == "string" then
		colorKey = col
		color = nil
	end
	local stroke = inst("UIStroke",{
		Color=color or K[colorKey] or K.border, Thickness=thick or 1,
		ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
	},p)
	if not color then
		registerThemeUpdater(function()
			stroke.Color = K[colorKey]
		end, stroke)
	end
	return stroke
end

local function frame(parent, p)
	local colorKey = p.colorKey
	local color = p.color
	if typeof(color) == "string" then
		colorKey = color
		color = nil
	end
	if not color and not colorKey and p.trans ~= 1 then
		colorKey = "surface"
	end
	local f = inst("Frame",{
		BackgroundColor3       = color or (colorKey and K[colorKey]) or K.surface,
		BackgroundTransparency = p.trans  or 0,
		BorderSizePixel        = 0,
		Size                   = p.size   or UDim2.fromScale(1,1),
		Position               = p.pos    or UDim2.fromScale(0,0),
		AnchorPoint            = p.anchor or Vector2.zero,
		Name                   = p.name   or "Frame",
		ZIndex                 = p.z      or 1,
		ClipsDescendants       = p.clip   or false,
	}, parent)
	if colorKey then
		registerThemeUpdater(function()
			f.BackgroundColor3 = K[colorKey]
		end, f)
	end
	return f
end

local function lbl(parent, p)
	local colorKey = p.colorKey
	local color = p.color
	if typeof(color) == "string" then
		colorKey = color
		color = nil
	end
	if not color and not colorKey then
		colorKey = "text"
	end
	local l = inst("TextLabel",{
		BackgroundTransparency = 1,
		Font                   = p.font   or Enum.Font.GothamMedium,
		Text                   = p.text   or "",
		TextColor3             = color or K[colorKey] or K.text,
		TextSize               = p.size   or 14,
		TextXAlignment         = p.xa     or Enum.TextXAlignment.Left,
		TextYAlignment         = p.ya     or Enum.TextYAlignment.Center,
		TextTransparency       = p.trans  or 0,
		TextWrapped            = p.wrap   or false,
		Size                   = p.sz     or UDim2.fromScale(1,1),
		Position               = p.pos    or UDim2.fromScale(0,0),
		AnchorPoint            = p.anchor or Vector2.zero,
		Name                   = p.name   or "Lbl",
		ZIndex                 = p.z      or 2,
	}, parent)
	if colorKey then
		registerThemeUpdater(function()
			l.TextColor3 = K[colorKey]
		end, l)
	end
	return l
end

local function btn(parent, p)
	local colorKey = p.colorKey
	local color = p.color
	if typeof(color) == "string" then
		colorKey = color
		color = nil
	end
	local tcKey = p.tcKey
	local tc = p.tc
	if typeof(tc) == "string" then
		tcKey = tc
		tc = nil
	end
	if not color and not colorKey then
		colorKey = "raised"
	end
	if not tc and not tcKey then
		tcKey = "text"
	end
	local b = inst("TextButton",{
		BackgroundColor3       = color or K[colorKey] or K.raised,
		BackgroundTransparency = p.trans  or 0,
		BorderSizePixel        = 0,
		Font                   = p.font   or Enum.Font.GothamMedium,
		Text                   = p.text   or "",
		TextColor3             = tc or K[tcKey] or K.text,
		TextSize               = p.size   or 14,
		TextXAlignment         = p.xa     or Enum.TextXAlignment.Center,
		AutoButtonColor        = false,
		Size                   = p.sz     or UDim2.new(0,80,0,34),
		Position               = p.pos    or UDim2.fromScale(0,0),
		AnchorPoint            = p.anchor or Vector2.zero,
		Name                   = p.name   or "Btn",
		ZIndex                 = p.z      or 3,
	}, parent)
	registerThemeUpdater(function()
		local activeColorKey = b:GetAttribute("colorKey") or colorKey
		local activeTcKey = b:GetAttribute("tcKey") or tcKey
		if not b:GetAttribute("Hovered") then
			b.BackgroundColor3 = K[activeColorKey]
			b.TextColor3 = K[activeTcKey]
		end
	end, b)
	return b
end

local function img(parent, p)
	local colorKey = p.colorKey
	local color = p.color
	if typeof(color) == "string" then
		colorKey = color
		color = nil
	end
	if not color and not colorKey then
		colorKey = "text"
	end
	local i = inst("ImageLabel",{
		BackgroundTransparency = 1,
		Image                  = p.img    or "",
		ImageColor3            = color or K[colorKey] or K.text,
		Size                   = p.sz     or UDim2.fromScale(1,1),
		Position               = p.pos    or UDim2.fromScale(0,0),
		AnchorPoint            = p.anchor or Vector2.zero,
		Name                   = p.name   or "Img",
		ZIndex                 = p.z      or 2,
		ScaleType              = Enum.ScaleType.Fit,
	}, parent)
	if colorKey then
		registerThemeUpdater(function()
			i.ImageColor3 = K[colorKey]
		end, i)
	end
	return i
end

local function makeToggle(parent, initialState)
	local state = initialState or false
	local TRACK_W, TRACK_H = 44, 24
	local KNOB   = 18

	local track = frame(parent,{
		name="Track", color=K.raised,
		size=UDim2.new(0,TRACK_W,0,TRACK_H),
		z=5,
	})
	rnd(track, 99)
	brd(track, "border", 1)

	local knob = frame(track,{
		name="Knob", color=K.white,
		size=UDim2.new(0,KNOB,0,KNOB),
		pos=UDim2.new(0,3,0.5,0), anchor=Vector2.new(0,0.5),
		z=6,
	})
	rnd(knob,99)

	local changedEvent = Instance.new("BindableEvent")

	local function update(s, animate)
		state=s
		local tx = s and TRACK_W-KNOB-3 or 3
		local tc = s and K.white or K.raised
		local kc = s and K.black or K.white
		if animate then
			tw(knob,{Position=UDim2.new(0,tx,0.5,0)},0.18):Play()
			tw(track,{BackgroundColor3=tc},0.18):Play()
			tw(knob,{BackgroundColor3=kc},0.18):Play()
		else
			knob.Position=UDim2.new(0,tx,0.5,0)
			track.BackgroundColor3=tc
			knob.BackgroundColor3=kc
		end
	end

	registerThemeUpdater(function()
		update(state, false)
	end, track)

	local tb = inst("TextButton",{
		BackgroundTransparency=1, Text="",
		Size=UDim2.fromScale(1,1), ZIndex=7, AutoButtonColor=false,
	}, track)
	tb.MouseButton1Click:Connect(function()
		update(not state, true)
		changedEvent:Fire(state)
	end)

	return { frame=track, set=update, changed=changedEvent.Event, getState=function() return state end }
end


local function makeSlider(parent, minV, maxV, defaultV)
	local val = defaultV or minV
	local TRACK_H = 5
	local KNOB_S  = 16

	local changedEvent = Instance.new("BindableEvent")

	local wrap = frame(parent,{
		name="SliderWrap", color=K.surface, trans=1,
		size=UDim2.new(1,0,0,KNOB_S+10), z=5,
	})

	local track = frame(wrap,{
		name="Track", colorKey="border",
		size=UDim2.new(1,-KNOB_S,0,TRACK_H),
		pos=UDim2.new(0,KNOB_S/2,0.5,0), anchor=Vector2.new(0,0.5), z=5,
	})
	rnd(track,99)

	local fill = frame(track,{
		name="Fill", colorKey="white",
		size=UDim2.new(0,0,1,0), clip=false, z=6,
	})
	rnd(fill,99)

	local knobF = frame(track,{
		name="Knob", colorKey="white",
		size=UDim2.new(0,KNOB_S,0,KNOB_S),
		pos=UDim2.new(0,0,0.5,0), anchor=Vector2.new(0.5,0.5), z=7,
	})
	rnd(knobF,99)

	local function setValue(v, silent)
		val = math.clamp(v, minV, maxV)
		local pct = (val-minV)/(maxV-minV)
		fill.Size = UDim2.new(pct,0,1,0)
		knobF.Position = UDim2.new(pct, 0, 0.5, 0)
		if not silent then
			changedEvent:Fire(val)
		end
	end

	local dragging = false
	local ib = inst("TextButton",{
		BackgroundTransparency=1, Text="",
		Size=UDim2.fromScale(1,1), ZIndex=8, AutoButtonColor=false,
	}, wrap)

	local function onInput(input)
		if not dragging then return end
		local abs = track.AbsolutePosition.X
		local sz  = track.AbsoluteSize.X
		local pct = math.clamp((input.Position.X - abs) / sz, 0, 1)
		setValue(minV + pct*(maxV-minV))
	end

	ib.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=true; onInput(inp)
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseMovement
		or inp.UserInputType==Enum.UserInputType.Touch then
			onInput(inp)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=false
		end
	end)

	task.defer(function() setValue(defaultV or minV, true) end)

	return { frame=wrap, setValue=setValue, getValue=function() return val end, changed=changedEvent.Event }
end

local function makeDropdown(parent, options, defaultIdx, onOpenStart)
	local selected = ""
	if type(defaultIdx) == "string" then
		for _, opt in ipairs(options) do
			if opt == defaultIdx then
				selected = opt
				break
			end
		end
		if selected == "" then
			selected = options[1] or ""
		end
	else
		selected = options[defaultIdx or 1] or options[1] or ""
	end
	local open = false
	local changedEvent = Instance.new("BindableEvent")

	local DROP_H = 32
	local LIST_W = 140

	local function calcWidth(optsText)
		local maxW = 140
		local ts = game:GetService("TextService")
		pcall(function()
			for _, txt in ipairs(optsText) do
				local b = ts:GetTextSize(txt, 13, Enum.Font.GothamMedium, Vector2.new(1000, 30))
				if b.X + 44 > maxW then maxW = b.X + 44 end
			end
			local b2 = ts:GetTextSize(selected, 13, Enum.Font.GothamMedium, Vector2.new(1000, 30))
			if b2.X + 44 > maxW then maxW = b2.X + 44 end
		end)
		return maxW
	end
	LIST_W = calcWidth(options)

	local wrap = frame(parent,{
		name="DropdownWrap", colorKey="bg", trans=1,
		size=UDim2.new(0,LIST_W,0,DROP_H), z=10,
	})

	local header = btn(wrap,{
		name="DHead", text=selected, font=Enum.Font.GothamMedium, size=13,
		colorKey="raised", tcKey="text",
		sz=UDim2.new(1,0,0,DROP_H), z=11,
	})
	header.TextTruncate = Enum.TextTruncate.AtEnd
	rnd(header,5)
	brd(header,"border",1)

	local arrow
	if lucide then
		arrow = img(header,{
			name="Arr", img=getLucide("chevron-down", 16),
			colorKey="sub", sz=UDim2.new(0,16,0,16), pos=UDim2.new(1,-24,0.5,0), anchor=Vector2.new(0,0.5), z=12,
		})
	else
		arrow = lbl(header,{
			text="v", font=Enum.Font.GothamBold, size=12, colorKey="sub",
			sz=UDim2.new(0,20,1,0), pos=UDim2.new(1,-20,0,0), z=12,
			xa=Enum.TextXAlignment.Center,
		})
	end

	local listZ = 150
	local listFrame = inst("ScrollingFrame",{
		Name="DList", BackgroundColor3=K.raised, BorderSizePixel=0,
		Size=UDim2.new(0,LIST_W,0,0), Position=UDim2.new(0,0,0,DROP_H+2),
		ClipsDescendants=true, ZIndex=listZ,
		ScrollBarThickness=4, ScrollBarImageColor3=K.border,
		ScrollingDirection=Enum.ScrollingDirection.Y,
		CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y
	}, wrap)
	registerThemeUpdater(function()
		listFrame.BackgroundColor3 = K.raised
		listFrame.ScrollBarImageColor3 = K.border
	end, listFrame)
	
	local function setScrollPadding(extra)
		local scroll = parent:FindFirstAncestorOfClass("ScrollingFrame")
		if scroll then
			local padObj = scroll:FindFirstChildOfClass("UIPadding")
			if padObj then
				padObj.PaddingBottom = UDim.new(0, 18 + (extra or 0))
			end
		end
	end

	wrap.AncestryChanged:Connect(function(_, newParent)
		if not newParent then
			listFrame:Destroy()
		end
	end)

	rnd(listFrame,5)
	brd(listFrame,"border",1)
	listFrame.Visible = false

	inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Vertical,
		SortOrder=Enum.SortOrder.LayoutOrder,
		Padding=UDim.new(0,0),
	}, listFrame)

	local function closeList()
		open = false
		parent.ZIndex = 7
		setScrollPadding(0)
		tw(arrow,{Rotation=0},0.15):Play()
		local t = tw(listFrame,{Size=UDim2.new(0,LIST_W,0,0)},0.15)
		t.Completed:Connect(function() if not open then listFrame.Visible = false end end)
		t:Play()
	end

	local function populateOptions()
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for i, opt in ipairs(options) do
			local ob = btn(listFrame,{
				name="Opt_"..opt, text=opt, font=Enum.Font.GothamMedium, size=13,
				colorKey="raised", tcKey="sub",
				sz=UDim2.new(1,0,0,30), z=listZ+1,
				xa=Enum.TextXAlignment.Left,
			})
			pad(ob,10,0,0,0)
			ob.LayoutOrder = i
			ob.MouseEnter:Connect(function()
				ob:SetAttribute("Hovered", true)
				tw(ob,{BackgroundColor3=K.border,TextColor3=K.white},0.08):Play()
			end)
			ob.MouseLeave:Connect(function()
				ob:SetAttribute("Hovered", false)
				tw(ob,{BackgroundColor3=K.raised,TextColor3=K.sub},0.08):Play()
			end)
			ob.MouseButton1Click:Connect(function()
				selected = opt
				header.Text = opt
				closeList()
				changedEvent:Fire(selected)
			end)
		end
	end
	
	populateOptions()

	header.MouseButton1Click:Connect(function()
		if not open and onOpenStart then pcall(onOpenStart) end
		open = not open
		if open then
			parent.ZIndex = 110
			listFrame.Visible = true
			local targetH = math.min(210, #options * 30)
			setScrollPadding(targetH)
			tw(listFrame,{Size=UDim2.new(0,LIST_W,0,targetH)},0.18):Play()
			tw(arrow,{Rotation=180},0.15):Play()
		else
			closeList()
		end
	end)

	return {
		frame = wrap,
		getValue = function() return selected end,
		setValue = function(opt)
			if type(opt) == "number" then
				selected = options[opt] or selected
			elseif type(opt) == "string" then
				selected = opt
			end
			header.Text = selected
			changedEvent:Fire(selected)
		end,
		setOptions = function(newOpts)
			options = newOpts
			local found = false
			for _, opt in ipairs(options) do
				if opt == selected then
					found = true
					break
				end
			end
			if not found then
				selected = options[1] or ""
				header.Text = selected
				changedEvent:Fire(selected)
			end
			LIST_W = calcWidth(options)
			wrap.Size = UDim2.new(0, LIST_W, 0, DROP_H)
			populateOptions()
			if open then
				local targetH = math.min(210, #options * 30)
				tw(listFrame,{Size=UDim2.new(0,LIST_W,0,targetH)},0.18):Play()
			end
		end,
		changed = changedEvent.Event,
		close = closeList,
	}
end


local function makeMultiDropdown(parent, options, defaultSelected, onOpenStart)
	local selected = {}
	if type(defaultSelected) == "table" then
		for k, v in pairs(defaultSelected) do
			if type(k) == "number" then
				selected[v] = true
			else
				selected[k] = v
			end
		end
	elseif type(defaultSelected) == "string" then
		selected[defaultSelected] = true
	end

	local open = false
	local changedEvent = Instance.new("BindableEvent")

	local DROP_H = 32
	local LIST_W = 140

	local function getHeaderText()
		local tbl = {}
		for _, opt in ipairs(options) do
			if selected[opt] then
				table.insert(tbl, opt)
			end
		end
		if #tbl == 0 then
			return "None"
		else
			return table.concat(tbl, ", ")
		end
	end

	local function calcWidth(optsText)
		local maxW = 140
		local ts = game:GetService("TextService")
		pcall(function()
			for _, txt in ipairs(optsText) do
				local b = ts:GetTextSize(txt, 13, Enum.Font.GothamMedium, Vector2.new(1000, 30))
				if b.X + 60 > maxW then maxW = b.X + 60 end
			end
			local b2 = ts:GetTextSize(getHeaderText(), 13, Enum.Font.GothamMedium, Vector2.new(1000, 30))
			if b2.X + 60 > maxW then maxW = b2.X + 60 end
		end)
		return maxW
	end
	LIST_W = calcWidth(options)

	local wrap = frame(parent,{
		name="DropdownWrap", colorKey="bg", trans=1,
		size=UDim2.new(0,LIST_W,0,DROP_H), z=10,
	})

	local header = btn(wrap,{
		name="DHead", text=getHeaderText(), font=Enum.Font.GothamMedium, size=13,
		colorKey="raised", tcKey="text",
		sz=UDim2.new(1,0,0,DROP_H), z=11,
	})
	header.TextTruncate = Enum.TextTruncate.AtEnd
	rnd(header,5)
	brd(header,"border",1)

	local arrow
	if lucide then
		arrow = img(header,{
			name="Arr", img=getLucide("chevron-down", 16),
			colorKey="sub", sz=UDim2.new(0,16,0,16), pos=UDim2.new(1,-24,0.5,0), anchor=Vector2.new(0,0.5), z=12,
		})
	else
		arrow = lbl(header,{
			text="v", font=Enum.Font.GothamBold, size=12, colorKey="sub",
			sz=UDim2.new(0,20,1,0), pos=UDim2.new(1,-20,0,0), z=12,
			xa=Enum.TextXAlignment.Center,
		})
	end

	local listZ = 150
	local listFrame = inst("ScrollingFrame",{
		Name="DList", BackgroundColor3=K.raised, BorderSizePixel=0,
		Size=UDim2.new(0,LIST_W,0,0), Position=UDim2.new(0,0,0,DROP_H+2),
		ClipsDescendants=true, ZIndex=listZ,
		ScrollBarThickness=4, ScrollBarImageColor3=K.border,
		ScrollingDirection=Enum.ScrollingDirection.Y,
		CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y
	}, wrap)
	registerThemeUpdater(function()
		listFrame.BackgroundColor3 = K.raised
		listFrame.ScrollBarImageColor3 = K.border
	end, listFrame)
	
	local function setScrollPadding(extra)
		local scroll = parent:FindFirstAncestorOfClass("ScrollingFrame")
		if scroll then
			local padObj = scroll:FindFirstChildOfClass("UIPadding")
			if padObj then
				padObj.PaddingBottom = UDim.new(0, 18 + (extra or 0))
			end
		end
	end

	wrap.AncestryChanged:Connect(function(_, newParent)
		if not newParent then
			listFrame:Destroy()
		end
	end)

	rnd(listFrame,5)
	brd(listFrame,"border",1)
	listFrame.Visible = false

	inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Vertical,
		SortOrder=Enum.SortOrder.LayoutOrder,
		Padding=UDim.new(0,0),
	}, listFrame)

	local function closeList()
		open = false
		parent.ZIndex = 7
		setScrollPadding(0)
		tw(arrow,{Rotation=0},0.15):Play()
		local t = tw(listFrame,{Size=UDim2.new(0,LIST_W,0,0)},0.15)
		t.Completed:Connect(function() if not open then listFrame.Visible = false end end)
		t:Play()
	end

	local function populateOptions()
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		for i, opt in ipairs(options) do
			local isSel = not not selected[opt]
			local ob = btn(listFrame,{
				name="Opt_"..opt, text=opt, font=Enum.Font.GothamMedium, size=13,
				colorKey="raised", tcKey=isSel and "white" or "sub",
				sz=UDim2.new(1,0,0,30), z=listZ+1,
				xa=Enum.TextXAlignment.Left,
			})
			ob:SetAttribute("tcKey", isSel and "white" or "sub")
			pad(ob,10,0,0,0)
			ob.LayoutOrder = i

			local check = lbl(ob, {
				name = "Check", text = "✓", font = Enum.Font.GothamBold, size = 12, colorKey = "white",
				sz = UDim2.new(0, 20, 1, 0), pos = UDim2.new(1, -24, 0, 0), z = listZ + 2,
				xa = Enum.TextXAlignment.Right,
			})
			check.Visible = isSel

			ob.MouseEnter:Connect(function()
				ob:SetAttribute("Hovered", true)
				tw(ob,{BackgroundColor3=K.border},0.08):Play()
			end)
			ob.MouseLeave:Connect(function()
				ob:SetAttribute("Hovered", false)
				tw(ob,{BackgroundColor3=K.raised},0.08):Play()
			end)
			ob.MouseButton1Click:Connect(function()
				selected[opt] = not selected[opt]
				check.Visible = not not selected[opt]
				ob:SetAttribute("tcKey", selected[opt] and "white" or "sub")
				ob.TextColor3 = selected[opt] and K.white or K.sub
				header.Text = getHeaderText()
				changedEvent:Fire(selected)
			end)
		end
	end
	
	populateOptions()

	header.MouseButton1Click:Connect(function()
		if not open and onOpenStart then pcall(onOpenStart) end
		open = not open
		if open then
			parent.ZIndex = 110
			listFrame.Visible = true
			local targetH = math.min(210, #options * 30)
			setScrollPadding(targetH)
			tw(listFrame,{Size=UDim2.new(0,LIST_W,0,targetH)},0.18):Play()
			tw(arrow,{Rotation=180},0.15):Play()
		else
			closeList()
		end
	end)

	return {
		frame = wrap,
		getValue = function() return selected end,
		setValue = function(newSelected)
			selected = {}
			if type(newSelected) == "table" then
				for k, v in pairs(newSelected) do
					if type(k) == "number" then
						selected[v] = true
					else
						selected[k] = v
					end
				end
			elseif type(newSelected) == "string" then
				selected[newSelected] = true
			end
			header.Text = getHeaderText()
			populateOptions()
			changedEvent:Fire(selected)
		end,
		setOptions = function(newOpts)
			options = newOpts
			local newSelected = {}
			local validOpts = {}
			for _, opt in ipairs(options) do
				validOpts[opt] = true
			end
			for opt, val in pairs(selected) do
				if validOpts[opt] then
					newSelected[opt] = val
				end
			end
			selected = newSelected
			header.Text = getHeaderText()
			LIST_W = calcWidth(options)
			wrap.Size = UDim2.new(0, LIST_W, 0, DROP_H)
			populateOptions()
			if open then
				local targetH = math.min(210, #options * 30)
				tw(listFrame,{Size=UDim2.new(0,LIST_W,0,targetH)},0.18):Play()
			end
			changedEvent:Fire(selected)
		end,
		changed = changedEvent.Event,
		close = closeList,
	}
end


local function makeTextBox(parent, placeholder, defaultText)
	local changedEvent = Instance.new("BindableEvent")

	local box = inst("TextBox",{
		Name = "InputBox",
		BackgroundColor3 = K.raised,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = defaultText or "",
		PlaceholderText = placeholder or "Type here...",
		PlaceholderColor3 = K.muted,
		TextColor3 = K.text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(0,160,0,32),
		ZIndex = 10,
	}, parent)
	rnd(box,5)
	brd(box,"border",1)
	pad(box,8,8,0,0)

	box.Focused:Connect(function()
		tw(box,{BackgroundColor3=K.border},0.1):Play()
	end)
	box.FocusLost:Connect(function(enterPressed)
		tw(box,{BackgroundColor3=K.raised},0.1):Play()
		changedEvent:Fire(box.Text, enterPressed)
	end)

	registerThemeUpdater(function()
		box.BackgroundColor3 = K.raised
		box.PlaceholderColor3 = K.muted
		box.TextColor3 = K.text
	end, box)

	return {
		frame = box,
		getText = function() return box.Text end,
		setText = function(t) box.Text = t end,
		changed = changedEvent.Event,
	}
end

local function makeColorPicker(parent, defaultColor, onOpenStart)
	local col = defaultColor or Color3.new(1,1,1)
	local h, s, v = col:ToHSV()
	local changedEvent = Instance.new("BindableEvent")
	local open = false

	local PICKER_H = 34
	local wrap = frame(parent, {
		name="CPWrap", colorKey="bg", trans=1,
		size=UDim2.new(0, 60, 0, PICKER_H), z=10,
	})

	local preview = btn(wrap, {
		name="Preview", text="", color=col,
		sz=UDim2.new(1,0,0,26), pos=UDim2.new(0,0,0.5,0), anchor=Vector2.new(0,0.5), z=11, 
	})
	rnd(preview, 5)
	brd(preview, "border", 1)

	local panel = frame(wrap, {
		name="Panel", colorKey="surface",
		size=UDim2.new(0, 180, 0, 160), pos=UDim2.new(0, -120, 0, PICKER_H + 2), z=150,
	})
	
	local function setScrollPadding(extra)
		local scroll = parent:FindFirstAncestorOfClass("ScrollingFrame")
		if scroll then
			local padObj = scroll:FindFirstChildOfClass("UIPadding")
			if padObj then
				padObj.PaddingBottom = UDim.new(0, 18 + (extra or 0))
			end
		end
	end

	wrap.AncestryChanged:Connect(function(_, newParent)
		if not newParent then
			panel:Destroy()
		end
	end)

	rnd(panel, 5)
	brd(panel, "border", 1)
	panel.Visible = false

	local svMap = inst("TextButton", {
		Name="SVMap", BackgroundColor3=Color3.fromHSV(h,1,1), Text="",
		Size=UDim2.new(1, -16, 0, 100), Position=UDim2.new(0, 8, 0, 8), ZIndex=101, AutoButtonColor=false,
	}, panel)
	rnd(svMap, 4)
	
	local wg = frame(svMap, { name="WhiteGrad", size=UDim2.fromScale(1,1), color=Color3.new(1,1,1), z=102 })
	rnd(wg, 4)
	inst("UIGradient", { Color=ColorSequence.new(Color3.new(1,1,1)), Transparency=NumberSequence.new{ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) } }, wg)
	
	local bg = frame(svMap, { name="BlackGrad", size=UDim2.fromScale(1,1), color=Color3.new(0,0,0), z=103 })
	rnd(bg, 4)
	inst("UIGradient", { Color=ColorSequence.new(Color3.new(0,0,0)), Rotation=90, Transparency=NumberSequence.new{ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) } }, bg)

	local svCursor = frame(bg, {
		size=UDim2.new(0,8,0,8), color=Color3.new(1,1,1), anchor=Vector2.new(0.5,0.5), pos=UDim2.new(s,0,1-v,0), z=105
	})
	rnd(svCursor, 99)
	brd(svCursor, Color3.new(0,0,0), 1)

	local hueTrack = inst("TextButton", {
		Name="HueTrack", BackgroundColor3=Color3.new(1,1,1), Text="",
		Size=UDim2.new(1, -16, 0, 14), Position=UDim2.new(0, 8, 0, 116), ZIndex=101, AutoButtonColor=false,
	}, panel)
	rnd(hueTrack, 4)
	
	local rainbow = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
	}
	inst("UIGradient", {Color=rainbow}, hueTrack)
	
	local hCursor = frame(hueTrack, {
		size=UDim2.new(0,4,1,4), pos=UDim2.new(h,0,0.5,0), anchor=Vector2.new(0.5,0.5), color=Color3.new(1,1,1), z=105
	})
	brd(hCursor, Color3.new(0,0,0), 1)
	
	local function updateColor(silence)
		col = Color3.fromHSV(h, s, v)
		preview.BackgroundColor3 = col
		svMap.BackgroundColor3 = Color3.fromHSV(h,1,1)
		svCursor.Position = UDim2.new(math.clamp(s,0,1), 0, math.clamp(1-v,0,1), 0)
		hCursor.Position = UDim2.new(math.clamp(h,0,1), 0, 0.5, 0)
		if not silence then changedEvent:Fire(col) end
	end
	
	local dragSV, dragH = false, false
	
	local function updateSV(inp)
		local posX = math.clamp(inp.Position.X - svMap.AbsolutePosition.X, 0, svMap.AbsoluteSize.X)
		local posY = math.clamp(inp.Position.Y - svMap.AbsolutePosition.Y, 0, svMap.AbsoluteSize.Y)
		s = posX / svMap.AbsoluteSize.X
		v = 1 - (posY / svMap.AbsoluteSize.Y)
		updateColor()
	end
	
	local function updateH(inp)
		local posX = math.clamp(inp.Position.X - hueTrack.AbsolutePosition.X, 0, hueTrack.AbsoluteSize.X)
		h = posX / hueTrack.AbsoluteSize.X
		updateColor()
	end
	
	svMap.InputBegan:Connect(function(inp) 
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragSV = true; updateSV(inp) end 
	end)
	hueTrack.InputBegan:Connect(function(inp) 
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragH = true; updateH(inp) end 
	end)
	
	UIS.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			if dragSV then updateSV(inp) end
			if dragH then updateH(inp) end
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragSV = false; dragH = false
		end
	end)
	
	local function closeCP()
		open = false
		panel.Visible = false
		parent.ZIndex = 7
		setScrollPadding(0)
	end

	preview.MouseButton1Click:Connect(function()
		if not open and onOpenStart then pcall(onOpenStart) end
		open = not open
		if open then
			parent.ZIndex = 110
			panel.Visible = true
			setScrollPadding(160)
		else
			closeCP()
		end
	end)
	
	local hexBox = inst("TextBox", {
		BackgroundColor3 = K.surface, BorderSizePixel=0, TextColor3=K.text,
		Font = Enum.Font.Code, TextSize=11, Size=UDim2.new(1,-16,0,20),
		Position=UDim2.new(0,8,0,134), ZIndex=101, ClearTextOnFocus=false
	}, panel)
	rnd(hexBox, 4)
	brd(hexBox, "border", 1)
	registerThemeUpdater(function()
		hexBox.BackgroundColor3 = K.surface
		hexBox.TextColor3 = K.text
	end, hexBox)
	
	local function updateHex()
		hexBox.Text = string.format("#%02X%02X%02X", math.floor(col.R*255+0.5), math.floor(col.G*255+0.5), math.floor(col.B*255+0.5))
	end
	changedEvent.Event:Connect(updateHex)
	updateHex()
	updateColor(true)

	return {
		frame = wrap,
		getValue = function() return col end,
		setValue = function(nc)
			col = nc
			h,s,v = col:ToHSV()
			updateColor(false); updateHex()
		end,
		changed = changedEvent.Event,
		close = closeCP
	}
end


local OceanUI = {}
OceanUI.Themes = THEMES

function OceanUI:SetTheme(name)
	setTheme(name)
end

function OceanUI:GetTheme()
	return activeThemeName
end

function OceanUI:CreateWindow(config)
	config = config or {}
	if config.Theme and THEMES[config.Theme] then
		setTheme(config.Theme)
	end
	local allDropdownClosers = {}
	local MOBILE = isMobile()
	local vp = camera.ViewportSize
	local WIN_W, WIN_H
	if MOBILE then
		WIN_W = math.min(vp.X - 20, 680)
		WIN_H = math.min(vp.Y - 40, 420)
	else
		WIN_W  = config.Size and math.clamp(config.Size[1], 200, vp.X - 20) or math.min(vp.X - 20, 680)
		WIN_H  = config.Size and math.clamp(config.Size[2], 200, vp.Y - 40) or math.min(vp.Y - 40, 420)
	end
	local SIDE_W = math.clamp(math.floor(WIN_W * 0.25), 90, 170)
	local TITLE  = config.Title or "Ocean"

	local existing = CoreGui:FindFirstChild("OceanUI")
	if existing then existing:Destroy() end


	local sg = inst("ScreenGui",{
		Name="OceanUI", ResetOnSpawn=false,
		IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
		DisplayOrder=999,
	}, CoreGui)

	local win = frame(sg,{
		name="Win", colorKey="bg",
		size=UDim2.new(0,WIN_W,0,0),
		pos=UDim2.new(0.5,0,0.5,0), anchor=Vector2.new(0.5,0.5),
		z=2,
	})
	brd(win, "border", 1)
	rnd(win, 10)

	local outerGlow = frame(win,{
		name="OuterGlow", colorKey="white", trans=0.93,
		size=UDim2.new(1,10,1,10), pos=UDim2.new(0,-5,0,-5),
		z=1,
	})
	rnd(outerGlow, 14)

	local minWinW, minWinH = WIN_W, WIN_H
	local maxWinW, maxWinH = 900, 700

	local resizeHandle = frame(win,{
		name="ResizeHandle", colorKey="white", trans=1,
		size=UDim2.new(0,26,0,26),
		pos=UDim2.new(1, -5, 1, -5), anchor=Vector2.new(0,0),
		z=20, clip=true,
	})
	local resizeCurve = frame(resizeHandle,{
		name="Curve", colorKey="bg", trans=1,
		size=UDim2.new(0,36,0,36), pos=UDim2.new(0,-18,0,-18), z=20,
	})
	rnd(resizeCurve, 99)
	local resizeStrk = inst("UIStroke", {Color=K.white, Thickness=3, Transparency=0.62}, resizeCurve)
	registerThemeUpdater(function()
		resizeStrk.Color = K.white
	end, resizeStrk)

	local resizeBtn = inst("TextButton",{
		BackgroundTransparency=1, Text="",
		Size=UDim2.new(0,44,0,44),
		Position=UDim2.new(1, 10, 1, 10), AnchorPoint=Vector2.new(0.5,0.5),
		ZIndex=25, AutoButtonColor=false,
	}, win)

	do
		local rDragging   = false
		local rStartInput = Vector2.zero
		local rStartSize  = Vector2.zero

		resizeBtn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
				rDragging   = true
				rStartInput = Vector2.new(inp.Position.X, inp.Position.Y)
				rStartSize  = Vector2.new(win.AbsoluteSize.X, win.AbsoluteSize.Y)
			end
		end)

		UIS.InputChanged:Connect(function(inp)
			if not rDragging then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement
			or inp.UserInputType == Enum.UserInputType.Touch then
				local dx = inp.Position.X - rStartInput.X
				local dy = inp.Position.Y - rStartInput.Y
				local nw = math.clamp(rStartSize.X + dx, minWinW, maxWinW)
				local nh = math.clamp(rStartSize.Y + dy, minWinH, maxWinH)
				win.Size = UDim2.new(0, nw, 0, nh)
			end
		end)

		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1
			or inp.UserInputType == Enum.UserInputType.Touch then
				rDragging = false
			end
		end)

		resizeBtn.MouseEnter:Connect(function()
			tw(resizeStrk, {Transparency=0.2}, 0.1):Play()
		end)
		resizeBtn.MouseLeave:Connect(function()
			tw(resizeStrk, {Transparency=0.62}, 0.1):Play()
		end)
	end

	local loadLayer = frame(win,{name="Load", colorKey="bg", z=30, clip=true})
	rnd(loadLayer, 10)

	local logoWrap = frame(loadLayer,{
		name="LW", colorKey="bg", trans=1,
		size=UDim2.new(0,260,0,80),
		pos=UDim2.new(0.5,0,0.5,-12), anchor=Vector2.new(0.5,0.5), z=31,
	})
	inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,
		HorizontalAlignment=Enum.HorizontalAlignment.Center,
		VerticalAlignment=Enum.VerticalAlignment.Center,
		Padding=UDim.new(0,-5),
	},logoWrap)

	local CHARS = {
		{"}",74,-4,44}, {"<",67,0,38}, {"(",67,-5,34},
		{"(",67,-5,34}, {"°",54,-1,30}, {">",67,0,38},
	}
	local logoGrad = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   K.logoTop),
		ColorSequenceKeypoint.new(0.45,K.logoMid),
		ColorSequenceKeypoint.new(1,   K.logoBot),
	})
	local charDefs={}
	for i,d in ipairs(CHARS) do
		local ch,fs,yo,w=d[1],d[2],d[3],d[4]
		local cf=frame(logoWrap,{name="cf"..i,colorKey="bg",trans=1,size=UDim2.new(0,w,0,80),z=32})
		local cl=lbl(cf,{
			text=ch,font=Enum.Font.Code,size=fs,colorKey="logoTop",trans=1,
			sz=UDim2.new(0,100,0,80),pos=UDim2.new(0.5,0,0.5,yo),anchor=Vector2.new(0.5,0.5),
			xa=Enum.TextXAlignment.Center,ya=Enum.TextYAlignment.Center,z=32,
		})
		local grad = inst("UIGradient",{Rotation=90,Color=logoGrad},cl)
		registerThemeUpdater(function()
			grad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0,   K.logoTop),
				ColorSequenceKeypoint.new(0.45,K.logoMid),
				ColorSequenceKeypoint.new(1,   K.logoBot),
			})
		end, grad)
		charDefs[i]={label=cl,yo=yo}
	end

	local loadSub=lbl(loadLayer,{
		text="OCEAN  DEVELOPMENT",font=Enum.Font.Gotham,
		size=12,colorKey="muted",trans=1,
		sz=UDim2.new(0,260,0,18),pos=UDim2.new(0.5,0,0.5,36),anchor=Vector2.new(0.5,0),
		xa=Enum.TextXAlignment.Center,z=32,
	})

	local shimF=frame(loadLayer,{name="Shim",colorKey="white",trans=1,z=35})
	local shimG=inst("UIGradient",{
		Rotation=45,
		Transparency=NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.42,1),
			NumberSequenceKeypoint.new(0.5,0.82),NumberSequenceKeypoint.new(0.58,1),
			NumberSequenceKeypoint.new(1,1),
		}),
	},shimF)

	local body -- forward declaration so minimize handler can access it

	local titlebar = frame(win,{
		name="Titlebar", colorKey="bg",
		size=UDim2.new(1,0,0,38), z=5,
	})
	rnd(titlebar, 10)
	titlebar.Visible = false

	frame(titlebar,{
		name="Div", colorKey="border",
		size=UDim2.new(1,0,0,1), pos=UDim2.new(0,0,1,-1), z=6,
	})

	local titleLbl = lbl(titlebar,{
		text=TITLE, font=Enum.Font.GothamBold, size=16, colorKey="white",
		sz=UDim2.new(0,200,1,0), pos=UDim2.new(0,16,0,0), z=6,
	})

	local tagContainer = frame(titlebar,{
		name="TagContainer", colorKey="bg", trans=1,
		size=UDim2.new(0,300,1,0),
		pos=UDim2.new(0, SIDE_W + 16, 0, 0), z=6,
	})
	inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,
		SortOrder=Enum.SortOrder.LayoutOrder,
		VerticalAlignment=Enum.VerticalAlignment.Center,
		Padding=UDim.new(0,8),
	},tagContainer)

	local ctrlFrame = frame(titlebar,{
		name="Controls", colorKey="bg", trans=1,
		size=UDim2.new(0,80,0,32),
		pos=UDim2.new(1,-10,0.5,0), anchor=Vector2.new(1,0.5), z=6,
	})
	inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,
		SortOrder=Enum.SortOrder.LayoutOrder,
		HorizontalAlignment=Enum.HorizontalAlignment.Right,
		VerticalAlignment=Enum.VerticalAlignment.Center,
		Padding=UDim.new(0,6),
	},ctrlFrame)

	local function makeCtrlBtn(iconName, name, isClose)
		local b = btn(ctrlFrame, {
			name=name, colorKey="raised", trans=1,
			sz=UDim2.new(0,30,0,30), z=7,
		})
		rnd(b, 6)
		b:SetAttribute("colorKey", "raised")
		b:SetAttribute("tcKey", "text")
		local ic = img(b,{
			name="Icon", img=getLucide(iconName, 18),
			colorKey="sub", sz=UDim2.new(0,19,0,19), pos=UDim2.new(0.5,0,0.5,0), anchor=Vector2.new(0.5,0.5), z=8
		})
		b.MouseEnter:Connect(function() 
			b:SetAttribute("Hovered", true)
			tw(b,{BackgroundTransparency=0, BackgroundColor3=isClose and Color3.fromRGB(220,60,60) or K.border},0.1):Play() 
			tw(ic,{ImageColor3=K.white},0.1):Play()
		end)
		b.MouseLeave:Connect(function() 
			b:SetAttribute("Hovered", false)
			tw(b,{BackgroundTransparency=1, BackgroundColor3=K.raised},0.1):Play() 
			tw(ic,{ImageColor3=K.sub},0.1):Play()
		end)
		return b
	end

	local closeBtn = makeCtrlBtn("x","Close", true)
	local minBtn   = makeCtrlBtn("minus","Minimize", false)
	minBtn.LayoutOrder   = 1
	closeBtn.LayoutOrder = 2

	closeBtn.MouseButton1Click:Connect(function()
		if win:GetAttribute("Closing") then return end
		win:SetAttribute("Closing", true)

		local winScale = Instance.new("UIScale")
		winScale.Scale = 1
		winScale.Parent = win

		local t = tw(winScale, {Scale = 0}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		t:Play()

		pcall(function()
			tw(outerGlow, {BackgroundTransparency = 1}, 0.15):Play()
		end)

		task.delay(0.25, function()
			sg:Destroy()
		end)
	end)

	local minOverlay = frame(sg, {
		name="MinOverlay", colorKey="bg",
		size=UDim2.new(0, 150, 0, 36),
		pos=UDim2.new(0.5, 0, 0.05, 0), anchor=Vector2.new(0.5, 0.5), z=100
	})
	rnd(minOverlay, 18)
	brd(minOverlay, "borderHi", 1)
	minOverlay.Visible = false

	local minGlow = frame(minOverlay,{
		name="OuterGlow", colorKey="white", trans=0.93,
		size=UDim2.new(1,10,1,10), pos=UDim2.new(0,-5,0,-5),
		z=99,
	})
	rnd(minGlow, 22)

	local dragArea = inst("TextButton", {
		Name="DragArea", BackgroundTransparency=1, Text="",
		Size=UDim2.new(0, 40, 1, 0), Position=UDim2.new(0,0,0,0), ZIndex=102, AutoButtonColor=false
	}, minOverlay)
	
	if lucide then
		img(dragArea, {
			img=getLucide("move", 16), colorKey="sub",
			sz=UDim2.new(0,16,0,16), pos=UDim2.new(0.5,0,0.5,0), anchor=Vector2.new(0.5,0.5), z=103
		})
	else
		lbl(dragArea,{text="+",font=Enum.Font.GothamMedium,size=16,colorKey="sub",sz=UDim2.fromScale(1,1),xa=Enum.TextXAlignment.Center,ya=Enum.TextYAlignment.Center,z=103})
	end

	frame(minOverlay,{name="Sep", colorKey="border", size=UDim2.new(0,1,0,20), pos=UDim2.new(0,40,0.5,0), anchor=Vector2.new(0,0.5), z=102})

	local clickArea = inst("TextButton", {
		Name="ClickArea", BackgroundTransparency=1, Text="",
		Size=UDim2.new(1, -41, 1, 0), Position=UDim2.new(0,41,0,0), ZIndex=102, AutoButtonColor=false
	}, minOverlay)

	if lucide then
		img(clickArea, {
			img=getLucide("layout-dashboard", 16), colorKey="white",
			sz=UDim2.new(0,16,0,16), pos=UDim2.new(0,10,0.5,0), anchor=Vector2.new(0,0.5), z=103
		})
	end
	
	lbl(clickArea, {
		text="Open Ocean", font=Enum.Font.GothamMedium, size=12, colorKey="white",
		sz=UDim2.new(1,-32,1,0), pos=UDim2.new(0, (lucide and 34 or 10),0,0), xa=Enum.TextXAlignment.Left, z=103
	})

	local savedMinPos = UDim2.new(0.5, 0, 0.05, 0)
	do
		local d_dragging = false
		local ds, ws
		dragArea.InputBegan:Connect(function(inp)
			if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
				d_dragging=true; ds=inp.Position; ws=minOverlay.Position
			end
		end)
		UIS.InputChanged:Connect(function(inp)
			if d_dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
				local d = inp.Position - ds
				minOverlay.Position = UDim2.new(ws.X.Scale, ws.X.Offset + d.X, ws.Y.Scale, ws.Y.Offset + d.Y)
				savedMinPos = minOverlay.Position
			end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then 
				d_dragging=false 
			end
		end)
	end
	
	minBtn.MouseButton1Click:Connect(function()
		for _, closer in ipairs(allDropdownClosers) do pcall(closer) end
		resizeBtn.Visible = false
		resizeHandle.Visible = false
		win.ClipsDescendants = true
		tw(outerGlow, {BackgroundTransparency=1}, 0.1):Play()
		local curSize = win.Size
		win:SetAttribute("RestoreSizeX", curSize.X.Offset)
		win:SetAttribute("RestoreSizeY", curSize.Y.Offset)
		-- tween to height 0
		tw(win,{Size=UDim2.new(0, curSize.X.Offset, 0, 0), BackgroundTransparency=1}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
		task.delay(0.25, function()
			win.Visible = false
			minOverlay.Position = UDim2.new(savedMinPos.X.Scale, savedMinPos.X.Offset, savedMinPos.Y.Scale, savedMinPos.Y.Offset - 40)
			minOverlay.Visible = true
			tw(minOverlay, {Position = savedMinPos}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			win.ClipsDescendants = false
		end)
	end)

	clickArea.MouseButton1Click:Connect(function()
		tw(minOverlay, {Position = UDim2.new(savedMinPos.X.Scale, savedMinPos.X.Offset, savedMinPos.Y.Scale, savedMinPos.Y.Offset - 40)}, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
		task.delay(0.2, function()
			minOverlay.Visible = false
			win.Visible = true
			resizeBtn.Visible = true
			resizeHandle.Visible = true
			win.ClipsDescendants = true
			local rW = win:GetAttribute("RestoreSizeX") or WIN_W
			local rH = win:GetAttribute("RestoreSizeY") or WIN_H
			if config.Size and not MOBILE then 
				rW = win:GetAttribute("RestoreSizeX") or math.clamp(config.Size[1], 200, vp.X - 20)
				rH = win:GetAttribute("RestoreSizeY") or math.clamp(config.Size[2], 200, vp.Y - 40)
			end
			tw(win,{Size=UDim2.new(0, rW, 0, rH), BackgroundTransparency=0}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			task.delay(0.3, function()
				win.ClipsDescendants = false
				tw(outerGlow, {BackgroundTransparency=0.93}, 0.15):Play()
			end)
		end)
	end)

	-- Drag
	local dragging,ds,ws
	titlebar.InputBegan:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then
			dragging=true; ds=inp.Position; ws=win.Position
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement
			or inp.UserInputType==Enum.UserInputType.Touch) then
			local d=inp.Position-ds
			win.Position=UDim2.new(ws.X.Scale,ws.X.Offset+d.X,ws.Y.Scale,ws.Y.Offset+d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType==Enum.UserInputType.MouseButton1
		or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end)

	local followBar = frame(win,{
		name="FollowBar", colorKey="white", trans=0.6,
		size=UDim2.new(0,50,0,4),
		pos=UDim2.new(0.5,0,1,10), anchor=Vector2.new(0.5,0),
		z=3,
	})
	rnd(followBar, 99)
	followBar.Visible = false

	body = frame(win,{
		name="Body", colorKey="bg", trans=1,
		size=UDim2.new(1,0,1,-38), pos=UDim2.new(0,0,0,38),
		z=4, clip=true,
	})
	rnd(body, 10)
	body.Visible=false

	local sidebar
	local sidebarScroll
	local navBtns = {}
	local tabs = {}
	local activePage = nil
	allDropdownClosers = {}

	local function setNav(page)
		activePage = page
		for _, closer in ipairs(allDropdownClosers) do pcall(closer) end
		for name, nb in pairs(navBtns) do
			local active = (name == page)
			tw(nb.accent,{BackgroundTransparency=active and 0 or 1},0.15):Play()
			nb.lbl.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
			nb.lbl:SetAttribute("tcKey", active and "white" or "sub")
			tw(nb.lbl,{TextColor3=active and K.white or K.sub},0.15):Play()
			if nb.icon then
				nb.icon:SetAttribute("tcKey", active and "white" or "sub")
				tw(nb.icon,{ImageColor3=active and K.white or K.sub},0.15):Play()
			end
			if nb.bg then
				tw(nb.bg,{BackgroundTransparency=active and 0.94 or 1},0.15):Play()
			end
		end
		for name, tab in pairs(tabs) do
			tab.content.Visible = (name == page)
		end
	end

	if true then -- always create sidebar (desktop + mobile)
		sidebar = frame(body,{
			name="Sidebar", colorKey="bg", trans=1,
			size=UDim2.new(0,SIDE_W,1,0), z=5,
		})
		rnd(sidebar, 10)
		frame(win,{
			name="SidebarSep",colorKey="border",
			size=UDim2.new(0,1,1,0),pos=UDim2.new(0,SIDE_W-1,0,0),z=15,
		})
		
		local profileH = 68

		sidebarScroll = inst("ScrollingFrame", {
			Name="SidebarScroll", Size=UDim2.new(1,0,1,-profileH), Position=UDim2.new(0,0,0,0),
			BackgroundTransparency=1, BorderSizePixel=0,
			ScrollBarThickness=0, -- Hidden scrollbar for cleaner UI
			ScrollingDirection=Enum.ScrollingDirection.Y,
			CanvasSize=UDim2.new(0,0,0,0),
			AutomaticCanvasSize=Enum.AutomaticSize.Y,
			ZIndex=6,
		}, sidebar)
		inst("UIListLayout", {
			FillDirection=Enum.FillDirection.Vertical,
			SortOrder=Enum.SortOrder.LayoutOrder,
			Padding=UDim.new(0,4),
		}, sidebarScroll)
		pad(sidebarScroll, 6, 6, 8, 8)

		local profileSection = frame(sidebar,{
			name="Profile", colorKey="bg", trans=1,
			size=UDim2.new(1,-1,0,profileH),
			pos=UDim2.new(0,0,1,0), anchor=Vector2.new(0,1),
			z=6,
		})

		frame(profileSection,{
			name="PSep", colorKey="border",
			size=UDim2.new(1,-16,0,1), pos=UDim2.new(0,8,0,0), z=7,
		})

		local AVA = 46
		local avatarHolder = frame(profileSection,{
			name="Avatar", colorKey="raised",
			size=UDim2.new(0,AVA,0,AVA),
			pos=UDim2.new(0,8,0.5,0), anchor=Vector2.new(0,0.5),
			z=7,
		})
		rnd(avatarHolder,99)
		brd(avatarHolder,"border",1)

		local avatarImg = inst("ImageLabel",{
			BackgroundTransparency=1, Image="",
			Size=UDim2.fromScale(1,1), ZIndex=8,
			ScaleType=Enum.ScaleType.Crop,
		}, avatarHolder)
		rnd(avatarImg,99)

		local txtX = AVA + 16
		lbl(profileSection,{
			text=player.DisplayName,
			font=Enum.Font.GothamBold, size=15, colorKey="text",
			sz=UDim2.new(1,-txtX-4,0,18),
			pos=UDim2.new(0,txtX,0.5,-15), z=7,
		})

		local execLbl = lbl(profileSection,{
			text="",
			font=Enum.Font.GothamMedium, size=13, colorKey="muted",
			sz=UDim2.new(1,-txtX-4,0,15),
			pos=UDim2.new(0,txtX,0.5,5), z=7,
		})

		task.spawn(function()
			local ok, thumb = pcall(function()
				return Players:GetUserThumbnailAsync(
					player.UserId,
					Enum.ThumbnailType.AvatarBust,
					Enum.ThumbnailSize.Size100x100
				)
			end)
			if ok and type(thumb) == "string" then avatarImg.Image = thumb end

			local execName = "Unknown"
			pcall(function()
				if identifyexecutor then
					execName = identifyexecutor()
				elseif getexecutorname then
					execName = getexecutorname()
				end
			end)
			execLbl.Text = execName
		end)
	end

	local contentX = SIDE_W
	local contentArea = frame(body,{
		name="ContentArea", colorKey="surface", trans=1,
		size=UDim2.new(1,-contentX,1,0), pos=UDim2.new(0,contentX,0,0),
		clip=true, z=5,
	})
	rnd(contentArea, 10)

	do
		local BG_H = MOBILE and 70 or 90
		local bgGrad = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   K.logoTop),
			ColorSequenceKeypoint.new(0.45,K.logoMid),
			ColorSequenceKeypoint.new(1,   K.logoBot),
		})
		local BG_CHARS = {
			{"}",  96,   0,  -5, 54},
			{"<",  86,  56,   0, 48},
			{"(",  86, 106,  -1, 42},
			{"(",  86, 150,  -1, 42},
			{"°",  66, 194,  -1, 38},
			{">",  86, 234,   6, 48},
		}
		local bgWrap = frame(contentArea,{
			name="BgLogo", colorKey="bg", trans=1,
			size=UDim2.new(0,320,0,BG_H),
			pos=UDim2.new(0.5,0,0.5,0), anchor=Vector2.new(0.5,0.5), z=1,
		})
		bgWrap.Rotation = -35
		for _,d in ipairs(BG_CHARS) do
			local ch,fs,xo,yo,w = d[1],d[2],d[3],d[4],d[5]
			local cl = inst("TextLabel",{
				BackgroundTransparency=1,
				Font=Enum.Font.Code, Text=ch,
				TextColor3=K.white,
				TextSize=fs, TextTransparency=0.88,
				TextXAlignment=Enum.TextXAlignment.Center,
				TextYAlignment=Enum.TextYAlignment.Center,
				Size=UDim2.new(0,w,0,BG_H),
				Position=UDim2.new(0,xo,0,yo),
				ZIndex=1,
			}, bgWrap)
			local grad = inst("UIGradient",{Rotation=90,Color=bgGrad},cl)
			registerThemeUpdater(function()
				cl.TextColor3 = K.white
				grad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,   K.logoTop),
					ColorSequenceKeypoint.new(0.45,K.logoMid),
					ColorSequenceKeypoint.new(1,   K.logoBot),
				})
			end, cl)
		end

		local bgScale = inst("UIScale",{Scale=1}, bgWrap)
		local _baseContentW = WIN_W - contentX
		contentArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			bgScale.Scale = math.max(1, contentArea.AbsoluteSize.X / _baseContentW)
		end)
	end

	local Window = {}
	local tabCount = 0
	local tagCount = 0

	function Window:CreateTag(text, bgColor, textColor)
		tagCount = tagCount + 1
		local tWrap = frame(tagContainer,{
			name="Tag_"..text, color=bgColor or Color3.fromRGB(60, 120, 210),
			size=UDim2.new(0,0,0,20), z=6,
		})
		tWrap.AutomaticSize = Enum.AutomaticSize.X
		tWrap.LayoutOrder = tagCount
		rnd(tWrap, 4)
		
		local tLbl = lbl(tWrap,{
			text=text, font=Enum.Font.GothamBold, size=11,
			color=textColor, colorKey=not textColor and "white" or nil,
			sz=UDim2.new(0,0,1,0), pos=UDim2.new(0,0,0,-1), z=7,
			xa=Enum.TextXAlignment.Center,
		})
		tLbl.AutomaticSize = Enum.AutomaticSize.X
		
		inst("UIPadding",{
			PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6)
		}, tWrap)
	end

	function Window:AddTab(tabName, iconName)
		tabCount = tabCount + 1
		local tabKey = tabName

		local tabContent = frame(contentArea,{
			name="Tab_"..tabName, colorKey="bg", trans=1,
			size=UDim2.fromScale(1,1), z=5,
		})
		tabContent.Visible = false

		local pageHdr = lbl(tabContent,{
			name="PageHdr", text=tabName,
			font=Enum.Font.GothamBold, size=MOBILE and 18 or 16, colorKey="white",
			sz=UDim2.new(1,-24,0,20), pos=UDim2.new(0,18,0,14), z=6,
		})

		frame(tabContent,{
			name="HDiv",colorKey="border",
			size=UDim2.new(1,-20,0,1),pos=UDim2.new(0,10,0,40),z=6,
		})

		local scroll = inst("ScrollingFrame",{
			Name="Scroll",
			Size=UDim2.new(1,0,1,-46), Position=UDim2.new(0,0,0,46),
			BackgroundTransparency=1, BorderSizePixel=0,
			ScrollBarThickness=2, ScrollBarImageColor3=K.border,
			ScrollingDirection=Enum.ScrollingDirection.Y,
			CanvasSize=UDim2.new(0,0,0,0),
			AutomaticCanvasSize=Enum.AutomaticSize.Y,
			ZIndex=6,
		},tabContent)
		registerThemeUpdater(function()
			scroll.ScrollBarImageColor3 = K.border
		end, scroll)
		pad(scroll,18,18,10,18)

		inst("UIListLayout",{
			FillDirection=Enum.FillDirection.Vertical,
			SortOrder=Enum.SortOrder.LayoutOrder,
			Padding=UDim.new(0,0),
		},scroll)

		if sidebar then
			local nb = frame(sidebarScroll,{
				name="NB_"..tabName, colorKey="white", trans=1,
				size=UDim2.new(1,0,0,36), z=6,
			})
			nb.LayoutOrder = tabCount
			rnd(nb,6)

			local accent=frame(nb,{
				name="Accent",colorKey="white",trans=1,
				size=UDim2.new(0,3,0,16),pos=UDim2.new(0,0,0.5,0),anchor=Vector2.new(0,0.5),z=8,
			})
			rnd(accent,99)

			local nl=lbl(nb,{
				text=tabName,font=Enum.Font.GothamMedium,size=SIDE_W < 140 and 12 or 15,colorKey="sub",
				sz=UDim2.new(1,0,1,0),pos=UDim2.new(0,(iconName and lucide) and (SIDE_W < 140 and 28 or 38) or (SIDE_W < 140 and 8 or 16),0,0),z=7,
			})

			local iconImg
			if iconName and lucide then
				iconImg = img(nb,{
					name="Icon", img=getLucide(iconName, 18),
					colorKey="sub", sz=UDim2.new(0,19,0,19), pos=UDim2.new(0,12,0.5,0), anchor=Vector2.new(0,0.5), z=7,
				})
			end

			local tbb=inst("TextButton",{
				BackgroundTransparency=1,Text="",
				Size=UDim2.fromScale(1,1),ZIndex=9,AutoButtonColor=false,
			},nb)
			tbb.MouseButton1Click:Connect(function() setNav(tabKey) end)

			navBtns[tabKey]={bg=nb,accent=accent,lbl=nl,icon=iconImg}
		end

		tabs[tabKey] = { content=tabContent, scroll=scroll }

		if tabCount == 1 then
			task.defer(function() setNav(tabKey) end)
		end

		local Tab = {}
		local rowCounter = 0

		local function makeRow(title, subtitle, iconName)
			rowCounter = rowCounter + 1
			local rowH = subtitle and 54 or 42
			local r = frame(scroll,{
				name="Row_"..title, colorKey="bg", trans=1,
				size=UDim2.new(1,0,0,rowH), z=7,
			})
			r.LayoutOrder = rowCounter

			local textOffset = (iconName and lucide) and 30 or 0

			if iconName and lucide then
				img(r,{
					name="Icon", img=getLucide(iconName, 20),
					colorKey="text", sz=UDim2.new(0,21,0,21), pos=UDim2.new(0,0,0.5,0), anchor=Vector2.new(0.5,0.5), z=8,
				})
			end

			lbl(r,{
				text=title, font=Enum.Font.GothamMedium, size=14, colorKey="text",
				sz=UDim2.new(0.6,0,0,20),
				pos=UDim2.new(0,textOffset,0, subtitle and 8 or 11), z=8,
			})
			if subtitle then
				lbl(r,{
					text=subtitle, font=Enum.Font.Gotham, size=12, colorKey="muted",
					sz=UDim2.new(0.6,0,0,16), pos=UDim2.new(0,textOffset,0,28), z=8,
				})
			end

			frame(r,{
				name="Div", colorKey="border",
				size=UDim2.new(1,0,0,1),
				pos=UDim2.new(0,0,1,-1), z=8,
			})

			return r
		end

		local function makeSliderRow(title, iconName)
			rowCounter = rowCounter + 1
			local r = frame(scroll,{
				name="SlRow_"..title, colorKey="bg", trans=1,
				size=UDim2.new(1,0,0,60), z=7,
			})
			r.LayoutOrder = rowCounter

			local textOffset = (iconName and lucide) and 30 or 0

			if iconName and lucide then
				img(r,{
					name="Icon", img=getLucide(iconName, 20),
					colorKey="text", sz=UDim2.new(0,21,0,21), pos=UDim2.new(0,0,0,10), z=8,
				})
			end

			lbl(r,{
				text=title, font=Enum.Font.GothamMedium, size=14, colorKey="text",
				sz=UDim2.new(1,0,0,20), pos=UDim2.new(0,textOffset,0,10), z=8,
			})

			frame(r,{
				name="Div", colorKey="border",
				size=UDim2.new(1,0,0,1),
				pos=UDim2.new(0,0,1,-1), z=8,
			})

			return r
		end

		function Tab:AddToggle(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Toggle", opts.Subtitle, opts.Icon)
			local tog = makeToggle(r, opts.Default or false)
			tog.frame.Position   = UDim2.new(1,0,0.5,0)
			tog.frame.AnchorPoint = Vector2.new(1,0.5)
			tog.frame.ZIndex = 9

			if opts.Callback then
				tog.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, state)
					tog.set(state, true)
					if opts.Callback then
						pcall(opts.Callback, state)
					end
				end,
				Get = function()
					return tog.getState()
				end,
				Changed = tog.changed,
				Lock = function() r.BackgroundTransparency = 0; r:FindFirstChildWhichIsA("TextLabel") and nil; pcall(function() for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end end); tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end,
				Unlock = function() pcall(function() for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end end); tw(r,{BackgroundColor3=K.bg},0.1):Play() end,
			}
		end

		function Tab:AddSlider(opts)
			opts = opts or {}
			local r = makeSliderRow(opts.Title or "Slider", opts.Icon)
			local sl = makeSlider(r, opts.Min or 0, opts.Max or 100, opts.Default or 0)
			sl.frame.Position = UDim2.new(0,0,0,30)
			sl.frame.ZIndex   = 8

			local initVal = opts.Default or opts.Min or 0
			local valLbl = lbl(r,{
				text=tostring(math.round(initVal)),
				font=Enum.Font.GothamBold, size=13, colorKey="white",
				sz=UDim2.new(0,55,0,20),
				pos=UDim2.new(1,0,0,8), anchor=Vector2.new(1,0),
				xa=Enum.TextXAlignment.Right, z=9,
			})
			sl.changed:Connect(function(v)
				valLbl.Text = tostring(math.round(v))
			end)

			if opts.Callback then
				sl.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, value)
					sl.setValue(value)
				end,
				Get = function()
					return sl.getValue()
				end,
				Changed = sl.changed,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddButton(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Button", opts.Subtitle, opts.Icon)
			
			local btnText = opts.ButtonText or opts.Text or "Execute"
			local bW = 70
			pcall(function() bW = math.max(70, game:GetService("TextService"):GetTextSize(btnText, 12, Enum.Font.GothamMedium, Vector2.new(1000, 30)).X + 24) end)

			local ab = btn(r,{
				text=btnText, font=Enum.Font.GothamMedium, size=12,
				colorKey="raised", tcKey="white",
				sz=UDim2.new(0,bW,0,28), pos=UDim2.new(1,0,0.5,0), anchor=Vector2.new(1,0.5), z=9,
			})
			rnd(ab,5)
			brd(ab,"border",1)

			ab.MouseEnter:Connect(function() 
				ab:SetAttribute("Hovered", true)
				tw(ab,{BackgroundColor3=K.border},0.1):Play() 
			end)
			ab.MouseLeave:Connect(function() 
				ab:SetAttribute("Hovered", false)
				tw(ab,{BackgroundColor3=K.raised},0.1):Play() 
			end)
			ab.MouseButton1Click:Connect(function()
				if opts.Callback then pcall(opts.Callback) end
				tw(ab,{BackgroundColor3=K.white,TextColor3=K.black},0.08):Play()
				task.delay(0.16,function() 
					tw(ab,{BackgroundColor3=K.raised,TextColor3=K.white},0.12):Play() 
				end)
			end)

			return ab
		end

		function Tab:AddLabel(text, iconName)
			rowCounter = rowCounter + 1
			local r = frame(scroll,{
				name="LblRow", colorKey="bg", trans=1,
				size=UDim2.new(1,0,0,34), z=7,
			})
			r.LayoutOrder = rowCounter

			local textOffset = (iconName and lucide) and 28 or 0

			if iconName and lucide then
				img(r,{
					name="Icon", img=getLucide(iconName, 18),
					colorKey="sub", sz=UDim2.new(0,19,0,19), pos=UDim2.new(0,0,0.5,0), anchor=Vector2.new(0,0.5), z=8,
				})
			end

			local l = lbl(r,{
				text=text or "", font=Enum.Font.Gotham, size=13, colorKey="sub",
				sz=UDim2.new(1,0,1,0), pos=UDim2.new(0,textOffset,0,0), z=8,
			})

			frame(r,{
				name="Div", colorKey="border",
				size=UDim2.new(1,0,0,1),
				pos=UDim2.new(0,0,1,-1), z=8,
			})

			return {
				Set = function(_, newText) l.Text = newText end,
				Get = function() return l.Text end,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddDropdown(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Dropdown", opts.Subtitle, opts.Icon)

			local onOpenStart = function()
				for _, closer in ipairs(allDropdownClosers) do pcall(closer) end
			end

			local optionsList = opts.Options or opts.List or {"Option 1"}
			local dd = makeDropdown(r, optionsList, opts.Default or 1, onOpenStart)
			dd.frame.Position   = UDim2.new(1,0,0.5,0)
			dd.frame.AnchorPoint = Vector2.new(1,0.5)
			dd.frame.ZIndex = 10

			table.insert(allDropdownClosers, dd.close)

			if opts.Callback then
				dd.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, val) dd.setValue(val) end,
				Get = function() return dd.getValue() end,
				SetOptions = function(_, newOpts) dd.setOptions(newOpts) end,
				Refresh = function(_, newOpts) dd.setOptions(newOpts) end,
				Changed = dd.changed,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddMultiDropdown(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Multi Dropdown", opts.Subtitle, opts.Icon)

			local onOpenStart = function()
				for _, closer in ipairs(allDropdownClosers) do pcall(closer) end
			end

			local optionsList = opts.Options or opts.List or {"Option 1"}
			local dd = makeMultiDropdown(r, optionsList, opts.Default or {}, onOpenStart)
			dd.frame.Position   = UDim2.new(1,0,0.5,0)
			dd.frame.AnchorPoint = Vector2.new(1,0.5)
			dd.frame.ZIndex = 10

			table.insert(allDropdownClosers, dd.close)

			if opts.Callback then
				dd.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, val) dd.setValue(val) end,
				Get = function() return dd.getValue() end,
				SetOptions = function(_, newOpts) dd.setOptions(newOpts) end,
				Refresh = function(_, newOpts) dd.setOptions(newOpts) end,
				Changed = dd.changed,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddTextBox(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Input", opts.Subtitle, opts.Icon)

			local tb = makeTextBox(r, opts.Placeholder, opts.Default)
			tb.frame.Position   = UDim2.new(1,0,0.5,0)
			tb.frame.AnchorPoint = Vector2.new(1,0.5)
			tb.frame.ZIndex = 10

			if opts.Callback then
				tb.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, text) tb.setText(text) end,
				Get = function() return tb.getText() end,
				Changed = tb.changed,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddColorPicker(opts)
			opts = opts or {}
			local r = makeRow(opts.Title or "Color Picker", opts.Subtitle, opts.Icon)
			
			local defaultColor = opts.Default or Color3.fromRGB(255,255,255)
			if type(opts.Default) == "string" then
				pcall(function() defaultColor = Color3.fromHex(opts.Default) end)
			end

			local onOpenStart = function()
				for _, closer in ipairs(allDropdownClosers) do pcall(closer) end
			end

			local cp = makeColorPicker(r, defaultColor, onOpenStart)
			cp.frame.Position   = UDim2.new(1,0,0.5,0)
			cp.frame.AnchorPoint = Vector2.new(1,0.5)
			cp.frame.ZIndex = 10

			table.insert(allDropdownClosers, cp.close)

			if opts.Callback then
				cp.changed:Connect(opts.Callback)
			end

			return {
				Set = function(_, color) cp.setValue(color) end,
				Get = function() return cp.getValue() end,
				Changed = cp.changed,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddKeybind(opts)
			opts = opts or {}
			local currentKey = opts.Default or Enum.KeyCode.Unknown
			local r = makeRow(opts.Title or "Keybind", opts.Subtitle, opts.Icon)
			local changedEvent = Instance.new("BindableEvent")

			local keyBtn = btn(r,{
				text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
				font=Enum.Font.GothamMedium, size=13,
				colorKey="raised", tcKey="sub",
				sz=UDim2.new(0,90,0,28),
				pos=UDim2.new(1,0,0.5,0), anchor=Vector2.new(1,0.5), z=10,
			})
			rnd(keyBtn,5)
			brd(keyBtn,"border",1)

			local listening = false
			keyBtn.MouseButton1Click:Connect(function()
				listening = true
				keyBtn.Text = "..."
				keyBtn:SetAttribute("Hovered", true)
				tw(keyBtn,{BackgroundColor3=K.border},0.1):Play()
			end)

			UIS.InputBegan:Connect(function(inp, gpe)
				if not listening then
					if currentKey ~= Enum.KeyCode.Unknown and inp.KeyCode == currentKey and not UIS:GetFocusedTextBox() and opts.Callback then
						pcall(opts.Callback)
					end
					return
				end
				if inp.KeyCode ~= Enum.KeyCode.Unknown then
					if inp.KeyCode == Enum.KeyCode.Escape then
						currentKey = Enum.KeyCode.Unknown
						keyBtn.Text = "None"
					else
						currentKey = inp.KeyCode
						keyBtn.Text = currentKey.Name
					end
					listening = false
					keyBtn:SetAttribute("Hovered", false)
					tw(keyBtn,{BackgroundColor3=K.raised},0.1):Play()
					changedEvent:Fire(currentKey)
				end
			end)

			return {
				Set = function(_, key)
					currentKey = key
					keyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
					changedEvent:Fire(currentKey)
				end,
				Get = function() return currentKey end,
				Changed = changedEvent.Event,
				Lock = function() pcall(function() r.BackgroundTransparency = 0.5; r:FindFirstChildWhichIsA("TextLabel") and nil; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = false end end; tw(r,{BackgroundColor3=Color3.fromRGB(20,20,20)},0.1):Play() end) end,
				Unlock = function() pcall(function() r.BackgroundTransparency = 0; for _, c in ipairs(r:GetDescendants()) do if c:IsA("GuiObject") then c.Interactable = true end end; tw(r,{BackgroundColor3=K.bg},0.1):Play() end) end,
			}
		end

		function Tab:AddSeparator()
			rowCounter = rowCounter + 1
			local r = frame(scroll,{
				name="Sep", colorKey="bg", trans=1,
				size=UDim2.new(1,0,0,12), z=7,
			})
			r.LayoutOrder = rowCounter
		end

		return Tab
	end

	local notifContainer = frame(sg,{
		name="NotifContainer", color=K.bg, trans=1,
		size=UDim2.new(0, 280, 1, 0), pos=UDim2.new(1, -296, 0, 0), z=50,
		clip=false
	})
	
	local notifLayout = inst("UIListLayout",{
		FillDirection=Enum.FillDirection.Vertical,
		HorizontalAlignment=Enum.HorizontalAlignment.Right,
		VerticalAlignment=Enum.VerticalAlignment.Top,
		SortOrder=Enum.SortOrder.LayoutOrder,
		Padding=UDim.new(0, 8),
	}, notifContainer)
	pad(notifContainer, 0, 0, 24, 0)

	local notifCount = 0

	function Window:Notify(opts)
		opts = opts or {}
		local duration = opts.Duration or 3
		local hasTitle = opts.Title and opts.Title ~= ""
		local hasText  = opts.Text  and opts.Text  ~= ""
		local NOTIF_H  = (hasTitle and hasText) and 68 or 46

		if not hasTitle and not hasText then return end

		notifCount = notifCount + 1

		local nf = inst("Frame", {
			Name                   = "NF_" .. notifCount,
			BackgroundTransparency = 1,
			Size                   = UDim2.new(1, 0, 0, 0),
			ClipsDescendants       = false,
			ZIndex                 = 51,
			LayoutOrder            = notifCount,
		}, notifContainer)

		local outerGlow = inst("Frame", {
			Name                   = "OuterGlow",
			BackgroundColor3       = K.white,
			BackgroundTransparency = 1,
			Size                   = UDim2.new(1, 10, 0, NOTIF_H + 10),
			Position               = UDim2.new(0, 23, 0, -5),
			BorderSizePixel        = 0,
			ZIndex                 = 50,
		}, nf)
		rnd(outerGlow, 14)
		registerThemeUpdater(function() outerGlow.BackgroundColor3 = K.white end, outerGlow)

		local card = inst("CanvasGroup", {
			Name                   = "Card",
			BackgroundColor3       = K.bg,
			BackgroundTransparency = 0,
			GroupTransparency      = 1,
			Size                   = UDim2.new(1, 0, 0, NOTIF_H),
			Position               = UDim2.new(0, 28, 0, 0),
			ClipsDescendants       = true,
			ZIndex                 = 52,
		}, nf)
		rnd(card, 10)
		registerThemeUpdater(function() card.BackgroundColor3 = K.bg end, card)

		local stroke = inst("UIStroke", {
			Color               = K.borderHi,
			Thickness           = 1,
			Transparency        = 0.25,
			ApplyStrokeMode     = Enum.ApplyStrokeMode.Border,
		}, card)
		registerThemeUpdater(function() stroke.Color = K.borderHi end, stroke)

		local cardScale = inst("UIScale", {Scale = 0.94}, card)

		local accent = inst("Frame", {
			Name            = "Accent",
			BackgroundColor3 = K.white,
			BorderSizePixel  = 0,
			Size             = UDim2.new(0, 3, 1, 0),
			ZIndex           = 54,
		}, card)
		rnd(accent, 2)
		registerThemeUpdater(function() accent.BackgroundColor3 = K.white end, accent)

		local iconLoaded = opts.Icon and lucide and getLucide(opts.Icon, 18) ~= ""
		local txtX = iconLoaded and 54 or 14

		if iconLoaded then
			local iconBox = inst("Frame", {
				Name             = "IconBox",
				BackgroundColor3 = K.raised,
				BorderSizePixel  = 0,
				Size             = UDim2.new(0, 32, 0, 32),
				Position         = UDim2.new(0, 12, 0.5, 0),
				AnchorPoint      = Vector2.new(0, 0.5),
				ZIndex           = 54,
			}, card)
			rnd(iconBox, 7)
			registerThemeUpdater(function() iconBox.BackgroundColor3 = K.raised end, iconBox)
			img(iconBox, {
				name="Ic", img=getLucide(opts.Icon, 18),
				colorKey="white",
				sz=UDim2.new(0, 16, 0, 16),
				pos=UDim2.new(0.5, 0, 0.5, 0), anchor=Vector2.new(0.5, 0.5), z=55,
			})
		end

		if hasTitle and hasText then
			local tl = inst("TextLabel", {
				BackgroundTransparency = 1,
				Text           = opts.Title,
				TextColor3     = K.text,
				Font           = Enum.Font.GothamBold,
				TextSize       = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextTruncate   = Enum.TextTruncate.AtEnd,
				Size           = UDim2.new(1, -txtX - 34, 0, 18),
				Position       = UDim2.new(0, txtX, 0, 10),
				ZIndex         = 53,
			}, card)
			registerThemeUpdater(function() tl.TextColor3 = K.text end, tl)

			local sl = inst("TextLabel", {
				BackgroundTransparency = 1,
				Text           = opts.Text,
				TextColor3     = K.muted,
				Font           = Enum.Font.GothamMedium,
				TextSize       = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped    = true,
				Size           = UDim2.new(1, -txtX - 34, 0, 28),
				Position       = UDim2.new(0, txtX, 0, 30),
				ZIndex         = 53,
			}, card)
			registerThemeUpdater(function() sl.TextColor3 = K.muted end, sl)
		else
			local single = inst("TextLabel", {
				BackgroundTransparency = 1,
				Text           = hasTitle and opts.Title or opts.Text,
				TextColor3     = K.text,
				Font           = Enum.Font.GothamBold,
				TextSize       = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextWrapped    = true,
				Size           = UDim2.new(1, -txtX - 34, 1, 0),
				Position       = UDim2.new(0, txtX, 0, 0),
				ZIndex         = 53,
			}, card)
			registerThemeUpdater(function() single.TextColor3 = K.text end, single)
		end

		local xBtn = inst("TextButton", {
			Name                   = "X",
			BackgroundTransparency = 1,
			Text                   = "×",
			TextColor3             = K.sub,
			Font                   = Enum.Font.GothamBold,
			TextSize               = 18,
			Size                   = UDim2.new(0, 26, 0, 26),
			Position               = UDim2.new(1, -30, 0, 4),
			AutoButtonColor        = false,
			ZIndex                 = 55,
		}, card)
		registerThemeUpdater(function() xBtn.TextColor3 = K.sub end, xBtn)
		xBtn.MouseEnter:Connect(function() tw(xBtn, {TextColor3=K.text}, 0.08):Play() end)
		xBtn.MouseLeave:Connect(function() tw(xBtn, {TextColor3=K.sub}, 0.08):Play() end)

		tw(nf, {Size=UDim2.new(1, 0, 0, NOTIF_H)}, 0.22, Enum.EasingStyle.Quint):Play()
		tw(card, {GroupTransparency=0, Position=UDim2.new(0, 0, 0, 0)}, 0.24, Enum.EasingStyle.Quint):Play()
		tw(outerGlow, {BackgroundTransparency=0.93, Position=UDim2.new(0, -5, 0, -5)}, 0.24, Enum.EasingStyle.Quint):Play()
		tw(cardScale, {Scale=1}, 0.28, Enum.EasingStyle.Back):Play()

		local dismissed = false
		local function dismiss()
			if dismissed then return end
			dismissed = true
			xBtn.Active = false

			local fadeOut = tw(card, {GroupTransparency=1, Position=UDim2.new(0, 34, 0, 0)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			fadeOut:Play()
			tw(outerGlow, {BackgroundTransparency=1, Position=UDim2.new(0, 29, 0, -5)}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
			tw(cardScale, {Scale=0.92}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()

			fadeOut.Completed:Connect(function()
				card.Visible = false
				outerGlow.Visible = false
				nf.ClipsDescendants = true
				local shrink = tw(nf, {Size=UDim2.new(1, 0, 0, 0)}, 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
				shrink:Play()
				shrink.Completed:Connect(function() nf:Destroy() end)
			end)
		end

		xBtn.MouseButton1Click:Connect(dismiss)
		task.delay(duration, dismiss)
	end

	function Window:Destroy()
		if win:GetAttribute("Closing") then return end
		win:SetAttribute("Closing", true)

		local winScale = Instance.new("UIScale")
		winScale.Scale = 1
		winScale.Parent = win

		local t = tw(winScale, {Scale = 0}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		t:Play()

		pcall(function()
			tw(outerGlow, {BackgroundTransparency = 1}, 0.15):Play()
		end)

		task.delay(0.25, function()
			sg:Destroy()
		end)
	end


	task.spawn(function()
		task.wait(0.05)
		tw(win,{Size=UDim2.new(0,WIN_W,0,WIN_H)},0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out):Play()
		task.wait(0.28)

		local STEP=0.11
		for i,d in ipairs(charDefs) do
			task.delay((i-1)*STEP,function()
				d.label.Position=UDim2.new(0.5,0,0.5,d.yo+10)
				tw(d.label,{TextTransparency=0,Position=UDim2.new(0.5,0,0.5,d.yo)},0.44,Enum.EasingStyle.Quint):Play()
			end)
		end

		task.delay(#CHARS*STEP+0.06,function()
			tw(loadSub,{TextTransparency=0},0.4):Play()
		end)

		local shimAt=#CHARS*STEP+0.44
		task.delay(shimAt,function()
			shimF.BackgroundTransparency=0
			local t0,dur=os.clock(),0.55
			local conn
			conn=RunService.Heartbeat:Connect(function()
				local t=math.min((os.clock()-t0)/dur,1)
				local e=t<.5 and 2*t*t or -1+(4-2*t)*t
				shimG.Offset=Vector2.new(-1+e*2,(-1+e*2)*0.4)
				if t>=1 then conn:Disconnect(); shimF.BackgroundTransparency=1 end
			end)
		end)

		task.delay(shimAt+0.72,function()
			for _,d in ipairs(loadLayer:GetDescendants()) do
				if d:IsA("TextLabel") then tw(d,{TextTransparency=1},0.2):Play()
				elseif d:IsA("Frame") then tw(d,{BackgroundTransparency=1},0.2):Play() end
			end
			tw(loadLayer,{BackgroundTransparency=1},0.22):Play()

			titlebar.Visible=true
			body.Visible=true
			tw(body,{BackgroundTransparency=0},0.28):Play()
			tw(contentArea,{BackgroundTransparency=0},0.28):Play()
			if sidebar then
				tw(sidebar,{BackgroundTransparency=0},0.28):Play()
			end

			task.delay(0.28,function() loadLayer:Destroy() end)
		end)
	end)

	local HttpService = game:GetService("HttpService")
	Window.ConfigManager = {}
	local ConfigManager = Window.ConfigManager
	ConfigManager.Folder = "OceanUI_Configs"
	
	function ConfigManager:SetFolder(name)
		self.Folder = name
		if not isfolder(name) then pcall(makefolder, name) end
	end
	
	function ConfigManager:CreateConfig(configName)
		local Config = { Name = configName, Elements = {} }
		function Config:RegisterElement(id, element)
			self.Elements[id] = element
		end
		function Config:Save()
			local data = {}
			for id, el in pairs(self.Elements) do
				if el and el.Get then
					local v = el:Get()
					if typeof(v) == "EnumItem" then
						data[id] = {type = "KeyCode", value = v.Name}
					elseif typeof(v) == "Color3" then
						data[id] = {type = "Color3", r = v.R, g = v.G, b = v.B}
					else
						data[id] = {type = "Raw", value = v}
					end
				end
			end
			if not isfolder(ConfigManager.Folder) then pcall(makefolder, ConfigManager.Folder) end
			pcall(writefile, ConfigManager.Folder .. "/" .. self.Name .. ".json", HttpService:JSONEncode(data))
		end
		function Config:Load()
			local path = ConfigManager.Folder .. "/" .. self.Name .. ".json"
			if isfile(path) then
				local s, res = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
				if s and res then
					for id, dat in pairs(res) do
						local el = self.Elements[id]
						if el and el.Set then
							if dat.type == "KeyCode" then
								pcall(function() el:Set(Enum.KeyCode[dat.value]) end)
							elseif dat.type == "Color3" then
								pcall(function() el:Set(Color3.new(dat.r, dat.g, dat.b)) end)
							elseif dat.type == "Raw" then
								pcall(function() el:Set(dat.value) end)
							end
						end
					end
				end
			end
		end
		return Config
	end

	function Window:SetTheme(name)
		setTheme(name)
	end

	function Window:GetTheme()
		return activeThemeName
	end

	return Window
end

return OceanUI

