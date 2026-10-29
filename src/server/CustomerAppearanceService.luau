--!strict
local Players = game:GetService("Players")

local ConsentService = require(script.Parent.ConsentService)

-- D18 server switch. Third-party appearance stays off until the platform policy review is done.
local FRIEND_APPEARANCE_ENABLED = false
local DISTORT_HEAD = 1.3
local DISTORT_WIDTH = 0.8

local SKIN_TONES = {
	Color3.fromRGB(234, 184, 146),
	Color3.fromRGB(190, 140, 100),
	Color3.fromRGB(120, 85, 60),
	Color3.fromRGB(245, 205, 180),
}
local COLOR_PROPERTIES =
	{ "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" }

type Record = { model: Model, source: Player? }

local records: { [number]: Record } = {}
local alive: { [number]: boolean } = {}
local friendIds: { [Player]: { number } } = {} -- in memory only, never saved or logged
local folder: Folder? = nil

local function generic(seed: number): HumanoidDescription
	local description = Instance.new("HumanoidDescription")
	local tone = SKIN_TONES[seed % #SKIN_TONES + 1]
	for _, property in COLOR_PROPERTIES do
		(description :: any)[property] = tone
	end
	return description
end

local function friendDescription(): (HumanoidDescription?, Player?)
	if not FRIEND_APPEARANCE_ENABLED then
		return nil, nil
	end
	local sources = {}
	for _, player in Players:GetPlayers() do
		if ConsentService.allowsFriends(player) then
			table.insert(sources, player)
		end
	end
	if #sources == 0 then
		return nil, nil
	end
	local source = sources[math.random(#sources)]
	local ids = friendIds[source]
	if not ids then
		ids = {}
		local ok, pages = pcall(function()
			return Players:GetFriendsAsync(source.UserId)
		end)
		if ok then
			for _, item in (pages :: any):GetCurrentPage() do
				table.insert(ids, (item :: any).Id)
			end
		end
		friendIds[source] = ids
	end
	if #ids == 0 then
		return nil, nil
	end
	local pick = ids[math.random(#ids)]
	local ok, description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(pick)
	end)
	if not ok then
		return nil, nil
	end
	description.HeadScale = DISTORT_HEAD
	description.WidthScale = DISTORT_WIDTH
	return description, source
end

local function container(): Folder
	if folder and folder.Parent then
		return folder
	end
	local created = Instance.new("Folder")
	created.Name = "Customers"
	created.Parent = workspace
	folder = created
	return created
end

local CustomerAppearanceService = {}

function CustomerAppearanceService.spawn(id: number, cframe: CFrame)
	alive[id] = true
	local description, source = friendDescription()
	local model = Players:CreateHumanoidModelFromDescription(
		description or generic(id),
		Enum.HumanoidRigType.R15
	)
	if source and not ConsentService.allowsFriends(source) then
		model:Destroy()
		source = nil
		model = Players:CreateHumanoidModelFromDescription(generic(id), Enum.HumanoidRigType.R15)
	end
	if not alive[id] then
		model:Destroy()
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not root:IsA("BasePart") then
		model:Destroy()
		return
	end
	humanoid.DisplayName = ""
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 0
	root.Anchored = true
	model.Name = "Customer"
	model:PivotTo(cframe * CFrame.new(0, humanoid.HipHeight + root.Size.Y / 2, 0))
	model.Parent = container()
	records[id] = { model = model, source = source }
	print(`[Customer] spawned with {if source then "third-party" else "generic"} appearance`)
end

function CustomerAppearanceService.remove(id: number)
	alive[id] = nil
	local record = records[id]
	records[id] = nil
	if record then
		record.model:Destroy()
	end
end

function CustomerAppearanceService.start()
	-- Opt-out takes effect immediately: customers built from that player's friends turn generic.
	ConsentService.Changed:Connect(function(player: Player, optedOut: boolean)
		if not optedOut then
			return
		end
		friendIds[player] = nil
		for id, record in records do
			local humanoid = record.model:FindFirstChildOfClass("Humanoid")
			if record.source == player and humanoid then
				record.source = nil
				task.spawn(function()
					humanoid:ApplyDescription(generic(id))
				end)
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		friendIds[player] = nil
	end)

	local function hideNameplate(character: Model)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	local function watch(player: Player)
		player.CharacterAdded:Connect(hideNameplate)
		if player.Character then
			task.spawn(hideNameplate, player.Character)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
end

return CustomerAppearanceService
