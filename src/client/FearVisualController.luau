--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)
local VhsOverlay = require(script.Parent.VhsOverlay)

local FearVisualController = {}

function FearVisualController.start()
	local current = 0
	local from = 0
	local target = 0
	local elapsed = VisualConfig.FEAR_SMOOTH_SECONDS

	VhsOverlay.setBand(VisualConfig.sampleBand(current))

	Remotes.FearChanged.OnClientEvent:Connect(function(value: unknown)
		if typeof(value) ~= "number" or value ~= value then
			return
		end
		from = current
		target = math.clamp(value, 0, VisualConfig.FEAR_MAX)
		elapsed = 0
	end)

	RunService.Heartbeat:Connect(function(dt)
		if current == target then
			return
		end
		elapsed += dt
		local t = elapsed / VisualConfig.FEAR_SMOOTH_SECONDS
		current = if t >= 1 then target else from + (target - from) * t
		VhsOverlay.setBand(VisualConfig.sampleBand(current))
	end)
end

return FearVisualController
