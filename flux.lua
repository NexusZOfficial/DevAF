--[[
    ◆ Frost UI Library ◆
    True iOS Frosted Glass UI for Roblox Executors
    Version: 4.0.0
    
    Features:
    - Real blur/glass shader effect
    - In-game resizable window
    - Compact, properly-sized elements
    - Gray-only frosted palette
    - Smooth 60fps animations
    - Production ready
    
    local Frost = loadstring(...)()
    local Window = Frost:CreateWindow({ Title = "App" })
    local Tab = Window:CreateTab({ Name = "Main" })
]]

local Frost = {}
Frost.__index = Frost

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- FROSTED GLASS THEME
-- ═══════════════════════════════════════════════════════════
local T = {
    -- Glass layers (transparency is KEY for frosted look)
    WindowBg          = Color3.fromRGB(22, 22, 24),
    WindowBgAlpha     = 0.12,
    
    SidebarBg         = Color3.fromRGB(30, 30, 33),
    SidebarBgAlpha    = 0.18,
    
    TitleBg           = Color3.fromRGB(38, 38, 42),
    TitleBgAlpha      = 0.15,
    
    CardBg            = Color3.fromRGB(255, 255, 255),
    CardBgAlpha       = 0.92,    -- very transparent white = frosted
    CardHoverAlpha    = 0.87,
    
    -- Glass tints
    GlassTint         = Color3.fromRGB(200, 200, 206),
    GlassTintAlpha    = 0.88,
    
    -- Text
    Text1             = Color3.fromRGB(242, 242, 247),
    Text2             = Color3.fromRGB(162, 162, 168),
    Text3             = Color3.fromRGB(110, 110, 116),
    Text4             = Color3.fromRGB(76, 76, 82),
    
    -- Accents (all grays)
    Accent            = Color3.fromRGB(190, 190, 196),
    AccentDim         = Color3.fromRGB(130, 130, 136),
    AccentDark        = Color3.fromRGB(90, 90, 96),
    
    -- Toggle
    ToggleOn          = Color3.fromRGB(190, 190, 196),
    ToggleOff         = Color3.fromRGB(52, 52, 56),
    Knob              = Color3.fromRGB(255, 255, 255),
    
    -- Slider
    SliderFill        = Color3.fromRGB(170, 170, 176),
    SliderTrack       = Color3.fromRGB(48, 48, 52),
    
    -- Borders
    Border            = Color3.fromRGB(70, 70, 76),
    BorderAlpha       = 0.55,
    Divider           = Color3.fromRGB(58, 58, 62),
    DividerAlpha      = 0.4,
    
    -- Dropdown
    DropBg            = Color3.fromRGB(42, 42, 46),
    DropHover         = Color3.fromRGB(58, 58, 62),
    DropSel           = Color3.fromRGB(68, 68, 72),
    
    -- Input
    InputBg           = Color3.fromRGB(38, 38, 42),
    
    -- Notifications
    NotifBg           = Color3.fromRGB(40, 40, 44),
    NotifBgAlpha      = 0.08,
    NotifSuccess      = Color3.fromRGB(160, 190, 160),
    NotifError        = Color3.fromRGB(190, 140, 140),
    NotifWarning      = Color3.fromRGB(190, 180, 140),
    NotifInfo         = Color3.fromRGB(150, 165, 190),
    
    -- Scroll
    ScrollCol         = Color3.fromRGB(90, 90, 96),
    ScrollAlpha       = 0.55,
    
    -- Sizing (compact, sleek)
    Corner            = UDim.new(0, 10),
    CornerSm          = UDim.new(0, 7),
    CornerXs          = UDim.new(0, 5),
    CornerPill        = UDim.new(1, 0),
    
    SidebarW          = 148,
    TitleH            = 42,
    ElemH             = 36,
    ElemHLg           = 48,
    ElemPad           = 4,
    ContentPad        = 10,
    Inner             = 12,
    
    -- Resize
    MinWidth          = 420,
    MinHeight         = 280,
    MaxWidth          = 900,
    MaxHeight         = 700,
    ResizeHandleSize  = 12,
}

-- ═══════════════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════════════
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

function U.tween(i, p, d, s, dir)
    local tw = TweenService:Create(i, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    tw:Play()
    return tw
end

function U.spring(i, p, d)
    return U.tween(i, p, d or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function U.corner(p, r) return U.new("UICorner", {CornerRadius = r or T.Corner, Parent = p}) end
function U.stroke(p, c, th, a) return U.new("UIStroke", {Parent = p, Color = c or T.Border, Thickness = th or 1, Transparency = a or T.BorderAlpha}) end
function U.pad(p, t, b, l, r) return U.new("UIPadding", {Parent = p, PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0), PaddingLeft = UDim.new(0, l or t or 0), PaddingRight = UDim.new(0, r or l or t or 0)}) end
function U.list(p, gap, dir) return U.new("UIListLayout", {Parent = p, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap or T.ElemPad), FillDirection = dir or Enum.FillDirection.Vertical}) end
function U.uid() return HttpService:GenerateGUID(false):sub(1, 8) end

function U.ripple(parent)
    local r = U.new("Frame", {
        Parent = parent, BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.92, Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0.5,0.5),
        ZIndex = parent.ZIndex + 5, BorderSizePixel = 0,
    })
    U.corner(r, UDim.new(1,0))
    local s = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    U.tween(r, {Size = UDim2.new(0,s,0,s), BackgroundTransparency = 1}, 0.45)
    task.delay(0.45, function() r:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════
-- BLUR SHADER (real frosted glass)
-- ═══════════════════════════════════════════════════════════
local BlurEffect

local function createBlur()
    -- Remove existing
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name == "_FrostUIBlur" then v:Destroy() end
    end
    BlurEffect = U.new("BlurEffect", {
        Name = "_FrostUIBlur",
        Parent = Lighting,
        Size = 0, -- starts disabled
    })
end

local function enableBlur(on)
    if not BlurEffect or not BlurEffect.Parent then createBlur() end
    U.tween(BlurEffect, {Size = on and 12 or 0}, 0.3)
end

-- ═══════════════════════════════════════════════════════════
-- FROSTED GLASS FRAME BUILDER
-- ═══════════════════════════════════════════════════════════
local function makeFrostedFrame(props)
    local frame = U.new("Frame", {
        Name = props.Name or "FrostedFrame",
        Parent = props.Parent,
        BackgroundColor3 = props.Color or T.CardBg,
        BackgroundTransparency = props.Alpha or T.CardBgAlpha,
        Size = props.Size or UDim2.new(1, 0, 0, T.ElemH),
        Position = props.Position or UDim2.new(0, 0, 0, 0),
        AnchorPoint = props.Anchor or Vector2.new(0, 0),
        ClipsDescendants = props.Clip ~= false,
        ZIndex = props.ZIndex or 10,
        LayoutOrder = props.Order or 0,
        BorderSizePixel = 0,
    })
    U.corner(frame, props.Corner or T.CornerSm)
    
    -- Frosted inner glow (subtle white overlay at top)
    U.new("Frame", {
        Name = "_frost",
        Parent = frame,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.96,
        Size = UDim2.new(1, -2, 0, math.max(1, math.floor((props.Size and props.Size.Y.Offset or T.ElemH) * 0.45))),
        Position = UDim2.new(0, 1, 0, 1),
        ZIndex = frame.ZIndex,
        BorderSizePixel = 0,
    })
    
    -- Subtle border
    U.stroke(frame, props.BorderColor or T.Border, 1, props.BorderAlpha or 0.7)
    
    return frame
end

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════
local Notifs = {}
Notifs.__index = Notifs

function Notifs.init(gui)
    local self = setmetatable({}, Notifs)
    self.Container = U.new("Frame", {
        Name = "Notifs", Parent = gui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.new(0, 280, 1, -28),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 500,
    })
    U.list(self.Container, 6)
    return self
end

function Notifs:Push(cfg)
    cfg = cfg or {}
    local t = cfg.Type or "Info"
    local accent = T.NotifInfo
    if t == "Success" then accent = T.NotifSuccess
    elseif t == "Error" then accent = T.NotifError
    elseif t == "Warning" then accent = T.NotifWarning end
    
    local icons = {Success="✓", Error="✕", Warning="!", Info="·"}
    local dur = cfg.Duration or 3
    
    local f = makeFrostedFrame({
        Name = "Notif", Parent = self.Container,
        Color = T.NotifBg, Alpha = T.NotifBgAlpha,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 501, Corner = T.CornerSm,
    })
    f.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Accent pip
    U.new("Frame", {
        Parent = f, BackgroundColor3 = accent,
        BackgroundTransparency = 0.25,
        Size = UDim2.new(0, 2, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BorderSizePixel = 0, ZIndex = 502,
    })
    
    local c = U.new("Frame", {
        Parent = f, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 502,
    })
    U.pad(c, 10, 10, 16, 8)
    U.list(c, 2)
    
    -- Title
    local tr = U.new("Frame", {
        Parent = c, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = 1, ZIndex = 503,
    })
    
    local ic = U.new("Frame", {
        Parent = tr, BackgroundColor3 = accent, BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 504,
    })
    U.corner(ic, UDim.new(1, 0))
    U.new("TextLabel", {
        Parent = ic, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = icons[t] or "·",
        TextColor3 = accent, TextSize = 9,
        Font = Enum.Font.GothamBold, ZIndex = 505,
    })
    
    U.new("TextLabel", {
        Parent = tr, BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -38, 1, 0),
        Text = cfg.Title or "Notice",
        TextColor3 = T.Text1, TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 504,
    })
    
    local cl = U.new("TextButton", {
        Parent = tr, BackgroundTransparency = 1,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "✕", TextColor3 = T.Text4,
        TextSize = 9, Font = Enum.Font.GothamBold,
        ZIndex = 504,
    })
    
    if cfg.Message and cfg.Message ~= "" then
        U.new("TextLabel", {
            Parent = c, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = cfg.Message, TextColor3 = T.Text3,
            TextSize = 11, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, LayoutOrder = 2, ZIndex = 504,
        })
    end
    
    -- Progress
    local prog = U.new("Frame", {
        Parent = f, BackgroundColor3 = accent,
        BackgroundTransparency = 0.45,
        Size = UDim2.new(1, 0, 0, 1.5),
        Position = UDim2.new(0, 0, 1, -1.5),
        BorderSizePixel = 0, ZIndex = 503,
    })
    
    -- Animate
    f.Position = UDim2.new(1, 16, 0, 0)
    U.tween(f, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)
    U.tween(prog, {Size = UDim2.new(0, 0, 0, 1.5)}, dur, Enum.EasingStyle.Linear)
    
    local function dismiss()
        U.tween(f, {Position = UDim2.new(1, 16, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() if f.Parent then f:Destroy() end end)
    end
    
    cl.MouseButton1Click:Connect(dismiss)
    cl.MouseEnter:Connect(function() U.tween(cl, {TextColor3 = T.Text1}, 0.1) end)
    cl.MouseLeave:Connect(function() U.tween(cl, {TextColor3 = T.Text4}, 0.1) end)
    task.delay(dur, function() if f and f.Parent then dismiss() end end)
end

-- ═══════════════════════════════════════════════════════════
-- TOOLTIP
-- ═══════════════════════════════════════════════════════════
local Tip = {}
Tip.__index = Tip

function Tip.init(gui)
    local self = setmetatable({}, Tip)
    self.F = U.new("Frame", {
        Name = "Tip", Parent = gui,
        BackgroundColor3 = T.NotifBg,
        BackgroundTransparency = 0.05,
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false, ZIndex = 600,
    })
    U.corner(self.F, T.CornerXs)
    U.stroke(self.F, T.Border, 1, 0.5)
    U.pad(self.F, 5, 5, 8, 8)
    
    self.L = U.new("TextLabel", {
        Parent = self.F, BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = "", TextColor3 = T.Text2,
        TextSize = 11, Font = Enum.Font.Gotham,
        TextWrapped = true, ZIndex = 601,
    })
    U.new("UISizeConstraint", {Parent = self.F, MaxSize = Vector2.new(200, 120)})
    
    RunService.RenderStepped:Connect(function()
        if self.F.Visible then
            local m = UserInputService:GetMouseLocation()
            self.F.Position = UDim2.new(0, m.X + 10, 0, m.Y + 4)
        end
    end)
    return self
end

function Tip:Show(t)
    self.L.Text = t; self.F.Visible = true
    self.F.BackgroundTransparency = 1; self.L.TextTransparency = 1
    U.tween(self.F, {BackgroundTransparency = 0.05}, 0.12)
    U.tween(self.L, {TextTransparency = 0}, 0.12)
end

function Tip:Hide()
    U.tween(self.F, {BackgroundTransparency = 1}, 0.1)
    U.tween(self.L, {TextTransparency = 1}, 0.1)
    task.delay(0.1, function() self.F.Visible = false end)
end

-- ═══════════════════════════════════════════════════════════
-- TAB CLASS
-- ═══════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab._new(win, cfg)
    local self = setmetatable({}, Tab)
    self._w = win
    self.Name = cfg.Name or "Tab"
    self.Icon = cfg.Icon
    self._elems = {}
    self._vis = false
    self._ord = #win._tabs + 1
    
    -- Sidebar button
    self._btn = U.new("TextButton", {
        Name = "T_" .. self.Name, Parent = win._tabList,
        BackgroundColor3 = T.GlassTint, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "", AutoButtonColor = false,
        LayoutOrder = self._ord, ZIndex = 20,
    })
    U.corner(self._btn, T.CornerSm)
    
    self._ind = U.new("Frame", {
        Parent = self._btn, BackgroundColor3 = T.Accent,
        Size = UDim2.new(0, 2.5, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0, ZIndex = 22,
    })
    U.corner(self._ind, UDim.new(0, 2))
    
    local xOff = 10
    if self.Icon then
        self._icon = U.new("ImageLabel", {
            Parent = self._btn, BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = self.Icon, ImageColor3 = T.Text3, ZIndex = 21,
        })
        xOff = 30
    end
    
    self._lbl = U.new("TextLabel", {
        Parent = self._btn, BackgroundTransparency = 1,
        Position = UDim2.new(0, xOff, 0, 0),
        Size = UDim2.new(1, -(xOff + 8), 1, 0),
        Text = self.Name, TextColor3 = T.Text3,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 21,
    })
    
    -- Content
    self._content = U.new("ScrollingFrame", {
        Name = "C_" .. self.Name, Parent = win._contentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.ScrollCol,
        ScrollBarImageTransparency = T.ScrollAlpha,
        BorderSizePixel = 0, Visible = false, ZIndex = 10,
        TopImage = "rbxassetid://7766642408",
        MidImage = "rbxassetid://7766642408",
        BottomImage = "rbxassetid://7766642408",
    })
    U.pad(self._content, T.ContentPad, 14, T.ContentPad, T.ContentPad)
    U.list(self._content, T.ElemPad)
    
    -- Interactions
    self._btn.MouseEnter:Connect(function()
        if not self._vis then U.tween(self._btn, {BackgroundTransparency = 0.75}, 0.12) end
    end)
    self._btn.MouseLeave:Connect(function()
        if not self._vis then U.tween(self._btn, {BackgroundTransparency = 1}, 0.15) end
    end)
    self._btn.MouseButton1Click:Connect(function() win:SelectTab(self) end)
    
    return self
end

function Tab:_show()
    self._vis = true
    self._content.Visible = true
    self._content.CanvasPosition = Vector2.new(0, 0)
    U.tween(self._btn, {BackgroundTransparency = 0.7}, 0.2)
    U.tween(self._lbl, {TextColor3 = T.Text1}, 0.2)
    U.spring(self._ind, {Size = UDim2.new(0, 2.5, 0, 14)}, 0.3)
    if self._icon then U.tween(self._icon, {ImageColor3 = T.Accent}, 0.2) end
end

function Tab:_hide()
    self._vis = false
    self._content.Visible = false
    U.tween(self._btn, {BackgroundTransparency = 1}, 0.2)
    U.tween(self._lbl, {TextColor3 = T.Text3}, 0.2)
    U.tween(self._ind, {Size = UDim2.new(0, 2.5, 0, 0)}, 0.15)
    if self._icon then U.tween(self._icon, {ImageColor3 = T.Text3}, 0.2) end
end

-- ═══════════════════════════════════════════════════════════
-- ELEMENTS
-- ═══════════════════════════════════════════════════════════

function Tab:AddLabel(cfg)
    cfg = cfg or {}
    local o = #self._elems + 1
    local f = U.new("Frame", {
        Name = "Lbl", Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = o, ZIndex = 10,
    })
    local l = U.new("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = cfg.Text or "", TextColor3 = T.Text4,
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    local api = {SetText = function(_, t) l.Text = t end, Destroy = function() f:Destroy() end}
    table.insert(self._elems, api); return api
end

function Tab:AddSection(cfg)
    cfg = cfg or {}
    local o = #self._elems + 1
    local f = U.new("Frame", {
        Name = "Sec", Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, o == 1 and 18 or 26),
        LayoutOrder = o, ZIndex = 10,
    })
    local l = U.new("TextLabel", {
        Parent = f, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -14),
        Size = UDim2.new(1, 0, 0, 14),
        Text = string.upper(cfg.Name or ""),
        TextColor3 = T.Text4, TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    local api = {SetText = function(_, t) l.Text = string.upper(t) end}
    table.insert(self._elems, api); return api
end

function Tab:AddSeparator()
    local o = #self._elems + 1
    local f = U.new("Frame", {
        Name = "Sep", Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 6),
        LayoutOrder = o, ZIndex = 10,
    })
    U.new("Frame", {
        Parent = f, BackgroundColor3 = T.Divider,
        BackgroundTransparency = T.DividerAlpha,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0, ZIndex = 11,
    })
    table.insert(self._elems, {}); return {}
end

function Tab:AddButton(cfg)
    cfg = cfg or {}
    local cb = cfg.Callback or function() end
    local o = #self._elems + 1
    local hasD = cfg.Description and cfg.Description ~= ""
    local h = hasD and T.ElemHLg or T.ElemH
    
    local card = makeFrostedFrame({
        Name = "Btn", Parent = self._content,
        Size = UDim2.new(1, 0, 0, h),
        Order = o, ZIndex = 10,
    })
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, hasD and 6 or 0),
        Size = UDim2.new(1, -(T.Inner*2+20), 0, hasD and 17 or h),
        Text = cfg.Name or "Button", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 24),
            Size = UDim2.new(1, -(T.Inner*2+20), 0, 16),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    local chev = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(1, -(T.Inner+6), 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "›", TextColor3 = T.Text4,
        TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 12,
    })
    
    local btn = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 15,
    })
    
    btn.MouseEnter:Connect(function()
        U.tween(card, {BackgroundTransparency = T.CardHoverAlpha}, 0.12)
        U.tween(chev, {TextColor3 = T.Accent, Position = UDim2.new(1, -(T.Inner+3), 0.5, 0)}, 0.12)
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    btn.MouseLeave:Connect(function()
        U.tween(card, {BackgroundTransparency = T.CardBgAlpha}, 0.15)
        U.tween(chev, {TextColor3 = T.Text4, Position = UDim2.new(1, -(T.Inner+6), 0.5, 0)}, 0.15)
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    btn.MouseButton1Click:Connect(function()
        U.ripple(card)
        U.tween(card, {BackgroundTransparency = 0.8}, 0.06)
        task.delay(0.1, function() U.tween(card, {BackgroundTransparency = T.CardBgAlpha}, 0.2) end)
        task.spawn(cb)
    end)
    
    local api = {SetCallback = function(_, c) cb = c end, Destroy = function() card:Destroy() end}
    table.insert(self._elems, api); return api
end

function Tab:AddToggle(cfg)
    cfg = cfg or {}
    local state = cfg.Default or false
    local cb = cfg.Callback or function() end
    local o = #self._elems + 1
    local hasD = cfg.Description and cfg.Description ~= ""
    local h = hasD and T.ElemHLg or T.ElemH
    
    local card = makeFrostedFrame({
        Name = "Tog", Parent = self._content,
        Size = UDim2.new(1, 0, 0, h), Order = o, ZIndex = 10,
    })
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, hasD and 6 or 0),
        Size = UDim2.new(1, -(T.Inner*2+56), 0, hasD and 17 or h),
        Text = cfg.Name or "Toggle", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 24),
            Size = UDim2.new(1, -(T.Inner*2+56), 0, 16),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    -- iOS switch (compact)
    local sw = U.new("Frame", {
        Parent = card, BackgroundColor3 = state and T.ToggleOn or T.ToggleOff,
        Position = UDim2.new(1, -(T.Inner+42), 0.5, 0),
        Size = UDim2.new(0, 42, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 12,
    })
    U.corner(sw, UDim.new(1, 0))
    
    local knob = U.new("Frame", {
        Parent = sw, BackgroundColor3 = T.Knob,
        Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 13,
    })
    U.corner(knob, UDim.new(1, 0))
    
    local function set(s, skip)
        state = s
        U.tween(sw, {BackgroundColor3 = state and T.ToggleOn or T.ToggleOff}, 0.2)
        U.spring(knob, {Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.28)
        U.tween(knob, {Size = UDim2.new(0, 24, 0, 20)}, 0.06)
        task.delay(0.06, function() U.spring(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.2) end)
        if not skip then task.spawn(cb, state) end
    end
    
    local click = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 15,
    })
    click.MouseEnter:Connect(function()
        U.tween(card, {BackgroundTransparency = T.CardHoverAlpha}, 0.12)
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    click.MouseLeave:Connect(function()
        U.tween(card, {BackgroundTransparency = T.CardBgAlpha}, 0.15)
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    click.MouseButton1Click:Connect(function() set(not state) end)
    
    if state then task.spawn(cb, true) end
    
    local api = {
        GetState = function() return state end,
        SetState = function(_, s, skip) set(s, skip) end,
        SetCallback = function(_, c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._elems, api); return api
end

function Tab:AddSlider(cfg)
    cfg = cfg or {}
    local mn, mx = cfg.Min or 0, cfg.Max or 100
    local val = math.clamp(cfg.Default or mn, mn, mx)
    local inc = cfg.Increment or 1
    local suf = cfg.Suffix or ""
    local cb = cfg.Callback or function() end
    local o = #self._elems + 1
    local drag = false
    local hasD = cfg.Description and cfg.Description ~= ""
    local h = hasD and 64 or 50
    
    local card = makeFrostedFrame({
        Name = "Sld", Parent = self._content,
        Size = UDim2.new(1, 0, 0, h), Order = o, ZIndex = 10,
    })
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, 6),
        Size = UDim2.new(0.55, -T.Inner, 0, 16),
        Text = cfg.Name or "Slider", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 22),
            Size = UDim2.new(0.55, -T.Inner, 0, 12),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    local vl = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0.55, 0, 0, 6),
        Size = UDim2.new(0.45, -T.Inner, 0, 16),
        Text = tostring(val) .. suf, TextColor3 = T.Accent,
        TextSize = 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11,
    })
    
    local tY = hasD and 42 or 32
    local track = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.SliderTrack,
        Position = UDim2.new(0, T.Inner, 0, tY),
        Size = UDim2.new(1, -(T.Inner*2), 0, 4),
        ZIndex = 12,
    })
    U.corner(track, UDim.new(1, 0))
    
    local pct = (val - mn) / (mx - mn)
    local fill = U.new("Frame", {
        Parent = track, BackgroundColor3 = T.SliderFill,
        Size = UDim2.new(pct, 0, 1, 0), ZIndex = 13,
    })
    U.corner(fill, UDim.new(1, 0))
    
    local knob = U.new("Frame", {
        Parent = track, BackgroundColor3 = T.Knob,
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 15,
    })
    U.corner(knob, UDim.new(1, 0))
    U.stroke(knob, T.Border, 1, 0.7)
    
    local function rnd(v) return math.floor(v / inc + 0.5) * inc end
    
    local function upd(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.clamp(rnd(mn + (mx - mn) * p), mn, mx)
        local dp = (val - mn) / (mx - mn)
        U.tween(fill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.04, Enum.EasingStyle.Quad)
        U.tween(knob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.04, Enum.EasingStyle.Quad)
        vl.Text = tostring(val) .. suf
        task.spawn(cb, val)
    end
    
    local ca = U.new("TextButton", {
        Parent = track, BackgroundTransparency = 1,
        Size = UDim2.new(1, 12, 0, 20),
        Position = UDim2.new(0, -6, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "", ZIndex = 16,
    })
    
    ca.MouseButton1Down:Connect(function()
        drag = true
        U.spring(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            upd(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            drag = false
            U.spring(knob, {Size = UDim2.new(0, 14, 0, 14)}, 0.2)
        end
    end)
    
    card.MouseEnter:Connect(function()
        if not drag then U.tween(card, {BackgroundTransparency = T.CardHoverAlpha}, 0.12) end
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    card.MouseLeave:Connect(function()
        if not drag then U.tween(card, {BackgroundTransparency = T.CardBgAlpha}, 0.15) end
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    
    if val ~= mn then task.spawn(cb, val) end
    
    local api = {
        GetValue = function() return val end,
        SetValue = function(_, v, skip)
            val = math.clamp(rnd(v), mn, mx)
            local dp = (val - mn) / (mx - mn)
            U.tween(fill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.2)
            U.tween(knob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.2)
            vl.Text = tostring(val) .. suf
            if not skip then task.spawn(cb, val) end
        end,
        SetCallback = function(_, c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._elems, api); return api
end

function Tab:AddDropdown(cfg)
    cfg = cfg or {}
    local opts = cfg.Options or {}
    local multi = cfg.MultiSelect or false
    local cb = cfg.Callback or function() end
    local o = #self._elems + 1
    local isOpen = false
    
    local sel
    if multi then
        sel = {}
        if cfg.Default and type(cfg.Default) == "table" then
            for _, v in ipairs(cfg.Default) do sel[v] = true end
        end
    else
        sel = cfg.Default
    end
    
    local hasD = cfg.Description and cfg.Description ~= ""
    local hH = hasD and T.ElemHLg or T.ElemH
    
    local card = makeFrostedFrame({
        Name = "Drop", Parent = self._content,
        Size = UDim2.new(1, 0, 0, hH),
        Order = o, ZIndex = 10, Clip = true,
    })
    local cs = card:FindFirstChildOfClass("UIStroke")
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, hasD and 6 or 0),
        Size = UDim2.new(0.4, -T.Inner, 0, hasD and 17 or hH),
        Text = cfg.Name or "Dropdown", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 24),
            Size = UDim2.new(0.4, -T.Inner, 0, 16),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    local function dispText()
        if multi then
            local it = {}; for k, v in pairs(sel) do if v then table.insert(it, k) end end
            if #it == 0 then return "None" end
            if #it <= 2 then return table.concat(it, ", ") end
            return it[1] .. " +" .. (#it - 1)
        end
        return sel or "Select..."
    end
    
    local pill = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.DropBg,
        Position = UDim2.new(0.4, 2, 0, (hH - 22) / 2),
        Size = UDim2.new(0.6, -(T.Inner + 22), 0, 22),
        ZIndex = 12,
    })
    U.corner(pill, T.CornerXs)
    
    local selLbl = U.new("TextLabel", {
        Parent = pill, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Text = dispText(), TextColor3 = T.Text2,
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
    })
    
    local chev = U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(1, -(T.Inner + 8), 0, (hH - 14) / 2),
        Size = UDim2.new(0, 14, 0, 14),
        Text = "▾", TextColor3 = T.Text4,
        TextSize = 12, Font = Enum.Font.GothamBold,
        Rotation = 0, ZIndex = 12,
    })
    
    local optC = U.new("Frame", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, hH),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 11,
    })
    U.pad(optC, 2, 6, 5, 5)
    U.list(optC, 1)
    
    local optFrames = {}
    
    local function toggle()
        isOpen = not isOpen
        local oH = math.min(#opts * 26 + 10, 160)
        if isOpen then
            U.tween(card, {Size = UDim2.new(1, 0, 0, hH + oH)}, 0.25)
            U.tween(chev, {Rotation = 180}, 0.2)
            if cs then U.tween(cs, {Color = T.AccentDark, Transparency = 0.4}, 0.2) end
        else
            U.tween(card, {Size = UDim2.new(1, 0, 0, hH)}, 0.2)
            U.tween(chev, {Rotation = 0}, 0.2)
            if cs then U.tween(cs, {Color = T.Border, Transparency = 0.7}, 0.2) end
        end
    end
    
    local function makeOpt(text, idx)
        local isSel = multi and sel[text] or sel == text
        local of = U.new("Frame", {
            Parent = optC, BackgroundColor3 = isSel and T.DropSel or T.DropBg,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = idx, ZIndex = 12,
        })
        U.corner(of, T.CornerXs)
        
        local ol = U.new("TextLabel", {
            Name = "L", Parent = of, BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(1, -28, 1, 0),
            Text = text, TextColor3 = isSel and T.Text1 or T.Text2,
            TextSize = 12, Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 13,
        })
        local ck = U.new("TextLabel", {
            Name = "C", Parent = of, BackgroundTransparency = 1,
            Position = UDim2.new(1, -22, 0.5, 0),
            Size = UDim2.new(0, 14, 0, 14),
            AnchorPoint = Vector2.new(0, 0.5),
            Text = isSel and "✓" or "", TextColor3 = T.Accent,
            TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 13,
        })
        
        local ob = U.new("TextButton", {
            Parent = of, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 14,
        })
        ob.MouseEnter:Connect(function() U.tween(of, {BackgroundColor3 = T.DropHover}, 0.1) end)
        ob.MouseLeave:Connect(function()
            local cs2 = multi and sel[text] or sel == text
            U.tween(of, {BackgroundColor3 = cs2 and T.DropSel or T.DropBg}, 0.12)
        end)
        ob.MouseButton1Click:Connect(function()
            if multi then
                sel[text] = not sel[text]
                local now = sel[text]
                U.tween(of, {BackgroundColor3 = now and T.DropSel or T.DropBg}, 0.12)
                ol.Font = now and Enum.Font.GothamBold or Enum.Font.GothamMedium
                U.tween(ol, {TextColor3 = now and T.Text1 or T.Text2}, 0.12)
                ck.Text = now and "✓" or ""
                selLbl.Text = dispText()
                local r = {}; for k, v in pairs(sel) do if v then table.insert(r, k) end end
                task.spawn(cb, r)
            else
                for _, fr in ipairs(optFrames) do
                    local l2 = fr.Frame:FindFirstChild("L")
                    local c2 = fr.Frame:FindFirstChild("C")
                    U.tween(fr.Frame, {BackgroundColor3 = T.DropBg}, 0.12)
                    if l2 then l2.Font = Enum.Font.GothamMedium; U.tween(l2, {TextColor3 = T.Text2}, 0.12) end
                    if c2 then c2.Text = "" end
                end
                sel = text
                U.tween(of, {BackgroundColor3 = T.DropSel}, 0.12)
                ol.Font = Enum.Font.GothamBold; U.tween(ol, {TextColor3 = T.Text1}, 0.12)
                ck.Text = "✓"
                selLbl.Text = dispText()
                task.spawn(cb, sel)
                task.delay(0.1, function() if isOpen then toggle() end end)
            end
        end)
        table.insert(optFrames, {Frame = of, Text = text})
    end
    
    for i, op in ipairs(opts) do makeOpt(op, i) end
    
    local hBtn = U.new("TextButton", {
        Parent = card, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, hH), Text = "", ZIndex = 15,
    })
    hBtn.MouseButton1Click:Connect(toggle)
    hBtn.MouseEnter:Connect(function()
        if not isOpen then U.tween(card, {BackgroundTransparency = T.CardHoverAlpha}, 0.12) end
        if cfg.Tooltip then self._w._tip:Show(cfg.Tooltip) end
    end)
    hBtn.MouseLeave:Connect(function()
        if not isOpen then U.tween(card, {BackgroundTransparency = T.CardBgAlpha}, 0.15) end
        if cfg.Tooltip then self._w._tip:Hide() end
    end)
    
    local api = {
        GetSelected = function()
            if multi then local r = {}; for k, v in pairs(sel) do if v then table.insert(r, k) end end; return r end
            return sel
        end,
        SetSelected = function(_, v, skip)
            if multi then sel = {}; if type(v) == "table" then for _, x in ipairs(v) do sel[x] = true end end
            else sel = v end
            selLbl.Text = dispText()
            if not skip then
                if multi then local r = {}; for k, s in pairs(sel) do if s then table.insert(r, k) end end; task.spawn(cb, r)
                else task.spawn(cb, sel) end
            end
        end,
        Refresh = function(_, nOpts, keep)
            opts = nOpts; for _, fr in ipairs(optFrames) do fr.Frame:Destroy() end; optFrames = {}
            if not keep then sel = multi and {} or nil; selLbl.Text = dispText() end
            for i, op in ipairs(opts) do makeOpt(op, i) end
            if isOpen then local oH = math.min(#opts * 26 + 10, 160); card.Size = UDim2.new(1, 0, 0, hH + oH) end
        end,
        SetCallback = function(_, c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._elems, api); return api
end

function Tab:AddInput(cfg)
    cfg = cfg or {}
    local cb = cfg.Callback or function() end
    local chCb = cfg.Changed
    local num = cfg.Numeric or false
    local o = #self._elems + 1
    local hasD = cfg.Description and cfg.Description ~= ""
    local h = hasD and T.ElemHLg or T.ElemH
    
    local card = makeFrostedFrame({
        Name = "Inp", Parent = self._content,
        Size = UDim2.new(1, 0, 0, h), Order = o, ZIndex = 10,
    })
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, hasD and 6 or 0),
        Size = UDim2.new(0.38, -T.Inner, 0, hasD and 17 or h),
        Text = cfg.Name or "Input", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 24),
            Size = UDim2.new(0.38, -T.Inner, 0, 16),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    local ic = U.new("Frame", {
        Parent = card, BackgroundColor3 = T.InputBg,
        Position = UDim2.new(0.38, 2, 0.5, 0),
        Size = UDim2.new(0.62, -(T.Inner + 2), 0, 24),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 12,
    })
    U.corner(ic, T.CornerXs)
    local iStr = U.stroke(ic, T.Border, 1, 0.6)
    
    local tb = U.new("TextBox", {
        Parent = ic, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0),
        Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "Type...",
        PlaceholderColor3 = T.Text4, TextColor3 = T.Text1,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = cfg.ClearOnFocus or false,
        ClipsDescendants = true, ZIndex = 13,
    })
    
    tb.Focused:Connect(function()
        U.tween(iStr, {Color = T.AccentDim, Transparency = 0.2}, 0.12)
    end)
    tb.FocusLost:Connect(function(enter)
        U.tween(iStr, {Color = T.Border, Transparency = 0.6}, 0.15)
        local t = tb.Text
        if num then t = tonumber(t) or 0; tb.Text = tostring(t) end
        if enter then task.spawn(cb, t) end
    end)
    if chCb then
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            if num then local cl = tb.Text:gsub("[^%d%.%-]", ""); if cl ~= tb.Text then tb.Text = cl end end
            task.spawn(chCb, tb.Text)
        end)
    end
    
    if cfg.Tooltip then
        card.MouseEnter:Connect(function() self._w._tip:Show(cfg.Tooltip) end)
        card.MouseLeave:Connect(function() self._w._tip:Hide() end)
    end
    
    local api = {
        GetValue = function() return tb.Text end,
        SetValue = function(_, v) tb.Text = tostring(v) end,
        SetCallback = function(_, c) cb = c end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._elems, api); return api
end

function Tab:AddKeybind(cfg)
    cfg = cfg or {}
    local key = cfg.Default or Enum.KeyCode.Unknown
    local cb = cfg.Callback or function() end
    local chCb = cfg.Changed or function() end
    local listening = false
    local o = #self._elems + 1
    local hasD = cfg.Description and cfg.Description ~= ""
    local h = hasD and T.ElemHLg or T.ElemH
    
    local card = makeFrostedFrame({
        Name = "Key", Parent = self._content,
        Size = UDim2.new(1, 0, 0, h), Order = o, ZIndex = 10,
    })
    
    U.new("TextLabel", {
        Parent = card, BackgroundTransparency = 1,
        Position = UDim2.new(0, T.Inner, 0, hasD and 6 or 0),
        Size = UDim2.new(0.6, -T.Inner, 0, hasD and 17 or h),
        Text = cfg.Name or "Keybind", TextColor3 = T.Text1,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    if hasD then
        U.new("TextLabel", {
            Parent = card, BackgroundTransparency = 1,
            Position = UDim2.new(0, T.Inner, 0, 24),
            Size = UDim2.new(0.6, -T.Inner, 0, 16),
            Text = cfg.Description, TextColor3 = T.Text3,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
        })
    end
    
    local function kn(k)
        if k == Enum.KeyCode.Unknown then return "None" end
        return k.Name:gsub("Left","L"):gsub("Right","R"):gsub("Control","Ctrl"):gsub("Shift","Shft")
    end
    
    local kb = U.new("TextButton", {
        Parent = card, BackgroundColor3 = T.DropBg,
        Position = UDim2.new(1, -T.Inner, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(1, 0.5),
        Text = "", AutoButtonColor = false, ZIndex = 12,
    })
    U.corner(kb, T.CornerXs)
    U.pad(kb, 0, 0, 8, 8)
    local kStr = U.stroke(kb, T.Border, 1, 0.5)
    
    local kl = U.new("TextLabel", {
        Parent = kb, BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        Text = kn(key), TextColor3 = T.Text2,
        TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 13,
    })
    
    kb.MouseEnter:Connect(function() U.tween(kStr, {Color = T.AccentDim, Transparency = 0.3}, 0.1) end)
    kb.MouseLeave:Connect(function() if not listening then U.tween(kStr, {Color = T.Border, Transparency = 0.5}, 0.15) end end)
    kb.MouseButton1Click:Connect(function()
        listening = true; kl.Text = "..."
        U.tween(kb, {BackgroundColor3 = T.AccentDark}, 0.12)
        U.tween(kl, {TextColor3 = T.Text1}, 0.12)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or input.KeyCode
                listening = false; kl.Text = kn(key)
                U.tween(kb, {BackgroundColor3 = T.DropBg}, 0.15)
                U.tween(kl, {TextColor3 = T.Text2}, 0.15)
                U.tween(kStr, {Color = T.Border, Transparency = 0.5}, 0.15)
                task.spawn(chCb, key)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and not gp then
            if input.KeyCode == key then task.spawn(cb) end
        end
    end)
    
    if cfg.Tooltip then
        card.MouseEnter:Connect(function() self._w._tip:Show(cfg.Tooltip) end)
        card.MouseLeave:Connect(function() self._w._tip:Hide() end)
    end
    
    local api = {
        GetKey = function() return key end,
        SetKey = function(_, k) key = k; kl.Text = kn(k) end,
        Destroy = function() card:Destroy() end,
    }
    table.insert(self._elems, api); return api
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window._new(cfg)
    local self = setmetatable({}, Window)
    self._title = cfg.Title or "Frost"
    self._sub = cfg.Subtitle or ""
    self._size = cfg.Size or UDim2.new(0, 520, 0, 370)
    self._tabs = {}
    self._active = nil
    self._min = false
    self._vis = true
    
    createBlur()
    
    local par = Player:WaitForChild("PlayerGui")
    pcall(function() if syn and syn.protect_gui then par = CoreGui end end)
    
    self._gui = U.new("ScreenGui", {
        Name = "Frost_" .. U.uid(), Parent = par,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false, DisplayOrder = 999,
    })
    pcall(function() if syn then syn.protect_gui(self._gui) end end)
    
    -- Main frame
    self._main = U.new("Frame", {
        Name = "Main", Parent = self._gui,
        BackgroundColor3 = T.WindowBg,
        BackgroundTransparency = T.WindowBgAlpha,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true, ZIndex = 1,
    })
    U.corner(self._main, UDim.new(0, 12))
    U.stroke(self._main, T.Border, 1, 0.35)
    
    -- ════════════════════════════════
    -- TITLE BAR
    -- ════════════════════════════════
    self._tb = U.new("Frame", {
        Parent = self._main,
        BackgroundColor3 = T.TitleBg,
        BackgroundTransparency = T.TitleBgAlpha,
        Size = UDim2.new(1, 0, 0, T.TitleH),
        BorderSizePixel = 0, ZIndex = 30,
    })
    -- Bottom corners cover
    U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.TitleBg,
        BackgroundTransparency = T.TitleBgAlpha,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BorderSizePixel = 0, ZIndex = 30,
    })
    U.corner(self._tb, UDim.new(0, 12))
    
    -- Frost sheen on title bar
    U.new("Frame", {
        Parent = self._tb,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.96,
        Size = UDim2.new(1, -2, 0, 1),
        Position = UDim2.new(0, 1, 0, 1),
        BorderSizePixel = 0, ZIndex = 31,
    })
    
    -- Divider
    U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.Divider,
        BackgroundTransparency = T.DividerAlpha,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0, ZIndex = 31,
    })
    
    -- Icon
    local ai = U.new("Frame", {
        Parent = self._tb, BackgroundColor3 = T.AccentDim,
        BackgroundTransparency = 0.25,
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 32,
    })
    U.corner(ai, UDim.new(0, 6))
    U.new("TextLabel", {
        Parent = ai, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = self._title:sub(1, 1):upper(),
        TextColor3 = T.Text1, TextSize = 12,
        Font = Enum.Font.GothamBold, ZIndex = 33,
    })
    
    -- Title
    U.new("TextLabel", {
        Parent = self._tb, BackgroundTransparency = 1,
        Position = UDim2.new(0, 42, 0, self._sub ~= "" and 5 or 0),
        Size = UDim2.new(0.5, -42, 0, self._sub ~= "" and 16 or T.TitleH),
        Text = self._title, TextColor3 = T.Text1,
        TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
    })
    if self._sub ~= "" then
        U.new("TextLabel", {
            Parent = self._tb, BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 22),
            Size = UDim2.new(0.5, -42, 0, 12),
            Text = self._sub, TextColor3 = T.Text4,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
        })
    end
    
    -- Controls
    local ctrl = U.new("Frame", {
        Parent = self._tb, BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.new(0, 38, 0, 12),
        AnchorPoint = Vector2.new(1, 0.5), ZIndex = 32,
    })
    U.list(ctrl, 6, Enum.FillDirection.Horizontal)
    
    local minB = U.new("TextButton", {
        Parent = ctrl, BackgroundColor3 = Color3.fromRGB(200, 180, 50),
        Size = UDim2.new(0, 12, 0, 12), Text = "",
        AutoButtonColor = false, LayoutOrder = 1, ZIndex = 33,
    })
    U.corner(minB, UDim.new(1, 0))
    
    local clsB = U.new("TextButton", {
        Parent = ctrl, BackgroundColor3 = Color3.fromRGB(200, 70, 60),
        Size = UDim2.new(0, 12, 0, 12), Text = "",
        AutoButtonColor = false, LayoutOrder = 2, ZIndex = 33,
    })
    U.corner(clsB, UDim.new(1, 0))
    
    for _, b in ipairs({minB, clsB}) do
        b.MouseEnter:Connect(function() U.spring(b, {Size = UDim2.new(0, 14, 0, 14)}, 0.2) end)
        b.MouseLeave:Connect(function() U.spring(b, {Size = UDim2.new(0, 12, 0, 12)}, 0.2) end)
    end
    
    -- ════════════════════════════════
    -- SIDEBAR
    -- ════════════════════════════════
    self._sb = U.new("Frame", {
        Parent = self._main,
        BackgroundColor3 = T.SidebarBg,
        BackgroundTransparency = T.SidebarBgAlpha,
        Size = UDim2.new(0, T.SidebarW, 1, -T.TitleH),
        Position = UDim2.new(0, 0, 0, T.TitleH),
        BorderSizePixel = 0, ZIndex = 2,
    })
    
    -- Frost sheen
    U.new("Frame", {
        Parent = self._sb, BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0, ZIndex = 3,
    })
    
    U.new("Frame", {
        Parent = self._sb, BackgroundColor3 = T.Divider,
        BackgroundTransparency = T.DividerAlpha,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0, ZIndex = 3,
    })
    
    self._tabList = U.new("ScrollingFrame", {
        Parent = self._sb, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0, BorderSizePixel = 0, ZIndex = 4,
    })
    U.list(self._tabList, 2)
    
    -- ════════════════════════════════
    -- CONTENT
    -- ════════════════════════════════
    self._contentArea = U.new("Frame", {
        Parent = self._main, BackgroundTransparency = 1,
        Size = UDim2.new(1, -T.SidebarW, 1, -T.TitleH),
        Position = UDim2.new(0, T.SidebarW, 0, T.TitleH),
        ZIndex = 2,
    })
    
    -- ════════════════════════════════
    -- RESIZE HANDLE
    -- ════════════════════════════════
    local resizeHandle = U.new("TextButton", {
        Name = "Resize",
        Parent = self._main,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, T.ResizeHandleSize, 0, T.ResizeHandleSize),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        Text = "",
        ZIndex = 50,
    })
    
    -- Resize grip visual (three diagonal lines)
    for idx = 0, 2 do
        U.new("Frame", {
            Parent = resizeHandle,
            BackgroundColor3 = T.Text4,
            BackgroundTransparency = 0.4,
            Size = UDim2.new(0, 2 + idx * 4, 0, 1),
            Position = UDim2.new(1, -2, 1, -(4 + idx * 3)),
            AnchorPoint = Vector2.new(1, 0),
            Rotation = -45,
            BorderSizePixel = 0,
            ZIndex = 51,
        })
    end
    
    local resizing = false
    local resizeStart, sizeStart
    
    resizeHandle.MouseButton1Down:Connect(function()
        resizing = true
        resizeStart = UserInputService:GetMouseLocation()
        sizeStart = self._main.AbsoluteSize
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouse = UserInputService:GetMouseLocation()
            local delta = mouse - resizeStart
            local newW = math.clamp(sizeStart.X + delta.X, T.MinWidth, T.MaxWidth)
            local newH = math.clamp(sizeStart.Y + delta.Y, T.MinHeight, T.MaxHeight)
            self._main.Size = UDim2.new(0, newW, 0, newH)
            self._size = self._main.Size
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            resizing = false
        end
    end)
    
    -- Cursor change on hover
    resizeHandle.MouseEnter:Connect(function()
        -- Visual feedback
        for _, c in ipairs(resizeHandle:GetChildren()) do
            if c:IsA("Frame") then U.tween(c, {BackgroundTransparency = 0}, 0.15) end
        end
    end)
    resizeHandle.MouseLeave:Connect(function()
        for _, c in ipairs(resizeHandle:GetChildren()) do
            if c:IsA("Frame") then U.tween(c, {BackgroundTransparency = 0.4}, 0.2) end
        end
    end)
    
    -- ════════════════════════════════
    -- SYSTEMS
    -- ════════════════════════════════
    self._tip = Tip.init(self._gui)
    self._notifs = Notifs.init(self._gui)
    
    -- ════════════════════════════════
    -- DRAGGING
    -- ════════════════════════════════
    local dragging, dragStart, startPos = false, nil, nil
    self._tb.InputBegan:Connect(function(input)
        if resizing then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = self._main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and not resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            self._main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    
    -- Minimize
    minB.MouseButton1Click:Connect(function()
        self._min = not self._min
        U.tween(self._main, {Size = self._min and UDim2.new(0, self._size.X.Offset, 0, T.TitleH) or self._size}, 0.3)
    end)
    
    -- Close
    clsB.MouseButton1Click:Connect(function()
        enableBlur(false)
        U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function() self._gui:Destroy() end)
    end)
    
    -- Toggle
    local tKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == tKey then
            self._vis = not self._vis
            if self._vis then
                self._gui.Enabled = true
                enableBlur(true)
                self._main.Size = UDim2.new(0, 0, 0, 0)
                U.spring(self._main, {Size = self._size}, 0.4)
            else
                enableBlur(false)
                U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
                task.delay(0.2, function() self._gui.Enabled = false end)
            end
        end
    end)
    
    -- Open animation
    self._main.BackgroundTransparency = 1
    task.delay(0.02, function()
        enableBlur(true)
        U.tween(self._main, {BackgroundTransparency = T.WindowBgAlpha}, 0.2)
        U.spring(self._main, {Size = self._size}, 0.45)
    end)
    
    return self
end

function Window:CreateTab(cfg)
    local tab = Tab._new(self, cfg or {})
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self._active == tab then return end
    if self._active then self._active:_hide() end
    self._active = tab; tab:_show()
end

function Window:Notify(cfg) self._notifs:Push(cfg) end

function Window:Destroy()
    enableBlur(false)
    U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25)
    task.delay(0.25, function() self._gui:Destroy() end)
end

function Frost:CreateWindow(cfg) return Window._new(cfg or {}) end
return Frost
