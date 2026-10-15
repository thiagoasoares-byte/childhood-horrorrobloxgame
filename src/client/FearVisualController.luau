local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local VisualConfig = require(Shared.VisualConfig)

local VhsOverlay = require(script.Parent.VhsOverlay)

local FearVisualController = {}

function FearVisualController.start()
	local vhs = VhsOverlay.create()

	local color = Lighting:FindFirstChild("SaudadeColorGrade") :: ColorCorrectionEffect?
	if not color then
		color = Instance.new("ColorCorrectionEffect")
		color.Name = "SaudadeColorGrade"
		color.Parent = Lighting
	end

	local targetFear = VisualConfig.FEAR_DEFAULT
	local displayFear = targetFear
	local lastGlitch = os.clock()

	local fearChanged = Remotes.waitForEvent("FearChanged")
	fearChanged.OnClientEvent:Connect(function(fear: number)
		targetFear = math.clamp(fear, 0, 100)
	end)

	RunService.RenderStepped:Connect(function(dt: number)
		local alpha = math.clamp(dt / VisualConfig.FEAR_LERP_SECONDS, 0, 1)
		displayFear = VisualConfig.lerp(displayFear, targetFear, alpha)

		local f = VisualConfig.fearNorm(displayFear)
		vhs.setFearVisual(displayFear)

		color.Saturation = VisualConfig.VHS.saturationBase + f * VisualConfig.VHS.saturationFear
		color.Contrast = 0.05 + f * 0.1
		color.TintColor = Color3.fromRGB(255, 240, 210)

		vhs.tickNoise(os.clock())

		local glitchEvery = VisualConfig.lerp(
			VisualConfig.VHS.glitchIntervalMax,
			VisualConfig.VHS.glitchIntervalMin,
			f
		)
		local now = os.clock()
		if now - lastGlitch > glitchEvery then
			vhs.triggerGlitch()
			lastGlitch = now
		end
	end)
end

return FearVisualController
