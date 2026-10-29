--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local HorrorCamera = require(script.Parent.HorrorCamera)
local Orders = require(ReplicatedStorage.Shared.Orders)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local CLOSE_DISTANCE = 18
local GHOST_SIZE = 64

local CHIPS = {
	{ kind = "dough", color = Color3.fromRGB(226, 200, 150) },
	{ kind = "sauce", color = Color3.fromRGB(180, 40, 30) },
	{ kind = "cheese", color = Color3.fromRGB(236, 190, 70) },
	{ kind = "pepperoni", color = Color3.fromRGB(135, 40, 40) },
}

local PEPPERONI_SPOTS = {
	Vector2.new(0.35, 0.35),
	Vector2.new(0.62, 0.32),
	Vector2.new(0.28, 0.6),
	Vector2.new(0.55, 0.58),
	Vector2.new(0.72, 0.62),
	Vector2.new(0.45, 0.76),
}

local gui: ScreenGui
local pizza: Frame
local layers: { [string]: { GuiObject } } = {}
local dragging: { input: InputObject, ghost: Frame, kind: string }? = nil

local function circle(parent: Instance, size: UDim2, position: UDim2, color: Color3): Frame
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = frame
	return frame
end

local function buildLayers()
	local center = UDim2.fromScale(0.5, 0.5)
	layers.dough = { circle(pizza, UDim2.fromScale(0.96, 0.96), center, CHIPS[1].color) }
	layers.sauce = { circle(pizza, UDim2.fromScale(0.82, 0.82), center, CHIPS[2].color) }
	layers.cheese = { circle(pizza, UDim2.fromScale(0.74, 0.74), center, CHIPS[3].color) }
	local spots = {}
	for _, spot in PEPPERONI_SPOTS do
		table.insert(
			spots,
			circle(
				pizza,
				UDim2.fromScale(0.13, 0.13),
				UDim2.fromScale(spot.X, spot.Y),
				CHIPS[4].color
			)
		)
	end
	layers.pepperoni = spots
end

-- The pizza drawing always mirrors what the server says the player is carrying.
local function showStages(stages: { string }, cooked: boolean)
	for kind, objects in layers do
		local on = table.find(stages, kind) ~= nil
		for _, object in objects do
			object.Visible = on
		end
	end
	if cooked then
		for _, object in layers.cheese do
			object.BackgroundColor3 = Color3.fromRGB(214, 150, 50)
		end
	else
		for _, object in layers.cheese do
			object.BackgroundColor3 = CHIPS[3].color
		end
	end
end

local function insidePizza(point: Vector2): boolean
	local radius = pizza.AbsoluteSize.X / 2
	local center = pizza.AbsolutePosition + pizza.AbsoluteSize / 2
	return (point - center).Magnitude <= radius
end

local function endDrag()
	if dragging then
		dragging.ghost:Destroy()
		dragging = nil
	end
end

local function startDrag(kind: string, color: Color3, input: InputObject)
	endDrag()
	local ghost = Instance.new("Frame")
	ghost.AnchorPoint = Vector2.new(0.5, 0.5)
	ghost.Size = UDim2.fromOffset(GHOST_SIZE, GHOST_SIZE)
	ghost.Position = UDim2.fromOffset(input.Position.X, input.Position.Y)
	ghost.BackgroundColor3 = color
	ghost.BackgroundTransparency = 0.15
	ghost.BorderSizePixel = 0
	ghost.ZIndex = 20
	ghost.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = ghost
	dragging = { input = input, ghost = ghost, kind = kind }
end

local function isPointer(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function buildPalette(panel: Frame)
	local palette = Instance.new("Frame")
	palette.BackgroundTransparency = 1
	palette.Position = UDim2.fromScale(0.04, 0.16)
	palette.Size = UDim2.fromScale(0.26, 0.74)
	palette.Parent = panel
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0.04, 0)
	list.Parent = palette

	for _, chip in CHIPS do
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromScale(1, 0.2)
		button.BackgroundColor3 = Color3.fromRGB(38, 36, 34)
		button.AutoButtonColor = true
		button.Font = Enum.Font.Code
		button.TextSize = 20
		button.TextColor3 = Color3.fromRGB(235, 235, 220)
		button.Text = "      " .. string.upper(Orders.INGREDIENT_LABELS[chip.kind] or "?")
		button.Parent = palette
		local swatch = Instance.new("Frame")
		swatch.AnchorPoint = Vector2.new(0, 0.5)
		swatch.Position = UDim2.fromScale(0.05, 0.5)
		swatch.Size = UDim2.fromScale(0.22, 0.7)
		swatch.SizeConstraint = Enum.SizeConstraint.RelativeYY
		swatch.BackgroundColor3 = chip.color
		swatch.BorderSizePixel = 0
		swatch.Parent = button
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = swatch
		button.InputBegan:Connect(function(input)
			if isPointer(input) then
				startDrag(chip.kind, chip.color, input)
			end
		end)
	end
end

local PizzaMaker = {}

function PizzaMaker.close()
	endDrag()
	gui.Enabled = false
	HorrorCamera.setCursorFree("pizza", false)
end

function PizzaMaker.open()
	gui.Enabled = true
	HorrorCamera.setCursorFree("pizza", true)
end

function PizzaMaker.start()
	gui = Instance.new("ScreenGui")
	gui.Name = "PizzaMaker"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 85
	gui.Enabled = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromScale(0.62, 0.66)
	panel.BackgroundColor3 = Color3.fromRGB(20, 18, 17)
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Parent = gui

	local hint = Instance.new("TextLabel")
	hint.BackgroundTransparency = 1
	hint.Position = UDim2.fromScale(0.04, 0.03)
	hint.Size = UDim2.fromScale(0.8, 0.1)
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.Font = Enum.Font.Code
	hint.TextSize = 20
	hint.TextColor3 = Color3.fromRGB(235, 235, 220)
	hint.Text = "ARRASTE OS INGREDIENTES PARA A PIZZA, NA ORDEM: MASSA, MOLHO, QUEIJO, CALABRESA"
	hint.TextWrapped = true
	hint.Parent = panel

	local close = Instance.new("TextButton")
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.fromScale(0.985, 0.02)
	close.Size = UDim2.fromScale(0.07, 0.1)
	close.BackgroundColor3 = Color3.fromRGB(90, 30, 28)
	close.Font = Enum.Font.Code
	close.TextSize = 22
	close.TextColor3 = Color3.fromRGB(235, 235, 220)
	close.Text = "X"
	close.Parent = panel
	close.Activated:Connect(PizzaMaker.close)

	pizza = Instance.new("Frame")
	pizza.AnchorPoint = Vector2.new(0.5, 0.5)
	pizza.Position = UDim2.fromScale(0.66, 0.56)
	pizza.Size = UDim2.fromScale(0.64, 0.64)
	pizza.SizeConstraint = Enum.SizeConstraint.RelativeYY
	pizza.BackgroundTransparency = 1
	pizza.Parent = panel

	buildLayers()
	buildPalette(panel)

	Remotes.PizzaMakerOpen.OnClientEvent:Connect(PizzaMaker.open)
	Remotes.CarryChanged.OnClientEvent:Connect(function(stages: any, cooked: any)
		local clean: { string } = {}
		if type(stages) == "table" then
			for _, kind in stages do
				if type(kind) == "string" and layers[kind] then
					table.insert(clean, kind)
				end
			end
		end
		showStages(clean, cooked == true)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input == dragging.input)
		then
			dragging.ghost.Position = UDim2.fromOffset(input.Position.X, input.Position.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		local current = dragging
		if current and isPointer(input) then
			if insidePizza(Vector2.new(input.Position.X, input.Position.Y)) then
				Remotes.PizzaAction:FireServer(current.kind)
			end
			endDrag()
		end
	end)

	-- Walking away from the table closes the maker, since the server would ignore the drops anyway.
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.5 or not gui.Enabled then
			return
		end
		elapsed = 0
		local map = workspace:FindFirstChild("Map")
		local prepTable = map and map:FindFirstChild("Station_prep")
		local character = Players.LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if prepTable and root and prepTable:IsA("BasePart") and root:IsA("BasePart") then
			if (root.Position - prepTable.Position).Magnitude > CLOSE_DISTANCE then
				PizzaMaker.close()
			end
		end
	end)
end

return PizzaMaker
