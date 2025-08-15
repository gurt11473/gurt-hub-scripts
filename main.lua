-- there are some formatting issues, but it shouldnt affect anything lmao
-- 08/14/2025 - Present

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local NotificationHolder = Instance.new("ScreenGui")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.ResetOnSpawn = false
NotificationHolder.Parent = PlayerGui

local HolderFrame = Instance.new("Frame")
HolderFrame.AnchorPoint = Vector2.new(1, 1)
HolderFrame.Position = UDim2.new(0.99, 0, 0.98, 0)
HolderFrame.Size = UDim2.new(0.3, 0, 0.6, 0)
HolderFrame.BackgroundTransparency = 1
HolderFrame.Parent = NotificationHolder

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0.02, 0)
ListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ListLayout.Parent = HolderFrame

local GuiFunctions = {
    ShowNotification = function(Text, Duration)
        local NotificationFrame = Instance.new("Frame")
        NotificationFrame.Size = UDim2.new(1, 0, 0, 0)
        NotificationFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
        NotificationFrame.BackgroundTransparency = 0
        NotificationFrame.ClipsDescendants = true
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.Parent = HolderFrame
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0.15, 0)
        Corner.Parent = NotificationFrame
        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                                            ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 210))})
        Gradient.Rotation = 90
        Gradient.Parent = NotificationFrame

        local Shadow = Instance.new("Frame")
        Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        Shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
        Shadow.Size = UDim2.new(1, 0, 1, 0)
        Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Shadow.BackgroundTransparency = 0.8
        Shadow.ZIndex = 0
        Shadow.ClipsDescendants = true
        Shadow.Parent = NotificationFrame

        local ShadowCorner = Instance.new("UICorner")
        ShadowCorner.CornerRadius = UDim.new(0.15, 0)
        ShadowCorner.Parent = Shadow

        local Label = Instance.new("TextLabel")
        Label.AnchorPoint = Vector2.new(0.5, 0.5)
        Label.Position = UDim2.new(0.5, 0, 0.5, 0)
        Label.Size = UDim2.new(0.9, 0, 0.7, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextScaled = true
        Label.Font = Enum.Font.GothamMedium
        Label.TextColor3 = Color3.fromRGB(40, 40, 40)
        Label.Parent = NotificationFrame

        TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0.1, 0)
        }):Play()

        task.delay(Duration or 3, function()
            TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            NotificationFrame:Destroy()
        end)
    end
}

local StartTime = tick()

local PlayerFunctions = {
    Respawn = function()
        local Character = LocalPlayer.Character
        if Character then
            Character:BreakJoints()
            LocalPlayer.Character = nil
            LocalPlayer.CharacterAdded:Wait()
            GuiFunctions.ShowNotification("Respawned!", 3)
        end
    end,

    Refresh = function()
        local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid", true)
        local pos = Humanoid and Humanoid.RootPart and Humanoid.RootPart.CFrame
        local camPos = workspace.CurrentCamera.CFrame

        PlayerFunctions.Respawn()

        task.spawn(function()
            local NewHumanoidRoot = LocalPlayer.CharacterAdded:Wait():WaitForChild("Humanoid").RootPart
            NewHumanoidRoot.CFrame = pos or NewHumanoidRoot.CFrame
            workspace.CurrentCamera.CFrame = camPos
        end)
    end,

    Teleport = function(x, y, z, ...)
        if typeof(x) == "CFrame" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = x
        elseif typeof(x) == "Vector3" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x)
        else
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z, ...)
        end
    end
}

local NoclipActive = false

local FlyActive = false
local FlyConnection
local FlySpeed = 50

local function GetNCParts()
    local parts = {}

    for _, part in next, LocalPlayer.Character:GetDescendants() do
        if part:IsA("BasePart") and part.CanCollide then
            table.insert(parts, part)
        end
    end
    return parts
end

local function Noclip()
    if not NoclipActive then
        return
    end

    for _, v in next, GetNCParts() do
        v.CanCollide = false
    end
end

local ESPActive = false

local Commands = {
    ["rejoin"] = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,

    ["esp"] = function()
        ESPActive = not ESPActive
        for _, Player in Players:GetPlayers() do
            if Player ~= LocalPlayer and Player.Character then
                local ExistingESP = Player.Character:FindFirstChild("Detector")
                if ESPActive then
                    if not ExistingESP then
                        local ESP = Instance.new("Highlight")
                        ESP.Adornee = Player.Character
                        ESP.FillColor = Player.TeamColor.Color
                        ESP.FillTransparency = 0.5
                        ESP.OutlineColor = Player.TeamColor.Color
                        ESP.OutlineTransparency = 0
                        ESP.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        ESP.Name = "Detector"
                        ESP.Parent = Player.Character
                        ESP.Enabled = true
                    end
                else
                    if ExistingESP then
                        ExistingESP:Destroy()
                    end
                end
            end
        end
    end,

    ["noclip"] = function()
        NoclipActive = not NoclipActive
        GuiFunctions.ShowNotification("Noclip State: " .. (NoclipActive and "Enabled" or "Disabled"))
    end,

    ["respawn"] = function()
        PlayerFunctions.Respawn()
    end,

    ["teleportcoords"] = function(Params)
        if not Params or #Params < 3 then
            GuiFunctions.ShowNotification("Usage: ;teleport x y z", 3)
            return
        end
        local X, Y, Z = tonumber(Params[1]), tonumber(Params[2]), tonumber(Params[3])
        if X and Y and Z then
            PlayerFunctions.Teleport(X, Y, Z)
            GuiFunctions.ShowNotification(string.format("Teleported to %.1f, %.1f, %.1f", X, Y, Z), 3)
        else
            GuiFunctions.ShowNotification("Invalid coordinates", 3)
        end
    end,

    ["goto"] = function(Params)
        if not Params[1] then
            GuiFunctions.ShowNotification("Usage: ;goto PlayerName", 3)
            return
        end
        for _, Player in Players:GetPlayers() do
            if Player.Name == Params[1] or Player.DisplayName == Params[1] then
                local TargetPlayer = Players:FindFirstChild(Params[1])
                if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
                    GuiFunctions.ShowNotification("Teleported to " .. Params[1], 3)
                else
                    GuiFunctions.ShowNotification("Player not found or not loaded", 3)
                end
            end
        end
    end,

    ["fly"] = function()
        local Character = LocalPlayer.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local HRP = Character.HumanoidRootPart
        FlyActive = not FlyActive
        if FlyActive then
            for _, part in Character:GetDescendants() do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            Humanoid.PlatformStand = true
            FlyConnection = RunService.RenderStepped:Connect(function()
                local Camera = workspace.CurrentCamera
                local MoveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    MoveDir = MoveDir + Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    MoveDir = MoveDir - Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    MoveDir = MoveDir - Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    MoveDir = MoveDir + Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    MoveDir = MoveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    MoveDir = MoveDir - Vector3.new(0, 1, 0)
                end
                if MoveDir.Magnitude > 0 then
                    HRP.AssemblyLinearVelocity = MoveDir.Unit * FlySpeed
                else
                    HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
            GuiFunctions.ShowNotification("Fly Enabled", 3)
        else
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
            Humanoid.PlatformStand = false
            HRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            GuiFunctions.ShowNotification("Fly Disabled", 3)
        end
    end,

    ["commands"] = function()
        local Channel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
        local Lines = {"Thank you for using Gurt Hub! The prefix is ';'. Here are the commands:",
                       "rejoin - Rejoin the game", "noclip - Toggle noclip", "respawn - Respawn",
                       "teleportcoords - Teleport to coordinates", "goto - Teleport to a player", "fly - Toggle fly"}

        for _, Line in ipairs(Lines) do
            Channel:DisplaySystemMessage(Line)
        end
    end,

    ["speed"] = function(Params)
        if not Params[1] then
            GuiFunctions.ShowNotification("Usage: ;speed value", 3)
            return
        end

        local Speed = tonumber(Params[1])

        if not Speed then
            GuiFunctions.ShowNotification("Invalid speed value", 3)
            return
        end

        local Character = LocalPlayer.Character
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        Humanoid.WalkSpeed = Speed
        GuiFunctions.ShowNotification("Speed set to " .. Speed, 3)
    end
}

TextChatService.SendingMessage:Connect(function(Message)
    local Text = Message.Text

    if string.sub(Text, 1, 1) == ";" then
        local Parts = string.split(string.sub(Text, 2), " ")
        local CommandName = table.remove(Parts, 1):lower()
        local Command = Commands[CommandName]

        if Command then
            Command(Parts)
        else
            GuiFunctions.ShowNotification("Unknown command: " .. CommandName, 3)
        end
    end
end)

local EndTime = tick()

GuiFunctions.ShowNotification(string.format("Gurt Hub loaded in %.2f seconds", EndTime - StartTime), 3)
GuiFunctions.ShowNotification("Please note: There is no server functionality yet. Commands will only affect you.", 5)

RunService.Stepped:Connect(Noclip)
