--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Phase = require(ReplicatedStorage.Shared.Phase)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local state: Phase.State = { night = 1, block = "ida" }

local PhaseService = {}

function PhaseService.get(): Phase.State
	return state
end

function PhaseService.set(night: number, block: Phase.Block)
	state = { night = night, block = block }
	Remotes.PhaseChanged:FireAllClients(night, block)
end

-- A client that joins mid-night has missed earlier broadcasts, so it asks for the current state.
function PhaseService.sync(player: Player)
	Remotes.PhaseChanged:FireClient(player, state.night, state.block)
end

return PhaseService
