--[[
    Project: Kill player Bycipikturbo - LT2 Volcano Trap & Rusuh Bring Parts Integration (System + HD Clear Lighting)
    Style: Ciphub Cyberpunk Neon Theme + Particles + Volcano Trap + TP Base + Interactive Player List + LT2 Sub-Tabs
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.AwaitingPlayer or Players.PlayerAdded:Wait()
end

-- ==================== FITUR LOCK TIME / DAY & HD CLEAR LIGHTING (FIXED FLICKERING) ====================
local function applyLightingFix()
    Lighting.ClockTime = 14.0
    Lighting.Brightness = 2.0
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(applyLightingFix)
end)
-- ===================================================================================

-- Status Toggle, Selected Target & Volcano Unlocked State
local isRunning = false
local selectedTarget = nil
local volcanoUnlocked = false

-- Status Fitur Tambahan
local glowChamsEnabled = false
local espNameEnabled = false
local activeSpectateConn = nil
local spectatedPlayer = nil
local spawnedCarReference = nil

-- Koordinat Presisi Volcano & Safe Position
local VolcanoPosition = Vector3.new(-1593, 442, 1317)
local SafePosition = nil

-- Bikin UI Utama dengan pengaman CoreGui / PlayerGui yang aman
local guiParent = nil
pcall(function()
    if gethui then
        guiParent = gethui()
    end
end)
if not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CiphubBrutalCombinedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 485) -- Diperpanjang sedikit agar muat tambahan tombol baru
MainFrame.Position = UDim2.new(0.5, -130, 0.33, -227)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
MainFrame.BackgroundTransparency = 0.1 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(120, 60, 255)
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Efek Partikel Latar Belakang Bergerak (Tema Cyberpunk Purple/Blue)
local ParticleContainer = Instance.new("Folder")
ParticleContainer.Name = "BackgroundParticles"
ParticleContainer.Parent = MainFrame

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(1.0)
        if not MainFrame or not MainFrame.Parent then break end
        
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
        particle.Position = UDim2.new(math.random(5, 95) / 100, 0, 1, 0)
        
        if math.random(1, 2) == 1 then
            particle.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
        else
            particle.BackgroundColor3 = Color3.fromRGB(50, 180, 255)
        end
        
        particle.BackgroundTransparency = 0.2
        particle.BorderSizePixel = 0
        particle.ZIndex = 0
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = particle
        
        particle.Parent = ParticleContainer
        
        local targetPosY = math.random(10, 80) / 100
        local moveTween = TweenService:Create(particle, TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = UDim2.new(particle.Position.X.Scale + (math.random(-10, 10)/100), 0, targetPosY, 0),
            BackgroundTransparency = 1
        })
        moveTween:Play()
        moveTween.Completed:Connect(function()
            particle:Destroy()
        end)
    end
end)

local HeaderBg = Instance.new("Frame")
HeaderBg.Size = UDim2.new(1, 0, 0, 36)
HeaderBg.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
HeaderBg.BackgroundTransparency = 0.2
HeaderBg.BorderSizePixel = 0
HeaderBg.ZIndex = 1
HeaderBg.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = HeaderBg

local IsMinimized = false
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.Position = UDim2.new(0, 6, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.ZIndex = 3
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -64, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.TextColor3 = Color3.fromRGB(220, 200, 255)
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ RUSUH Bycipikturbo 👑"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 36, 0, 0)
Title.BackgroundTransparency = 1
Title.ZIndex = 2
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.ZIndex = 3
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    if activeSpectateConn then activeSpectateConn:Disconnect() end
    isRunning = false
    selectedTarget = nil
    ScreenGui:Destroy()
end)

-- Tombol Floating Open
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0.02, 0, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(100, 40, 200)
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 12
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Text = "OPEN"
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

-- Tombol Tab Navigation (4 Tab: VOLCANO, RUSUH, WALLHCK, LT2)
local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Size = UDim2.new(0.25, -3, 0, 26)
Tab1Btn.Position = UDim2.new(0, 4, 0, 42)
Tab1Btn.BackgroundColor3 = Color3.fromRGB(90, 40, 180)
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1Btn.TextSize = 8.5
Tab1Btn.Font = Enum.Font.GothamBold
Tab1Btn.Text = "VOLCANO"
Tab1Btn.ZIndex = 2
Tab1Btn.Parent = MainFrame

local Tab1Corner = Instance.new("UICorner")
Tab1Corner.CornerRadius = UDim.new(0, 6)
Tab1Corner.Parent = Tab1Btn

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Size = UDim2.new(0.25, -3, 0, 26)
Tab2Btn.Position = UDim2.new(0.25, 2, 0, 42)
Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
Tab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
Tab2Btn.TextSize = 8.5
Tab2Btn.Font = Enum.Font.GothamBold
Tab2Btn.Text = "RUSUH"
Tab2Btn.ZIndex = 2
Tab2Btn.Parent = MainFrame

local Tab2Corner = Instance.new("UICorner")
Tab2Corner.CornerRadius = UDim.new(0, 6)
Tab2Corner.Parent = Tab2Btn

local Tab3Btn = Instance.new("TextButton")
Tab3Btn.Size = UDim2.new(0.25, -3, 0, 26)
Tab3Btn.Position = UDim2.new(0.50, 0, 0, 42)
Tab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
Tab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
Tab3Btn.TextSize = 8.5
Tab3Btn.Font = Enum.Font.GothamBold
Tab3Btn.Text = "WALLHCK"
Tab3Btn.ZIndex = 2
Tab3Btn.Parent = MainFrame

local Tab3Corner = Instance.new("UICorner")
Tab3Corner.CornerRadius = UDim.new(0, 6)
Tab3Corner.Parent = Tab3Btn

local Tab4Btn = Instance.new("TextButton")
Tab4Btn.Size = UDim2.new(0.25, -3, 0, 26)
Tab4Btn.Position = UDim2.new(0.75, -2, 0, 42)
Tab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
Tab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
Tab4Btn.TextSize = 8.5
Tab4Btn.Font = Enum.Font.GothamBold
Tab4Btn.Text = "LT2"
Tab4Btn.ZIndex = 2
Tab4Btn.Parent = MainFrame

local Tab4Corner = Instance.new("UICorner")
Tab4Corner.CornerRadius = UDim.new(0, 6)
Tab4Corner.Parent = Tab4Btn

-- ==================== CONTAINER 1: VOLCANO TRAP ====================
local TrapContainer = Instance.new("ScrollingFrame")
TrapContainer.Size = UDim2.new(1, 0, 1, -76)
TrapContainer.Position = UDim2.new(0, 0, 0, 76)
TrapContainer.BackgroundTransparency = 1
TrapContainer.Visible = true
TrapContainer.ZIndex = 2
TrapContainer.CanvasSize = UDim2.new(0, 0, 0, 360)
TrapContainer.ScrollBarThickness = 4
TrapContainer.Parent = MainFrame
-- Konten Asli Volcano Trap
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.92, 0, 0, 18)
TargetLabel.Position = UDim2.new(0.04, 0, 0.01, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
TargetLabel.TextSize = 9.5
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.Text = "TARGET: (Belum dipilih)"
TargetLabel.ZIndex = 2
TargetLabel.Parent = TrapContainer

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(0.92, 0, 0, 115)
PlayerListScroll.Position = UDim2.new(0.04, 0, 0.06, 0)
PlayerListScroll.BackgroundColor3 = Color3.fromRGB(20, 14, 35)
PlayerListScroll.BackgroundTransparency = 0.4
PlayerListScroll.BorderSizePixel = 0
PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListScroll.ScrollBarThickness = 4
PlayerListScroll.ZIndex = 2
PlayerListScroll.Parent = TrapContainer

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = PlayerListScroll

local UIListLayout1 = Instance.new("UIListLayout")
UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout1.Padding = UDim.new(0, 4)
UIListLayout1.Parent = PlayerListScroll

-- Deklarasi Variabel Global untuk Menu Rusuh
local RusuhTargetLabel
local RusuhPlayerListScroll
local refreshPlayerList

refreshPlayerList = function()
    for _, child in pairs(PlayerListScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    if RusuhPlayerListScroll then
        for _, child in pairs(RusuhPlayerListScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            -- VOLCANO TAB ITEM
            local pItem = Instance.new("Frame")
            pItem.Size = UDim2.new(1, 0, 0, 32)
            pItem.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
            pItem.BackgroundTransparency = 0.4
            pItem.BorderSizePixel = 0
            pItem.ZIndex = 2
            pItem.Parent = PlayerListScroll

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = pItem

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 24, 0, 24)
            icon.Position = UDim2.new(0, 4, 0.5, -12)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
            icon.ZIndex = 3
            icon.Parent = pItem

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(0.40, 0, 0, 15)
            nameLbl.Position = UDim2.new(0, 32, 0, 2)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.TextSize = 9.5
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.Text = p.DisplayName
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.ZIndex = 3
            nameLbl.Parent = pItem

            local tagLbl = Instance.new("TextLabel")
            tagLbl.Size = UDim2.new(0.40, 0, 0, 12)
            tagLbl.Position = UDim2.new(0, 32, 0, 17)
            tagLbl.BackgroundTransparency = 1
            tagLbl.TextColor3 = Color3.fromRGB(180, 160, 210)
            tagLbl.TextSize = 8
            tagLbl.Font = Enum.Font.Gotham
            tagLbl.Text = "@" .. p.Name
            tagLbl.TextXAlignment = Enum.TextXAlignment.Left
            tagLbl.ZIndex = 3
            tagLbl.Parent = pItem

            local selectHitbox = Instance.new("TextButton")
            selectHitbox.Size = UDim2.new(0.50, 0, 1, 0)
            selectHitbox.BackgroundTransparency = 1
            selectHitbox.Text = ""
            selectHitbox.ZIndex = 3
            selectHitbox.Parent = pItem

            selectHitbox.MouseButton1Click:Connect(function()
                if not volcanoUnlocked then return end
                selectedTarget = p
                TargetLabel.Text = "TARGET: " .. p.Name
                TargetLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
            end)

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 24, 0, 22)
            tpBtn.Position = UDim2.new(1, -54, 0.5, -11)
            tpBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 9
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Text = "TP"
            tpBtn.ZIndex = 3
            tpBtn.Parent = pItem

            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0, 4)
            tpCorner.Parent = tpBtn

            tpBtn.MouseButton1Click:Connect(function()
                if not volcanoUnlocked then return end
                selectedTarget = p
                TargetLabel.Text = "TARGET: " .. p.Name
                TargetLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
                local myChar = LocalPlayer.Character
                local targetChar = p.Character
                if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end)

            local spBtn = Instance.new("TextButton")
            spBtn.Size = UDim2.new(0, 24, 0, 22)
            spBtn.Position = UDim2.new(1, -26, 0.5, -11)
            spBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
            spBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            spBtn.TextSize = 9
            spBtn.Font = Enum.Font.GothamBold
            spBtn.Text = "SP"
            spBtn.ZIndex = 3
            spBtn.Parent = pItem

            local spCorner = Instance.new("UICorner")
            spCorner.CornerRadius = UDim.new(0, 4)
            spCorner.Parent = spBtn

            spBtn.MouseButton1Click:Connect(function()
                if not volcanoUnlocked then return end
                if spectatedPlayer == p then
                    if activeSpectateConn then activeSpectateConn:Disconnect() end
                    Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    spectatedPlayer = nil
                    spBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
                else
                    if activeSpectateConn then activeSpectateConn:Disconnect() end
                    spectatedPlayer = p
                    spBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 100)
                    activeSpectateConn = RunService.RenderStepped:Connect(function()
                        if p.Character and p.Character:FindFirstChild("Humanoid") then
                            Workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
                        end
                    end)
                end
            end)

            -- RUSUH TAB ITEM
            if RusuhPlayerListScroll then
                local pItemR = Instance.new("Frame")
                pItemR.Size = UDim2.new(1, 0, 0, 32)
                pItemR.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
                pItemR.BackgroundTransparency = 0.4
                pItemR.BorderSizePixel = 0
                pItemR.ZIndex = 2
                pItemR.Parent = RusuhPlayerListScroll

                local itemCornerR = Instance.new("UICorner")
                itemCornerR.CornerRadius = UDim.new(0, 6)
                itemCornerR.Parent = pItemR

                local iconR = Instance.new("ImageLabel")
                iconR.Size = UDim2.new(0, 24, 0, 24)
                iconR.Position = UDim2.new(0, 4, 0.5, -12)
                iconR.BackgroundTransparency = 1
                iconR.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
                iconR.ZIndex = 3
                iconR.Parent = pItemR

                local nameLblR = Instance.new("TextLabel")
                nameLblR.Size = UDim2.new(0.40, 0, 0, 15)
                nameLblR.Position = UDim2.new(0, 32, 0, 2)
                nameLblR.BackgroundTransparency = 1
                nameLblR.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLblR.TextSize = 9.5
                nameLblR.Font = Enum.Font.GothamBold
                nameLblR.Text = p.DisplayName
                nameLblR.TextXAlignment = Enum.TextXAlignment.Left
                nameLblR.ZIndex = 3
                nameLblR.Parent = pItemR

                local tagLblR = Instance.new("TextLabel")
                tagLblR.Size = UDim2.new(0.40, 0, 0, 12)
                tagLblR.Position = UDim2.new(0, 32, 0, 17)
                tagLblR.BackgroundTransparency = 1
                tagLblR.TextColor3 = Color3.fromRGB(180, 160, 210)
                tagLblR.TextSize = 8
                tagLblR.Font = Enum.Font.Gotham
                tagLblR.Text = "@" .. p.Name
                tagLblR.TextXAlignment = Enum.TextXAlignment.Left
                tagLblR.ZIndex = 3
                tagLblR.Parent = pItemR

                local selectHitboxR = Instance.new("TextButton")
                selectHitboxR.Size = UDim2.new(0.50, 0, 1, 0)
                selectHitboxR.BackgroundTransparency = 1
                selectHitboxR.Text = ""
                selectHitboxR.ZIndex = 3
                selectHitboxR.Parent = pItemR

                selectHitboxR.MouseButton1Click:Connect(function()
                    _G.RusuhTargetPlayer = p
                    if RusuhTargetLabel then
                        RusuhTargetLabel.Text = "RUSUH TARGET: " .. p.Name
                        RusuhTargetLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
                    end
                end)

                local tpBtnR = Instance.new("TextButton")
                tpBtnR.Size = UDim2.new(0, 24, 0, 22)
                tpBtnR.Position = UDim2.new(1, -54, 0.5, -11)
                tpBtnR.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
                tpBtnR.TextColor3 = Color3.fromRGB(255, 255, 255)
                tpBtnR.TextSize = 9
                tpBtnR.Font = Enum.Font.GothamBold
                tpBtnR.Text = "TP"
                tpBtnR.ZIndex = 3
                tpBtnR.Parent = pItemR

                local tpCornerR = Instance.new("UICorner")
                tpCornerR.CornerRadius = UDim.new(0, 4)
                tpCornerR.Parent = tpBtnR

                tpBtnR.MouseButton1Click:Connect(function()
                    _G.RusuhTargetPlayer = p
                    if RusuhTargetLabel then
                        RusuhTargetLabel.Text = "RUSUH TARGET: " .. p.Name
                        RusuhTargetLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
                    end
                    local myChar = LocalPlayer.Character
                    local targetChar = p.Character
                    if myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
                        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                end)

                local spBtnR = Instance.new("TextButton")
                spBtnR.Size = UDim2.new(0, 24, 0, 22)
                spBtnR.Position = UDim2.new(1, -26, 0.5, -11)
                spBtnR.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
                spBtnR.TextColor3 = Color3.fromRGB(255, 255, 255)
                spBtnR.TextSize = 9
                spBtnR.Font = Enum.Font.GothamBold
                spBtnR.Text = "SP"
                spBtnR.ZIndex = 3
                spBtnR.Parent = pItemR

                local spCornerR = Instance.new("UICorner")
                spCornerR.CornerRadius = UDim.new(0, 4)
                spCornerR.Parent = spBtnR

                spBtnR.MouseButton1Click:Connect(function()
                    if spectatedPlayer == p then
                        if activeSpectateConn then activeSpectateConn:Disconnect() end
                        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                        spectatedPlayer = nil
                        spBtnR.BackgroundColor3 = Color3.fromRGB(50, 30, 90)
                    else
                        if activeSpectateConn then activeSpectateConn:Disconnect() end
                        spectatedPlayer = p
                        spBtnR.BackgroundColor3 = Color3.fromRGB(40, 150, 100)
                        activeSpectateConn = RunService.RenderStepped:Connect(function()
                            if p.Character and p.Character:FindFirstChild("Humanoid") then
                                Workspace.CurrentCamera.CameraSubject = p.Character.Humanoid
                            end
                        end)
                    end
                end)
            end
        end
    end
    PlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout1.AbsoluteContentSize.Y)
    if RusuhPlayerListScroll then
        local layoutR = RusuhPlayerListScroll:FindFirstChildOfClass("UIListLayout")
        if layoutR then
            RusuhPlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, layoutR.AbsoluteContentSize.Y)
        end
    end
end

refreshPlayerList()

task.spawn(function()
    while true do
        task.wait(2.5)
        if ScreenGui and ScreenGui.Parent then
            refreshPlayerList()
        else
            break
        end
    end
end)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.92, 0, 0, 28)
ToggleButton.Position = UDim2.new(0.04, 0, 0.385, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 9.5
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "VOLCANO TRAP: OFF"
ToggleButton.ZIndex = 2
ToggleButton.Parent = TrapContainer

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    if not volcanoUnlocked then return end
    if not selectedTarget then
        TargetLabel.Text = "PILIH TARGET DULU DI LIST!"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        return
    end

    local myChar = LocalPlayer.Character
    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
        SafePosition = myChar.HumanoidRootPart.CFrame
    end

    isRunning = not isRunning
    if isRunning then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
        ToggleButton.Text = "VOLCANO TRAP: ON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 60)
        ToggleButton.Text = "VOLCANO TRAP: OFF"
    end
end)

local function executeTeleportToCar()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local targetPart = nil
    if spawnedCarReference and spawnedCarReference.Parent then
        targetPart = spawnedCarReference.PrimaryPart 
            or spawnedCarReference:FindFirstChild("Chassis") 
            or spawnedCarReference:FindFirstChild("VehicleSeat") 
            or spawnedCarReference:FindFirstChild("Body") 
            or spawnedCarReference:FindFirstChildWhichIsA("BasePart")
    end

    if not targetPart then
        local shortestDistance = math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= character then
                local carPart = obj:FindFirstChild("VehicleSeat") 
                    or obj:FindFirstChild("Chassis") 
                    or obj:FindFirstChildWhichIsA("VehicleSeat")
                if carPart then
                    local distance = (carPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        targetPart = carPart
                    end
                end
            end
        end
    end

    if targetPart then
        local driverSideCFrame = targetPart.CFrame + (targetPart.CFrame.RightVector * -3) + Vector3.new(0, 3, 0)
        character.HumanoidRootPart.CFrame = driverSideCFrame
    end
end

local TpCarButton = Instance.new("TextButton")
TpCarButton.Size = UDim2.new(0.92, 0, 0, 28)
TpCarButton.Position = UDim2.new(0.04, 0, 0.465, 0)
TpCarButton.BackgroundColor3 = Color3.fromRGB(50, 40, 90)
TpCarButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpCarButton.TextSize = 9.5
TpCarButton.Font = Enum.Font.GothamBold
TpCarButton.Text = "🚗 TP TO CAR"
TpCarButton.ZIndex = 2
TpCarButton.Parent = TrapContainer

local TpCarCorner = Instance.new("UICorner")
TpCarCorner.CornerRadius = UDim.new(0, 6)
TpCarCorner.Parent = TpCarButton

TpCarButton.MouseButton1Click:Connect(function()
    if not volcanoUnlocked then return end
    executeTeleportToCar()
end)

-- ==================== PERBAIKAN FITUR: TP BASE (LUMBER TYCOON 2) ====================
local TpBaseButton = Instance.new("TextButton")
TpBaseButton.Size = UDim2.new(0.92, 0, 0, 28)
TpBaseButton.Position = UDim2.new(0.04, 0, 0.545, 0)
TpBaseButton.BackgroundColor3 = Color3.fromRGB(70, 40, 130)
TpBaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpBaseButton.TextSize = 9.5
TpBaseButton.Font = Enum.Font.GothamBold
TpBaseButton.Text = "🏠 TP TO BASE"
TpBaseButton.ZIndex = 2
TpBaseButton.Parent = TrapContainer

local TpBaseCorner = Instance.new("UICorner")
TpBaseCorner.CornerRadius = UDim.new(0, 6)
TpBaseCorner.Parent = TpBaseButton

TpBaseButton.MouseButton1Click:Connect(function()
    if not volcanoUnlocked then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end

    local foundBaseCenter = nil

    local plotsFolder = Workspace:FindFirstChild("PlayerPlots")
    if plotsFolder then
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local ownerVal = plot:FindFirstChild("Owner")
            if ownerVal and ownerVal.Value == LocalPlayer then
                local woodSection = plot:FindFirstChild("WoodSection")
                if woodSection and woodSection:IsA("BasePart") then
                    foundBaseCenter = woodSection.CFrame + Vector3.new(0, 5, 0)
                    break
                end
                
                for _, part in ipairs(plot:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name == "Base" or part.Name == "WoodSection" or part.Name == "Land") then
                        foundBaseCenter = part.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
                if foundBaseCenter then break end
            end
        end
    end

    if not foundBaseCenter then
        for _, land in ipairs(Workspace:GetChildren()) do
            if land.Name == "Land" then
                local ownerVal = land:FindFirstChild("Owner")
                if ownerVal and ownerVal.Value == LocalPlayer then
                    local centerPart = land:FindFirstChild("Center") or land:FindFirstChild("WoodSection") or land:FindFirstChildWhichIsA("BasePart")
                    if centerPart then
                        foundBaseCenter = centerPart.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end
    end

    if not foundBaseCenter then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Owner" and obj.Value == LocalPlayer then
                local parentModel = obj.Parent
                if parentModel then
                    local basePart = parentModel:FindFirstChild("WoodSection") or parentModel:FindFirstChild("Center") or parentModel:FindFirstChildWhichIsA("BasePart")
                    if basePart then
                        foundBaseCenter = basePart.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end
    end

    if foundBaseCenter then
        myChar.HumanoidRootPart.CFrame = foundBaseCenter
        TargetLabel.Text = "STATUS: Berhasil Teleport ke Base!"
        TargetLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        TargetLabel.Text = "STATUS: Base belum di-load / tidak ditemukan!"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ==========================================
-- VEHICLE MODULE LOGIC (Flip & TP to Me)
-- ==========================================
local FlipVehicleBtn = Instance.new("TextButton")
FlipVehicleBtn.Size = UDim2.new(0.92, 0, 0, 28)
FlipVehicleBtn.Position = UDim2.new(0.04, 0, 0.625, 0)
FlipVehicleBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
FlipVehicleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlipVehicleBtn.TextSize = 9.5
FlipVehicleBtn.Font = Enum.Font.GothamBold
FlipVehicleBtn.Text = "🔄 FLIP VEHICLE"
FlipVehicleBtn.ZIndex = 2
FlipVehicleBtn.Parent = TrapContainer

local FlipCorner = Instance.new("UICorner")
FlipCorner.CornerRadius = UDim.new(0, 6)
FlipCorner.Parent = FlipVehicleBtn

FlipVehicleBtn.MouseButton1Click:Connect(function()
    if not volcanoUnlocked then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local nearest, nearestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < nearestDist then 
                nearest = obj
                nearestDist = d 
            end
        end
    end
    
    if nearest and nearest.Parent then
        nearest.Parent:PivotTo(nearest.Parent:GetPivot() * CFrame.Angles(0, 0, math.pi))
        TargetLabel.Text = "STATUS: Vehicle flipped!"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    else
        TargetLabel.Text = "STATUS: No vehicle found nearby!"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

local TpVehicleBtn = Instance.new("TextButton")
TpVehicleBtn.Size = UDim2.new(0.92, 0, 0, 28)
TpVehicleBtn.Position = UDim2.new(0.04, 0, 0.705, 0)
TpVehicleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TpVehicleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpVehicleBtn.TextSize = 9.5
TpVehicleBtn.Font = Enum.Font.GothamBold
TpVehicleBtn.Text = "🚙 TELEPORT VEHICLE TO ME"
TpVehicleBtn.ZIndex = 2
TpVehicleBtn.Parent = TrapContainer

local TpVehCorner = Instance.new("UICorner")
TpVehCorner.CornerRadius = UDim.new(0, 6)
TpVehCorner.Parent = TpVehicleBtn

TpVehicleBtn.MouseButton1Click:Connect(function()
    if not volcanoUnlocked then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local nearest, nearestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < nearestDist then 
                nearest = obj
                nearestDist = d 
            end
        end
    end
    
    if nearest and nearest.Parent then
        nearest.Parent:PivotTo(CFrame.new(hrp.Position + Vector3.new(5, 0, 0)))
        TargetLabel.Text = "STATUS: Vehicle teleported!"
        TargetLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    else
        TargetLabel.Text = "STATUS: No vehicle found nearby!"
        TargetLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)
-- ==================== CONTAINER 2: RUSUH / BRING PARTS ====================
local RusuhContainer = Instance.new("Frame")
RusuhContainer.Size = UDim2.new(1, 0, 1, -76)
RusuhContainer.Position = UDim2.new(0, 0, 0, 76)
RusuhContainer.BackgroundTransparency = 1
RusuhContainer.Visible = false
RusuhContainer.ZIndex = 2
RusuhContainer.Parent = MainFrame

RusuhTargetLabel = Instance.new("TextLabel")
RusuhTargetLabel.Size = UDim2.new(0.92, 0, 0, 18)
RusuhTargetLabel.Position = UDim2.new(0.04, 0, 0.01, 0)
RusuhTargetLabel.BackgroundTransparency = 1
RusuhTargetLabel.TextColor3 = Color3.fromRGB(180, 160, 210)
RusuhTargetLabel.TextSize = 9.5
RusuhTargetLabel.Font = Enum.Font.GothamBold
RusuhTargetLabel.Text = "RUSUH TARGET: (Pilih di List / Ketik bawah)"
RusuhTargetLabel.ZIndex = 2
RusuhTargetLabel.Parent = RusuhContainer

RusuhPlayerListScroll = Instance.new("ScrollingFrame")
RusuhPlayerListScroll.Size = UDim2.new(0.92, 0, 0, 120)
RusuhPlayerListScroll.Position = UDim2.new(0.04, 0, 0.075, 0)
RusuhPlayerListScroll.BackgroundColor3 = Color3.fromRGB(20, 14, 35)
RusuhPlayerListScroll.BackgroundTransparency = 0.4
RusuhPlayerListScroll.BorderSizePixel = 0
RusuhPlayerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RusuhPlayerListScroll.ScrollBarThickness = 4
RusuhPlayerListScroll.ZIndex = 2
RusuhPlayerListScroll.Parent = RusuhContainer

local RusuhScrollCorner = Instance.new("UICorner")
RusuhScrollCorner.CornerRadius = UDim.new(0, 6)
RusuhScrollCorner.Parent = RusuhPlayerListScroll

local UIListLayoutRusuh = Instance.new("UIListLayout")
UIListLayoutRusuh.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutRusuh.Padding = UDim.new(0, 4)
UIListLayoutRusuh.Parent = RusuhPlayerListScroll

local RusuhBox = Instance.new("TextBox")
RusuhBox.Size = UDim2.new(0.92, 0, 0, 30)
RusuhBox.Position = UDim2.new(0.04, 0, 0.38, 0)
RusuhBox.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
RusuhBox.BackgroundTransparency = 0.4
RusuhBox.PlaceholderText = "Ketik Nama Target Rusuh..."
RusuhBox.Text = ""
RusuhBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RusuhBox.TextSize = 10
RusuhBox.Font = Enum.Font.GothamBold
RusuhBox.ZIndex = 2
RusuhBox.Parent = RusuhContainer

local RusuhBoxCorner = Instance.new("UICorner")
RusuhBoxCorner.CornerRadius = UDim.new(0, 6)
RusuhBoxCorner.Parent = RusuhBox

local RusuhExecBtn = Instance.new("TextButton")
RusuhExecBtn.Size = UDim2.new(0.92, 0, 0, 40)
RusuhExecBtn.Position = UDim2.new(0.04, 0, 0.50, 0)
RusuhExecBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 210)
RusuhExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RusuhExecBtn.TextSize = 12
RusuhExecBtn.Font = Enum.Font.GothamBold
RusuhExecBtn.Text = "RUSUH OFF"
RusuhExecBtn.ZIndex = 2
RusuhExecBtn.Parent = RusuhContainer

local RusuhExecCorner = Instance.new("UICorner")
RusuhExecCorner.CornerRadius = UDim.new(0, 6)
RusuhExecCorner.Parent = RusuhExecBtn

-- Logika Bring Parts / Network Physics
local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(pItem)
        if pItem:IsA("BasePart") and pItem:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, pItem)
            pItem.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            pItem.CanCollide = false
        end
    end

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            pcall(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end)
            for _, bp in pairs(Network.BaseParts) do
                if bp and bp:IsDescendantOf(Workspace) then
                    bp.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
        if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
        if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        v.CanCollide = false
        
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
        
        Network.RetainPart(v)
    end
end

local blackHoleActive = false
local DescendantAddedConnection

local function getPlayerByName(name)
    local lowerName = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), lowerName) or string.find(string.lower(p.DisplayName), lowerName) then
            return p
        end
    end
end

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        RusuhExecBtn.Text = "RUSUH ON"
        RusuhExecBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end

        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v)
            end
        end)

        task.spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                local currentRusuhTarget = _G.RusuhTargetPlayer
                local char = currentRusuhTarget and currentRusuhTarget.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    Attachment1.WorldCFrame = hrp.CFrame
                elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    Attachment1.WorldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end
        end)
    else
        RusuhExecBtn.Text = "RUSUH OFF"
        RusuhExecBtn.BackgroundColor3 = Color3.fromRGB(110, 40, 210)
        if DescendantAddedConnection then
            DescendantAddedConnection:Disconnect()
        end
    end
end

RusuhExecBtn.MouseButton1Click:Connect(function()
    if RusuhBox.Text ~= "" then
        local typedTarget = getPlayerByName(RusuhBox.Text)
        if typedTarget then
            _G.RusuhTargetPlayer = typedTarget
            RusuhTargetLabel.Text = "RUSUH TARGET: " .. typedTarget.Name
            RusuhTargetLabel.TextColor3 = Color3.fromRGB(180, 160, 210)
        end
    end
    
    if not _G.RusuhTargetPlayer then
        _G.RusuhTargetPlayer = LocalPlayer
    end
    
    toggleBlackHole()
end)

-- ==================== CONTAINER 3: WALLHCK ====================
local WallhckContainer = Instance.new("Frame")
WallhckContainer.Size = UDim2.new(1, 0, 1, -76)
WallhckContainer.Position = UDim2.new(0, 0, 0, 76)
WallhckContainer.BackgroundTransparency = 1
WallhckContainer.Visible = false
WallhckContainer.ZIndex = 2
WallhckContainer.Parent = MainFrame

local GlowBtn = Instance.new("TextButton")
GlowBtn.Size = UDim2.new(0.92, 0, 0, 36)
GlowBtn.Position = UDim2.new(0.04, 0, 0.05, 0)
GlowBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
GlowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GlowBtn.TextSize = 9.5
GlowBtn.Font = Enum.Font.GothamBold
GlowBtn.Text = "GLOW CHAMS: OFF"
GlowBtn.ZIndex = 2
GlowBtn.Parent = WallhckContainer

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 6)
GlowCorner.Parent = GlowBtn

GlowBtn.MouseButton1Click:Connect(function()
    glowChamsEnabled = not glowChamsEnabled
    if glowChamsEnabled then
        GlowBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
        GlowBtn.Text = "GLOW CHAMS: ON"
    else
        GlowBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
        GlowBtn.Text = "GLOW CHAMS: OFF"
    end
end)

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.92, 0, 0, 36)
EspBtn.Position = UDim2.new(0.04, 0, 0.22, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 9.5
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Text = "ESP NAME: OFF"
EspBtn.ZIndex = 2
EspBtn.Parent = WallhckContainer

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspBtn

EspBtn.MouseButton1Click:Connect(function()
    espNameEnabled = not espNameEnabled
    if espNameEnabled then
        EspBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
        EspBtn.Text = "ESP NAME: ON"
    else
        EspBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
        EspBtn.Text = "ESP NAME: OFF"
    end
end)

-- ==================== CONTAINER 4: LT2 (DENGAN 4 SUB-TAB) ====================
local Lt2Container = Instance.new("Frame")
Lt2Container.Size = UDim2.new(1, 0, 1, -76)
Lt2Container.Position = UDim2.new(0, 0, 0, 76)
Lt2Container.BackgroundTransparency = 1
Lt2Container.Visible = false
Lt2Container.ZIndex = 2
Lt2Container.Parent = MainFrame

-- Tombol Sub-Tab LT2 (Kayu, Teleport, LocalTap 3, LocalTap 4)
local SubTab1Btn = Instance.new("TextButton")
SubTab1Btn.Size = UDim2.new(0.23, 0, 0, 22)
SubTab1Btn.Position = UDim2.new(0.04, 0, 0.02, 0)
SubTab1Btn.BackgroundColor3 = Color3.fromRGB(80, 35, 150)
SubTab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTab1Btn.TextSize = 8
SubTab1Btn.Font = Enum.Font.GothamBold
SubTab1Btn.Text = "Kayu"
SubTab1Btn.ZIndex = 3
SubTab1Btn.Parent = Lt2Container

local Sub1Corner = Instance.new("UICorner")
Sub1Corner.CornerRadius = UDim.new(0, 4)
Sub1Corner.Parent = SubTab1Btn

local SubTab2Btn = Instance.new("TextButton")
SubTab2Btn.Size = UDim2.new(0.23, 0, 0, 22)
SubTab2Btn.Position = UDim2.new(0.28, 0, 0.02, 0)
SubTab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
SubTab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
SubTab2Btn.TextSize = 8
SubTab2Btn.Font = Enum.Font.GothamBold
SubTab2Btn.Text = "Teleport"
SubTab2Btn.ZIndex = 3
SubTab2Btn.Parent = Lt2Container

local Sub2Corner = Instance.new("UICorner")
Sub2Corner.CornerRadius = UDim.new(0, 4)
Sub2Corner.Parent = SubTab2Btn

local SubTab3Btn = Instance.new("TextButton")
SubTab3Btn.Size = UDim2.new(0.23, 0, 0, 22)
SubTab3Btn.Position = UDim2.new(0.52, 0, 0.02, 0)
SubTab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
SubTab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
SubTab3Btn.TextSize = 8
SubTab3Btn.Font = Enum.Font.GothamBold
SubTab3Btn.Text = "LocalTap 3"
SubTab3Btn.ZIndex = 3
SubTab3Btn.Parent = Lt2Container

local Sub3Corner = Instance.new("UICorner")
Sub3Corner.CornerRadius = UDim.new(0, 4)
Sub3Corner.Parent = SubTab3Btn

local SubTab4Btn = Instance.new("TextButton")
SubTab4Btn.Size = UDim2.new(0.23, 0, 0, 22)
SubTab4Btn.Position = UDim2.new(0.76, 0, 0.02, 0)
SubTab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
SubTab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
SubTab4Btn.TextSize = 8
SubTab4Btn.Font = Enum.Font.GothamBold
SubTab4Btn.Text = "LocalTap 4"
SubTab4Btn.ZIndex = 3
SubTab4Btn.Parent = Lt2Container

local Sub4Corner = Instance.new("UICorner")
Sub4Corner.CornerRadius = UDim.new(0, 4)
Sub4Corner.Parent = SubTab4Btn

-- Frame Konten untuk masing-masing Sub-Tab LT2
local SubContent1 = Instance.new("ScrollingFrame")
SubContent1.Size = UDim2.new(0.92, 0, 0.84, 0)
SubContent1.Position = UDim2.new(0.04, 0, 0.12, 0)
SubContent1.BackgroundTransparency = 1
SubContent1.Visible = true
SubContent1.ZIndex = 3
SubContent1.ScrollBarThickness = 4
SubContent1.Parent = Lt2Container

local UIListLayoutSub1 = Instance.new("UIListLayout")
UIListLayoutSub1.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutSub1.Padding = UDim.new(0, 4)
UIListLayoutSub1.Parent = SubContent1

local SubContent2 = Instance.new("ScrollingFrame")
SubContent2.Size = UDim2.new(0.92, 0, 0.84, 0)
SubContent2.Position = UDim2.new(0.04, 0, 0.12, 0)
SubContent2.BackgroundTransparency = 1
SubContent2.Visible = false
SubContent2.ZIndex = 3
SubContent2.ScrollBarThickness = 4
SubContent2.Parent = Lt2Container

local UIListLayoutSub2 = Instance.new("UIListLayout")
UIListLayoutSub2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutSub2.Padding = UDim.new(0, 4)
UIListLayoutSub2.Parent = SubContent2

local SubContent3 = Instance.new("Frame")
SubContent3.Size = UDim2.new(0.92, 0, 0.84, 0)
SubContent3.Position = UDim2.new(0.04, 0, 0.12, 0)
SubContent3.BackgroundTransparency = 1
SubContent3.Visible = false
SubContent3.ZIndex = 3
SubContent3.Parent = Lt2Container

local SubText3 = Instance.new("TextLabel")
SubText3.Size = UDim2.new(1, 0, 1, 0)
SubText3.BackgroundTransparency = 1
SubText3.TextColor3 = Color3.fromRGB(200, 180, 255)
SubText3.TextSize = 10
SubText3.Font = Enum.Font.GothamBold
SubText3.Text = "✨ Konten LocalTap 3 (LT2)"
SubText3.ZIndex = 3
SubText3.Parent = SubContent3

local SubContent4 = Instance.new("Frame")
SubContent4.Size = UDim2.new(0.92, 0, 0.84, 0)
SubContent4.Position = UDim2.new(0.04, 0, 0.12, 0)
SubContent4.BackgroundTransparency = 1
SubContent4.Visible = false
SubContent4.ZIndex = 3
SubContent4.Parent = Lt2Container

local SubText4 = Instance.new("TextLabel")
SubText4.Size = UDim2.new(1, 0, 1, 0)
SubText4.BackgroundTransparency = 1
SubText4.TextColor3 = Color3.fromRGB(200, 180, 255)
SubText4.TextSize = 10
SubText4.Font = Enum.Font.GothamBold
SubText4.Text = "✨ Konten LocalTap 4 (LT2)"
SubText4.ZIndex = 3
SubText4.Parent = SubContent4

local WoodT = SubContent1
local TeleT = SubContent2

local function Notify(text, color)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 200, 0, 30)
    notif.Position = UDim2.new(0.5, -100, 0, 50)
    notif.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
    notif.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    notif.TextSize = 10
    notif.Font = Enum.Font.GothamBold
    notif.Text = text
    notif.ZIndex = 20
    notif.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notif

    task.delay(2, function()
        pcall(function() notif:Destroy() end)
    end)
end

local function NewButton(name, parent, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 30, 90)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 9.5
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.ZIndex = 4
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)

    if parent:IsA("ScrollingFrame") then
        local layout = parent:FindFirstChildOfClass("UIListLayout")
        if layout then
            parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end
    end
end

-- ==========================================
-- LOGIKA & MENU WOOD - GREEN HUB V2
-- ==========================================
local function getAxStats(axName, treClas)
    local mod = ReplicatedStorage.AxeClasses:FindFirstChild("AxeClass_"..axName)
    if not mod then return end
    local s = require(mod).new()
    if s.SpecialTrees and s.SpecialTrees[treClas] then
        for k, v in next, s.SpecialTrees[treClas] do 
            s[k] = v 
        end
    end
    return s
end

local function getTreeOfClass(clas)
    local pos = {}
    for _, r in next, workspace:GetChildren() do
        if r.Name == "TreeRegion" then
            for _, t in next, r:GetChildren() do
                if t:IsA("Model") and t:FindFirstChild("TreeClass") and t.TreeClass.Value == clas then
                    if t:FindFirstChild("CutEvent") and (not t:FindFirstChild("Owner") or t.Owner.Value == nil) then
                        local m = 0
                        for _, p in next, t:GetDescendants() do
                            if p:IsA("BasePart") then 
                                m = m + p.Mass 
                            end
                        end
                        table.insert(pos, {tre=t, mass=m})
                    end
                end
            end
        end
    end
    table.sort(pos, function(a,b) return a.mass > b.mass end)
    return pos[1] and pos[1].tre or nil
end

NewButton("BRING ALL WOOD", WoodT, Color3.fromRGB(139,90,43), function()
    local count = 0 
    for _, Log in pairs(workspace.LogModels:GetChildren()) do 
        if Log.Name:sub(1,6) == "Loose_" and Log:FindFirstChild("Owner") and Log.Owner.Value == LocalPlayer then 
            Log:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0,10,0)) 
            count = count + 1 
        end 
    end 
    Notify("Brought "..count.." logs!", Color3.fromRGB(139,90,43))
end)

NewButton("SELL EVERYTHING", WoodT, Color3.fromRGB(255,50,50), function()
    pcall(function() 
        loadstring(game:HttpGet('https://pastebin.com/raw/YZMvDRHB',true))() 
    end) 
    Notify("Selling...", Color3.fromRGB(255,50,50))
end)

NewButton("DELETE MY WOOD", WoodT, Color3.fromRGB(200,50,50), function()
    local count = 0 
    for _, Log in pairs(workspace.LogModels:GetChildren()) do 
        if Log.Name:sub(1,6) == "Loose_" and Log:FindFirstChild("Owner") and Log.Owner.Value == LocalPlayer then 
            Log:Destroy()
            count = count + 1 
        end 
    end 
    Notify("Deleted "..count.." logs!", Color3.fromRGB(200,50,50))
end)

local woodTypes = {
    {"BRING GENERIC", "Generic", Color3.fromRGB(150,150,150)},
    {"BRING OAK", "Oak", Color3.fromRGB(139,69,19)},
    {"BRING BIRCH", "Birch", Color3.fromRGB(255,228,196)},
    {"BRING CHERRY", "Cherry", Color3.fromRGB(255,105,180)},
    {"BRING WALNUT", "Walnut", Color3.fromRGB(101,67,33)},
    {"BRING FIR", "Fir", Color3.fromRGB(34,139,34)},
    {"BRING PINE", "Pine", Color3.fromRGB(0,100,0)},
    {"BRING VOLCANO", "Volcano", Color3.fromRGB(255,69,0)},
    {"BRING FROST", "Frost", Color3.fromRGB(0,255,255)},
    {"BRING GOLD", "GoldSwampy", Color3.fromRGB(255,215,0)},
    {"BRING KOA", "Koa", Color3.fromRGB(205,133,63)},
    {"BRING PALM", "Palm", Color3.fromRGB(244,164,96)},
    {"BRING CAVECRAWLER","CaveCrawler", Color3.fromRGB(169,169,169)},
    {"BRING ZOMBIE", "GreenSwampy", Color3.fromRGB(85,107,47)},
} 

for _, data in pairs(woodTypes) do 
    local lbl, woodType, color = data[1], data[2], data[3] 
    NewButton(lbl, WoodT, color, function() 
        local cooper = LocalPlayer 
        local curpos = cooper.Character.HumanoidRootPart.CFrame 
        local target = getTreeOfClass(woodType) 
        local ax = nil 
        
        for _, v in next, cooper.Backpack:GetChildren() do 
            if v:FindFirstChild("ToolName") then 
                ax = v
                break 
            end 
        end 
        
        if target and ax then 
            Notify("Bringing "..woodType.."...", color) 
            local stats = getAxStats(ax.ToolName.Value, woodType) 
            local newLog = nil 
            
            local con = workspace.LogModels.ChildAdded:Connect(function(l) 
                task.wait() 
                if l:FindFirstChild("Owner") and l.Owner.Value == cooper then 
                    newLog = l 
                end 
            end) 
            
            local lp = RunService.Heartbeat:Connect(function() 
                cooper.Character.HumanoidRootPart.CFrame = target.WoodSection.CFrame + Vector3.new(5,3,0) 
            end) 
            
            repeat 
                ReplicatedStorage.Interaction.RemoteProxy:FireServer(target.CutEvent, {
                    tool = ax,
                    height = 0.3,
                    faceVector = Vector3.new(1,0,0),
                    sectionId = 1,
                    hitPoints = stats.Damage,
                    cooldown = stats.SwingCooldown,
                    cuttingClass = "Axe"
                }) 
                task.wait(stats.SwingCooldown) 
            until newLog ~= nil 
            
            lp:Disconnect()
            con:Disconnect()
            task.wait(0.2) 
            
            for i = 1, 60 do 
                ReplicatedStorage.Interaction.ClientIsDragging:FireServer(newLog)
                newLog:PivotTo(curpos)
                task.wait() 
            end 
            
            cooper.Character.HumanoidRootPart.CFrame = curpos 
            Notify(woodType.." brought!", color) 
        else 
            Notify("No tree or axe found!", Color3.fromRGB(255,80,80)) 
        end 
    end) 
end

NewButton("BRING LONECAVE", WoodT, Color3.fromRGB(128,0,128), function() 
    local char = LocalPlayer.Character
    if not char then return end 
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end 
    local found = false 
    
    for _, tree in pairs(workspace:GetDescendants()) do 
        if tree:IsA("Model") and tree:FindFirstChild("TreeClass") and tree.TreeClass.Value == "Lonecave" then 
            local rootPart = tree:FindFirstChildWhichIsA("BasePart") 
            if rootPart then 
                local offset = tree:GetPivot():Inverse() * rootPart.CFrame 
                tree:PivotTo(hrp.CFrame * offset:Inverse()) 
            end 
            for _, part in pairs(tree:GetDescendants()) do 
                if part:IsA("BasePart") then 
                    part.CanCollide = false
                    part.Anchored = true 
                end 
            end 
            found = true 
        end 
    end 
    
    Notify(found and "Lonecave brought!" or "Lonecave not found!", found and Color3.fromRGB(128,0,128) or Color3.fromRGB(255,80,80))
end)

-- ==========================================
-- TELEPORT MODULE LOGIC (CipV99)
-- ==========================================
local LocData = {
    {"Wood R Us", CFrame.new(264,3,57)},
    {"Land Store", CFrame.new(111,11,-987)},
    {"Links Logic", CFrame.new(114,3,-611)},
    {"Volcano", CFrame.new(-1585,625,1140)},
    {"Swamp", CFrame.new(-1209,138,-801)},
    {"Cave", CFrame.new(3581,-177,430)},
    {"Palm Island", CFrame.new(2549,5,-42)},
    {"Fancy Furnishings", CFrame.new(491,13,-1720)},
    {"Boxed Cars", CFrame.new(509,5,-1463)},
    {"Fine Arts Shop", CFrame.new(5207,-156,719)},
    {"Bob's Shack", CFrame.new(260,10,-2542)},
    {"The Den", CFrame.new(323,49,1930)},
    {"Shrine of Sight", CFrame.new(-1600,205,919)},
    {"Ski Lodge", CFrame.new(1244,66,2306)},
    {"Strange Man", CFrame.new(1061,20,1131)},
    {"End Times", CFrame.new(113,-204,-951)},
    {"Spawn", CFrame.new(0,5,0)},
}

for _, d in pairs(LocData) do
    NewButton("TP: "..d[1], TeleT, Color3.fromRGB(0,150,255), function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = d[2]
        Notify("Teleported to "..d[1], Color3.fromRGB(0,150,255))
    end)
end

SubTab1Btn.MouseButton1Click:Connect(function()
    SubContent1.Visible = true; SubContent2.Visible = false; SubContent3.Visible = false; SubContent4.Visible = false
    SubTab1Btn.BackgroundColor3 = Color3.fromRGB(80, 35, 150); SubTab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubTab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

SubTab2Btn.MouseButton1Click:Connect(function()
    SubContent1.Visible = false; SubContent2.Visible = true; SubContent3.Visible = false; SubContent4.Visible = false
    SubTab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab2Btn.BackgroundColor3 = Color3.fromRGB(80, 35, 150); SubTab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubTab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

SubTab3Btn.MouseButton1Click:Connect(function()
    SubContent1.Visible = false; SubContent2.Visible = false; SubContent3.Visible = true; SubContent4.Visible = false
    SubTab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab3Btn.BackgroundColor3 = Color3.fromRGB(80, 35, 150); SubTab3Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubTab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

SubTab4Btn.MouseButton1Click:Connect(function()
    SubContent1.Visible = false; SubContent2.Visible = false; SubContent3.Visible = false; SubContent4.Visible = true
    SubTab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); SubTab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    SubTab4Btn.BackgroundColor3 = Color3.fromRGB(80, 35, 150); SubTab4Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- ==================== TAB SWITCHING LOGIC ====================
Tab1Btn.MouseButton1Click:Connect(function()
    TrapContainer.Visible = true
    RusuhContainer.Visible = false
    WallhckContainer.Visible = false
    Lt2Container.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(90, 40, 180); Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

Tab2Btn.MouseButton1Click:Connect(function()
    TrapContainer.Visible = false
    RusuhContainer.Visible = true
    WallhckContainer.Visible = false
    Lt2Container.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(90, 40, 180); Tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

Tab3Btn.MouseButton1Click:Connect(function()
    TrapContainer.Visible = false
    RusuhContainer.Visible = false
    WallhckContainer.Visible = true
    Lt2Container.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(90, 40, 180); Tab3Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab4Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab4Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
end)

Tab4Btn.MouseButton1Click:Connect(function()
    TrapContainer.Visible = false
    RusuhContainer.Visible = false
    WallhckContainer.Visible = false
    Lt2Container.Visible = true
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab1Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab2Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(30, 20, 50); Tab3Btn.TextColor3 = Color3.fromRGB(180, 160, 210)
    Tab4Btn.BackgroundColor3 = Color3.fromRGB(90, 40, 180); Tab4Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

-- ==================== MINIMIZE & OPEN LOGIC ====================
MinimizeBtn.MouseButton1Click:Connect(function()
    IsMinimized = true
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- ==================== BACKGROUND RUNSERVICE LOOPS ====================
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("CiphubGlowChams")
            if glowChamsEnabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "CiphubGlowChams"
                    hl.FillColor = Color3.fromRGB(130, 60, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.Parent = char
                end
            else
                if hl then hl:Destroy() end
            end

            local head = char:FindFirstChild("Head")
            if head then
                local bill = head:FindFirstChild("CiphubEspName")
                if espNameEnabled then
                    if not bill then
                        bill = Instance.new("BillboardGui")
                        bill.Name = "CiphubEspName"
                        bill.Size = UDim2.new(0, 100, 0, 40)
                        bill.StudsOffset = Vector3.new(0, 2.5, 0)
                        bill.AlwaysOnTop = true
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(180, 120, 255)
                        lbl.TextSize = 10
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = p.Name
                        lbl.TextStrokeTransparency = 0.5
                        lbl.Parent = bill
                        
                        bill.Parent = head
                    end
                else
                    if bill then bill:Destroy() end
                end
            end
        end
    end
end)

-- Loop Utama Volcano Trap Execution
task.spawn(function()
    while true do
        task.wait(0.1)
        if volcanoUnlocked and isRunning and selectedTarget and selectedTarget.Parent then
            local targetChar = selectedTarget.Character
            local myChar = LocalPlayer.Character
            
            if targetChar and myChar then
                local targetHumRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                local myHumRoot = myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar:FindFirstChild("Humanoid")

                if targetHumRoot and targetHumanoid and targetHumanoid.Health > 0 and myHumRoot and myHumanoid then
                    if not SafePosition then
                        SafePosition = myHumRoot.CFrame
                    end

                    myHumanoid.Sit = false
                    task.wait(0.02)
                    myHumRoot.CFrame = SafePosition

                    targetHumanoid.WalkSpeed = 0
                    targetHumanoid.JumpPower = 0

                    targetHumRoot.CFrame = myHumRoot.CFrame * CFrame.new(3, 0, 0)
                    task.wait(0.05)
                    
                    targetHumRoot.CFrame = CFrame.new(VolcanoPosition)
                    
                    task.wait(0.1)
                    targetHumanoid.Sit = false
                    
                    for _, v in pairs(targetChar:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("Motor6D") then
                            if (v.Part0 and (v.Part0.Name:lower():find("seat") or v.Part0:IsA("Seat") or v.Part0:IsA("VehicleSeat"))) or 
                               (v.Part1 and (v.Part1.Name:lower():find("seat") or v.Part1:IsA("Seat") or v.Part1:IsA("VehicleSeat"))) then
                                v:Destroy()
                            end
                        end
                    end
                    
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                            if (obj.Position - VolcanoPosition).Magnitude < 60 then
                                obj.Disabled = true
                                obj:Sit(nil)
                            end
                        end
                    end

                    if SafePosition then
                        myHumRoot.CFrame = SafePosition
                    end
                    
                    isRunning = false
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 60)
                    ToggleButton.Text = "VOLCANO TRAP: OFF"
                    TargetLabel.Text = "TARGET: " .. selectedTarget.Name .. " (Hangus di Volcano!)"
                    TargetLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
                end
            end
        end
    end
end)
