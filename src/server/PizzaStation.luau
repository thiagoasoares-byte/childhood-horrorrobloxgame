--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrderService = require(script.Parent.OrderService)
local PhaseService = require(script.Parent.PhaseService)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local COOK_SECONDS = 12
local OVEN_SLOTS = 2
local DEBOUNCE = 0.2
local PREP_RANGE = 14 -- studs from the prep table within which drops are accepted
local STEP = 5

type Carry = { stages: { string }, cooked: boolean }
type Slot = { stages: { string }, readyAt: number }

local carrying: { [Player]: Carry } = {}
local lastUse: { [Player]: number } = {}
local oven: { Slot } = {}

local STATIONS = {
	{
		kind = "prep",
		text = "Montar pizza",
		color = Color3.fromRGB(220, 205, 170),
		size = Vector3.new(7, 3, 4),
	},
	{
		kind = "oven",
		text = "Forno",
		color = Color3.fromRGB(50, 50, 55),
		size = Vector3.new(4, 3, 4),
	},
	{
		kind = "counter",
		text = "Entregar",
		color = Color3.fromRGB(150, 110, 70),
		size = Vector3.new(4, 3, 4),
	},
}

-- Ingredients are layered in this order, like the pizza itself.
local LAYER = { dough = 1, sauce = 2, cheese = 3, pepperoni = 4 } :: { [string]: number }

local prepPart: BasePart? = nil

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
	if kind == "prep" then
		Remotes.PizzaMakerOpen:FireClient(player)
	elseif kind == "dough" then
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
	elseif carry and not carry.cooked and LAYER[kind] then
		local last = carry.stages[#carry.stages]
		if LAYER[kind] > (LAYER[last] or 0) then
			table.insert(carry.stages, kind)
			sendCarry(player)
		end
	end
end

local PizzaStation = {}

function PizzaStation.start(parent: Instance, origin: Vector3)
	for i, station in STATIONS do
		local part = Instance.new("Part")
		part.Name = "Station_" .. station.kind
		part.Size = station.size
		part.Position = origin + Vector3.new(0, 1.5, (i - 1) * STEP - (#STATIONS - 1) * STEP / 2)
		if station.kind == "prep" then
			prepPart = part
		end
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

	-- The drop comes from the client UI, so the kind, the distance and the pace are all checked here.
	Remotes.PizzaAction.OnServerEvent:Connect(function(player: Player, kind: any)
		if type(kind) ~= "string" or not LAYER[kind] or not prepPart then
			return
		end
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if
			root
			and root:IsA("BasePart")
			and (root.Position - prepPart.Position).Magnitude <= PREP_RANGE
		then
			use(player, kind)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		carrying[player] = nil
		lastUse[player] = nil
	end)
end

return PizzaStation
