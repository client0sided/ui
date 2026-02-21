--[[
HattoriUI

Version: 1.0.3
Author: @noah_ang
Contributors:

]]--



local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

local CONFIG = {
	Colors = {
		Background = Color3.fromRGB(10, 10, 10),
		Secondary = Color3.fromRGB(15, 15, 15),
		Element = Color3.fromRGB(17, 17, 17),
		Border = Color3.fromRGB(40, 40, 40),
		TextPrimary = Color3.fromRGB(184, 184, 184),
		TextSecondary = Color3.fromRGB(150, 150, 150),
		TextTertiary = Color3.fromRGB(100, 100, 100),
	},
	Sizes = {
		MainFrame = Vector2.new(590, 387),
		TabFrame = Vector2.new(185, 387),
		HeaderHeight = 47,
		ParagraphHeight = 50,
		TitleHeight = 38,
	},
	Animation = {
		Speed = 0.3,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
	}
}

local CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local CHARSET_LEN = #CHARSET
local NAME_LENGTH = 12

local function randomName()
	local t = table.create(NAME_LENGTH)
	for i = 1, NAME_LENGTH do
		t[i] = string.sub(CHARSET, math.random(1, CHARSET_LEN), math.random(1, CHARSET_LEN))
	end
	return table.concat(t)
end

local _nameTargets = {}
local _nameTimer   = 0

local _nameConnection = RunService.Heartbeat:Connect(function(dt)
	_nameTimer = _nameTimer + dt
	if _nameTimer < 1 then return end
	_nameTimer = 0
	for i = 1, #_nameTargets do
		local inst = _nameTargets[i]
		if inst and inst.Parent then
			inst.Name = randomName()
		end
	end
end)

local function stopNameRandomizer()
	if _nameConnection then
		_nameConnection:Disconnect()
		_nameConnection = nil
	end
	table.clear(_nameTargets)
end

local function trackNames(...)
	for _, inst in ipairs({...}) do
		if inst then
			_nameTargets[#_nameTargets + 1] = inst
		end
	end
end

function Library.new(options)
	local self = setmetatable({}, Library)
	options = options or {}

	self.Title     = options.Title     or "ui"
	self.Subtitle  = options.Subtitle  or "Game Name"
	self.Position  = options.Position  or UDim2.new(0.05, 0, 0.22, 0)
	self.Scale     = options.Scale     or 1
	self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	self.Tabs      = {}
	self.CurrentTab = nil
	self.IsOpen    = false

	pcall(function()
		self:CreateUI()
		self:SetupEvents()
	end)

	return self
end

function Library:CreateUI()
	pcall(function()
		self.ScreenGui = Instance.new("ScreenGui")
		self.ScreenGui.Name = game:GetService("HttpService"):GenerateGUID(false)
		self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		self.ScreenGui.ResetOnSpawn = false
		self.ScreenGui.IgnoreGuiInset = true
		self.ScreenGui.DisplayOrder = 999

		local success = pcall(function()
			syn.protect_gui(self.ScreenGui)
		end)
		if not success then
			pcall(function()
				game:GetService("CoreGui"):FindFirstChild("RobloxGui")
			end)
		end

		self.ScreenGui.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
		trackNames(self.ScreenGui)

		local scale = math.clamp(self.Scale, 0.1, 4)

		self.CanvasGroup = Instance.new("CanvasGroup")
		self.CanvasGroup.Name = "UICanvas"
		self.CanvasGroup.BackgroundTransparency = 1
		self.CanvasGroup.BorderSizePixel = 0
		self.CanvasGroup.Position = self.Position
		self.CanvasGroup.Size = UDim2.new(0, CONFIG.Sizes.MainFrame.X, 0, CONFIG.Sizes.MainFrame.Y)
		self.CanvasGroup.Parent = self.ScreenGui
		trackNames(self.CanvasGroup)

		local uiScale = Instance.new("UIScale")
		uiScale.Scale = scale
		uiScale.Parent = self.CanvasGroup
		trackNames(uiScale)

		self.MainFrame = Instance.new("Frame")
		self.MainFrame.Name = game:GetService("HttpService"):GenerateGUID(false)
		self.MainFrame.BackgroundColor3 = CONFIG.Colors.Background
		self.MainFrame.BorderSizePixel = 0
		self.MainFrame.Position = UDim2.new(0, 0, 0, 0)
		self.MainFrame.Size = UDim2.new(0, CONFIG.Sizes.MainFrame.X, 0, CONFIG.Sizes.MainFrame.Y)
		self.MainFrame.Parent = self.CanvasGroup
		trackNames(self.MainFrame)

		local mainCorner = Instance.new("UICorner")
		mainCorner.Parent = self.MainFrame
		trackNames(mainCorner)

		self:CreateHeader()

		self.ContentContainer = Instance.new("ScrollingFrame")
		self.ContentContainer.Name = "ContentContainer"
		self.ContentContainer.BackgroundTransparency = 1
		self.ContentContainer.BorderSizePixel = 0
		self.ContentContainer.Position = UDim2.new(0, 0, 0.096, 0)
		self.ContentContainer.Size = UDim2.new(1, 0, 0.904, 0)
		self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		self.ContentContainer.ScrollBarThickness = 0
		self.ContentContainer.ScrollingEnabled = false
		self.ContentContainer.ScrollBarImageColor3 = CONFIG.Colors.TextSecondary
		self.ContentContainer.ScrollBarImageTransparency = 0.5
		self.ContentContainer.ScrollingDirection = Enum.ScrollingDirection.Y
		self.ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		self.ContentContainer.Parent = self.MainFrame
		trackNames(self.ContentContainer)

		local contentLayout = Instance.new("UIListLayout")
		contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Padding = UDim.new(0, 8)
		contentLayout.Parent = self.ContentContainer
		trackNames(contentLayout)

		self:CreateTabFrame()
	end)
end

function Library:CreateHeader()
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, CONFIG.Sizes.HeaderHeight)
	header.Parent = self.MainFrame
	trackNames(header)

	self.TabOpener = Instance.new("ImageLabel")
	self.TabOpener.Name = "TabOpener"
	self.TabOpener.BackgroundTransparency = 1
	self.TabOpener.BorderSizePixel = 0
	self.TabOpener.Position = UDim2.new(0.029, 0, 0.328, 0)
	self.TabOpener.Size = UDim2.new(0, 17, 0, 17)
	self.TabOpener.Image = "rbxassetid://131692115073395"
	self.TabOpener.ImageColor3 = CONFIG.Colors.TextSecondary
	self.TabOpener.Parent = header
	trackNames(self.TabOpener)

	local titleText = Instance.new("TextLabel")
	titleText.Name = "TitleText"
	titleText.BackgroundTransparency = 1
	titleText.BorderSizePixel = 0
	titleText.Position = UDim2.new(0.071, 0, 0.276, 0)
	titleText.Size = UDim2.new(0, 200, 0, 20)
	titleText.Font = Enum.Font.Ubuntu
	titleText.RichText = true
	titleText.Text = string.format('%s - %s', self.Title, self.Subtitle)
	titleText.TextColor3 = CONFIG.Colors.TextPrimary
	titleText.TextSize = 14
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.Parent = header
	trackNames(titleText)

	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local currentTween

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		if currentTween then currentTween:Cancel() end
		currentTween = TweenService:Create(
			self.CanvasGroup,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = targetPos}
		)
		currentTween:Play()
	end

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.CanvasGroup.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function Library:CreateTabFrame()
	self.TabFrame = Instance.new("CanvasGroup")
	self.TabFrame.Name = "TabFrame"
	self.TabFrame.BackgroundColor3 = CONFIG.Colors.Background
	self.TabFrame.BorderSizePixel = 0
	self.TabFrame.Position = UDim2.new(0, 0, 0, 0)
	self.TabFrame.Size = UDim2.new(0, CONFIG.Sizes.TabFrame.X, 0, CONFIG.Sizes.TabFrame.Y)
	self.TabFrame.ClipsDescendants = true
	self.TabFrame.ZIndex = 2
	self.TabFrame.Visible = false
	self.TabFrame.Parent = self.MainFrame
	trackNames(self.TabFrame)

	local tabCorner = Instance.new("UICorner")
	tabCorner.Parent = self.TabFrame
	trackNames(tabCorner)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Background
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0.925, 0, 0, 0)
	cornerFiller.Size = UDim2.new(0, 13, 1, 0)
	cornerFiller.Parent = self.TabFrame
	trackNames(cornerFiller)

	local borderLine = Instance.new("Frame")
	borderLine.BackgroundColor3 = CONFIG.Colors.Border
	borderLine.BorderSizePixel = 0
	borderLine.Position = UDim2.new(0.995, 0, 0, 0)
	borderLine.Size = UDim2.new(0, 1, 1, 0)
	borderLine.Parent = self.TabFrame
	trackNames(borderLine)

	self.CloseIcon = Instance.new("ImageLabel")
	self.CloseIcon.Name = "CloseIcon"
	self.CloseIcon.BackgroundTransparency = 1
	self.CloseIcon.BorderSizePixel = 0
	self.CloseIcon.Position = UDim2.new(0.088, 0, 0.041, 0)
	self.CloseIcon.Size = UDim2.new(0, 17, 0, 17)
	self.CloseIcon.Image = "rbxassetid://74216110692187"
	self.CloseIcon.ImageColor3 = CONFIG.Colors.TextSecondary
	self.CloseIcon.Parent = self.TabFrame
	trackNames(self.CloseIcon)

	self.TabListContainer = Instance.new("Frame")
	self.TabListContainer.Name = "TabListContainer"
	self.TabListContainer.BackgroundTransparency = 1
	self.TabListContainer.BorderSizePixel = 0
	self.TabListContainer.Position = UDim2.new(0.092, 0, 0.119, 0)
	self.TabListContainer.Size = UDim2.new(0, 153, 0, 357)
	self.TabListContainer.Parent = self.TabFrame
	trackNames(self.TabListContainer)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 7)
	tabLayout.Parent = self.TabListContainer
	trackNames(tabLayout)
end

function Library:SetupEvents()
	pcall(function()
		local tabOpenerButton = Instance.new("TextButton")
		tabOpenerButton.Size = UDim2.new(1, 0, 1, 0)
		tabOpenerButton.BackgroundTransparency = 1
		tabOpenerButton.Text = ""
		tabOpenerButton.ZIndex = 10
		tabOpenerButton.Parent = self.TabOpener
		trackNames(tabOpenerButton)

		tabOpenerButton.MouseButton1Click:Connect(function()
			pcall(function() self:ToggleTabs() end)
		end)

		local closeButton = Instance.new("TextButton")
		closeButton.Size = UDim2.new(1, 0, 1, 0)
		closeButton.BackgroundTransparency = 1
		closeButton.Text = ""
		closeButton.Parent = self.CloseIcon
		trackNames(closeButton)

		closeButton.MouseButton1Click:Connect(function()
			pcall(function() self:ToggleTabs() end)
		end)

		self.Visible = true

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == self.ToggleKey then
				self:ToggleVisibility()
			end
		end)
	end)
end

function Library:ToggleTabs()
	self.IsOpen = not self.IsOpen
	if self.IsOpen then
		self.TabFrame.Visible = true
		self.TabFrame.GroupTransparency = 1
		TweenService:Create(self.TabFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
	else
		TweenService:Create(self.TabFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
		task.delay(0.1, function()
			if not self.IsOpen then
				self.TabFrame.Visible = false
			end
		end)
	end
end

function Library:ToggleVisibility()
	self.Visible = not self.Visible
	local target = self.Visible and 0 or 1
	TweenService:Create(self.CanvasGroup, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = target}):Play()
	if self.Visible then
		self.CanvasGroup.Interactable = true
	else
		task.delay(0.1, function()
			if not self.Visible then
				self.CanvasGroup.Interactable = false
			end
		end)
	end
end

function Library:AddTab(options)
	local name, iconId
	if type(options) == "string" then
		name = options
		iconId = ""
	elseif type(options) == "table" then
		name = type(options.Title) == "string" and options.Title or "Tab"
		iconId = type(options.Icon) == "string" and options.Icon or ""
	else
		name = "Tab"
		iconId = ""
	end

	local tab = {}
	tab.Name = name
	tab.IconId = iconId
	tab.Elements = {}

	tab.Container = Instance.new("ScrollingFrame")
	tab.Container.Name = name .. "Container"
	tab.Container.BackgroundTransparency = 1
	tab.Container.BorderSizePixel = 0
	tab.Container.Visible = false
	tab.Container.Position = UDim2.new(0, 0, 0, 0)
	tab.Container.Size = UDim2.new(1, 0, 1, 0)
	tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
	tab.Container.ScrollBarThickness = 4
	tab.Container.ScrollBarImageColor3 = CONFIG.Colors.TextSecondary
	tab.Container.ScrollBarImageTransparency = 0.5
	tab.Container.ScrollingDirection = Enum.ScrollingDirection.Y
	tab.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tab.Container.Parent = self.ContentContainer
	trackNames(tab.Container)

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Padding = UDim.new(0, 8)
	containerLayout.Parent = tab.Container
	trackNames(containerLayout)

	local containerPadding = Instance.new("UIPadding")
	containerPadding.PaddingTop = UDim.new(0, 8)
	containerPadding.PaddingBottom = UDim.new(0, 20)
	containerPadding.Parent = tab.Container
	trackNames(containerPadding)

	self:CreateTabButton(name, iconId, tab)
	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return {
		AddParagraph  = function(_, opts) return self:AddParagraph(tab, opts) end,
		AddTitle      = function(_, opts) return self:AddTitle(tab, opts) end,
		AddToggle     = function(_, opts) return self:AddToggle(tab, opts) end,
		AddButton     = function(_, opts) return self:AddButton(tab, opts) end,
		AddSlider     = function(_, opts) return self:AddSlider(tab, opts) end,
		AddColorPicker = function(_, opts) return self:AddColorPicker(tab, opts) end,
	}
end

function Library:CreateTabButton(name, iconId, tab)
	local hasIcon = iconId and iconId ~= ""

	local button = Instance.new("Frame")
	button.Name = "TabButton_" .. name
	button.BackgroundColor3 = CONFIG.Colors.Element
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 154, 0, 30)
	button.Parent = self.TabListContainer
	trackNames(button)

	local corner = Instance.new("UICorner")
	corner.Parent = button
	trackNames(corner)

	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.Colors.Border
	stroke.Thickness = 1
	stroke.Transparency = 1
	stroke.Parent = button
	trackNames(stroke)

	if hasIcon then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.BorderSizePixel = 0
		icon.Position = UDim2.new(0.061, 0, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.Size = UDim2.new(0, 16, 0, 16)
		icon.Image = "rbxassetid://" .. iconId
		icon.ImageColor3 = CONFIG.Colors.TextSecondary
		icon.Parent = button
		trackNames(icon)
		tab.Icon = icon
	end

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = hasIcon and UDim2.new(0.061, 22, 0.174, 0) or UDim2.new(0.061, 0, 0.174, 0)
	label.Size = UDim2.new(0, hasIcon and 114 or 136, 0, 20)
	label.Font = Enum.Font.Ubuntu
	label.Text = name
	label.TextColor3 = CONFIG.Colors.TextPrimary
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	trackNames(label)

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.Parent = button
	trackNames(clickButton)

	clickButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	tab.Button = button
	tab.Stroke = stroke
end

function Library:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		if t.Container and t.Button and t.Stroke then
			t.Container.Visible = false
			t.Button.BackgroundTransparency = 1
			t.Stroke.Transparency = 1
			if t.Icon then t.Icon.ImageColor3 = CONFIG.Colors.TextSecondary end
		end
	end
	if tab.Container and tab.Button and tab.Stroke then
		tab.Container.Visible = true
		tab.Button.BackgroundTransparency = 0
		tab.Stroke.Transparency = 0
		if tab.Icon then tab.Icon.ImageColor3 = CONFIG.Colors.TextPrimary end
	end
	self.CurrentTab = tab
end

function Library:AddParagraph(tab, options)
	local title = options.Title or "Title"
	local description = options.Description or "Description"

	local paragraph = Instance.new("Frame")
	paragraph.Name = "Paragraph"
	paragraph.BackgroundColor3 = CONFIG.Colors.Element
	paragraph.BorderSizePixel = 0
	paragraph.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	paragraph.Parent = tab.Container
	trackNames(paragraph)

	local corner = Instance.new("UICorner")
	corner.Parent = paragraph
	trackNames(corner)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = UDim2.new(0.029, 0, 0.174, 0)
	titleLabel.Size = UDim2.new(0, 200, 0, 20)
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.Colors.TextPrimary
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = paragraph
	trackNames(titleLabel)

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.BorderSizePixel = 0
	descLabel.Position = UDim2.new(0.029, 0, 0.508, 0)
	descLabel.Size = UDim2.new(0, 200, 0, 20)
	descLabel.Font = Enum.Font.Ubuntu
	descLabel.Text = description
	descLabel.TextColor3 = CONFIG.Colors.TextTertiary
	descLabel.TextSize = 14
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = paragraph
	trackNames(descLabel)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = paragraph
	trackNames(cornerFiller)

	local button = Instance.new("TextButton")
	button.Name = "HoverDetector"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = paragraph
	trackNames(button)

	button.MouseEnter:Connect(function()
		paragraph.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	button.MouseLeave:Connect(function()
		paragraph.BackgroundColor3 = CONFIG.Colors.Element
		cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, paragraph)
	return paragraph
end

function Library:AddTitle(tab, options)
	local title = options.Title or "Title"

	local titleFrame = Instance.new("Frame")
	titleFrame.Name = "Title"
	titleFrame.BackgroundColor3 = CONFIG.Colors.Element
	titleFrame.BorderSizePixel = 0
	titleFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.TitleHeight)
	titleFrame.Parent = tab.Container
	trackNames(titleFrame)

	local corner = Instance.new("UICorner")
	corner.Parent = titleFrame
	trackNames(corner)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = UDim2.new(0.029, 0, 0.265, 0)
	titleLabel.Size = UDim2.new(0, 200, 0, 20)
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.Colors.TextPrimary
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = titleFrame
	trackNames(titleLabel)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = titleFrame
	trackNames(cornerFiller)

	local button = Instance.new("TextButton")
	button.Name = "HoverDetector"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = titleFrame
	trackNames(button)

	button.MouseEnter:Connect(function()
		titleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	button.MouseLeave:Connect(function()
		titleFrame.BackgroundColor3 = CONFIG.Colors.Element
		cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, titleFrame)
	return titleFrame
end

function Library:AddToggle(tab, options)
	local title       = options.Title       or "Toggle"
	local description = options.Description or "Description"
	local default     = options.Default     or false
	local callback    = options.Callback

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = "Toggle"
	toggleFrame.BackgroundColor3 = CONFIG.Colors.Element
	toggleFrame.BorderSizePixel = 0
	toggleFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	toggleFrame.Parent = tab.Container
	trackNames(toggleFrame)

	local corner = Instance.new("UICorner")
	corner.Parent = toggleFrame
	trackNames(corner)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = UDim2.new(0.029, 0, 0.174, 0)
	titleLabel.Size = UDim2.new(0, 400, 0, 20)
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.Colors.TextPrimary
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = toggleFrame
	trackNames(titleLabel)

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.BorderSizePixel = 0
	descLabel.Position = UDim2.new(0.029, 0, 0.508, 0)
	descLabel.Size = UDim2.new(0, 400, 0, 20)
	descLabel.Font = Enum.Font.Ubuntu
	descLabel.Text = description
	descLabel.TextColor3 = CONFIG.Colors.TextTertiary
	descLabel.TextSize = 14
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = toggleFrame
	trackNames(descLabel)

	local checkboxState = default

	local checkboxBg = Instance.new("Frame")
	checkboxBg.Name = "CheckboxBackground"
	checkboxBg.BackgroundColor3 = checkboxState and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(25, 25, 25)
	checkboxBg.BorderSizePixel = 0
	checkboxBg.Position = UDim2.new(0.945, 0, 0.35, 0)
	checkboxBg.Size = UDim2.new(0, 18, 0, 18)
	checkboxBg.Parent = toggleFrame
	trackNames(checkboxBg)

	local checkboxCorner = Instance.new("UICorner")
	checkboxCorner.CornerRadius = UDim.new(0, 3)
	checkboxCorner.Parent = checkboxBg
	trackNames(checkboxCorner)

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.AutoButtonColor = false
	clickButton.Parent = checkboxBg
	trackNames(clickButton)

	clickButton.MouseButton1Click:Connect(function()
		checkboxState = not checkboxState
		TweenService:Create(checkboxBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = checkboxState and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(25, 25, 25)
		}):Play()
		if callback then callback(checkboxState) end
	end)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = toggleFrame
	trackNames(cornerFiller)

	local hoverDetector = Instance.new("TextButton")
	hoverDetector.Name = "HoverDetector"
	hoverDetector.Size = UDim2.new(1, 0, 1, 0)
	hoverDetector.BackgroundTransparency = 1
	hoverDetector.Text = ""
	hoverDetector.AutoButtonColor = false
	hoverDetector.ZIndex = 0
	hoverDetector.Parent = toggleFrame
	trackNames(hoverDetector)

	hoverDetector.MouseEnter:Connect(function()
		toggleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	hoverDetector.MouseLeave:Connect(function()
		toggleFrame.BackgroundColor3 = CONFIG.Colors.Element
		cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, toggleFrame)
	return toggleFrame
end

function Library:AddButton(tab, options)
	local title       = options.Title       or "Button"
	local description = options.Description or "Description"
	local callback    = options.Callback

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "Button"
	buttonFrame.BackgroundColor3 = CONFIG.Colors.Element
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	buttonFrame.Parent = tab.Container
	trackNames(buttonFrame)

	local corner = Instance.new("UICorner")
	corner.Parent = buttonFrame
	trackNames(corner)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = UDim2.new(0.029, 0, 0.174, 0)
	titleLabel.Size = UDim2.new(0, 400, 0, 20)
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.Colors.TextPrimary
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = buttonFrame
	trackNames(titleLabel)

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.BorderSizePixel = 0
	descLabel.Position = UDim2.new(0.029, 0, 0.508, 0)
	descLabel.Size = UDim2.new(0, 400, 0, 20)
	descLabel.Font = Enum.Font.Ubuntu
	descLabel.Text = description
	descLabel.TextColor3 = CONFIG.Colors.TextTertiary
	descLabel.TextSize = 14
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = buttonFrame
	trackNames(descLabel)

	local actionIcon = Instance.new("ImageLabel")
	actionIcon.Name = "ActionIcon"
	actionIcon.BackgroundTransparency = 1
	actionIcon.BorderSizePixel = 0
	actionIcon.Position = UDim2.new(0.945, 0, 0.35, 0)
	actionIcon.Size = UDim2.new(0, 18, 0, 18)
	actionIcon.Image = "rbxassetid://10709791437"
	actionIcon.ImageColor3 = CONFIG.Colors.TextSecondary
	actionIcon.Parent = buttonFrame
	trackNames(actionIcon)

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.AutoButtonColor = false
	clickButton.Parent = buttonFrame
	trackNames(clickButton)

	clickButton.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = buttonFrame
	trackNames(cornerFiller)

	clickButton.MouseEnter:Connect(function()
		buttonFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	clickButton.MouseLeave:Connect(function()
		buttonFrame.BackgroundColor3 = CONFIG.Colors.Element
		cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, buttonFrame)
	return buttonFrame
end

function Library:AddSlider(tab, options)
	local title       = options.Title       or "Slider"
	local description = options.Description or ""
	local min         = options.Min         or 0
	local max         = options.Max         or 100
	local default     = options.Default     or min
	local increment   = options.Increment   or 1
	local suffix      = options.Suffix      or ""
	local callback    = options.Callback

	local hasDescription = description ~= ""
	local frameHeight    = hasDescription and CONFIG.Sizes.ParagraphHeight or 38

	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = "Slider"
	sliderFrame.BackgroundColor3 = CONFIG.Colors.Element
	sliderFrame.BorderSizePixel = 0
	sliderFrame.Size = UDim2.new(0, 570, 0, frameHeight)
	sliderFrame.Parent = tab.Container
	trackNames(sliderFrame)

	local corner = Instance.new("UICorner")
	corner.Parent = sliderFrame
	trackNames(corner)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Position = hasDescription and UDim2.new(0.029, 0, 0.174, 0) or UDim2.new(0.029, 0, 0.294, 0)
	titleLabel.Size = UDim2.new(0, 300, 0, 20)
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.Text = title
	titleLabel.TextColor3 = CONFIG.Colors.TextPrimary
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = sliderFrame
	trackNames(titleLabel)

	if hasDescription then
		local descLabel = Instance.new("TextLabel")
		descLabel.BackgroundTransparency = 1
		descLabel.BorderSizePixel = 0
		descLabel.Position = UDim2.new(0.029, 0, 0.508, 0)
		descLabel.Size = UDim2.new(0, 200, 0, 20)
		descLabel.Font = Enum.Font.Ubuntu
		descLabel.Text = description
		descLabel.TextColor3 = CONFIG.Colors.TextTertiary
		descLabel.TextSize = 14
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = sliderFrame
		trackNames(descLabel)
	end

	local valueLabel = Instance.new("TextLabel")
	valueLabel.AnchorPoint = Vector2.new(1, 0.5)
	valueLabel.BackgroundTransparency = 1
	valueLabel.BorderSizePixel = 0
	valueLabel.Position = UDim2.new(0.971, 0, 0.5, 0)
	valueLabel.Size = UDim2.new(0, 55, 0, 18)
	valueLabel.Font = Enum.Font.Ubuntu
	valueLabel.Text = tostring(default) .. suffix
	valueLabel.TextColor3 = CONFIG.Colors.TextSecondary
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = sliderFrame
	trackNames(valueLabel)

	local sliderTrack = Instance.new("Frame")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Position = UDim2.new(0.501, 0, 0.553, -3)
	sliderTrack.Size = UDim2.new(0, 211, 0, 6)
	sliderTrack.Parent = sliderFrame
	trackNames(sliderTrack)

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = sliderTrack
	trackNames(trackCorner)

	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "SliderFill"
	sliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	sliderFill.BorderSizePixel = 0
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.Parent = sliderTrack
	trackNames(sliderFill)

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill
	trackNames(fillCorner)

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Name = "SliderKnob"
	sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	sliderKnob.Size = UDim2.new(0, 16, 0, 16)
	sliderKnob.ZIndex = 5
	sliderKnob.Parent = sliderTrack
	trackNames(sliderKnob)

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = sliderKnob
	trackNames(knobCorner)

	local dragging = false

	local function updateSlider(input)
		local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
		local value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
		value = math.clamp(value, min, max)
		valueLabel.Text = tostring(value) .. suffix
		TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(pos, 0, 1, 0)
		}):Play()
		TweenService:Create(sliderKnob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(pos, 0, 0.5, 0)
		}):Play()
		if callback then pcall(callback, value) end
	end

	sliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input)
		end
	end)
	sliderTrack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input)
		end
	end)

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = sliderFrame
	trackNames(cornerFiller)

	local hoverDetector = Instance.new("TextButton")
	hoverDetector.Name = "HoverDetector"
	hoverDetector.Size = UDim2.new(1, 0, 1, 0)
	hoverDetector.BackgroundTransparency = 1
	hoverDetector.Text = ""
	hoverDetector.AutoButtonColor = false
	hoverDetector.ZIndex = 0
	hoverDetector.Parent = sliderFrame
	trackNames(hoverDetector)

	hoverDetector.MouseEnter:Connect(function()
		sliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	hoverDetector.MouseLeave:Connect(function()
		sliderFrame.BackgroundColor3 = CONFIG.Colors.Element
		cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, sliderFrame)
	return sliderFrame
end

local function hsvToRgb(h, s, v)
	if s == 0 then
		return Color3.new(v, v, v)
	end
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then return Color3.new(v, t, p)
	elseif i == 1 then return Color3.new(q, v, p)
	elseif i == 2 then return Color3.new(p, v, t)
	elseif i == 3 then return Color3.new(p, q, v)
	elseif i == 4 then return Color3.new(t, p, v)
	else return Color3.new(v, p, q)
	end
end

local function rgbToHsv(color)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min
	local h, s, v = 0, 0, max
	if max ~= 0 then s = delta / max end
	if delta ~= 0 then
		if max == r then
			h = (g - b) / delta % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end
		h = h / 6
	end
	return h, s, v
end

function Library:AddColorPicker(tab, options)
	local title    = options.Title   or "Color"
	local default  = options.Default or Color3.fromRGB(255, 100, 100)
	local callback = options.Callback

	local currentColor       = default
	local hue, sat, val      = rgbToHsv(default)
	local isOpen             = false
	local svDragging         = false
	local hueDragging        = false

	local rowFrame = Instance.new("Frame")
	rowFrame.Name = "ColorPicker"
	rowFrame.BackgroundColor3 = CONFIG.Colors.Element
	rowFrame.BorderSizePixel = 0
	rowFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	rowFrame.Parent = tab.Container
	trackNames(rowFrame)

	local rowCorner = Instance.new("UICorner")
	rowCorner.Parent = rowFrame
	trackNames(rowCorner)

	local rowCornerFiller = Instance.new("Frame")
	rowCornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	rowCornerFiller.BorderSizePixel = 0
	rowCornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	rowCornerFiller.Size = UDim2.new(1, 0, 0, 10)
	rowCornerFiller.Parent = rowFrame
	trackNames(rowCornerFiller)

	local rowTitle = Instance.new("TextLabel")
	rowTitle.BackgroundTransparency = 1
	rowTitle.BorderSizePixel = 0
	rowTitle.Position = UDim2.new(0.029, 0, 0.174, 0)
	rowTitle.Size = UDim2.new(0, 350, 0, 20)
	rowTitle.Font = Enum.Font.Ubuntu
	rowTitle.Text = title
	rowTitle.TextColor3 = CONFIG.Colors.TextPrimary
	rowTitle.TextSize = 14
	rowTitle.TextXAlignment = Enum.TextXAlignment.Left
	rowTitle.Parent = rowFrame
	trackNames(rowTitle)

	local swatch = Instance.new("Frame")
	swatch.AnchorPoint = Vector2.new(1, 0.5)
	swatch.Position = UDim2.new(1, -16, 0.5, 0)
	swatch.Size = UDim2.new(0, 28, 0, 20)
	swatch.BackgroundColor3 = default
	swatch.BorderSizePixel = 0
	swatch.Parent = rowFrame
	trackNames(swatch)

	local swatchCorner = Instance.new("UICorner")
	swatchCorner.CornerRadius = UDim.new(0, 4)
	swatchCorner.Parent = swatch
	trackNames(swatchCorner)

	local swatchStroke = Instance.new("UIStroke")
	swatchStroke.Color = CONFIG.Colors.Border
	swatchStroke.Thickness = 1
	swatchStroke.Parent = swatch
	trackNames(swatchStroke)

	local POP_W   = 230
	local HDR_H   = 34
	local SV_W    = 210
	local SV_H    = 140
	local BAR_H   = 10
	local PAD     = 10
	local POP_H   = HDR_H + PAD + SV_H + PAD + BAR_H + PAD

	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = CONFIG.Colors.Background
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.ZIndex = 48
	overlay.Visible = false
	overlay.Parent = self.MainFrame
	trackNames(overlay)

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.Parent = overlay
	trackNames(overlayCorner)

	local overlayBtn = Instance.new("TextButton")
	overlayBtn.Size = UDim2.new(1, 0, 1, 0)
	overlayBtn.BackgroundTransparency = 1
	overlayBtn.Text = ""
	overlayBtn.ZIndex = 49
	overlayBtn.AutoButtonColor = false
	overlayBtn.Parent = overlay
	trackNames(overlayBtn)

	local popup = Instance.new("Frame")
	popup.BackgroundColor3 = CONFIG.Colors.Element
	popup.BorderSizePixel = 0
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.Position = UDim2.new(0.5, 0, 0.5, 0)
	popup.Size = UDim2.new(0, POP_W, 0, POP_H)
	popup.ZIndex = 50
	popup.Visible = false
	popup.ClipsDescendants = true
	popup.Parent = self.MainFrame
	trackNames(popup)

	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 8)
	popupCorner.Parent = popup
	trackNames(popupCorner)

	local popupStroke = Instance.new("UIStroke")
	popupStroke.Color = CONFIG.Colors.Border
	popupStroke.Thickness = 1
	popupStroke.Transparency = 0.4
	popupStroke.Parent = popup
	trackNames(popupStroke)

	local popHeader = Instance.new("Frame")
	popHeader.BackgroundColor3 = CONFIG.Colors.Background
	popHeader.BorderSizePixel = 0
	popHeader.Size = UDim2.new(1, 0, 0, HDR_H)
	popHeader.ZIndex = 51
	popHeader.Parent = popup
	trackNames(popHeader)

	local popHeaderCorner = Instance.new("UICorner")
	popHeaderCorner.CornerRadius = UDim.new(0, 8)
	popHeaderCorner.Parent = popHeader
	trackNames(popHeaderCorner)

	local popHeaderFill = Instance.new("Frame")
	popHeaderFill.BackgroundColor3 = CONFIG.Colors.Background
	popHeaderFill.BorderSizePixel = 0
	popHeaderFill.Position = UDim2.new(0, 0, 1, -8)
	popHeaderFill.Size = UDim2.new(1, 0, 0, 8)
	popHeaderFill.ZIndex = 51
	popHeaderFill.Parent = popHeader
	trackNames(popHeaderFill)

	local popHeaderLine = Instance.new("Frame")
	popHeaderLine.BackgroundColor3 = CONFIG.Colors.Border
	popHeaderLine.BorderSizePixel = 0
	popHeaderLine.Position = UDim2.new(0, 0, 1, -1)
	popHeaderLine.Size = UDim2.new(1, 0, 0, 1)
	popHeaderLine.ZIndex = 52
	popHeaderLine.Parent = popHeader
	trackNames(popHeaderLine)

	local popTitleLbl = Instance.new("TextLabel")
	popTitleLbl.BackgroundTransparency = 1
	popTitleLbl.BorderSizePixel = 0
	popTitleLbl.AnchorPoint = Vector2.new(0, 0.5)
	popTitleLbl.Position = UDim2.new(0, PAD, 0.5, 0)
	popTitleLbl.Size = UDim2.new(1, -PAD * 2, 0, 16)
	popTitleLbl.Font = Enum.Font.Ubuntu
	popTitleLbl.Text = title
	popTitleLbl.TextColor3 = CONFIG.Colors.TextPrimary
	popTitleLbl.TextSize = 13
	popTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	popTitleLbl.ZIndex = 52
	popTitleLbl.Parent = popHeader
	trackNames(popTitleLbl)

	-- SV box
	local svBox = Instance.new("Frame")
	svBox.BackgroundColor3 = hsvToRgb(hue, 1, 1)
	svBox.BorderSizePixel = 0
	svBox.Position = UDim2.new(0, PAD, 0, HDR_H + PAD)
	svBox.Size = UDim2.new(0, SV_W, 0, SV_H)
	svBox.ZIndex = 51
	svBox.ClipsDescendants = true
	svBox.Parent = popup
	trackNames(svBox)

	local svCorner = Instance.new("UICorner")
	svCorner.CornerRadius = UDim.new(0, 4)
	svCorner.Parent = svBox
	trackNames(svCorner)

	local svSatLayer = Instance.new("Frame")
	svSatLayer.BackgroundColor3 = Color3.new(1, 1, 1)
	svSatLayer.BorderSizePixel = 0
	svSatLayer.Size = UDim2.new(1, 0, 1, 0)
	svSatLayer.ZIndex = 52
	svSatLayer.Parent = svBox
	trackNames(svSatLayer)

	local satGrad = Instance.new("UIGradient")
	satGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	satGrad.Rotation = 0
	satGrad.Parent = svSatLayer
	trackNames(satGrad)

	local svValLayer = Instance.new("Frame")
	svValLayer.BackgroundColor3 = Color3.new(0, 0, 0)
	svValLayer.BorderSizePixel = 0
	svValLayer.Size = UDim2.new(1, 0, 1, 0)
	svValLayer.ZIndex = 53
	svValLayer.Parent = svBox
	trackNames(svValLayer)

	local valGrad = Instance.new("UIGradient")
	valGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	valGrad.Rotation = 90
	valGrad.Parent = svValLayer
	trackNames(valGrad)

	-- SV cursor dot
	local svCursor = Instance.new("Frame")
	svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
	svCursor.Size = UDim2.new(0, 10, 0, 10)
	svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
	svCursor.BorderSizePixel = 0
	svCursor.ZIndex = 55
	svCursor.Parent = svBox
	trackNames(svCursor)

	local svCursorCorner = Instance.new("UICorner")
	svCursorCorner.CornerRadius = UDim.new(1, 0)
	svCursorCorner.Parent = svCursor
	trackNames(svCursorCorner)

	local svCursorStroke = Instance.new("UIStroke")
	svCursorStroke.Color = Color3.new(0, 0, 0)
	svCursorStroke.Thickness = 1.5
	svCursorStroke.Parent = svCursor
	trackNames(svCursorStroke)

	local svInput = Instance.new("TextButton")
	svInput.Size = UDim2.new(1, 0, 1, 0)
	svInput.BackgroundTransparency = 1
	svInput.Text = ""
	svInput.AutoButtonColor = false
	svInput.ZIndex = 56
	svInput.Parent = svBox
	trackNames(svInput)

	local hueBar = Instance.new("Frame")
	hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
	hueBar.BorderSizePixel = 0
	hueBar.Position = UDim2.new(0, PAD, 0, HDR_H + PAD + SV_H + PAD)
	hueBar.Size = UDim2.new(0, SV_W, 0, BAR_H)
	hueBar.ZIndex = 51
	hueBar.Parent = popup
	trackNames(hueBar)

	local hueBarCorner = Instance.new("UICorner")
	hueBarCorner.CornerRadius = UDim.new(1, 0)
	hueBarCorner.Parent = hueBar
	trackNames(hueBarCorner)

	local hueGrad = Instance.new("UIGradient")
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,   0,   0)),
		ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255,   0)),
		ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0, 255,   0)),
		ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0, 255, 255)),
		ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,   0, 255)),
		ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,   0, 255)),
		ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,   0,   0)),
	})
	hueGrad.Parent = hueBar
	trackNames(hueGrad)

	-- hue knob (thin vertical bar style)
	local hueKnob = Instance.new("Frame")
	hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
	hueKnob.Size = UDim2.new(0, 4, 0, BAR_H + 4)
	hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
	hueKnob.BorderSizePixel = 0
	hueKnob.ZIndex = 52
	hueKnob.Parent = hueBar
	trackNames(hueKnob)

	local hueKnobCorner = Instance.new("UICorner")
	hueKnobCorner.CornerRadius = UDim.new(0, 2)
	hueKnobCorner.Parent = hueKnob
	trackNames(hueKnobCorner)

	local hueKnobStroke = Instance.new("UIStroke")
	hueKnobStroke.Color = Color3.fromRGB(30, 30, 30)
	hueKnobStroke.Thickness = 1
	hueKnobStroke.Parent = hueKnob
	trackNames(hueKnobStroke)

	-- invisible click layer over hue bar
	local hueInput = Instance.new("TextButton")
	hueInput.Size = UDim2.new(1, 0, 1, 0)
	hueInput.BackgroundTransparency = 1
	hueInput.Text = ""
	hueInput.AutoButtonColor = false
	hueInput.ZIndex = 53
	hueInput.Parent = hueBar
	trackNames(hueInput)

	local function updateColor()
		currentColor = hsvToRgb(hue, sat, val)
		swatch.BackgroundColor3 = currentColor
		svBox.BackgroundColor3 = hsvToRgb(hue, 1, 1)
		svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
		hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
		if callback then pcall(callback, currentColor) end
	end

	updateColor()

	local function updateSV(x, y)
		sat = math.clamp((x - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
		val = 1 - math.clamp((y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
		updateColor()
	end

	local function updateHue(x)
		hue = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
		updateColor()
	end

	svInput.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			svDragging = true
			updateSV(inp.Position.X, inp.Position.Y)
		end
	end)
	svInput.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
	end)

	hueInput.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			hueDragging = true
			updateHue(inp.Position.X)
		end
	end)
	hueInput.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		if svDragging  then updateSV(inp.Position.X, inp.Position.Y) end
		if hueDragging then updateHue(inp.Position.X) end
	end)

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local function closePicker()
		isOpen = false
		TweenService:Create(overlay, tweenInfo, {BackgroundTransparency = 1}):Play()
		TweenService:Create(popup,   tweenInfo, {Size = UDim2.new(0, POP_W, 0, 0)}):Play()
		task.delay(0.15, function()
			if not isOpen then
				overlay.Visible = false
				popup.Visible   = false
				overlay.BackgroundTransparency = 1
			end
		end)
	end

	local function openPicker()
		isOpen = true
		overlay.BackgroundTransparency = 1
		overlay.Visible = true
		popup.Size = UDim2.new(0, POP_W, 0, 0)
		popup.Visible = true
		TweenService:Create(overlay, tweenInfo, {BackgroundTransparency = 0.35}):Play()
		TweenService:Create(popup,   tweenInfo, {Size = UDim2.new(0, POP_W, 0, POP_H)}):Play()
	end

	overlayBtn.MouseButton1Click:Connect(closePicker)

	local rowBtn = Instance.new("TextButton")
	rowBtn.Size = UDim2.new(1, 0, 1, 0)
	rowBtn.BackgroundTransparency = 1
	rowBtn.Text = ""
	rowBtn.AutoButtonColor = false
	rowBtn.ZIndex = 5
	rowBtn.Parent = rowFrame
	trackNames(rowBtn)

	rowBtn.MouseButton1Click:Connect(function()
		if isOpen then closePicker() else openPicker() end
	end)
	rowBtn.MouseEnter:Connect(function()
		rowFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		rowCornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
	end)
	rowBtn.MouseLeave:Connect(function()
		rowFrame.BackgroundColor3 = CONFIG.Colors.Element
		rowCornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	end)

	table.insert(tab.Elements, rowFrame)

	return {
		SetValue = function(_, color)
			currentColor = color
			hue, sat, val = rgbToHsv(color)
			updateColor()
		end,
		GetValue = function()
			return currentColor
		end,
	}
end

local rowFrame = Instance.new("Frame")
rowFrame.Name = "ColorPicker"
rowFrame.BackgroundColor3 = CONFIG.Colors.Element

function Library:SetScale(newScale)
	newScale = math.clamp(newScale, 0.1, 4)
	self.Scale = newScale
	local uiScale = self.CanvasGroup and self.CanvasGroup:FindFirstChildOfClass("UIScale")
	if uiScale then uiScale.Scale = newScale end
	if self.CanvasGroup then
		self.CanvasGroup.Size = UDim2.new(0, CONFIG.Sizes.MainFrame.X, 0, CONFIG.Sizes.MainFrame.Y)
	end
end

function Library:Destroy()
	stopNameRandomizer()
	if self.ScreenGui then self.ScreenGui:Destroy() end
end

return Library
