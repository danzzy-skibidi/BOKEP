-- ========================================================
--                 DANZZY MENU PREMIUM
-- ========================================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ========================================================
-- SETTINGS
-- ========================================================

_G.H42 = {
    AutoFarm = false,
    Fullbright = false,
    InfiniteJump = false,
    WalkSpeed = 16
}

-- ========================================================
-- GUI
-- ========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Danzzy_MENU"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.Size = UDim2.fromOffset(470, 455)
Main.Position = UDim2.new(0.5, -235, 0.5, -227)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Main.BorderSizePixel = 0

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Color = Color3.fromRGB(75, 85, 110)
Stroke.Thickness = 1.5

-- ========================================================
-- HEADER
-- ========================================================

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Color3.fromRGB(25, 28, 39)
Header.BorderSizePixel = 0

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -120, 0, 30)
Title.Position = UDim2.fromOffset(18, 8)
Title.BackgroundTransparency = 1
Title.Text = "DANZZY MENU"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = Header
SubTitle.Size = UDim2.new(1, -120, 0, 20)
SubTitle.Position = UDim2.fromOffset(19, 36)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PREMIUM CONTROL PANEL"
SubTitle.TextColor3 = Color3.fromRGB(145,150,170)
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ========================================================
-- HIDE
-- ========================================================

local HideButton = Instance.new("TextButton")
HideButton.Parent = Header
HideButton.Size = UDim2.fromOffset(34, 30)
HideButton.Position = UDim2.new(1, -80, 0, 16)
HideButton.Text = "−"
HideButton.TextSize = 20
HideButton.Font = Enum.Font.GothamBold
HideButton.TextColor3 = Color3.new(1,1,1)
HideButton.BackgroundColor3 = Color3.fromRGB(55,60,75)
HideButton.BorderSizePixel = 0

Instance.new("UICorner", HideButton).CornerRadius = UDim.new(0,6)

-- ========================================================
-- CLOSE
-- ========================================================

local Close = Instance.new("TextButton")
Close.Parent = Header
Close.Size = UDim2.fromOffset(34, 30)
Close.Position = UDim2.new(1, -40, 0, 16)
Close.Text = "X"
Close.TextSize = 13
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(190,45,45)
Close.BorderSizePixel = 0

Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)

-- ========================================================
-- STATUS
-- ========================================================

local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.Size = UDim2.new(1, -36, 0, 25)
Status.Position = UDim2.fromOffset(18, 75)
Status.BackgroundTransparency = 1
Status.Text = "● DANZZY SYSTEM READY"
Status.TextColor3 = Color3.fromRGB(80,220,120)
Status.TextSize = 11
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left

-- ========================================================
-- BUTTON CREATOR
-- ========================================================

local function Button(text, position)

    local B = Instance.new("TextButton")
    B.Parent = Main
    B.Size = UDim2.fromOffset(215, 40)
    B.Position = position
    B.BackgroundColor3 = Color3.fromRGB(43,47,60)
    B.BorderSizePixel = 0
    B.Text = text
    B.TextColor3 = Color3.fromRGB(235,235,235)
    B.TextSize = 11
    B.Font = Enum.Font.GothamBold
    B.AutoButtonColor = false

    Instance.new("UICorner", B).CornerRadius = UDim.new(0,7)

    local S = Instance.new("UIStroke")
    S.Parent = B
    S.Color = Color3.fromRGB(65,70,88)
    S.Thickness = 1

    B.MouseEnter:Connect(function()
        if not B:GetAttribute("Active") then
            B.BackgroundColor3 = Color3.fromRGB(55,60,75)
        end
    end)

    B.MouseLeave:Connect(function()
        if not B:GetAttribute("Active") then
            B.BackgroundColor3 = Color3.fromRGB(43,47,60)
        end
    end)

    return B
end

local function SetButton(B, text, active)

    B.Text = text
    B:SetAttribute("Active", active)

    if active then
        B.BackgroundColor3 = Color3.fromRGB(45,150,75)
    else
        B.BackgroundColor3 = Color3.fromRGB(43,47,60)
    end

end

-- ========================================================
-- MAIN BUTTONS
-- ========================================================

local AutoFarm = Button(
    "Auto Farm : OFF",
    UDim2.fromOffset(18,110)
)

local Fullbright = Button(
    "Fullbright : OFF",
    UDim2.fromOffset(237,110)
)

local InfiniteJump = Button(
    "Infinite Jump : OFF",
    UDim2.fromOffset(18,157)
)

local SpeedNormal = Button(
    "Speed Normal : 16",
    UDim2.fromOffset(237,157)
)

local SpeedFast = Button(
    "Speed Cepat : 50",
    UDim2.fromOffset(18,204)
)

local SpeedSuper = Button(
    "Speed Super : 100",
    UDim2.fromOffset(237,204)
)

-- ========================================================
-- TELEPORT
-- ========================================================

local Rumah = Button(
    "Teleport : Rumah",
    UDim2.fromOffset(18,251)
)

local Brewog = Button(
    "Teleport : Brewog",
    UDim2.fromOffset(237,251)
)

local Maxgen = Button(
    "Teleport : Maxgen",
    UDim2.fromOffset(18,298)
)

local GetCoord = Button(
    "GET COORDINATE",
    UDim2.fromOffset(237,298)
)

-- ========================================================
-- AUTO FARM
-- ========================================================

AutoFarm.MouseButton1Click:Connect(function()

    _G.H42.AutoFarm = not _G.H42.AutoFarm

    SetButton(
        AutoFarm,
        _G.H42.AutoFarm
            and "Auto Farm : ON"
            or "Auto Farm : OFF",
        _G.H42.AutoFarm
    )

    Status.Text = _G.H42.AutoFarm
        and "● AUTO FARM : ON"
        or "● DANZZY SYSTEM READY"

end)

-- ========================================================
-- FULLBRIGHT
-- ========================================================

Fullbright.MouseButton1Click:Connect(function()

    _G.H42.Fullbright = not _G.H42.Fullbright

    if _G.H42.Fullbright then

        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000

    else

        Lighting.Brightness = 1
        Lighting.FogEnd = 1000

    end

    SetButton(
        Fullbright,
        _G.H42.Fullbright
            and "Fullbright : ON"
            or "Fullbright : OFF",
        _G.H42.Fullbright
    )

end)

-- ========================================================
-- INFINITE JUMP
-- ========================================================

InfiniteJump.MouseButton1Click:Connect(function()

    _G.H42.InfiniteJump = not _G.H42.InfiniteJump

    SetButton(
        InfiniteJump,
        _G.H42.InfiniteJump
            and "Infinite Jump : ON"
            or "Infinite Jump : OFF",
        _G.H42.InfiniteJump
    )

end)

UserInputService.JumpRequest:Connect(function()

    if not _G.H42.InfiniteJump then
        return
    end

    local Character = LocalPlayer.Character
    local Humanoid = Character
        and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end

end)

-- ========================================================
-- SPEED 16
-- ========================================================

SpeedNormal.MouseButton1Click:Connect(function()

    local Character = LocalPlayer.Character
    local Humanoid = Character
        and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then

        Humanoid.WalkSpeed = 16
        _G.H42.WalkSpeed = 16
        Status.Text = "● SPEED : 16"

    end

end)

-- ========================================================
-- SPEED 50
-- ========================================================

SpeedFast.MouseButton1Click:Connect(function()

    local Character = LocalPlayer.Character
    local Humanoid = Character
        and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then

        Humanoid.WalkSpeed = 50
        _G.H42.WalkSpeed = 50
        Status.Text = "● SPEED : 50"

    end

end)

-- ========================================================
-- SPEED 100
-- ========================================================

SpeedSuper.MouseButton1Click:Connect(function()

    local Character = LocalPlayer.Character
    local Humanoid = Character
        and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then

        Humanoid.WalkSpeed the 2000
        _G.H42.WalkSpeed = 1000
        Status.Text = "● SPEED : 100"

    end

end)

-- ========================================================
-- GET COORDINATE
-- ========================================================

GetCoord.MouseButton1Click:Connect(function()

    local Character = LocalPlayer.Character
    local Root = Character
        and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Status.Text = "● CHARACTER BELUM SIAP"
        return
    end

    local P = Root.Position

    print("================================")
    print("       DANZZY COORDINATE")
    print("================================")
    print("X =", P.X)
    print("Y =", P.Y)
    print("Z =", P.Z)
    print("================================")

    Status.Text = string.format(
        "X %.1f | Y %.1f | Z %.1f",
        P.X,
        P.Y,
        P.Z
    )

end)

-- ========================================================
-- TELEPORT FUNCTION
-- ========================================================

local function TeleportTo(Name)

    local Target = workspace:FindFirstChild(Name, true)

    if not Target then

        Status.Text = "● " .. Name .. " : TIDAK DITEMUKAN"
        warn("[Danzzy] Lokasi tidak ditemukan:", Name)

        return
    end

    local Character = LocalPlayer.Character
    local Root = Character
        and Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Status.Text = "● CHARACTER BELUM SIAP"
        return
    end

    local Part

    if Target:IsA("BasePart") then
        Part = Target

    elseif Target:IsA("Model") then
        Part = Target.PrimaryPart
            or Target:FindFirstChildWhichIsA(
                "BasePart",
                true
            )
    end

    if not Part then

        Status.Text = "● " .. Name .. " : PART TIDAK ADA"
        return

    end

    Root.CFrame = Part.CFrame + Vector3.new(0,3,0)

    Status.Text = "● TELEPORT : " .. Name

end

-- ========================================================
-- TELEPORT BUTTONS
-- ========================================================

Rumah.MouseButton1Click:Connect(function()
    TeleportTo("Rumah")
end)

Brewog.MouseButton1Click:Connect(function()
    TeleportTo("Brewog")
end)

Maxgen.MouseButton1Click:Connect(function()
    TeleportTo("Maxgen")
end)

-- ========================================================
-- SHOW BUTTON
-- ========================================================

local ShowButton = Instance.new("TextButton")
ShowButton.Parent = ScreenGui
ShowButton.Size = UDim2.fromOffset(55,55)
ShowButton.Position = UDim2.new(0,20,0.5,-25)
ShowButton.Text = "D"
ShowButton.TextSize = 22
ShowButton.Font = Enum.Font.GothamBold
ShowButton.TextColor3 = Color3.fromRGB(255,255,255)
ShowButton.BackgroundColor3 = Color3.fromRGB(30,33,43)
ShowButton.BorderSizePixel = 0
ShowButton.Visible = false

Instance.new("UICorner", ShowButton).CornerRadius = UDim.new(1,0)

-- ========================================================
-- HIDE / SHOW
-- ========================================================

HideButton.MouseButton1Click:Connect(function()

    Main.Visible = false
    ShowButton.Visible = true

end)

ShowButton.MouseButton1Click:Connect(function()

    Main.Visible = true
    ShowButton.Visible = false

end)

Close.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()

end)

-- ========================================================
-- DRAG MENU
-- ========================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseMovement
    or Input.UserInputType == Enum.UserInputType.Touch then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

    end

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false

    end

end)

-- ========================================================
-- READY
-- ========================================================

print("================================")
print("       DANZZY MENU READY")
print("================================")
