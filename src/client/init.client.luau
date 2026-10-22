--!strict
local CameraMotionBlur = require(script.CameraMotionBlur)
local FearVisualController = require(script.FearVisualController)
local FirstPersonLock = require(script.FirstPersonLock)

FirstPersonLock.start()
CameraMotionBlur.start()
FearVisualController.start()
