--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local levels: { [Player]: number } = {}

local FearService = {}

function FearService.get(player: Player): number
	return levels[player] or 0
end

function FearService.set(player: Player, level: number)
	local current = levels[player]
	if current == nil then
		return
	end
	local clamped = math.clamp(level, VisualConfig.FEAR_MIN, VisualConfig.FEAR_MAX)
	if clamped ~= current then
		levels[player] = clamped
		Remotes.FearChanged:FireClient(player, clamped)
	end
end

function FearService.add(player: Player, delta: number)
	FearService.set(player, FearService.get(player) + delta)
end

-- The client starts at 0 and can miss a value sent before its listener connects, so it asks for the current one.
function FearService.sync(player: Player)
	if levels[player] then
		Remotes.FearChanged:FireClient(player, levels[player])
	end
end

function FearService.start()
	Players.PlayerAdded:Connect(function(player)
		levels[player] = 0
	end)
	Players.PlayerRemoving:Connect(function(player)
		levels[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		levels[player] = 0
	end
end

return FearService
