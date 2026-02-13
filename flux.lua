--[[
    ◆ Flux UI Library ◆
    Modern iOS-Inspired UI Library for Roblox
    Version: 2.0.0
]]

local Flux = {}
Flux.__index = Flux

-- ══════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ══════════════════════════════════════════════════════════
-- THEMES
-- ══════════════════════════════════════════════════════════
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 18),
        SecondaryBackground = Color3.fromRGB(22, 22, 28),
        TertiaryBackground = Color3.fromRGB(30, 30, 38),
        CardBackground = Color3.fromRGB(26, 26, 34),
        CardBackgroundHover = Color3.fromRGB(32, 32, 42),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(105, 117, 255),
        AccentDark = Color3.fromRGB(68, 81, 222),
        Text = Color3.fromRGB(235, 235, 245),
        TextSecondary = Color3.fromRGB(155, 155, 170),
        TextTertiary = Color3.fromRGB(100, 100, 115),
        Divider = Color3.fromRGB(40, 40, 50),
        DividerLight = Color3.fromRGB(35, 35, 45),
        ToggleOn = Color3.fromRGB(52, 199, 89),
        ToggleOff = Color3.fromRGB(55, 55, 65),
        ToggleKnob = Color3.fromRGB(255, 255, 255),
        SliderFill = Color3.fromRGB(88, 101, 242),
        SliderTrack = Color3.fromRGB(45, 45, 55),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        DropdownBackground = Color3.fromRGB(20, 20, 26),
        DropdownHover = Color3.fromRGB(35, 35, 45),
        ScrollBar = Color3.fromRGB(60, 60, 75),
        Shadow = Color3.fromRGB(0, 0, 0),
        NotificationSuccess = Color3.fromRGB(52, 199, 89),
        NotificationError = Color3.fromRGB(255, 69, 58),
        NotificationWarning = Color3.fromRGB(255, 159, 10),
        NotificationInfo = Color3.fromRGB(88, 101, 242),
        TabActive = Color3.fromRGB(88, 101, 242),
        TabInactive = Color3.fromRGB(40, 40, 50),
        Border = Color3.fromRGB(45, 45, 55),
    },
    Light = {
        Background = Color3.fromRGB(242, 242, 247),
        SecondaryBackground = Color3.fromRGB(255, 255, 255),
        TertiaryBackground = Color3.fromRGB(235, 235, 240),
        CardBackground = Color3.fromRGB(255, 255, 255),
        CardBackgroundHover = Color3.fromRGB(245, 245, 250),
        Accent = Color3.fromRGB(0, 122, 255),
        AccentHover = Color3.fromRGB(30, 142, 255),
        AccentDark = Color3.fromRGB(0, 100, 220),
        Text = Color3.fromRGB(28, 28, 30),
        TextSecondary = Color3.fromRGB(99, 99, 102),
        TextTertiary = Color3.fromRGB(142, 142, 147),
        Divider = Color3.fromRGB(218, 218, 222),
        DividerLight = Color3.fromRGB(228, 228, 232),
        ToggleOn = Color3.fromRGB(52, 199, 89),
        ToggleOff = Color3.fromRGB(200, 200, 208),
        ToggleKnob = Color3.fromRGB(255, 255, 255),
        SliderFill = Color3.fromRGB(0, 122, 255),
        SliderTrack = Color3.fromRGB(210, 210, 218),
        SliderKnob = Color3.fromRGB(255, 255, 255),
        DropdownBackground = Color3.fromRGB(255, 255, 255),
        DropdownHover = Color3.fromRGB(240, 240, 245),
        ScrollBar = Color3.fromRGB(180, 180, 190),
        Shadow = Color3.fromRGB(0, 0, 0),
        NotificationSuccess = Color3.fromRGB(52, 199, 89),
        NotificationError = Color3.fromRGB(255, 59, 48),
        NotificationWarning = Color3.fromRGB(255, 149, 0),
        NotificationInfo = Color3.fromRGB(0, 122, 255),
        TabActive = Color3.fromRGB(0, 122, 255),
        TabInactive = Color3.fromRGB(230, 230, 235),
        Border = Color3.fromRGB(210, 210, 218),
    }
}

-- ══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════
local Utility = {}

function Utility:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.3,
            easingStyle or Enum.EasingStyle.Quart,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

function Utility:Spring(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.45,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

function Utility:Ripple(button, theme)
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1,
    })
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple,
    })
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Utility:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    task.delay(0.6, function()
        ripple:Destroy()
    end)
end

function Utility:AddShadow(instance, transparency, size)
    local shadow = Utility:Create("ImageLabel", {
        Name = "Shadow",
        Parent = instance,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, size or 24, 1, size or 24),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = instance.ZIndex - 1,
    })
    return shadow
end

function Utility:GenerateUID()
    return HttpService:GenerateGUID(false)
end

-- ══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui, theme)
    local self = setmetatable({}, NotificationSystem)
    self.Theme = theme
    self.Notifications = {}
    self.Container = Utility:Create("Frame", {
        Name = "NotificationContainer",
        Parent = screenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 320, 1, -40),
        AnchorPoint = Vector2.new(1, 1),
        ZIndex = 1000,
    })
    Utility:Create("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    })
    return self
end

function NotificationSystem:Push(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 4
    local type_ = config.Type or "Info"
    local theme = self.Theme

    local accentColor
    if type_ == "Success" then accentColor = theme.NotificationSuccess
    elseif type_ == "Error" then accentColor = theme.NotificationError
    elseif type_ == "Warning" then accentColor = theme.NotificationWarning
    else accentColor = theme.NotificationInfo end

    local iconText
    if type_ == "Success" then iconText = "✓"
    elseif type_ == "Error" then iconText = "✕"
    elseif type_ == "Warning" then iconText = "⚠"
    else iconText = "ℹ" end

    local notifFrame = Utility:Create("Frame", {
        Name = "Notification",
        Parent = self.Container,
        BackgroundColor3 = theme.CardBackground,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        ZIndex = 1001,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = notifFrame})
    Utility:Create("UIStroke", {Parent = notifFrame, Color = theme.Border, Thickness = 1, Transparency = 0.5})
    Utility:AddShadow(notifFrame, 0.6, 30)

    Utility:Create("Frame", {
        Name = "AccentBar", Parent = notifFrame,
        BackgroundColor3 = accentColor,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0, ZIndex = 1002,
    })

    local contentFrame = Utility:Create("Frame", {
        Name = "Content", Parent = notifFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 16, 0, 0),
        ZIndex = 1002,
    })
    Utility:Create("UIPadding", {
        Parent = contentFrame,
        PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingRight = UDim.new(0, 10),
    })
    Utility:Create("UIListLayout", {Parent = contentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

    local headerRow = Utility:Create("Frame", {
        Name = "HeaderRow", Parent = contentFrame,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = 1, ZIndex = 1002,
    })

    local iconLabel = Utility:Create("TextLabel", {
        Parent = headerRow, BackgroundColor3 = accentColor, BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), Text = iconText,
        TextColor3 = accentColor, TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 1003,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = iconLabel})

    Utility:Create("TextLabel", {
        Parent = headerRow, BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0.5, 0), Size = UDim2.new(1, -60, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5), Text = title,
        TextColor3 = theme.Text, TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 1003,
    })

    local closeBtn = Utility:Create("TextButton", {
        Parent = headerRow, BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, 0), Size = UDim2.new(0, 20, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5), Text = "✕",
        TextColor3 = theme.TextTertiary, TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 1003,
    })

    Utility:Create("TextLabel", {
        Parent = contentFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Text = message, TextColor3 = theme.TextSecondary,
        TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, LayoutOrder = 2, ZIndex = 1003,
    })

    local progressBar = Utility:Create("Frame", {
        Parent = notifFrame, BackgroundColor3 = accentColor, BackgroundTransparency = 0.6,
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0, ZIndex = 1003,
    })

    notifFrame.Position = UDim2.new(1, 50, 0, 0)
    Utility:Spring(notifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
    Utility:Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    local function closeNotification()
        Utility:Tween(notifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.35)
        task.delay(0.35, function() notifFrame:Destroy() end)
    end

    closeBtn.MouseButton1Click:Connect(closeNotification)
    closeBtn.MouseEnter:Connect(function() Utility:Tween(closeBtn, {TextColor3 = theme.Text}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() Utility:Tween(closeBtn, {TextColor3 = theme.TextTertiary}, 0.2) end)

    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then closeNotification() end
    end)

    table.insert(self.Notifications, notifFrame)
    return notifFrame
end

-- ══════════════════════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ══════════════════════════════════════════════════════════
local TooltipSystem = {}
TooltipSystem.__index = TooltipSystem

function TooltipSystem.new(screenGui, theme)
    local self = setmetatable({}, TooltipSystem)
    self.Theme = theme

    self.TooltipFrame = Utility:Create("Frame", {
        Name = "Tooltip", Parent = screenGui,
        BackgroundColor3 = theme.CardBackground,
        Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false, ZIndex = 2000,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.TooltipFrame})
    Utility:Create("UIStroke", {Parent = self.TooltipFrame, Color = theme.Border, Thickness = 1, Transparency = 0.3})
    Utility:Create("UIPadding", {
        Parent = self.TooltipFrame,
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
    })
    Utility:AddShadow(self.TooltipFrame, 0.7, 16)

    self.TooltipLabel = Utility:Create("TextLabel", {
        Parent = self.TooltipFrame, BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        Text = "", TextColor3 = theme.TextSecondary, TextSize = 12,
        Font = Enum.Font.Gotham, TextWrapped = true, ZIndex = 2001,
    })
    Utility:Create("UISizeConstraint", {Parent = self.TooltipFrame, MaxSize = Vector2.new(250, 200)})

    return self
end

function TooltipSystem:Show(text, position)
    self.TooltipLabel.Text = text
    self.TooltipFrame.Position = UDim2.new(0, position.X + 10, 0, position.Y - 10)
    self.TooltipFrame.Visible = true
    self.TooltipFrame.BackgroundTransparency = 1
    self.TooltipLabel.TextTransparency = 1
    Utility:Tween(self.TooltipFrame, {BackgroundTransparency = 0}, 0.2)
    Utility:Tween(self.TooltipLabel, {TextTransparency = 0}, 0.2)
end

function TooltipSystem:Hide()
    Utility:Tween(self.TooltipFrame, {BackgroundTransparency = 1}, 0.15)
    Utility:Tween(self.TooltipLabel, {TextTransparency = 1}, 0.15)
    task.delay(0.15, function() self.TooltipFrame.Visible = false end)
end

function TooltipSystem:Track()
    RunService.RenderStepped:Connect(function()
        if self.TooltipFrame.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            self.TooltipFrame.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y - 5)
        end
    end)
end

-- ══════════════════════════════════════════════════════════
-- TAB CLASS
-- ══════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(window, config)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Theme = window.Theme
    self.Name = config.Name or "Tab"
    self.Icon = config.Icon or ""
    self.Elements = {}
    self.Visible = false
    self.UID = Utility:GenerateUID()

    self.TabButton = Utility:Create("TextButton", {
        Name = "TabBtn_" .. self.Name, Parent = window._TabList,
        BackgroundColor3 = self.Theme.TabInactive, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42), Text = "", AutoButtonColor = false, ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.TabButton})

    if self.Icon ~= "" then
        self.TabIcon = Utility:Create("ImageLabel", {
            Parent = self.TabButton, BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.new(0, 18, 0, 18),
            AnchorPoint = Vector2.new(0, 0.5), Image = self.Icon,
            ImageColor3 = self.Theme.TextSecondary, ZIndex = 6,
        })
    end

    self.TabLabel = Utility:Create("TextLabel", {
        Parent = self.TabButton, BackgroundTransparency = 1,
        Position = UDim2.new(0, self.Icon ~= "" and 40 or 14, 0, 0),
        Size = UDim2.new(1, self.Icon ~= "" and -54 or -28, 1, 0),
        Text = self.Name, TextColor3 = self.Theme.TextSecondary,
        TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
    })

    self.ActiveIndicator = Utility:Create("Frame", {
        Parent = self.TabButton, BackgroundColor3 = self.Theme.Accent,
        Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 7,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = self.ActiveIndicator})

    self.ContentFrame = Utility:Create("ScrollingFrame", {
        Name = "Content_" .. self.Name, Parent = window._ContentContainer,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.ScrollBar, ScrollBarImageTransparency = 0.5,
        Visible = false, BorderSizePixel = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 4,
    })
    Utility:Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
    })
    Utility:Create("UIListLayout", {Parent = self.ContentFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

    self.TabButton.MouseEnter:Connect(function()
        if not self.Visible then Utility:Tween(self.TabButton, {BackgroundTransparency = 0.7}, 0.2) end
    end)
    self.TabButton.MouseLeave:Connect(function()
        if not self.Visible then Utility:Tween(self.TabButton, {BackgroundTransparency = 1}, 0.2) end
    end)
    self.TabButton.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)

    return self
end

function Tab:Show()
    self.Visible = true
    self.ContentFrame.Visible = true
    Utility:Tween(self.TabButton, {BackgroundColor3 = self.Theme.Accent, BackgroundTransparency = 0.85}, 0.3)
    Utility:Tween(self.TabLabel, {TextColor3 = self.Theme.Text}, 0.3)
    Utility:Tween(self.ActiveIndicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.3, Enum.EasingStyle.Back)
    if self.TabIcon then Utility:Tween(self.TabIcon, {ImageColor3 = self.Theme.Accent}, 0.3) end
    self.ContentFrame.CanvasPosition = Vector2.new(0, 0)
    for i, element in ipairs(self.ContentFrame:GetChildren()) do
        if element:IsA("Frame") then
            element.BackgroundTransparency = 1
            task.delay(i * 0.02, function()
                Utility:Tween(element, {BackgroundTransparency = 0}, 0.3)
            end)
        end
    end
end

function Tab:Hide()
    self.Visible = false
    self.ContentFrame.Visible = false
    Utility:Tween(self.TabButton, {BackgroundColor3 = self.Theme.TabInactive, BackgroundTransparency = 1}, 0.3)
    Utility:Tween(self.TabLabel, {TextColor3 = self.Theme.TextSecondary}, 0.3)
    Utility:Tween(self.ActiveIndicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.25)
    if self.TabIcon then Utility:Tween(self.TabIcon, {ImageColor3 = self.Theme.TextSecondary}, 0.3) end
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Label
-- ══════════════════════════════════════════════════════════
function Tab:AddLabel(config)
    config = config or {}
    local text = config.Text or "Label"
    local theme = self.Theme
    local order = #self.Elements + 1

    local labelFrame = Utility:Create("Frame", {
        Name = "Label_" .. order, Parent = self.ContentFrame,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
        LayoutOrder = order, ZIndex = 4,
    })
    local labelText = Utility:Create("TextLabel", {
        Parent = labelFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = text,
        TextColor3 = theme.TextTertiary, TextSize = 12,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    local api = {
        Frame = labelFrame,
        SetText = function(_, t) labelText.Text = t end,
        Destroy = function(_) labelFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Section Header
-- ══════════════════════════════════════════════════════════
function Tab:AddSection(config)
    config = config or {}
    local text = config.Name or "Section"
    local theme = self.Theme
    local order = #self.Elements + 1

    local sectionFrame = Utility:Create("Frame", {
        Name = "Section_" .. text, Parent = self.ContentFrame,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = order, ZIndex = 4,
    })
    local sectionLabel = Utility:Create("TextLabel", {
        Parent = sectionFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X, Text = string.upper(text),
        TextColor3 = theme.Accent, TextSize = 11,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    local api = {
        Frame = sectionFrame,
        SetText = function(_, t) sectionLabel.Text = string.upper(t) end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Separator
-- ══════════════════════════════════════════════════════════
function Tab:AddSeparator()
    local theme = self.Theme
    local order = #self.Elements + 1

    local sepFrame = Utility:Create("Frame", {
        Name = "Separator_" .. order, Parent = self.ContentFrame,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 12),
        LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("Frame", {
        Parent = sepFrame, BackgroundColor3 = theme.Divider,
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0, ZIndex = 5,
    })

    local api = {Frame = sepFrame}
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Button
-- ══════════════════════════════════════════════════════════
function Tab:AddButton(config)
    config = config or {}
    local name = config.Name or "Button"
    local description = config.Description
    local callback = config.Callback or function() end
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local height = description and 58 or 42

    local buttonFrame = Utility:Create("Frame", {
        Name = "Button_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order, ClipsDescendants = true, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = buttonFrame})
    Utility:Create("UIStroke", {Parent = buttonFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    local buttonLabel = Utility:Create("TextLabel", {
        Parent = buttonFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, description and 10 or 0),
        Size = UDim2.new(1, -80, 0, description and 22 or height),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = buttonFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(1, -80, 0, 16),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        })
    end

    local actionIcon = Utility:Create("TextLabel", {
        Parent = buttonFrame, BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0.5, 0), Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5), Text = "›",
        TextColor3 = theme.TextTertiary, TextSize = 22, Font = Enum.Font.GothamBold, ZIndex = 5,
    })

    local button = Utility:Create("TextButton", {
        Parent = buttonFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 6,
    })

    if tooltip then
        button.MouseEnter:Connect(function()
            self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation())
        end)
        button.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    button.MouseEnter:Connect(function()
        Utility:Tween(buttonFrame, {BackgroundColor3 = theme.CardBackgroundHover}, 0.2)
        Utility:Tween(actionIcon, {TextColor3 = theme.Accent, Position = UDim2.new(1, -36, 0.5, 0)}, 0.2)
    end)
    button.MouseLeave:Connect(function()
        Utility:Tween(buttonFrame, {BackgroundColor3 = theme.CardBackground}, 0.2)
        Utility:Tween(actionIcon, {TextColor3 = theme.TextTertiary, Position = UDim2.new(1, -40, 0.5, 0)}, 0.2)
    end)
    button.MouseButton1Click:Connect(function()
        Utility:Ripple(buttonFrame, theme)
        Utility:Tween(buttonFrame, {BackgroundColor3 = theme.Accent}, 0.1)
        Utility:Tween(buttonLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
        task.delay(0.15, function()
            Utility:Tween(buttonFrame, {BackgroundColor3 = theme.CardBackground}, 0.3)
            Utility:Tween(buttonLabel, {TextColor3 = theme.Text}, 0.3)
        end)
        task.spawn(callback)
    end)

    local api = {
        Frame = buttonFrame,
        SetName = function(_, n) buttonLabel.Text = n end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) buttonFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Toggle
-- ══════════════════════════════════════════════════════════
function Tab:AddToggle(config)
    config = config or {}
    local name = config.Name or "Toggle"
    local description = config.Description
    local default = config.Default or false
    local callback = config.Callback or function() end
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local state = default
    local height = description and 58 or 42

    local toggleFrame = Utility:Create("Frame", {
        Name = "Toggle_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = toggleFrame})
    Utility:Create("UIStroke", {Parent = toggleFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    Utility:Create("TextLabel", {
        Parent = toggleFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, description and 10 or 0),
        Size = UDim2.new(1, -80, 0, description and 22 or height),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = toggleFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(1, -80, 0, 16),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        })
    end

    local toggleSwitch = Utility:Create("Frame", {
        Parent = toggleFrame, BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff,
        Position = UDim2.new(1, -62, 0.5, 0), Size = UDim2.new(0, 46, 0, 28),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleSwitch})

    local knob = Utility:Create("Frame", {
        Parent = toggleSwitch, BackgroundColor3 = theme.ToggleKnob,
        Position = state and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    Utility:AddShadow(knob, 0.7, 8)

    local function updateToggle(newState, skipCallback)
        state = newState
        Utility:Tween(toggleSwitch, {BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff}, 0.25)
        Utility:Spring(knob, {Position = state and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.35)
        Utility:Tween(knob, {Size = UDim2.new(0, 26, 0, 22)}, 0.1)
        task.delay(0.1, function() Utility:Spring(knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.3) end)
        if not skipCallback then task.spawn(callback, state) end
    end

    local clickArea = Utility:Create("TextButton", {
        Parent = toggleFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 7,
    })

    if tooltip then
        clickArea.MouseEnter:Connect(function()
            self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation())
        end)
        clickArea.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    clickArea.MouseEnter:Connect(function()
        Utility:Tween(toggleFrame, {BackgroundColor3 = theme.CardBackgroundHover}, 0.2)
    end)
    clickArea.MouseLeave:Connect(function()
        Utility:Tween(toggleFrame, {BackgroundColor3 = theme.CardBackground}, 0.2)
    end)
    clickArea.MouseButton1Click:Connect(function() updateToggle(not state) end)

    if default then task.spawn(callback, true) end

    local api = {
        Frame = toggleFrame,
        GetState = function() return state end,
        SetState = function(_, s, skip) updateToggle(s, skip) end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) toggleFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Slider
-- ══════════════════════════════════════════════════════════
function Tab:AddSlider(config)
    config = config or {}
    local name = config.Name or "Slider"
    local description = config.Description
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local increment = config.Increment or 1
    local suffix = config.Suffix or ""
    local callback = config.Callback or function() end
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local value = math.clamp(default, min, max)
    local dragging = false
    local height = description and 78 or 62

    local sliderFrame = Utility:Create("Frame", {
        Name = "Slider_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = sliderFrame})
    Utility:Create("UIStroke", {Parent = sliderFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    Utility:Create("TextLabel", {
        Parent = sliderFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 10), Size = UDim2.new(0.6, -16, 0, 20),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = sliderFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 28), Size = UDim2.new(1, -32, 0, 14),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        })
    end

    local valueLabel = Utility:Create("TextLabel", {
        Parent = sliderFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0.6, 0, 0, 10), Size = UDim2.new(0.4, -16, 0, 20),
        Text = tostring(value) .. suffix, TextColor3 = theme.Accent, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 5,
    })

    local trackY = description and 52 or 38
    local sliderTrack = Utility:Create("Frame", {
        Parent = sliderFrame, BackgroundColor3 = theme.SliderTrack,
        Position = UDim2.new(0, 16, 0, trackY), Size = UDim2.new(1, -32, 0, 6), ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderTrack})

    local initialPercent = (value - min) / (max - min)
    local sliderFill = Utility:Create("Frame", {
        Parent = sliderTrack, BackgroundColor3 = theme.SliderFill,
        Size = UDim2.new(initialPercent, 0, 1, 0), ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderFill})

    local fillGlow = Utility:Create("Frame", {
        Parent = sliderFill, BackgroundColor3 = theme.SliderFill,
        BackgroundTransparency = 0.6, Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 12), AnchorPoint = Vector2.new(0, 0.5), ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fillGlow})

    local sliderKnob = Utility:Create("Frame", {
        Parent = sliderTrack, BackgroundColor3 = theme.SliderKnob,
        Position = UDim2.new(initialPercent, 0, 0.5, 0), Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 8,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sliderKnob})
    Utility:AddShadow(sliderKnob, 0.6, 10)

    Utility:Create("Frame", {
        Parent = sliderKnob, BackgroundColor3 = theme.SliderFill,
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 9,
    })

    local function roundToIncrement(val)
        return math.floor(val / increment + 0.5) * increment
    end

    local function updateSlider(input)
        local percent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        value = math.clamp(roundToIncrement(min + (max - min) * percent), min, max)
        local dp = (value - min) / (max - min)
        Utility:Tween(sliderFill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.08, Enum.EasingStyle.Quad)
        Utility:Tween(sliderKnob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.08, Enum.EasingStyle.Quad)
        valueLabel.Text = tostring(value) .. suffix
        task.spawn(callback, value)
    end

    local sliderClickArea = Utility:Create("TextButton", {
        Parent = sliderTrack, BackgroundTransparency = 1,
        Size = UDim2.new(1, 20, 0, 30), Position = UDim2.new(0, -10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), Text = "", ZIndex = 10,
    })

    sliderClickArea.MouseButton1Down:Connect(function()
        dragging = true
        Utility:Spring(sliderKnob, {Size = UDim2.new(0, 22, 0, 22)}, 0.3)
        Utility:Tween(fillGlow, {BackgroundTransparency = 0.4}, 0.2)
    end)

    if tooltip then
        sliderClickArea.MouseEnter:Connect(function()
            if not dragging then self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation()) end
        end)
        sliderClickArea.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            Utility:Spring(sliderKnob, {Size = UDim2.new(0, 18, 0, 18)}, 0.3)
            Utility:Tween(fillGlow, {BackgroundTransparency = 0.6}, 0.3)
        end
    end)

    if default ~= min then task.spawn(callback, value) end

    local api = {
        Frame = sliderFrame,
        GetValue = function() return value end,
        SetValue = function(_, v, skip)
            value = math.clamp(roundToIncrement(v), min, max)
            local dp = (value - min) / (max - min)
            Utility:Tween(sliderFill, {Size = UDim2.new(dp, 0, 1, 0)}, 0.3)
            Utility:Tween(sliderKnob, {Position = UDim2.new(dp, 0, 0.5, 0)}, 0.3)
            valueLabel.Text = tostring(value) .. suffix
            if not skip then task.spawn(callback, value) end
        end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) sliderFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Dropdown
-- ══════════════════════════════════════════════════════════
function Tab:AddDropdown(config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local description = config.Description
    local options = config.Options or {}
    local default = config.Default
    local multiSelect = config.MultiSelect or false
    local callback = config.Callback or function() end
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local isOpen = false
    local selected = multiSelect and {} or default
    local headerHeight = description and 58 or 42

    if multiSelect and default and type(default) == "table" then
        for _, v in ipairs(default) do selected[v] = true end
    end

    local dropdownFrame = Utility:Create("Frame", {
        Name = "Dropdown_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, headerHeight),
        ClipsDescendants = true, LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = dropdownFrame})
    local dropdownStroke = Utility:Create("UIStroke", {
        Parent = dropdownFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7,
    })

    local headerFrame = Utility:Create("Frame", {
        Parent = dropdownFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, headerHeight), ZIndex = 5,
    })

    Utility:Create("TextLabel", {
        Parent = headerFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, description and 10 or 0),
        Size = UDim2.new(0.5, -16, 0, description and 22 or headerHeight),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = headerFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(0.5, -16, 0, 16),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6,
        })
    end

    local function getSelectedText()
        if multiSelect then
            local items = {}
            for item, sel in pairs(selected) do if sel then table.insert(items, item) end end
            if #items == 0 then return "None" end
            if #items <= 2 then return table.concat(items, ", ") end
            return items[1] .. " + " .. (#items - 1) .. " more"
        else
            return selected or "Select..."
        end
    end

    local selectedLabel = Utility:Create("TextLabel", {
        Parent = headerFrame, BackgroundColor3 = theme.TertiaryBackground,
        Position = UDim2.new(0.5, 4, 0.5, 0), Size = UDim2.new(0.5, -50, 0, 28),
        AnchorPoint = Vector2.new(0, 0.5), Text = getSelectedText(),
        TextColor3 = theme.TextSecondary, TextSize = 12, Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = selectedLabel})
    Utility:Create("UIPadding", {Parent = selectedLabel, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local chevron = Utility:Create("TextLabel", {
        Parent = headerFrame, BackgroundTransparency = 1,
        Position = UDim2.new(1, -34, 0.5, 0), Size = UDim2.new(0, 20, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5), Text = "▾",
        TextColor3 = theme.TextTertiary, TextSize = 16,
        Font = Enum.Font.GothamBold, Rotation = 0, ZIndex = 6,
    })

    local optionsContainer = Utility:Create("Frame", {
        Parent = dropdownFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, headerHeight),
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 5,
    })
    Utility:Create("UIPadding", {
        Parent = optionsContainer,
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
    })
    Utility:Create("UIListLayout", {Parent = optionsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

    local optionButtons = {}

    local toggleDropdown -- forward declaration

    local function createOption(optionText, idx)
        local isSel = multiSelect and (selected[optionText] == true) or (selected == optionText)

        local optionFrame = Utility:Create("Frame", {
            Parent = optionsContainer, BackgroundColor3 = isSel and theme.Accent or theme.DropdownBackground,
            BackgroundTransparency = isSel and 0.85 or 0,
            Size = UDim2.new(1, 0, 0, 34), LayoutOrder = idx, ZIndex = 6,
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = optionFrame})

        local optionLabel = Utility:Create("TextLabel", {
            Name = "Label", Parent = optionFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -44, 1, 0),
            Text = optionText, TextColor3 = isSel and theme.Accent or theme.Text,
            TextSize = 13, Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7,
        })

        local radioIndicator
        if not multiSelect then
            radioIndicator = Utility:Create("TextLabel", {
                Name = "Radio", Parent = optionFrame, BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5), Text = isSel and "●" or "",
                TextColor3 = theme.Accent, TextSize = 14, Font = Enum.Font.GothamBold, ZIndex = 7,
            })
        end

        local optionBtn = Utility:Create("TextButton", {
            Parent = optionFrame, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 9,
        })

        optionBtn.MouseEnter:Connect(function()
            Utility:Tween(optionFrame, {BackgroundColor3 = theme.DropdownHover}, 0.15)
        end)
        optionBtn.MouseLeave:Connect(function()
            local cs = multiSelect and (selected[optionText] == true) or (selected == optionText)
            Utility:Tween(optionFrame, {
                BackgroundColor3 = cs and theme.Accent or theme.DropdownBackground,
                BackgroundTransparency = cs and 0.85 or 0,
            }, 0.15)
        end)

        optionBtn.MouseButton1Click:Connect(function()
            if multiSelect then
                selected[optionText] = not selected[optionText]
                local now = selected[optionText]
                Utility:Tween(optionFrame, {
                    BackgroundColor3 = now and theme.Accent or theme.DropdownBackground,
                    BackgroundTransparency = now and 0.85 or 0,
                }, 0.2)
                optionLabel.Font = now and Enum.Font.GothamBold or Enum.Font.GothamMedium
                Utility:Tween(optionLabel, {TextColor3 = now and theme.Accent or theme.Text}, 0.2)
                selectedLabel.Text = getSelectedText()
                local result = {}
                for item, s in pairs(selected) do if s then table.insert(result, item) end end
                task.spawn(callback, result)
            else
                for _, btn in pairs(optionButtons) do
                    local f = btn.Frame
                    local l = f:FindFirstChild("Label")
                    local r = f:FindFirstChild("Radio")
                    Utility:Tween(f, {BackgroundColor3 = theme.DropdownBackground, BackgroundTransparency = 0}, 0.2)
                    if l then l.Font = Enum.Font.GothamMedium; Utility:Tween(l, {TextColor3 = theme.Text}, 0.2) end
                    if r then r.Text = "" end
                end
                selected = optionText
                Utility:Tween(optionFrame, {BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.85}, 0.2)
                optionLabel.Font = Enum.Font.GothamBold
                Utility:Tween(optionLabel, {TextColor3 = theme.Accent}, 0.2)
                if radioIndicator then radioIndicator.Text = "●" end
                selectedLabel.Text = getSelectedText()
                task.spawn(callback, selected)
                task.delay(0.15, function() if isOpen then toggleDropdown() end end)
            end
        end)

        table.insert(optionButtons, {Frame = optionFrame, Text = optionText})
    end

    for i, opt in ipairs(options) do createOption(opt, i) end

    toggleDropdown = function()
        isOpen = not isOpen
        local optionsHeight = math.min(#options * 36 + 12, 200)
        if isOpen then
            Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, headerHeight + optionsHeight)}, 0.35, Enum.EasingStyle.Quart)
            Utility:Tween(chevron, {Rotation = 180}, 0.3)
            Utility:Tween(dropdownStroke, {Color = theme.Accent, Transparency = 0.5}, 0.3)
        else
            Utility:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, headerHeight)}, 0.3, Enum.EasingStyle.Quart)
            Utility:Tween(chevron, {Rotation = 0}, 0.3)
            Utility:Tween(dropdownStroke, {Color = theme.Border, Transparency = 0.7}, 0.3)
        end
    end

    local headerBtn = Utility:Create("TextButton", {
        Parent = headerFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 7,
    })
    headerBtn.MouseButton1Click:Connect(function() toggleDropdown() end)

    if tooltip then
        headerBtn.MouseEnter:Connect(function()
            if not isOpen then self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation()) end
        end)
        headerBtn.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    local api = {
        Frame = dropdownFrame,
        GetSelected = function()
            if multiSelect then
                local result = {}
                for item, s in pairs(selected) do if s then table.insert(result, item) end end
                return result
            end
            return selected
        end,
        SetSelected = function(_, newSel, skip)
            if multiSelect then
                selected = {}
                if type(newSel) == "table" then for _, v in ipairs(newSel) do selected[v] = true end end
            else
                selected = newSel
            end
            selectedLabel.Text = getSelectedText()
            if not skip then
                if multiSelect then
                    local result = {}
                    for item, s in pairs(selected) do if s then table.insert(result, item) end end
                    task.spawn(callback, result)
                else
                    task.spawn(callback, selected)
                end
            end
        end,
        Refresh = function(_, newOptions, keepSelected)
            options = newOptions
            for _, btn in pairs(optionButtons) do btn.Frame:Destroy() end
            optionButtons = {}
            if not keepSelected then
                selected = multiSelect and {} or nil
                selectedLabel.Text = getSelectedText()
            end
            for i, opt in ipairs(options) do createOption(opt, i) end
            if isOpen then
                local h2 = math.min(#options * 36 + 12, 200)
                dropdownFrame.Size = UDim2.new(1, 0, 0, headerHeight + h2)
            end
        end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) dropdownFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Input
-- ══════════════════════════════════════════════════════════
function Tab:AddInput(config)
    config = config or {}
    local name = config.Name or "Input"
    local description = config.Description
    local placeholder = config.Placeholder or "Type here..."
    local default = config.Default or ""
    local numeric = config.Numeric or false
    local clearOnFocus = config.ClearOnFocus or false
    local callback = config.Callback or function() end
    local changedCallback = config.Changed
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local height = description and 58 or 42

    local inputFrame = Utility:Create("Frame", {
        Name = "Input_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = inputFrame})
    Utility:Create("UIStroke", {Parent = inputFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    Utility:Create("TextLabel", {
        Parent = inputFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, description and 10 or 0),
        Size = UDim2.new(0.45, -16, 0, description and 22 or height),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = inputFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(0.45, -16, 0, 16),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        })
    end

    local tbContainer = Utility:Create("Frame", {
        Parent = inputFrame, BackgroundColor3 = theme.TertiaryBackground,
        Position = UDim2.new(0.45, 4, 0.5, 0), Size = UDim2.new(0.55, -20, 0, 30),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tbContainer})
    local tbStroke = Utility:Create("UIStroke", {Parent = tbContainer, Color = theme.Border, Thickness = 1, Transparency = 0.6})

    local textBox = Utility:Create("TextBox", {
        Parent = tbContainer, BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        Text = default, PlaceholderText = placeholder, PlaceholderColor3 = theme.TextTertiary,
        TextColor3 = theme.Text, TextSize = 13, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = clearOnFocus,
        ClipsDescendants = true, ZIndex = 6,
    })

    textBox.Focused:Connect(function()
        Utility:Tween(tbStroke, {Color = theme.Accent, Transparency = 0}, 0.2)
        Utility:Tween(tbContainer, {BackgroundColor3 = theme.SecondaryBackground}, 0.2)
        Utility:Tween(inputFrame, {BackgroundColor3 = theme.CardBackgroundHover}, 0.2)
    end)
    textBox.FocusLost:Connect(function(enter)
        Utility:Tween(tbStroke, {Color = theme.Border, Transparency = 0.6}, 0.2)
        Utility:Tween(tbContainer, {BackgroundColor3 = theme.TertiaryBackground}, 0.2)
        Utility:Tween(inputFrame, {BackgroundColor3 = theme.CardBackground}, 0.2)
        local t = textBox.Text
        if numeric then t = tonumber(t) or 0; textBox.Text = tostring(t) end
        if enter then task.spawn(callback, t) end
    end)
    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if numeric then
            local cleaned = textBox.Text:gsub("[^%d%.%-]", "")
            if cleaned ~= textBox.Text then textBox.Text = cleaned end
        end
        if changedCallback then task.spawn(changedCallback, textBox.Text) end
    end)

    if tooltip then
        inputFrame.MouseEnter:Connect(function()
            self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation())
        end)
        inputFrame.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    local api = {
        Frame = inputFrame,
        GetValue = function() return textBox.Text end,
        SetValue = function(_, v) textBox.Text = tostring(v) end,
        SetCallback = function(_, c) callback = c end,
        Destroy = function(_) inputFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Keybind
-- ══════════════════════════════════════════════════════════
function Tab:AddKeybind(config)
    config = config or {}
    local name = config.Name or "Keybind"
    local description = config.Description
    local default = config.Default or Enum.KeyCode.Unknown
    local callback = config.Callback or function() end
    local changedCallback = config.Changed or function() end
    local tooltip = config.Tooltip
    local theme = self.Theme
    local order = #self.Elements + 1
    local currentKey = default
    local listening = false
    local height = description and 58 or 42

    local keybindFrame = Utility:Create("Frame", {
        Name = "Keybind_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = keybindFrame})
    Utility:Create("UIStroke", {Parent = keybindFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    Utility:Create("TextLabel", {
        Parent = keybindFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, description and 10 or 0),
        Size = UDim2.new(0.6, -16, 0, description and 22 or height),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    if description then
        Utility:Create("TextLabel", {
            Parent = keybindFrame, BackgroundTransparency = 1,
            Position = UDim2.new(0, 16, 0, 32), Size = UDim2.new(0.6, -16, 0, 16),
            Text = description, TextColor3 = theme.TextTertiary,
            TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
        })
    end

    local function getKeyName(key)
        if key == Enum.KeyCode.Unknown then return "None" end
        return key.Name:gsub("LeftShift", "LShift"):gsub("RightShift", "RShift")
            :gsub("LeftControl", "LCtrl"):gsub("RightControl", "RCtrl")
            :gsub("LeftAlt", "LAlt"):gsub("RightAlt", "RAlt")
    end

    local keyDisplay = Utility:Create("TextButton", {
        Parent = keybindFrame, BackgroundColor3 = theme.TertiaryBackground,
        Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(1, 0.5),
        Text = "", AutoButtonColor = false, ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = keyDisplay})
    Utility:Create("UIPadding", {Parent = keyDisplay, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
    local keyDisplayStroke = Utility:Create("UIStroke", {Parent = keyDisplay, Color = theme.Border, Thickness = 1, Transparency = 0.5})

    local keyText = Utility:Create("TextLabel", {
        Parent = keyDisplay, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = getKeyName(currentKey),
        TextColor3 = theme.TextSecondary, TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 7,
    })

    keyDisplay.MouseEnter:Connect(function()
        Utility:Tween(keyDisplayStroke, {Color = theme.Accent, Transparency = 0.3}, 0.2)
    end)
    keyDisplay.MouseLeave:Connect(function()
        if not listening then Utility:Tween(keyDisplayStroke, {Color = theme.Border, Transparency = 0.5}, 0.2) end
    end)
    keyDisplay.MouseButton1Click:Connect(function()
        listening = true
        keyText.Text = "..."
        Utility:Tween(keyDisplay, {BackgroundColor3 = theme.Accent}, 0.2)
        Utility:Tween(keyText, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or input.KeyCode
                listening = false
                keyText.Text = getKeyName(currentKey)
                Utility:Tween(keyDisplay, {BackgroundColor3 = theme.TertiaryBackground}, 0.2)
                Utility:Tween(keyText, {TextColor3 = theme.TextSecondary}, 0.2)
                Utility:Tween(keyDisplayStroke, {Color = theme.Border, Transparency = 0.5}, 0.2)
                task.spawn(changedCallback, currentKey)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == currentKey and not gp then task.spawn(callback) end
        end
    end)

    if tooltip then
        keybindFrame.MouseEnter:Connect(function()
            self.Window._Tooltip:Show(tooltip, UserInputService:GetMouseLocation())
        end)
        keybindFrame.MouseLeave:Connect(function() self.Window._Tooltip:Hide() end)
    end

    local api = {
        Frame = keybindFrame,
        GetKey = function() return currentKey end,
        SetKey = function(_, k) currentKey = k; keyText.Text = getKeyName(k) end,
        Destroy = function(_) keybindFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- ELEMENT: Color Picker
-- ══════════════════════════════════════════════════════════
function Tab:AddColorPicker(config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Color3.fromRGB(255, 255, 255)
    local callback = config.Callback or function() end
    local theme = self.Theme
    local order = #self.Elements + 1
    local currentColor = default
    local isOpen = false
    local h, s, v = Color3.toHSV(default)

    local pickerFrame = Utility:Create("Frame", {
        Name = "ColorPicker_" .. name, Parent = self.ContentFrame,
        BackgroundColor3 = theme.CardBackground, Size = UDim2.new(1, 0, 0, 42),
        ClipsDescendants = true, LayoutOrder = order, ZIndex = 4,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = pickerFrame})
    Utility:Create("UIStroke", {Parent = pickerFrame, Color = theme.Border, Thickness = 1, Transparency = 0.7})

    Utility:Create("TextLabel", {
        Parent = pickerFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0.6, -16, 0, 42),
        Text = name, TextColor3 = theme.Text, TextSize = 14,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
    })

    local colorPreview = Utility:Create("Frame", {
        Parent = pickerFrame, BackgroundColor3 = currentColor,
        Position = UDim2.new(1, -52, 0, 9), Size = UDim2.new(0, 36, 0, 24), ZIndex = 5,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = colorPreview})
    Utility:Create("UIStroke", {Parent = colorPreview, Color = theme.Border, Thickness = 1, Transparency = 0.5})

    local pickerArea = Utility:Create("Frame", {
        Parent = pickerFrame, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 50), Size = UDim2.new(1, -24, 0, 130), ZIndex = 5,
    })

    local svBox = Utility:Create("Frame", {
        Parent = pickerArea, BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Size = UDim2.new(1, -40, 0, 110), ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = svBox})

    local whiteOverlay = Utility:Create("Frame", {
        Parent = svBox, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 7,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = whiteOverlay})
    Utility:Create("UIGradient", {
        Parent = whiteOverlay,
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
    })

    local blackOverlay = Utility:Create("Frame", {
        Parent = svBox, BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 8,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = blackOverlay})
    Utility:Create("UIGradient", {
        Parent = blackOverlay, Rotation = 90,
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
    })

    local svCursor = Utility:Create("Frame", {
        Parent = svBox, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(s, 0, 1 - v, 0), Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 10,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = svCursor})
    Utility:Create("UIStroke", {Parent = svCursor, Color = Color3.fromRGB(255, 255, 255), Thickness = 2})

    local hueBar = Utility:Create("Frame", {
        Parent = pickerArea, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(1, -28, 0, 0), Size = UDim2.new(0, 20, 0, 110), ZIndex = 6,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = hueBar})
    Utility:Create("UIGradient", {
        Parent = hueBar, Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
    })

    local hueCursor = Utility:Create("Frame", {
        Parent = hueBar, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0.5, 0, h, 0), Size = UDim2.new(1, 6, 0, 6),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 8,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = hueCursor})

    local hexDisplay = Utility:Create("TextBox", {
        Parent = pickerArea, BackgroundColor3 = theme.TertiaryBackground,
        Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, -40, 0, 24),
        Text = "#" .. currentColor:ToHex(), TextColor3 = theme.TextSecondary,
        TextSize = 11, Font = Enum.Font.GothamMedium, ZIndex = 6, ClearTextOnFocus = true,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = hexDisplay})

    local function updateColor()
        currentColor = Color3.fromHSV(h, s, v)
        colorPreview.BackgroundColor3 = currentColor
        svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(0.5, 0, h, 0)
        hexDisplay.Text = "#" .. currentColor:ToHex()
        task.spawn(callback, currentColor)
    end

    local svDragging, hueDragging = false, false

    local svInput = Utility:Create("TextButton", {
        Parent = svBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 11,
    })
    svInput.MouseButton1Down:Connect(function() svDragging = true end)

    local hueInput = Utility:Create("TextButton", {
        Parent = hueBar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 9,
    })
    hueInput.MouseButton1Down:Connect(function() hueDragging = true end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if svDragging then
                s = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                updateColor()
            elseif hueDragging then
                h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                updateColor()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = false; hueDragging = false
        end
    end)

    hexDisplay.FocusLost:Connect(function()
        local ok, col = pcall(function() return Color3.fromHex("#" .. hexDisplay.Text:gsub("#", "")) end)
        if ok then h, s, v = Color3.toHSV(col); updateColor()
        else hexDisplay.Text = "#" .. currentColor:ToHex() end
    end)

    local headerBtn = Utility:Create("TextButton", {
        Parent = pickerFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 42), Text = "", ZIndex = 6,
    })
    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        Utility:Tween(pickerFrame, {Size = UDim2.new(1, 0, 0, isOpen and 200 or 42)}, 0.35, Enum.EasingStyle.Quart)
    end)

    local api = {
        Frame = pickerFrame,
        GetColor = function() return currentColor end,
        SetColor = function(_, c) h, s, v = Color3.toHSV(c); updateColor() end,
        Destroy = function(_) pickerFrame:Destroy() end,
    }
    table.insert(self.Elements, api)
    return api
end

-- ══════════════════════════════════════════════════════════
-- WINDOW CLASS
-- ══════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(config, fluxInstance)
    local self = setmetatable({}, Window)
    self.Title = config.Title or "Flux UI"
    self.Subtitle = config.Subtitle or "v2.0.0"
    self.Size = config.Size or UDim2.new(0, 580, 0, 440)
    self.ThemeName = config.Theme or "Dark"
    self.Theme = Themes[self.ThemeName] or Themes.Dark
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Visible = true
    self.Flux = fluxInstance

    self.ScreenGui = Utility:Create("ScreenGui", {
        Name = "FluxUI_" .. Utility:GenerateUID(),
        Parent = (syn and syn.protect_gui and CoreGui) or Player:WaitForChild("PlayerGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false, DisplayOrder = 999,
    })
    if syn and syn.protect_gui then pcall(syn.protect_gui, self.ScreenGui) end

    self.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame", Parent = self.ScreenGui,
        BackgroundColor3 = self.Theme.Background,
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, ZIndex = 2,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = self.MainFrame})
    Utility:AddShadow(self.MainFrame, 0.4, 40)
    Utility:Create("UIStroke", {Parent = self.MainFrame, Color = self.Theme.Border, Thickness = 1, Transparency = 0.5})

    -- Title Bar
    self.TitleBar = Utility:Create("Frame", {
        Name = "TitleBar", Parent = self.MainFrame,
        BackgroundColor3 = self.Theme.SecondaryBackground,
        Size = UDim2.new(1, 0, 0, 52), BorderSizePixel = 0, ZIndex = 10,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = self.TitleBar})
    Utility:Create("Frame", {
        Parent = self.TitleBar, BackgroundColor3 = self.Theme.SecondaryBackground,
        Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16),
        BorderSizePixel = 0, ZIndex = 10,
    })
    Utility:Create("Frame", {
        Parent = self.TitleBar, BackgroundColor3 = self.Theme.Divider,
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0, ZIndex = 11,
    })

    -- Title icon
    local titleIcon = Utility:Create("Frame", {
        Parent = self.TitleBar, BackgroundColor3 = self.Theme.Accent,
        Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.new(0, 32, 0, 32),
        AnchorPoint = Vector2.new(0, 0.5), ZIndex = 11,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = titleIcon})
    Utility:Create("TextLabel", {
        Parent = titleIcon, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = string.sub(self.Title, 1, 1),
        TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 12,
    })

    Utility:Create("TextLabel", {
        Parent = self.TitleBar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 58, 0, 8), Size = UDim2.new(0.5, -58, 0, 18),
        Text = self.Title, TextColor3 = self.Theme.Text,
        TextSize = 16, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    Utility:Create("TextLabel", {
        Parent = self.TitleBar, BackgroundTransparency = 1,
        Position = UDim2.new(0, 58, 0, 28), Size = UDim2.new(0.5, -58, 0, 14),
        Text = self.Subtitle, TextColor3 = self.Theme.TextTertiary,
        TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })

    -- Controls
    local controlsFrame = Utility:Create("Frame", {
        Parent = self.TitleBar, BackgroundTransparency = 1,
        Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.new(0, 50, 0, 28),
        AnchorPoint = Vector2.new(1, 0.5), ZIndex = 11,
    })
    Utility:Create("UIListLayout", {
        Parent = controlsFrame, FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    local minimizeBtn = Utility:Create("TextButton", {
        Parent = controlsFrame, BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        Size = UDim2.new(0, 16, 0, 16), Text = "", AutoButtonColor = false, LayoutOrder = 1, ZIndex = 12,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = minimizeBtn})

    local closeBtn = Utility:Create("TextButton", {
        Parent = controlsFrame, BackgroundColor3 = Color3.fromRGB(255, 69, 58),
        Size = UDim2.new(0, 16, 0, 16), Text = "", AutoButtonColor = false, LayoutOrder = 2, ZIndex = 12,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = closeBtn})

    for _, btn in ipairs({minimizeBtn, closeBtn}) do
        btn.MouseEnter:Connect(function() Utility:Spring(btn, {Size = UDim2.new(0, 18, 0, 18)}, 0.3) end)
        btn.MouseLeave:Connect(function() Utility:Spring(btn, {Size = UDim2.new(0, 16, 0, 16)}, 0.3) end)
    end

    -- Sidebar
    self.Sidebar = Utility:Create("Frame", {
        Parent = self.MainFrame, BackgroundColor3 = self.Theme.SecondaryBackground,
        Size = UDim2.new(0, 170, 1, -52), Position = UDim2.new(0, 0, 0, 52),
        BorderSizePixel = 0, ZIndex = 3,
    })
    Utility:Create("Frame", {
        Parent = self.Sidebar, BackgroundColor3 = self.Theme.Divider,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0),
        BorderSizePixel = 0, ZIndex = 4,
    })

    self._TabList = Utility:Create("ScrollingFrame", {
        Parent = self.Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, -16), Position = UDim2.new(0, 8, 0, 8),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2, ScrollBarImageColor3 = self.Theme.ScrollBar,
        ScrollBarImageTransparency = 0.5, BorderSizePixel = 0, ZIndex = 4,
    })
    Utility:Create("UIListLayout", {Parent = self._TabList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})

    -- Content Area
    self._ContentContainer = Utility:Create("Frame", {
        Parent = self.MainFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, -52), Position = UDim2.new(0, 170, 0, 52), ZIndex = 3,
    })

    -- Systems
    self._Tooltip = TooltipSystem.new(self.ScreenGui, self.Theme)
    self._Tooltip:Track()
    self._Notifications = NotificationSystem.new(self.ScreenGui, self.Theme)

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Utility:Tween(self.MainFrame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Quad)
        end
    end)

    -- Minimize
    minimizeBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        Utility:Tween(self.MainFrame, {
            Size = self.Minimized and UDim2.new(0, self.Size.X.Offset, 0, 52) or self.Size
        }, 0.4, Enum.EasingStyle.Quart)
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        Utility:Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quart)
        task.delay(0.4, function() self.ScreenGui:Destroy() end)
    end)

    -- Open animation
    self.MainFrame.BackgroundTransparency = 1
    task.delay(0.05, function()
        Utility:Tween(self.MainFrame, {BackgroundTransparency = 0}, 0.3)
        Utility:Spring(self.MainFrame, {Size = self.Size}, 0.6)
    end)

    -- Toggle keybind
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            self.Visible = not self.Visible
            if self.Visible then
                self.ScreenGui.Enabled = true
                self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
                Utility:Spring(self.MainFrame, {Size = self.Size}, 0.5)
            else
                Utility:Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart)
                task.delay(0.3, function() self.ScreenGui.Enabled = false end)
            end
        end
    end)

    return self
end

function Window:CreateTab(config)
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Window:SelectTab(tab)
    if self.ActiveTab == tab then return end
    if self.ActiveTab then self.ActiveTab:Hide() end
    self.ActiveTab = tab
    tab:Show()
end

function Window:Notify(config)
    return self._Notifications:Push(config)
end

function Window:Destroy()
    Utility:Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Quart)
    task.delay(0.35, function() self.ScreenGui:Destroy() end)
end

-- ══════════════════════════════════════════════════════════
-- MAIN CONSTRUCTOR
-- ══════════════════════════════════════════════════════════
function Flux:CreateWindow(config)
    return Window.new(config or {}, self)
end

function Flux:GetThemes() return Themes end
function Flux:AddTheme(n, d) Themes[n] = d end

return Flux
