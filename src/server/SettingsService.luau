--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Settings = require(ReplicatedStorage.Shared.Settings)

local WINDOW_SECONDS = 2
local MAX_PER_WINDOW = 5

local stored: { [Player]: Settings.Settings } = {}
local windows: { [Player]: { start: number, count: number } } = {}

local SettingsService = {}

function SettingsService.get(player: Player): Settings.Settings
	return stored[player] or Settings.defaults()
end

local function allowed(player: Player): boolean
	local now = os.clock()
	local window = windows[player]
	if window == nil or now - window.start >= WINDOW_SECONDS then
		windows[player] = { start = now, count = 1 }
		return true
	end
	window.count += 1
	return window.count <= MAX_PER_WINDOW
end

function SettingsService.start()
	Remotes.SettingsChanged.OnServerEvent:Connect(function(player, payload)
		if not allowed(player) then
			return
		end
		local clean = Settings.sanitize(payload)
		if clean then
			stored[player] = clean
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		stored[player] = nil
		windows[player] = nil
	end)
end

return SettingsService
