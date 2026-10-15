local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FOLDER_NAME = "Remotes"

local Remotes = {}

local function getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end
	return folder :: Folder
end

function Remotes.ensureServerEvents(names: { string })
	local folder = getFolder()
	for _, name in names do
		if not folder:FindFirstChild(name) then
			local ev = Instance.new("RemoteEvent")
			ev.Name = name
			ev.Parent = folder
		end
	end
end

function Remotes.waitForEvent(name: string, timeout: number?): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME, timeout or 30)
	return folder:WaitForChild(name, timeout or 30) :: RemoteEvent
end

return Remotes
