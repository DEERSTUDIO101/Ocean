local Ocean = {}
Ocean.__index = Ocean

-- ─── Services ─────────────────────────────────────────
local TweenService   = game:GetService("TweenService")
local UserInput      = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local CoreGui        = game:GetService("CoreGui")
local gethui         = gethui
local getgenv        = getgenv

local LocalPlayer    = Players.LocalPlayer

-- ─── gethui / CoreGui fallback ────────────────────────
local function getRoot()
    if gethui then return gethui() end
    return CoreGui
end

-- ─── Icons ──────────────────────────────────────────────
Ocean.Icons = {
    -- Fallbacks in case HTTP fails
    ["search"]   = "rbxassetid://7734052925",
    ["settings"] = "rbxassetid://7734053495",
    ["x"]        = "rbxassetid://7743878857",
}

task.spawn(function()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local req = game:HttpGet("https://raw.githubusercontent.com/DEERSTUDIO101/Ocean/refs/heads/main/icons.json")
        local decoded = HttpService:JSONDecode(req)
        if decoded then
            for k, v in pairs(decoded) do
                Ocean.Icons[k] = v
            end
        end
    end)
end)

-- ─── Theme ────────────────────────────────────────────
Ocean.Theme = {
    -- backgrounds
    BG          = Color3.fromRGB(25, 38, 68),     -- deepest bg
    Surface     = Color3.fromRGB(33, 46, 82),    -- card/window
    Surface2    = Color3.fromRGB(43, 58, 98),    -- navbar / dropdowns
    Surface3    = Color3.fromRGB(55, 72, 115),    -- inputs / inactive states

    -- accent
    Accent      = Color3.fromRGB(68, 140, 255),  -- bright ocean blue
    AccentHover = Color3.fromRGB(106, 175, 255),  -- brighter hover
    AccentDark  = Color3.fromRGB(40, 90, 190),   -- pressed

    -- text
    TextPrimary = Color3.fromRGB(250, 250, 255),
    TextSub     = Color3.fromRGB(190, 210, 240),
    TextDim     = Color3.fromRGB(140, 165, 205),

    -- borders / strokes
    Border      = Color3.fromRGB(60, 78, 120),
    BorderHover = Color3.fromRGB(68, 140, 255),

    -- states
    Success     = Color3.fromRGB(34, 197, 94),
    Warning     = Color3.fromRGB(234, 179, 8),
    Danger      = Color3.fromRGB(239, 68, 68),

    -- toggles & sliders
    ToggleOff   = Color3.fromRGB(40, 55, 95),
    ToggleOn    = Color3.fromRGB(58, 130, 246),
    
    -- shadows
    Shadow      = Color3.fromRGB(0, 5, 15),
}

-- ─── Tween helper ─────────────────────────────────────
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local fast   = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local slow   = TweenInfo.new(0.55, Enum.EasingStyle.Exponential,  Enum.EasingDirection.Out)

-- ─── Instance factory ─────────────────────────────────
local function make(cls, props, parent)
    local obj = Instance.new(cls)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

-- ─── UICorner helper ──────────────────────────────────
local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

-- ─── UIStroke helper ──────────────────────────────────
local function stroke(parent, color, thickness, trans)
    return make("UIStroke", {
        Color       = color or Ocean.Theme.Border,
        Thickness   = thickness or 1.2,
        Transparency = trans or 0,
    }, parent)
end

-- ─── Padding helper ───────────────────────────────────
local function padding(parent, all, top, bottom, left, right)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, top    or all or 0),
        PaddingBottom = UDim.new(0, bottom or all or 0),
        PaddingLeft   = UDim.new(0, left   or all or 0),
        PaddingRight  = UDim.new(0, right  or all or 0),
    }, parent)
end

-- ─── Drag utility ─────────────────────────────────────
local function makeDraggable(handle, window)
    local dragging, startMouse, startPos = false, nil, nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startMouse = UserInput:GetMouseLocation()
            local ss   = workspace.CurrentCamera.ViewportSize
            startPos   = Vector2.new(
                window.Position.X.Scale * ss.X + window.Position.X.Offset,
                window.Position.Y.Scale * ss.Y + window.Position.Y.Offset
            )
        end
    end)

    UserInput.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local cur = UserInput:GetMouseLocation()
        local d   = cur - startMouse
        window.Position = UDim2.new(0, startPos.X + d.X, 0, startPos.Y + d.Y)
    end)

    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ─── Expose internals ─────────────────────────────────
Ocean._make       = make
Ocean._corner     = corner
Ocean._stroke     = stroke
Ocean._padding    = padding
Ocean._tween      = tween
Ocean._fast       = fast
Ocean._smooth     = smooth
Ocean._slow       = slow
Ocean._drag       = makeDraggable
Ocean._root       = getRoot
Ocean.Connections = {}
Ocean.Flags       = {}
Ocean.Windows     = {}

-- ─── Connection manager ───────────────────────────────
function Ocean:Connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(self.Connections, c)
    return c
end

function Ocean:Destroy()
    for _, c in ipairs(self.Connections) do
        if c.Connected then c:Disconnect() end
    end
    self.Connections = {}
    for _, w in ipairs(self.Windows) do
        if w and w.Parent then w:Destroy() end
    end
    self.Windows = {}
end

-- ─── Notification system ──────────────────────────────
local notifHolder

local function ensureNotifHolder()
    if notifHolder and notifHolder.Parent then return end
    local root = getRoot()
    -- cleanup old
    local old = root:FindFirstChild("OceanNotifs")
    if old then old:Destroy() end

    local sg = make("ScreenGui", {
        Name            = "OceanNotifs",
        ResetOnSpawn    = false,
        IgnoreGuiInset  = true,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    }, root)

    notifHolder = make("Frame", {
        Name              = "Holder",
        BackgroundTransparency = 1,
        Position          = UDim2.new(1, -20, 1, -20),
        Size              = UDim2.new(0, 300, 1, -40),
        AnchorPoint       = Vector2.new(1, 1),
    }, sg)

    make("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding          = UDim.new(0, 8),
    }, notifHolder)
end

function Ocean:Notify(config)
    config = config or {}
    local title    = config.Title    or "Ocean"
    local desc     = config.Desc     or ""
    local duration = config.Duration or 4
    local ntype    = config.Type     or "Info" -- Info | Success | Warning | Danger

    ensureNotifHolder()

    local T = Ocean.Theme
    local accentMap = {
        Info    = T.Accent,
        Success = T.Success,
        Warning = T.Warning,
        Danger  = T.Danger,
    }
    local accent = accentMap[ntype] or T.Accent

    -- card
    local card = make("Frame", {
        Name               = "Notif",
        BackgroundColor3   = T.Surface,
        Size               = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1,
        ClipsDescendants   = true,
    }, notifHolder)
    corner(card, 10)

    local st = stroke(card, accent, 1.2, 0.3)

    -- left accent bar
    make("Frame", {
        Name             = "Bar",
        BackgroundColor3 = accent,
        Size             = UDim2.new(0, 3, 1, 0),
        BorderSizePixel  = 0,
    }, card)
    corner(card:FindFirstChild("Bar"), 2)

    -- title
    make("TextLabel", {
        Name             = "Title",
        Text             = title,
        TextColor3       = T.TextPrimary,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 14, 0, 10),
        Size             = UDim2.new(1, -24, 0, 18),
        TextXAlignment   = Enum.TextXAlignment.Left,
        RichText         = true,
    }, card)

    -- desc
    make("TextLabel", {
        Name             = "Desc",
        Text             = desc,
        TextColor3       = T.TextSub,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 14, 0, 32),
        Size             = UDim2.new(1, -24, 0, 28),
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        RichText         = true,
    }, card)

    -- progress bar
    local prog = make("Frame", {
        Name             = "Progress",
        BackgroundColor3 = accent,
        Position         = UDim2.new(0, 0, 1, -2),
        Size             = UDim2.new(1, 0, 0, 2),
        BorderSizePixel  = 0,
    }, card)

    -- animate in
    card.BackgroundTransparency = 1
    tween(card, smooth, { BackgroundTransparency = 0 })

    -- progress drain
    tween(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration, function()
        tween(card, smooth, { BackgroundTransparency = 1 })
        task.wait(0.4)
        card:Destroy()
    end)

    return card
end

--  WINDOW

function Ocean:Window(config)
    config = config or {}
    local title    = config.Title    or "Ocean"
    local subtitle = config.Subtitle or ""
    local size     = config.Size     or Vector2.new(410, 400)
    local logo     = config.Logo     or nil

    local T = self.Theme
    local root = self._root()

    local old = root:FindFirstChild("OceanUI")
    if old then old:Destroy() end

    local sg = make("ScreenGui", {
        Name           = "OceanUI",
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, root)

    -- ── Floating Navbar ────────────────────────────────
    local navbarW = math.min(size.X + 60, 500)
    local navbar = make("Frame", {
        Name             = "Navbar",
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(0.5, -navbarW/2, 0, -80),
        Size             = UDim2.new(0, navbarW, 0, 50),
        BorderSizePixel  = 0,
        ZIndex           = 100,
        Visible          = false,
    }, sg)
    corner(navbar, 25)
    stroke(navbar, T.Border, 1)

    local drop = make("Frame", {
        Name             = "ConnectionDrop",
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(0.5, -4, 0, -80), -- Starts offscreen
        Size             = UDim2.fromOffset(8, 8),
        BorderSizePixel  = 0,
        ZIndex           = 99,
        Visible          = false,
    }, sg)
    corner(drop, 8)

    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 99,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
    }, navbar)

    make("TextLabel", {
        Name                   = "Logo",
        Text                   = "~ Ocean",
        TextColor3             = Color3.fromRGB(255, 255, 255),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 18,
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 20, 0, 0),
        Size                   = UDim2.new(0, 90, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
    }, navbar)

    local tabContainer = make("ScrollingFrame", {
        Name                   = "TabContainer",
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 120, 0, 0),
        Size                   = UDim2.new(1, -290, 1, 0),
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.X,
        ScrollBarThickness     = 0,
        ScrollingDirection     = Enum.ScrollingDirection.X,
        BorderSizePixel        = 0,
    }, navbar)

    make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 10),
    }, tabContainer)
    padding(tabContainer, nil, 0, 0, 10, 10)

    -- ── Main window frame (Content Area) ───────────────
    -- Position below navbar, centered horizontally, max 90% width on mobile
    local winW = math.min(size.X, 420)
    local winH = math.min(size.Y, 380)

    local win = make("Frame", {
        Name             = "OceanContent",
        BackgroundColor3 = T.Surface,
        Size             = UDim2.fromOffset(winW, winH),
        Position         = UDim2.new(0.5, 0, 0, 85),
        AnchorPoint      = Vector2.new(0.5, 0),
        BorderSizePixel  = 0,
        Visible          = false,
    }, sg)
    corner(win, 10)
    stroke(win, T.Border, 1)
    
    local winScale = make("UIScale", {
        Scale = 0
    }, win)

    -- Subtle shadow
    local shadow = make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 36, 1, 36),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = T.Shadow,
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
    }, win)

    make("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(55, 72, 115)),
            ColorSequenceKeypoint.new(0.4, T.Surface),
            ColorSequenceKeypoint.new(1,   T.Surface),
        }),
        Rotation = 90,
    }, win)

    local contentArea = make("Frame", {
        Name             = "Content",
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 0, 0, 10),
        Size             = UDim2.new(1, 0, 1, -20),
        ClipsDescendants = true,
    }, win)

    -- ── Fish Background ──
    make("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://123719999719488",
        ImageTransparency = 0.85,
        Size = UDim2.new(1, 0, 1, 0),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 0,
    }, win)



    local exploreBtn = make("TextButton", {
        Name             = "ExploreBtn",
        Text             = "",
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(1, -125, 0.5, -15),
        Size             = UDim2.fromOffset(30, 30),
        AutoButtonColor  = false,
    }, navbar)
    corner(exploreBtn, 8)
    make("ImageLabel", {
        BackgroundTransparency = 1,
        Image = Ocean.Icons["search"],
        ImageColor3 = T.TextDim,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
    }, exploreBtn)

    local settingsBtn = make("TextButton", {
        Name             = "SettingsBtn",
        Text             = "",
        BackgroundColor3 = T.Surface3,
        Position         = UDim2.new(1, -85, 0.5, -15),
        Size             = UDim2.fromOffset(30, 30),
        AutoButtonColor  = false,
    }, navbar)
    corner(settingsBtn, 8)
    make("ImageLabel", {
        BackgroundTransparency = 1,
        Image = Ocean.Icons["settings"],
        ImageColor3 = T.TextDim,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
    }, settingsBtn)

    local closeBtn = make("TextButton", {
        Name             = "CloseBtn",
        Text             = "",
        BackgroundColor3 = T.Surface3,
        Position         = UDim2.new(1, -45, 0.5, -15),
        Size             = UDim2.fromOffset(30, 30),
        AutoButtonColor  = false,
    }, navbar)
    corner(closeBtn, 8)
    make("ImageLabel", {
        BackgroundTransparency = 1,
        Image = Ocean.Icons["x"],
        ImageColor3 = T.TextDim,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
    }, closeBtn)
    
    settingsBtn.MouseEnter:Connect(function() tween(settingsBtn, fast, { BackgroundColor3 = T.Border, TextColor3 = T.TextPrimary }) end)
    settingsBtn.MouseLeave:Connect(function() tween(settingsBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.TextDim }) end)
    
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, fast, { BackgroundColor3 = T.Danger, TextColor3 = T.TextPrimary }) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.TextDim }) end)

    -- Close Question UI
    local closePromptOverlay = make("Frame", {
        Name = "ClosePromptOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 200,
        Visible = false,
        Active = true,
    }, sg)
    
    local closePrompt = make("CanvasGroup", {
        Name = "ClosePrompt",
        BackgroundColor3 = T.Surface2,
        Size = UDim2.fromOffset(260, 130),
        Position = UDim2.new(0.5, -130, 0.5, -45),
        ZIndex = 201,
        GroupTransparency = 1,
    }, closePromptOverlay)
    corner(closePrompt, 12)
    stroke(closePrompt, T.Border, 1)
    
    make("TextLabel", {
        Text = "Exit Ocean?",
        TextColor3 = T.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, closePrompt)
    
    make("TextLabel", {
        Text = "Are you sure you want to close the UI?",
        TextColor3 = T.TextSub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 40),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, closePrompt)
    
    local promptYes = make("TextButton", {
        Text = "Yes",
        TextColor3 = T.TextPrimary,
        BackgroundColor3 = T.Danger,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.fromOffset(90, 32),
        Position = UDim2.new(0.5, -100, 0, 80),
        AutoButtonColor = false,
    }, closePrompt)
    corner(promptYes, 8)
    
    local promptNo = make("TextButton", {
        Text = "No",
        TextColor3 = T.TextPrimary,
        BackgroundColor3 = T.Surface3,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Size = UDim2.fromOffset(90, 32),
        Position = UDim2.new(0.5, 10, 0, 80),
        AutoButtonColor = false,
    }, closePrompt)
    corner(promptNo, 8)
    
    promptYes.MouseEnter:Connect(function() tween(promptYes, fast, { BackgroundColor3 = Color3.fromRGB(200, 50, 50) }) end)
    promptYes.MouseLeave:Connect(function() tween(promptYes, fast, { BackgroundColor3 = T.Danger }) end)
    promptNo.MouseEnter:Connect(function() tween(promptNo, fast, { BackgroundColor3 = T.Border }) end)
    promptNo.MouseLeave:Connect(function() tween(promptNo, fast, { BackgroundColor3 = T.Surface3 }) end)
    
    closeBtn.MouseButton1Click:Connect(function()
        closePromptOverlay.Visible = true
        tween(closePromptOverlay, fast, { BackgroundTransparency = 0.5 })
        tween(closePrompt, fast, { GroupTransparency = 0, Position = UDim2.new(0.5, -130, 0.5, -65) })
    end)
    
    promptNo.MouseButton1Click:Connect(function()
        tween(closePromptOverlay, fast, { BackgroundTransparency = 1 })
        tween(closePrompt, fast, { GroupTransparency = 1, Position = UDim2.new(0.5, -130, 0.5, -45) })
        task.delay(0.2, function() closePromptOverlay.Visible = false end)
    end)
    
    promptYes.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    local isVisible = false
    
    local function toggleWindow(force)
        if force ~= nil then
            isVisible = force
        else
            isVisible = not isVisible
        end
        if isVisible then
            win.Visible = true
            drop.Visible = true
            winScale.Scale = 0
            tween(winScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
            drop.BackgroundTransparency = 1
            tween(drop, smooth, { BackgroundTransparency = 0 })
        else
            tween(winScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 })
            tween(drop, smooth, { BackgroundTransparency = 1 })
            task.delay(0.35, function() win.Visible = false; drop.Visible = false end)
        end
    end

    UserInput.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == Enum.KeyCode.RightShift then
            toggleWindow()
        end
    end)

    local dragHandle = make("Frame", {
        Name = "DragHandle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 100,
    }, win)
    self._drag(dragHandle, mainContainer)
    
    -- Fix for dragging with AnchorPoint 0.5, 0: drag needs absolute position calculations
    -- but since self._drag just modifies Position directly based on Input.Delta, it works identically!

    local W = {
        _gui        = sg,
        _win        = win,
        _navbar     = navbar,
        _tabList    = tabContainer,
        _content    = contentArea,
        _tabs       = {},
        _activeTab  = nil,
        _library    = self,
        _toggle     = toggleWindow,
        _searchItems = {},
    }
    table.insert(self.Windows, sg)

    -- ─── Explore / Floating Search Bar ───────────────────
    local searchContainer = make("Frame", {
        Name             = "SearchContainer",
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(0.5, -navbarW/2, 0, 105),
        Size             = UDim2.new(0, navbarW, 0, 44),
        BorderSizePixel  = 0,
        ZIndex           = 100,
        Visible          = false,
    }, sg)
    corner(searchContainer, 12)
    stroke(searchContainer, T.Border, 1)

    local searchIcon = make("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        Image = Ocean.Icons["search"],
        ImageColor3 = T.TextDim,
    }, searchContainer)

    local searchBox = make("TextBox", {
        Text = "",
        PlaceholderText = "Search...",
        TextColor3 = T.TextPrimary,
        PlaceholderColor3 = T.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -46, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchContainer)

    local searchResults = make("ScrollingFrame", {
        Name             = "SearchResults",
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(0.5, -navbarW/2, 0, 155),
        Size             = UDim2.new(0, navbarW, 0, 200),
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 90,
        Visible          = false,
    }, sg)
    corner(searchResults, 12)
    stroke(searchResults, T.Border, 1)
    make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, searchResults)
    padding(searchResults, 8)

    local function updateSearch()
        local query = searchBox.Text:lower()
        for _, c in ipairs(searchResults:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
        end
        if query == "" then
            searchResults.Visible = false
            return
        end
        
        local matches = {}
        for _, item in ipairs(W._searchItems) do
            local matchName = item.Name:lower():find(query)
            local matchDesc = item.Desc and item.Desc:lower():find(query)
            if matchName or matchDesc then
                table.insert(matches, item)
            end
        end

        if #matches > 0 then
            searchResults.Visible = true
            for _, item in ipairs(matches) do
                local resBtn = make("TextButton", {
                    BackgroundColor3 = T.Surface,
                    Size = UDim2.new(1, 0, 0, item.Desc and item.Desc ~= "" and 46 or 36),
                    Text = "",
                    AutoButtonColor = false,
                }, searchResults)
                corner(resBtn, 6)
                
                local title = item.Name
                if item.Type == "Tab" then title = "Tab: " .. title end
                if item.Type == "Command" then title = "Cmd: " .. title end
                
                make("TextLabel", {
                    Text = title,
                    TextColor3 = T.TextPrimary,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, (item.Desc and item.Desc ~= "") and 6 or 0),
                    Size = UDim2.new(1, -20, 0, (item.Desc and item.Desc ~= "") and 16 or 36),
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, resBtn)
                
                if item.Desc and item.Desc ~= "" then
                    make("TextLabel", {
                        Text = item.Desc,
                        TextColor3 = T.TextSub,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 24),
                        Size = UDim2.new(1, -20, 0, 14),
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }, resBtn)
                end
                
                resBtn.MouseEnter:Connect(function() tween(resBtn, fast, { BackgroundColor3 = T.Surface3 }) end)
                resBtn.MouseLeave:Connect(function() tween(resBtn, fast, { BackgroundColor3 = T.Surface }) end)
                resBtn.MouseButton1Click:Connect(function()
                    tween(exploreBtn, fast, { BackgroundColor3 = T.Surface2 })
                    searchMode = false
                    tween(searchContainer, smooth, { Position = UDim2.new(0.5, -navbarW/2, 0, 95) })
                    searchResults.Visible = false
                    task.delay(0.3, function() if not searchMode then searchContainer.Visible = false end end)
                    
                    if item.Type == "Tab" then
                        if not isVisible then toggleWindow(true) end
                        W:_setTab(item.Tab)
                    elseif item.Type == "Element" then
                        if not isVisible then toggleWindow(true) end
                        W:_setTab(item.Tab)
                    elseif item.Type == "Command" then
                        if item.Callback then task.spawn(item.Callback) end
                    end
                end)
            end
            local h = math.min(#matches * 50 + 8, 220)
            searchResults.Size = UDim2.new(0, navbarW, 0, h)
        else
            searchResults.Visible = false
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)

    local searchMode = false
    exploreBtn.MouseEnter:Connect(function()
        if not searchMode then tween(exploreBtn, fast, { BackgroundColor3 = T.Surface3 }) end
    end)
    exploreBtn.MouseLeave:Connect(function()
        if not searchMode then tween(exploreBtn, fast, { BackgroundColor3 = T.Surface2 }) end
    end)
    
    exploreBtn.MouseButton1Click:Connect(function()
        searchMode = not searchMode
        if searchMode then
            tween(exploreBtn, fast, { BackgroundColor3 = T.Accent })
            if isVisible then
                tween(winScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0 })
                task.delay(0.3, function() if searchMode then win.Visible = false end end)
            end
            
            searchContainer.Visible = true
            searchContainer.Position = UDim2.new(0.5, -navbarW/2, 0, 95)
            tween(searchContainer, smooth, { Position = UDim2.new(0.5, -navbarW/2, 0, 105) })
            searchBox:CaptureFocus()
            updateSearch()
        else
            tween(exploreBtn, fast, { BackgroundColor3 = T.Surface2 })
            tween(searchContainer, smooth, { Position = UDim2.new(0.5, -navbarW/2, 0, 95) })
            searchResults.Visible = false
            task.delay(0.3, function() if not searchMode then searchContainer.Visible = false end end)
            
            if isVisible then
                win.Visible = true
                tween(winScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
            end
        end
    end)

    function W:AddCommand(config)
        table.insert(self._searchItems, {
            Type = "Command",
            Name = config.Name or "Command",
            Desc = config.Desc or "",
            Callback = config.Callback
        })
    end

    function W:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"

        local btn = make("TextButton", {
            Text             = tabName,
            TextColor3       = T.TextSub,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 14,
            BackgroundColor3 = T.Surface2,
            BackgroundTransparency = 0,
            Size             = UDim2.fromOffset(90, 32),
            AutoButtonColor  = false,
        }, self._tabList)
        corner(btn, 16)

        local tab = {
            _btn       = btn,
            _page      = nil,
            _window    = self,
            _library   = self._library,
        }

        btn.MouseEnter:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.TextPrimary })
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, fast, { BackgroundColor3 = T.Surface2, TextColor3 = T.TextSub })
            end
        end)
        btn.MouseButton1Click:Connect(function()
            self:_setTab(tab)
            if not isVisible then
                toggleWindow(true)
            end
        end)

        local page = make("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 0, 0, 0),
            Size             = UDim2.new(1, 0, 1, 0),
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
        }, self._content)

        make("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
        }, page)
        padding(page, nil, 14, 14, 14, 14)

        tab._page = page
        table.insert(self._tabs, tab)
        table.insert(self._searchItems, { Type = "Tab", Name = tabName, Tab = tab })

        if #self._tabs == 1 then
            self:_setTab(tab)
        end

        setmetatable(tab, { __index = self._library })
        return tab
    end

    function W:_setTab(tab)
        for _, t in ipairs(self._tabs) do
            t._page.Visible = false
            if t ~= tab then
                tween(t._btn, fast, { BackgroundColor3 = T.Surface2, TextColor3 = T.TextSub })
            end
        end
        self._activeTab = tab
        tab._page.Visible = true
        tween(tab._btn, fast, { BackgroundColor3 = T.Accent, TextColor3 = Color3.fromRGB(255, 255, 255) })
    end

    -- ─── Ocean Loading Animation ─────────────────────────
    win.Visible = false

    local loadFrame = make("Frame", {
        Name = "LoadingOverlay",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 1000,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
    }, sg)
    
    local stage = make("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -20),
        Size = UDim2.new(0, 460, 0, 180),
        ZIndex = 1001,
    }, loadFrame)

    local logoTxtL = make("TextLabel", {
        Text = "",
        Font = Enum.Font.Code,
        TextSize = 48,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0.5, -40),
        BackgroundTransparency = 1,
        TextTransparency = 1,
        RichText = true
    }, stage)
    
    local subTxt = make("TextLabel", {
        Text = "INITIALIZING OCEAN...",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = T.TextSub,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, 30),
        BackgroundTransparency = 1,
        TextTransparency = 1,
    }, stage)
    
    local grad = make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        }),
        Rotation = 45
    }, logoTxtL)
    
    local progBg = make("Frame", {
        Size = UDim2.new(0, 200, 0, 2),
        Position = UDim2.new(0.5, -100, 0.5, 60),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    }, stage)
    
    local progFill = make("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 255, 255),
        BorderSizePixel = 0,
    }, progBg)
    
    local fish = { "}", "<", "(", "(", "(", "*", ">" }
    local currentText = ""
    
    task.spawn(function()
        tween(subTxt, smooth, { TextTransparency = 0 })
        tween(progBg, smooth, { BackgroundTransparency = 0 })
        
        for i, char in ipairs(fish) do
            currentText = currentText .. char
            logoTxtL.Text = currentText
            tween(logoTxtL, fast, { TextTransparency = 0 })
            task.wait(0.15)
        end
        
        tween(progFill, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0) })
        
        for i = 1, 4 do
            tween(grad, smooth, { Rotation = grad.Rotation + 90 })
            task.wait(0.5)
        end
        
        task.delay(0.5, function()
            tween(loadFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
            for _, child in ipairs(stage:GetDescendants()) do
                if child:IsA("TextLabel") then
                    tween(child, smooth, { TextTransparency = 1 })
                elseif child:IsA("Frame") then
                    tween(child, smooth, { BackgroundTransparency = 1 })
                end
            end
    
            task.delay(0.6, function()
                loadFrame:Destroy()
                
                -- Slide in Navbar
                navbar.Visible = true
                drop.Visible = true
                navbar.Position = UDim2.new(0.5, -navbarW/2, 0, -80)
                drop.Position = UDim2.new(0.5, -4, 0, -80 + 53)
                
                tween(navbar, smooth, { Position = UDim2.new(0.5, -navbarW/2, 0, 20) })
                tween(drop, smooth, { Position = UDim2.new(0.5, -4, 0, 73) })
                
                -- Auto open the window
                toggleWindow(true)
            end)
        end)
    end)

    return W
end

--  ELEMENTS  (Button · Toggle · Slider · Section · Label)

-- ─── Section header ───────────────────────────────────
function Ocean:Section(tab, config)
    config = config or {}
    local text = config.Text or "Section"
    local T = self.Theme

    local row = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        BorderSizePixel = 0,
    }, tab._page)

    make("TextLabel", {
        Text           = string.upper(text),
        TextColor3     = T.TextDim,
        Font           = Enum.Font.GothamBold,
        TextSize       = 10,
        BackgroundTransparency = 1,
        Size           = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    -- divider line
    make("Frame", {
        BackgroundColor3 = T.Border,
        Position = UDim2.new(0, 0, 1, -1),
        Size     = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
    }, row)

    return row
end

-- ─── Label ────────────────────────────────────────────
function Ocean:Label(tab, config)
    config = config or {}
    local text = config.Text or ""
    local T = self.Theme

    local lbl = make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextSub,
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        BackgroundTransparency = 1,
        Size           = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText       = true,
        TextWrapped    = true,
    }, tab._page)

    -- expose Set method
    return {
        Set = function(_, newText)
            lbl.Text = newText
        end
    }
end

-- ─── Button ───────────────────────────────────────────
function Ocean:Button(tab, config)
    config = config or {}
    local text     = config.Text     or "Button"
    local desc     = config.Desc     or nil
    local callback = config.Callback or function() end
    local T = self.Theme

    local h = desc and 52 or 40 -- Increased height slightly for a more premium feel

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, h),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow for Button
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    -- click zone (invisible button over whole card)
    local btn = make("TextButton", {
        Text             = "",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 5,
    }, card)

    -- left accent strip
    local strip = make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(0, 3, 1, 0),
        BorderSizePixel  = 0,
    }, card)
    corner(strip, 3)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 16, 0, desc and 8 or 0),
        Size           = UDim2.new(1, -80, 0, desc and 18 or h),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    if desc then
        make("TextLabel", {
            Text           = desc,
            TextColor3     = T.TextDim,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            BackgroundTransparency = 1,
            Position       = UDim2.new(0, 16, 0, 26),
            Size           = UDim2.new(1, -30, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped    = true,
        }, card)
    end

    -- arrow icon
    local arrow = make("TextLabel", {
        Text           = "›",
        TextColor3     = T.TextDim,
        Font           = Enum.Font.GothamBold,
        TextSize       = 18,
        BackgroundTransparency = 1,
        Position       = UDim2.new(1, -24, 0.5, -10),
        Size           = UDim2.fromOffset(18, 20),
        TextXAlignment = Enum.TextXAlignment.Center,
    }, card)

    -- hover / press
    btn.MouseEnter:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
        tween(strip, fast, { BackgroundColor3 = T.AccentHover })
        tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
        tween(arrow, fast, { Position = UDim2.new(1, -20, 0.5, -10), TextColor3 = T.TextPrimary })
    end)
    btn.MouseLeave:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface2 })
        tween(strip, fast, { BackgroundColor3 = T.Accent })
        tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
        tween(arrow, fast, { Position = UDim2.new(1, -24, 0.5, -10), TextColor3 = T.TextDim })
    end)
    btn.MouseButton1Down:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.AccentDark })
    end)
    btn.MouseButton1Up:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
    end)
    btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("[Ocean:Button] " .. tostring(err)) end
    end)

    return { _card = card }
end

-- ─── Toggle ───────────────────────────────────────────
function Ocean:Toggle(tab, config)
    config = config or {}
    local text     = config.Text     or "Toggle"
    local desc     = config.Desc     or nil
    local default  = config.Default  ~= false  -- default ON
    local flag     = config.Flag     or nil
    local callback = config.Callback or function() end
    local T = self.Theme

    local state = default
    if flag then self.Flags[flag] = state end

    local h = desc and 52 or 40

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, h),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 16, 0, desc and 8 or 0),
        Size           = UDim2.new(1, -80, 0, desc and 18 or h),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    if desc then
        make("TextLabel", {
            Text           = desc,
            TextColor3     = T.TextDim,
            Font           = Enum.Font.Gotham,
            TextSize       = 12,
            BackgroundTransparency = 1,
            Position       = UDim2.new(0, 16, 0, 26),
            Size           = UDim2.new(1, -80, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
    end

    -- toggle track
    local track = make("Frame", {
        BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
        Position         = UDim2.new(1, -50, 0.5, -10),
        Size             = UDim2.fromOffset(38, 20),
        BorderSizePixel  = 0,
    }, card)
    corner(track, 10)
    stroke(track, state and T.Accent or T.Border, 1, 0.3)

    -- toggle knob
    local knob = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position         = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
        Size             = UDim2.fromOffset(14, 14),
        BorderSizePixel  = 0,
    }, track)
    corner(knob, 7)
    
    -- Knob shadow
    make("UIStroke", {
        Color = Color3.new(0,0,0),
        Thickness = 1,
        Transparency = 0.7,
    }, knob)

    -- invisible hit button
    local btn = make("TextButton", {
        Text             = "",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 5,
    }, card)
    
    -- hover / press
    btn.MouseEnter:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
        tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
    end)
    btn.MouseLeave:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface2 })
        tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
    end)
    btn.MouseButton1Down:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.AccentDark })
    end)
    btn.MouseButton1Up:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
    end)

    local function setState(v, fire)
        state = v
        if flag then self.Flags[flag] = state end
        tween(track, fast, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff })
        tween(knob,  fast, { Position = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7) })
        if fire ~= false then
            local ok, err = pcall(callback, state)
            if not ok then warn("[Ocean:Toggle] " .. tostring(err)) end
        end
    end

    btn.MouseButton1Click:Connect(function() setState(not state) end)

    return {
        Set = function(_, v) setState(v, false) end,
        Get = function(_) return state end,
    }
end

-- ─── Slider ───────────────────────────────────────────
function Ocean:Slider(tab, config)
    config = config or {}
    local text     = config.Text     or "Slider"
    local desc     = config.Desc     or nil
    local min      = config.Min      or 0
    local max      = config.Max      or 100
    local default  = config.Default  or min
    local suffix   = config.Suffix   or ""
    local flag     = config.Flag     or nil
    local callback = config.Callback or function() end
    local T = self.Theme

    local value = math.clamp(default, min, max)
    if flag then self.Flags[flag] = value end

    local h = desc and 66 or 52

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, h),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    -- label row
    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, desc and 8 or 6),
        Size           = UDim2.new(1, -80, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    -- value label (right side)
    local valLabel = make("TextLabel", {
        Text           = tostring(value) .. suffix,
        TextColor3     = T.Accent,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
        BackgroundTransparency = 1,
        Position       = UDim2.new(1, -60, desc and 0 or 0, desc and 8 or 6),
        Size           = UDim2.fromOffset(54, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
    }, card)

    if desc then
        make("TextLabel", {
            Text           = desc,
            TextColor3     = T.TextDim,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            BackgroundTransparency = 1,
            Position       = UDim2.new(0, 14, 0, 26),
            Size           = UDim2.new(1, -30, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
    end

    -- track bg
    local trackY = desc and 46 or 32
    local trackBG = make("TextButton", {
        Text             = "",
        AutoButtonColor  = false,
        BackgroundColor3 = T.Surface3,
        Position         = UDim2.new(0, 14, 0, trackY),
        Size             = UDim2.new(1, -28, 0, 5),
        BorderSizePixel  = 0,
    }, card)
    corner(trackBG, 3)

    -- fill
    local pct = (value - min) / (max - min)
    local fill = make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(pct, 0, 1, 0),
        BorderSizePixel  = 0,
    }, trackBG)
    corner(fill, 3)

    -- knob
    local knob = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(pct, 0, 0.5, 0),
        Size             = UDim2.fromOffset(14, 14),
        BorderSizePixel  = 0,
        ZIndex           = 3,
    }, trackBG)
    corner(knob, 7)

    local function updateValue(newVal, fire)
        value = math.clamp(math.round(newVal), min, max)
        if flag then self.Flags[flag] = value end
        local p = (value - min) / (max - min)
        tween(fill,  fast, { Size     = UDim2.new(p, 0, 1, 0) })
        tween(knob,  fast, { Position = UDim2.new(p, 0, 0.5, 0) })
        valLabel.Text = tostring(value) .. suffix
        if fire ~= false then
            local ok, err = pcall(callback, value)
            if not ok then warn("[Ocean:Slider] " .. tostring(err)) end
        end
    end

    -- drag logic
    local dragging = false
    trackBG.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInput.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos = trackBG.AbsolutePosition.X
            local absSize = trackBG.AbsoluteSize.X
            local mouseX = UserInput:GetMouseLocation().X
            local t2 = math.clamp((mouseX - absPos) / absSize, 0, 1)
            updateValue(min + t2 * (max - min))
        end
    end)
    trackBG.MouseButton1Click:Connect(function()
        local absPos = trackBG.AbsolutePosition.X
        local absSize = trackBG.AbsoluteSize.X
        local mouseX = UserInput:GetMouseLocation().X
        local t2 = math.clamp((mouseX - absPos) / absSize, 0, 1)
        updateValue(min + t2 * (max - min))
    end)

    -- hover
    card.MouseEnter:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
        tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
    end)
    card.MouseLeave:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface2 })
        tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
    end)

    return {
        Set = function(_, v) updateValue(v, false) end,
        Get = function(_) return value end,
    }
end

-- ─── Dropdown ─────────────────────────────────────────
function Ocean:Dropdown(tab, config)
    config = config or {}
    local text     = config.Text     or "Dropdown"
    local options  = config.Options  or {}
    local default  = config.Default  or options[1]
    local flag     = config.Flag     or nil
    local callback = config.Callback or function() end
    local T = self.Theme

    local selected = default
    if flag then self.Flags[flag] = selected end

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, 40),
        BorderSizePixel  = 0,
        ZIndex           = 10,
        ClipsDescendants = false,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, 0),
        Size           = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 11,
    }, card)

    local valLabel = make("TextLabel", {
        Text           = tostring(selected or "Select..."),
        TextColor3     = T.Accent,
        Font           = Enum.Font.Gotham,
        TextSize       = 12,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0.5, 0, 0, 0),
        Size           = UDim2.new(0.5, -28, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 11,
    }, card)

    local chevron = make("TextLabel", {
        Text           = "▾",
        TextColor3     = T.TextDim,
        Font           = Enum.Font.GothamBold,
        TextSize       = 12,
        BackgroundTransparency = 1,
        Position       = UDim2.new(1, -22, 0, 0),
        Size           = UDim2.fromOffset(16, 36),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex         = 11,
    }, card)

    local btn = make("TextButton", {
        Text             = "",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 15,
    }, card)

    local listFrame = make("Frame", {
        BackgroundColor3 = T.Surface,
        Position         = UDim2.new(0, 0, 1, 4),
        Size             = UDim2.new(1, 0, 0, 0),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 20,
        Visible          = false,
    }, card)
    corner(listFrame, 8)
    stroke(listFrame, T.Border, 1)
    make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, listFrame)
    padding(listFrame, 4)

    local isOpen = false
    local ITEM_H = 30

    local function buildList()
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local item = make("TextButton", {
                Text             = tostring(opt),
                TextColor3       = opt == selected and T.Accent or T.TextSub,
                Font             = opt == selected and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextSize         = 12,
                BackgroundColor3 = opt == selected and T.Surface3 or T.Surface,
                Size             = UDim2.new(1, 0, 0, ITEM_H),
                BorderSizePixel  = 0,
                AutoButtonColor  = false,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 22,
            }, listFrame)
            corner(item, 6)
            padding(item, nil, 0, 0, 10, 6)
            item.MouseEnter:Connect(function() tween(item, fast, { BackgroundColor3 = T.Surface3 }) end)
            item.MouseLeave:Connect(function()
                if opt ~= selected then tween(item, fast, { BackgroundColor3 = T.Surface }) end
            end)
            item.MouseButton1Click:Connect(function()
                selected = opt
                if flag then self.Flags[flag] = selected end
                valLabel.Text = tostring(selected)
                buildList()
                isOpen = false
                tween(listFrame, fast, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.18, function() listFrame.Visible = false end)
                tween(chevron, fast, { Rotation = 0 })
                tween(card, fast, { BackgroundColor3 = T.Surface2 })
                local ok, err = pcall(callback, selected)
                if not ok then warn("[Ocean:Dropdown] " .. tostring(err)) end
            end)
        end
    end
    buildList()

    btn.MouseEnter:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface3 }) 
        tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
    end)
    btn.MouseLeave:Connect(function() 
        if not isOpen then 
            tween(card, fast, { BackgroundColor3 = T.Surface2 }) 
            tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
        end 
    end)
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            listFrame.Visible = true
            tween(listFrame, fast, { Size = UDim2.new(1, 0, 0, #options * (ITEM_H + 2) + 8) })
            tween(chevron, fast, { Rotation = 180 })
        else
            tween(listFrame, fast, { Size = UDim2.new(1, 0, 0, 0) })
            tween(chevron, fast, { Rotation = 0 })
            task.delay(0.18, function() listFrame.Visible = false end)
            tween(card, fast, { BackgroundColor3 = T.Surface2 })
        end
    end)

    return {
        Set = function(_, v)
            selected = v; if flag then self.Flags[flag] = v end
            valLabel.Text = tostring(v); buildList()
        end,
        Get = function(_) return selected end,
        SetOptions = function(_, o)
            options = o; selected = o[1]
            valLabel.Text = tostring(selected or ""); buildList()
        end,
    }
end

-- ─── TextInput ────────────────────────────────────────
function Ocean:TextInput(tab, config)
    config = config or {}
    local text        = config.Text        or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local default     = config.Default     or ""
    local flag        = config.Flag        or nil
    local callback    = config.Callback    or function() end
    local T = self.Theme

    if flag then self.Flags[flag] = default end

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, 52),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, 6),
        Size           = UDim2.new(1, -20, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    local inputBG = make("Frame", {
        BackgroundColor3 = T.BG,
        Position         = UDim2.new(0, 10, 0, 26),
        Size             = UDim2.new(1, -20, 0, 20),
        BorderSizePixel  = 0,
    }, card)
    corner(inputBG, 5)
    local inputStroke = stroke(inputBG, T.Border, 1)

    local inputBox = make("TextBox", {
        Text                   = default,
        PlaceholderText        = placeholder,
        PlaceholderColor3      = T.TextDim,
        TextColor3             = T.TextPrimary,
        Font                   = Enum.Font.Gotham,
        TextSize               = 12,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ClearTextOnFocus       = false,
        TextXAlignment         = Enum.TextXAlignment.Left,
    }, inputBG)
    padding(inputBox, nil, 0, 0, 8, 8)

    inputBox.Focused:Connect(function()
        tween(inputBG, fast, { BackgroundColor3 = T.Surface3 })
        tween(inputStroke, fast, { Color = T.Accent })
        tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
    end)
    inputBox.FocusLost:Connect(function(enter)
        tween(inputBG, fast, { BackgroundColor3 = T.BG })
        tween(inputStroke, fast, { Color = T.Border })
        tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
        if flag then self.Flags[flag] = inputBox.Text end
        if enter then
            local ok, err = pcall(callback, inputBox.Text)
            if not ok then warn("[Ocean:TextInput] " .. tostring(err)) end
        end
    end)
    
    -- Card hover
    card.MouseEnter:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface3 }) 
        if not inputBox:IsFocused() then
            tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
        end
    end)
    card.MouseLeave:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface2 }) 
        if not inputBox:IsFocused() then
            tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
        end
    end)

    return {
        Get = function(_) return inputBox.Text end,
        Set = function(_, v) inputBox.Text = v end,
    }
end

-- ─── Keybind ──────────────────────────────────────────
function Ocean:Keybind(tab, config)
    config = config or {}
    local text     = config.Text     or "Keybind"
    local default  = config.Default  or Enum.KeyCode.RightShift
    local flag     = config.Flag     or nil
    local callback = config.Callback or function() end
    local T = self.Theme

    local currentKey = default
    local listening  = false
    if flag then self.Flags[flag] = currentKey end

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, 40),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    local cardStroke = stroke(card, T.Border, 1)

    -- Drop Shadow
    make("ImageLabel", {
        Name = "DropShadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -10, 0, -10),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = -1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, card)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamMedium,
        TextSize       = 14,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, 0),
        Size           = UDim2.new(0.6, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    local keyBtn = make("TextButton", {
        Text             = "[" .. tostring(currentKey.Name) .. "]",
        TextColor3       = T.Accent,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        BackgroundColor3 = T.Surface3,
        Size             = UDim2.fromOffset(90, 24),
        Position         = UDim2.new(1, -100, 0.5, -12),
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, card)
    corner(keyBtn, 6)

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        tween(keyBtn, fast, { BackgroundColor3 = T.AccentDark, TextColor3 = T.TextPrimary })
    end)

    UserInput.InputBegan:Connect(function(inp)
        if not listening then
            if inp.KeyCode == currentKey then
                local ok, err = pcall(callback, currentKey)
                if not ok then warn("[Ocean:Keybind] " .. tostring(err)) end
            end
            return
        end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if inp.KeyCode == Enum.KeyCode.Escape then
            listening = false
            keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
            tween(keyBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.Accent })
            return
        end
        currentKey = inp.KeyCode
        if flag then self.Flags[flag] = currentKey end
        listening = false
        keyBtn.Text = "[" .. tostring(currentKey.Name) .. "]"
        tween(keyBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.Accent })
    end)

    card.MouseEnter:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface3 })
        if not listening then
            tween(cardStroke, fast, { Color = T.BorderHover, Transparency = 0.5 })
        end
    end)
    card.MouseLeave:Connect(function() 
        tween(card, fast, { BackgroundColor3 = T.Surface2 })
        if not listening then
            tween(cardStroke, fast, { Color = T.Border, Transparency = 0 })
        end
    end)

    return {
        Get = function(_) return currentKey end,
        Set = function(_, k)
            currentKey = k
            if flag then self.Flags[flag] = k end
            keyBtn.Text = "[" .. tostring(k.Name) .. "]"
        end,
    }
end

-- ─── Built-In Commands Section ──────────────────────────
-- These are some standalone versions of the scripts requested
function Ocean:InitBuiltInCommands(W)
    W:AddCommand({
        Name = "Dex++",
        Desc = "Advanced Explorer",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexPlusBackup.luau"))()
            Ocean:Notify({ Title = "Command", Desc = "Dex++ Loaded!", Type = "Success" })
        end
    })

    local AF_Tracked = {}
    local AF_Conn = nil
    W:AddCommand({
        Name = "Anti Fling",
        Desc = "Makes other players non-collidable",
        Callback = function()
            local lp = game:GetService("Players").LocalPlayer
            if not lp then return end
            
            local function disableCollide(part)
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    AF_Tracked[part] = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
                        if part.CanCollide then part.CanCollide = false end
                    end)
                end
            end
            
            local function onChar(char)
                for _, p in ipairs(char:GetDescendants()) do disableCollide(p) end
                char.DescendantAdded:Connect(disableCollide)
            end
            
            local function onPlayer(plr)
                if plr == lp then return end
                if plr.Character then onChar(plr.Character) end
                plr.CharacterAdded:Connect(onChar)
            end
            
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do onPlayer(plr) end
            AF_Conn = game:GetService("Players").PlayerAdded:Connect(onPlayer)
            Ocean:Notify({ Title = "Command Executed", Desc = "Anti Fling enabled.", Type = "Success" })
        end
    })

    W:AddCommand({
        Name = "Un-Anti Fling",
        Desc = "Restores collision for other players",
        Callback = function()
            if AF_Conn then AF_Conn:Disconnect() end
            for part, conn in pairs(AF_Tracked) do
                conn:Disconnect()
                if part and part.Parent then part.CanCollide = true end
            end
            table.clear(AF_Tracked)
            Ocean:Notify({ Title = "Command Executed", Desc = "Anti Fling disabled.", Type = "Info" })
        end
    })

    W:AddCommand({
        Name = "Vehiclefly (vfly)",
        Desc = "Fly vehicles",
        Callback = function()
            -- Placeholder logic or basic loadstring. 
            -- A full vehicle fly requires heavy client physics, this is a placeholder stub matching Nameless.
            Ocean:Notify({ Title = "Vehicle Fly", Desc = "Vehicle fly enabled. (Stub)", Type = "Info" })
        end
    })

    W:AddCommand({
        Name = "Unvfly",
        Desc = "Disable vehicle fly",
        Callback = function()
            Ocean:Notify({ Title = "Vehicle Fly", Desc = "Vehicle fly disabled. (Stub)", Type = "Info" })
        end
    })
end

_G.Ocean = Ocean

function Ocean:InitNamelessAdminCommands(W)
    local namelessLoaded = false
    local naEnv = nil

    local function ensureNameless()
        if not namelessLoaded then
            Ocean:Notify({ Title = "Nameless Admin", Desc = "Loading Nameless Admin...", Type = "Info" })
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
            namelessLoaded = true
            naEnv = (getgenv and getgenv()) or _G or {}
            task.wait(1.5)
        end
    end

    -- Fuehrt einen NA-Command direkt ueber den internen Dispatcher aus.
    -- Fallback: Prefix-Chat-Methode falls NARunCommand nicht vorhanden.
    local function runNACommand(cmdName)
        ensureNameless()
        local env = naEnv or (getgenv and getgenv()) or _G or {}

        local runner = rawget(env, "NARunCommand")
            or rawget(env, "NAExecCommand")
            or rawget(env, "NAEXEC")
        if type(runner) == "function" then
            pcall(runner, cmdName)
            return
        end

        -- Fallback via Chat-Prefix
        local prefix = ";"
        local msg = prefix .. cmdName
        pcall(function()
            local TCS = game:GetService("TextChatService")
            if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
                local ch = TCS.ChatInputBarConfiguration.TargetTextChannel
                if ch then ch:SendAsync(msg) end
            else
                game:GetService("ReplicatedStorage")
                    .DefaultChatSystemChatEvents
                    .SayMessageRequest:FireServer(msg, "All")
            end
        end)
    end

    local commands = {
{ Name = "shaders", Desc = "shaders (shader, rtx, hd), Enable a shader preset for Lighting" },
    { Name = "unshaders", Desc = "unshaders (shadersoff, rtxoff), Disable the shader preset and restore Lighting" },
    { Name = "i", Desc = "ibtools, Load the iBuild Tools helper tool" },
    { Name = "u", Desc = "unibtools, Remove the iBuild Tools helper tool" },
    { Name = "setfflag", Desc = "setfflag [save] (setff), Set a fast flag (use save to store it)" },
    { Name = "a", Desc = "addalias , Adds a persistent alias for an existing command" },
    { Name = "r", Desc = "removealias, Select and remove a saved alias" },
    { Name = "c", Desc = "clearaliases, Removes all aliases created using addalias." },
    { Name = "addbutton", Desc = "addbutton [] (ab), Add a mobile button" },
    { Name = "removebutton", Desc = "removebutton (rb), Remove a user button" },
    { Name = "clearbuttons", Desc = "clearbuttons (clearbtns, cb), Clear all user buttons" },
    { Name = "addautoexec", Desc = "addautoexec [arguments] (aaexec, addae, addauto, aexecadd), Add a command to autoexecute" },
    { Name = "removeautoexec", Desc = "removeautoexec (raexec, removeae, removeauto, aexecremove), Remove a command from autoexecute" },
    { Name = "clearautoexec", Desc = "clearautoexec (caexec, clearauto, autoexecclear, aexecclear, aeclear), Clear all AutoExec commands" },
    { Name = "executor", Desc = "executor (exec),Open the integrated executor UI" },
    { Name = "lastcommand", Desc = "lastcommand (lastcmd),Re-run your previously executed command" },
    { Name = "commandloop", Desc = "commandloop {arguments" },
    { Name = "stoploop", Desc = "stoploop, Stop a running loop" },
    { Name = "scripthub", Desc = "scripthub (hub),Thanks to scriptblox/rscripts API" },
    { Name = "uiscale", Desc = "uiscale (uscale), Adjust the scale of the ..adminName.. UI" },
    { Name = "p", Desc = "prefix , Changes the admin prefix" },
    { Name = "s", Desc = "saveprefix , Saves the prefix to a file and applies it" },
    { Name = "chatlogs", Desc = "chatlogs (clogs),Open the chat logs" },
    { Name = "gotocampos", Desc = "gotocampos (tocampos,tcp),Teleports you to your camera position works with free cam but freezes you" },
    { Name = "teleportgui", Desc = "teleportgui,Gives an UI that grabs all places and teleports you by clicking a simple button" },
    { Name = "imagescanner", Desc = "imagescanner,Gives an UI that grabs all images on the game" },
    { Name = "serverremotespy", Desc = "serverremotespy (srs,sremotespy),Gives an UI that logs all the remotes being called from the server (thanks SolSpy lol)" },
    { Name = "discord", Desc = "discord, Copy an invite link" },
    { Name = "clickfling", Desc = "clickfling (mousefling),Fling a player by clicking them" },
    { Name = "unclickfling", Desc = "unclickfling (unmousefling),disables clickfling" },
    { Name = "offset", Desc = "offset [x y z|y],Offsets your character for others (positive Y = up, negative Y = down)" },
    { Name = "upsidedown", Desc = "upsidedown,Flips your character upside down for others using the offset replication method" },
    { Name = "unoffset", Desc = "unoffset,Disables offset and restores your character" },
    { Name = "unupsidedown", Desc = "unupsidedown,Disables the upside down replication and restores your character" },
    { Name = "clickscare", Desc = "clickscare (clickspook),Teleports next to a clicked player for a few seconds" },
    { Name = "unclickscare", Desc = "unclickscare (unclickspook),Disables clickscare" },
    { Name = "hovername", Desc = "hovername, Shows players username on hover" },
    { Name = "unhovername", Desc = "unhovername, Disables hovername" },
    { Name = "resetfilter", Desc = "resetfilter,If Pedoblox keeps tagging your messages, run this to reset the filter" },
    { Name = "p", Desc = "ping, Shows your network latency" },
    { Name = "f", Desc = "fps, Shows your frames per second" },
    { Name = "s", Desc = "stats, Shows both FPS and ping" },
    { Name = "commands", Desc = "commands,Open the command list" },
    { Name = "s", Desc = "settings,Open the settings menu" },
    { Name = "commandkeybinds", Desc = "commandkeybinds (cmdkeybinds, ckeybinds), Open the command keybinds window" },
    { Name = "waypoints", Desc = "waypoints,Open the waypoints menu" },
    { Name = "binders", Desc = "binders,Open the event binder menu" },
    { Name = "setwaypoint", Desc = "setwaypoint , Store your current position under that name" },
    { Name = "gotowaypoint", Desc = "gotowaypoint , Teleport to a saved waypoint" },
    { Name = "removewaypoint", Desc = "removewaypoint , Remove a saved waypoint" },
    { Name = "chardebug", Desc = "chardebug (cdebug),debug your character" },
    { Name = "unchardebug", Desc = "unchardebug (uncdebug),disable character debug" },
    { Name = "n", Desc = "naked, no clothing gang" },
    { Name = "somersault", Desc = "somersault (frontflip), Makes you do a clean front flip" },
    { Name = "unsomersault", Desc = "unsomersault (unfrontflip), Disable somersault button and keybind" },
    { Name = "r", Desc = "rolewatch , Notify if someone from a watched group joins with a specific role" },
    { Name = "r", Desc = "rolewatchstop, Disable Rolewatch monitoring" },
    { Name = "rolewatchleave", Desc = "rolewatchleave (unrolewatch), Toggle leaving the server if the watched role joins" },
    { Name = "joingroup", Desc = "joingroup [groupId] (groupjoin), Open the Pedoblox join prompt for a group" },
    { Name = "t", Desc = "trackstaff, Track and notify when a staff member joins the server" },
    { Name = "stoptrackstaff", Desc = "stoptrackstaff (untrackstaff), Stop tracking staff members" },
    { Name = "deletevelocity", Desc = "deletevelocity (dv, removevelocity, removeforces), removes any velocity/force instanceson your character" },
    { Name = "sensorrotationscreen", Desc = "sensorrotationscreen,Changes ScreenOrientation to Sensor" },
    { Name = "landscaperotationscreen", Desc = "landscaperotationscreen,Changes ScreenOrientation to Landscape Sensor" },
    { Name = "portraitrotationscreen", Desc = "portraitrotationscreen,Changes ScreenOrientation to Portrait" },
    { Name = "defaultrotaionscreen", Desc = "defaultrotaionscreen,Changes ScreenOrientation to Portrait" },
    { Name = "commandcount", Desc = "commandcount (cc),Counts how many commands NA has" },
    { Name = "flyfling", Desc = "flyfling (ff), makes you fly and fling" },
    { Name = "unflyfling", Desc = "unflyfling (unff), stops fly and fling" },
    { Name = "walkfling", Desc = "walkfling (wfling,wf),probably the best fling lol" },
    { Name = "unwalkfling", Desc = "unwalkfling (unwfling,unwf),stop the walkfling command" },
    { Name = "rjre", Desc = "rjre (rejoinrefresh),Rejoins and teleports you to your previous position" },
    { Name = "cancelteleport", Desc = "cancelteleport,Cancel an in-progress teleport" },
    { Name = "cancelteleportloop", Desc = "cancelteleportloop [interval],Repeatedly cancels in-progress teleport" },
    { Name = "uncancelteleportloop", Desc = "uncancelteleportloop,Disable cancelteleport loop" },
    { Name = "rejoin", Desc = "rejoin (rj),Rejoin the game" },
    { Name = "teleporttoplace", Desc = "teleporttoplace ,Teleports you using PlaceId" },
    { Name = "adonisbypass", Desc = "adonisbypass (bypassadonis,badonis,adonisb),bypasses adonis admin detection" },
    { Name = "accountage", Desc = "accountage (accage),Tells the account age of a player in the server" },
    { Name = "h", Desc = "hitboxes,shows all the hitboxes" },
    { Name = "u", Desc = "unhitboxes,removes the hitboxes outline" },
    { Name = "vfly", Desc = "vehiclefly (vfly),be able to fly vehicles" },
    { Name = "unvfly", Desc = "unvfly,disable vehicle fly" },
    { Name = "equiptools", Desc = "equiptools,Equip all of your tools" },
    { Name = "usetools", Desc = "usetools (uset),Equips all tools, uses them, and unequips them" },
    { Name = "settweenspeed", Desc = "tweenspeed [seconds],Set how long tween teleport commands take" },
    { Name = "tweento", Desc = "tweengoto ,Teleportation method that bypasses some anticheats" },
    { Name = "reach", Desc = "reach [number] (swordreach), Extends sword reach in one direction" },
    { Name = "b", Desc = "boxreach [number], Creates a box-shaped hitbox around your tool" },
    { Name = "resetreach", Desc = "resetreach (normalreach, unreach), Resets tool to normal size" },
    { Name = "a", Desc = "aura [distance],Continuously damages nearby players with equipped tool" },
    { Name = "u", Desc = "unaura,Stops aura loop and removes visualizer" },
    { Name = "n", Desc = "npcaura [distance],Continuously damages nearby NPCs with equipped tool" },
    { Name = "u", Desc = "unnpcaura,Stops NPC aura loop and removes visualizer" },
    { Name = "a", Desc = "antivoid,Prevents you from falling into the void by launching you upwards" },
    { Name = "u", Desc = "unantivoid,Disables antivoid" },
    { Name = "f", Desc = "fakeout, tp to void and back" },
    { Name = "i", Desc = "invisfling, Enables invisible fling (the invis part is patched, try using the god command before using this)" },
    { Name = "s", Desc = "split, Destroys waist joint" },
    { Name = "a", Desc = "antivoid2, sets FallenPartsDestroyHeight to -inf" },
    { Name = "u", Desc = "unantivoid2, reverts FallenPartsDestroyHeight" },
    { Name = "antivelocity", Desc = "antivelocity [limit], Limits your characters velocity to the provided value" },
    { Name = "unantivelocity", Desc = "unantivelocity, Disables the antivelocity limiter" },
    { Name = "antiknockback", Desc = "antiknockback (akb), Disables knockback" },
    { Name = "unantiknockback", Desc = "unantiknockback (unakb), Disables antiknockback" },
    { Name = "showcom", Desc = "showcom [radiusStuds],Create a glass sphere with a Highlight at your center of mass" },
    { Name = "p", Desc = "predict [leadSeconds],Visualize predicted player movement" },
    { Name = "u", Desc = "unpredict ,Remove prediction orb" },
    { Name = "hidecom", Desc = "hidecom,Remove COM tracker" },
    { Name = "droptool", Desc = "droptool, Drop one of your tools" },
    { Name = "d", Desc = "dropalltools, Drop all of your tools" },
    { Name = "loopdroptools", Desc = "loopdroptools, Loop drops your tools" },
    { Name = "unloopdroptools", Desc = "unloopdroptools, Stops loop dropping tools" },
    { Name = "n", Desc = "notools,Remove your tools" },
    { Name = "fpsbooster", Desc = "fpsbooster,Enables maximum-performance low graphics mode, run again to restore" },
    { Name = "a", Desc = "annoy , Annoys the given player" },
    { Name = "u", Desc = "unannoy, Stops the annoy command" },
    { Name = "deleteinvisparts", Desc = "deleteinvisparts (deleteinvisibleparts,dip),Deletes invisible parts" },
    { Name = "invisibleparts", Desc = "invisibleparts (invisparts),Shows invisible parts" },
    { Name = "uninvisibleparts", Desc = "uninvisibleparts (uninvisparts),Makes parts affected by invisparts return to normal" },
    { Name = "d", Desc = "datalimit ,Set outgoing bandwidth limit in KBps" },
    { Name = "removeads", Desc = "removeads (adblock),Continuously removes billboard advertisements" },
    { Name = "unremoveads", Desc = "unremoveads (noadblock,disableads),Stop removing billboard advertisements" },
    { Name = "replicationlag", Desc = "replicationlag (backtrack), Set IncomingReplicationLag" },
    { Name = "a", Desc = "animdata, Shows you information about your current animations" },
    { Name = "u", Desc = "unanimdata," },
    { Name = "s", Desc = "sleepon, Enable AllowSleep" },
    { Name = "u", Desc = "unsleepon, Disable AllowSleep" },
    { Name = "t", Desc = "throttle, Set PhysicsEnvironmentalThrottle (1 = default, 2 = disabled)" },
    { Name = "quality", Desc = "quality <1-21>,Manage rendering quality settings" },
    { Name = "l", Desc = "logphysics, Enable Physics Error Logging" },
    { Name = "n", Desc = "nologphysics, Disable Physics Error Logging" },
    { Name = "n", Desc = "norender,Disable 3d Rendering to decrease the amount of CPU the client uses" },
    { Name = "r", Desc = "render,Enable 3d Rendering" },
    { Name = "noreset", Desc = "noreset,disable reset button" },
    { Name = "resetbtn", Desc = "resetbtn,enable reset button" },
    { Name = "l", Desc = "loopoof,Loops everyones character sounds (everyone can hear)" },
    { Name = "u", Desc = "unloopoof,Stops the oof chaos" },
    { Name = "s", Desc = "strengthen,Makes your character more dense (CustomPhysicalProperties)" },
    { Name = "unweaken", Desc = "unweaken (unstrengthen),Sets your characters CustomPhysicalProperties to default" },
    { Name = "w", Desc = "weaken,Makes your character less dense" },
    { Name = "s", Desc = "seat, Finds a seat and automatically sits on it" },
    { Name = "vehicleseat", Desc = "vehicleseat (vseat), Sits you in a vehicle seat, useful for trying to find cars in games" },
    { Name = "copytools", Desc = "copytools (ctools),Copies the tools the given player has" },
    { Name = "localtime", Desc = "localtime (yourtime), Shows your current time" },
    { Name = "localdate", Desc = "localdate (yourdate), Shows your current date" },
    { Name = "servertime", Desc = "servertime (svtime), Shows the servers current time" },
    { Name = "serverdate", Desc = "serverdate (svdate), Shows the servers current date" },
    { Name = "datetime", Desc = "datetime (localdatetime), Shows your full local date and time" },
    { Name = "u", Desc = "uptime, Shows how long the game/session has been running" },
    { Name = "timestamp", Desc = "timestamp (epoch), Shows current Unix timestamp" },
    { Name = "cartornado", Desc = "cartornado (ctornado), Tornados a car just sit in the car" },
    { Name = "unspam", Desc = "unspam,Stop all attempts to lag/spam" },
    { Name = "UNCTest", Desc = "UNCTest (UNC),Test how many functions your executor supports" },
    { Name = "vulnerabilitytest", Desc = "vulnerabilitytest (vulntest),Test if your executor is Vulnerable" },
    { Name = "respawn", Desc = "respawn (re), Respawn your character" },
    { Name = "a", Desc = "antisit,Prevents the player from sitting" },
    { Name = "u", Desc = "unantisit,Allows the player to sit again" },
    { Name = "antikick", Desc = "antikick (nokick, bypasskick, bk),Bypass Kick on Most Games" },
    { Name = "antiteleport", Desc = "antiteleport (noteleport, blocktp),Prevents TeleportService from moving you to another place" },
    { Name = "unantikick", Desc = "unantikick,Disables Anti-Kick protection" },
    { Name = "unantiteleport", Desc = "unantiteleport,Disables Anti-Teleport protection" },
    { Name = "anticframeteleport", Desc = "anticframeteleport (acframetp,acftp),Prevents client teleports" },
    { Name = "unanticframeteleport", Desc = "unanticframeteleport (unacframetp,unacftp),Disables Anti CFrame Teleport" },
    { Name = "l", Desc = "lay,zzzzzzzz" },
    { Name = "t", Desc = "trip,get up NOW" },
    { Name = "permtrip", Desc = "permtrip (ptrip),Permanent trip that keeps you down" },
    { Name = "unpermtrip", Desc = "unpermtrip (unptrip),Disable permanent trip" },
    { Name = "a", Desc = "antitrip, no tripping today bruh" },
    { Name = "u", Desc = "unantitrip, tripping allowed now" },
    { Name = "disablehumanoidstate", Desc = "disablehumanoidstate, why..." },
    { Name = "enablehumanoidstate", Desc = "enablehumanoidstate, why..." },
    { Name = "c", Desc = "checkrfe,Checks if the game has respect filtering enabled off" },
    { Name = "s", Desc = "sit,Sit your player" },
    { Name = "o", Desc = "oldroblox,Old skybox and studs" },
    { Name = "u", Desc = "unoldroblox,Restore skybox and studs" },
    { Name = "2", Desc = "2016,Makes your Pedoblox CoreGui look like the 2016 CoreGui" },
    { Name = "f3x", Desc = "f3x (fex),F3X for client" },
    { Name = "harked", Desc = "harked (comet),Executes Comet which is like harked" },
    { Name = "triggerbot", Desc = "triggerbot (tbot), Executes a script that automatically clicks the mouse when the mouse is on a player" },
    { Name = "setspawn", Desc = "setspawn (spawnpoint, ss),Sets your spawn point to the current characters position" },
    { Name = "disablespawn", Desc = "disablespawn (unsetspawn, ds),Disables the previously set spawn point" },
    { Name = "autoflashback", Desc = "autoflashback,Auto-teleports you to your last death point on respawn" },
    { Name = "unautoflashback", Desc = "unautoflashback,Disables auto deathpos" },
    { Name = "flashback", Desc = "flashback (deathpos, deathtp), Teleports you to your last death point" },
    { Name = "tospawn", Desc = "tospawn (ts), Teleports you to a SpawnLocation" },
    { Name = "h", Desc = "hamster , Hamster ball" },
    { Name = "u", Desc = "unhamster, Disable hamster ball" },
    { Name = "antiafk", Desc = "antiafk (noafk),Prevents you from being kicked for being AFK" },
    { Name = "unantiafk", Desc = "unantiafk (unnoafk),Allows you to be kicked for being AFK" },
    { Name = "tptool", Desc = "tptool,Create click/tween teleport buttons or backpack tools" },
    { Name = "unclicktptool", Desc = "unclicktptool,Remove teleport buttons or tools" },
    { Name = "clickteleport", Desc = "clickteleport,Bind-only click teleport (hold bind + left click)" },
    { Name = "clickdelete", Desc = "clickdelete,Bind-only click delete (hold bind + left click)" },
    { Name = "t", Desc = "thru ,Move forward by distance" },
    { Name = "o", Desc = "olddex,Using this you can see the parts / guis / scripts etc with this. A really good and helpful script." },
    { Name = "d", Desc = "dex,Better version of dex" },
    { Name = "m", Desc = "minimap,just a minimap lol" },
    { Name = "animationplayer", Desc = "animationplayer,dropdown menu with all the animations the game has to be played" },
    { Name = "D", Desc = "Decompiler,Allows you to decompile LocalScript/ModuleScripts using konstant" },
    { Name = "getidfromusername", Desc = "getidfromusername (gidu),Copy a users UserId by Username" },
    { Name = "getuserfromid", Desc = "getuserfromid (guid),Copy a users Username by ID" },
    { Name = "o", Desc = "ownerid,masks you as the game owners ID and Username" },
    { Name = "u", Desc = "userid ,changes your UserId to any ID you enter" },
    { Name = "username", Desc = "username ,changes your Username to any name you enter" },
    { Name = "spoofclientid", Desc = "spoofclientid (spoofclid), Spoofs GetClientId() to the value you provide" },
    { Name = "unspoofclientid", Desc = "unspoofclientid (unspoofclid), Restores normal GetClientId() behavior" },
    { Name = "synapsedex", Desc = "synapsedex (sdex),Loads SynapseXs dex explorer" },
    { Name = "a", Desc = "antifling,makes other players non-collidable with you" },
    { Name = "u", Desc = "unantifling,restores collision for other players" },
    { Name = "antiflingparts", Desc = "antiflingparts,Disables collision on nearby high-velocity unanchored non-player parts" },
    { Name = "unantiflingparts", Desc = "unantiflingparts,Restores collision for unanchored parts changed by antiflingparts" },
    { Name = "lockws", Desc = "lockws (lockworkspace),Locks the whole workspace" },
    { Name = "unlockws", Desc = "unlockws (unlockworkspace),Unlocks everything in Workspace" },
    { Name = "vehiclespeed", Desc = "vehiclespeed (vspeed), Change the vehicle speed" },
    { Name = "unvehiclespeed", Desc = "unvehiclespeed (unvspeed), Stops the vehiclespeed command" },
    { Name = "shiftlock", Desc = "shiftlock (sl), Toggles shiftlock" },
    { Name = "unshiftlock", Desc = "unshiftlock (unsl), Disables shiftlock" },
    { Name = "e", Desc = "enable, Enables a specific CoreGui" },
    { Name = "d", Desc = "disable, Disables a specific CoreGui" },
    { Name = "reverb", Desc = "reverb (reverbcontrol),Manage sound reverb settings" },
    { Name = "forcereverb", Desc = "forcereverb,Lock ambient reverb and auto-restore if changed" },
    { Name = "unforcereverb", Desc = "unforcereverb (ufreverb, ufr),Stop forcing ambient reverb" },
    { Name = "cam", Desc = "cam (camera, cameratype),Manage camera type settings" },
    { Name = "f", Desc = "forcecam,Lock camera type and auto-restore if changed" },
    { Name = "unforcecam", Desc = "unforcecam (ufcam, ufc),Stop forcing camera type" },
    { Name = "alignmentkeys", Desc = "alignmentkeys,Enable alignment keys" },
    { Name = "disablealignmentkeys", Desc = "disablealignmentkeys,Disable alignment keys" },
    { Name = "e", Desc = "esp,locate where the players are" },
    { Name = "c", Desc = "chams,ESP but without the text :shock:" },
    { Name = "l", Desc = "locate etc (optional), locate where the specified player(s) are" },
    { Name = "npcesp", Desc = "npcesp (espnpc),locate where the npcs are" },
    { Name = "unnpcesp", Desc = "unnpcesp (unespnpc),stop locating npcs" },
    { Name = "unesp", Desc = "unesp (unchams),Disables esp/chams" },
    { Name = "u", Desc = "unlocate" },
    { Name = "c", Desc = "crash,crashes ur client lol (why would you even use this tho)" },
    { Name = "vehiclenoclip", Desc = "vehiclenoclip (vnoclip), Disables vehicle collision" },
    { Name = "vehicleclip", Desc = "vehicleclip (vclip, unvnoclip, unvehiclenoclip), Enables vehicle collision" },
    { Name = "handlekill", Desc = "handlekill (hkill), Kills a player using a tool that deals damage on touch" },
    { Name = "c", Desc = "creep , Teleports from a player behind them and under the floor to the top" },
    { Name = "netless", Desc = "netless (net),Executes netless which makes scripts more stable" },
    { Name = "reset", Desc = "reset (die),Makes your health be 0" },
    { Name = "runanim", Desc = "runanim [speed] (playanim,anim), Plays an animation by ID with optional speed multiplier" },
    { Name = "animbuilder", Desc = "animbuilder (abuilder),Opens animation builder GUI" },
    { Name = "setkiller", Desc = "setkiller (killeranim), Sets killer animation set" },
    { Name = "setpsycho", Desc = "setpsycho (psychoanim), Sets psycho animation set" },
    { Name = "resetanims", Desc = "resetanims (defaultanims,animsreset), Restores your previous animations" },
    { Name = "animcopycore", Desc = "animcopycore ,Copy core animations from target" },
    { Name = "syncanim", Desc = "syncanim ,Mirror target animations (live)" },
    { Name = "syncstop", Desc = "syncstop,Stop live sync and restore defaults" },
    { Name = "animresetcore", Desc = "animresetcore,Reset core animations to saved" },
    { Name = "unsyncreset", Desc = "unsyncreset,Stop sync and reset saved" },
    { Name = "mimic", Desc = "mimic [delay],Clone target movement with optional delay" },
    { Name = "mstop", Desc = "mstop,Stop mimic and restore defaults" },
    { Name = "bubblechat", Desc = "bubblechat (bchat),Enables BubbleChat" },
    { Name = "unbubblechat", Desc = "unbubblechat (unbchat),Disabled BubbleChat" },
    { Name = "hideicon", Desc = "hideicon,Hides the NA icon" },
    { Name = "showicon", Desc = "showicon,Shows the NA icon" },
    { Name = "lockiconposition", Desc = "lockiconposition,Locks the NA icons position (cant be dragged)" },
    { Name = "unlockiconposition", Desc = "unlockiconposition,Unlocks the NA icons position (can be dragged again)" },
    { Name = "saveinstance", Desc = "saveinstance (savegame),if it bugs out try removing stuff from your AutoExec folder" },
    { Name = "admin", Desc = "admin ,Whitelist the user to have access to *your* client-side commands, anything they type runs on *you*, not on themselves" },
    { Name = "u", Desc = "unadmin ,removes someone from being admin" },
    { Name = "partname", Desc = "partname (partpath,partgrabber),gives a ui and allows you click on a part to grab its path" },
    { Name = "j", Desc = "jobid,Copies your job id" },
    { Name = "joinjobid", Desc = "joinjobid ,Joins the job id you put in" },
    { Name = "serverhop", Desc = "serverhop (shop),serverhop" },
    { Name = "smallserverhop", Desc = "smallserverhop (sshop),serverhop to a small server" },
    { Name = "pingserverhop", Desc = "pingserverhop (pshop),serverhop to a server with the best ping" },
    { Name = "autorejoin", Desc = "autorejoin (autorj), Rejoins the server if you get kicked / disconnected" },
    { Name = "unautorejoin", Desc = "unautorejoin (unautorj), Disables auto rejoin command" },
    { Name = "f", Desc = "functionspy,Check console" },
    { Name = "f", Desc = "fly [speed],Enable flight" },
    { Name = "u", Desc = "unfly,Disable flight" },
    { Name = "cframefly", Desc = "cframefly [speed] (cfly),Enable CFrame-based flight" },
    { Name = "uncframefly", Desc = "uncfly,Disable CFrame-based flight" },
    { Name = "tfly", Desc = "tfly [speed] (tweenfly),Enables smooth flying" },
    { Name = "untfly", Desc = "untfly,Disables tween flying" },
    { Name = "noclip", Desc = "noclip,Disable your players collision" },
    { Name = "clip", Desc = "clip,Enable your players collision" },
    { Name = "antianchor", Desc = "antianchor,Prevent your parts from being anchored" },
    { Name = "unantianchor", Desc = "unantianchor,Allow your parts to be anchored" },
    { Name = "a", Desc = "antibang, prevents users to bang you (still WORK IN PROGRESS)" },
    { Name = "u", Desc = "unantibang, disables antibang" },
    { Name = "o", Desc = "orbit [speed], Orbit around a player" },
    { Name = "u", Desc = "uporbit [speed], Orbit around a player on the Y axis" },
    { Name = "u", Desc = "unorbit, Stop orbiting" },
    { Name = "freecam", Desc = "freecam [speed] (fc,fcam),Enable free camera" },
    { Name = "unfreecam", Desc = "unfreecam (unfc,unfcam),Disable free camera" },
    { Name = "nohats", Desc = "nohats (drophats),Drop all of your hats" },
    { Name = "permadeath", Desc = "permadeath (pdeath), be death permanently" },
    { Name = "unpermadeath", Desc = "unpermadeath (unpdeath), no perma death" },
    { Name = "instantrespawn", Desc = "instantrespawn (instantr, irespawn), respawn instantly" },
    { Name = "circlemath", Desc = "circlemath , Gay circle math\nModes: a,b,c,d,e" },
    { Name = "grippos", Desc = "grippos (setgrip), Opens a UI to manually input grip offset and rotation." },
    { Name = "s", Desc = "seizure, Gives you a seizure" },
    { Name = "u", Desc = "unseizure, Stops you from having a seizure not in real life noob" },
    { Name = "fakelag", Desc = "fakelag (flag), fake lag" },
    { Name = "unfakelag", Desc = "unfakelag (unflag), stops the fake lag command" },
    { Name = "hide", Desc = "hide (unshow), places the selected player to lighting" },
    { Name = "unhide", Desc = "show (unhide), places the selected player back to workspace" },
    { Name = "aimbot", Desc = "aimbot (aimbotui,aimbotgui),aimbot and yeah" },
    { Name = "grabtools", Desc = "grabtools [range],Grabs dropped tools" },
    { Name = "loopgrabtools", Desc = "loopgrabtools [range],Loop grabs dropped tools" },
    { Name = "unloopgrabtools", Desc = "unloopgrabtools,Stops the loop grab command" },
    { Name = "d", Desc = "dance,Does a random dance" },
    { Name = "u", Desc = "undance,Stops the dance command" },
    { Name = "animspoofer", Desc = "animspoofer (animationspoofer, spoofanim, animspoof),Loads up an animation spoofer,spoofs animations that use rbxassetid" },
    { Name = "badgeviewer", Desc = "badgeviewer (badgeview, bviewer, badgev, bv),loads up a badge viewer UI that views all badges in the game youre in" },
    { Name = "bodytransparency", Desc = "bodytransparency [part1] [part2] ... (btransparency,bodyt), Sets LocalTransparencyModifier on selected body parts (no Head) to a value (0-1). UI supports multi-select." },
    { Name = "unbodytransparency", Desc = "unbodytransparency (unbtransparency,unbodyt), Stops transparency loop" },
    { Name = "animationspeed", Desc = "animationspeed (animspeed,aspeed), Adjusts the speed of currently playing animations" },
    { Name = "unanimationspeed", Desc = "unanimationspeed (unanimspeed,unaspeed), Stops the animation speed adjustment loop" },
    { Name = "placeid", Desc = "placeid (pid),Copies the PlaceId of the game youre in" },
    { Name = "gameid", Desc = "gameid (universeid,gid),Copies the GameId/Universe Id of the game youre in" },
    { Name = "f", Desc = "firework, pop" },
    { Name = "placename", Desc = "placename (pname),Copies the games place name to your clipboard" },
    { Name = "gameinfo", Desc = "gameinfo (ginfo),shows info about the game youre playing" },
    { Name = "userpreview", Desc = "userpreview,show info about a user you name" },
    { Name = "copyname", Desc = "copyname (cname), Copies the username of the target" },
    { Name = "copydisplay", Desc = "copydisplay (cdisplay), Copies the display name of the target" },
    { Name = "copyid", Desc = "copyid (id), Copies the UserId of the target" },
    { Name = "antitouch", Desc = "antitouch [remove/cantouch/loop] (antikillbrick, antikb),Disables touchable parts" },
    { Name = "loopantitouch", Desc = "loopantitouch (loopantikillbrick, loopantikb),Enables AntiTouch live tracking without opening the method popup" },
    { Name = "unantitouch", Desc = "unantitouch (unantikillbrick, unantikb),Re-enables touchable parts" },
    { Name = "height", Desc = "height (hipheight,hh),Changes your hipheight" },
    { Name = "netbypass", Desc = "netbypass (netb), Net bypass" },
    { Name = "d", Desc = "day,Makes it day" },
    { Name = "n", Desc = "night,Makes it night" },
    { Name = "t", Desc = "time , Sets the time" },
    { Name = "chat", Desc = "chat (message), Chats for you, useful if youre muted" },
    { Name = "privatemessage", Desc = "privatemessage (pm), Sends a private message to a player" },
    { Name = "mimicchat", Desc = "mimicchat (mimic), Mimics the chat of a player" },
    { Name = "stopmimicchat", Desc = "stopmimicchat (unmimicchat), Stops mimicking a player" },
    { Name = "fixcam", Desc = "fixcam, Fix your camera" },
    { Name = "f", Desc = "fling , Fling the given player" },
    { Name = "commitoof", Desc = "commitoof (suicide, kys), Triggers a dramatic oof sequence for the player" },
    { Name = "volume", Desc = "volume <0-10> (vol),Changes your volume" },
    { Name = "p", Desc = "perfstats ,Shows or hides performance stats" },
    { Name = "preftransparency", Desc = "preftransparency <0-15>,Preferred UI transparency" },
    { Name = "sensitivity", Desc = "sensitivity <1-10> (sens),Changes your sensitivity" },
    { Name = "torandom", Desc = "torandom (tr),Teleports to a random player" },
    { Name = "timestop", Desc = "timestop (tstop), freezes all players (ZA WARUDO)" },
    { Name = "untimestop", Desc = "untimestop (untstop), unfreeze all players" },
    { Name = "t", Desc = "team ,Changes your team (for the client)" },
    { Name = "n", Desc = "nilchar,Temporarily parent your character to nil" },
    { Name = "unnilchar", Desc = "unnilchar (nonilchar),Move your character back to workspace" },
    { Name = "char", Desc = "char ,change your characters appearance to someone elses" },
    { Name = "u", Desc = "unchar,revert to your character" },
    { Name = "autochar", Desc = "autochar,auto-change your character on respawn" },
    { Name = "unautochar", Desc = "unautochar,stop auto-change on respawn" },
    { Name = "reselectchar", Desc = "reselectchar,Re-open the character picker" },
    { Name = "autooutfit", Desc = "autooutfit {username/userid|outfit:id" },
    { Name = "unautooutfit", Desc = "unautooutfit,stop outfit auto-apply" },
    { Name = "outfit", Desc = "outfit {username/userid|outfit:id" },
    { Name = "goto", Desc = "goto ,Teleport to the given player or X,Y,Z coordinates" },
    { Name = "lookat", Desc = "lookat , Stare at a player" },
    { Name = "unlookat", Desc = "unlookat, Stops staring" },
    { Name = "starenear", Desc = "starenear (stareclosest), Stare at the closest player" },
    { Name = "unstarenear", Desc = "unstarenear (unstareclosest), Stop staring at closest player" },
    { Name = "watch", Desc = "watch (view, spectate), Spectate player" },
    { Name = "unwatch", Desc = "unwatch (unview), Stop spectating" },
    { Name = "watch2", Desc = "watch2," },
    { Name = "unwatch2", Desc = "unwatch2," },
    { Name = "stealaudio", Desc = "stealaudio ,Save all sounds a player is playing to a file -Cyrus" },
    { Name = "follow", Desc = "follow , Follow a player wherever they go" },
    { Name = "unfollow", Desc = "unfollow, Stop all attempts to follow a player" },
    { Name = "autofollow", Desc = "autofollow (autostalk,proxfollow), Automatically follow any player who comes close" },
    { Name = "unautofollow", Desc = "unautofollow (stopautofollow,unproxfollow), Stop automatically following nearby players" },
    { Name = "p", Desc = "pathfind ,Follow a player using the pathfinder API wherever they go" },
    { Name = "freeze", Desc = "freeze (thaw,anchor,fr),Freezes your character" },
    { Name = "unfreeze", Desc = "unfreeze (unthaw,unanchor,unfr),Unfreezes your character" },
    { Name = "blackhole", Desc = "blackhole,Makes unanchored parts teleport to the black hole" },
    { Name = "disableanimations", Desc = "disableanimations (disableanims),Freezes your animations" },
    { Name = "undisableanimations", Desc = "undisableanimations (undisableanims),Unfreezes your animations" },
    { Name = "h", Desc = "hatresize,Makes your hats very big r15 only" },
    { Name = "e", Desc = "exit,Close down pedoblox" },
    { Name = "firekey", Desc = "firekey (fkey),makes you fire a keybind using VirtualInputManager" },
    { Name = "l", Desc = "loopfling , Loop voids a player" },
    { Name = "u", Desc = "unloopfling, Stops loop flinging a player" },
    { Name = "freegamepass", Desc = "freegamepass (freegp), Pretends you own every gamepass and fires product purchase signals" },
    { Name = "devproducts", Desc = "devproducts (products),Lists Developer Products" },
    { Name = "l", Desc = "listen , Listen to your targets voice chat" },
    { Name = "vcworld", Desc = "vcworld ,Toggle default spatial voice routing" },
    { Name = "u", Desc = "unlisten, Stops listening" },
    { Name = "g", Desc = "gear [id], This is client sided and will probably not work" },
    { Name = "lockmouse", Desc = "lockmouse (lockm), Default Mouse Behaviour (idk any description)" },
    { Name = "unlockmouse", Desc = "unlockmouse (unlockm), Unlocks your mouse (fr this time)" },
    { Name = "lockmouse2", Desc = "lockmouse2 (lockm2), Locks your mouse in the center" },
    { Name = "unlockmouse2", Desc = "unlockmouse2 (unlockm2), Unlocks your mouse" },
    { Name = "h", Desc = "headsit , sit on someones head" },
    { Name = "u", Desc = "unheadsit, Stop the headsit command." },
    { Name = "w", Desc = "wallhop,wallhop helper" },
    { Name = "u", Desc = "unwallhop,disable wallhop helper" },
    { Name = "joinvoice", Desc = "joinvoice,lets you use vc if you were suspended" },
    { Name = "j", Desc = "jump,jump." },
    { Name = "loopjump", Desc = "loopjump (bhop),Continuously jump." },
    { Name = "unloopjump", Desc = "unloopjump (unbhop),Stop continuous jumping." },
    { Name = "trussjump", Desc = "trussjump,Boost off trusses when you jump" },
    { Name = "untrussjump", Desc = "untrussjump,Disable trussjump" },
    { Name = "chattranslate", Desc = "chattranslate,the very old chat translator came back after years" },
    { Name = "h", Desc = "headstand , Stand on someones head." },
    { Name = "u", Desc = "unheadstand, Stop the headstand command." },
    { Name = "loopwalkspeed", Desc = "loopwalkspeed (loopws,lws), Loop walkspeed" },
    { Name = "unloopwalkspeed", Desc = "unloopwalkspeed, Disable loop walkspeed" },
    { Name = "loopjumppower", Desc = "loopjumppower (loopjp,ljp), Loop JumpPower" },
    { Name = "unloopjumppower", Desc = "unloopjumppower (unloopjp,unljp), Disable loop jump power" },
    { Name = "stopanimations", Desc = "stopanimations (stopanims,stopanim,noanim), Stops running animations" },
    { Name = "refreshanimations", Desc = "refreshanimations (refreshanimation,refreshanims,refreshanim), Reload character animations" },
    { Name = "loopwaveat", Desc = "loopwaveat (loopwat), Wave to a player in a loop" },
    { Name = "unloopwaveat", Desc = "unloopwaveat (unloopwat), Stops the loopwaveat command" },
    { Name = "tools", Desc = "tools (gears), Copies tools from ReplicatedStorage and Lighting" },
    { Name = "toolview", Desc = "toolview (tview), 3D tool viewer above a players head" },
    { Name = "untoolview", Desc = "untview (untview), Removes the tool viewer above a players head" },
    { Name = "toolview2", Desc = "toolview2 (tview2), Live-updating tool viewer" },
    { Name = "waveat", Desc = "waveat (wat), Wave to a player" },
    { Name = "headbang", Desc = "headbang (mouthbang,headfuck,mouthfuck,facebang,facefuck,hb,mb), Bang them in the mouth because you are gay" },
    { Name = "unheadbang", Desc = "unheadbang (unmouthbang,unhb,unmb), Stops headbang" },
    { Name = "jerkuser", Desc = "jerkuser (jorkuser, handjob, hjob, handj), Lay under them and vibe" },
    { Name = "unjerkuser", Desc = "unjerkuser (unjorkuser, unhandjob, unhjob, unhandj), Stop the jerk user action" },
    { Name = "suck", Desc = "suck ,suck it" },
    { Name = "unsuck", Desc = "unsuck,no more fun" },
    { Name = "i", Desc = "improvetextures,Switches Textures" },
    { Name = "u", Desc = "undotextures,Switches Textures" },
    { Name = "serverlist", Desc = "serverlist (serverlister,slist),list of servers to join in" },
    { Name = "k", Desc = "keyboard,provides a keyboard gui for mobile users" },
    { Name = "a", Desc = "autoclicker,provides a autoclicker gui" },
    { Name = "b", Desc = "backpack,provides a custom backpack gui" },
    { Name = "edgejump", Desc = "edgejump (ejump), Automatically jumps when you get to the edge of an object" },
    { Name = "unedgejump", Desc = "unedgejump (noedgejump, noejump, unejump), Disables edgejump" },
    { Name = "equiptools", Desc = "equiptools (etools,equipt),Equips every tool in your inventory" },
    { Name = "u", Desc = "unequiptools,Unequips every tool you are currently holding" },
    { Name = "equiptool", Desc = "equiptool (etool),Equip a specific tool by name or selection" },
    { Name = "loopequiptool", Desc = "loopequiptool ,Keeps a specific tool equipped until disabled" },
    { Name = "unloopequiptool", Desc = "unloopequiptool,Stops the loop equip behaviour" },
    { Name = "multitool", Desc = "multitool (mtool),Allows stacking equipped tools from your inventory" },
    { Name = "unmultitool", Desc = "unmultitool (nomultitool),Disables multitool mode" },
    { Name = "bang", Desc = "bang (fuck), fucks the player by attaching to them" },
    { Name = "unbang", Desc = "unbang (unfuck), Unbangs the player" },
    { Name = "c", Desc = "carpet , Be someones carpet" },
    { Name = "uncarpet", Desc = "uncarpet (nocarpet), Undoes carpet" },
    { Name = "c", Desc = "climb, Allows you to climb while in air" },
    { Name = "u", Desc = "unclimb, Disables climb" },
    { Name = "inversebang", Desc = "inversebang ,youre the one getting fucked today ;)" },
    { Name = "uninversebang", Desc = "uninversebang,no more fun" },
    { Name = "suslay", Desc = "suslay (laysus), Lay down in a suspicious way" },
    { Name = "u", Desc = "unsuslay, Stand up from the sussy lay" },
    { Name = "jerk", Desc = "jerk (jork), jorking it" },
    { Name = "hug", Desc = "hug (clickhug), huggies time (click on a target to hug)" },
    { Name = "u", Desc = "unhug, no huggies :(" },
    { Name = "glue", Desc = "glue ,Loop teleport to a player" },
    { Name = "unglue", Desc = "unglue,Stops teleporting you to a player" },
    { Name = "glueback", Desc = "glueback ,Loop teleport behind a player" },
    { Name = "unglueback", Desc = "unglueback,Stops teleporting you to a player" },
    { Name = "spook", Desc = "spook (scare), Teleports next to a player for a few seconds" },
    { Name = "loopspook", Desc = "loopspook ,Teleports next to a player repeatedly" },
    { Name = "unloopspook", Desc = "unloopspook,Stops the loopspook command" },
    { Name = "airwalk", Desc = "airwalk (float, aw), Press space to go up, unairwalk to stop" },
    { Name = "unairwalk", Desc = "unairwalk (unfloat, unaw), Stops the airwalk command" },
    { Name = "airmomentum", Desc = "airmomentum (amomentum, aircontrol), Overrides default in-air horizontal movement with custom air control" },
    { Name = "unairmomentum", Desc = "unairmomentum (unamomentum, unaircontrol), Stops the custom air momentum command" },
    { Name = "cbring", Desc = "cbring , Brings the player once on your client" },
    { Name = "loopcbring", Desc = "loopcbring , Continuously brings the player on your client" },
    { Name = "unloopcbring", Desc = "unloopcbring, Disable looped client bring" },
    { Name = "mute", Desc = "mute (muteboombox), Mutes the players boombox" },
    { Name = "tpwalk", Desc = "tpwalk , More undetectable walkspeed script" },
    { Name = "u", Desc = "untpwalk, Stops the tpwalk command" },
    { Name = "loopmute", Desc = "loopmute (loopmuteboombox), Loop mutes the players boombox" },
    { Name = "unloopmute", Desc = "unloopmute (unloopmuteboombox), Unloop mutes the players boombox" },
    { Name = "g", Desc = "getmass , Get your mass" },
    { Name = "copyposition", Desc = "copyposition , Get the position of another player" },
    { Name = "e", Desc = "equiptools,Equips every tool in your inventory at once" },
    { Name = "u", Desc = "unequiptools,Unequips every tool you are currently holding at once" },
    { Name = "removeterrain", Desc = "removeterrain (rterrain, noterrain),clears terrain" },
    { Name = "memory", Desc = "memory, Shows you your current memory usage" },
    { Name = "clearnilinstances", Desc = "clearnilinstances (nonilinstances, cni),Removes nil instances" },
    { Name = "i", Desc = "inspect, checks a users items" },
    { Name = "noprompt", Desc = "noprompt (nopurchaseprompts,noprompts,np),remove the stupid purchase prompt" },
    { Name = "prompt", Desc = "prompt (purchaseprompts,showprompts,showpurchaseprompts,ppr),allows the stupid purchase prompt" },
    { Name = "nonetworkpause", Desc = "nonetworkpause (disableNetworkPause,nnw,nnpause),Disable Roblox network pause overlay" },
    { Name = "networkpause", Desc = "networkpause (enablenetworkpause,nw,npause),Re-enable Roblox network pause overlay" },
    { Name = "w", Desc = "wallwalk,Makes you walk on walls" },
    { Name = "h", Desc = "hideguis,Hides GUIs" },
    { Name = "u", Desc = "unhideguis,Restores GUIs hidden by hideguis" },
    { Name = "s", Desc = "showguis,Enables every UI" },
    { Name = "u", Desc = "unshowguis,Restores UI states set by showguis" },
    { Name = "s", Desc = "spin {amount" },
    { Name = "u", Desc = "unspin, Makes your character unspin" },
    { Name = "notepad", Desc = "notepad,integrated notepad" },
    { Name = "r", Desc = "rc7,RC7 Internal UI" },
    { Name = "scriptviewer", Desc = "scriptviewer (viewscripts),Can view scripts made by 0866" },
    { Name = "moduleeditor", Desc = "moduleeditor,loads the module editor UI" },
    { Name = "upvalueeditor", Desc = "upvalueeditor,loads the upvalue editor UI" },
    { Name = "hydroxide", Desc = "hydroxide (hydro),executes hydroxide" },
    { Name = "remotespy", Desc = "remotespy (simplespy,rspy),executes simplespy that supports both pc and mobile" },
    { Name = "cobaltspy", Desc = "cobaltspy (cobalt,cspy)" },
    { Name = "turtlespy", Desc = "turtlespy (tspy),executes Turtle Spy that supports both pc and mobile" },
    { Name = "gravity", Desc = "gravity (grav),sets game gravity to whatever u want" },
    { Name = "fireclickdetectors", Desc = "fireclickdetectors (fcd,firecd),Fires every ClickDetector in Workspace" },
    { Name = "fireclickdetectorsfind", Desc = "fireclickdetectorsfind (fcdfind,firecdfind),Fires ClickDetectors substring-matching [target] in Workspace" },
    { Name = "fireproximityprompts", Desc = "fireproximityprompts (fpp,firepp),Fires every ProximityPrompt in Workspace" },
    { Name = "fireproximitypromptsfind", Desc = "fireproximitypromptsfind (fppfind,fireppfind),Fires ProximityPrompts substring-matching [target] in Workspace" },
    { Name = "firetouchinterests", Desc = "firetouchinterests (fti),Fires every TouchInterest in Workspace" },
    { Name = "firetouchinterestsfind", Desc = "firetouchinterestsfind (ftifind,firetifind),Fires TouchInterests substring-matching [target] in Workspace" },
    { Name = "autofireproxi", Desc = "autofireproxi [target],Automatically fires ProximityPrompts matching [target] every seconds" },
    { Name = "autofireproxifind", Desc = "autofireproxifind [target],Automatically fires ProximityPrompts matching [target] using substring matching every seconds" },
    { Name = "autofireclick", Desc = "autofireclick [target],Automatically fires ClickDetectors matching [target] every seconds" },
    { Name = "autofireclickfind", Desc = "autofireclickfind [target],Automatically fires ClickDetectors matching [target] using substring matching every seconds" },
    { Name = "autotouch", Desc = "autotouch [target],Automatically fires TouchInterests on parts matching [target] every seconds" },
    { Name = "autotouchfind", Desc = "autotouchfind [target],Automatically fires TouchInterests on parts matching [target] using substring matching every seconds" },
    { Name = "unautofireproxi", Desc = "unautofireproxi (uafp),Stops all AutoFireProxi loops" },
    { Name = "unautofireclick", Desc = "unautofireclick (uafc),Stops all AutoFireClick loops" },
    { Name = "unautotouch", Desc = "unautotouch (uat),Stops all AutoTouch loops" },
    { Name = "unautotouchfind", Desc = "unautotouchfind (uatfind),Stops substring-matching AutoTouch loops" },
    { Name = "unautofireproxifind", Desc = "unautofireproxifind (uafpfind),Stops substring-matching AutoFireProxi loops" },
    { Name = "unautofireclickfind", Desc = "unautofireclickfind (uafcfind),Stops substring-matching AutoFireClick loops" },
    { Name = "noclickdetectorlimits", Desc = "noclickdetectorlimits (nocdlimits,removecdlimits),Sets all click detectors MaxActivationDistance to math.huge" },
    { Name = "noproximitypromptlimits", Desc = "noproximitypromptlimits (nopplimits,removepplimits),Sets all proximity prompts MaxActivationDistance to math.huge" },
    { Name = "instantproximityprompts", Desc = "instantproximityprompts (instantpp,ipp),Disable the cooldown for proximity prompts" },
    { Name = "uninstantproximityprompts", Desc = "uninstantproximityprompts (uninstantpp,unipp),Undo the cooldown removal" },
    { Name = "enableproximitypromptservice", Desc = "enableproximitypromptservice (enablepps,epps,ppson,ppon),enable proximity prompt buttons" },
    { Name = "disableproximitypromptservice", Desc = "disableproximitypromptservice (disablepps,dpps,ppsoff,ppoff),disable proximity prompt buttons" },
    { Name = "enableproximityprompts", Desc = "enableproximityprompts [name],Enable ProximityPrompts (all or matching)" },
    { Name = "disableproximityprompts", Desc = "disableproximityprompts [name],Disable ProximityPrompts (all or matching)" },
    { Name = "loopenableproximityprompts", Desc = "loopenableproximityprompts [name],Continuously enable ProximityPrompts (all or matching)" },
    { Name = "unloopenableproximityprompts", Desc = "unloopenableproximityprompts,Stop enabling loop" },
    { Name = "r", Desc = "r6,Shows a prompt that will switch your character rig type into R6" },
    { Name = "r", Desc = "r15,Shows a prompt that will switch your character rig type into R15" },
    { Name = "b", Desc = "breakvelocity,Sets your characters velocity to zero momentarily" },
    { Name = "maxslopeangle", Desc = "maxslopeangle (msa), Changes your characters MaxSlopeAngle" },
    { Name = "unlight", Desc = "unlight (nolight),Removes dynamic light from your player" },
    { Name = "lighting", Desc = "lighting (lightingcontrol),Manage lighting technology settings" },
    { Name = "f", Desc = "friend , Sends a friend request to your target" },
    { Name = "u", Desc = "unfriend , Prompts to unfriend your target" },
    { Name = "block", Desc = "block (blockuser),Open block / unblock prompt for target player" },
    { Name = "friendweb", Desc = "friendweb (fweb),Finds friend circles in the current server" },
    { Name = "m", Desc = "massfollowedinto, Shows everyone in the server that followed someone into the game" },
    { Name = "tweengotocampos", Desc = "tweengotocampos (tweentcp),Another version of goto camera position but bypassing more anti-cheats" },
    { Name = "delete", Desc = "delete {partname" },
    { Name = "deletefind", Desc = "deletefind {partname" },
    { Name = "deletelighting", Desc = "deletelighting (removelighting, removel, ldel),Removes all descendants (objects) within Lighting." },
    { Name = "lightingdisable", Desc = "lightingdisable (disablelighting, ldisable), Disables all post-processing effects in Lighting instead of deleting them." },
    { Name = "autodelete", Desc = "autodelete {partname" },
    { Name = "unautodelete", Desc = "unautodelete {partname" },
    { Name = "autodeletefind", Desc = "autodeletefind {name" },
    { Name = "unautodeletefind", Desc = "unautodeletefind (unautoremovefind,unautodelfind), Stops autodeletefind" },
    { Name = "deleteclass", Desc = "deleteclass {ClassName" },
    { Name = "autodeleteclass", Desc = "autodeleteclass {ClassName" },
    { Name = "unautodeleteclass", Desc = "unautodeleteclass {ClassName" },
    { Name = "chardelete", Desc = "chardelete {partname" },
    { Name = "chardeletefind", Desc = "chardeletefind {name" },
    { Name = "chardeleteclass", Desc = "chardeleteclass {ClassName" },
    { Name = "gotopartnext", Desc = "gotopartnext [prefix] [end] [delay] (gpn), Teleport sequentially to parts with optional prefix and duplicate handling." },
    { Name = "gotomodelnext", Desc = "gotomodelnext [prefix] [end] [delay] (gmn), Teleport sequentially to models with optional prefix and duplicate handling." },
    { Name = "gotofoldernext", Desc = "gotofoldernext [prefix] [end] [delay] (gfn), Teleport sequentially through folder contents with optional prefix." },
    { Name = "gotobreak", Desc = "gotobreak (gb), Stop the active goto sequence and clear duplicate selections." },
    { Name = "gotopart", Desc = "gotopart {partname" },
    { Name = "tweengotopart", Desc = "tweengotopart ,Tween to each matching part by name once" },
    { Name = "gotopartfind", Desc = "gotopartfind {name" },
    { Name = "tweengotopartfind", Desc = "tweengotopartfind {name" },
    { Name = "gotopartclass", Desc = "gotopartclass {classname" },
    { Name = "bringpart", Desc = "bringpart {partname" },
    { Name = "bringpartfind", Desc = "bringpartfind {name" },
    { Name = "bringmodel", Desc = "bringmodel {modelname" },
    { Name = "bringmodelfind", Desc = "bringmodelfind {name" },
    { Name = "bringfolder", Desc = "bringfolder {folderName" },
    { Name = "gotomodel", Desc = "gotomodel {modelname" },
    { Name = "gotomodelfind", Desc = "gotomodelfind {name" },
    { Name = "gotomodelfind", Desc = "gotomodelfind {name" },
    { Name = "gotofolder", Desc = "gotofolder {folderName" },
    { Name = "s", Desc = "swim {speed" },
    { Name = "u", Desc = "unswim,Stops the swim script" },
    { Name = "p", Desc = "punch,punch tool that flings" },
    { Name = "tpua", Desc = "tpua ,Brings every unanchored part on the map to the player" },
    { Name = "blackholefollow", Desc = "blackholefollow,Pulls unanchored parts to you with spin" },
    { Name = "noblackholefollow", Desc = "noblackholefollow,Stops blackhole follow and clears constraints" },
    { Name = "swordfighter", Desc = "swordfighter (sfighter, swordf, swordbot, sf), Activates a sword fighting bot that engages in automated PvP combat" },
    { Name = "touchesp", Desc = "touchesp" },
    { Name = "untouchesp", Desc = "untouchesp" },
    { Name = "proximityesp", Desc = "proximityesp" },
    { Name = "unproximityesp", Desc = "unproximityesp" },
    { Name = "clickesp", Desc = "clickesp" },
    { Name = "unclickesp", Desc = "unclickesp" },
    { Name = "sitesp", Desc = "sitesp" },
    { Name = "unsitesp", Desc = "unsitesp" },
    { Name = "vehiclesitesp", Desc = "vehiclesitesp" },
    { Name = "unvehiclesitesp", Desc = "unvehiclesitesp" },
    { Name = "pesp", Desc = "pesp {partname" },
    { Name = "unpesp", Desc = "unpesp [name|All],Remove exact-name part ESP by name or All" },
    { Name = "pespfind", Desc = "pespfind {partname" },
    { Name = "unpespfind", Desc = "unpespfind [name|All],Remove partial-name part ESP by name or All" },
    { Name = "unanchored", Desc = "unanchored" },
    { Name = "ununanchored", Desc = "ununanchored" },
    { Name = "collisionesp", Desc = "collisionesp" },
    { Name = "uncollisionesp", Desc = "uncollisionesp" },
    { Name = "nocollisionesp", Desc = "nocollisionesp" },
    { Name = "unnocollisionesp", Desc = "unnocollisionesp" },
    { Name = "esplocator", Desc = "esplocator," },
    { Name = "unesplocator", Desc = "unesplocator," },
    { Name = "folderesp", Desc = "folderesp {folderName" },
    { Name = "modelesp", Desc = "modelesp {modelName" },
    { Name = "unfolderesp", Desc = "unfolderesp [folderName],Disables folder ESP for a folder or all" },
    { Name = "unmodelesp", Desc = "unmodelesp [modelName],Disables model ESP for a model or all" },
    { Name = "viewpart", Desc = "viewpart {partName" },
    { Name = "unviewpart", Desc = "unviewpart (unviewp), Resets the camera to the local humanoid" },
    { Name = "viewpartfind", Desc = "viewpartfind {name" },
    { Name = "unviewpart", Desc = "unviewpart (unviewp), Resets the camera to the local humanoid" },
    { Name = "console", Desc = "console (debug), Opens developer console" },
    { Name = "oldconsole", Desc = "oldconsole, opens old version of the developer console" },
    { Name = "hitbox", Desc = "hitbox {size" },
    { Name = "unhitbox", Desc = "unhitbox ," },
    { Name = "partsize", Desc = "partsize {name" },
    { Name = "partsizefind", Desc = "partsizefind {term" },
    { Name = "unpartsize", Desc = "unpartsize, Undo partsize—return those parts back to their original size and collision." },
    { Name = "unpartsizefind", Desc = "unpartsizefind, Undo partsizefind—return those resized parts back to their original size and collision." },
    { Name = "breakcars", Desc = "breakcars (bcars), Breaks any car" },
    { Name = "setsimradius", Desc = "setsimradius ,Set sim radius using available methods. Usage: setsimradius" },
    { Name = "infjump", Desc = "infjump (infinitejump), Enables infinite jumping" },
    { Name = "uninfjump", Desc = "uninfjump (uninfinitejump), Disables infinite jumping" },
    { Name = "f", Desc = "flyjump,Allows you to hold space to fly up" },
    { Name = "unflyjump", Desc = "unflyjump (noflyjump),Disables flyjump" },
    { Name = "xray", Desc = "xray (xrayon), Enables X-ray vision to see through walls" },
    { Name = "unxray", Desc = "unxray (xrayoff), Disables X-ray vision" },
    { Name = "fullbright", Desc = "fullbright (fullb,fb),makes dark games bright without destroying effects" },
    { Name = "loopday", Desc = "loopday,Sunshiiiine!" },
    { Name = "unloopday", Desc = "unloopday,No more sunshine" },
    { Name = "loopfullbright", Desc = "loopfullbright,Sunshiiiine!" },
    { Name = "unloopfullbright", Desc = "unloopfullbright,No more sunshine" },
    { Name = "loopnight", Desc = "loopnight,Moonlight." },
    { Name = "unloopnight", Desc = "unloopnight,No more moonlight." },
    { Name = "loopnoeffect", Desc = "loopnoeffect,Keeps Lighting and CurrentCamera effects disabled" },
    { Name = "unloopnoeffect", Desc = "unloopnoeffect,Restores Lighting and CurrentCamera effects" },
    { Name = "noeffect", Desc = "noeffect,Disables Lighting and CurrentCamera effects" },
    { Name = "loopnofog", Desc = "loopnofog,See clearly forever!" },
    { Name = "unloopnofog", Desc = "unloopnofog,No more sight." },
    { Name = "n", Desc = "nofog,Removes all fog from the game" },
    { Name = "nightmare", Desc = "nightmare,Make it dark and spooky" },
    { Name = "unnightmare", Desc = "unnightmare (unnm),Disable nightmare mode" },
    { Name = "b", Desc = "brightness ,Changes the brightness lighting property" },
    { Name = "loopbrightness", Desc = "loopbrightness (loopbri,loopb),Lock the brightness lighting property" },
    { Name = "unloopbrightness", Desc = "unloopbrightness (unloopbri,unloopb),Stop locking brightness" },
    { Name = "globalshadows", Desc = "globalshadows,Enables global shadows" },
    { Name = "unglobalshadows", Desc = "unglobalshadows (nogshadows,ungshadows,noglobalshadows),Disables global shadows" },
    { Name = "gamma", Desc = "gamma (exposure),gamma vision (real)" },
    { Name = "loopgamma", Desc = "loopgamma (loopexposure),loop gamma vision (mega real)" },
    { Name = "unloopgamma", Desc = "unloopgamma (unlgamma, unloopexposure, unlexposure),stop gamma vision (real)" },
    { Name = "firstp", Desc = "firstperson (1stp,firstp,fp),Makes you go in first person mode" },
    { Name = "thirdp", Desc = "thirdperson (3rdp,thirdp),Makes you go in third person mode" },
    { Name = "m", Desc = "maxzoom ,Set your maximum camera distance" },
    { Name = "m", Desc = "minzoom ,Set your minimum camera distance" },
    { Name = "cameranoclip", Desc = "cameranoclip (camnoclip,cnoclip,nccam),Makes your camera clip through walls" },
    { Name = "uncameranoclip", Desc = "uncameranoclip (uncamnoclip,uncnoclip,unnccam),Restores normal camera" },
    { Name = "o", Desc = "oganims,Old animations from 2007" },
    { Name = "f", Desc = "fakechat,Fake a chat gui" },
    { Name = "f", Desc = "fpscap ,Sets the fps cap to whatever you want" },
    { Name = "toolinvisible", Desc = "toolinvisible (tinvis), Be invisible while still being able to use tools" },
    { Name = "invisible", Desc = "invisible (invis), Sets invisibility to scare people or something" },
    { Name = "visible", Desc = "visible, turn visible" },
    { Name = "invisbind", Desc = "invisbind (invisiblebind, bindinvis), set a custom keybind for the Invisible command" },
    { Name = "fireremotes", Desc = "fireremotes (fremotes, frem), Fires every remote with arguments" },
    { Name = "k", Desc = "keepna, keep executing ..adminName.. every time you teleport" },
    { Name = "u", Desc = "unkeepna, Stop executing ..adminName.. every time you teleport" },
    { Name = "f", Desc = "fov , Sets your FOV to a custom value (1–300)" },
    { Name = "loopfov", Desc = "loopfov (lfov), Locks your FOV target (1–300)" },
    { Name = "unloopfov", Desc = "unloopfov (unlfov), Stops FOV loop" },
    { Name = "h", Desc = "homebrew,Executes homebrew admin" },
    { Name = "f", Desc = "fatesadmin,Executes fates admin" },
    { Name = "savetools", Desc = "savetools (stools), Saves your tools to memory" },
    { Name = "loadtools", Desc = "loadtools (ltools), Restores your saved tools to your backpack" },
    { Name = "preventtools", Desc = "preventtools (noequip,antiequip), Prevents any item from being equipped" },
    { Name = "unpreventtools", Desc = "unpreventtools (unnoequip,unantiequip), Self-explanatory" },
    { Name = "ws", Desc = "walkspeed (speed,ws), Sets your WalkSpeed" },
    { Name = "jp", Desc = "jumppower (jp), Sets your JumpPower" },
    { Name = "blockremote", Desc = "blockremote [name],Block a remote event/function by name (or pick from list)" },
    { Name = "unblockremote", Desc = "unblockremote [name|all],Unblock a remote by name, or pick from blocked list" },
    { Name = "bypassspeed", Desc = "bypassspeed (bps,bpws),Set WalkSpeed (bypass variant)" },
    { Name = "loopbypassspeed", Desc = "loopbypassspeed (lbps,lbws),Loop WalkSpeed (bypass variant)" },
    { Name = "unloopbypassspeed", Desc = "unloopbypassspeed (unlbps,unlbws),Disable loop WalkSpeed (bypass variant)" },
    { Name = "o", Desc = "oofspam,Spams oof" },
    { Name = "h", Desc = "httpspy,HTTP Spy" },
    { Name = "k", Desc = "keystroke,Executes a keystroke ui script" },
    { Name = "e", Desc = "errorchat,Makes the chat error appear when roblox chat is slow" },
    { Name = "clearerror", Desc = "clearerror, Clears any current error or disconnected UI immediately" },
    { Name = "a", Desc = "antierror, Continuously blocks and clears any future error or disconnected UI" },
    { Name = "unantierror", Desc = "unantierror, Disables Anti Error" },
    { Name = "boobs", Desc = "boobs (boobies),Boobs" },
    { Name = "unboobs", Desc = "unboobs (unboobies,noboobs,noboobies),Boobs" },
    { Name = "ass", Desc = "ass (booty),Ass" },
    { Name = "unass", Desc = "unass (noass),Ass" },
    { Name = "penis", Desc = "penis (pp),penis" },
    { Name = "unpenis", Desc = "unpenis (unpp,nopenis,nopp),penis" },
    { Name = "f", Desc = "flingnpcs, Flings NPCs" },
    { Name = "n", Desc = "npcfollow, Makes NPCS follow you" },
    { Name = "l", Desc = "loopnpcfollow, Makes NPCS follow you in a loop" },
    { Name = "u", Desc = "unloopnpcfollow, Makes NPCS not follow you in a loop" },
    { Name = "s", Desc = "sitnpcs, Makes NPCS sit" },
    { Name = "u", Desc = "unsitnpcs, Makes NPCS unsit" },
    { Name = "k", Desc = "killnpcs, Kills NPCs" },
    { Name = "npcwalkspeed", Desc = "npcwalkspeed ,Sets all NPC WalkSpeed to (default 16)" },
    { Name = "npcjumppower", Desc = "npcjumppower ,Sets all NPC JumpPower to (default 50)" },
    { Name = "b", Desc = "bringnpcs, Brings NPCs" },
    { Name = "loopbringnpcs", Desc = "loopbringnpcs (lbnpcs), Loops NPC bringing" },
    { Name = "unloopbringnpcs", Desc = "unloopbringnpcs (unlbnpcs), Stops NPC bring loop" },
    { Name = "g", Desc = "gotonpcs, Teleports to each NPC" },
    { Name = "a", Desc = "actnpc, Start acting like an NPC" },
    { Name = "unactnpc", Desc = "unactnpc (stopnpc), Stop acting like an NPC" },
    { Name = "clickkillnpc", Desc = "clickkillnpc (cknpc), Click on an NPC to kill it" },
    { Name = "unclickkillnpc", Desc = "unclickkillnpc (uncknpc), Disable clickkillnpc" },
    { Name = "voidnpcs", Desc = "voidnpcs (vnpcs), Teleports NPCs to void" },
    { Name = "clickvoidnpc", Desc = "clickvoidnpc (cvnpc), Click to void NPCs" },
    { Name = "unclickvoidnpc", Desc = "unclickvoidnpc (uncvnpc),Disable click-void" },
    { Name = "clicknpcws", Desc = "clicknpcws,Click on an NPC to set its WalkSpeed" },
    { Name = "unclicknpcws", Desc = "unclicknpcws,Disable clicknpcws" },
    { Name = "clicknpcjp", Desc = "clicknpcjp,Click on an NPC to set its JumpPower" },
    { Name = "unclicknpcjp", Desc = "unclicknpcjp,Disable clicknpcjp" },
    { Name = "r", Desc = "rename , Renames the admin UI placeholder to the given name" },
    { Name = "u", Desc = "unname, Resets the admin UI placeholder name to default" },

    }

    for _, cmd in ipairs(commands) do
        W:AddCommand({
            Name = "Ocean: " .. cmd.Name,
            Desc = cmd.Desc,
            Callback = function()
                runNACommand(cmd.Name)
                Ocean:Notify({ Title = "Command", Desc = "Executed: " .. cmd.Name, Type = "Success" })
            end
        })
    end
end


return Ocean
