-- FluxWare | Prison Life Script
-- Game: Prison Life
-- https://www.roblox.com/games/155615604/Prison-Life-v2-0-2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== CONFIG ====================
local Config = {
    -- ESP
    ESP = {
        Enabled = false,
        ShowPlayers = true,
        ShowDistance = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
    },

    -- Aimbot
    Aimbot = {
        Enabled = false,
        FOV = 150,
        Smoothness = 0.1,
        AimPart = "Head",
        TeamCheck = true,
        VisibilityCheck = false,
    },

    -- Movement
    Speed = {
        Enabled = false,
        Value = 50,
    },
    NoClip = {
        Enabled = false,
    },
    Fly = {
        Enabled = false,
        Speed = 60,
    },

    -- Misc
    InfiniteStamina = false,
    AutoFarm = false,
    SilentAim = false,
}

-- ==================== UTILITIES ====================
local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
    })
end

local function GetClosestPlayer(fov)
    local closestPlayer = nil
    local closestDistance = fov
    local camera = workspace.CurrentCamera
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(Config.Aimbot.AimPart)
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ==================== ESP ====================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FluxWare_ESP"
ESPFolder.Parent = game.CoreGui

local function CreateESP(player)
    if player == LocalPlayer then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FluxESP_" .. player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = ESPFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.TextColor3 = Config.ESP.TextColor
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.BackgroundTransparency = 1
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.TextColor3 = Config.ESP.TextColor
    distLabel.TextStrokeTransparency = 0
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Text = ""
    distLabel.Parent = billboard

    player.CharacterAdded:Connect(function(char)
        billboard.Adornee = char:WaitForChild("HumanoidRootPart")
    end)

    if player.Character then
        billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    end

    RunService.Heartbeat:Connect(function()
        if not Config.ESP.Enabled then
            billboard.Enabled = false
            return
        end
        billboard.Enabled = true
        if player.Character and RootPart then
            local dist = math.floor((player.Character:FindFirstChild("HumanoidRootPart") and
                (player.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) or 0)
            distLabel.Text = Config.ESP.ShowDistance and ("[" .. dist .. " studs]") or ""
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

-- ==================== SPEED ====================
RunService.Heartbeat:Connect(function()
    if Config.Speed.Enabled and Humanoid then
        Humanoid.WalkSpeed = Config.Speed.Value
    end
    if Config.InfiniteStamina then
        local stamina = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Stamina")
        if stamina then stamina.Value = 100 end
    end
end)

-- ==================== NO CLIP ====================
local NoClipConnection
local function ToggleNoClip(state)
    if state then
        NoClipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
    end
end

-- ==================== FLY ====================
local FlyConnection
local BodyVelocity, BodyGyro

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
            local camera = workspace.CurrentCamera
            local cf = camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            BodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * Config.Fly.Speed or Vector3.zero
            BodyGyro.CFrame = cf
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
        if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end
end

-- ==================== AIMBOT ====================
local AimConnection
local function ToggleAimbot(state)
    if state then
        AimConnection = RunService.RenderStepped:Connect(function()
            if not Config.Aimbot.Enabled then return end
            local target = GetClosestPlayer(Config.Aimbot.FOV)
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild(Config.Aimbot.AimPart)
                if aimPart then
                    local camera = workspace.CurrentCamera
                    local cf = CFrame.new(camera.CFrame.Position, aimPart.Position)
                    camera.CFrame = camera.CFrame:Lerp(cf, Config.Aimbot.Smoothness)
                end
            end
        end)
    else
        if AimConnection then AimConnection:Disconnect() AimConnection = nil end
    end
end

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP.Enabled = not Config.ESP.Enabled
        Notify("FluxWare", "ESP: " .. (Config.ESP.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.Speed.Enabled = not Config.Speed.Enabled
        Notify("FluxWare", "Speed: " .. (Config.Speed.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.NoClip.Enabled = not Config.NoClip.Enabled
        ToggleNoClip(Config.NoClip.Enabled)
        Notify("FluxWare", "NoClip: " .. (Config.NoClip.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Fly.Enabled = not Config.Fly.Enabled
        ToggleFly(Config.Fly.Enabled)
        Notify("FluxWare", "Fly: " .. (Config.Fly.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        ToggleAimbot(Config.Aimbot.Enabled)
        Notify("FluxWare", "Aimbot: " .. (Config.Aimbot.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Config.InfiniteStamina = not Config.InfiniteStamina
        Notify("FluxWare", "Infinite Stamina: " .. (Config.InfiniteStamina and "ON" or "OFF"))
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

Notify("FluxWare", "Prison Life script loaded! Press F1-F6 for features.", 5)
