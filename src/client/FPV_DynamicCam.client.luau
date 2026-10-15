-- FPV DynamicCam, migrated from the supplied Studio model and kept under Rojo.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Settings = require(script.Parent.FPV_DynamicCamSettings)
local player = Players.LocalPlayer

local currentVelocity = 0
local drift = 0
local accumulator = 0
local humanoid: Humanoid?
local root: BasePart?
local baseFov = 70

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function getBlur(): BlurEffect
	local blur = Lighting:FindFirstChild("FPVDynamicCamBlur") :: BlurEffect?
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "FPVDynamicCamBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end
	return blur
end

local blur = getBlur()

local function setCharacter(character: Model)
	humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	root = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	currentVelocity = 0
	drift = 0
end

local function update(dt: number)
	accumulator += dt
	if accumulator < 1 / Settings.Rate then
		return
	end
	accumulator -= 1 / Settings.Rate
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local velocity = root.AssemblyLinearVelocity.Magnitude
	currentVelocity = lerp(currentVelocity, velocity, Settings.BaseNumLerp)
	local mouseDelta = UserInputService:GetMouseDelta()
	drift = lerp(drift, math.clamp(mouseDelta.X, Settings.DriftMin, Settings.DriftMax), math.clamp(Settings.BaseMult * dt, 0, 1))

	local clock = os.clock()
	local bob = math.sin(clock * Settings.BaseFreq) * Settings.SetFreq * currentVelocity / Settings.BaseMult
	local roll = math.rad(math.sin(clock * Settings.BaseRot) * Settings.SetRot * currentVelocity / Settings.BaseMult + drift)
	camera.FieldOfView = baseFov + math.sqrt(currentVelocity)
	blur.Size = math.clamp(math.abs(drift * Settings.BlurMult), 0, Settings.MaxBlur)
	camera.CFrame *= CFrame.new(0, bob, 0) * CFrame.Angles(0, 0, roll)

	-- A tiny camera offset is safer and less disorienting than applying an
	-- absolute CFrame to the humanoid every frame.
	local swayX = math.cos(clock * Settings.BaseSway) * Settings.SetSway
	local swayY = math.sin(clock * Settings.BaseSway) * Settings.SetSway
	humanoid.CameraOffset = Vector3.new(swayX, swayY, -0.08)
end

player.CameraMode = Enum.CameraMode.LockFirstPerson
player.CameraMinZoomDistance = 0.5
player.CameraMaxZoomDistance = 128
UserInputService.MouseIconEnabled = false
if workspace.CurrentCamera then
	baseFov = workspace.CurrentCamera.FieldOfView
end
if player.Character then
	setCharacter(player.Character)
end
player.CharacterAdded:Connect(setCharacter)
RunService:BindToRenderStep("FPVDynamicCam", Enum.RenderPriority.Camera.Value + 1, update)
