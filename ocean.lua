-- ╔══════════════════════════════════════════════════════╗
-- ║           Ocean UI Library  •  Core                 ║
-- ║     Dark & Blue  •  Roblox-style  •  by Ocean       ║
-- ╚══════════════════════════════════════════════════════╝

local Ocean = {}
Ocean.__index = Ocean

-- ─── Services ─────────────────────────────────────────
local TweenService   = game:GetService("TweenService")
local UserInput      = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer    = Players.LocalPlayer

-- ─── gethui / CoreGui fallback ────────────────────────
local function getRoot()
    if gethui then return gethui() end
    return CoreGui
end

-- ─── Theme ────────────────────────────────────────────
Ocean.Theme = {
    -- backgrounds
    BG          = Color3.fromRGB(10,  14,  26),   -- deepest bg
    Surface     = Color3.fromRGB(16,  22,  40),   -- card/window
    Surface2    = Color3.fromRGB(20,  28,  52),   -- slightly lighter
    Surface3    = Color3.fromRGB(26,  36,  66),   -- hover / accent bg

    -- accent
    Accent      = Color3.fromRGB(58,  130, 246),  -- ocean blue
    AccentHover = Color3.fromRGB(96,  165, 250),  -- lighter on hover
    AccentDark  = Color3.fromRGB(30,  80,  180),  -- pressed / dim

    -- text
    TextPrimary = Color3.fromRGB(235, 240, 255),
    TextSub     = Color3.fromRGB(140, 160, 200),
    TextDim     = Color3.fromRGB(80,  100, 150),

    -- borders / strokes
    Border      = Color3.fromRGB(30,  45,  90),
    BorderHover = Color3.fromRGB(58,  130, 246),

    -- states
    Success     = Color3.fromRGB(34,  197, 94),
    Warning     = Color3.fromRGB(234, 179, 8),
    Danger      = Color3.fromRGB(239, 68,  68),

    -- toggle
    ToggleOff   = Color3.fromRGB(30,  40,  70),
    ToggleOn    = Color3.fromRGB(58,  130, 246),
}

-- ─── Tween helper ─────────────────────────────────────
local function tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local fast   = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local slow   = TweenInfo.new(0.55, Enum.EasingStyle.Expo,  Enum.EasingDirection.Out)

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

-- ══════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════

function Ocean:Window(config)
    config = config or {}
    local title    = config.Title    or "Ocean"
    local subtitle = config.Subtitle or ""
    local size     = config.Size     or Vector2.new(560, 400)
    local logo     = config.Logo     or nil   -- rbxassetid://...

    local T = self.Theme
    local root = self._root()

    -- cleanup old gui
    local old = root:FindFirstChild("OceanUI")
    if old then old:Destroy() end

    -- ── ScreenGui ──────────────────────────────────────
    local sg = make("ScreenGui", {
        Name           = "OceanUI",
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, root)

    -- ── Main window frame ──────────────────────────────
    local win = make("Frame", {
        Name             = "Window",
        BackgroundColor3 = T.Surface,
        Size             = UDim2.fromOffset(size.X, size.Y),
        Position         = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, sg)
    corner(win, 12)
    stroke(win, T.Border, 1.2)

    -- subtle inner gradient (top glow)
    local grad = make("UIGradient", {
        Color    = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(30, 50, 100)),
            ColorSequenceKeypoint.new(0.4, T.Surface),
            ColorSequenceKeypoint.new(1,   T.Surface),
        }),
        Rotation = 90,
    }, win)

    -- ── Titlebar ───────────────────────────────────────
    local titlebar = make("Frame", {
        Name             = "Titlebar",
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, 50),
        BorderSizePixel  = 0,
    }, win)
    corner(titlebar, 12)

    -- bottom fill to kill bottom corners of titlebar
    make("Frame", {
        BackgroundColor3 = T.Surface2,
        Position         = UDim2.new(0, 0, 1, -10),
        Size             = UDim2.new(1, 0, 0, 10),
        BorderSizePixel  = 0,
    }, titlebar)

    -- titlebar bottom border line
    make("Frame", {
        BackgroundColor3 = T.Border,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        BorderSizePixel  = 0,
    }, titlebar)

    -- logo / icon
    local logoX = 14
    if logo then
        make("ImageLabel", {
            Image            = logo,
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 12, 0.5, -11),
            Size             = UDim2.fromOffset(22, 22),
        }, titlebar)
        logoX = 42
    end

    -- title text
    make("TextLabel", {
        Text             = title,
        TextColor3       = T.TextPrimary,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, logoX, 0, 8),
        Size             = UDim2.new(0.5, 0, 0, 18),
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, titlebar)

    -- subtitle text
    if subtitle ~= "" then
        make("TextLabel", {
            Text             = subtitle,
            TextColor3       = T.TextDim,
            Font             = Enum.Font.Gotham,
            TextSize         = 11,
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, logoX, 0, 28),
            Size             = UDim2.new(0.5, 0, 0, 14),
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, titlebar)
    end

    -- close button
    local closeBtn = make("TextButton", {
        Text             = "✕",
        TextColor3       = T.TextDim,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        BackgroundColor3 = T.Surface3,
        Size             = UDim2.fromOffset(28, 28),
        Position         = UDim2.new(1, -38, 0.5, -14),
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, titlebar)
    corner(closeBtn, 7)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, fast, { BackgroundColor3 = T.Danger, TextColor3 = T.TextPrimary })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.TextDim })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(win, smooth, { BackgroundTransparency = 1 })
        task.wait(0.35)
        sg:Destroy()
    end)

    -- minimise button
    local minBtn = make("TextButton", {
        Text             = "─",
        TextColor3       = T.TextDim,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        BackgroundColor3 = T.Surface3,
        Size             = UDim2.fromOffset(28, 28),
        Position         = UDim2.new(1, -72, 0.5, -14),
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
    }, titlebar)
    corner(minBtn, 7)

    local minimised = false
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, fast, { BackgroundColor3 = T.AccentDark, TextColor3 = T.TextPrimary })
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, fast, { BackgroundColor3 = T.Surface3, TextColor3 = T.TextDim })
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            tween(win, smooth, { Size = UDim2.fromOffset(size.X, 50) })
        else
            tween(win, smooth, { Size = UDim2.fromOffset(size.X, size.Y) })
        end
    end)

    -- drag
    self._drag(titlebar, win)

    -- ── Tab bar (left sidebar) ─────────────────────────
    local sidebar = make("Frame", {
        Name             = "Sidebar",
        BackgroundColor3 = T.BG,
        Position         = UDim2.new(0, 0, 0, 50),
        Size             = UDim2.new(0, 130, 1, -50),
        BorderSizePixel  = 0,
    }, win)

    -- sidebar right border
    make("Frame", {
        BackgroundColor3 = T.Border,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BorderSizePixel  = 0,
    }, sidebar)

    local tabList = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 8),
        Size     = UDim2.new(1, 0, 1, -8),
    }, sidebar)
    make("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 4),
    }, tabList)
    padding(tabList, nil, 0, 0, 8, 8)

    -- ── Content area ──────────────────────────────────
    local contentArea = make("Frame", {
        Name             = "Content",
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 130, 0, 50),
        Size             = UDim2.new(1, -130, 1, -50),
        ClipsDescendants = true,
    }, win)

    -- ── Window object ─────────────────────────────────
    local W = {
        _gui        = sg,
        _win        = win,
        _sidebar    = sidebar,
        _tabList    = tabList,
        _content    = contentArea,
        _tabs       = {},
        _activeTab  = nil,
        _library    = self,
    }
    table.insert(self.Windows, sg)

    -- ── Tab method ────────────────────────────────────
    function W:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or nil  -- rbxassetid://...

        local T2 = self._library.Theme

        -- sidebar button
        local btn = make("TextButton", {
            Text             = (tabIcon and "  " or "") .. tabName,
            TextColor3       = T2.TextSub,
            Font             = Enum.Font.Gotham,
            TextSize         = 13,
            BackgroundColor3 = T2.BG,
            Size             = UDim2.new(1, 0, 0, 34),
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, self._tabList)
        corner(btn, 8)
        padding(btn, nil, 0, 0, tabIcon and 30 or 10, 6)

        if tabIcon then
            make("ImageLabel", {
                Image            = tabIcon,
                BackgroundTransparency = 1,
                Position         = UDim2.new(0, 8, 0.5, -8),
                Size             = UDim2.fromOffset(16, 16),
            }, btn)
        end

        -- active indicator bar
        local indicator = make("Frame", {
            BackgroundColor3 = T2.Accent,
            Position         = UDim2.new(0, 0, 0.15, 0),
            Size             = UDim2.new(0, 3, 0.7, 0),
            BorderSizePixel  = 0,
            Visible          = false,
        }, btn)
        corner(indicator, 3)

        -- tab content page
        local page = make("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 0, 0, 0),
            Size             = UDim2.new(1, 0, 1, 0),
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T2.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
        }, self._content)

        make("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
        }, page)
        padding(page, nil, 10, 10, 12, 12)

        local tab = {
            _btn       = btn,
            _page      = page,
            _indicator = indicator,
            _window    = self,
            _library   = self._library,
            _order     = 0,
        }
        table.insert(self._tabs, tab)

        -- activate on click
        btn.MouseButton1Click:Connect(function()
            self:_setTab(tab)
        end)

        btn.MouseEnter:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, fast, { BackgroundColor3 = T2.Surface3, TextColor3 = T2.TextPrimary })
            end
        end)
        btn.MouseLeave:Connect(function()
            if self._activeTab ~= tab then
                tween(btn, fast, { BackgroundColor3 = T2.BG, TextColor3 = T2.TextSub })
            end
        end)

        -- auto-activate first tab
        if #self._tabs == 1 then
            self:_setTab(tab)
        end

        -- add elements to this tab
        setmetatable(tab, { __index = self._library })
        tab._page = page
        return tab
    end

    function W:_setTab(tab)
        for _, t in ipairs(self._tabs) do
            t._page.Visible    = false
            t._indicator.Visible = false
            tween(t._btn, fast, {
                BackgroundColor3 = self._library.Theme.BG,
                TextColor3       = self._library.Theme.TextSub,
            })
        end
        self._activeTab = tab
        tab._page.Visible    = true
        tab._indicator.Visible = true
        tween(tab._btn, fast, {
            BackgroundColor3 = self._library.Theme.Surface3,
            TextColor3       = self._library.Theme.TextPrimary,
        })
    end

    -- open animation
    win.BackgroundTransparency = 1
    win.Size = UDim2.fromOffset(size.X * 0.92, size.Y * 0.92)
    tween(win, smooth, {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(size.X, size.Y),
    })

    return W
end

-- ══════════════════════════════════════════════════════
--  ELEMENTS  (Button · Toggle · Slider · Section · Label)
-- ══════════════════════════════════════════════════════

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
        LetterSpacing  = 2,
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

    local h = desc and 52 or 36

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, h),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    stroke(card, T.Border, 1)

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
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, desc and 8 or 0),
        Size           = UDim2.new(1, -80, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    if desc then
        make("TextLabel", {
            Text           = desc,
            TextColor3     = T.TextDim,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            BackgroundTransparency = 1,
            Position       = UDim2.new(0, 14, 0, 28),
            Size           = UDim2.new(1, -30, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped    = true,
        }, card)
    end

    -- arrow icon
    make("TextLabel", {
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
    end)
    btn.MouseLeave:Connect(function()
        tween(card, fast, { BackgroundColor3 = T.Surface2 })
        tween(strip, fast, { BackgroundColor3 = T.Accent })
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

    local h = desc and 52 or 36

    local card = make("Frame", {
        BackgroundColor3 = T.Surface2,
        Size             = UDim2.new(1, 0, 0, h),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    stroke(card, T.Border, 1)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
        BackgroundTransparency = 1,
        Position       = UDim2.new(0, 14, 0, desc and 8 or 0),
        Size           = UDim2.new(1, -80, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    if desc then
        make("TextLabel", {
            Text           = desc,
            TextColor3     = T.TextDim,
            Font           = Enum.Font.Gotham,
            TextSize       = 11,
            BackgroundTransparency = 1,
            Position       = UDim2.new(0, 14, 0, 28),
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
        Position         = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Size             = UDim2.fromOffset(14, 14),
        BorderSizePixel  = 0,
    }, track)
    corner(knob, 7)

    -- invisible hit button
    local btn = make("TextButton", {
        Text             = "",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        ZIndex           = 5,
    }, card)

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

    btn.MouseEnter:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface3 }) end)
    btn.MouseLeave:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface2 }) end)
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
    stroke(card, T.Border, 1)

    -- label row
    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
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
    local trackBG = make("Frame", {
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
    card.MouseEnter:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface3 }) end)
    card.MouseLeave:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface2 }) end)

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
        Size             = UDim2.new(1, 0, 0, 36),
        BorderSizePixel  = 0,
        ZIndex           = 10,
        ClipsDescendants = false,
    }, tab._page)
    corner(card, 8)
    stroke(card, T.Border, 1)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
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

    btn.MouseEnter:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface3 }) end)
    btn.MouseLeave:Connect(function() if not isOpen then tween(card, fast, { BackgroundColor3 = T.Surface2 }) end end)
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
    stroke(card, T.Border, 1)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
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
    end)
    inputBox.FocusLost:Connect(function(enter)
        tween(inputBG, fast, { BackgroundColor3 = T.BG })
        tween(inputStroke, fast, { Color = T.Border })
        if flag then self.Flags[flag] = inputBox.Text end
        if enter then
            local ok, err = pcall(callback, inputBox.Text)
            if not ok then warn("[Ocean:TextInput] " .. tostring(err)) end
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
        Size             = UDim2.new(1, 0, 0, 36),
        BorderSizePixel  = 0,
    }, tab._page)
    corner(card, 8)
    stroke(card, T.Border, 1)

    make("TextLabel", {
        Text           = text,
        TextColor3     = T.TextPrimary,
        Font           = Enum.Font.GothamBold,
        TextSize       = 13,
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

    card.MouseEnter:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface3 }) end)
    card.MouseLeave:Connect(function() tween(card, fast, { BackgroundColor3 = T.Surface2 }) end)

    return {
        Get = function(_) return currentKey end,
        Set = function(_, k)
            currentKey = k
            if flag then self.Flags[flag] = k end
            keyBtn.Text = "[" .. tostring(k.Name) .. "]"
        end,
    }
end

-- ─── Ready ────────────────────────────────────────────
print("[Ocean] Fully loaded ✓")

return Ocean
