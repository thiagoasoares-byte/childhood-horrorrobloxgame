--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SEND_DELAY = 0.3 -- same coalescing as the settings, under the server rate limit

local optOut = false
local sendQueued = false

local function send()
	sendQueued = false
	Remotes.ConsentChanged:FireServer(optOut)
end

local Consent = {}

function Consent.label(): string
	return `Aparência de amigos: {if optOut then "Desligada" else "Ligada"}`
end

function Consent.toggle()
	optOut = not optOut
	if not sendQueued then
		sendQueued = true
		task.delay(SEND_DELAY, send)
	end
end

function Consent.start()
	send()
end

return Consent
