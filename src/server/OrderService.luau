--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CustomerAppearanceService = require(script.Parent.CustomerAppearanceService)
local FearService = require(script.Parent.FearService)
local Orders = require(ReplicatedStorage.Shared.Orders)
local PhaseService = require(script.Parent.PhaseService)
local PizzeriaBuilder = require(script.Parent.PizzeriaBuilder)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ORDER_LIFETIME = 90
local FEAR_RIGHT = -8 -- a right order calms the kitchen
local FEAR_WRONG = 10
local FEAR_LATE = 6

type Order = { id: number, pizza: string, due: number, slot: number }

local open: { Order } = {}
local nextId = 0
local lastSpawn = 0
local inShift = false

local function snapshot(): { Order }
	return open
end

local function broadcast()
	Remotes.OrdersChanged:FireAllClients(snapshot())
end

local function shiftFear(delta: number)
	for _, player in Players:GetPlayers() do
		FearService.add(player, delta)
	end
end

-- Group scale: fewer simultaneous orders and longer gaps for small groups. Provisional until playtested with 2 to 4 players.
local function limits(): (number, number)
	local count = math.clamp(#Players:GetPlayers(), 1, 4)
	return count, 40 - 5 * count
end

local function freeSlot(): number
	local used = {}
	for _, order in open do
		used[order.slot] = true
	end
	local slot = 1
	while used[slot] do
		slot += 1
	end
	return slot
end

-- Customers queue in front of the counter station, facing the kitchen.
local function customerCFrame(slot: number): CFrame
	local position = PizzeriaBuilder.KITCHEN_ORIGIN + Vector3.new(-6, 0, 12.5 + (slot - 1) * 3)
	return CFrame.lookAt(position, position + Vector3.xAxis)
end

local function closeOrder(index: number)
	CustomerAppearanceService.remove(open[index].id)
	table.remove(open, index)
end

local function clearOrders()
	for i = #open, 1, -1 do
		closeOrder(i)
	end
end

local OrderService = {}

function OrderService.sync(player: Player)
	Remotes.OrdersChanged:FireClient(player, snapshot())
end

function OrderService.deliver(stages: { string })
	for i, order in open do
		if Orders.matches(stages, order.pizza) then
			closeOrder(i)
			shiftFear(FEAR_RIGHT)
			broadcast()
			return
		end
	end
	shiftFear(FEAR_WRONG)
end

function OrderService.start()
	task.spawn(function()
		while true do
			task.wait(1)
			local active = PhaseService.get().block == "turno"
			if not active then
				if inShift then
					inShift = false
					clearOrders()
					broadcast()
				end
				continue
			end
			if not inShift then
				inShift = true
				lastSpawn = -math.huge
			end

			local now = workspace:GetServerTimeNow()
			local changed = false
			for i = #open, 1, -1 do
				if open[i].due <= now then
					closeOrder(i)
					shiftFear(FEAR_LATE)
					changed = true
				end
			end

			local maxOpen, interval = limits()
			if #open < maxOpen and now - lastSpawn >= interval then
				nextId += 1
				local slot = freeSlot()
				table.insert(open, {
					id = nextId,
					pizza = Orders.MENU[math.random(#Orders.MENU)],
					due = now + ORDER_LIFETIME,
					slot = slot,
				})
				task.spawn(CustomerAppearanceService.spawn, nextId, customerCFrame(slot))
				lastSpawn = now
				changed = true
			end
			if changed then
				broadcast()
			end
		end
	end)
end

return OrderService
