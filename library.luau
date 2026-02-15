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

function Library.new(options)
	local self = setmetatable({}, Library)
	options = options or {}

	self.Title = options.Title or "ui"
	self.Subtitle = options.Subtitle or "Game Name"
	self.Position = options.Position or UDim2.new(0.05, 0, 0.22, 0)
	self.Tabs = {}
	self.CurrentTab = nil
	self.IsOpen = false

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

		self.MainFrame = Instance.new("Frame")
		self.MainFrame.Name = game:GetService("HttpService"):GenerateGUID(false)
		self.MainFrame.BackgroundColor3 = CONFIG.Colors.Background
		self.MainFrame.BorderSizePixel = 0
		self.MainFrame.Position = self.Position
		self.MainFrame.Size = UDim2.new(0, CONFIG.Sizes.MainFrame.X, 0, CONFIG.Sizes.MainFrame.Y)
		self.MainFrame.Parent = self.ScreenGui

		local mainCorner = Instance.new("UICorner")
		mainCorner.Parent = self.MainFrame

		self:CreateHeader()

		-- ContentContainer with scrolling disabled
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

		local contentLayout = Instance.new("UIListLayout")
		contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contentLayout.Padding = UDim.new(0, 8)
		contentLayout.Parent = self.ContentContainer

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

	self.TabOpener = Instance.new("ImageLabel")
	self.TabOpener.Name = "TabOpener"
	self.TabOpener.BackgroundTransparency = 1
	self.TabOpener.BorderSizePixel = 0
	self.TabOpener.Position = UDim2.new(0.029, 0, 0.328, 0)
	self.TabOpener.Size = UDim2.new(0, 17, 0, 17)
	self.TabOpener.Image = "rbxassetid://131692115073395"
	self.TabOpener.ImageColor3 = CONFIG.Colors.TextSecondary
	self.TabOpener.Parent = header

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

	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local currentTween

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

		if currentTween then
			currentTween:Cancel()
		end

		currentTween = TweenService:Create(
			self.MainFrame,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = targetPos}
		)
		currentTween:Play()
	end

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position

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
	self.TabFrame = Instance.new("Frame")
	self.TabFrame.Name = "TabFrame"
	self.TabFrame.BackgroundColor3 = CONFIG.Colors.Background
	self.TabFrame.BorderSizePixel = 0
	self.TabFrame.Position = UDim2.new(0, 0, 0, 0)
	self.TabFrame.Size = UDim2.new(0, CONFIG.Sizes.TabFrame.X, 0, CONFIG.Sizes.TabFrame.Y)
	self.TabFrame.ClipsDescendants = true
	self.TabFrame.ZIndex = 2
	self.TabFrame.Visible = false
	self.TabFrame.Parent = self.MainFrame

	local tabCorner = Instance.new("UICorner")
	tabCorner.Parent = self.TabFrame

	local cornerFiller = Instance.new("Frame")
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Background
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0.925, 0, 0, 0)
	cornerFiller.Size = UDim2.new(0, 13, 1, 0)
	cornerFiller.Parent = self.TabFrame

	local borderLine = Instance.new("Frame")
	borderLine.BackgroundColor3 = CONFIG.Colors.Border
	borderLine.BorderSizePixel = 0
	borderLine.Position = UDim2.new(0.995, 0, 0, 0)
	borderLine.Size = UDim2.new(0, 1, 1, 0)
	borderLine.Parent = self.TabFrame

	self.CloseIcon = Instance.new("ImageLabel")
	self.CloseIcon.Name = "CloseIcon"
	self.CloseIcon.BackgroundTransparency = 1
	self.CloseIcon.BorderSizePixel = 0
	self.CloseIcon.Position = UDim2.new(0.088, 0, 0.041, 0)
	self.CloseIcon.Size = UDim2.new(0, 17, 0, 17)
	self.CloseIcon.Image = "rbxassetid://74216110692187"
	self.CloseIcon.ImageColor3 = CONFIG.Colors.TextSecondary
	self.CloseIcon.Parent = self.TabFrame

	self.TabListContainer = Instance.new("Frame")
	self.TabListContainer.Name = "TabListContainer"
	self.TabListContainer.BackgroundTransparency = 1
	self.TabListContainer.BorderSizePixel = 0
	self.TabListContainer.Position = UDim2.new(0.092, 0, 0.119, 0)
	self.TabListContainer.Size = UDim2.new(0, 153, 0, 357)
	self.TabListContainer.Parent = self.TabFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 7)
	tabLayout.Parent = self.TabListContainer
end

function Library:SetupEvents()
	pcall(function()
		local tabOpenerButton = Instance.new("TextButton")
		tabOpenerButton.Size = UDim2.new(1, 0, 1, 0)
		tabOpenerButton.BackgroundTransparency = 1
		tabOpenerButton.Text = ""
		tabOpenerButton.Parent = self.TabOpener

		tabOpenerButton.MouseButton1Click:Connect(function()
			pcall(function()
				self:ToggleTabs()
			end)
		end)

		local closeButton = Instance.new("TextButton")
		closeButton.Size = UDim2.new(1, 0, 1, 0)
		closeButton.BackgroundTransparency = 1
		closeButton.Text = ""
		closeButton.Parent = self.CloseIcon

		closeButton.MouseButton1Click:Connect(function()
			pcall(function()
				self:ToggleTabs()
			end)
		end)
	end)
end

function Library:ToggleTabs()
	self.IsOpen = not self.IsOpen
	self.TabFrame.Visible = self.IsOpen
end

function Library:AddTab(name, iconId)
	local tab = {}
	tab.Name = name
	tab.IconId = iconId or ""
	tab.Elements = {}

	-- Tab container with scrolling enabled
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

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Padding = UDim.new(0, 8)
	containerLayout.Parent = tab.Container

	local containerPadding = Instance.new("UIPadding")
	containerPadding.PaddingTop = UDim.new(0, 8)
	containerPadding.PaddingBottom = UDim.new(0, 20)
	containerPadding.Parent = tab.Container

	local tabButton = self:CreateTabButton(name, iconId, tab)

	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return {
		AddParagraph = function(_, options)
			return self:AddParagraph(tab, options)
		end,
		AddTitle = function(_, options)
			return self:AddTitle(tab, options)
		end,
		AddToggle = function(_, options)
			return self:AddToggle(tab, options)
		end,
		AddButton = function(_, options)
			return self:AddButton(tab, options)
		end,
		AddSlider = function(_, options)
			return self:AddSlider(tab, options)
		end,
	}
end

function Library:CreateTabButton(name, iconId, tab)
	local button = Instance.new("Frame")
	button.Name = "TabButton_" .. name
	button.BackgroundColor3 = CONFIG.Colors.Element
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0, 154, 0, 30)
	button.Parent = self.TabListContainer

	local corner = Instance.new("UICorner")
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.Colors.Border
	stroke.Thickness = 1
	stroke.Transparency = 1
	stroke.Parent = button

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0.061, 0, 0.174, 0)
	label.Size = UDim2.new(0, 136, 0, 20)
	label.Font = Enum.Font.Ubuntu
	label.Text = name
	label.TextColor3 = CONFIG.Colors.TextPrimary
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.Parent = button

	clickButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	tab.Button = button
	tab.Stroke = stroke

	return button
end

function Library:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		if t.Container and t.Button and t.Stroke then
			t.Container.Visible = false
			t.Button.BackgroundTransparency = 1
			t.Stroke.Transparency = 1
		end
	end

	if tab.Container and tab.Button and tab.Stroke then
		tab.Container.Visible = true
		tab.Button.BackgroundTransparency = 0
		tab.Stroke.Transparency = 0
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

	local corner = Instance.new("UICorner")
	corner.Parent = paragraph

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

	local bottomBorder = Instance.new("Frame")
	bottomBorder.BackgroundColor3 = CONFIG.Colors.Border
	bottomBorder.BorderSizePixel = 0
	bottomBorder.Position = UDim2.new(0, 0, 1, 0)
	bottomBorder.Size = UDim2.new(1, 0, 0, 1)
	bottomBorder.Parent = paragraph

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = paragraph

	local button = Instance.new("TextButton")
	button.Name = "HoverDetector"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = paragraph

	button.MouseEnter:Connect(function()
		pcall(function()
			paragraph.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		end)
	end)

	button.MouseLeave:Connect(function()
		pcall(function()
			paragraph.BackgroundColor3 = CONFIG.Colors.Element
			cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
		end)
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

	local corner = Instance.new("UICorner")
	corner.Parent = titleFrame

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

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = titleFrame

	local button = Instance.new("TextButton")
	button.Name = "HoverDetector"
	button.Size = UDim2.new(1, 0, 1, 0)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = titleFrame

	button.MouseEnter:Connect(function()
		pcall(function()
			titleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		end)
	end)

	button.MouseLeave:Connect(function()
		pcall(function()
			titleFrame.BackgroundColor3 = CONFIG.Colors.Element
			cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
		end)
	end)

	table.insert(tab.Elements, titleFrame)
	return titleFrame
end

function Library:AddToggle(tab, options)
	local title = options.Title or "Toggle"
	local description = options.Description or "Description"
	local default = options.Default or false
	local callback = options.Callback

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = "Toggle"
	toggleFrame.BackgroundColor3 = CONFIG.Colors.Element
	toggleFrame.BorderSizePixel = 0
	toggleFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	toggleFrame.Parent = tab.Container

	local corner = Instance.new("UICorner")
	corner.Parent = toggleFrame

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

	local checkboxState = default

	local checkboxBg = Instance.new("Frame")
	checkboxBg.Name = "CheckboxBackground"
	checkboxBg.BackgroundColor3 = checkboxState and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(25, 25, 25)
	checkboxBg.BorderSizePixel = 0
	checkboxBg.Position = UDim2.new(0.945, 0, 0.35, 0)
	checkboxBg.Size = UDim2.new(0, 18, 0, 18)
	checkboxBg.Parent = toggleFrame

	local checkboxCorner = Instance.new("UICorner")
	checkboxCorner.CornerRadius = UDim.new(0, 3)
	checkboxCorner.Parent = checkboxBg

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.AutoButtonColor = false
	clickButton.Parent = checkboxBg

	clickButton.MouseButton1Click:Connect(function()
		checkboxState = not checkboxState

		TweenService:Create(checkboxBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = checkboxState and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(25, 25, 25)
		}):Play()

		if callback then
			callback(checkboxState)
		end
	end)

	local bottomBorder = Instance.new("Frame")
	bottomBorder.BackgroundColor3 = CONFIG.Colors.Border
	bottomBorder.BorderSizePixel = 0
	bottomBorder.Position = UDim2.new(0, 0, 1, 0)
	bottomBorder.Size = UDim2.new(1, 0, 0, 1)
	bottomBorder.Parent = toggleFrame

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = toggleFrame

	local hoverDetector = Instance.new("TextButton")
	hoverDetector.Name = "HoverDetector"
	hoverDetector.Size = UDim2.new(1, 0, 1, 0)
	hoverDetector.BackgroundTransparency = 1
	hoverDetector.Text = ""
	hoverDetector.AutoButtonColor = false
	hoverDetector.ZIndex = 0
	hoverDetector.Parent = toggleFrame

	hoverDetector.MouseEnter:Connect(function()
		pcall(function()
			toggleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		end)
	end)

	hoverDetector.MouseLeave:Connect(function()
		pcall(function()
			toggleFrame.BackgroundColor3 = CONFIG.Colors.Element
			cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
		end)
	end)

	table.insert(tab.Elements, toggleFrame)
	return toggleFrame
end

function Library:AddButton(tab, options)
	local title = options.Title or "Button"
	local description = options.Description or "Description"
	local callback = options.Callback

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "Button"
	buttonFrame.BackgroundColor3 = CONFIG.Colors.Element
	buttonFrame.BorderSizePixel = 0
	buttonFrame.Size = UDim2.new(0, 570, 0, CONFIG.Sizes.ParagraphHeight)
	buttonFrame.Parent = tab.Container

	local corner = Instance.new("UICorner")
	corner.Parent = buttonFrame

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

	local actionIcon = Instance.new("ImageLabel")
	actionIcon.Name = "ActionIcon"
	actionIcon.BackgroundTransparency = 1
	actionIcon.BorderSizePixel = 0
	actionIcon.Position = UDim2.new(0.945, 0, 0.35, 0)
	actionIcon.Size = UDim2.new(0, 18, 0, 18)
	actionIcon.Image = "rbxassetid://10709791437"
	actionIcon.ImageColor3 = CONFIG.Colors.TextSecondary
	actionIcon.Parent = buttonFrame

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.AutoButtonColor = false
	clickButton.Parent = buttonFrame

	clickButton.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	local bottomBorder = Instance.new("Frame")
	bottomBorder.BackgroundColor3 = CONFIG.Colors.Border
	bottomBorder.BorderSizePixel = 0
	bottomBorder.Position = UDim2.new(0, 0, 1, 0)
	bottomBorder.Size = UDim2.new(1, 0, 0, 1)
	bottomBorder.Parent = buttonFrame

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = buttonFrame

	clickButton.MouseEnter:Connect(function()
		pcall(function()
			buttonFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		end)
	end)

	clickButton.MouseLeave:Connect(function()
		pcall(function()
			buttonFrame.BackgroundColor3 = CONFIG.Colors.Element
			cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
		end)
	end)

	table.insert(tab.Elements, buttonFrame)
	return buttonFrame
end

function Library:AddSlider(tab, options)
	local title = options.Title or "Slider"
	local description = options.Description or ""
	local min = options.Min or 0
	local max = options.Max or 100
	local default = options.Default or min
	local increment = options.Increment or 1
	local suffix = options.Suffix or ""
	local callback = options.Callback

	local hasDescription = description ~= ""
	local frameHeight = hasDescription and CONFIG.Sizes.ParagraphHeight or 38

	local sliderFrame = Instance.new("Frame")
	sliderFrame.Name = hasDescription and "SliderDesc" or "Slider"
	sliderFrame.BackgroundColor3 = CONFIG.Colors.Element
	sliderFrame.BorderSizePixel = 0
	sliderFrame.Size = UDim2.new(0, 570, 0, frameHeight)
	sliderFrame.Parent = tab.Container

	local corner = Instance.new("UICorner")
	corner.Parent = sliderFrame

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

	local sliderTrack = Instance.new("Frame")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Position = UDim2.new(0.501, 0, 0.553, -3)
	sliderTrack.Size = UDim2.new(0, 211, 0, 6)
	sliderTrack.Parent = sliderFrame

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = sliderTrack

	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "SliderFill"
	sliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	sliderFill.BorderSizePixel = 0
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.Parent = sliderTrack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill

	local sliderKnob = Instance.new("Frame")
	sliderKnob.Name = "SliderKnob"
	sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderKnob.BorderSizePixel = 0
	sliderKnob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	sliderKnob.Size = UDim2.new(0, 16, 0, 16)
	sliderKnob.ZIndex = 5
	sliderKnob.Parent = sliderTrack

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = sliderKnob

	local currentValue = default
	local dragging = false

	local function updateSlider(input)
		local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
		local value = math.floor((min + (max - min) * pos) / increment + 0.5) * increment
		value = math.clamp(value, min, max)

		currentValue = value
		valueLabel.Text = tostring(value) .. suffix

		TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(pos, 0, 1, 0)
		}):Play()

		TweenService:Create(sliderKnob, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(pos, 0, 0.5, 0)
		}):Play()

		pcall(function()
			if callback then
				callback(value)
			end
		end)
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

	local bottomBorder = Instance.new("Frame")
	bottomBorder.BackgroundColor3 = CONFIG.Colors.Border
	bottomBorder.BorderSizePixel = 0
	bottomBorder.Position = UDim2.new(0, 0, 1, 0)
	bottomBorder.Size = UDim2.new(1, 0, 0, 1)
	bottomBorder.Parent = sliderFrame

	local cornerFiller = Instance.new("Frame")
	cornerFiller.Name = "CornerFiller"
	cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
	cornerFiller.BorderSizePixel = 0
	cornerFiller.Position = UDim2.new(0, 0, 0.841, 0)
	cornerFiller.Size = UDim2.new(1, 0, 0, 10)
	cornerFiller.Parent = sliderFrame

	local hoverDetector = Instance.new("TextButton")
	hoverDetector.Name = "HoverDetector"
	hoverDetector.Size = UDim2.new(1, 0, 1, 0)
	hoverDetector.BackgroundTransparency = 1
	hoverDetector.Text = ""
	hoverDetector.AutoButtonColor = false
	hoverDetector.ZIndex = 0
	hoverDetector.Parent = sliderFrame

	hoverDetector.MouseEnter:Connect(function()
		pcall(function()
			sliderFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			cornerFiller.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
		end)
	end)

	hoverDetector.MouseLeave:Connect(function()
		pcall(function()
			sliderFrame.BackgroundColor3 = CONFIG.Colors.Element
			cornerFiller.BackgroundColor3 = CONFIG.Colors.Element
		end)
	end)

	table.insert(tab.Elements, sliderFrame)
	return sliderFrame
end

function Library:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return Library
