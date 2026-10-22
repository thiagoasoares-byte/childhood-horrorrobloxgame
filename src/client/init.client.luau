--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)
local AccessibilitySettings = require(script.AccessibilitySettings)
local CameraMotionBlur = require(script.CameraMotionBlur)
local ContentNotice = require(script.ContentNotice)
local FearVisualController = require(script.FearVisualController)
local FirstPersonLock = require(script.FirstPersonLock)
local QualityProfile = require(script.QualityProfile)
local VhsOverlay = require(script.VhsOverlay)

local function applyEffects()
	local settings = AccessibilitySettings.get()
	local profile = QualityProfile.get()

	local blurFactor = if settings.blur == "Off"
		then 0
		elseif settings.blur == "Reduced" then VisualConfig.Blur.reducedFactor
		else 1
	CameraMotionBlur.setCeiling(profile.blurMax * blurFactor)

	VhsOverlay.setOptions({
		frame = settings.frame,
		frameAnimated = profile.frameAnimated and not settings.reduceMotion,
		scanlines = settings.scanlines,
		scanlineSpacing = profile.scanlineSpacing,
		vignette = settings.vignette,
		colorGrade = settings.colorGrade,
		brightness = settings.brightness,
	})
end

AccessibilitySettings.onChanged(function(settings)
	QualityProfile.setPreference(settings.quality)
	applyEffects()
end)
QualityProfile.onChanged(applyEffects)

AccessibilitySettings.start()
ContentNotice.start(AccessibilitySettings.open)
FirstPersonLock.start()
CameraMotionBlur.start()
VhsOverlay.start()
FearVisualController.start()
QualityProfile.start()
applyEffects()
