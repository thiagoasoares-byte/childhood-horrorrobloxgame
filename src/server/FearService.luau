local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local VisualConfig = require(Shared.VisualConfig)

local FearService = {}

local fearByPlayer: { [Player]: number } = {}
local fearChanged: RemoteEvent

function FearService.init()
	Remotes.ensureServerEvents({ "FearChanged" })
	fearChanged = ReplicatedStorage.Remotes.FearChanged

	Players.PlayerAdded:Connect(function(player)
		FearService.setFear(player, VisualConfig.FEAR_DEFAULT)
	end)

	for _, player in Players:GetPlayers() do
		FearService.setFear(player, VisualConfig.FEAR_DEFAULT)
	end
end

function FearService.getFear(player: Player): number
	return fearByPlayer[player] or VisualConfig.FEAR_DEFAULT
end

function FearService.setFear(player: Player, value: number)
	local clamped = math.clamp(value, 0, 100)
	fearByPlayer[player] = clamped
	fearChanged:FireClient(player, clamped)
end

function FearService.addFear(player: Player, delta: number)
	FearService.setFear(player, FearService.getFear(player) + delta)
end

Players.PlayerRemoving:Connect(function(player)
	fearByPlayer[player] = nil
end)

return FearService
