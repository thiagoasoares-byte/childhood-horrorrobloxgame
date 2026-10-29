--!strict
export type Pizza = "margherita" | "pepperoni"

local Orders = {}

Orders.MENU = { "margherita", "pepperoni" }

Orders.RECIPES = {
	margherita = { "dough", "sauce", "cheese" },
	pepperoni = { "dough", "sauce", "cheese", "pepperoni" },
} :: { [string]: { string } }

Orders.LABELS = {
	margherita = "Pizza simples",
	pepperoni = "Pizza de calabresa",
} :: { [string]: string }

Orders.INGREDIENT_LABELS = {
	dough = "massa",
	sauce = "molho",
	cheese = "queijo",
	pepperoni = "calabresa",
} :: { [string]: string }

function Orders.matches(stages: { string }, pizza: string): boolean
	local recipe = Orders.RECIPES[pizza]
	if not recipe or #recipe ~= #stages then
		return false
	end
	for i, ingredient in recipe do
		if stages[i] ~= ingredient then
			return false
		end
	end
	return true
end

return Orders
