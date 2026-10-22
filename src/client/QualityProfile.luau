--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local AUTO = VisualConfig.AutoQuality
local ORDER: { VisualConfig.QualityName } = { "High", "Medium", "Low" }

local preference: Settings.Quality = "Auto"
local autoIndex = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	then 2
	else 1
local listeners: { (VisualConfig.QualityName) -> () } = {}
local warmup = 0
local frames = 0
local seconds = 0

local QualityProfile = {}

function QualityProfile.getName(): VisualConfig.QualityName
	if preference ~= "Auto" then
		return preference
	end
	return ORDER[autoIndex]
end

function QualityProfile.get(): VisualConfig.Profile
	return VisualConfig.Profiles[QualityProfile.getName()]
end

function QualityProfile.onChanged(listener: (VisualConfig.QualityName) -> ())
	table.insert(listeners, listener)
end

local function notify()
	local name = QualityProfile.getName()
	for _, listener in listeners do
		listener(name)
	end
end

function QualityProfile.setPreference(value: Settings.Quality)
	if value == preference then
		return
	end
	preference = value
	warmup, frames, seconds = 0, 0, 0
	notify()
end

-- only steps down: stepping back up would make the profile oscillate
function QualityProfile.start()
	RunService.Heartbeat:Connect(function(dt)
		if preference ~= "Auto" or autoIndex >= #ORDER then
			return
		end
		warmup += dt
		if warmup < AUTO.warmupSeconds then
			return
		end
		frames += 1
		seconds += dt
		if seconds < AUTO.windowSeconds then
			return
		end
		local fps = frames / seconds
		frames, seconds = 0, 0
		if fps < AUTO.downgradeBelowFps then
			autoIndex += 1
			notify()
		end
	end)
end

return QualityProfile
