-- FluxWare | Blade Ball Script
-- Game: Blade Ball
-- https://www.roblox.com/games/13772394625/Blade-Ball

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ==================== CONFIG ====================
local Config = {
    -- Auto Parry
    AutoParry = {
        Enabled = false,
        Delay = 0,       -- Delay in seconds before parrying (0 = instant)
        Range = 30,      -- Distance at which the ball triggers auto parry
    },

    -- Ball Trajectory ESP
    BallESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 80, 0),
        Thickness = 2,
    },

    -- Movement
    Speed = {
        Enabled = false,
        Value = 40,
    },
    Fly = {
        Enabled = false,
        Speed = 55,
    },
    NoClip = {
        Enabled = false,
    },

    -- Anti Features
    AntiKill = false,

    -- ESP
    ESP = {
        Enabled = false,
        TextColor = Color3.fromRGB(255, 255, 255),
        ShowDistance = true,
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

local function GetBall()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "blade_ball" or obj.Name == "BladeBall") then
            return obj
        end
    end
    return nil
end

local function GetParryRemote()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("parry") or remote.Name:lower():find("block") or remote.Name:lower():find("deflect")) then
            return remote
        end
    end
    return nil
end

-- ==================== AUTO PARRY ====================
local ParryConnection
local isParrying = false

local function TryParry()
    if isParrying then return end
    local parryRemote = GetParryRemote()
    if parryRemote then
        isParrying = true
        task.delay(Config.AutoParry.Delay, function()
            parryRemote:FireServer()
            task.wait(0.1)
            isParrying = false
        end)
    end
end

local function ToggleAutoParry(state)
    if state then
        ParryConnection = RunService.Heartbeat:Connect(function()
            if not Config.AutoParry.Enabled then return end
            local ball = GetBall()
            if ball and RootPart then
                local dist = (ball.Position - RootPart.Position).Magnitude
                local velocity = ball.Velocity
                if dist < Config.AutoParry.Range and velocity.Magnitude > 5 then
                    -- Check if ball is heading toward the player
                    local toPlayer = (RootPart.Position - ball.Position).Unit
                    local ballDir = velocity.Unit
                    if toPlayer:Dot(ballDir) > 0.3 then
                        TryParry()
                    end
                end
            end
        end)
    else
        if ParryConnection then
            ParryConnection:Disconnect()
            ParryConnection = nil
        end
    end
end

-- ==================== BALL ESP ====================
local BallHighlight
local function UpdateBallESP()
    RunService.Heartbeat:Connect(function()
        local ball = GetBall()
        if Config.BallESP.Enabled and ball then
            if not BallHighlight or not BallHighlight.Parent then
                BallHighlight = Instance.new("SelectionBox")
                BallHighlight.Color3 = Config.BallESP.Color
                BallHighlight.LineThickness = Config.BallESP.Thickness
                BallHighlight.Parent = game.CoreGui
            end
            BallHighlight.Adornee = ball
            BallHighlight.Visible = true
        elseif BallHighlight then
            BallHighlight.Visible = false
        end
    end)
end
UpdateBallESP()

-- ==================== ESP ====================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FluxWare_BB_ESP"
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
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.TextColor3 = Config.ESP.TextColor
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
        billboard.Enabled = Config.ESP.Enabled
        if Config.ESP.ShowDistance and player.Character and RootPart then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = math.floor((hrp.Position - RootPart.Position).Magnitude)
                distLabel.Text = "[" .. dist .. " studs]"
            end
        else
            distLabel.Text = ""
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- ==================== SPEED ====================
RunService.Heartbeat:Connect(function()
    if Config.Speed.Enabled and Humanoid then
        Humanoid.WalkSpeed = Config.Speed.Value
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

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.AutoParry.Enabled = not Config.AutoParry.Enabled
        ToggleAutoParry(Config.AutoParry.Enabled)
        Notify("FluxWare", "Auto Parry: " .. (Config.AutoParry.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.BallESP.Enabled = not Config.BallESP.Enabled
        Notify("FluxWare", "Ball ESP: " .. (Config.BallESP.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Config.ESP.Enabled = not Config.ESP.Enabled
        Notify("FluxWare", "Player ESP: " .. (Config.ESP.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Config.Speed.Enabled = not Config.Speed.Enabled
        Notify("FluxWare", "Speed Hack: " .. (Config.Speed.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        Config.Fly.Enabled = not Config.Fly.Enabled
        ToggleFly(Config.Fly.Enabled)
        Notify("FluxWare", "Fly: " .. (Config.Fly.Enabled and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Config.NoClip.Enabled = not Config.NoClip.Enabled
        ToggleNoClip(Config.NoClip.Enabled)
        Notify("FluxWare", "NoClip: " .. (Config.NoClip.Enabled and "ON" or "OFF"))
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

Notify("FluxWare", "Blade Ball script loaded! F1=AutoParry F2=BallESP F3=PlayerESP F4=Speed F5=Fly F6=NoClip", 6)
