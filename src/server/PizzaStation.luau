-- Server-authoritative assembly line for the shared Night 1 pizza.
local PizzaStation = {}

export type PizzaState = {
	stage: number,
	cooked: boolean,
	boxed: boolean,
}

local sequence = { "Dough", "Sauce", "Cheese", "Oven", "Box", "Counter" }

function PizzaStation.new(): PizzaState
	return { stage = 0, cooked = false, boxed = false }
end

function PizzaStation.reset(state: PizzaState)
	state.stage = 0
	state.cooked = false
	state.boxed = false
end

function PizzaStation.expectedStation(state: PizzaState): string?
	return sequence[state.stage + 1]
end

function PizzaStation.advance(state: PizzaState, stationName: string): (boolean, string)
	local expected = PizzaStation.expectedStation(state)
	if expected ~= stationName then
		return false, expected or "a new order"
	end

	state.stage += 1
	if stationName == "Oven" then
		state.cooked = true
	elseif stationName == "Box" then
		state.boxed = true
	end
	return true, PizzaStation.expectedStation(state) or "complete"
end

function PizzaStation.isComplete(state: PizzaState): boolean
	return state.stage >= #sequence and state.cooked and state.boxed
end

return PizzaStation
