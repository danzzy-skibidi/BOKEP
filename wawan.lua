--==================================================
--        NANDA-WAWAN PRIVATE SERVER FINDER
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "NandaWawanServerFinder"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- MAIN
--==================================================

local main = Instance.new("Frame")
main.Name = "NandaWawanMain"
main.Size = UDim2.new(0,455,0,420)
main.Position = UDim2.new(0.5,-227,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(14,11,27)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,24)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(85,30,170)
stroke.Thickness = 2
stroke.Parent = main

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()

			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end

		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)

	end
end)

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-70,0,45)
title.Position = UDim2.new(0,25,0,18)
title.Text = "NANDA-WAWAN PRIVATE SERVER"
title.TextColor3 = Color3.fromRGB(0,220,255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1,-50,0,25)
subtitle.Position = UDim2.new(0,25,0,58)
subtitle.Text = "by Nanda-Wawan"
subtitle.TextColor3 = Color3.fromRGB(155,150,175)
subtitle.TextSize = 14
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--==================================================
-- CLOSE
--==================================================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,38,0,38)
close.Position = UDim2.new(1,-53,0,18)
close.BackgroundColor3 = Color3.fromRGB(34,29,50)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,10)
closeCorner.Parent = close

--==================================================
-- SERVER INFO
--==================================================

local info = Instance.new("Frame")
info.Size = UDim2.new(1,-50,0,86)
info.Position = UDim2.new(0,25,0,95)
info.BackgroundColor3 = Color3.fromRGB(22,18,39)
info.BorderSizePixel = 0
info.Parent = main

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0,15)
infoCorner.Parent = info

local serverText = Instance.new("TextLabel")
serverText.BackgroundTransparency = 1
serverText.Size = UDim2.new(1,-30,0,30)
serverText.Position = UDim2.new(0,15,0,12)
serverText.Text = "Current Server: "..#Players:GetPlayers().." player(s)"
serverText.TextColor3 = Color3.fromRGB(0,220,255)
serverText.TextSize = 18
serverText.Font = Enum.Font.GothamBold
serverText.TextXAlignment = Enum.TextXAlignment.Left
serverText.Parent = info

local desc = Instance.new("TextLabel")
desc.BackgroundTransparency = 1
desc.Size = UDim2.new(1,-30,0,25)
desc.Position = UDim2.new(0,15,0,47)
desc.Text = "Set max player & click Hop."
desc.TextColor3 = Color3.fromRGB(150,145,170)
desc.TextSize = 14
desc.Font = Enum.Font.Gotham
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.Parent = info

--==================================================
-- MAX PLAYER
--==================================================

local maxPlayer = Instance.new("TextBox")
maxPlayer.Name = "MaxPlayer"
maxPlayer.Size = UDim2.new(1,-50,0,58)
maxPlayer.Position = UDim2.new(0,25,0,195)

maxPlayer.BackgroundColor3 = Color3.fromRGB(24,20,42)
maxPlayer.BorderSizePixel = 0

-- Bisa diganti sendiri
maxPlayer.Text = "1"

maxPlayer.TextEditable = true
maxPlayer.ClearTextOnFocus = false
maxPlayer.PlaceholderText = "Max Player"

maxPlayer.TextColor3 = Color3.fromRGB(255,255,255)
maxPlayer.PlaceholderColor3 = Color3.fromRGB(120,115,140)

maxPlayer.TextSize = 20
maxPlayer.Font = Enum.Font.GothamBold

maxPlayer.TextXAlignment = Enum.TextXAlignment.Center
maxPlayer.TextYAlignment = Enum.TextYAlignment.Center

maxPlayer.Parent = main

local maxCorner = Instance.new("UICorner")
maxCorner.CornerRadius = UDim.new(0,15)
maxCorner.Parent = maxPlayer

-- Hanya angka
maxPlayer:GetPropertyChangedSignal("Text"):Connect(function()

	local angka = maxPlayer.Text:gsub("[^0-9]","")

	if maxPlayer.Text ~= angka then
		maxPlayer.Text = angka
	end

end)

--==================================================
-- HOP BUTTON
--==================================================

local hop = Instance.new("TextButton")
hop.Name = "HopServer"
hop.Size = UDim2.new(1,-50,0,60)
hop.Position = UDim2.new(0,25,0,270)

hop.BackgroundColor3 = Color3.fromRGB(20,145,245)
hop.BorderSizePixel = 0

hop.Text = "HOP SERVER NOW"
hop.TextColor3 = Color3.fromRGB(255,255,255)
hop.TextSize = 18
hop.Font = Enum.Font.GothamBold

hop.Parent = main

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0,15)
hopCorner.Parent = hop

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-50,0,55)
status.Position = UDim2.new(0,25,0,345)

status.BackgroundColor3 = Color3.fromRGB(31,26,48)
status.BorderSizePixel = 0

status.Text = "AUTO HOP: DISABLED"
status.TextColor3 = Color3.fromRGB(170,165,185)
status.TextSize = 16
status.Font = Enum.Font.GothamBold

status.Parent = main

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0,15)
statusCorner.Parent = status

--==================================================
-- UPDATE PLAYER COUNT
--==================================================

local function updatePlayers()

	serverText.Text =
		"Current Server: "
		..#Players:GetPlayers()
		.." player(s)"

end

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

--==================================================
-- HOP
--==================================================

hop.MouseButton1Click:Connect(function()

	local angka = tonumber(maxPlayer.Text)

	if not angka then

		status.Text = "MASUKKAN MAX PLAYER!"
		status.TextColor3 = Color3.fromRGB(255,120,120)

		return
	end

	if angka < 1 then

		status.Text = "MINIMAL 1 PLAYER!"
		status.TextColor3 = Color3.fromRGB(255,120,120)

		return
	end

	status.Text = "CHECKING SERVER..."
	status.TextColor3 = Color3.fromRGB(0,220,255)

	task.wait(0.7)

	local current = #Players:GetPlayers()

	if current <= angka then

		status.Text = "SERVER MEMENUHI BATAS"
		status.TextColor3 = Color3.fromRGB(100,255,150)

	else

		status.Text = "SERVER TERLALU PENUH"
		status.TextColor3 = Color3.fromRGB(255,120,120)

	end

end)

--==================================================
-- OPEN BUTTON
--==================================================

local open = Instance.new("TextButton")
open.Name = "NandaWawanOpen"
open.Size = UDim2.new(0,58,0,58)
open.Position = UDim2.new(0,20,0.5,-29)

open.BackgroundColor3 = Color3.fromRGB(18,14,32)
open.Text = "N"
open.TextColor3 = Color3.fromRGB(0,220,255)
open.TextSize = 25
open.Font = Enum.Font.GothamBold

open.Visible = false
open.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1,0)
openCorner.Parent = open

--==================================================
-- HIDE / SHOW
--==================================================

close.MouseButton1Click:Connect(function()

	main.Visible = false
	open.Visible = true

end)

open.MouseButton1Click:Connect(function()

	main.Visible = true
	open.Visible = false

end)

print("Nanda-Wawan Server Finder Loaded")
