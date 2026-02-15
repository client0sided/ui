local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library"))()


local UI = Library.new({
	Title = "hattori ui",
	Subtitle = "aimbot",
	Position = UDim2.new(0.05, 0, 0.22, 0)
})

local tabs = {
	Aimbot = UI:AddTab("Aimbot", "rbxassetid://YOUR_ICON_ID")
}

tabs.Aimbot:AddToggle({
	Title = "toggle or checkbox whatever",
	Description = "desc",
	Default = false,
	Callback = function(state)
		print("Aimbot enabled:", state)
	end
})

tabs.Aimbot:AddSlider({
	Title = "dih size",
	Description = "how big",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Suffix = "%",
	Callback = function(value)
		print("clicked:", value)
	end
})

tabs.Aimbot:AddSlider({
	Title = "hole size",
	Description = "ifykyk",
	Min = 50,
	Max = 500,
	Default = 150,
	Increment = 1,
	Suffix = "px",
	Callback = function(value)
		print("FOV size:", value)
	end
})

tabs.Aimbot:AddToggle({
	Title = "Target",
	Description = "target",
	Default = true,
	Callback = function(state)
		print("Target:", state)
	end
})

tabs.Aimbot:AddButton({
	Title = "obama have dih",
	Description = "lock onto nearest player",
	Callback = function()
		print("[instert n word]")
	end
})
