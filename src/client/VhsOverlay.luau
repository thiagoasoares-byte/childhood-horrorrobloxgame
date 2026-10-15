local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local VisualConfig = require(Shared.VisualConfig)

export type VhsGui = {
	gui: ScreenGui,
	scanlines: Frame,
	noise: Frame,
	vignette: Frame,
	glitch: Frame,
	chromaRed: Frame,
	chromaCyan: Frame,
	recLabel: TextLabel,
	stampLabel: TextLabel,
	fearFill: Frame,
	setFearVisual: (f: number) -> (),
	triggerGlitch: () -> (),
	tickNoise: (now: number) -> (),
}

local VhsOverlay = {}

local function radialVignette(parent: Instance)
	local frame = Instance.new("Frame")
	frame.Name = "Vignette"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local grad = Instance.new("UIGradient")
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.45, 1),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	grad.Parent = frame
	return frame
end

function VhsOverlay.create(): VhsGui
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "SaudadeVhs"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.Parent = playerGui

	local worldStack = Instance.new("Frame")
	worldStack.Name = "WorldStack"
	worldStack.Size = UDim2.fromScale(1, 1)
	worldStack.BackgroundTransparency = 1
	worldStack.BorderSizePixel = 0
	worldStack.Parent = gui

	local chromaRed = Instance.new("Frame")
	chromaRed.Name = "ChromaRed"
	chromaRed.Size = UDim2.fromScale(1, 1)
	chromaRed.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
	chromaRed.BackgroundTransparency = 0.97
	chromaRed.BorderSizePixel = 0
	chromaRed.Parent = worldStack

	local chromaCyan = Instance.new("Frame")
	chromaCyan.Name = "ChromaCyan"
	chromaCyan.Size = UDim2.fromScale(1, 1)
	chromaCyan.BackgroundColor3 = Color3.fromRGB(40, 220, 255)
	chromaCyan.BackgroundTransparency = 0.97
	chromaCyan.BorderSizePixel = 0
	chromaCyan.Parent = worldStack

	local scanlines = Instance.new("Frame")
	scanlines.Name = "Scanlines"
	scanlines.Size = UDim2.fromScale(1, 1)
	scanlines.BackgroundTransparency = 1
	scanlines.BorderSizePixel = 0
	scanlines.ClipsDescendants = true
	scanlines.Parent = gui

	for i = 0, 80 do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 2)
		line.Position = UDim2.fromScale(0, i / 80)
		line.BackgroundColor3 = Color3.new(0, 0, 0)
		line.BackgroundTransparency = 0.45
		line.BorderSizePixel = 0
		line.Parent = scanlines
	end

	local noise = Instance.new("Frame")
	noise.Name = "Noise"
	noise.Size = UDim2.fromScale(1, 1)
	noise.BackgroundColor3 = Color3.new(1, 1, 1)
	noise.BackgroundTransparency = 0.88
	noise.BorderSizePixel = 0
	noise.Parent = gui

	local vignette = radialVignette(gui)

	local glitch = Instance.new("Frame")
	glitch.Name = "GlitchBand"
	glitch.Size = UDim2.new(1, 0, 0.08, 0)
	glitch.Position = UDim2.fromScale(0, 0.3)
	glitch.BackgroundColor3 = Color3.new(1, 1, 1)
	glitch.BackgroundTransparency = 0.93
	glitch.BorderSizePixel = 0
	glitch.Visible = false
	glitch.Parent = gui

	local hud = Instance.new("Frame")
	hud.Name = "Hud"
	hud.Size = UDim2.fromScale(1, 1)
	hud.BackgroundTransparency = 1
	hud.Parent = gui

	local recLabel = Instance.new("TextLabel")
	recLabel.Name = "Rec"
	recLabel.Size = UDim2.fromOffset(120, 24)
	recLabel.Position = UDim2.fromOffset(12, 10)
	recLabel.BackgroundTransparency = 1
	recLabel.Font = Enum.Font.Code
	recLabel.TextSize = 14
	recLabel.TextColor3 = Color3.fromRGB(238, 238, 238)
	recLabel.TextXAlignment = Enum.TextXAlignment.Left
	recLabel.Text = "● REC   SP"
	recLabel.Parent = hud

	local stampLabel = Instance.new("TextLabel")
	stampLabel.Name = "Stamp"
	stampLabel.Size = UDim2.fromOffset(200, 24)
	stampLabel.Position = UDim2.new(1, -212, 1, -34)
	stampLabel.BackgroundTransparency = 1
	stampLabel.Font = Enum.Font.Code
	stampLabel.TextSize = 14
	stampLabel.TextColor3 = Color3.fromRGB(238, 238, 238)
	stampLabel.TextXAlignment = Enum.TextXAlignment.Right
	stampLabel.Text = `{VisualConfig.HUD.recStamp}   {VisualConfig.HUD.recTime}`
	stampLabel.Parent = hud

	local fearBar = Instance.new("Frame")
	fearBar.Name = "FearBar"
	fearBar.Size = UDim2.fromOffset(90, 6)
	fearBar.Position = UDim2.new(0, 12, 1, -16)
	fearBar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	fearBar.BorderSizePixel = 0
	fearBar.Parent = hud

	local fearFill = Instance.new("Frame")
	fearFill.Name = "Fill"
	fearFill.Size = UDim2.fromScale(0, 1)
	fearFill.BackgroundColor3 = Color3.fromRGB(170, 51, 51)
	fearFill.BorderSizePixel = 0
	fearFill.Parent = fearBar

	local cross = Instance.new("Frame")
	cross.Name = "Crosshair"
	cross.Size = UDim2.fromOffset(4, 4)
	cross.AnchorPoint = Vector2.new(0.5, 0.5)
	cross.Position = UDim2.fromScale(0.5, 0.5)
	cross.BackgroundColor3 = Color3.new(1, 1, 1)
	cross.BackgroundTransparency = 0.3
	cross.BorderSizePixel = 0
	cross.Parent = hud

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = cross

	local vhs = VisualConfig.VHS
	local lastNoiseTick = 0

	local function setFearVisual(fear: number)
		local f = VisualConfig.fearNorm(fear)
		scanlines.BackgroundTransparency = 1
		for _, line in scanlines:GetChildren() do
			if line:IsA("Frame") then
				line.BackgroundTransparency = 1 - (vhs.scanlineBaseTransparency + f * vhs.scanlineFearBoost) * 0.55
			end
		end
		noise.BackgroundTransparency = vhs.noiseBaseTransparency - f * vhs.noiseFearBoost
		vignette.BackgroundTransparency = 1 - (vhs.vignetteBase + f * vhs.vignetteFearBoost)
		local px = vhs.chromaBasePx + f * vhs.chromaFearPx
		chromaRed.Position = UDim2.fromOffset(px, 0)
		chromaCyan.Position = UDim2.fromOffset(-px, 0)
		chromaRed.BackgroundTransparency = 0.96 - f * 0.04
		chromaCyan.BackgroundTransparency = 0.96 - f * 0.04
		fearFill.Size = UDim2.fromScale(f, 1)
	end

	local function triggerGlitch()
		glitch.Visible = true
		glitch.Position = UDim2.fromScale(0, math.random() * 0.7)
		glitch.Rotation = (math.random() - 0.5) * 2
		task.delay(0.12, function()
			if glitch.Parent then
				glitch.Visible = false
				glitch.Rotation = 0
			end
		end)
	end

	local function tickNoise(now: number)
		if now - lastNoiseTick < 1 / vhs.noiseFps then
			return
		end
		lastNoiseTick = now
		noise.BackgroundTransparency = math.clamp(
			noise.BackgroundTransparency + (math.random() - 0.5) * 0.08,
			0.65,
			0.95
		)
	end

	task.spawn(function()
		while recLabel.Parent do
			recLabel.Text = if math.floor(os.clock()) % 2 == 0 then "● REC   SP" else "○ REC   SP"
			task.wait(0.5)
		end
	end)

	setFearVisual(VisualConfig.FEAR_DEFAULT)

	return {
		gui = gui,
		scanlines = scanlines,
		noise = noise,
		vignette = vignette,
		glitch = glitch,
		chromaRed = chromaRed,
		chromaCyan = chromaCyan,
		recLabel = recLabel,
		stampLabel = stampLabel,
		fearFill = fearFill,
		setFearVisual = setFearVisual,
		triggerGlitch = triggerGlitch,
		tickNoise = tickNoise,
	}
end

return VhsOverlay
