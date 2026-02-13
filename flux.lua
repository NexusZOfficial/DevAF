--[[
    ◆ Frost UI Library ◆
    iOS Frosted Glass UI Library for Roblox
    Version: 3.0.0
    
    Pure iOS aesthetic — frosted glass, gray palette, perfect layout
    
    local Frost = loadstring(...)()
    local Window = Frost:CreateWindow({ Title = "My App" })
    local Tab = Window:CreateTab({ Name = "Main" })
    Tab:AddToggle({ Name = "Feature", Callback = function(v) end })
]]

local Frost = {}
Frost.__index = Frost

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- iOS FROSTED GLASS THEME — Gray Only Palette
-- ═══════════════════════════════════════════════════════════
local Theme = {
    -- Backgrounds (layered glass effect)
    WindowBackground = Color3.fromRGB(28, 28, 30),
    WindowBackgroundTransparency = 0.05,
    
    SidebarBackground = Color3.fromRGB(36, 36, 40),
    SidebarBackgroundTransparency = 0.1,
    
    TitleBarBackground = Color3.fromRGB(44, 44, 48),
    TitleBarTransparency = 0.08,
    
    -- Cards (frosted glass layers)
    CardBackground = Color3.fromRGB(58, 58, 62),
    CardBackgroundTransparency = 0.25,
    CardHover = Color3.fromRGB(68, 68, 72),
    CardHoverTransparency = 0.18,
    CardPress = Color3.fromRGB(78, 78, 82),
    
    -- Glass overlay
    GlassOverlay = Color3.fromRGB(255, 255, 255),
    GlassOverlayTransparency = 0.92,
    
    -- Text hierarchy
    TextPrimary = Color3.fromRGB(245, 245, 247),
    TextSecondary = Color3.fromRGB(174, 174, 178),
    TextTertiary = Color3.fromRGB(124, 124, 128),
    TextQuaternary = Color3.fromRGB(88, 88, 92),
    
    -- Accents (iOS gray system)
    AccentLight = Color3.fromRGB(200, 200, 204),
    AccentMid = Color3.fromRGB(142, 142, 147),
    AccentDark = Color3.fromRGB(99, 99, 102),
    
    -- Interactive elements
    ToggleOn = Color3.fromRGB(200, 200, 204),
    ToggleOff = Color3.fromRGB(56, 56, 60),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    
    SliderFill = Color3.fromRGB(174, 174, 178),
    SliderTrack = Color3.fromRGB(50, 50, 54),
    
    -- Borders & dividers
    Border = Color3.fromRGB(62, 62, 66),
    BorderTransparency = 0.5,
    Divider = Color3.fromRGB(54, 54, 58),
    DividerTransparency = 0.3,
    
    -- Dropdown
    DropdownBg = Color3.fromRGB(46, 46, 50),
    DropdownHover = Color3.fromRGB(62, 62, 66),
    DropdownSelected = Color3.fromRGB(72, 72, 76),
    
    -- Tab states
    TabActive = Color3.fromRGB(72, 72, 76),
    TabActiveTransparency = 0.2,
    TabIndicator = Color3.fromRGB(200, 200, 204),
    
    -- Scrollbar
    ScrollBar = Color3.fromRGB(100, 100, 104),
    ScrollBarTransparency = 0.5,
    
    -- Notifications
    NotifBackground = Color3.fromRGB(48, 48, 52),
    NotifSuccess = Color3.fromRGB(180, 200, 180),
    NotifError = Color3.fromRGB(200, 160, 160),
    NotifWarning = Color3.fromRGB(200, 190, 160),
    NotifInfo = Color3.fromRGB(170, 180, 200),
    
    -- Sizes
    CornerRadius = UDim.new(0, 12),
    CornerRadiusSmall = UDim.new(0, 8),
    CornerRadiusPill = UDim.new(1, 0),
    
    -- Layout
    SidebarWidth = 160,
    TitleBarHeight = 48,
    ElementHeight = 44,
    ElementHeightLarge = 60,
    ElementPadding = 6,
    ContentPadding = 12,
    InnerPadding = 14,
}

-- ═══════════════════════════════════════════════════════════
-- UTILITY
-- ═══════════════════════════════════════════════════════════
local U = {}

function U.new(class, props)
    local inst = Instance.new(class)
    local parent = nil
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            inst[k] = v
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

function U.tween(inst, props, dur, style, dir)
    local t = TweenService:Create(inst, TweenInfo.new(
        dur or 0.25,
        style or Enum.EasingStyle.Quint,
        dir or Enum.EasingDirection.Out
    ), props)
    t:Play()
    return t
end

function U.spring(inst, props, dur)
    return U.tween(inst, props, dur or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function U.uid()
    return HttpService:GenerateGUID(false):sub(1, 8)
end

function U.corner(parent, radius)
    return U.new("UICorner", {
        CornerRadius = radius or Theme.CornerRadius,
        Parent = parent,
    })
end

function U.stroke(parent, color, thickness, transparency)
    return U.new("UIStroke", {
        Parent = parent,
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or Theme.BorderTransparency,
    })
end

function U.padding(parent, top, bottom, left, right)
    return U.new("UIPadding", {
        Parent = parent,
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or top or 0),
        PaddingRight = UDim.new(0, right or left or top or 0),
    })
end

function U.list(parent, padding, direction)
    return U.new("UIListLayout", {
        Parent = parent,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or Theme.ElementPadding),
        FillDirection = direction or Enum.FillDirection.Vertical,
    })
end

-- Frosted glass effect using layered transparency
function U.glass(parent, color, transparency, cornerRadius)
    -- Base glass layer
    local glass = U.new("Frame", {
        Name = "Glass",
        Parent = parent,
        BackgroundColor3 = color or Theme.CardBackground,
        BackgroundTransparency = transparency or Theme.CardBackgroundTransparency,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = parent.ZIndex,
        BorderSizePixel = 0,
    })
    U.corner(glass, cornerRadius or Theme.CornerRadius)
    
    -- Subtle top highlight (simulates glass refraction)
    local highlight = U.new("Frame", {
        Name = "GlassHighlight",
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.94,
        Size = UDim2.new(1, -2, 0, 1),
        Position = UDim2.new(0, 1, 0, 1),
        ZIndex = parent.ZIndex + 1,
        BorderSizePixel = 0,
    })
    U.corner(highlight, cornerRadius or Theme.CornerRadius)
    
    return glass
end

-- Ripple effect
function U.ripple(parent)
    local ripple = U.new("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.9,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = parent.ZIndex + 5,
        BorderSizePixel = 0,
    })
    U.corner(ripple, UDim.new(1, 0))
    
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    U.tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
    }, 0.5)
    task.delay(0.5, function() ripple:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════
local Notifications = {}
Notifications.__index = Notifications

function Notifications.init(screenGui)
    local self = setmetatable({}, Notifications)
    self.Queue = {}
    
    self.Container = U.new("Frame", {
        Name = "Notifications",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 300, 1, -32),
        AnchorPoint = Vector2.new(1, 0),
        ZIndex = 500,
    })
    
    U.list(self.Container, 8)
    return self
end

function Notifications:Push(config)
    config = config or {}
    local title = config.Title or "Notice"
    local message = config.Message or ""
    local duration = config.Duration or 3.5
    local nType = config.Type or "Info"
    
    local accent = Theme.NotifInfo
    if nType == "Success" then accent = Theme.NotifSuccess
    elseif nType == "Error" then accent = Theme.NotifError
    elseif nType == "Warning" then accent = Theme.NotifWarning end
    
    local icons = {Success = "✓", Error = "✕", Warning = "!", Info = "i"}
    
    local frame = U.new("Frame", {
        Name = "Notif",
        Parent = self.Container,
        BackgroundColor3 = Theme.NotifBackground,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        ZIndex = 501,
    })
    U.corner(frame, Theme.CornerRadiusSmall)
    U.stroke(frame, Theme.Border, 1, 0.6)
    
    -- Accent line
    U.new("Frame", {
        Parent = frame,
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 2, 1, 0),
        BorderSizePixel = 0,
        ZIndex = 502,
    })
    
    local content = U.new("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 502,
    })
    U.padding(content, 12, 12, 14, 10)
    U.list(content, 3)
    
    -- Title row
    local titleRow = U.new("Frame", {
        Parent = content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        LayoutOrder = 1,
        ZIndex = 503,
    })
    
    -- Icon circle
    local iconFrame = U.new("Frame", {
        Parent = titleRow,
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.75,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 504,
    })
    U.corner(iconFrame, UDim.new(1, 0))
    
    U.new("TextLabel", {
        Parent = iconFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = icons[nType] or "i",
        TextColor3 = accent,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 505,
    })
    
    U.new("TextLabel", {
        Parent = titleRow,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 24, 0, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 504,
    })
    
    -- Close
    local closeBtn = U.new("TextButton", {
        Parent = titleRow,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "✕",
        TextColor3 = Theme.TextQuaternary,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 504,
    })
    
    if message ~= "" then
        U.new("TextLabel", {
            Parent = content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = message,
            TextColor3 = Theme.TextTertiary,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LayoutOrder = 2,
            ZIndex = 504,
        })
    end
    
    -- Progress bar
    local progress = U.new("Frame", {
        Parent = frame,
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0,
        ZIndex = 503,
    })
    
    -- Animate in
    frame.Position = UDim2.new(1, 20, 0, 0)
    frame.BackgroundTransparency = 1
    U.tween(frame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.08}, 0.4)
    U.tween(progress, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)
    
    local function dismiss()
        U.tween(frame, {Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function()
            if frame.Parent then frame:Destroy() end
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseEnter:Connect(function()
        U.tween(closeBtn, {TextColor3 = Theme.TextPrimary}, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        U.tween(closeBtn, {TextColor3 = Theme.TextQuaternary}, 0.15)
    end)
    
    task.delay(duration, function()
        if frame and frame.Parent then dismiss() end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════
local Tooltip = {}
Tooltip.__index = Tooltip

function Tooltip.init(screenGui)
    local self = setmetatable({}, Tooltip)
    
    self.Frame = U.new("Frame", {
        Name = "Tooltip",
        Parent = screenGui,
        BackgroundColor3 = Theme.NotifBackground,
        BackgroundTransparency = 0.06,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 600,
    })
    U.corner(self.Frame, Theme.CornerRadiusSmall)
    U.stroke(self.Frame, Theme.Border, 1, 0.5)
    U.padding(self.Frame, 6, 6, 10, 10)
    
    self.Label = U.new("TextLabel", {
        Parent = self.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Text = "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        ZIndex = 601,
    })
    
    U.new("UISizeConstraint", {
        Parent = self.Frame,
        MaxSize = Vector2.new(220, 150),
    })
    
    -- Mouse tracking
    RunService.RenderStepped:Connect(function()
        if self.Frame.Visible then
            local m = UserInputService:GetMouseLocation()
            self.Frame.Position = UDim2.new(0, m.X + 12, 0, m.Y + 2)
        end
    end)
    
    return self
end

function Tooltip:Show(text)
    self.Label.Text = text
    self.Frame.Visible = true
    self.Frame.BackgroundTransparency = 1
    self.Label.TextTransparency = 1
    U.tween(self.Frame, {BackgroundTransparency = 0.06}, 0.15)
    U.tween(self.Label, {TextTransparency = 0}, 0.15)
end

function Tooltip:Hide()
    U.tween(self.Frame, {BackgroundTransparency = 1}, 0.12)
    U.tween(self.Label, {TextTransparency = 1}, 0.12)
    task.delay(0.12, function() self.Frame.Visible = false end)
end

-- ═══════════════════════════════════════════════════════════
-- ELEMENT BUILDER (shared card template)
-- ═══════════════════════════════════════════════════════════
local function createCard(parent, config)
    local order = config.Order or 0
    local height = config.Height or Theme.ElementHeight
    local hasDesc = config.Description and config.Description ~= ""
    
    if hasDesc then
        height = Theme.ElementHeightLarge
    end
    
    local card = U.new("Frame", {
        Name = config.Type .. "_" .. (config.Name or ""),
        Parent = parent,
        BackgroundColor3 = Theme.CardBackground,
        BackgroundTransparency = Theme.CardBackgroundTransparency,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order,
        ClipsDescendants = true,
        ZIndex = 10,
    })
    U.corner(card, Theme.CornerRadiusSmall)
    U.stroke(card, Theme.Border, 1, 0.65)
    
    -- Name label
    local nameLabel = U.new("TextLabel", {
        Name = "NameLabel",
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.InnerPadding, 0, hasDesc and 8 or 0),
        Size = UDim2.new(1, -(Theme.InnerPadding * 2 + (config.RightWidth or 60)), 0, hasDesc and 20 or height),
        Text = config.Name or "",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 11,
    })
    
    -- Description label
    local descLabel
    if hasDesc then
        descLabel = U.new("TextLabel", {
            Name = "DescLabel",
            Parent = card,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, Theme.InnerPadding, 0, 30),
            Size = UDim2.new(1, -(Theme.InnerPadding * 2 + (config.RightWidth or 60)), 0, 18),
            Text = config.Description,
            TextColor3 = Theme.TextTertiary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 11,
        })
    end
    
    return card, nameLabel, descLabel
end

-- Hover handler for cards
local function addCardHover(card, tooltip, tooltipSystem)
    local hovering = false
    
    card.MouseEnter:Connect(function()
        hovering = true
        U.tween(card, {
            BackgroundColor3 = Theme.CardHover,
            BackgroundTransparency = Theme.CardHoverTransparency,
        }, 0.15)
        if tooltip and tooltipSystem then
            tooltipSystem:Show(tooltip)
        end
    end)
    
    card.MouseLeave:Connect(function()
        hovering = false
        U.tween(card, {
            BackgroundColor3 = Theme.CardBackground,
            BackgroundTransparency = Theme.CardBackgroundTransparency,
        }, 0.2)
        if tooltipSystem then
            tooltipSystem:Hide()
        end
    end)
    
    return function() return hovering end
end

-- ═══════════════════════════════════════════════════════════
-- TAB CLASS
-- ═══════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab._new(window, config)
    local self = setmetatable({}, Tab)
    self._window = window
    self.Name = config.Name or "Tab"
    self.Icon = config.Icon
    self._elements = {}
    self._visible = false
    self._order = #window._tabs + 1
    
    -- Sidebar tab button
    self._btn = U.new("TextButton", {
        Name = "Tab_" .. self.Name,
        Parent = window._tabList,
        BackgroundColor3 = Theme.TabActive,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = self._order,
        ZIndex = 20,
    })
    U.corner(self._btn, Theme.CornerRadiusSmall)
    
    -- Indicator bar
    self._indicator = U.new("Frame", {
        Parent = self._btn,
        BackgroundColor3 = Theme.TabIndicator,
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        ZIndex = 22,
    })
    U.corner(self._indicator, UDim.new(0, 2))
    
    -- Icon (optional)
    local textOffset = Theme.InnerPadding
    if self.Icon then
        self._iconLabel = U.new("ImageLabel", {
            Parent = self._btn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = self.Icon,
            ImageColor3 = Theme.TextTertiary,
            ZIndex = 21,
        })
        textOffset = 36
    end
    
    self._label = U.new("TextLabel", {
        Parent = self._btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, textOffset, 0, 0),
        Size = UDim2.new(1, -(textOffset + 10), 1, 0),
        Text = self.Name,
        TextColor3 = Theme.TextTertiary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 21,
    })
    
    -- Content scroll frame
    self._content = U.new("ScrollingFrame", {
        Name = "Content_" .. self.Name,
        Parent = window._contentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.ScrollBar,
        ScrollBarImageTransparency = Theme.ScrollBarTransparency,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10,
        TopImage = "rbxassetid://7766642408",
        MidImage = "rbxassetid://7766642408",
        BottomImage = "rbxassetid://7766642408",
    })
    U.padding(self._content, Theme.ContentPadding, 20, Theme.ContentPadding, Theme.ContentPadding)
    U.list(self._content, Theme.ElementPadding)
    
    -- Tab button interactions
    self._btn.MouseEnter:Connect(function()
        if not self._visible then
            U.tween(self._btn, {BackgroundTransparency = 0.6}, 0.15)
        end
    end)
    self._btn.MouseLeave:Connect(function()
        if not self._visible then
            U.tween(self._btn, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    self._btn.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)
    
    return self
end

function Tab:_show()
    self._visible = true
    self._content.Visible = true
    self._content.CanvasPosition = Vector2.new(0, 0)
    
    U.tween(self._btn, {
        BackgroundColor3 = Theme.TabActive,
        BackgroundTransparency = Theme.TabActiveTransparency,
    }, 0.25)
    U.tween(self._label, {TextColor3 = Theme.TextPrimary}, 0.25)
    U.spring(self._indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.35)
    
    if self._iconLabel then
        U.tween(self._iconLabel, {ImageColor3 = Theme.AccentLight}, 0.25)
    end
    
    -- Stagger element fade-in
    local children = self._content:GetChildren()
    for i, child in ipairs(children) do
        if child:IsA("Frame") then
            child.BackgroundTransparency = 1
            local targetTransparency = Theme.CardBackgroundTransparency
            -- Separators and labels should stay transparent
            if child.Name:find("Sep_") or child.Name:find("Label_") or child.Name:find("Section_") then
                targetTransparency = 1
            end
            task.delay((i - 1) * 0.015, function()
                U.tween(child, {BackgroundTransparency = targetTransparency}, 0.25)
            end)
        end
    end
end

function Tab:_hide()
    self._visible = false
    self._content.Visible = false
    
    U.tween(self._btn, {
        BackgroundTransparency = 1,
    }, 0.25)
    U.tween(self._label, {TextColor3 = Theme.TextTertiary}, 0.25)
    U.tween(self._indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
    
    if self._iconLabel then
        U.tween(self._iconLabel, {ImageColor3 = Theme.TextTertiary}, 0.25)
    end
end

-- ═══════════════════════════════════════════════════════════
-- ELEMENTS
-- ═══════════════════════════════════════════════════════════

-- Label
function Tab:AddLabel(config)
    config = config or {}
    local order = #self._elements + 1
    
    local frame = U.new("Frame", {
        Name = "Label_" .. order,
        Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        LayoutOrder = order,
        ZIndex = 10,
    })
    
    local label = U.new("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = config.Text or "Label",
        TextColor3 = Theme.TextQuaternary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })
    
    local api = {
        SetText = function(_, t) label.Text = t end,
        Destroy = function(_) frame:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Section
function Tab:AddSection(config)
    config = config or {}
    local order = #self._elements + 1
    
    local frame = U.new("Frame", {
        Name = "Section_" .. (config.Name or ""),
        Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, order == 1 and 22 or 32),
        LayoutOrder = order,
        ZIndex = 10,
    })
    
    local label = U.new("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -18),
        Size = UDim2.new(1, 0, 0, 18),
        Text = string.upper(config.Name or "Section"),
        TextColor3 = Theme.TextQuaternary,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })
    
    local api = {
        SetText = function(_, t) label.Text = string.upper(t) end,
    }
    table.insert(self._elements, api)
    return api
end

-- Separator
function Tab:AddSeparator()
    local order = #self._elements + 1
    
    local frame = U.new("Frame", {
        Name = "Sep_" .. order,
        Parent = self._content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 8),
        LayoutOrder = order,
        ZIndex = 10,
    })
    
    U.new("Frame", {
        Parent = frame,
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = Theme.DividerTransparency,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    
    table.insert(self._elements, {})
    return {}
end

-- Button
function Tab:AddButton(config)
    config = config or {}
    local callback = config.Callback or function() end
    local order = #self._elements + 1
    
    local card, nameLabel = createCard(self._content, {
        Type = "Button", Name = config.Name, Description = config.Description,
        Order = order, RightWidth = 30,
    })
    
    -- Chevron
    local chevron = U.new("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -(Theme.InnerPadding + 8), 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "›",
        TextColor3 = Theme.TextQuaternary,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 12,
    })
    
    local btn = U.new("TextButton", {
        Parent = card,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 15,
    })
    
    addCardHover(btn, config.Tooltip, self._window._tooltip)
    
    btn.MouseEnter:Connect(function()
        U.tween(card, {BackgroundColor3 = Theme.CardHover, BackgroundTransparency = Theme.CardHoverTransparency}, 0.15)
        U.tween(chevron, {
            TextColor3 = Theme.AccentLight,
            Position = UDim2.new(1, -(Theme.InnerPadding + 4), 0.5, 0),
        }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        U.tween(card, {BackgroundColor3 = Theme.CardBackground, BackgroundTransparency = Theme.CardBackgroundTransparency}, 0.2)
        U.tween(chevron, {
            TextColor3 = Theme.TextQuaternary,
            Position = UDim2.new(1, -(Theme.InnerPadding + 8), 0.5, 0),
        }, 0.2)
    end)
    
    btn.MouseButton1Click:Connect(function()
        U.ripple(card)
        -- Flash feedback
        U.tween(card, {BackgroundColor3 = Theme.CardPress, BackgroundTransparency = 0.15}, 0.08)
        task.delay(0.12, function()
            U.tween(card, {BackgroundColor3 = Theme.CardBackground, BackgroundTransparency = Theme.CardBackgroundTransparency}, 0.25)
        end)
        task.spawn(callback)
    end)
    
    local api = {
        SetName = function(_, t) nameLabel.Text = t end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Toggle
function Tab:AddToggle(config)
    config = config or {}
    local state = config.Default or false
    local callback = config.Callback or function() end
    local order = #self._elements + 1
    
    local card, nameLabel = createCard(self._content, {
        Type = "Toggle", Name = config.Name, Description = config.Description,
        Order = order, RightWidth = 60,
    })
    
    -- iOS toggle switch
    local switchBg = U.new("Frame", {
        Parent = card,
        BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
        Position = UDim2.new(1, -(Theme.InnerPadding + 48), 0.5, 0),
        Size = UDim2.new(0, 48, 0, 28),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 12,
    })
    U.corner(switchBg, UDim.new(1, 0))
    
    local knob = U.new("Frame", {
        Parent = switchBg,
        BackgroundColor3 = Theme.ToggleKnob,
        Position = state and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 13,
    })
    U.corner(knob, UDim.new(1, 0))
    
    -- Knob inner shadow (subtle)
    U.new("Frame", {
        Parent = knob,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.95,
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        ZIndex = 14,
    })
    
    local function setToggle(newState, skip)
        state = newState
        U.tween(switchBg, {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
        U.spring(knob, {
            Position = state and UDim2.new(1, -26, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        }, 0.3)
        -- Squish
        U.tween(knob, {Size = UDim2.new(0, 28, 0, 24)}, 0.08)
        task.delay(0.08, function()
            U.spring(knob, {Size = UDim2.new(0, 24, 0, 24)}, 0.25)
        end)
        if not skip then task.spawn(callback, state) end
    end
    
    local clickArea = U.new("TextButton", {
        Parent = card,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 15,
    })
    
    clickArea.MouseEnter:Connect(function()
        U.tween(card, {BackgroundColor3 = Theme.CardHover, BackgroundTransparency = Theme.CardHoverTransparency}, 0.15)
        if config.Tooltip then self._window._tooltip:Show(config.Tooltip) end
    end)
    clickArea.MouseLeave:Connect(function()
        U.tween(card, {BackgroundColor3 = Theme.CardBackground, BackgroundTransparency = Theme.CardBackgroundTransparency}, 0.2)
        if config.Tooltip then self._window._tooltip:Hide() end
    end)
    clickArea.MouseButton1Click:Connect(function()
        setToggle(not state)
    end)
    
    if state then task.spawn(callback, true) end
    
    local api = {
        GetState = function() return state end,
        SetState = function(_, s, skip) setToggle(s, skip) end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Slider
function Tab:AddSlider(config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local value = math.clamp(config.Default or min, min, max)
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    local order = #self._elements + 1
    local dragging = false
    
    local hasDesc = config.Description and config.Description ~= ""
    local height = hasDesc and 76 or 58
    
    local card = U.new("Frame", {
        Name = "Slider_" .. (config.Name or ""),
        Parent = self._content,
        BackgroundColor3 = Theme.CardBackground,
        BackgroundTransparency = Theme.CardBackgroundTransparency,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order,
        ClipsDescendants = true,
        ZIndex = 10,
    })
    U.corner(card, Theme.CornerRadiusSmall)
    U.stroke(card, Theme.Border, 1, 0.65)
    
    -- Name
    U.new("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.InnerPadding, 0, 8),
        Size = UDim2.new(0.6, -Theme.InnerPadding, 0, 18),
        Text = config.Name or "Slider",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })
    
    if hasDesc then
        U.new("TextLabel", {
            Parent = card,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, Theme.InnerPadding, 0, 26),
            Size = UDim2.new(0.6, -Theme.InnerPadding, 0, 14),
            Text = config.Description,
            TextColor3 = Theme.TextTertiary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
        })
    end
    
    -- Value display
    local valueLabel = U.new("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.6, 0, 0, 8),
        Size = UDim2.new(0.4, -Theme.InnerPadding, 0, 18),
        Text = tostring(value) .. suffix,
        TextColor3 = Theme.AccentLight,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 11,
    })
    
    -- Track
    local trackY = hasDesc and 50 or 36
    local track = U.new("Frame", {
        Parent = card,
        BackgroundColor3 = Theme.SliderTrack,
        Position = UDim2.new(0, Theme.InnerPadding, 0, trackY),
        Size = UDim2.new(1, -(Theme.InnerPadding * 2), 0, 4),
        ZIndex = 12,
    })
    U.corner(track, UDim.new(1, 0))
    
    local pct = (value - min) / (max - min)
    
    -- Fill
    local fill = U.new("Frame", {
        Parent = track,
        BackgroundColor3 = Theme.SliderFill,
        Size = UDim2.new(pct, 0, 1, 0),
        ZIndex = 13,
    })
    U.corner(fill, UDim.new(1, 0))
    
    -- Knob
    local knobSize = 16
    local knob = U.new("Frame", {
        Parent = track,
        BackgroundColor3 = Theme.ToggleKnob,
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, knobSize, 0, knobSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 15,
    })
    U.corner(knob, UDim.new(1, 0))
    U.stroke(knob, Theme.Border, 1, 0.7)
    
    local function round(v)
        return math.floor(v / increment + 0.5) * increment
    end
    
    local function update(input)
        local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.clamp(round(min + (max - min) * p), min, max)
        local dp = (value - min) / (max - min)
        U.tween(fill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.06, Enum.EasingStyle.Quad)
        U.tween(knob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.06, Enum.EasingStyle.Quad)
        valueLabel.Text = tostring(value) .. suffix
        task.spawn(callback, value)
    end
    
    -- Click area
    local clickArea = U.new("TextButton", {
        Parent = track,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 16, 0, 24),
        Position = UDim2.new(0, -8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "",
        ZIndex = 16,
    })
    
    clickArea.MouseButton1Down:Connect(function()
        dragging = true
        U.spring(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.25)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            U.spring(knob, {Size = UDim2.new(0, knobSize, 0, knobSize)}, 0.25)
        end
    end)
    
    -- Card hover
    card.MouseEnter:Connect(function()
        if not dragging then
            U.tween(card, {BackgroundColor3 = Theme.CardHover, BackgroundTransparency = Theme.CardHoverTransparency}, 0.15)
        end
        if config.Tooltip then self._window._tooltip:Show(config.Tooltip) end
    end)
    card.MouseLeave:Connect(function()
        if not dragging then
            U.tween(card, {BackgroundColor3 = Theme.CardBackground, BackgroundTransparency = Theme.CardBackgroundTransparency}, 0.2)
        end
        if config.Tooltip then self._window._tooltip:Hide() end
    end)
    
    if value ~= min then task.spawn(callback, value) end
    
    local api = {
        GetValue = function() return value end,
        SetValue = function(_, v, skip)
            value = math.clamp(round(v), min, max)
            local dp = (value - min) / (max - min)
            U.tween(fill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.25)
            U.tween(knob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.25)
            valueLabel.Text = tostring(value) .. suffix
            if not skip then task.spawn(callback, value) end
        end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Dropdown
function Tab:AddDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local multiSelect = config.MultiSelect or false
    local callback = config.Callback or function() end
    local order = #self._elements + 1
    local isOpen = false
    
    local selected
    if multiSelect then
        selected = {}
        if config.Default and type(config.Default) == "table" then
            for _, v in ipairs(config.Default) do selected[v] = true end
        end
    else
        selected = config.Default
    end
    
    local hasDesc = config.Description and config.Description ~= ""
    local headerH = hasDesc and Theme.ElementHeightLarge or Theme.ElementHeight
    
    local card = U.new("Frame", {
        Name = "Dropdown_" .. (config.Name or ""),
        Parent = self._content,
        BackgroundColor3 = Theme.CardBackground,
        BackgroundTransparency = Theme.CardBackgroundTransparency,
        Size = UDim2.new(1, 0, 0, headerH),
        ClipsDescendants = true,
        LayoutOrder = order,
        ZIndex = 10,
    })
    U.corner(card, Theme.CornerRadiusSmall)
    local cardStroke = U.stroke(card, Theme.Border, 1, 0.65)
    
    -- Header
    U.new("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.InnerPadding, 0, hasDesc and 8 or 0),
        Size = UDim2.new(0.45, -Theme.InnerPadding, 0, hasDesc and 20 or headerH),
        Text = config.Name or "Dropdown",
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })
    
    if hasDesc then
        U.new("TextLabel", {
            Parent = card,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, Theme.InnerPadding, 0, 30),
            Size = UDim2.new(0.45, -Theme.InnerPadding, 0, 18),
            Text = config.Description,
            TextColor3 = Theme.TextTertiary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
        })
    end
    
    local function getDisplayText()
        if multiSelect then
            local items = {}
            for k, v in pairs(selected) do if v then table.insert(items, k) end end
            if #items == 0 then return "None" end
            if #items <= 2 then return table.concat(items, ", ") end
            return items[1] .. " +" .. (#items - 1)
        end
        return selected or "Select..."
    end
    
    -- Selected display pill
    local selectedPill = U.new("Frame", {
        Parent = card,
        BackgroundColor3 = Theme.DropdownBg,
        Position = UDim2.new(0.45, 4, 0.5, 0),
        Size = UDim2.new(0.55, -(Theme.InnerPadding + 30), 0, 26),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 12,
    })
    -- Keep pill within header bounds
    selectedPill.Position = UDim2.new(0.45, 4, 0, (headerH - 26) / 2)
    selectedPill.AnchorPoint = Vector2.new(0, 0)
    U.corner(selectedPill, UDim.new(0, 6))
    
    local selectedText = U.new("TextLabel", {
        Parent = selectedPill,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        Text = getDisplayText(),
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 13,
    })
    
    -- Chevron
    local chevron = U.new("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -(Theme.InnerPadding + 10), 0, (headerH - 16) / 2),
        Size = UDim2.new(0, 16, 0, 16),
        Text = "▾",
        TextColor3 = Theme.TextQuaternary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Rotation = 0,
        ZIndex = 12,
    })
    
    -- Options container
    local optContainer = U.new("Frame", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, headerH),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 11,
    })
    U.padding(optContainer, 2, 8, 6, 6)
    U.list(optContainer, 2)
    
    local optionFrames = {}
    
    local function toggleDropdown()
        isOpen = not isOpen
        local optH = math.min(#options * 32 + 12, 180)
        if isOpen then
            U.tween(card, {Size = UDim2.new(1, 0, 0, headerH + optH)}, 0.3)
            U.tween(chevron, {Rotation = 180}, 0.25)
            U.tween(cardStroke, {Color = Theme.AccentDark, Transparency = 0.4}, 0.25)
        else
            U.tween(card, {Size = UDim2.new(1, 0, 0, headerH)}, 0.25)
            U.tween(chevron, {Rotation = 0}, 0.25)
            U.tween(cardStroke, {Color = Theme.Border, Transparency = 0.65}, 0.25)
        end
    end
    
    local function createOptionBtn(text, idx)
        local isSel = multiSelect and selected[text] or selected == text
        
        local optFrame = U.new("Frame", {
            Parent = optContainer,
            BackgroundColor3 = isSel and Theme.DropdownSelected or Theme.DropdownBg,
            BackgroundTransparency = isSel and 0.3 or 0.1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = idx,
            ZIndex = 12,
        })
        U.corner(optFrame, UDim.new(0, 6))
        
        local optLabel = U.new("TextLabel", {
            Name = "Label",
            Parent = optFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -36, 1, 0),
            Text = text,
            TextColor3 = isSel and Theme.TextPrimary or Theme.TextSecondary,
            TextSize = 13,
            Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 13,
        })
        
        local check = U.new("TextLabel", {
            Name = "Check",
            Parent = optFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -26, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            Text = isSel and "✓" or "",
            TextColor3 = Theme.AccentLight,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            ZIndex = 13,
        })
        
        local optBtn = U.new("TextButton", {
            Parent = optFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 14,
        })
        
        optBtn.MouseEnter:Connect(function()
            U.tween(optFrame, {BackgroundColor3 = Theme.DropdownHover, BackgroundTransparency = 0.15}, 0.12)
        end)
        optBtn.MouseLeave:Connect(function()
            local cs = multiSelect and selected[text] or selected == text
            U.tween(optFrame, {
                BackgroundColor3 = cs and Theme.DropdownSelected or Theme.DropdownBg,
                BackgroundTransparency = cs and 0.3 or 0.1,
            }, 0.15)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            if multiSelect then
                selected[text] = not selected[text]
                local now = selected[text]
                U.tween(optFrame, {
                    BackgroundColor3 = now and Theme.DropdownSelected or Theme.DropdownBg,
                    BackgroundTransparency = now and 0.3 or 0.1,
                }, 0.15)
                optLabel.Font = now and Enum.Font.GothamBold or Enum.Font.GothamMedium
                U.tween(optLabel, {TextColor3 = now and Theme.TextPrimary or Theme.TextSecondary}, 0.15)
                check.Text = now and "✓" or ""
                selectedText.Text = getDisplayText()
                local result = {}
                for k, v in pairs(selected) do if v then table.insert(result, k) end end
                task.spawn(callback, result)
            else
                -- Deselect all
                for _, of in ipairs(optionFrames) do
                    local l = of.Frame:FindFirstChild("Label")
                    local c = of.Frame:FindFirstChild("Check")
                    U.tween(of.Frame, {BackgroundColor3 = Theme.DropdownBg, BackgroundTransparency = 0.1}, 0.15)
                    if l then l.Font = Enum.Font.GothamMedium; U.tween(l, {TextColor3 = Theme.TextSecondary}, 0.15) end
                    if c then c.Text = "" end
                end
                selected = text
                U.tween(optFrame, {BackgroundColor3 = Theme.DropdownSelected, BackgroundTransparency = 0.3}, 0.15)
                optLabel.Font = Enum.Font.GothamBold
                U.tween(optLabel, {TextColor3 = Theme.TextPrimary}, 0.15)
                check.Text = "✓"
                selectedText.Text = getDisplayText()
                task.spawn(callback, selected)
                task.delay(0.12, function() if isOpen then toggleDropdown() end end)
            end
        end)
        
        table.insert(optionFrames, {Frame = optFrame, Text = text})
    end
    
    for i, opt in ipairs(options) do createOptionBtn(opt, i) end
    
    -- Header click
    local headerBtn = U.new("TextButton", {
        Parent = card,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, headerH),
        Text = "",
        ZIndex = 15,
    })
    headerBtn.MouseButton1Click:Connect(toggleDropdown)
    
    headerBtn.MouseEnter:Connect(function()
        if not isOpen then
            U.tween(card, {BackgroundColor3 = Theme.CardHover, BackgroundTransparency = Theme.CardHoverTransparency}, 0.15)
        end
        if config.Tooltip then self._window._tooltip:Show(config.Tooltip) end
    end)
    headerBtn.MouseLeave:Connect(function()
        if not isOpen then
            U.tween(card, {BackgroundColor3 = Theme.CardBackground, BackgroundTransparency = Theme.CardBackgroundTransparency}, 0.2)
        end
        if config.Tooltip then self._window._tooltip:Hide() end
    end)
    
    local api = {
        GetSelected = function()
            if multiSelect then
                local r = {}; for k, v in pairs(selected) do if v then table.insert(r, k) end end; return r
            end
            return selected
        end,
        SetSelected = function(_, v, skip)
            if multiSelect then
                selected = {}
                if type(v) == "table" then for _, x in ipairs(v) do selected[x] = true end end
            else
                selected = v
            end
            selectedText.Text = getDisplayText()
            if not skip then
                if multiSelect then
                    local r = {}; for k, s in pairs(selected) do if s then table.insert(r, k) end end
                    task.spawn(callback, r)
                else
                    task.spawn(callback, selected)
                end
            end
        end,
        Refresh = function(_, newOpts, keep)
            options = newOpts
            for _, of in ipairs(optionFrames) do of.Frame:Destroy() end
            optionFrames = {}
            if not keep then
                selected = multiSelect and {} or nil
                selectedText.Text = getDisplayText()
            end
            for i, opt in ipairs(options) do createOptionBtn(opt, i) end
            if isOpen then
                local optH = math.min(#options * 32 + 12, 180)
                card.Size = UDim2.new(1, 0, 0, headerH + optH)
            end
        end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Input
function Tab:AddInput(config)
    config = config or {}
    local callback = config.Callback or function() end
    local changedCb = config.Changed
    local numeric = config.Numeric or false
    local order = #self._elements + 1
    
    local card, nameLabel = createCard(self._content, {
        Type = "Input", Name = config.Name, Description = config.Description,
        Order = order, RightWidth = 0,
    })
    
    -- Resize name to left half
    nameLabel.Size = UDim2.new(0.42, -Theme.InnerPadding, 0, card.Size.Y.Offset)
    if config.Description then
        nameLabel.Size = UDim2.new(0.42, -Theme.InnerPadding, 0, 20)
    end
    
    -- Input container
    local inputContainer = U.new("Frame", {
        Parent = card,
        BackgroundColor3 = Theme.DropdownBg,
        Position = UDim2.new(0.42, 4, 0.5, 0),
        Size = UDim2.new(0.58, -(Theme.InnerPadding + 4), 0, 28),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 12,
    })
    U.corner(inputContainer, UDim.new(0, 6))
    local inputStroke = U.stroke(inputContainer, Theme.Border, 1, 0.6)
    
    local textBox = U.new("TextBox", {
        Parent = inputContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 1, 0),
        Position = UDim2.new(0, 7, 0, 0),
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "Type...",
        PlaceholderColor3 = Theme.TextQuaternary,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = config.ClearOnFocus or false,
        ClipsDescendants = true,
        ZIndex = 13,
    })
    
    textBox.Focused:Connect(function()
        U.tween(inputStroke, {Color = Theme.AccentMid, Transparency = 0.2}, 0.15)
        U.tween(inputContainer, {BackgroundColor3 = Theme.SidebarBackground}, 0.15)
    end)
    textBox.FocusLost:Connect(function(enter)
        U.tween(inputStroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
        U.tween(inputContainer, {BackgroundColor3 = Theme.DropdownBg}, 0.2)
        local t = textBox.Text
        if numeric then t = tonumber(t) or 0; textBox.Text = tostring(t) end
        if enter then task.spawn(callback, t) end
    end)
    
    if changedCb then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            if numeric then
                local cleaned = textBox.Text:gsub("[^%d%.%-]", "")
                if cleaned ~= textBox.Text then textBox.Text = cleaned end
            end
            task.spawn(changedCb, textBox.Text)
        end)
    end
    
    if config.Tooltip then
        card.MouseEnter:Connect(function() self._window._tooltip:Show(config.Tooltip) end)
        card.MouseLeave:Connect(function() self._window._tooltip:Hide() end)
    end
    
    local api = {
        GetValue = function() return textBox.Text end,
        SetValue = function(_, v) textBox.Text = tostring(v) end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- Keybind
function Tab:AddKeybind(config)
    config = config or {}
    local currentKey = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local changedCb = config.Changed or function() end
    local listening = false
    local order = #self._elements + 1
    
    local card = createCard(self._content, {
        Type = "Keybind", Name = config.Name, Description = config.Description,
        Order = order, RightWidth = 70,
    })
    
    local function keyName(key)
        if key == Enum.KeyCode.Unknown then return "None" end
        return key.Name:gsub("Left", "L"):gsub("Right", "R"):gsub("Control", "Ctrl"):gsub("Shift", "Shft")
    end
    
    -- Key display
    local keyBtn = U.new("TextButton", {
        Parent = card,
        BackgroundColor3 = Theme.DropdownBg,
        Position = UDim2.new(1, -Theme.InnerPadding, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        AnchorPoint = Vector2.new(1, 0.5),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12,
    })
    U.corner(keyBtn, UDim.new(0, 6))
    U.padding(keyBtn, 0, 0, 10, 10)
    local keyStroke = U.stroke(keyBtn, Theme.Border, 1, 0.5)
    
    local keyLabel = U.new("TextLabel", {
        Parent = keyBtn,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text = keyName(currentKey),
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 13,
    })
    
    keyBtn.MouseEnter:Connect(function()
        U.tween(keyStroke, {Color = Theme.AccentMid, Transparency = 0.3}, 0.15)
    end)
    keyBtn.MouseLeave:Connect(function()
        if not listening then U.tween(keyStroke, {Color = Theme.Border, Transparency = 0.5}, 0.2) end
    end)
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyLabel.Text = "..."
        U.tween(keyBtn, {BackgroundColor3 = Theme.AccentDark}, 0.15)
        U.tween(keyLabel, {TextColor3 = Theme.TextPrimary}, 0.15)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or input.KeyCode
                listening = false
                keyLabel.Text = keyName(currentKey)
                U.tween(keyBtn, {BackgroundColor3 = Theme.DropdownBg}, 0.2)
                U.tween(keyLabel, {TextColor3 = Theme.TextSecondary}, 0.2)
                U.tween(keyStroke, {Color = Theme.Border, Transparency = 0.5}, 0.2)
                task.spawn(changedCb, currentKey)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and not gp then
            if input.KeyCode == currentKey then task.spawn(callback) end
        end
    end)
    
    if config.Tooltip then
        card.MouseEnter:Connect(function() self._window._tooltip:Show(config.Tooltip) end)
        card.MouseLeave:Connect(function() self._window._tooltip:Hide() end)
    end
    
    local api = {
        GetKey = function() return currentKey end,
        SetKey = function(_, k) currentKey = k; keyLabel.Text = keyName(k) end,
        Destroy = function(_) card:Destroy() end,
    }
    table.insert(self._elements, api)
    return api
end

-- ═══════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ═══════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window._new(config)
    local self = setmetatable({}, Window)
    self._title = config.Title or "Frost UI"
    self._subtitle = config.Subtitle or ""
    self._size = config.Size or UDim2.new(0, 560, 0, 400)
    self._tabs = {}
    self._activeTab = nil
    self._minimized = false
    self._visible = true
    
    -- Screen GUI
    local guiParent = Player:WaitForChild("PlayerGui")
    pcall(function()
        if syn and syn.protect_gui then guiParent = CoreGui end
    end)
    
    self._gui = U.new("ScreenGui", {
        Name = "FrostUI_" .. U.uid(),
        Parent = guiParent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
    })
    pcall(function() if syn then syn.protect_gui(self._gui) end end)
    
    -- Main frame
    self._main = U.new("Frame", {
        Name = "Main",
        Parent = self._gui,
        BackgroundColor3 = Theme.WindowBackground,
        BackgroundTransparency = Theme.WindowBackgroundTransparency,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        ZIndex = 1,
    })
    U.corner(self._main, UDim.new(0, 14))
    U.stroke(self._main, Theme.Border, 1, 0.4)
    
    -- ═══════════════════════════════════
    -- TITLE BAR
    -- ═══════════════════════════════════
    self._titleBar = U.new("Frame", {
        Parent = self._main,
        BackgroundColor3 = Theme.TitleBarBackground,
        BackgroundTransparency = Theme.TitleBarTransparency,
        Size = UDim2.new(1, 0, 0, Theme.TitleBarHeight),
        BorderSizePixel = 0,
        ZIndex = 30,
    })
    -- Cover bottom corners
    U.new("Frame", {
        Parent = self._titleBar,
        BackgroundColor3 = Theme.TitleBarBackground,
        BackgroundTransparency = Theme.TitleBarTransparency,
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BorderSizePixel = 0,
        ZIndex = 30,
    })
    U.corner(self._titleBar, UDim.new(0, 14))
    
    -- Bottom divider
    U.new("Frame", {
        Parent = self._titleBar,
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = Theme.DividerTransparency,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
        ZIndex = 31,
    })
    
    -- App icon
    local appIcon = U.new("Frame", {
        Parent = self._titleBar,
        BackgroundColor3 = Theme.AccentMid,
        BackgroundTransparency = 0.15,
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 32,
    })
    U.corner(appIcon, UDim.new(0, 7))
    
    U.new("TextLabel", {
        Parent = appIcon,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = string.sub(self._title, 1, 1):upper(),
        TextColor3 = Theme.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 33,
    })
    
    -- Title
    U.new("TextLabel", {
        Parent = self._titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, self._subtitle ~= "" and 6 or 0),
        Size = UDim2.new(0.5, -50, 0, self._subtitle ~= "" and 18 or Theme.TitleBarHeight),
        Text = self._title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31,
    })
    
    if self._subtitle ~= "" then
        U.new("TextLabel", {
            Parent = self._titleBar,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 26),
            Size = UDim2.new(0.5, -50, 0, 14),
            Text = self._subtitle,
            TextColor3 = Theme.TextQuaternary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 31,
        })
    end
    
    -- Window controls (macOS style dots)
    local controls = U.new("Frame", {
        Parent = self._titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 46, 0, 14),
        AnchorPoint = Vector2.new(1, 0.5),
        ZIndex = 32,
    })
    U.list(controls, 8, Enum.FillDirection.Horizontal)
    
    local minBtn = U.new("TextButton", {
        Parent = controls,
        BackgroundColor3 = Color3.fromRGB(180, 170, 60),
        Size = UDim2.new(0, 14, 0, 14),
        Text = "", AutoButtonColor = false,
        LayoutOrder = 1, ZIndex = 33,
    })
    U.corner(minBtn, UDim.new(1, 0))
    
    local closeBtn = U.new("TextButton", {
        Parent = controls,
        BackgroundColor3 = Color3.fromRGB(180, 70, 60),
        Size = UDim2.new(0, 14, 0, 14),
        Text = "", AutoButtonColor = false,
        LayoutOrder = 2, ZIndex = 33,
    })
    U.corner(closeBtn, UDim.new(1, 0))
    
    -- Hover animations
    for _, b in ipairs({minBtn, closeBtn}) do
        b.MouseEnter:Connect(function() U.spring(b, {Size = UDim2.new(0, 16, 0, 16)}, 0.25) end)
        b.MouseLeave:Connect(function() U.spring(b, {Size = UDim2.new(0, 14, 0, 14)}, 0.25) end)
    end
    
    -- ═══════════════════════════════════
    -- SIDEBAR
    -- ═══════════════════════════════════
    self._sidebar = U.new("Frame", {
        Parent = self._main,
        BackgroundColor3 = Theme.SidebarBackground,
        BackgroundTransparency = Theme.SidebarBackgroundTransparency,
        Size = UDim2.new(0, Theme.SidebarWidth, 1, -Theme.TitleBarHeight),
        Position = UDim2.new(0, 0, 0, Theme.TitleBarHeight),
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    
    -- Sidebar right divider
    U.new("Frame", {
        Parent = self._sidebar,
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = Theme.DividerTransparency,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    
    self._tabList = U.new("ScrollingFrame", {
        Parent = self._sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        ZIndex = 4,
    })
    U.list(self._tabList, 3)
    
    -- ═══════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════
    self._contentArea = U.new("Frame", {
        Parent = self._main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -Theme.SidebarWidth, 1, -Theme.TitleBarHeight),
        Position = UDim2.new(0, Theme.SidebarWidth, 0, Theme.TitleBarHeight),
        ZIndex = 2,
    })
    
    -- ═══════════════════════════════════
    -- SYSTEMS
    -- ═══════════════════════════════════
    self._tooltip = Tooltip.init(self._gui)
    self._notifs = Notifications.init(self._gui)
    
    -- ═══════════════════════════════════
    -- DRAGGING
    -- ═══════════════════════════════════
    local dragging, dragStart, startPos = false, nil, nil
    
    self._titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self._main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            U.tween(self._main, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            }, 0.06, Enum.EasingStyle.Quad)
        end
    end)
    
    -- ═══════════════════════════════════
    -- MINIMIZE
    -- ═══════════════════════════════════
    minBtn.MouseButton1Click:Connect(function()
        self._minimized = not self._minimized
        U.tween(self._main, {
            Size = self._minimized and UDim2.new(0, self._size.X.Offset, 0, Theme.TitleBarHeight) or self._size,
        }, 0.35)
    end)
    
    -- ═══════════════════════════════════
    -- CLOSE
    -- ═══════════════════════════════════
    closeBtn.MouseButton1Click:Connect(function()
        U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35)
        task.delay(0.35, function() self._gui:Destroy() end)
    end)
    
    -- ═══════════════════════════════════
    -- TOGGLE KEYBIND
    -- ═══════════════════════════════════
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            self._visible = not self._visible
            if self._visible then
                self._gui.Enabled = true
                self._main.Size = UDim2.new(0, 0, 0, 0)
                U.spring(self._main, {Size = self._size}, 0.45)
            else
                U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
                task.delay(0.25, function() self._gui.Enabled = false end)
            end
        end
    end)
    
    -- ═══════════════════════════════════
    -- OPEN ANIMATION
    -- ═══════════════════════════════════
    self._main.BackgroundTransparency = 1
    task.delay(0.03, function()
        U.tween(self._main, {BackgroundTransparency = Theme.WindowBackgroundTransparency}, 0.25)
        U.spring(self._main, {Size = self._size}, 0.5)
    end)
    
    return self
end

function Window:CreateTab(config)
    local tab = Tab._new(self, config or {})
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self._activeTab == tab then return end
    if self._activeTab then self._activeTab:_hide() end
    self._activeTab = tab
    tab:_show()
end

function Window:Notify(config)
    self._notifs:Push(config)
end

function Window:Destroy()
    U.tween(self._main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.3, function() self._gui:Destroy() end)
end

-- ═══════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════
function Frost:CreateWindow(config)
    return Window._new(config or {})
end

return Frost
