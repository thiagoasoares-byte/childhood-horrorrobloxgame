--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderService = require(script.Parent.OrderService)
local PhaseService = require(script.Parent.PhaseService)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local COOK_SECONDS = 12
local OVEN_SLOTS = 2
local DEBOUNCE = 0.3
local STEP = 5

type Carry = { stages: { string }, cooked: boolean }
type Slot = { stages: { string }, readyAt: number }

local carrying: { [Player]: Carry } = {}
local lastUse: { [Player]: number } = {}
local oven: { Slot } = {}

local STATIONS = {
	{ kind = "dough", text = "Pegar massa", color = Color3.fromRGB(220, 205, 170) },
	{ kind = "sauce", text = "Molho", color = Color3.fromRGB(170, 40, 30) },
	{ kind = "cheese", text = "Queijo", color = Color3.fromRGB(230, 190, 70) },
	{ kind = "pepperoni", text = "Calabresa", color = Color3.fromRGB(130, 40, 40) },
	{ kind = "oven", text = "Forno", color = Color3.fromRGB(50, 50, 55) },
	{ kind = "counter", text = "Entregar", color = Color3.fromRGB(150, 110, 70) },
}

local function sendCarry(player: Player)
	local carry = carrying[player]
	Remotes.CarryChanged:FireClient(
		player,
		if carry then carry.stages else {},
		carry ~= nil and carry.cooked
	)
end

local function setCarry(player: Player, carry: Carry?)
	carrying[player] = carry
	sendCarry(player)
end

local function use(player: Player, kind: string)
	if PhaseService.get().block ~= "turno" then
		return
	end
	local now = os.clock()
	if now - (lastUse[player] or 0) < DEBOUNCE then
		return
	end
	lastUse[player] = now

	local carry = carrying[player]
	if kind == "dough" then
		if not carry then
			setCarry(player, { stages = { "dough" }, cooked = false })
		end
	elseif kind == "oven" then
		if carry and not carry.cooked then
			if #oven < OVEN_SLOTS then
				table.insert(oven, { stages = carry.stages, readyAt = now + COOK_SECONDS })
				setCarry(player, nil)
			end
		elseif not carry then
			for i, slot in oven do
				if slot.readyAt <= now then
					table.remove(oven, i)
					setCarry(player, { stages = slot.stages, cooked = true })
					break
				end
			end
		end
	elseif kind == "counter" then
		if carry and carry.cooked then
			OrderService.deliver(carry.stages)
			setCarry(player, nil)
		end
	elseif carry and not carry.cooked and not table.find(carry.stages, kind) then
		table.insert(carry.stages, kind)
		sendCarry(player)
	end
end

local PizzaStation = {}

function PizzaStation.start(parent: Instance, origin: Vector3)
	for i, station in STATIONS do
		local part = Instance.new("Part")
		part.Name = "Station_" .. station.kind
		part.Size = Vector3.new(4, 3, 4)
		part.Position = origin + Vector3.new(0, 1.5, (i - 1) * STEP - (#STATIONS - 1) * STEP / 2)
		part.Anchored = true
		part.Color = station.color
		part.Material = Enum.Material.Concrete
		part.Parent = parent

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = station.text
		prompt.ObjectText = "Cozinha"
		prompt.HoldDuration = 0.3
		prompt.MaxActivationDistance = 8
		prompt.RequiresLineOfSight = false
		prompt.Parent = part
		prompt.Triggered:Connect(function(player)
			use(player, station.kind)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		carrying[player] = nil
		lastUse[player] = nil
	end)
end

return PizzaStation
