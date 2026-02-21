local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library.luau"))()

local Window = Library.new({
	Title = "Hattori UI",
	Subtitle = "v1.0",
	Scale = 0.9,
	ToggleKey = Enum.KeyCode.A, -- change to whatever
})

local AimbotTab = Window:AddTab({
	Title = "Aimbot",
})

local Toggle = AimbotTab:AddToggle({
	Title = "Enable Aimbot",
	Description = "Turn aimbot on or off",
	Default = false,
	Callback = function(state)
		print("Aimbot is now:", state)
	end
})

local Button = AimbotTab:AddButton({
	Title = "Reset Settings",
	Description = "Reset all settings to default",
	Callback = function()
		print("Settings reset!")
	end
})

local Slider = AimbotTab:AddSlider({
	Title = "Smoothness",
	Description = "Adjust aim smoothness",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Callback = function(value)
		print("Smoothness:", value)
	end
})

local Toggle2 = AimbotTab:AddToggle({
	Title = "Enable Aimbot",
	Description = "Turn aimbot on or off",
	Default = false,
	Callback = function(state)
		print("Aimbot is now:", state)
	end
})

local Button2 = AimbotTab:AddButton({
	Title = "Reset Settings",
	Description = "Reset all settings to default",
	Callback = function()
		print("Settings reset!")
	end
})

local Slider2 = AimbotTab:AddSlider({
	Title = "Smoothness",
	Description = "Adjust aim smoothness",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Callback = function(value)
		print("Smoothness:", value)
	end
})

local picker = AimbotTab:AddColorPicker({
	Title = "Team Color",
	Default = Color3.fromRGB(255, 100, 50),
	Callback = function(color) print(color) end,
})

picker:SetValue(Color3.fromRGB(0, 255, 0))
print(picker:GetValue())
