--!strict
local FearService = require(script.FearService)
local NightDirector = require(script.NightDirector)
local OrderService = require(script.OrderService)
local PizzaStation = require(script.PizzaStation)
local PizzeriaBuilder = require(script.PizzeriaBuilder)
local SettingsService = require(script.SettingsService)

FearService.start()
SettingsService.start()
local map = PizzeriaBuilder.build()
PizzaStation.start(map, PizzeriaBuilder.KITCHEN_ORIGIN)
OrderService.start()
NightDirector.start()
