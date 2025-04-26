--// Real Blade Ball Auto Parry with draggable, half-colored circular button

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

local replicatedStorage = game:GetService("ReplicatedStorage")
local parryRemote = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Parry")

local parryDistance = 25 -- distance to auto-parry

local autoParryEnabled = false

-- UI Creation
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "AutoParryGUI"

local mainButton = Instance.new("ImageButton", screenGui)
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(0, 70, 0, 70)
mainButton.Position = UDim2.new(0.1, 0, 0.5, 0)
mainButton.BackgroundColor3 = Color3.new(1, 1, 1)
mainButton.BorderSizePixel = 0
mainButton.Image = "rbxassetid://0"
mainButton.AutoButtonColor = false
mainButton.BackgroundTransparency = 1

-- Draw half black, half red circle
local uicorner = Instance.new("UICorner", mainButton)
uicorner.CornerRadius = UDim.new(1, 0)

local leftHalf = Instance.new("Frame", mainButton)
leftHalf.Size = UDim2.new(0.5, 0, 1, 0)
leftHalf.Position = UDim2.new(0, 0, 0, 0)
leftHalf.BackgroundColor3 = Color3.new(0, 0, 0)
leftHalf.BorderSizePixel = 0

local rightHalf = Instance.new("Frame", mainButton)
rightHalf.Size = UDim2.new(0.5, 0, 1, 0)
rightHalf.Position = UDim2.new(0.5, 0, 0, 0)
rightHalf.BackgroundColor3 = Color3.new(1, 0, 0)
rightHalf.BorderSizePixel = 0

local uicornerLeft = Instance.new("UICorner", leftHalf)
uicornerLeft.CornerRadius = UDim.new(1, 0)

local uicornerRight = Instance.new("UICorner", rightHalf)
uicornerRight.CornerRadius = UDim.new(1, 0)

-- Dragging
local dragging, dragInput, dragStart, startPos

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Main logic
mainButton.MouseButton1Click:Connect(function()
    autoParryEnabled = not autoParryEnabled
    if autoParryEnabled then
        leftHalf.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- green/black when ON
    else
        leftHalf.BackgroundColor3 = Color3.new(0, 0, 0) -- back to black/red when OFF
    end
end)

-- Auto Parry Loop
game:GetService("RunService").Heartbeat:Connect(function()
    if autoParryEnabled then
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name == "Ball" then
                local distance = (v.Position - humanoidRootPart.Position).Magnitude
                if distance <= parryDistance then
                    parryRemote:FireServer()
                end
            end
        end
    end
end)