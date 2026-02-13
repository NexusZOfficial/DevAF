--[[
    ◆ Frost UI Library ◆
    Simulated iOS Frosted Glass — No BlurEffect
    v5.0 — Production Ready
    
    local Frost = loadstring(...)()
    local Window = Frost:CreateWindow({ Title = "App" })
    local Tab = Window:CreateTab({ Name = "Main" })
]]

local Frost = {}
Frost.__index = Frost

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- THEME — Frosted glass simulation
-- All backgrounds are semi-transparent
-- Layered to create depth illusion
-- ═══════════════════════════════════════════
local T = {
    -- Window shell
    WinBg       = Color3.fromRGB(20, 20, 22),
    WinAlpha    = 0.18, -- see-through base

    -- Sidebar glass
    SideBg      = Color3.fromRGB(255, 255, 255),
    SideAlpha   = 0.94, -- very faint white = frosted

    -- Title bar glass
    TitleBg     = Color3.fromRGB(255, 255, 255),
    TitleAlpha  = 0.92,

    -- Content area
    ContentBg   = Color3.fromRGB(18, 18, 20),
    ContentAlpha = 0.35,

    -- Element cards — frosted glass panels
    CardBg      = Color3.fromRGB(255, 255, 255),
    CardAlpha   = 0.93,  -- subtle frosted white
    CardHAlpha  = 0.89,  -- hover state

    -- Text
    T1 = Color3.fromRGB(230, 230, 235),
    T2 = Color3.fromRGB(156, 156, 162),
    T3 = Color3.fromRGB(105, 105, 112),
    T4 = Color3.fromRGB(72, 72, 78),

    -- Accent
    Acc    = Color3.fromRGB(180, 180, 186),
    AccDim = Color3.fromRGB(120, 120, 128),

    -- Toggle
    TgOn  = Color3.fromRGB(180, 180, 186),
    TgOff = Color3.fromRGB(50, 50, 54),
    Knob  = Color3.fromRGB(255, 255, 255),

    -- Slider
    SFill  = Color3.fromRGB(160, 160, 168),
    STrack = Color3.fromRGB(44, 44, 48),

    -- Borders (very subtle)
    Brd     = Color3.fromRGB(255, 255, 255),
    BrdA    = 0.88, -- almost invisible
    Div     = Color3.fromRGB(255, 255, 255),
    DivA    = 0.92,

    -- Dropdown
    DBg   = Color3.fromRGB(38, 38, 42),
    DHov  = Color3.fromRGB(52, 52, 56),
    DSel  = Color3.fromRGB(62, 62, 66),

    -- Input
    IBg = Color3.fromRGB(34, 34, 38),

    -- Notif
    NBg   = Color3.fromRGB(32, 32, 36),
    NAlpha = 0.06,
    NSuc  = Color3.fromRGB(140, 180, 140),
    NErr  = Color3.fromRGB(180, 120, 120),
    NWrn  = Color3.fromRGB(180, 170, 120),
    NInf  = Color3.fromRGB(130, 150, 180),

    -- Scroll
    ScCol = Color3.fromRGB(80, 80, 86),
    ScA   = 0.6,

    -- Corners
    Cr   = UDim.new(0, 10),
    CrSm = UDim.new(0, 6),
    CrXs = UDim.new(0, 4),
    Pill = UDim.new(1, 0),

    -- Layout — COMPACT like real iOS
    SideW   = 140,
    TitleH  = 38,
    EH      = 32,   -- element height (compact!)
    EHL     = 42,   -- element with description
    EPad    = 3,     -- gap between elements
    CPad    = 8,     -- content padding
    Inn     = 10,    -- inner padding

    -- Resize
    MinW = 380, MinH = 260,
    MaxW = 800, MaxH = 600,
    ResH = 10,
}

-- ═══════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════
local U = {}

function U.new(c, p)
    local i = Instance.new(c)
    local par
    for k, v in pairs(p or {}) do
        if k == "Parent" then par = v else i[k] = v end
    end
    if par then i.Parent = par end
    return i
end

function U.tw(i, p, d, s)
    local t = TweenService:Create(i,
        TweenInfo.new(d or 0.18, s or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p)
    t:Play(); return t
end

function U.sp(i, p, d)
    return U.tw(i, p, d or 0.3, Enum.EasingStyle.Back)
end

function U.corner(p, r)
    return U.new("UICorner", {CornerRadius = r or T.Cr, Parent = p})
end

function U.stroke(p, c, th, a)
    return U.new("UIStroke", {
        Parent = p, Color = c or T.Brd,
        Thickness = th or 1, Transparency = a or T.BrdA,
    })
end

function U.pad(p, t, b, l, r)
    return U.new("UIPadding", {
        Parent = p,
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft = UDim.new(0, l or t or 0),
        PaddingRight = UDim.new(0, r or l or t or 0),
    })
end

function U.list(p, gap, dir)
    return U.new("UIListLayout", {
        Parent = p, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or T.EPad),
        FillDirection = dir or Enum.FillDirection.Vertical,
    })
end

function U.uid()
    return HttpService:GenerateGUID(false):sub(1, 8)
end

function U.ripple(p)
    local r = U.new("Frame", {
        Parent = p, BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.88, Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0.5,0.5),
        ZIndex = p.ZIndex + 5, BorderSizePixel = 0,
    })
    U.corner(r, UDim.new(1,0))
    local s = math.max(p.AbsoluteSize.X, p.AbsoluteSize.Y) * 2
    U.tw(r, {Size = UDim2.new(0,s,0,s), BackgroundTransparency = 1}, 0.4)
    task.delay(0.4, function() r:Destroy() end)
end

-- ═══════════════════════════════════════════
-- FROSTED GLASS PANEL
-- Creates the layered frosted look:
-- 1. Base semi-transparent dark
-- 2. White overlay at ~94% transparency
-- 3. Top edge highlight at ~97%
-- 4. Very faint border
-- ═══════════════════════════════════════════
local function frost(props)
    local f = U.new("Frame", {
        Name = props.Name or "frost",
        Parent = props.Parent,
        BackgroundColor3 = props.Dark or T.WinBg,
        BackgroundTransparency = props.DarkAlpha or 0.4,
        Size = props.Size or UDim2.new(1, 0, 0, T.EH),
        Position = props.Pos or UDim2.new(0,0,0,0),
        AnchorPoint = props.Anchor or Vector2.new(0,0),
        ClipsDescendants = props.Clip ~= false,
        LayoutOrder = props.Order or 0,
        ZIndex = props.Z or 10,
        BorderSizePixel = 0,
    })

    -- Frosted white overlay
    local overlay = U.new("Frame", {
        Name = "_glass",
        Parent = f,
        BackgroundColor3 = props.Glass or T.CardBg,
        BackgroundTransparency = props.GlassAlpha or T.CardAlpha,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = f.ZIndex,
        BorderSizePixel = 0,
    })
    U.corner(overlay, props.Corner or T.CrSm)

    -- Top edge shine
    U.new("Frame", {
        Name = "_shine",
        Parent = f,
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 0, 0),
        ZIndex = f.ZIndex + 1,
        BorderSizePixel = 0,
    })

    -- Gradient on overlay for depth
    U.new("UIGradient", {
        Parent = overlay,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 224)),
        }),
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, props.GlassAlpha or T.CardAlpha),
            NumberSequenceKeypoint.new(1, (props.GlassAlpha or T.CardAlpha) - 0.01),
        }),
    })

    U.corner(f, props.Corner or T.CrSm)
    U.stroke(f, T.Brd, 1, props.BrdAlpha or 0.85)

    return f, overlay
end

-- ═══════════════════════════════════════════
-- NOTIFICATION
-- ═══════════════════════════════════════════
local Notifs = {}
Notifs.__index = Notifs

function Notifs.init(gui)
    local self = setmetatable({}, Notifs)
    self.C = U.new("Frame", {
        Name = "N", Parent = gui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.new(0, 260, 1, -24),
        AnchorPoint = Vector2.new(1, 0), ZIndex = 500,
    })
    U.list(self.C, 5)
    return self
end

function Notifs:Push(cfg)
    cfg = cfg or {}
    local typ = cfg.Type or "Info"
    local dur = cfg.Duration or 3
    local ac = T.NInf
    if typ == "Success" then ac = T.NSuc
    elseif typ == "Error" then ac = T.NErr
    elseif typ == "Warning" then ac = T.NWrn end
    local icons = {Success="✓", Error="✕", Warning="!", Info="·"}

    local nf, _ = frost({
        Name = "nf", Parent = self.C,
        Size = UDim2.new(1, 0, 0, 0),
        Dark = T.NBg, DarkAlpha = T.NAlpha,
        Glass = Color3.fromRGB(40, 40, 44), GlassAlpha = 0.12,
        Z = 501, Corner = T.CrSm,
    })
    nf.AutomaticSize = Enum.AutomaticSize.Y

    -- Accent pip
    U.new("Frame", {
        Parent = nf, BackgroundColor3 = ac, BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 2, 1, -6), Position = UDim2.new(0, 3, 0, 3),
        BorderSizePixel = 0, ZIndex = 502,
    })

    local c = U.new("Frame", {
        Parent = nf, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 502,
    })
    U.pad(c, 8, 8, 14, 6)
    U.list(c, 2)

    local tr = U.new("Frame", {
        Parent = c, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 1, ZIndex = 503,
    })
    local ic = U.new("Frame", {
        Parent = tr, BackgroundColor3 = ac, BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 504,
    })
    U.corner(ic, UDim.new(1,0))
    U.new("TextLabel", {
        Parent = ic, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = icons[typ] or "·",
        TextColor3 = ac, TextSize = 8, Font = Enum.Font.GothamBold, ZIndex = 505,
    })

    U.new("TextLabel", {
        Parent = tr, BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -34, 1, 0),
        Text = cfg.Title or "", TextColor3 = T.T1, TextSize = 11,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 504,
    })

    local cl = U.new("TextButton", {
        Parent = tr, BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0, 0.5), Text = "✕",
        TextColor3 = T.T4, TextSize = 8, Font = Enum.Font.GothamBold, ZIndex = 504,
    })

    if cfg.Message and cfg.Message ~= "" then
        U.new("TextLabel", {
            Parent = c, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            Text = cfg.Message, TextColor3 = T.T3, TextSize = 10,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, LayoutOrder = 2, ZIndex = 504,
        })
    end

    local prog = U.new("Frame", {
        Parent = nf, BackgroundColor3 = ac, BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0, ZIndex = 503,
    })

    nf.Position = UDim2.new(1, 14, 0, 0)
    U.tw(nf, {Position = UDim2.new(0,0,0,0)}, 0.3)
    U.tw(prog, {Size = UDim2.new(0,0,0,1)}, dur, Enum.EasingStyle.Linear)

    local function dismiss()
        U.tw(nf, {Position = UDim2.new(1, 14, 0, 0), BackgroundTransparency = 1}, 0.2)
        task.delay(0.2, function() if nf.Parent then nf:Destroy() end end)
    end
    cl.MouseButton1Click:Connect(dismiss)
    cl.MouseEnter:Connect(function() U.tw(cl, {TextColor3 = T.T1}, 0.1) end)
    cl.MouseLeave:Connect(function() U.tw(cl, {TextColor3 = T.T4}, 0.1) end)
    task.delay(dur, function() if nf and nf.Parent then dismiss() end end)
end

-- ═══════════════════════════════════════════
-- TOOLTIP
-- ═══════════════════════════════════════════
local Tip = {}
Tip.__index = Tip

function Tip.init(gui)
    local self = setmetatable({}, Tip)
    self.F = U.new("Frame", {
        Parent = gui, BackgroundColor3 = T.NBg,
        BackgroundTransparency = 0.04,
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false, ZIndex = 600,
    })
    U.corner(self.F, T.CrXs)
    U.stroke(self.F, T.Brd, 1, 0.7)
    U.pad(self.F, 4, 4, 7, 7)
    self.L = U.new("TextLabel", {
        Parent = self.F, BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        TextColor3 = T.T2, TextSize = 10, Font = Enum.Font.Gotham,
        TextWrapped = true, ZIndex = 601,
    })
    U.new("UISizeConstraint", {Parent = self.F, MaxSize = Vector2.new(180, 100)})
    RunService.RenderStepped:Connect(function()
        if self.F.Visible then
            local m = UIS:GetMouseLocation()
            self.F.Position = UDim2.new(0, m.X+10, 0, m.Y+4)
        end
    end)
    return self
end

function Tip:Show(t)
    self.L.Text = t; self.F.Visible = true
    self.F.BackgroundTransparency = 1; self.L.TextTransparency = 1
    U.tw(self.F, {BackgroundTransparency = 0.04}, 0.1)
    U.tw(self.L, {TextTransparency = 0}, 0.1)
end

function Tip:Hide()
    U.tw(self.F, {BackgroundTransparency = 1}, 0.08)
    U.tw(self.L, {TextTransparency = 1}, 0.08)
    task.delay(0.08, function() self.F.Visible = false end)
end

-- ═══════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab._new(w, cfg)
    local self = setmetatable({}, Tab)
    self._w = w; self.Name = cfg.Name or "Tab"
    self.Icon = cfg.Icon; self._el = {}; self._vis = false
    self._ord = #w._tabs + 1

    self._btn = U.new("TextButton", {
        Parent = w._tl, BackgroundColor3 = T.SideBg,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        Text = "", AutoButtonColor = false,
        LayoutOrder = self._ord, ZIndex = 20,
    })
    U.corner(self._btn, T.CrSm)

    self._ind = U.new("Frame", {
        Parent = self._btn, BackgroundColor3 = T.Acc,
        Size = UDim2.new(0, 2, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0, ZIndex = 22,
    })
    U.corner(self._ind, UDim.new(0, 1))

    local xo = 8
    if self.Icon then
        self._ic = U.new("ImageLabel", {
            Parent = self._btn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, 0),
            Size = UDim2.new(0, 13, 0, 13),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = self.Icon, ImageColor3 = T.T3, ZIndex = 21,
        })
        xo = 26
    end

    self._lbl = U.new("TextLabel", {
        Parent = self._btn, BackgroundTransparency = 1,
        Position = UDim2.new(0, xo, 0, 0),
        Size = UDim2.new(1, -(xo+6), 1, 0),
        Text = self.Name, TextColor3 = T.T3,
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 21,
    })

    self._cf = U.new("ScrollingFrame", {
        Parent = w._ca, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.ScCol,
        ScrollBarImageTransparency = T.ScA,
        BorderSizePixel = 0, Visible = false, ZIndex = 10,
        TopImage = "rbxassetid://7766642408",
        MidImage = "rbxassetid://7766642408",
        BottomImage = "rbxassetid://7766642408",
    })
    U.pad(self._cf, T.CPad, 12, T.CPad, T.CPad)
    U.list(self._cf, T.EPad)

    self._btn.MouseEnter:Connect(function()
        if not self._vis then U.tw(self._btn, {BackgroundTransparency = 0.8}, 0.1) end
    end)
    self._btn.MouseLeave:Connect(function()
        if not self._vis then U.tw(self._btn, {BackgroundTransparency = 1}, 0.12) end
    end)
    self._btn.MouseButton1Click:Connect(function() w:SelectTab(self) end)
    return self
end

function Tab:_show()
    self._vis = true; self._cf.Visible = true
    self._cf.CanvasPosition = Vector2.new(0,0)
    U.tw(self._btn, {BackgroundTransparency = 0.75}, 0.15)
    U.tw(self._lbl, {TextColor3 = T.T1}, 0.15)
    U.sp(self._ind, {Size = UDim2.new(0, 2, 0, 12)}, 0.25)
    if self._ic then U.tw(self._ic, {ImageColor3 = T.Acc}, 0.15) end
end

function Tab:_hide()
    self._vis = false; self._cf.Visible = false
    U.tw(self._btn, {BackgroundTransparency = 1}, 0.15)
    U.tw(self._lbl, {TextColor3 = T.T3}, 0.15)
    U.tw(self._ind, {Size = UDim2.new(0, 2, 0, 0)}, 0.12)
    if self._ic then U.tw(self._ic, {ImageColor3 = T.T3}, 0.15) end
end

-- ═══════════════════════════════════════════
-- ELEMENTS
-- ═══════════════════════════════════════════

function Tab:AddLabel(cfg)
    cfg = cfg or {}; local o = #self._el + 1
    local f = U.new("Frame", {
        Parent = self._cf, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,14), LayoutOrder = o, ZIndex = 10,
    })
    local l = U.new("TextLabel", {
        Parent = f, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
        Text = cfg.Text or "", TextColor3 = T.T4, TextSize = 10,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    local a = {SetText = function(_,t) l.Text = t end, Destroy = function() f:Destroy() end}
    table.insert(self._el, a); return a
end

function Tab:AddSection(cfg)
    cfg = cfg or {}; local o = #self._el + 1
    local f = U.new("Frame", {
        Parent = self._cf, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0, o == 1 and 14 or 22),
        LayoutOrder = o, ZIndex = 10,
    })
    local l = U.new("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0,0,1,-12), Size = UDim2.new(1,0,0,12),
        Text = string.upper(cfg.Name or ""), TextColor3 = T.T4,
        TextSize = 9, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    local a = {SetText = function(_,t) l.Text = string.upper(t) end}
    table.insert(self._el, a); return a
end

function Tab:AddSeparator()
    local o = #self._el + 1
    local f = U.new("Frame", {
        Parent = self._cf, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,4), LayoutOrder = o, ZIndex = 10,
    })
    U.new("Frame", {
        Parent = f, BackgroundColor3 = T.Div, BackgroundTransparency = T.DivA,
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0.5,0),
        AnchorPoint = Vector2.new(0,0.5), BorderSizePixel = 0, ZIndex = 11,
    })
    table.insert(self._el, {}); return {}
end

function Tab:AddButton(cfg)
    cfg = cfg or {}; local cb = cfg.Callback or function() end; local o = #self._el + 1
    local hd = cfg.Description and cfg.Description ~= ""
    local h = hd and T.EHL or T.EH

    local card = frost({
        Parent = self._cf, Size = UDim2.new(1,0,0,h),
        Order = o, Z = 10,
    })

    local nl = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, hd and 5 or 0),
        Size = UDim2.new(1, -(T.Inn*2+16), 0, hd and 16 or h),
        Text = cfg.Name or "Button", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 22),
            Size = UDim2.new(1, -(T.Inn*2+16), 0, 13),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local ch = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(1, -(T.Inn+4), 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0, 0.5),
        Text = "›", TextColor3 = T.T4, TextSize = 14,
        Font = Enum.Font.GothamBold, ZIndex = 12,
    })

    local glass = card:FindFirstChild("_glass")
    local btn = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", ZIndex = 15,
    })
    btn.MouseEnter:Connect(function()
        if glass then U.tw(glass, {BackgroundTransparency = T.CardHAlpha}, 0.1) end
        U.tw(ch, {TextColor3 = T.Acc, Position = UDim2.new(1, -(T.Inn+2), 0.5, 0)}, 0.1)
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    btn.MouseLeave:Connect(function()
        if glass then U.tw(glass, {BackgroundTransparency = T.CardAlpha}, 0.12) end
        U.tw(ch, {TextColor3 = T.T4, Position = UDim2.new(1, -(T.Inn+4), 0.5, 0)}, 0.12)
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    btn.MouseButton1Click:Connect(function()
        U.ripple(card)
        if glass then
            U.tw(glass, {BackgroundTransparency = 0.82}, 0.05)
            task.delay(0.08, function() U.tw(glass, {BackgroundTransparency = T.CardAlpha}, 0.15) end)
        end
        task.spawn(cb)
    end)

    local a = {
        SetName = function(_,t) nl.Text = t end,
        SetCallback = function(_,c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

function Tab:AddToggle(cfg)
    cfg = cfg or {}; local state = cfg.Default or false
    local cb = cfg.Callback or function() end; local o = #self._el + 1
    local hd = cfg.Description and cfg.Description ~= ""
    local h = hd and T.EHL or T.EH

    local card = frost({
        Parent = self._cf, Size = UDim2.new(1,0,0,h), Order = o, Z = 10,
    })
    local glass = card:FindFirstChild("_glass")

    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, hd and 5 or 0),
        Size = UDim2.new(1, -(T.Inn*2+48), 0, hd and 16 or h),
        Text = cfg.Name or "Toggle", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 22),
            Size = UDim2.new(1, -(T.Inn*2+48), 0, 13),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local sw = U.new("Frame", {
        Parent = card, BackgroundColor3 = state and T.TgOn or T.TgOff,
        Position = UDim2.new(1, -(T.Inn+38), 0.5, 0),
        Size = UDim2.new(0, 38, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 12,
    })
    U.corner(sw, UDim.new(1,0))

    local knob = U.new("Frame", {
        Parent = sw, BackgroundColor3 = T.Knob,
        Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
    })
    U.corner(knob, UDim.new(1,0))

    local function set(s, skip)
        state = s
        U.tw(sw, {BackgroundColor3 = state and T.TgOn or T.TgOff}, 0.15)
        U.sp(knob, {Position = state and UDim2.new(1,-20,0.5,0) or UDim2.new(0,2,0.5,0)}, 0.22)
        U.tw(knob, {Size = UDim2.new(0,22,0,18)}, 0.05)
        task.delay(0.05, function() U.sp(knob, {Size = UDim2.new(0,18,0,18)}, 0.18) end)
        if not skip then task.spawn(cb, state) end
    end

    local cl = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", ZIndex = 15,
    })
    cl.MouseEnter:Connect(function()
        if glass then U.tw(glass, {BackgroundTransparency = T.CardHAlpha}, 0.1) end
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    cl.MouseLeave:Connect(function()
        if glass then U.tw(glass, {BackgroundTransparency = T.CardAlpha}, 0.12) end
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    cl.MouseButton1Click:Connect(function() set(not state) end)
    if state then task.spawn(cb, true) end

    local a = {
        GetState = function() return state end,
        SetState = function(_,s,sk) set(s,sk) end,
        SetCallback = function(_,c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

function Tab:AddSlider(cfg)
    cfg = cfg or {}; local mn, mx = cfg.Min or 0, cfg.Max or 100
    local val = math.clamp(cfg.Default or mn, mn, mx)
    local inc = cfg.Increment or 1; local suf = cfg.Suffix or ""
    local cb = cfg.Callback or function() end; local o = #self._el + 1
    local drag = false; local hd = cfg.Description and cfg.Description ~= ""
    local h = hd and 54 or 44

    local card = frost({
        Parent = self._cf, Size = UDim2.new(1,0,0,h), Order = o, Z = 10,
    })
    local glass = card:FindFirstChild("_glass")

    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, 5),
        Size = UDim2.new(0.55, -T.Inn, 0, 14),
        Text = cfg.Name or "Slider", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 19),
            Size = UDim2.new(0.55, -T.Inn, 0, 11),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local vl = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0.55, 0, 0, 5),
        Size = UDim2.new(0.45, -T.Inn, 0, 14),
        Text = tostring(val)..suf, TextColor3 = T.Acc,
        TextSize = 12, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    })

    local tY = hd and 36 or 28
    local track = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.STrack,
        Position = UDim2.new(0, T.Inn, 0, tY),
        Size = UDim2.new(1, -(T.Inn*2), 0, 3),
        ZIndex = 12,
    })
    U.corner(track, UDim.new(1,0))

    local pct = (val-mn)/(mx-mn)
    local fill = U.new("Frame", {
        Parent = track, BackgroundColor3 = T.SFill,
        Size = UDim2.new(pct,0,1,0), ZIndex = 13,
    })
    U.corner(fill, UDim.new(1,0))

    local knob = U.new("Frame", {
        Parent = track, BackgroundColor3 = T.Knob,
        Position = UDim2.new(pct,0,0.5,0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 15,
    })
    U.corner(knob, UDim.new(1,0))
    U.stroke(knob, T.Brd, 1, 0.8)

    local function rnd(v) return math.floor(v/inc+0.5)*inc end
    local function upd(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        val = math.clamp(rnd(mn+(mx-mn)*p), mn, mx)
        local dp = (val-mn)/(mx-mn)
        U.tw(fill, {Size = UDim2.new(dp,0,1,0)}, 0.03, Enum.EasingStyle.Quad)
        U.tw(knob, {Position = UDim2.new(dp,0,0.5,0)}, 0.03, Enum.EasingStyle.Quad)
        vl.Text = tostring(val)..suf
        task.spawn(cb, val)
    end

    local ca = U.new("TextButton", {
        Parent = track, BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 0, 18),
        Position = UDim2.new(0, -5, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "", ZIndex = 16,
    })
    ca.MouseButton1Down:Connect(function()
        drag = true; U.sp(knob, {Size = UDim2.new(0,16,0,16)}, 0.15)
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            drag = false; U.sp(knob, {Size = UDim2.new(0,12,0,12)}, 0.15)
        end
    end)
    card.MouseEnter:Connect(function()
        if not drag and glass then U.tw(glass, {BackgroundTransparency = T.CardHAlpha}, 0.1) end
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    card.MouseLeave:Connect(function()
        if not drag and glass then U.tw(glass, {BackgroundTransparency = T.CardAlpha}, 0.12) end
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    if val ~= mn then task.spawn(cb, val) end

    local a = {
        GetValue = function() return val end,
        SetValue = function(_,v,sk)
            val = math.clamp(rnd(v),mn,mx); local dp=(val-mn)/(mx-mn)
            U.tw(fill,{Size=UDim2.new(dp,0,1,0)},0.2)
            U.tw(knob,{Position=UDim2.new(dp,0,0.5,0)},0.2)
            vl.Text=tostring(val)..suf; if not sk then task.spawn(cb,val) end
        end,
        SetCallback = function(_,c) cb=c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

function Tab:AddDropdown(cfg)
    cfg = cfg or {}; local opts = cfg.Options or {}
    local multi = cfg.MultiSelect or false
    local cb = cfg.Callback or function() end; local o = #self._el + 1
    local isOpen = false
    local sel; if multi then sel = {}; if cfg.Default and type(cfg.Default)=="table" then for _,v in ipairs(cfg.Default) do sel[v]=true end end else sel = cfg.Default end
    local hd = cfg.Description and cfg.Description ~= ""
    local hH = hd and T.EHL or T.EH

    local card = frost({Parent = self._cf, Size = UDim2.new(1,0,0,hH), Order = o, Z = 10, Clip = true})
    local glass = card:FindFirstChild("_glass")
    local cs = card:FindFirstChildOfClass("UIStroke")

    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, hd and 5 or 0),
        Size = UDim2.new(0.38, -T.Inn, 0, hd and 16 or hH),
        Text = cfg.Name or "Dropdown", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 22),
            Size = UDim2.new(0.38, -T.Inn, 0, 13),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local function dt()
        if multi then
            local it={}; for k,v in pairs(sel) do if v then table.insert(it,k) end end
            if #it==0 then return "None" end; if #it<=2 then return table.concat(it,", ") end
            return it[1].." +"..#it-1
        end; return sel or "Select..."
    end

    local pill = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.DBg,
        Position = UDim2.new(0.38, 2, 0, (hH-20)/2),
        Size = UDim2.new(0.62, -(T.Inn+18), 0, 20), ZIndex = 12,
    })
    U.corner(pill, T.CrXs)
    local sl = U.new("TextLabel", {
        Parent = pill, BackgroundTransparency = 1,
        Size = UDim2.new(1,-8,1,0), Position = UDim2.new(0,4,0,0),
        Text = dt(), TextColor3 = T.T2, TextSize = 10,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
    })
    local chev = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(1, -(T.Inn+6), 0, (hH-12)/2),
        Size = UDim2.new(0,12,0,12), Text = "▾", TextColor3 = T.T4,
        TextSize = 10, Font = Enum.Font.GothamBold, Rotation = 0, ZIndex = 12,
    })

    local oc = U.new("Frame", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0,0,0,hH),
        Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 11,
    })
    U.pad(oc, 1, 4, 4, 4); U.list(oc, 1)

    local ofs = {}
    local function tog()
        isOpen = not isOpen
        local oH = math.min(#opts*22+6, 140)
        if isOpen then
            U.tw(card, {Size = UDim2.new(1,0,0,hH+oH)}, 0.2)
            U.tw(chev, {Rotation = 180}, 0.15)
            if cs then U.tw(cs, {Transparency = 0.6}, 0.15) end
        else
            U.tw(card, {Size = UDim2.new(1,0,0,hH)}, 0.18)
            U.tw(chev, {Rotation = 0}, 0.15)
            if cs then U.tw(cs, {Transparency = T.BrdA}, 0.15) end
        end
    end

    local function mkOpt(tx, idx)
        local is = multi and sel[tx] or sel == tx
        local of = U.new("Frame", {
            Parent = oc, BackgroundColor3 = is and T.DSel or T.DBg,
            Size = UDim2.new(1,0,0,20), LayoutOrder = idx, ZIndex = 12,
        })
        U.corner(of, T.CrXs)
        local ol = U.new("TextLabel", {
            Name="L", Parent = of, BackgroundTransparency = 1,
            Position = UDim2.new(0,6,0,0), Size = UDim2.new(1,-24,1,0),
            Text = tx, TextColor3 = is and T.T1 or T.T2,
            TextSize = 11, Font = is and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
        })
        local ck = U.new("TextLabel", {
            Name="C", Parent = of, BackgroundTransparency = 1,
            Position = UDim2.new(1,-18,0.5,0), Size = UDim2.new(0,12,0,12),
            AnchorPoint = Vector2.new(0,0.5), Text = is and "✓" or "",
            TextColor3 = T.Acc, TextSize = 10, Font = Enum.Font.GothamBold, ZIndex = 13,
        })
        local ob = U.new("TextButton", {
            Parent = of, BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0), Text = "", ZIndex = 14,
        })
        ob.MouseEnter:Connect(function() U.tw(of, {BackgroundColor3 = T.DHov}, 0.08) end)
        ob.MouseLeave:Connect(function()
            local cs2 = multi and sel[tx] or sel == tx
            U.tw(of, {BackgroundColor3 = cs2 and T.DSel or T.DBg}, 0.1)
        end)
        ob.MouseButton1Click:Connect(function()
            if multi then
                sel[tx] = not sel[tx]; local now = sel[tx]
                U.tw(of, {BackgroundColor3 = now and T.DSel or T.DBg}, 0.1)
                ol.Font = now and Enum.Font.GothamBold or Enum.Font.GothamMedium
                U.tw(ol, {TextColor3 = now and T.T1 or T.T2}, 0.1)
                ck.Text = now and "✓" or ""
                sl.Text = dt()
                local r={}; for k,v in pairs(sel) do if v then table.insert(r,k) end end
                task.spawn(cb, r)
            else
                for _,fr in ipairs(ofs) do
                    local l2=fr.Frame:FindFirstChild("L"); local c2=fr.Frame:FindFirstChild("C")
                    U.tw(fr.Frame, {BackgroundColor3=T.DBg}, 0.1)
                    if l2 then l2.Font=Enum.Font.GothamMedium; U.tw(l2,{TextColor3=T.T2},0.1) end
                    if c2 then c2.Text="" end
                end
                sel = tx; U.tw(of, {BackgroundColor3=T.DSel}, 0.1)
                ol.Font=Enum.Font.GothamBold; U.tw(ol,{TextColor3=T.T1},0.1); ck.Text="✓"
                sl.Text = dt(); task.spawn(cb, sel)
                task.delay(0.08, function() if isOpen then tog() end end)
            end
        end)
        table.insert(ofs, {Frame=of, Text=tx})
    end
    for i,op in ipairs(opts) do mkOpt(op, i) end

    local hb = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,hH), Text = "", ZIndex = 15,
    })
    hb.MouseButton1Click:Connect(tog)
    hb.MouseEnter:Connect(function()
        if not isOpen and glass then U.tw(glass, {BackgroundTransparency = T.CardHAlpha}, 0.1) end
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    hb.MouseLeave:Connect(function()
        if not isOpen and glass then U.tw(glass, {BackgroundTransparency = T.CardAlpha}, 0.12) end
        if cfg.Tooltip then self._w._tip:Hide() end
    end)

    local a = {
        GetSelected = function()
            if multi then local r={}; for k,v in pairs(sel) do if v then table.insert(r,k) end end; return r end; return sel
        end,
        SetSelected = function(_,v,sk)
            if multi then sel={}; if type(v)=="table" then for _,x in ipairs(v) do sel[x]=true end end else sel=v end
            sl.Text=dt(); if not sk then if multi then local r={}; for k,s in pairs(sel) do if s then table.insert(r,k) end end; task.spawn(cb,r) else task.spawn(cb,sel) end end
        end,
        Refresh = function(_,no,keep)
            opts=no; for _,fr in ipairs(ofs) do fr.Frame:Destroy() end; ofs={}
            if not keep then sel=multi and {} or nil; sl.Text=dt() end
            for i,op in ipairs(opts) do mkOpt(op,i) end
            if isOpen then local oH=math.min(#opts*22+6,140); card.Size=UDim2.new(1,0,0,hH+oH) end
        end,
        SetCallback = function(_,c) cb=c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

function Tab:AddInput(cfg)
    cfg = cfg or {}; local cb = cfg.Callback or function() end
    local chCb = cfg.Changed; local num = cfg.Numeric or false; local o = #self._el + 1
    local hd = cfg.Description and cfg.Description ~= ""
    local h = hd and T.EHL or T.EH

    local card = frost({Parent = self._cf, Size = UDim2.new(1,0,0,h), Order = o, Z = 10})

    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, hd and 5 or 0),
        Size = UDim2.new(0.35, -T.Inn, 0, hd and 16 or h),
        Text = cfg.Name or "Input", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 22),
            Size = UDim2.new(0.35, -T.Inn, 0, 13),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local ic = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.IBg,
        Position = UDim2.new(0.35, 2, 0.5, 0),
        Size = UDim2.new(0.65, -(T.Inn+2), 0, 22),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 12,
    })
    U.corner(ic, T.CrXs)
    local iS = U.stroke(ic, T.Brd, 1, 0.8)

    local tb = U.new("TextBox", {
        Parent = ic, BackgroundTransparency = 1,
        Size = UDim2.new(1,-8,1,0), Position = UDim2.new(0,4,0,0),
        Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "...",
        PlaceholderColor3 = T.T4, TextColor3 = T.T1,
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = cfg.ClearOnFocus or false,
        ClipsDescendants = true, ZIndex = 13,
    })
    tb.Focused:Connect(function() U.tw(iS, {Color = T.AccDim, Transparency = 0.3}, 0.1) end)
    tb.FocusLost:Connect(function(enter)
        U.tw(iS, {Color = T.Brd, Transparency = 0.8}, 0.12)
        local t = tb.Text; if num then t = tonumber(t) or 0; tb.Text = tostring(t) end
        if enter then task.spawn(cb, t) end
    end)
    if chCb then tb:GetPropertyChangedSignal("Text"):Connect(function()
        if num then local cl = tb.Text:gsub("[^%d%.%-]",""); if cl ~= tb.Text then tb.Text = cl end end
        task.spawn(chCb, tb.Text)
    end) end

    local a = {
        GetValue = function() return tb.Text end,
        SetValue = function(_,v) tb.Text = tostring(v) end,
        SetCallback = function(_,c) cb=c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

function Tab:AddKeybind(cfg)
    cfg = cfg or {}; local key = cfg.Default or Enum.KeyCode.Unknown
    local cb = cfg.Callback or function() end
    local chCb = cfg.Changed or function() end
    local listening = false; local o = #self._el + 1
    local hd = cfg.Description and cfg.Description ~= ""
    local h = hd and T.EHL or T.EH

    local card = frost({Parent = self._cf, Size = UDim2.new(1,0,0,h), Order = o, Z = 10})

    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inn, 0, hd and 5 or 0),
        Size = UDim2.new(0.6, -T.Inn, 0, hd and 16 or h),
        Text = cfg.Name or "Keybind", TextColor3 = T.T1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    })
    if hd then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inn, 0, 22),
            Size = UDim2.new(0.6, -T.Inn, 0, 13),
            Text = cfg.Description, TextColor3 = T.T3, TextSize = 9,
            Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
        })
    end

    local function kn(k) if k==Enum.KeyCode.Unknown then return "None" end; return k.Name:gsub("Left","L"):gsub("Right","R"):gsub("Control","Ctrl"):gsub("Shift","Shft") end

    local kb = U.new("TextButton", {
        Parent = card, BackgroundColor3 = T.DBg,
        Position = UDim2.new(1, -T.Inn, 0.5, 0),
        Size = UDim2.new(0,0,0,20), AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(1, 0.5), Text = "", AutoButtonColor = false, ZIndex = 12,
    })
    U.corner(kb, T.CrXs); U.pad(kb, 0, 0, 7, 7)
    local kS = U.stroke(kb, T.Brd, 1, 0.7)

    local kl = U.new("TextLabel", {
        Parent = kb, BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0,0,1,0), Text = kn(key),
        TextColor3 = T.T2, TextSize = 10, Font = Enum.Font.GothamBold, ZIndex = 13,
    })

    kb.MouseEnter:Connect(function() U.tw(kS, {Color=T.AccDim, Transparency=0.4}, 0.08) end)
    kb.MouseLeave:Connect(function() if not listening then U.tw(kS, {Color=T.Brd, Transparency=0.7}, 0.1) end end)
    kb.MouseButton1Click:Connect(function()
        listening = true; kl.Text = "..."
        U.tw(kb, {BackgroundColor3 = T.AccDim}, 0.1)
        U.tw(kl, {TextColor3 = T.T1}, 0.1)
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or input.KeyCode
                listening = false; kl.Text = kn(key)
                U.tw(kb, {BackgroundColor3=T.DBg}, 0.12)
                U.tw(kl, {TextColor3=T.T2}, 0.12)
                U.tw(kS, {Color=T.Brd, Transparency=0.7}, 0.12)
                task.spawn(chCb, key)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and not gp then
            if input.KeyCode == key then task.spawn(cb) end
        end
    end)

    local a = {
        GetKey = function() return key end,
        SetKey = function(_,k) key=k; kl.Text=kn(k) end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._el, a); return a
end

-- ═══════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window._new(cfg)
    local self = setmetatable({}, Window)
    self._title = cfg.Title or "Frost"
    self._sub = cfg.Subtitle or ""
    self._size = cfg.Size or UDim2.new(0, 480, 0, 320)
    self._tabs = {}; self._active = nil; self._min = false; self._vis = true

    local par = Player:WaitForChild("PlayerGui")
    pcall(function() if syn and syn.protect_gui then par = CoreGui end end)
    self._gui = U.new("ScreenGui", {
        Name = "Frost_"..U.uid(), Parent = par,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false, DisplayOrder = 999,
    })
    pcall(function() if syn then syn.protect_gui(self._gui) end end)

    -- Main frame
    self._m = U.new("Frame", {
        Parent = self._gui,
        BackgroundColor3 = T.WinBg,
        BackgroundTransparency = T.WinAlpha,
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true, ZIndex = 1,
    })
    U.corner(self._m, UDim.new(0, 10))
    U.stroke(self._m, T.Brd, 1, 0.6)

    -- Frosted background overlay on entire window
    U.new("Frame", {
        Parent = self._m,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1, BorderSizePixel = 0,
    })

    -- ═══ TITLE BAR ═══
    self._tb = U.new("Frame", {
        Parent = self._m, BackgroundColor3 = T.TitleBg,
        BackgroundTransparency = T.TitleAlpha,
        Size = UDim2.new(1, 0, 0, T.TitleH),
        BorderSizePixel = 0, ZIndex = 30,
    })
    U.corner(self._tb, UDim.new(0, 10))
    U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.TitleBg,
        BackgroundTransparency = T.TitleAlpha,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BorderSizePixel = 0, ZIndex = 30,
    })
    -- Shine
    U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.94,
        Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 2, 0, 0),
        BorderSizePixel = 0, ZIndex = 31,
    })
    -- Divider
    U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.Div,
        BackgroundTransparency = T.DivA,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0, ZIndex = 31,
    })

    -- Icon
    local ai = U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.AccDim,
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 32,
    })
    U.corner(ai, UDim.new(0, 5))
    U.new("TextLabel", {
        Parent = ai, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Text = self._title:sub(1,1):upper(),
        TextColor3 = T.T1, TextSize = 11,
        Font = Enum.Font.GothamBold, ZIndex = 33,
    })

    U.new("TextLabel", {
        Parent = self._tb, BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, self._sub ~= "" and 4 or 0),
        Size = UDim2.new(0.5, -38, 0, self._sub ~= "" and 15 or T.TitleH),
        Text = self._title, TextColor3 = T.T1,
        TextSize = 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
    })
    if self._sub ~= "" then
        U.new("TextLabel", {
            Parent = self._tb, BackgroundTransparency = 1,
            Position = UDim2.new(0, 38, 0, 20),
            Size = UDim2.new(0.5, -38, 0, 11),
            Text = self._sub, TextColor3 = T.T4,
            TextSize = 9, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
        })
    end

    -- Controls
    local ctrl = U.new("Frame", {
        Parent = self._tb, BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 10),
        AnchorPoint = Vector2.new(1, 0.5), ZIndex = 32,
    })
    U.list(ctrl, 5, Enum.FillDirection.Horizontal)

    local minB = U.new("TextButton", {
        Parent = ctrl, BackgroundColor3 = Color3.fromRGB(190,170,50),
        Size = UDim2.new(0,10,0,10), Text = "", AutoButtonColor = false, LayoutOrder = 1, ZIndex = 33,
    })
    U.corner(minB, UDim.new(1,0))
    local clsB = U.new("TextButton", {
        Parent = ctrl, BackgroundColor3 = Color3.fromRGB(190,65,55),
        Size = UDim2.new(0,10,0,10), Text = "", AutoButtonColor = false, LayoutOrder = 2, ZIndex = 33,
    })
    U.corner(clsB, UDim.new(1,0))
    for _,b in ipairs({minB,clsB}) do
        b.MouseEnter:Connect(function() U.sp(b, {Size=UDim2.new(0,12,0,12)}, 0.15) end)
        b.MouseLeave:Connect(function() U.sp(b, {Size=UDim2.new(0,10,0,10)}, 0.15) end)
    end

    -- ═══ SIDEBAR ═══
    self._sb = U.new("Frame", {
        Parent = self._m, BackgroundColor3 = T.SideBg,
        BackgroundTransparency = T.SideAlpha,
        Size = UDim2.new(0, T.SideW, 1, -T.TitleH),
        Position = UDim2.new(0, 0, 0, T.TitleH),
        BorderSizePixel = 0, ZIndex = 2,
    })
    -- Sidebar shine
    U.new("Frame", {
        Parent = self._sb, BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.96,
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0, ZIndex = 3,
    })
    -- Right divider
    U.new("Frame", {
        Parent = self._sb, BackgroundColor3 = T.Div,
        BackgroundTransparency = T.DivA,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0, ZIndex = 3,
    })

    self._tl = U.new("ScrollingFrame", {
        Parent = self._sb, BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0, BorderSizePixel = 0, ZIndex = 4,
    })
    U.list(self._tl, 2)

    -- ═══ CONTENT ═══
    self._ca = U.new("Frame", {
        Parent = self._m, BackgroundColor3 = T.ContentBg,
        BackgroundTransparency = T.ContentAlpha,
        Size = UDim2.new(1, -T.SideW, 1, -T.TitleH),
        Position = UDim2.new(0, T.SideW, 0, T.TitleH),
        BorderSizePixel = 0, ZIndex = 2,
    })

    -- ═══ RESIZE HANDLE ═══
    local rh = U.new("TextButton", {
        Parent = self._m, BackgroundTransparency = 1,
        Size = UDim2.new(0, T.ResH, 0, T.ResH),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        Text = "", ZIndex = 50,
    })
    -- Grip dots
    for idx = 0, 2 do
        U.new("Frame", {
            Parent = rh, BackgroundColor3 = T.T4,
            BackgroundTransparency = 0.3,
            Size = UDim2.new(0, 2, 0, 2),
            Position = UDim2.new(1, -(3 + idx * 3), 1, -(3 + (2-idx) * 3)),
            BorderSizePixel = 0, ZIndex = 51,
        })
    end

    local resizing, resStart, sStart = false, nil, nil
    rh.MouseButton1Down:Connect(function()
        resizing = true; resStart = UIS:GetMouseLocation()
        sStart = self._m.AbsoluteSize
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local m = UIS:GetMouseLocation(); local d = m - resStart
            local nw = math.clamp(sStart.X + d.X, T.MinW, T.MaxW)
            local nh = math.clamp(sStart.Y + d.Y, T.MinH, T.MaxH)
            self._m.Size = UDim2.new(0, nw, 0, nh); self._size = self._m.Size
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if resizing and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then resizing = false end
    end)
    rh.MouseEnter:Connect(function()
        for _,c in ipairs(rh:GetChildren()) do if c:IsA("Frame") then U.tw(c, {BackgroundTransparency=0}, 0.1) end end
    end)
    rh.MouseLeave:Connect(function()
        for _,c in ipairs(rh:GetChildren()) do if c:IsA("Frame") then U.tw(c, {BackgroundTransparency=0.3}, 0.12) end end
    end)

    -- ═══ SYSTEMS ═══
    self._tip = Tip.init(self._gui)
    self._notifs = Notifs.init(self._gui)

    -- ═══ DRAG ═══
    local dragging, dragS, startP = false, nil, nil
    self._tb.InputBegan:Connect(function(input)
        if resizing then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragS = input.Position; startP = self._m.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and not resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragS
            self._m.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
        end
    end)

    -- Minimize
    minB.MouseButton1Click:Connect(function()
        self._min = not self._min
        U.tw(self._m, {Size = self._min and UDim2.new(0, self._size.X.Offset, 0, T.TitleH) or self._size}, 0.25)
    end)

    -- Close
    clsB.MouseButton1Click:Connect(function()
        U.tw(self._m, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() self._gui:Destroy() end)
    end)

    -- Toggle
    local tKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == tKey then
            self._vis = not self._vis
            if self._vis then
                self._gui.Enabled = true; self._m.Size = UDim2.new(0,0,0,0)
                U.sp(self._m, {Size = self._size}, 0.35)
            else
                U.tw(self._m, {Size = UDim2.new(0,0,0,0)}, 0.18)
                task.delay(0.18, function() self._gui.Enabled = false end)
            end
        end
    end)

    -- Open
    self._m.BackgroundTransparency = 1
    task.delay(0.02, function()
        U.tw(self._m, {BackgroundTransparency = T.WinAlpha}, 0.2)
        U.sp(self._m, {Size = self._size}, 0.4)
    end)

    return self
end

function Window:CreateTab(cfg)
    local t = Tab._new(self, cfg or {})
    table.insert(self._tabs, t)
    if #self._tabs == 1 then self:SelectTab(t) end
    return t
end
function Window:SelectTab(t)
    if self._active == t then return end
    if self._active then self._active:_hide() end
    self._active = t; t:_show()
end
function Window:Notify(cfg) self._notifs:Push(cfg) end
function Window:Destroy()
    U.tw(self._m, {Size=UDim2.new(0,0,0,0), BackgroundTransparency=1}, 0.2)
    task.delay(0.2, function() self._gui:Destroy() end)
end
function Frost:CreateWindow(cfg) return Window._new(cfg or {}) end
return Frost
