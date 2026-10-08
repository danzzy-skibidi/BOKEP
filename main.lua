--// DANZZY RUSUH - SAFE VEHICLE MENU

local Players = game:GetService("Players")
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

--==================================================
-- MAIN MENU
--==================================================

local main = Instance.new("Frame")
main.Name = "MainMenu"
main.Size = UDim2.fromOffset(280, 330)
main.Position = UDim2.new(0.5, -140, 0.5, -165)
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

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ DANZZY RUSUH"
title.TextColor3 = Color3.fromRGB(220, 200, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

--==================================================
-- HIDE BUTTON
--==================================================

local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.fromOffset(55, 28)
hideButton.Position = UDim2.new(1, -65, 0, 8)
hideButton.BackgroundColor3 = Color3.fromRGB(70, 40, 110)
hideButton.Text = "HIDE"
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hideButton.TextSize = 10
hideButton.Font = Enum.Font.GothamBold
hideButton.BorderSizePixel = 0
hideButton.Parent = header

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 6)
hideCorner.Parent = hideButton

--==================================================
-- OPEN BUTTON
--==================================================

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.fromOffset(65, 65)
openButton.Position = UDim2.new(0.03, 0, 0.5, 0)
openButton.BackgroundColor3 = Color3.fromRGB(100, 45, 190)
openButton.Text = "OPEN"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 11
openButton.Font = Enum.Font.GothamBold
openButton.BorderSizePixel = 0
openButton.Active = true
openButton.Draggable = true
openButton.Visible = false
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(180, 100, 255)
openStroke.Thickness = 2
openStroke.Parent = openButton

--==================================================
-- HIDE / OPEN
--==================================================

hideButton.MouseButton1Click:Connect(function()
	main.Visible = false
	openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
	main.Visible = true
	openButton.Visible = false
end)

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.fromOffset(10, 52)
status.BackgroundTransparency = 1
status.Text = "STATUS: Siap"
status.TextColor3 = Color3.fromRGB(180, 160, 210)
status.TextSize = 10
status.Font = Enum.Font.Gotham
status.Parent = main

--==================================================
-- BUTTON HELPER
--==================================================

local function makeButton(text, y)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -30, 0, 42)
	button.Position = UDim2.fromOffset(15, y)

	button.BackgroundColor3 =
		Color3.fromRGB(55, 30, 90)

	button.TextColor3 =
		Color3.fromRGB(255, 255, 255)

	button.TextSize = 11
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.BorderSizePixel = 0

	button.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = button

	return button
end

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()

	local character = player.Character

	if not character then
		return nil
	end

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil
	end

	return character, root
end

--==================================================
-- FIND VEHICLE
--==================================================

local function getNearestVehicle()

	local character, root = getCharacter()

	if not character then
		return nil
	end

	local nearest = nil
	local nearestDistance = math.huge

	for _, model in ipairs(
		Workspace:GetDescendants()
	) do

		if model:IsA("Model")
			and model ~= character then

			local seat =
				model:FindFirstChildWhichIsA(
					"VehicleSeat",
					true
				)

			if seat then

				local distance =
					(seat.Position - root.Position).Magnitude

				if distance < nearestDistance then

					nearestDistance = distance
					nearest = model

				end
			end
		end
	end

	return nearest
end

--==================================================
-- LIFT VEHICLE
--==================================================

local liftButton = makeButton(
	"🚗 ANGKAT MOBIL TERDEKAT",
	100
)

local liftedVehicle = nil
local originalCFrame = nil

liftButton.MouseButton1Click:Connect(function()

	-- TURUNKAN
	if liftedVehicle
		and liftedVehicle.Parent then

		if originalCFrame then
			liftedVehicle:PivotTo(
				originalCFrame
			)
		end

		liftedVehicle = nil
		originalCFrame = nil

		liftButton.Text =
			"🚗 ANGKAT MOBIL TERDEKAT"

		liftButton.BackgroundColor3 =
			Color3.fromRGB(55, 30, 90)

		status.Text =
			"STATUS: Mobil diturunkan"

		status.TextColor3 =
			Color3.fromRGB(100, 255, 150)

		return
	end

	local vehicle =
		getNearestVehicle()

	if not vehicle then

		status.Text =
			"STATUS: Mobil tidak ditemukan"

		status.TextColor3 =
			Color3.fromRGB(255, 80, 80)

		return
	end

	local character, root =
		getCharacter()

	if not character then
		return
	end

	liftedVehicle = vehicle
	originalCFrame =
		vehicle:GetPivot()

	vehicle:PivotTo(
		root.CFrame
		* CFrame.new(0, 10, -4)
	)

	liftButton.Text =
		"⬇️ TURUNKAN MOBIL"

	liftButton.BackgroundColor3 =
		Color3.fromRGB(30, 150, 80)

	status.Text =
		"STATUS: Mobil berhasil diangkat"

	status.TextColor3 =
		Color3.fromRGB(100, 255, 150)
end)

--==================================================
-- TP TO VEHICLE
--==================================================

local tpButton = makeButton(
	"🚙 TP KE MOBIL TERDEKAT",
	150
)

tpButton.MouseButton1Click:Connect(function()

	local character, root =
		getCharacter()

	if not character then
		return
	end

	local vehicle =
		getNearestVehicle()

	if not vehicle then

		status.Text =
			"STATUS: Mobil tidak ditemukan"

		status.TextColor3 =
			Color3.fromRGB(255, 80, 80)

		return
	end

	root.CFrame =
		vehicle:GetPivot()
		* CFrame.new(0, 3, 5)

	status.Text =
		"STATUS: Teleport ke mobil"

	status.TextColor3 =
		Color3.fromRGB(100, 200, 255)
end)

--==================================================
-- FLIP VEHICLE
--==================================================

local flipButton = makeButton(
	"🔄 FLIP MOBIL TERDEKAT",
	200
)

flipButton.MouseButton1Click:Connect(function()

	local vehicle =
		getNearestVehicle()

	if not vehicle then

		status.Text =
			"STATUS: Mobil tidak ditemukan"

		status.TextColor3 =
			Color3.fromRGB(255, 80, 80)

		return
	end

	local cf =
		vehicle:GetPivot()

	vehicle:PivotTo(
		cf * CFrame.Angles(0, 0, math.pi)
	)

	status.Text =
		"STATUS: Mobil berhasil di-flip"

	status.TextColor3 =
		Color3.fromRGB(255, 180, 80)
end)

--==================================================
-- CLOSE
--==================================================

local closeButton = makeButton(
	"✕ TUTUP MENU",
	250
)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
