-- Schedules private, non-damaging appearances. The server owns all limits;
-- clients only render their assigned entity.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local VisualConfig = require(Shared.VisualConfig)
local FearService = require(script.Parent.FearService)

local EntityAppearanceService = {}

local appearanceRemote: RemoteEvent
local dismissRemote: RemoteEvent
local activeByPlayer: { [Player]: number } = {}
local lastAppearance: { [Player]: number } = {}
local nextId = 0
local running = false

local function activeCount(): number
	local count = 0
	for _ in activeByPlayer do
		count += 1
	end
	return count
end

local function release(player: Player, id: number)
	if activeByPlayer[player] == id then
		activeByPlayer[player] = nil
	end
end

local function canAppear(player: Player, now: number): boolean
	return activeByPlayer[player] == nil
		and now - (lastAppearance[player] or -math.huge) >= VisualConfig.APPEARANCES.cooldownSeconds
end

function EntityAppearanceService.spawnFor(player: Player): boolean
	local now = os.clock()
	if activeCount() >= VisualConfig.APPEARANCES.maxSimultaneous or not canAppear(player, now) then
		return false
	end

	nextId += 1
	local id = nextId
	activeByPlayer[player] = id
	lastAppearance[player] = now
	FearService.addFear(player, VisualConfig.APPEARANCES.fearOnAppear)
	appearanceRemote:FireClient(player, if id % 2 == 0 then "BANZO" else "Antena", id)
	task.delay(VisualConfig.APPEARANCES.durationSeconds, function()
		release(player, id)
	end)
	return true
end

function EntityAppearanceService.init()
	if running then
		return
	end
	running = true
	Remotes.ensureServerEvents({ "EntityAppearance", "EntityDismissed" })
	appearanceRemote = ReplicatedStorage.Remotes.EntityAppearance
	dismissRemote = ReplicatedStorage.Remotes.EntityDismissed

	dismissRemote.OnServerEvent:Connect(function(player: Player, id: number)
		if typeof(id) == "number" then
			release(player, id)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		activeByPlayer[player] = nil
		lastAppearance[player] = nil
	end)

	task.spawn(function()
		-- The first one arrives shortly after joining; subsequent spawns still honour 45 s/player.
		task.wait(10)
		while running do
			for _, player in Players:GetPlayers() do
				if EntityAppearanceService.spawnFor(player) then
					break
				end
			end
			task.wait(8)
		end
	end)
end

return EntityAppearanceService
