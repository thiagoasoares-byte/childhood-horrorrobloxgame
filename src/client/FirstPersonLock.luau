--!strict
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local FirstPersonLock = {}

-- The default camera script resets this every frame, so the hide is re-applied on change.
local function hide(part: BasePart)
	local function apply()
		if part.LocalTransparencyModifier ~= 1 then
			part.LocalTransparencyModifier = 1
		end
	end
	apply()
	part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(apply)
end

local function hideBody(character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			hide(descendant)
		end
	end
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			hide(descendant)
		end
	end)
end

function FirstPersonLock.start()
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	if player.Character then
		hideBody(player.Character)
	end
	player.CharacterAdded:Connect(hideBody)
end

return FirstPersonLock
