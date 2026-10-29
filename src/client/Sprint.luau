--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local SPRINT_KEYS: { [Enum.KeyCode]: boolean } = {
	[Enum.KeyCode.LeftShift] = true,
	[Enum.KeyCode.ButtonL3] = true,
}

local held = false

local function setHeld(value: boolean)
	if held == value then
		return
	end
	held = value
	Remotes.SprintInput:FireServer(value)
end

local function isPointer(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1
end

local Sprint = {}

function Sprint.start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Stamina"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 80
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local back = Instance.new("Frame")
	back.AnchorPoint = Vector2.new(0.5, 0.5)
	back.Position = UDim2.fromScale(0.5, 0.855)
	back.Size = UDim2.fromScale(0.18, 0.012)
	back.BackgroundColor3 = Color3.fromRGB(20, 18, 17)
	back.BackgroundTransparency = 0.3
	back.BorderSizePixel = 0
	back.Visible = false
	back.Parent = gui

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(220, 215, 195)
	fill.BorderSizePixel = 0
	fill.Parent = back

	Remotes.StaminaChanged.OnClientEvent:Connect(function(value: any, exhausted: any)
		if type(value) ~= "number" then
			return
		end
		local clamped = math.clamp(value, 0, 100)
		fill.Size = UDim2.fromScale(clamped / 100, 1)
		fill.BackgroundColor3 = if exhausted == true
			then Color3.fromRGB(150, 50, 45)
			else Color3.fromRGB(220, 215, 195)
		back.Visible = clamped < 100 or exhausted == true
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and SPRINT_KEYS[input.KeyCode] then
			setHeld(true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if SPRINT_KEYS[input.KeyCode] then
			setHeld(false)
		end
	end)
	UserInputService.WindowFocusReleased:Connect(function()
		setHeld(false)
	end)

	if UserInputService.TouchEnabled then
		local button = Instance.new("TextButton")
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.Position = UDim2.fromScale(0.9, 0.72)
		button.Size = UDim2.fromScale(0.14, 0.14)
		button.SizeConstraint = Enum.SizeConstraint.RelativeYY
		button.BackgroundColor3 = Color3.fromRGB(20, 18, 17)
		button.BackgroundTransparency = 0.35
		button.Font = Enum.Font.Code
		button.TextSize = 16
		button.TextColor3 = Color3.fromRGB(235, 235, 220)
		button.Text = "CORRER"
		button.AutoButtonColor = false
		button.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = button
		button.InputBegan:Connect(function(input)
			if isPointer(input) then
				setHeld(true)
			end
		end)
		button.InputEnded:Connect(function(input)
			if isPointer(input) then
				setHeld(false)
			end
		end)
	end
end

return Sprint
