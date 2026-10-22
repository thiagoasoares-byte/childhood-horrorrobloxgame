--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

-- Provisional tuning, to be adjusted on the P5 reference phone.
local DEADZONE = 1.5 -- rad/s of camera turn that produces no blur
local GAIN = 2 -- blur size per rad/s above the dead zone
local SMOOTHING = 12 -- per second

local cap = VisualConfig.QUALITY.high.blurMax

local CameraMotionBlur = {}

function CameraMotionBlur.setCap(value: number)
	cap = math.max(0, value)
end

function CameraMotionBlur.start()
	local blur = Instance.new("BlurEffect")
	blur.Name = "CameraMotionBlur"
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting

	local lastLook: Vector3? = nil
	local size = 0

	RunService.RenderStepped:Connect(function(dt)
		local camera = Workspace.CurrentCamera
		if not camera or dt <= 0 then
			return
		end
		local look = camera.CFrame.LookVector
		local speed = 0
		if lastLook then
			speed = math.acos(math.clamp(look:Dot(lastLook), -1, 1)) / dt
		end
		lastLook = look

		local target = math.min(cap, math.max(0, speed - DEADZONE) * GAIN)
		size += (target - size) * (1 - math.exp(-SMOOTHING * dt))
		if size < 0.05 then
			size = 0
		end
		blur.Size = size
		blur.Enabled = size > 0
	end)
end

return CameraMotionBlur
