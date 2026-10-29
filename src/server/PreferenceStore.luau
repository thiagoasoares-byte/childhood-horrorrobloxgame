--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

-- Single owner of persistence: DataStore "PlayerPrefs_v1", one key per player, versioned.
-- It never stores appearance data or the UserId of anyone else.
local STORE_NAME = "PlayerPrefs_v1"
local VERSION = 1
local LOAD_ATTEMPTS = 3
local SAVE_DELAY = 10
local AWAIT_TIMEOUT = 15

export type Record = {
	v: number,
	consent: { optOut: boolean },
	access: VisualConfig.Settings,
}

type Patch = { optOut: boolean?, access: VisualConfig.Settings? }

local store = DataStoreService:GetDataStore(STORE_NAME)

local loaded: { [Player]: Record? } = {}
local ready: { [Player]: boolean } = {}
local blocked: { [Player]: boolean } = {} -- the read failed, so a save could erase real data
local pending: { [Player]: Patch } = {}
local saveQueued: { [Player]: boolean } = {}
local inFlight = 0

local function keyFor(player: Player): string
	return "u_" .. player.UserId
end

-- Unknown version or any invalid field means "no record", so the player starts from defaults.
local function readRecord(raw: any): Record?
	if type(raw) ~= "table" or raw.v ~= VERSION then
		return nil
	end
	local consent = raw.consent
	if type(consent) ~= "table" or type(consent.optOut) ~= "boolean" then
		return nil
	end
	local access = VisualConfig.sanitizeSettings(raw.access)
	if not access then
		return nil
	end
	return { v = VERSION, consent = { optOut = consent.optOut }, access = access }
end

local function load(player: Player)
	for attempt = 1, LOAD_ATTEMPTS do
		local ok, raw = pcall(function()
			return store:GetAsync(keyFor(player))
		end)
		if ok then
			loaded[player] = readRecord(raw)
			ready[player] = true
			return
		end
		if attempt < LOAD_ATTEMPTS then
			task.wait(2 ^ attempt)
		end
	end
	warn("[PreferenceStore] could not read preferences; this session will not save them")
	blocked[player] = true
	ready[player] = true
end

local function save(player: Player)
	local patch = pending[player]
	if not patch or blocked[player] then
		return
	end
	pending[player] = nil
	local base = loaded[player]
	local record: Record = {
		v = VERSION,
		consent = {
			optOut = if patch.optOut ~= nil
				then patch.optOut
				else (base and base.consent.optOut or false),
		},
		access = patch.access or (base and base.access) or VisualConfig.DEFAULT_SETTINGS,
	}
	loaded[player] = record
	inFlight += 1
	local ok = pcall(function()
		store:SetAsync(keyFor(player), record)
	end)
	inFlight -= 1
	if not ok then
		warn("[PreferenceStore] save failed")
	end
end

local PreferenceStore = {}

-- Waits for the read to finish. Returns nil when there is no valid saved record.
function PreferenceStore.await(player: Player): Record?
	local deadline = os.clock() + AWAIT_TIMEOUT
	while not ready[player] and player.Parent ~= nil and os.clock() < deadline do
		task.wait(0.1)
	end
	return loaded[player]
end

function PreferenceStore.set(player: Player, patch: Patch)
	local merged = pending[player] or {}
	if patch.optOut ~= nil then
		merged.optOut = patch.optOut
	end
	if patch.access then
		merged.access = patch.access
	end
	pending[player] = merged
	if not saveQueued[player] then
		saveQueued[player] = true
		task.delay(SAVE_DELAY, function()
			saveQueued[player] = nil
			save(player)
		end)
	end
end

function PreferenceStore.start()
	Players.PlayerAdded:Connect(function(player)
		task.spawn(load, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		save(player)
		loaded[player] = nil
		ready[player] = nil
		blocked[player] = nil
		pending[player] = nil
		saveQueued[player] = nil
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			save(player)
		end
		while inFlight > 0 do
			task.wait(0.1)
		end
	end)
end

return PreferenceStore
