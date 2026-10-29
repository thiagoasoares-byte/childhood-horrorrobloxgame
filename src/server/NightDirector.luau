--!strict
local Players = game:GetService("Players")

local PhaseService = require(script.Parent.PhaseService)

local POLL_SECONDS = 0.5
local SHIFT_SECONDS = 300 -- provisional until the order curve is tuned in playtest

-- Arrival zones are Parts under workspace.Zones, placed by the map builder.
-- shortcut: one shared "Home" zone for the whole block, split into one zone per house when the map has them.
local ZONES_FOLDER = "Zones"

local warned: { [string]: boolean } = {}

local function inside(zone: BasePart, point: Vector3): boolean
	local localPoint = zone.CFrame:PointToObjectSpace(point)
	local half = zone.Size / 2
	return math.abs(localPoint.X) <= half.X
		and math.abs(localPoint.Y) <= half.Y
		and math.abs(localPoint.Z) <= half.Z
end

local function allArrived(zoneName: string): boolean
	local players = Players:GetPlayers()
	if #players == 0 then
		return false
	end
	local folder = workspace:FindFirstChild(ZONES_FOLDER)
	local zone = folder and folder:FindFirstChild(zoneName)
	if not zone or not zone:IsA("BasePart") then
		if not warned[zoneName] then
			warned[zoneName] = true
			warn(`[NightDirector] zone {zoneName} not found under workspace.{ZONES_FOLDER}`)
		end
		return false
	end
	for _, player in players do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if
			not (root and root:IsA("BasePart"))
			or not humanoid
			or humanoid.Health <= 0
			or not inside(zone, root.Position)
		then
			return false
		end
	end
	return true
end

local function waitForAll(zoneName: string)
	while not allArrived(zoneName) do
		task.wait(POLL_SECONDS)
	end
end

local NightDirector = {}

function NightDirector.start()
	task.spawn(function()
		PhaseService.set(1, "ida")
		waitForAll("Pizzeria")
		PhaseService.set(1, "turno")
		task.wait(SHIFT_SECONDS)
		PhaseService.set(1, "volta")
		waitForAll("Home")
		PhaseService.set(1, "fim")
	end)
end

return NightDirector
