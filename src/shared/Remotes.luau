--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function build(): Folder
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	for _, name in
		{
			"FearChanged",
			"SettingsChanged",
			"PhaseChanged",
			"OrdersChanged",
			"CarryChanged",
			"ConsentChanged",
		}
	do
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
	PhaseChanged = folder:WaitForChild("PhaseChanged") :: RemoteEvent,
	OrdersChanged = folder:WaitForChild("OrdersChanged") :: RemoteEvent,
	CarryChanged = folder:WaitForChild("CarryChanged") :: RemoteEvent,
	ConsentChanged = folder:WaitForChild("ConsentChanged") :: RemoteEvent,
	PrefsLoaded = folder:WaitForChild("PrefsLoaded") :: RemoteEvent,
}
