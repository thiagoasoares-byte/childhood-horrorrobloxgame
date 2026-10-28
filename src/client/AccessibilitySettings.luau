--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HorrorCamera = require(script.Parent.HorrorCamera)
local QualityProfile = require(script.Parent.QualityProfile)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VhsFilter = require(script.Parent.VhsFilter)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local REDUCED_BLUR = 0.4 -- share of the camera blur kept by the "reduced" mode
local BRIGHTNESS_GAIN = 0.25 -- ColorCorrection brightness added at the maximum setting
local SEND_DELAY = 0.3 -- coalesces rapid changes into one message, under the server rate limit

local settings: VisualConfig.Settings = table.clone(VisualConfig.DEFAULT_SETTINGS)
local sendQueued = false

local function apply()
	local profile = QualityProfile.get()
	VhsFilter.setLayerVisible("frame", settings.vhsFrame)
	VhsFilter.setLayerVisible("scanlines", settings.scanlines)
	VhsFilter.setLayerVisible("vignette", settings.vignette)
	VhsFilter.setQuality(profile)
	VhsFilter.setMotion(not settings.reduceMotion)
	VhsFilter.setGrade(settings.colorGrade, settings.brightness * BRIGHTNESS_GAIN)
	HorrorCamera.setReducedMotion(settings.reduceMotion)
	if settings.blur == "off" then
		HorrorCamera.setBlurScale(0)
	elseif settings.blur == "reduced" then
		HorrorCamera.setBlurScale(REDUCED_BLUR)
	else
		HorrorCamera.setBlurScale(1)
	end
end

local function send()
	sendQueued = false
	Remotes.SettingsChanged:FireServer(settings)
end

local AccessibilitySettings = {}

function AccessibilitySettings.get(): VisualConfig.Settings
	return settings
end

function AccessibilitySettings.set(key: string, value: any)
	local candidate: any = table.clone(settings)
	candidate[key] = value
	local clean = VisualConfig.sanitizeSettings(candidate)
	if not clean then
		return
	end
	if clean.quality ~= settings.quality then
		QualityProfile.setMode(clean.quality)
	end
	settings = clean
	apply()
	if not sendQueued then
		sendQueued = true
		task.delay(SEND_DELAY, send)
	end
end

-- The first message also tells the server this client is ready to receive the current fear level.
function AccessibilitySettings.start()
	QualityProfile.onChanged(apply)
	apply()
	Remotes.SettingsChanged:FireServer(settings)
end

return AccessibilitySettings
