--!strict
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)
local VhsOverlay = require(script.Parent.VhsOverlay)

local SETTLE_TIME = 0.13 -- time constant: about 95% of a change is shown within 0.4 s

local color = Instance.new("ColorCorrectionEffect")
color.Name = "FearColor"
color.Parent = Lighting

local target = 0
local shown = 0
local gradeOn = true

local function apply()
	local sample = VisualConfig.sampleFear(shown)
	color.Saturation = if gradeOn then sample.saturation else 0
	VhsOverlay.setFear(sample)
end
apply()

local FearVisualController = {}

function FearVisualController.setGrade(enabled: boolean, brightness: number)
	gradeOn = enabled
	color.Brightness = brightness
	apply()
end

function FearVisualController.start()
	Remotes.FearChanged.OnClientEvent:Connect(function(level: number)
		target = level
	end)

	RunService.RenderStepped:Connect(function(dt)
		if shown == target then
			return
		end
		shown += (target - shown) * (1 - math.exp(-dt / SETTLE_TIME))
		if math.abs(target - shown) < 0.05 then
			shown = target
		end
		apply()
	end)
end

return FearVisualController
