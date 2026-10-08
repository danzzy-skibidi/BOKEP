--// DANZZY RUSUH v3

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--==================================================
-- STATE
--==================================================

local State = {
	Noclip = false,
	InfiniteJump = false,
	ESP = false,
	VehicleESP = false,
	FullBright = false,
	LiftedVehicle = nil,
	OldVehicleCF = nil,
}

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "DanzzyRusuh"
GUI.ResetOnSpawn = false
GUI.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(310, 530)
Main.Position = UDim2.new(.5, -155, .5, -265)
Main.BackgroundColor3 = Color3.fromRGB(13, 9, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = GUI

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(0, 14)
MC.Parent = Main

local MS = Instance.new("UIStroke")
MS.Color = Color3.fromRGB(150, 70, 255)
MS.Thickness = 2
MS.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(28, 16, 48)
Header.BorderSizePixel = 0
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DANZZY RUSUH"
Title.TextColor3 = Color3.fromRGB(235, 215, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Hide = Instance.new("TextButton")
Hide.Size = UDim2.fromOffset(55, 28)
Hide.Position = UDim2.new(1, -65, 0, 10)
Hide.Text = "HIDE"
Hide.TextSize = 10
Hide.Font = Enum.Font.GothamBold
Hide.TextColor3 = Color3.new(1,1,1)
Hide.BackgroundColor3 = Color3.fromRGB(75, 40, 115)
Hide.BorderSizePixel = 0
Hide.Parent = Header

Instance.new("UICorner", Hide).CornerRadius = UDim.new(0,6)

--==================================================
-- OPEN BUTTON
--==================================================

local Open = Instance.new("TextButton")
Open.Size = UDim2.fromOffset(68,68)
Open.Position = UDim2.new(.03,0,.5,0)
Open.Text = "OPEN"
Open.TextSize = 11
Open.Font = Enum.Font.GothamBold
Open.TextColor3 = Color3.new(1,1,1)
Open.BackgroundColor3 = Color3.fromRGB(100,45,190)
Open.BorderSizePixel = 0
Open.Active = true
Open.Draggable = true
Open.Visible = false
Open.Parent = GUI

Instance.new("UICorner", Open).CornerRadius = UDim.new(1,0)

Hide.MouseButton1Click:Connect(function()
	Main.Visible = false
	Open.Visible = true
end)

Open.MouseButton1Click:Connect(function()
	Main.Visible = true
	Open.Visible = false
end)

--==================================================
-- SCROLL
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Position = UDim2.fromOffset(5,53)
Scroll.Size = UDim2.new(1,-10,1,-58)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.fromOffset(0,900)
Scroll.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,-20,0,30)
Status.Position = UDim2.fromOffset(10,5)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: Ready"
Status.TextColor3 = Color3.fromRGB(180,160,210)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10
Status.Parent = Scroll

local function setStatus(text)
	Status.Text = "STATUS: "..text
end

--==================================================
-- BUTTON
--==================================================

local function Btn(text,y)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-20,0,40)
	b.Position = UDim2.fromOffset(10,y)
	b.BackgroundColor3 = Color3.fromRGB(55,30,90)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextSize = 11
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = Scroll

	Instance.new("UICorner",b).CornerRadius = UDim.new(0,7)

	return b
end

local function Box(placeholder,y)

	local b = Instance.new("TextBox")
	b.Size = UDim2.new(1,-20,0,40)
	b.Position = UDim2.fromOffset(10,y)
	b.BackgroundColor3 = Color3.fromRGB(30,20,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.PlaceholderColor3 = Color3.fromRGB(150,140,160)
	b.PlaceholderText = placeholder
	b.TextSize = 11
	b.Font = Enum.Font.Gotham
	b.ClearTextOnFocus = false
	b.Parent = Scroll

	Instance.new("UICorner",b).CornerRadius = UDim.new(0,7)

	return b
end

--==================================================
-- CHARACTER
--==================================================

local function getChar()

	local char = LP.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	return char,hum,root
end

--==================================================
-- WALKSPEED
--==================================================

local SpeedBox = Box("Ketik WalkSpeed...",45)

local SpeedBtn = Btn("🏃 SET WALKSPEED",90)

SpeedBtn.MouseButton1Click:Connect(function()

	local value = tonumber(SpeedBox.Text)
	local _,hum = getChar()

	if value and hum then
		hum.WalkSpeed = value
		setStatus("WalkSpeed = "..value)
	else
		setStatus("Masukkan angka yang valid")
	end
end)

local ResetSpeed = Btn("↩ RESET WALKSPEED",135)

ResetSpeed.MouseButton1Click:Connect(function()

	local _,hum = getChar()

	if hum then
		hum.WalkSpeed = 16
		SpeedBox.Text = "16"
		setStatus("WalkSpeed kembali 16")
	end
end)

--==================================================
-- JUMP POWER
--==================================================

local JumpBox = Box("Ketik JumpPower...",185)

local JumpBtn = Btn("🦘 SET JUMPPOWER",230)

JumpBtn.MouseButton1Click:Connect(function()

	local value = tonumber(JumpBox.Text)
	local _,hum = getChar()

	if value and hum then
		hum.UseJumpPower = true
		hum.JumpPower = value
		setStatus("JumpPower = "..value)
	else
		setStatus("Masukkan angka yang valid")
	end
end)

--==================================================
-- INFINITE JUMP
--==================================================

local IJ = Btn("♾ INFINITE JUMP: OFF",275)

IJ.MouseButton1Click:Connect(function()

	State.InfiniteJump = not State.InfiniteJump

	IJ.Text =
		State.InfiniteJump
		and "♾ INFINITE JUMP: ON"
		or "♾ INFINITE JUMP: OFF"

	setStatus(State.InfiniteJump and "Infinite Jump ON" or "Infinite Jump OFF")
end)

UIS.JumpRequest:Connect(function()

	if State.InfiniteJump then

		local _,hum = getChar()

		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--==================================================
-- NOCLIP
--==================================================

local NC = Btn("👻 NOCLIP: OFF",320)

NC.MouseButton1Click:Connect(function()

	State.Noclip = not State.Noclip

	NC.Text =
		State.Noclip
		and "👻 NOCLIP: ON"
		or "👻 NOCLIP: OFF"

	setStatus(State.Noclip and "Noclip ON" or "Noclip OFF")
end)

RunService.Stepped:Connect(function()

	if not State.Noclip then return end

	local char = LP.Character

	if char then

		for _,v in ipairs(char:GetDescendants()) do

			if v:IsA("BasePart") then
				v.CanCollide = false
			end

		end
	end
end)

--==================================================
-- FULLBRIGHT
--==================================================

local FB = Btn("☀ FULLBRIGHT: OFF",365)

FB.MouseButton1Click:Connect(function()

	State.FullBright = not State.FullBright

	if State.FullBright then

		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false

	else

		Lighting.Brightness = 2
		Lighting.FogEnd = 1000
		Lighting.GlobalShadows = true
	end

	FB.Text =
		State.FullBright
		and "☀ FULLBRIGHT: ON"
		or "☀ FULLBRIGHT: OFF"

	setStatus(State.FullBright and "FullBright ON" or "FullBright OFF")
end)

--==================================================
-- RESET CHARACTER
--==================================================

local Reset = Btn("🔄 RESET CHARACTER",410)

Reset.MouseButton1Click:Connect(function()

	local _,hum = getChar()

	if hum then
		hum.Health = 0
		setStatus("Character reset")
	end
end)

--==================================================
-- VEHICLE FINDER
--==================================================

local function nearestVehicle()

	local char,_,root = getChar()

	if not root then return end

	local nearest
	local dist = math.huge

	for _,model in ipairs(Workspace:GetDescendants()) do

		if model:IsA("Model") and model ~= char then

			local seat =
				model:FindFirstChildWhichIsA(
					"VehicleSeat",
					true
				)

			if seat then

				local d =
					(seat.Position-root.Position).Magnitude

				if d < dist then
					dist = d
					nearest = model
				end
			end
		end
	end

	return nearest
end

--==================================================
-- TP VEHICLE
--==================================================

local TP = Btn("🚙 TP KE MOBIL TERDEKAT",455)

TP.MouseButton1Click:Connect(function()

	local _,_,root = getChar()
	local vehicle = nearestVehicle()

	if root and vehicle then

		root.CFrame =
			vehicle:GetPivot()
			*CFrame.new(0,3,5)

		setStatus("Teleport ke kendaraan")
	else
		setStatus("Kendaraan tidak ditemukan")
	end
end)

--==================================================
-- FLIP
--==================================================

local Flip = Btn("🔄 FLIP MOBIL",500)

Flip.MouseButton1Click:Connect(function()

	local vehicle = nearestVehicle()

	if vehicle then

		local cf = vehicle:GetPivot()

		vehicle:PivotTo(
			cf*CFrame.Angles(0,0,math.pi)
		)

		setStatus("Mobil di-flip")
	else
		setStatus("Kendaraan tidak ditemukan")
	end
end)

--==================================================
-- LIFT 300 STUDS
--==================================================

local Lift = Btn("🚗 ANGKAT MOBIL 300 STUDS",545)

Lift.MouseButton1Click:Connect(function()

	local vehicle = nearestVehicle()

	if not vehicle then
		setStatus("Kendaraan tidak ditemukan")
		return
	end

	if State.LiftedVehicle == vehicle then

		if State.OldVehicleCF then
			vehicle:PivotTo(State.OldVehicleCF)
		end

		State.LiftedVehicle = nil
		State.OldVehicleCF = nil

		Lift.Text = "🚗 ANGKAT MOBIL 300 STUDS"

		setStatus("Mobil diturunkan")

	else

		State.LiftedVehicle = vehicle
		State.OldVehicleCF = vehicle:GetPivot()

		vehicle:PivotTo(
			vehicle:GetPivot()
			*CFrame.new(0,300,0)
		)

		Lift.Text = "⬇ TURUNKAN MOBIL"

		setStatus("Mobil naik 300 studs")
	end
end)

--==================================================
-- VEHICLE RESET
--==================================================

local VR = Btn("↩ RESET POSISI MOBIL",590)

VR.MouseButton1Click:Connect(function()

	if State.LiftedVehicle
		and State.OldVehicleCF then

		State.LiftedVehicle:PivotTo(
			State.OldVehicleCF
		)

		State.LiftedVehicle = nil
		State.OldVehicleCF = nil

		Lift.Text = "🚗 ANGKAT MOBIL 300 STUDS"

		setStatus("Posisi mobil direset")
	else
		setStatus("Tidak ada mobil yang sedang diangkat")
	end
end)

--==================================================
-- PLAYER HIGHLIGHT
--==================================================

local ESP = Btn("👀 PLAYER HIGHLIGHT: OFF",635)

local function clearESP()

	for _,p in ipairs(Players:GetPlayers()) do

		if p.Character then

			local h =
				p.Character:FindFirstChild("DanzzyHighlight")

			if h then
				h:Destroy()
			end
		end
	end
end

local function applyESP()

	for _,p in ipairs(Players:GetPlayers()) do

		if p ~= LP and p.Character then

			if not p.Character:FindFirstChild("DanzzyHighlight") then

				local h = Instance.new("Highlight")
				h.Name = "DanzzyHighlight"
				h.FillTransparency = .65
				h.OutlineTransparency = 0
				h.Parent = p.Character

			end
		end
	end
end

ESP.MouseButton1Click:Connect(function()

	State.ESP = not State.ESP

	if State.ESP then
		applyESP()
	else
		clearESP()
	end

	ESP.Text =
		State.ESP
		and "👀 PLAYER HIGHLIGHT: ON"
		or "👀 PLAYER HIGHLIGHT: OFF"

	setStatus(State.ESP and "Player Highlight ON" or "Player Highlight OFF")
end)

Players.PlayerAdded:Connect(function(p)

	p.CharacterAdded:Connect(function()

		task.wait(1)

		if State.ESP then
			applyESP()
		end
	end)
end)

--==================================================
-- SPAWN TELEPORT
--==================================================

local SpawnTP = Btn("📍 TP KE SPAWN",680)

SpawnTP.MouseButton1Click:Connect(function()

	local _,_,root = getChar()

	if not root then return end

	local spawn

	for _,v in ipairs(Workspace:GetDescendants()) do

		if v:IsA("SpawnLocation") then
			spawn = v
			break
		end
	end

	if spawn then

		root.CFrame =
			spawn.CFrame
			*CFrame.new(0,4,0)

		setStatus("Teleport ke Spawn")
	else
		setStatus("Spawn tidak ditemukan")
	end
end)

--==================================================
-- SIT / STAND
--==================================================

local Sit = Btn("🪑 SIT / STAND",725)

Sit.MouseButton1Click:Connect(function()

	local _,hum = getChar()

	if hum then
		hum.Sit = not hum.Sit
		setStatus(hum.Sit and "Duduk" or "Berdiri")
	end
end)

--==================================================
-- REFRESH
--==================================================

local Refresh = Btn("🔄 REFRESH MENU",770)

Refresh.MouseButton1Click:Connect(function()

	setStatus("Menu siap digunakan")
end)

--==================================================
-- CLOSE
--==================================================

local Close = Btn("✕ TUTUP",815)

Close.MouseButton1Click:Connect(function()
	GUI:Destroy()
end)

--==================================================
-- END
--==================================================

setStatus("Ready")
