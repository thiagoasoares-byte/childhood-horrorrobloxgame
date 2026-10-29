--!strict
local ServerStorage = game:GetService("ServerStorage")

local KIT_FOLDER = "MapKit"

-- The route runs along +X: homes, playground, pizzeria. Distances are provisional until the walk time is playtested.
local HOME_X = 0
local PARK_X = 180
local PIZZERIA_X = 400

-- Stand-in sizes (studs) matching the Blender kit, used when ServerStorage.MapKit has no imported model of that name.
local PLACEHOLDER_SIZE: { [string]: Vector3 } = {
	SM_House = Vector3.new(18, 14, 16),
	SM_Pizzeria = Vector3.new(37, 17, 28.5),
	SM_Slide = Vector3.new(4, 9.2, 12.4),
	SM_Swing = Vector3.new(9.6, 10.5, 6.5),
	SM_Carousel = Vector3.new(10, 5.4, 10),
	SM_SpringRider = Vector3.new(2.2, 4.9, 3.9),
	SM_DeadTree = Vector3.new(7.4, 13.2, 3.9),
	SM_Statue = Vector3.new(4, 8.4, 4),
	SM_FenceSegment = Vector3.new(8, 3.4, 0.4),
	SM_Streetlamp = Vector3.new(2.7, 12.1, 1),
}

local function anchor(instance: Instance)
	if instance:IsA("BasePart") then
		instance.Anchored = true
	end
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end
end

-- Kit models have their origin at the centre of the base.
local function place(
	parent: Instance,
	kit: Instance?,
	name: string,
	x: number,
	z: number,
	yaw: number
)
	local cframe = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(yaw), 0)
	local template = kit and kit:FindFirstChild(name)
	local instance: Instance
	if template and (template:IsA("Model") or template:IsA("BasePart")) then
		instance = template:Clone()
		if instance:IsA("Model") then
			instance:PivotTo(cframe)
		elseif instance:IsA("BasePart") then
			instance.CFrame = cframe * CFrame.new(0, instance.Size.Y / 2, 0)
		end
	else
		local size = PLACEHOLDER_SIZE[name]
		local part = Instance.new("Part")
		part.Size = size
		part.CFrame = cframe * CFrame.new(0, size.Y / 2, 0)
		part.Color = Color3.fromRGB(140, 130, 110)
		part.Material = Enum.Material.Concrete
		instance = part
	end
	anchor(instance)
	instance.Name = name
	instance.Parent = parent
end

local function zone(parent: Instance, name: string, center: Vector3, size: Vector3)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = center
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = parent
end

local PizzeriaBuilder = {}

function PizzeriaBuilder.build()
	for _, old in { "Map", "Zones" } do
		local existing = workspace:FindFirstChild(old)
		if existing then
			existing:Destroy()
		end
	end

	local kit = ServerStorage:FindFirstChild(KIT_FOLDER)
	local map = Instance.new("Folder")
	map.Name = "Map"

	local ground = Instance.new("Part")
	ground.Name = "Ground"
	ground.Size = Vector3.new(700, 1, 400)
	ground.Position = Vector3.new(200, -0.5, 0)
	ground.Anchored = true
	ground.Color = Color3.fromRGB(70, 78, 62)
	ground.Material = Enum.Material.Grass
	ground.Parent = map

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HomeSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(HOME_X + 25, 0.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = map

	for _, z in { -45, -15, 15, 45 } do
		place(map, kit, "SM_House", HOME_X, z, 0)
	end

	place(map, kit, "SM_Slide", PARK_X - 30, -20, 0)
	place(map, kit, "SM_Swing", PARK_X, -30, 0)
	place(map, kit, "SM_Carousel", PARK_X + 10, 10, 0)
	place(map, kit, "SM_SpringRider", PARK_X - 15, 25, 0)
	place(map, kit, "SM_DeadTree", PARK_X - 40, -40, 0)
	place(map, kit, "SM_DeadTree", PARK_X + 40, 35, 0)
	place(map, kit, "SM_DeadTree", PARK_X + 50, -25, 90)
	place(map, kit, "SM_Statue", PARK_X + 85, 0, 90)
	for i = 0, 12 do
		place(map, kit, "SM_FenceSegment", PARK_X - 50 + i * 8, -50, 0)
	end
	for _, x in { 60, 120, 240, 300, 360 } do
		place(map, kit, "SM_Streetlamp", x, 8, 0)
	end

	-- Yaw 90 turns the entrance toward the park (-X).
	place(map, kit, "SM_Pizzeria", PIZZERIA_X, 0, 90)

	local zones = Instance.new("Folder")
	zones.Name = "Zones"
	zone(zones, "Pizzeria", Vector3.new(PIZZERIA_X - 28, 6, 0), Vector3.new(24, 12, 40))
	zone(zones, "Home", Vector3.new(HOME_X + 10, 10, 0), Vector3.new(60, 24, 120))

	map.Parent = workspace
	zones.Parent = workspace
end

return PizzeriaBuilder
