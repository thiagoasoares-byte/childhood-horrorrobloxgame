--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local WALK_SPEED = 16
local SPRINT_SPEED = 21 -- a light sprint, about a third faster than walking
local MAX = 100
local DRAIN = 20 -- per second while sprinting, so about 5 s from full
local REGEN = 14 -- per second once resting
local REGEN_DELAY = 1
local RECOVER_AT = 30 -- after running dry, sprinting stays locked until this much is back
local INPUT_GAP = 0.1
local MIN_SPEED = 1 -- horizontal studs per second that count as moving

type State = {
	stamina: number,
	wants: boolean,
	exhausted: boolean,
	restSince: number,
	lastInput: number,
	sentValue: number,
	sentExhausted: boolean,
}

local states: { [Player]: State } = {}

local function newState(): State
	return {
		stamina = MAX,
		wants = false,
		exhausted = false,
		restSince = 0,
		lastInput = 0,
		sentValue = MAX,
		sentExhausted = false,
	}
end

local function step(player: Player, state: State, dt: number, now: number)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return
	end

	local velocity = root.AssemblyLinearVelocity
	local moving = Vector3.new(velocity.X, 0, velocity.Z).Magnitude > MIN_SPEED
	local sprinting = state.wants and not state.exhausted and moving

	if sprinting then
		state.stamina = math.max(0, state.stamina - DRAIN * dt)
		state.restSince = now
		if state.stamina == 0 then
			state.exhausted = true
		end
	elseif now - state.restSince >= REGEN_DELAY then
		state.stamina = math.min(MAX, state.stamina + REGEN * dt)
		if state.exhausted and state.stamina >= RECOVER_AT then
			state.exhausted = false
		end
	end

	local speed = if sprinting then SPRINT_SPEED else WALK_SPEED
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end

	local shown = math.floor(state.stamina + 0.5)
	if shown ~= state.sentValue or state.exhausted ~= state.sentExhausted then
		state.sentValue = shown
		state.sentExhausted = state.exhausted
		Remotes.StaminaChanged:FireClient(player, shown, state.exhausted)
	end
end

local StaminaService = {}

function StaminaService.start()
	Players.PlayerAdded:Connect(function(player)
		states[player] = newState()
	end)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		states[player] = newState()
	end

	-- The client only says whether the key is held; speed and stamina are decided here.
	Remotes.SprintInput.OnServerEvent:Connect(function(player: Player, wants: any)
		local state = states[player]
		local now = os.clock()
		if not state or type(wants) ~= "boolean" or now - state.lastInput < INPUT_GAP then
			return
		end
		state.lastInput = now
		state.wants = wants
	end)

	RunService.Heartbeat:Connect(function(dt)
		local now = os.clock()
		for player, state in states do
			step(player, state, dt, now)
		end
	end)
end

return StaminaService
