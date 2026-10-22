--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local parts: { [BasePart]: true } = {}

local function track(character: Model)
	table.clear(parts)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			parts[descendant] = true
		end
	end
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			parts[descendant] = true
		end
	end)
	character.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			parts[descendant] = nil
		end
	end)
end

local FirstPersonLock = {}

function FirstPersonLock.start()
	player.CameraMode = Enum.CameraMode.LockFirstPerson

	-- runs after the default camera, which resets this property every frame
	RunService:BindToRenderStep(
		"ChildhoodHideBody",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			for part in parts do
				part.LocalTransparencyModifier = 1
			end
		end
	)

	if player.Character then
		track(player.Character)
	end
	player.CharacterAdded:Connect(track)
end

return FirstPersonLock
