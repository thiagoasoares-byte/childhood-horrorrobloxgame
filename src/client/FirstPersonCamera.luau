--!strict
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local SENSITIVITY = 0.4 -- degrees per pixel of mouse or touch movement
local MAX_PITCH = math.rad(80)
local LEAN_DIVISOR = 320 -- higher means less roll while turning
local LEAN_MAX = 0.2 -- rad
local LEAN_RECOVERY = 0.9 -- seconds for the roll to settle
local CAMERA_SMOOTHING = 16

local BOB_IDLE_SPEED = 0.2 -- rad/s
local BOB_WALK_SPEED = 11 -- rad/s
local BOB_DISTANCE = 0.2 -- studs
local WALK_THRESHOLD = 9 -- studs/s of horizontal speed

local BASE_FOV = 60
local FOV_KICK = 8
local FOV_MAX_SPEED = 10 -- studs/s
local FOV_SMOOTHING = 3

local EYE_FORWARD = 0.25 -- studs ahead of the head centre so the camera clears the neck

local yaw = 0
local pitch = 0
local roll = 0
local bobPhase = 0
local reducedMotion = false
local snap = true
local freeOwners: { [string]: boolean } = {}

local root: BasePart? = nil
local head: BasePart? = nil

local function isFree(): boolean
	return next(freeOwners) ~= nil or GuiService.MenuIsOpen
end

-- The default camera scripts reset this, so the hide is re-applied whenever it changes.
local function hide(part: BasePart)
	local function apply()
		if part.LocalTransparencyModifier ~= 1 then
			part.LocalTransparencyModifier = 1
		end
	end
	apply()
	part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(apply)
end

-- Only the head and accessories go; the rest of the body stays visible when looking down.
local function conceal(instance: Instance)
	if instance:IsA("BasePart") then
		if instance.Name == "Head" or instance:FindFirstAncestorWhichIsA("Accessory") then
			hide(instance)
		end
	elseif instance:IsA("Decal") and instance.Parent and instance.Parent.Name == "Head" then
		instance.Transparency = 1
	end
end

local function bind(model: Model)
	local newRoot = model:WaitForChild("HumanoidRootPart") :: BasePart
	local newHead = model:WaitForChild("Head") :: BasePart
	local humanoid = model:WaitForChild("Humanoid") :: Humanoid
	humanoid.AutoRotate = false
	for _, descendant in model:GetDescendants() do
		conceal(descendant)
	end
	model.DescendantAdded:Connect(conceal)

	local _, startYaw = newRoot.CFrame:ToOrientation()
	yaw = startYaw
	pitch = 0
	roll = 0
	snap = true
	root = newRoot
	head = newHead
end

local function look(dx: number, dy: number)
	if isFree() then
		return
	end
	yaw -= math.rad(dx * SENSITIVITY)
	pitch = math.clamp(pitch - math.rad(dy * SENSITIVITY), -MAX_PITCH, MAX_PITCH)
	if not reducedMotion then
		roll = math.clamp(roll - dx * SENSITIVITY / LEAN_DIVISOR, -LEAN_MAX, LEAN_MAX)
	end
end

local function updateCursor()
	local free = isFree()
	local behavior = if free then Enum.MouseBehavior.Default else Enum.MouseBehavior.LockCenter
	if UserInputService.MouseBehavior ~= behavior then
		UserInputService.MouseBehavior = behavior
	end
	if UserInputService.MouseIconEnabled ~= free then
		UserInputService.MouseIconEnabled = free
	end
end

local function update(dt: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end
	updateCursor()

	if not (root and head and root.Parent) then
		return
	end

	local velocity = root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

	local amount = dt / LEAN_RECOVERY
	roll = if roll > 0 then math.max(roll - amount, 0) else math.min(roll + amount, 0)

	local bob = 0
	local fov = BASE_FOV
	if not reducedMotion then
		bobPhase += dt * (if speed >= WALK_THRESHOLD then BOB_WALK_SPEED else BOB_IDLE_SPEED)
		bob = math.sin(bobPhase) * BOB_DISTANCE
		fov += math.clamp(speed / FOV_MAX_SPEED, 0, 1) * FOV_KICK
	end
	camera.FieldOfView += (fov - camera.FieldOfView) * math.min(1, dt * FOV_SMOOTHING)

	local facing = CFrame.Angles(0, yaw, 0)
	local eye = head.Position + facing.LookVector * EYE_FORWARD + Vector3.new(0, bob, 0)
	local target = CFrame.new(eye) * facing * CFrame.Angles(pitch, 0, 0) * CFrame.Angles(0, 0, roll)
	if snap then
		camera.CFrame = target
		snap = false
	else
		camera.CFrame = camera.CFrame:Lerp(target, math.min(1, dt * CAMERA_SMOOTHING))
	end

	root.CFrame = CFrame.new(root.Position) * facing
end

local FirstPersonCamera = {}

function FirstPersonCamera.setReducedMotion(enabled: boolean)
	reducedMotion = enabled
end

-- Menus and notices own the cursor while open; the camera ignores look input until all of them release it.
function FirstPersonCamera.setCursorFree(owner: string, free: boolean)
	freeOwners[owner] = if free then true else nil
end

function FirstPersonCamera.start()
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			look(input.Delta.X, input.Delta.Y)
		end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if not processed then
			look(touch.Delta.X, touch.Delta.Y)
		end
	end)
	RunService.RenderStepped:Connect(update)

	player.CharacterAdded:Connect(bind)
	if player.Character then
		task.spawn(bind, player.Character)
	end
end

return FirstPersonCamera
