local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local VisualConfig = require(Shared.VisualConfig)

local ClientEntityRenderer = {}
local active: { [number]: Model } = {}

local function createPart(model: Model, size: Vector3, offset: CFrame, color: Color3): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Size = size
	part.CFrame = offset
	part.Parent = model
	return part
end

local function buildEntity(kind: string, origin: CFrame): Model
	local model = Instance.new("Model")
	model.Name = kind
	model.Parent = workspace
	local black = Color3.fromRGB(5, 5, 6)
	local body = createPart(model, Vector3.new(2, 10, 1.5), origin * CFrame.new(0, 3, 0), black)
	body.Name = "Body"
	local head = createPart(model, Vector3.new(2.4, 2, 1.7), origin * CFrame.new(0, 9, 0), black)
	head.Name = "Head"
	for _, x in { -0.46, 0.46 } do
		local eye = createPart(model, Vector3.new(0.16, 0.16, 0.1), origin * CFrame.new(x, 9.2, -0.9), Color3.new(1, 1, 1))
		eye.Name = "Eye"
	end
	if kind == "Antena" or kind == "BANZO" then
		createPart(model, Vector3.new(5, 0.25, 0.35), origin * CFrame.new(0, 9.7, 0), black).Name = "Antenna"
	end
	return model
end

local function dismiss(id: number)
	local model = active[id]
	if model then
		active[id] = nil
		model:Destroy()
	end
end

function ClientEntityRenderer.start()
	local appearance = Remotes.waitForEvent("EntityAppearance")
	local dismissed = Remotes.waitForEvent("EntityDismissed")
	appearance.OnClientEvent:Connect(function(kind: string, id: number)
		local camera = workspace.CurrentCamera
		if not camera or typeof(id) ~= "number" then
			return
		end
		dismiss(id)
		local lateral = if id % 2 == 0 then 7 else -7
		local origin = camera.CFrame * CFrame.new(lateral, -5, -18)
		local model = buildEntity(kind, origin)
		active[id] = model

		local lookedAtFor = 0
		local connection: RBXScriptConnection?
		connection = RunService.RenderStepped:Connect(function(dt)
			if active[id] ~= model or not model.Parent then
				connection:Disconnect()
				return
			end
			local currentCamera = workspace.CurrentCamera
			local head = model:FindFirstChild("Head") :: BasePart?
			if not currentCamera or not head then
				return
			end
			local direction = head.Position - currentCamera.CFrame.Position
			local hit = workspace:Raycast(currentCamera.CFrame.Position, direction)
			if hit and hit.Instance:IsDescendantOf(model) then
				lookedAtFor += dt
				if lookedAtFor >= VisualConfig.APPEARANCES.lookSecondsToDismiss then
					dismissed:FireServer(id)
					dismiss(id)
				end
			else
				lookedAtFor = 0
			end
		end)
		task.delay(VisualConfig.APPEARANCES.durationSeconds, function()
			dismiss(id)
		end)
	end)
end

return ClientEntityRenderer
