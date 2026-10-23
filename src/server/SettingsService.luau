--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FearService = require(script.Parent.FearService)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local MIN_INTERVAL = 0.25

local settings: { [Player]: VisualConfig.Settings } = {}
local lastAt: { [Player]: number } = {}

local SettingsService = {}

function SettingsService.get(player: Player): VisualConfig.Settings
	return settings[player] or VisualConfig.DEFAULT_SETTINGS
end

function SettingsService.start()
	Remotes.SettingsChanged.OnServerEvent:Connect(function(player, payload)
		local now = os.clock()
		if now - (lastAt[player] or -math.huge) < MIN_INTERVAL then
			return
		end
		lastAt[player] = now

		local clean = VisualConfig.sanitizeSettings(payload)
		if not clean then
			return
		end
		local isFirst = settings[player] == nil
		settings[player] = clean
		-- The first valid message means the client is listening, so the current fear level can be delivered.
		if isFirst then
			FearService.sync(player)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		settings[player] = nil
		lastAt[player] = nil
	end)
end

return SettingsService
