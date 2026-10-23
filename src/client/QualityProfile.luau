--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local ORDER: { VisualConfig.QualityName } = { "high", "medium", "low" }
local WINDOW = 4 -- seconds per FPS measurement
local MIN_FPS = 28

local mode: VisualConfig.QualityMode = "auto"
local autoIndex = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	then 2
	else 1
local listeners: { () -> () } = {}

local function currentName(): VisualConfig.QualityName
	return if mode == "auto" then ORDER[autoIndex] else mode
end

local shown = currentName()

local function refresh()
	local name = currentName()
	if name ~= shown then
		shown = name
		for _, listener in listeners do
			listener()
		end
	end
end

local QualityProfile = {}

function QualityProfile.get(): VisualConfig.QualityProfile
	return VisualConfig.QUALITY[shown]
end

function QualityProfile.onChanged(listener: () -> ())
	table.insert(listeners, listener)
end

function QualityProfile.setMode(value: VisualConfig.QualityMode)
	mode = value
	refresh()
end

-- Automatic mode only steps down, so a slow moment never makes the profile flap back and forth.
function QualityProfile.start()
	local frames = 0
	local elapsed = 0
	local warmingUp = true
	RunService.RenderStepped:Connect(function(dt)
		frames += 1
		elapsed += dt
		if elapsed < WINDOW then
			return
		end
		local fps = frames / elapsed
		frames = 0
		elapsed = 0
		if warmingUp then
			warmingUp = false
		elseif mode == "auto" and fps < MIN_FPS and autoIndex < #ORDER then
			autoIndex += 1
			refresh()
		end
	end)
end

return QualityProfile
