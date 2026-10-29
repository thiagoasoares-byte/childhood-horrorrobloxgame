--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Orders = require(ReplicatedStorage.Shared.Orders)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local REFRESH = 0.5

local orders: { { pizza: string, due: number } } = {}
local carried: { string } = {}
local cooked = false

local label: TextLabel

local function render()
	local lines = { "PEDIDOS" }
	local now = workspace:GetServerTimeNow()
	for _, order in orders do
		local name = Orders.LABELS[order.pizza]
		if name then
			table.insert(lines, `- {name} ({math.max(0, math.ceil(order.due - now))}s)`)
		end
	end
	if #lines == 1 then
		table.insert(lines, "- nenhum")
	end
	if cooked then
		table.insert(lines, "\nNa mão: pizza pronta")
	elseif #carried > 0 then
		local names = {}
		for _, ingredient in carried do
			table.insert(names, Orders.INGREDIENT_LABELS[ingredient] or "?")
		end
		table.insert(lines, "\nNa mão: " .. table.concat(names, ", "))
	end
	label.Text = table.concat(lines, "\n")
end

-- Server payloads are checked for shape; text shown always comes from the shared label tables.
local function readOrders(raw: any)
	local clean = {}
	if type(raw) == "table" then
		for _, item in raw do
			if
				type(item) == "table"
				and type(item.pizza) == "string"
				and type(item.due) == "number"
			then
				table.insert(clean, { pizza = item.pizza, due = item.due })
			end
		end
	end
	orders = clean
	render()
end

local Hud = {}

function Hud.start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 80
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromScale(0.02, 0.3)
	label.Size = UDim2.fromScale(0.3, 0.4)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Code
	label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(235, 235, 220)
	label.TextStrokeTransparency = 0.4
	label.Parent = gui

	Remotes.OrdersChanged.OnClientEvent:Connect(readOrders)
	Remotes.CarryChanged.OnClientEvent:Connect(function(stages: any, isCooked: any)
		carried = {}
		if type(stages) == "table" then
			for _, ingredient in stages do
				if type(ingredient) == "string" then
					table.insert(carried, ingredient)
				end
			end
		end
		cooked = isCooked == true
		render()
	end)

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed >= REFRESH then
			elapsed = 0
			render()
		end
	end)
	render()
end

return Hud
