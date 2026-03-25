-- FluxWare | Escape a Brainrot Script
-- Game: Escape a Brainrot
-- https://www.roblox.com/games/Escape-a-Brainrot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== CONFIG ====================
local Config = {
    -- Auto Escape
    AutoEscape = {
        Enabled = false,
        SafeDistance = 40,   -- Distance to keep from the brainrot entity
    },

    -- Auto Collect Coins
    AutoCollect = {
        Enabled = false,
        Range = 50,
    },

    -- ESP
    ESP = {
        Enabled = false,
        ShowPlayers = true,
        ShowEnemies = true,
        ShowItems = true,
        PlayerColor = Color3.fromRGB(0, 200, 255),
        EnemyColor = Color3.fromRGB(255, 50, 50),
        ItemColor = Color3.fromRGB(255, 215, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        ShowDistance = true,
    },

    -- Movement
    Speed = {
        Enabled = false,
        Value = 45,
    },
    Fly = {
        Enabled = false,
        Speed = 60,
    },
    NoClip = {
        Enabled = false,
    },
    InfiniteJump = {
        Enabled = false,
    },

    -- God Mode (anti-kill)
    GodMode = {
        Enabled = false,
    },
}

-- ==================== UTILITIES ====================
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
    })
end

local function IsEnemy(obj)
    local name = obj.Name:lower()
    return name:find("brainrot") or name:find("enemy") or name:find("monster") or name:find("chaser")
end

local function IsCollectible(obj)
    local name = obj.Name:lower()
    return name:find("coin") or name:find("gem") or name:find("collectible") or name:find("item") or name:find("pickup")
end

-- ==================== ESP ====================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FluxWare_EABR_ESP"
ESPFolder.Parent = game.CoreGui

-- Player ESP
local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FluxESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = ESPFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.TextColor3 = Config.ESP.PlayerColor
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.TextColor3 = Config.ESP.TextColor
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = billboard

    player.CharacterAdded:Connect(function(char)
        billboard.Adornee = char:WaitForChild("HumanoidRootPart")
    end)
    if player.Character then
        billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    end

    RunService.Heartbeat:Connect(function()
        billboard.Enabled = Config.ESP.Enabled and Config.ESP.ShowPlayers
        if billboard.Enabled and player.Character and RootPart then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and Config.ESP.ShowDistance then
                distLabel.Text = "[" .. math.floor((hrp.Position - RootPart.Position).Magnitude) .. " studs]"
            end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do CreatePlayerESP(p) end
Players.PlayerAdded:Connect(CreatePlayerESP)

-- Enemy & Item Highlights
local function CreateWorldESP()
    RunService.Heartbeat:Connect(function()
        if not Config.ESP.Enabled then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local highlight = obj:FindFirstChildOfClass("Highlight")
                if Config.ESP.ShowEnemies and IsEnemy(obj) then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Parent = obj
                    end
                    highlight.FillColor = Config.ESP.EnemyColor
                    highlight.OutlineColor = Config.ESP.EnemyColor
                    highlight.FillTransparency = 0.6
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                elseif Config.ESP.ShowItems and IsCollectible(obj) then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Parent = obj
                    end
                    highlight.FillColor = Config.ESP.ItemColor
                    highlight.OutlineColor = Config.ESP.ItemColor
                    highlight.FillTransparency = 0.4
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
    end)
end
CreateWorldESP()

-- ==================== AUTO ESCAPE ====================
local AutoEscapeConnection
local function ToggleAutoEscape(state)
    if state then
        AutoEscapeConnection = RunService.Heartbeat:Connect(function()
            if not Config.AutoEscape.Enabled or not RootPart then return end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and IsEnemy(obj) then
                    local enemyPart = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
                    if enemyPart then
                        local dist = (enemyPart.Position - RootPart.Position).Magnitude
                        if dist < Config.AutoEscape.SafeDistance then
                            -- Move away from enemy
                            local awayDir = (RootPart.Position - enemyPart.Position).Unit
                            local target = RootPart.Position + awayDir * (Config.AutoEscape.SafeDistance + 10)
                            RootPart.CFrame = CFrame.new(target)
                        end
                    end
                end
            end
        end)
    else
        if AutoEscapeConnection then AutoEscapeConnection:Disconnect() AutoEscapeConnection = nil end
    end
end

-- ==================== AUTO COLLECT ====================
local AutoCollectConnection
local function ToggleAutoCollect(state)
    if state then
        AutoCollectConnection = RunService.Heartbeat:Connect(function()
            if not Config.AutoCollect.Enabled or not RootPart then return end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and IsCollectible(obj) then
                    local dist = (obj.Position - RootPart.Position).Magnitude
                    if dist < Config.AutoCollect.Range then
                        RootPart.CFrame = CFrame.new(obj.Position)
                        task.wait(0.05)
                    end
                end
            end
        end)
    else
        if AutoCollectConnection then AutoCollectConnection:Disconnect() AutoCollectConnection = nil end
    end
end

-- ==================== SPEED ====================
RunService.Heartbeat:Connect(function()
    if Config.Speed.Enabled and Humanoid then
        Humanoid.WalkSpeed = Config.Speed.Value
    end
end)

-- ==================== INFINITE JUMP ====================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump.Enabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ==================== NO CLIP ====================
local NoClipConnection
local function ToggleNoClip(state)
    if state then
        NoClipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    else
        if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
    end
end

-- ==================== FLY ====================
local FlyConnection, BodyVelocity, BodyGyro
local function ToggleFly(state)
    if state then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Parent = RootPart
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.P = 1e4
        BodyGyro.Parent = RootPart
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not Config.Fly.Enabled then return end
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            BodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * Config.Fly.Speed or Vector3.zero
            BodyGyro.CFrame = cam
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end
end

-- ==================== GOD MODE ====================
RunService.Heartbeat:Connect(function()
    if Config.GodMode.Enabled and Humanoid then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
        Notify("FluxWare", "ESP: " .. (Config.ESP.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.AutoEscape.Enabled = not Config.AutoEscape.Enabled
        ToggleAutoEscape(Config.AutoEscape.Enabled)
        Notify("FluxWare", "Auto Escape: " .. (Config.AutoEscape.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.AutoCollect.Enabled = not Config.AutoCollect.Enabled
        ToggleAutoCollect(Config.AutoCollect.Enabled)
        Notify("FluxWare", "Auto Collect: " .. (Config.AutoCollect.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Speed.Enabled = not Config.Speed.Enabled
        Notify("FluxWare", "Speed: " .. (Config.Speed.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Config.Fly.Enabled = not Config.Fly.Enabled
        ToggleFly(Config.Fly.Enabled)
        Notify("FluxWare", "Fly: " .. (Config.Fly.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Config.NoClip.Enabled = not Config.NoClip.Enabled
        ToggleNoClip(Config.NoClip.Enabled)
        Notify("FluxWare", "NoClip: " .. (Config.NoClip.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F7 then
        Config.InfiniteJump.Enabled = not Config.InfiniteJump.Enabled
        Notify("FluxWare", "Infinite Jump: " .. (Config.InfiniteJump.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Config.GodMode.Enabled = not Config.GodMode.Enabled
        Notify("FluxWare", "God Mode: " .. (Config.GodMode.Enabled and "ON" or "OFF"))
    end
end)

-- ==================== CHARACTER RESPAWN ====================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    if Config.Fly.Enabled then ToggleFly(true) end
    if Config.NoClip.Enabled then ToggleNoClip(true) end
end)

Notify("FluxWare", "Escape a Brainrot loaded! F1=ESP F2=AutoEscape F3=AutoCollect F4=Speed F5=Fly F6=NoClip F7=InfJump F8=GodMode", 7)
