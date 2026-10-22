--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local BLUR = VisualConfig.Blur
local MAX_FRAME_SECONDS = 0.1
local SNAP_BELOW = 0.05

local ceiling = VisualConfig.Profiles.High.blurMax
local size = 0
local previousLook: Vector3? = nil

local CameraMotionBlur = {}

function CameraMotionBlur.setCeiling(value: number)
	ceiling = math.max(value, 0)
end

function CameraMotionBlur.start()
	local blur = Instance.new("BlurEffect")
	blur.Name = "MotionBlur"
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting

	RunService:BindToRenderStep(
		"ChildhoodMotionBlur",
		Enum.RenderPriority.Camera.Value + 1,
		function(dt: number)
			local camera = workspace.CurrentCamera
			if not camera then
				return
			end
			local look = camera.CFrame.LookVector
			local last = previousLook
			previousLook = look
			if last == nil or dt <= 0 or dt > MAX_FRAME_SECONDS then
				return
			end

			local speed = last:Angle(look) / dt
			if speed > BLUR.cutSpeed then
				return
			end

			local intensity =
				math.clamp((speed - BLUR.deadzone) / (BLUR.fullAt - BLUR.deadzone), 0, 1)
			local target = ceiling * intensity
			local seconds = if target > size then BLUR.riseSeconds else BLUR.fallSeconds
			size += (target - size) * (1 - math.exp(-dt / seconds))
			if target < SNAP_BELOW and size < SNAP_BELOW then
				size = 0
			end

			blur.Size = size
			blur.Enabled = size > 0
		end
	)
end

return CameraMotionBlur
