--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FearService = require(script.Parent.FearService)
local OrderService = require(script.Parent.OrderService)
local PhaseService = require(script.Parent.PhaseService)
local PreferenceStore = require(script.Parent.PreferenceStore)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local MIN_INTERVAL = 0.25

local settings: { [Player]: VisualConfig.Settings } = {}
local lastAt: { [Player]: number } = {}
local greeted: { [Player]: boolean } = {}

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
		if greeted[player] then
			settings[player] = clean
			PreferenceStore.set(player, { access = clean })
			return
		end
		-- The first valid message is the client's hello with its defaults: a saved record replaces them,
		-- and it means the client is listening, so the current state can be delivered.
		greeted[player] = true
		local record = PreferenceStore.await(player)
		if player.Parent == nil then
			return
		end
		settings[player] = if record then record.access else clean
		if record then
			Remotes.PrefsLoaded:FireClient(player, record.access, record.consent.optOut)
		end
		FearService.sync(player)
		PhaseService.sync(player)
		OrderService.sync(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		settings[player] = nil
		lastAt[player] = nil
		greeted[player] = nil
	end)
end

return SettingsService
