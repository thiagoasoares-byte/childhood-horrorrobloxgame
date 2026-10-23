--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in { "FearChanged", "SettingsChanged" } do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	folder.Parent = ReplicatedStorage
	return folder
end

local folder = if RunService:IsServer()
	then build()
	else ReplicatedStorage:WaitForChild("Remotes") :: Folder

return {
	FearChanged = folder:WaitForChild("FearChanged") :: RemoteEvent,
	SettingsChanged = folder:WaitForChild("SettingsChanged") :: RemoteEvent,
}
