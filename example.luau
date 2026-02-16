local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library.luau"))()

local Window = Library.new({
    Title = "Hattori UI",
    Subtitle = "v1.0",
    Position = UDim2.new(0.05, 0, 0.22, 0)
})

local AimbotTab = Window:AddTab({
    Title = "Aimbot"
})

AimbotTab:AddToggle({
    Title = "Enable Aimbot",
    Description = "Automatically aim at targets",
    Default = false,
    Callback = function(enabled)
        print("Aimbot enabled:", enabled)
    end
})

AimbotTab:AddSlider({
    Title = "Smoothness",
    Description = "How smooth the aim movement is",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("Smoothness:", value)
    end
})

AimbotTab:AddSlider({
    Title = "FOV Size",
    Description = "Field of view radius for targeting",
    Min = 50,
    Max = 500,
    Default = 150,
    Increment = 1,
    Suffix = "px",
    Callback = function(value)
        print("FOV size:", value)
    end
})

AimbotTab:AddToggle({
    Title = "Target Teammates",
    Description = "Include teammates as targets",
    Default = false,
    Callback = function(enabled)
        print("Target teammates:", enabled)
    end
})

AimbotTab:AddButton({
    Title = "Reset Settings",
    Description = "Reset all aimbot settings to default",
    Callback = function()
        print("Settings reset")
    end
})
