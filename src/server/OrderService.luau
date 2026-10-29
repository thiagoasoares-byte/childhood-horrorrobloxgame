--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FearService = require(script.Parent.FearService)
local Orders = require(ReplicatedStorage.Shared.Orders)
local PhaseService = require(script.Parent.PhaseService)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local ORDER_LIFETIME = 90
local FEAR_RIGHT = -8 -- a right order calms the kitchen
local FEAR_WRONG = 10
local FEAR_LATE = 6

type Order = { id: number, pizza: string, due: number }

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

local OrderService = {}

function OrderService.sync(player: Player)
	Remotes.OrdersChanged:FireClient(player, snapshot())
end

function OrderService.deliver(stages: { string })
	for i, order in open do
		if Orders.matches(stages, order.pizza) then
			table.remove(open, i)
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
					open = {}
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
					table.remove(open, i)
					shiftFear(FEAR_LATE)
					changed = true
				end
			end

			local maxOpen, interval = limits()
			if #open < maxOpen and now - lastSpawn >= interval then
				nextId += 1
				table.insert(open, {
					id = nextId,
					pizza = Orders.MENU[math.random(#Orders.MENU)],
					due = now + ORDER_LIFETIME,
				})
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
