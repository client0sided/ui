local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library.luau"))()

local Window = Library.new({
    Title = "Hattori UI",
    Subtitle = "v1.01",
    Scale = 0.9,
    ToggleKey = Enum.KeyCode.G,
})

local MainTab = Window:AddTab({
    Title = "Player",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local InfiniteJump = {
    Enabled = false,
    Connection = nil
}

local InfiniteJumpToggle = MainTab:AddToggle({
    Title = "Infinite Jump",
    Description = "Allows you to jump repeatedly in mid-air",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if not player then return end
        
        InfiniteJump.Enabled = state
        
        if state then
            print("Infinite Jump enabled")
            
            if InfiniteJump.Connection then
                InfiniteJump.Connection:Disconnect()
                InfiniteJump.Connection = nil
            end
            
            InfiniteJump.Connection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if not InfiniteJump.Enabled then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                if not humanoid then return end
                
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        else
            print("Infinite Jump disabled")
            
            if InfiniteJump.Connection then
                InfiniteJump.Connection:Disconnect()
                InfiniteJump.Connection = nil
            end
        end
    end
})

local WalkspeedSlider = MainTab:AddSlider({
    Title = "Walkspeed",
    Description = "Adjust movement speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Suffix = " studs/s",
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

local JumppowerSlider = MainTab:AddSlider({
    Title = "Jump Power",
    Description = "Adjust jump height",
    Min = 50,
    Max = 200,
    Default = 50,
    Increment = 1,
    Suffix = "",
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = value
        end
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if WalkspeedSlider and WalkspeedSlider.Value then
        wait(0.1)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = WalkspeedSlider.Value
        end
    end
    
    if JumppowerSlider and JumppowerSlider.Value then
        wait(0.1)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = JumppowerSlider.Value
        end
    end
end)
