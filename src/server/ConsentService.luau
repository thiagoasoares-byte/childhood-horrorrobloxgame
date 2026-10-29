--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RATE_LIMIT = 0.25

-- Owner of the player's friend-appearance opt-out. A player who has not answered yet counts as opted out.
local answers: { [Player]: boolean } = {}
local lastChange: { [Player]: number } = {}
local changed = Instance.new("BindableEvent")

local ConsentService = {}

ConsentService.Changed = changed.Event :: RBXScriptSignal

function ConsentService.allowsFriends(player: Player): boolean
	return answers[player] == false
end

function ConsentService.start()
	Remotes.ConsentChanged.OnServerEvent:Connect(function(player: Player, optOut: any)
		if type(optOut) ~= "boolean" then
			return
		end
		local now = os.clock()
		if now - (lastChange[player] or 0) < RATE_LIMIT then
			return
		end
		lastChange[player] = now
		if answers[player] == optOut then
			return
		end
		answers[player] = optOut
		changed:Fire(player, optOut)
	end)

	Players.PlayerRemoving:Connect(function(player)
		answers[player] = nil
		lastChange[player] = nil
	end)
end

return ConsentService
