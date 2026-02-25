local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library.luau"))()

local Window = Library.new({
    Title = "TitsHub",
    Subtitle = "Blocks'n Props",
    Scale = 0.9,
    ToggleKey = Enum.KeyCode.G
})

local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://4483362458"
})

MainTab:AddButton({
    Title = "Remove KillBrick",
    Description = "Destroys the KillBrick if it exists",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        local classic = map and map:FindFirstChild("Classic")
        local killbrick = classic and classic:FindFirstChild("KillBrick")

        if killbrick then
            killbrick:Destroy()
            Window:Notify({
                Title = "Removed",
                Description = "KillBrick Removed!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "KillBrick not found!",
                Duration = 3
            })
        end
    end
})

MainTab:AddButton({
    Title = "Instant Win",
    Description = "Teleport to the Button part",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local map = workspace:FindFirstChild("Map")
        local classic = map and map:FindFirstChild("Classic")
        local buttonPart = classic and classic:FindFirstChild("Button")

        if buttonPart then
            hrp.CFrame = buttonPart.CFrame + Vector3.new(0, 3, 0)
        else
            Window:Notify({
                Title = "Error",
                Description = "Button not found!",
                Duration = 3
            })
        end
    end
})

local noclipEnabled = false
MainTab:AddToggle({
    Title = "Noclip",
    Description = "Toggle noclip on/off",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled then
        local player = game.Players.LocalPlayer
        if player and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)
