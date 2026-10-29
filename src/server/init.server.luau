--!strict
local FearService = require(script.FearService)
local NightDirector = require(script.NightDirector)
local PizzeriaBuilder = require(script.PizzeriaBuilder)
local SettingsService = require(script.SettingsService)

FearService.start()
SettingsService.start()
PizzeriaBuilder.build()
NightDirector.start()
