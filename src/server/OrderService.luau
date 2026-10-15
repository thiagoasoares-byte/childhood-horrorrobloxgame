local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local FearService = require(script.Parent.FearService)
local PizzaStation = require(script.Parent.PizzaStation)

local OrderService = {}

local orderChanged: RemoteEvent
local state = PizzaStation.new()
local orderNumber = 0
local deadline = 0
local active = false
local ovenBusy = false
local onNightComplete: (() -> boolean)?
local order = {
	name = "Pizza de queijo",
	ingredients = "massa • molho • queijo",
}

local function secondsLeft(): number
	return math.max(0, math.ceil(deadline - os.clock()))
end

local function broadcast(status: string)
	orderChanged:FireAllClients({
		active = active,
		number = orderNumber,
		name = order.name,
		ingredients = order.ingredients,
		nextStation = PizzaStation.expectedStation(state),
		secondsLeft = secondsLeft(),
		status = status,
	})
end

local function beginOrder()
	PizzaStation.reset(state)
	active = true
	ovenBusy = false
	orderNumber += 1
	deadline = os.clock() + 120
	broadcast("Cliente aguardando no balcão")
end

function OrderService.init(nightComplete: (() -> boolean)?)
	onNightComplete = nightComplete
	Remotes.ensureServerEvents({ "OrderUpdated", "NightSummary" })
	orderChanged = ReplicatedStorage.Remotes.OrderUpdated
	beginOrder()

	task.spawn(function()
		while true do
			task.wait(1)
			if active and secondsLeft() <= 0 then
				active = false
				for _, player in Players:GetPlayers() do
					FearService.addFear(player, 8)
				end
				broadcast("Pedido atrasou — Medo +8")
				task.wait(3)
				beginOrder()
			elseif active then
				broadcast("")
			end
		end
	end)
end

function OrderService.interact(player: Player, stationName: string)
	if not active then
		return
	end

	if stationName == "Oven" then
		if PizzaStation.expectedStation(state) ~= "Oven" or ovenBusy then
			FearService.addFear(player, 3)
			broadcast("O forno não aceita isso agora — Medo +3")
			return
		end
		ovenBusy = true
		broadcast("Assando… 8 segundos")
		task.delay(8, function()
			if active and ovenBusy then
				ovenBusy = false
				PizzaStation.advance(state, "Oven")
				broadcast("Pizza pronta: leve para a caixa")
			end
		end)
		return
	end

	if ovenBusy then
		broadcast("A pizza ainda está no forno")
		return
	end

	local accepted, expected = PizzaStation.advance(state, stationName)
	if not accepted then
		FearService.addFear(player, 3)
		broadcast(`Ordem incorreta. Próximo: {expected} — Medo +3`)
		return
	end

	if stationName == "Counter" and PizzaStation.isComplete(state) then
		active = false
		for _, eachPlayer in Players:GetPlayers() do
			FearService.addFear(eachPlayer, -10)
		end
		local nightFinished = onNightComplete and onNightComplete() or false
		broadcast(if nightFinished then "NOITE 1 ENCERRADA" else "Pedido correto — Medo -10")
		if not nightFinished then
			task.delay(4, beginOrder)
		end
	else
		broadcast(`Correto. Próximo: {expected}`)
	end
end

return OrderService
