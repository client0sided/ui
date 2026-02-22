local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/client0sided/ui/refs/heads/main/library.luau"))()

local Window = Library.new({
    Title = "Hattori UI",
    Scale = 0.9,
    ToggleKey = Enum.KeyCode.G,
})

local PlayerTab = Window:AddTab({
    Title = "Player",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local InfiniteJump = {
    Enabled = false,
    Connection = nil
}

local InfiniteJumpToggle = PlayerTab:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if not player then return end
        
        InfiniteJump.Enabled = state
        
        if state then
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
            if InfiniteJump.Connection then
                InfiniteJump.Connection:Disconnect()
                InfiniteJump.Connection = nil
            end
        end
    end
})

local WalkspeedSlider = PlayerTab:AddSlider({
    Title = "Walkspeed",
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

local JumppowerSlider = PlayerTab:AddSlider({
    Title = "Jump Power",
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

local GravitySlider = PlayerTab:AddSlider({
    Title = "Gravity",
    Min = 0,
    Max = 500,
    Default = 196.2,
    Increment = 1,
    Suffix = "",
    Callback = function(value)
        game.Workspace.Gravity = value
    end
})

local HipHeightSlider = PlayerTab:AddSlider({
    Title = "Hip Height",
    Min = 0,
    Max = 100,
    Default = 0,
    Increment = 0.1,
    Suffix = "",
    Callback = function(value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.HipHeight = value
        end
    end
})

local VisualTab = Window:AddTab({
    Title = "Visuals",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local FullbrightToggle = VisualTab:AddToggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(state)
        if state then
            game.Lighting.Ambient = Color3.new(1, 1, 1)
            game.Lighting.Brightness = 2
            game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            game.Lighting.GlobalShadows = false
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
            game.Lighting.Brightness = 1
            game.Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            game.Lighting.GlobalShadows = true
        end
    end
})

local ESP = {
    Enabled = false,
    Connections = {},
    Boxes = {}
}

local function CreateESP(player)
    if not player.Character then return end
    local char = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = char
    highlight.FillColor = player.TeamColor.Color or Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    ESP.Boxes[player] = highlight
end

local ESPToggle = VisualTab:AddToggle({
    Title = "ESP",
    Default = false,
    Callback = function(state)
        ESP.Enabled = state
        
        if state then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    CreateESP(player)
                end
            end
            
            ESP.Connections.PlayerAdded = game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    wait(0.5)
                    if ESP.Enabled then
                        CreateESP(player)
                    end
                end)
            end)
            
            ESP.Connections.PlayerRemoving = game.Players.PlayerRemoving:Connect(function(player)
                if ESP.Boxes[player] then
                    ESP.Boxes[player]:Destroy()
                    ESP.Boxes[player] = nil
                end
            end)
        else
            for _, box in pairs(ESP.Boxes) do
                box:Destroy()
            end
            table.clear(ESP.Boxes)
            
            for _, conn in pairs(ESP.Connections) do
                conn:Disconnect()
            end
            table.clear(ESP.Connections)
        end
    end
})

local XRayToggle = VisualTab:AddToggle({
    Title = "X-Ray",
    Default = false,
    Callback = function(state)
        if state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v.LocalTransparencyModifier = 0.5
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end
})

local MovementTab = Window:AddTab({
    Title = "Movement",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local Fly = {
    Enabled = false,
    BodyGyro = nil,
    BodyVelocity = nil,
    Connection = nil
}

local FlyToggle = MovementTab:AddToggle({
    Title = "Fly",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if not player or not player.Character then return end
        
        local char = player.Character
        local humanoid = char:FindFirstChild("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        
        if state then
            if not rootPart then return end
            
            Fly.BodyGyro = Instance.new("BodyGyro")
            Fly.BodyGyro.P = 9e4
            Fly.BodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            Fly.BodyGyro.CFrame = rootPart.CFrame
            Fly.BodyGyro.Parent = rootPart
            
            Fly.BodyVelocity = Instance.new("BodyVelocity")
            Fly.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            Fly.BodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            Fly.BodyVelocity.Parent = rootPart
            
            humanoid.PlatformStand = true
            
            Fly.Connection = game:GetService("RunService").Heartbeat:Connect(function()
                if not Fly.Enabled or not rootPart then return end
                
                local moveDir = Vector3.new(0, 0, 0)
                local userInput = game:GetService("UserInputService")
                
                if userInput:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + (workspace.CurrentCamera.CFrame.LookVector * 50)
                end
                if userInput:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - (workspace.CurrentCamera.CFrame.LookVector * 50)
                end
                if userInput:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - (workspace.CurrentCamera.CFrame.RightVector * 50)
                end
                if userInput:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + (workspace.CurrentCamera.CFrame.RightVector * 50)
                end
                if userInput:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 50, 0)
                end
                if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir = moveDir - Vector3.new(0, 50, 0)
                end
                
                Fly.BodyVelocity.Velocity = moveDir
                Fly.BodyGyro.CFrame = workspace.CurrentCamera.CFrame
            end)
            
            Fly.Enabled = true
        else
            if Fly.BodyGyro then Fly.BodyGyro:Destroy() end
            if Fly.BodyVelocity then Fly.BodyVelocity:Destroy() end
            if Fly.Connection then Fly.Connection:Disconnect() end
            
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            Fly.BodyGyro = nil
            Fly.BodyVelocity = nil
            Fly.Connection = nil
            Fly.Enabled = false
        end
    end
})

local Noclip = {
    Enabled = false,
    Connection = nil
}

local NoclipToggle = MovementTab:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(state)
        Noclip.Enabled = state
        
        if state then
            Noclip.Connection = game:GetService("RunService").Stepped:Connect(function()
                if not Noclip.Enabled then return end
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    for _, v in ipairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Noclip.Connection then
                Noclip.Connection:Disconnect()
                Noclip.Connection = nil
            end
            
            local player = game.Players.LocalPlayer
            if player and player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
    end
})

local MiscTab = Window:AddTab({
    Title = "Misc",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local FPSButton = MiscTab:AddButton({
    Title = "Unlock FPS",
    Callback = function()
        setfpscap(999)
        print("FPS cap removed!")
    end
})

local AntiAfkToggle = MiscTab:AddToggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(state)
        if state then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
            print("Anti AFK enabled")
        else
            print("Anti AFK disabled")
        end
    end
})

local TimeSlider = MiscTab:AddSlider({
    Title = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Increment = 0.5,
    Suffix = ":00",
    Callback = function(value)
        game.Lighting.TimeOfDay = (value % 24) * 3600
    end
})

local WeatherDropdown = MiscTab:AddDropdown({
    Title = "Weather",
    Values = {"Clear", "Rain", "Snow", "Fog", "Storm"},
    Default = 1,
    Callback = function(value)
        if value == "Rain" then
            game.Lighting:SetAttribute("Atmosphere", "Rain")
        elseif value == "Snow" then
            game.Lighting:SetAttribute("Atmosphere", "Snow")
        elseif value == "Fog" then
            game.Lighting.FogEnd = 100
        elseif value == "Storm" then
            game.Lighting:SetAttribute("Atmosphere", "Storm")
        else
            game.Lighting.FogEnd = 100000
            game.Lighting:SetAttribute("Atmosphere", "Clear")
        end
    end
})

local CombatTab = Window:AddTab({
    Title = "Combat",
    Icon = "rbxassetid://YOUR_ICON_ID"
})

local Aimbot = {
    Enabled = false,
    Target = nil
}

local AimbotToggle = CombatTab:AddToggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(state)
        Aimbot.Enabled = state
    end
})

local AimbotSmoothness = CombatTab:AddSlider({
    Title = "Aimbot Smoothness",
    Min = 1,
    Max = 100,
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
    end
})

local SilentAimToggle = CombatTab:AddToggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(state)
        print("Silent Aim:", state)
    end
})

local TriggerBotToggle = CombatTab:AddToggle({
    Title = "Trigger Bot",
    Default = false,
    Callback = function(state)
        print("Trigger Bot:", state)
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    local player = game.Players.LocalPlayer
    
    if WalkspeedSlider and WalkspeedSlider.Value then
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = WalkspeedSlider.Value
        end
    end
    
    if JumppowerSlider and JumppowerSlider.Value then
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = JumppowerSlider.Value
        end
    end
    
    if HipHeightSlider and HipHeightSlider.Value then
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.HipHeight = HipHeightSlider.Value
        end
    end
    
    if FlyToggle and FlyToggle.State then
        wait(0.5)
        FlyToggle:Set(true)
    end
end)

print("Hattori UI v2.0 loaded")
