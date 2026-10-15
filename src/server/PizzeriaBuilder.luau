local Workspace = game:GetService("Workspace")

local PizzeriaBuilder = {}

local function part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local value = Instance.new("Part")
	value.Name = name
	value.Anchored = true
	value.Size = size
	value.Position = position
	value.Color = color
	value.Material = Enum.Material.SmoothPlastic
	value.TopSurface = Enum.SurfaceType.Smooth
	value.Parent = parent
	return value
end

local function station(parent: Instance, name: string, position: Vector3, color: Color3)
	local counter = part(parent, name, Vector3.new(7, 3, 3), position, color)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "WorkPrompt"
	prompt.ActionText = "Usar"
	prompt.ObjectText = name == "Counter" and "Balcão de entrega" or name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter
	return prompt
end

function PizzeriaBuilder.create(onStationUsed: (Player, string) -> ())
	local existing = Workspace:FindFirstChild("SaudadePizzeria")
	if existing then
		return
	end

	local map = Instance.new("Folder")
	map.Name = "SaudadePizzeria"
	map.Parent = Workspace

	part(map, "Floor", Vector3.new(70, 1, 45), Vector3.new(0, 0, 0), Color3.fromRGB(79, 67, 59))
	part(map, "BackWall", Vector3.new(70, 16, 1), Vector3.new(0, 8, 22), Color3.fromRGB(95, 83, 72))
	part(map, "LeftWall", Vector3.new(1, 16, 45), Vector3.new(-35, 8, 0), Color3.fromRGB(95, 83, 72))
	part(map, "RightWall", Vector3.new(1, 16, 45), Vector3.new(35, 8, 0), Color3.fromRGB(95, 83, 72))
	part(map, "Ceiling", Vector3.new(70, 1, 45), Vector3.new(0, 16, 0), Color3.fromRGB(54, 48, 45))

	local positions = {
		Dough = Vector3.new(-22, 2, 12),
		Sauce = Vector3.new(-13, 2, 12),
		Cheese = Vector3.new(-4, 2, 12),
		Oven = Vector3.new(7, 2, 12),
		Box = Vector3.new(18, 2, 12),
		Counter = Vector3.new(22, 2, -12),
	}
	local colors = {
		Dough = Color3.fromRGB(215, 178, 119), Sauce = Color3.fromRGB(166, 61, 45),
		Cheese = Color3.fromRGB(232, 190, 59), Oven = Color3.fromRGB(71, 70, 73),
		Box = Color3.fromRGB(181, 144, 93), Counter = Color3.fromRGB(84, 112, 92),
	}
	for name, position in positions do
		local prompt = station(map, name, position, colors[name])
		prompt.Triggered:Connect(function(player)
			onStationUsed(player, name)
		end)
	end

	local board = part(map, "OrderBoard", Vector3.new(14, 8, 1), Vector3.new(20, 7, -19), Color3.fromRGB(23, 27, 24))
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.AlwaysOnTop = true
	surface.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "PIZZARIA SAUDADE\nPEDIDO: QUEIJO"
	label.Font = Enum.Font.Code
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(239, 231, 201)
	label.Parent = surface

	local clock = part(map, "NightClock", Vector3.new(5, 3, 0.5), Vector3.new(-26, 11, -20), Color3.fromRGB(30, 27, 24))
	local clockSurface = Instance.new("SurfaceGui")
	clockSurface.Face = Enum.NormalId.Front
	clockSurface.AlwaysOnTop = true
	clockSurface.Parent = clock
	local clockText = Instance.new("TextLabel")
	clockText.Size = UDim2.fromScale(1, 1)
	clockText.BackgroundTransparency = 1
	clockText.Font = Enum.Font.Code
	clockText.TextScaled = true
	clockText.TextColor3 = Color3.fromRGB(244, 224, 174)
	clockText.Parent = clockSurface
	task.spawn(function()
		local minute = 14
		while clockText.Parent do
			clockText.Text = string.format("22:%02d", minute)
			task.wait(3)
			-- Once per cycle the clock visibly runs backwards: the first Night 1 anomaly.
			minute = if minute <= 8 then 17 else minute - 1
		end
	end)
end

return PizzeriaBuilder
