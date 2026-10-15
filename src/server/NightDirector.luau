-- Night 1 pacing: three successful orders closes the shift.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)

local NightDirector = {}
local finished = false
local completedOrders = 0
local summaryRemote: RemoteEvent

function NightDirector.init()
	Remotes.ensureServerEvents({ "NightSummary" })
	summaryRemote = ReplicatedStorage.Remotes.NightSummary
end

function NightDirector.completeOrder(): boolean
	if finished then
		return true
	end
	completedOrders += 1
	if completedOrders < 3 then
		return false
	end
	finished = true
	summaryRemote:FireAllClients({
		night = 1,
		completedOrders = completedOrders,
		message = "CAIXA FECHADO. A fita continua rodando.",
	})
	return true
end

return NightDirector
