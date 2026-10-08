--// DANZZY RUSUH - ROBLOX STUDIO

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DanzzyRusuh"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 500)
main.Position = UDim2.new(0.5, -150, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(130, 70, 255)
stroke.Thickness = 2
stroke.Parent = main

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(25, 15, 45)
header.BorderSizePixel = 0
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ DANZZY RUSUH"
title.TextColor3 = Color3.fromRGB(220, 200, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

--==================================================
-- HIDE
--==================================================

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.fromOffset(55, 28)
hideButton.Position = UDim2.new(1, -65, 0, 8)
hideButton.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
hideButton.Text = "HIDE"
hideButton.TextColor3 = Color3.new(1,1,1)
hideButton.TextSize = 10
hideButton.Font = Enum.Font.GothamBold
hideButton.BorderSizePixel = 0
hideButton.Parent = header

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 6)
hc.Parent = hideButton

--==================================================
-- OPEN
--==================================================

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(65, 65)
openButton.Position = UDim2.new(0.03, 0, 0.5, 0)
openButton.BackgroundColor3 = Color3.fromRGB(100, 45, 190)
openButton.Text = "OPEN"
openButton.TextColor3 = Color3.new(1,1,1)
openButton.TextSize = 11
openButton.Font = Enum.Font.GothamBold
openButton.BorderSizePixel = 0
openButton.Active = true
openButton.Draggable = true
openButton.Visible = false
openButton.Parent = gui

local oc = Instance.new("UICorner")
oc.CornerRadius = UDim.new(1, 0)
oc.Parent = openButton

hideButton.MouseButton1Click:Connect(function()
	main.Visible = false
	openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
	main.Visible = true
	openButton.Visible = false
end)

--==================================================
-- SCROLL
--==================================================

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -55)
scroll.Position = UDim2.fromOffset(5, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 650)
scroll.Parent = main

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.fromOffset(10, 5)
status.BackgroundTransparency = 1
status.Text = "STATUS: Siap"
status.TextColor3 = Color3.fromRGB(180, 160, 210)
status.TextSize = 10
status.Font = Enum.Font.Gotham
status.Parent = scroll

--==================================================
-- BUTTON
--==================================================

local function button(text, y)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, 40)
	b.Position = UDim2.fromOffset(10, y)
	b.BackgroundColor3 = Color3.fromRGB(55, 30, 90)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = scroll

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = b

	return b
end

--==================================================
-- CHARACTER
--==================================================

local function character()

	local char = player.Character
	if not char then return end

	local humanoid =
		char:FindFirstChildOfClass("Humanoid")

	local root =
		char:FindFirstChild("HumanoidRootPart")

	return char, humanoid, root
end

--==================================================
-- VEHICLE
--==================================================

local function nearestVehicle()

	local char, _, root = character()
	if not root then return end

	local nearest
	local distance = math.huge

	for _, model in ipairs(Workspace:GetDescendants()) do

		if model:IsA("Model") and model ~= char then

			local seat =
				model:FindFirstChildWhichIsA(
					"VehicleSeat",
					true
				)

			if seat then

				local d =
					(seat.Position - root.Position).Magnitude

				if d < distance then
					distance = d
					nearest = model
				end

			end
		end
	end

	return nearest
end

--==================================================
-- ANGKAT 300 STUDS
--==================================================

local lift = button(
	"🚗 ANGKAT MOBIL 300 STUDS",
	45
)

local lifted
local oldCFrame

lift.MouseButton1Click:Connect(function()

	if lifted and lifted.Parent then

		lifted:PivotTo(oldCFrame)

		lifted = nil
		oldCFrame = nil

		lift.Text = "🚗 ANGKAT MOBIL 300 STUDS"
		status.Text = "STATUS: Mobil diturunkan"

		return
	end

	local vehicle = nearestVehicle()

	if not vehicle then
		status.Text = "STATUS: Mobil tidak ditemukan"
		return
	end

	local _, _, root = character()

	if not root then return end

	lifted = vehicle
	oldCFrame = vehicle:GetPivot()

	vehicle:PivotTo(
		root.CFrame * CFrame.new(0, 300, -4)
	)

	lift.Text = "⬇️ TURUNKAN MOBIL"
	status.Text = "STATUS: Mobil naik 300 studs"
end)

--==================================================
-- TP MOBIL
--==================================================

local tp = button(
	"🚙 TP KE MOBIL",
	95
)

tp.MouseButton1Click:Connect(function()

	local _, _, root = character()
	local vehicle = nearestVehicle()

	if root and vehicle then
		root.CFrame =
			vehicle:GetPivot()
			* CFrame.new(0, 3, 5)

		status.Text = "STATUS: TP berhasil"
	end
end)

--==================================================
-- FLIP
--==================================================

local flip = button(
	"🔄 FLIP MOBIL",
	145
)

flip.MouseButton1Click:Connect(function()

	local vehicle = nearestVehicle()

	if vehicle then

		local cf = vehicle:GetPivot()

		vehicle:PivotTo(
			cf * CFrame.Angles(0, 0, math.pi)
		)

		status.Text = "STATUS: Mobil di-flip"
	end
end)

--==================================================
-- NOCLIP
--==================================================

local noclip = false

local noclipButton = button(
	"👻 NOCLIP: OFF",
	195
)

noclipButton.MouseButton1Click:Connect(function()

	noclip = not noclip

	noclipButton.Text =
		noclip and "👻 NOCLIP: ON"
		or "👻 NOCLIP: OFF"

	status.Text =
		noclip and "STATUS: Noclip ON"
		or "STATUS: Noclip OFF"
end)

RunService.Stepped:Connect(function()

	if not noclip then return end

	local char = player.Character

	if char then

		for _, obj in ipairs(char:GetDescendants()) do

			if obj:IsA("BasePart") then
				obj.CanCollide = false
			end

		end

	end
end)

--==================================================
-- WALKSPEED INPUT
--==================================================

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 40)
speedBox.Position = UDim2.fromOffset(10, 250)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.PlaceholderText = "Ketik WalkSpeed..."
speedBox.PlaceholderColor3 = Color3.fromRGB(150,150,160)
speedBox.Text = ""
speedBox.TextSize = 11
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false
speedBox.Parent = scroll

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 7)
sbc.Parent = speedBox

local speedButton = button(
	"🏃 SET WALKSPEED",
	300
)

speedButton.MouseButton1Click:Connect(function()

	local value = tonumber(speedBox.Text)

	if not value then
		status.Text = "STATUS: Masukkan angka"
		return
	end

	local _, humanoid = character()

	if humanoid then
		humanoid.WalkSpeed = value
		status.Text =
			"WALKSPEED: " .. tostring(value)
	end
end)

--==================================================
-- INFINITE JUMP
--==================================================

local infiniteJump = false

local jumpButton = button(
	"♾️ INFINITE JUMP: OFF",
	350
)

jumpButton.MouseButton1Click:Connect(function()

	infiniteJump = not infiniteJump

	if infiniteJump then
		jumpButton.Text =
			"♾️ INFINITE JUMP: ON"

		status.Text =
			"STATUS: Infinite Jump ON"
	else
		jumpButton.Text =
			"♾️ INFINITE JUMP: OFF"

		status.Text =
			"STATUS: Infinite Jump OFF"
	end
end)

UserInputService.JumpRequest:Connect(function()

	if not infiniteJump then
		return
	end

	local _, humanoid = character()

	if humanoid then
		humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)
	end
end)

--==================================================
-- RESET SPEED
--==================================================

local reset = button(
	"↩️ RESET WALKSPEED",
	400
)

reset.MouseButton1Click:Connect(function()

	local _, humanoid = character()

	if humanoid then
		humanoid.WalkSpeed = 16
		speedBox.Text = "16"
		status.Text = "STATUS: WalkSpeed kembali 16"
	end
end)

--==================================================
-- CLOSE
--==================================================

local close = button(
	"✕ TUTUP MENU",
	450
)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
