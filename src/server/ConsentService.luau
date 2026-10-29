--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PreferenceStore = require(script.Parent.PreferenceStore)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local RATE_LIMIT = 0.25

-- Owner of the player's friend-appearance opt-out. A player who has not answered yet counts as opted out.
local answers: { [Player]: boolean } = {}
local lastChange: { [Player]: number } = {}
local greeted: { [Player]: boolean } = {}
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
		-- The first message is the client's hello with its default, so a saved answer wins over it.
		if not greeted[player] then
			greeted[player] = true
			local record = PreferenceStore.await(player)
			if player.Parent == nil then
				return
			end
			if record then
				optOut = record.consent.optOut
			end
		else
			PreferenceStore.set(player, { optOut = optOut })
		end
		answers[player] = optOut
		changed:Fire(player, optOut)
	end)

	Players.PlayerRemoving:Connect(function(player)
		answers[player] = nil
		lastChange[player] = nil
		greeted[player] = nil
	end)
end

return ConsentService
