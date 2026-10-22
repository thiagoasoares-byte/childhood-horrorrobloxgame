--!strict
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)
local Ui = require(script.Parent.Ui)

local make = Ui.make

export type Options = {
	frame: boolean,
	frameAnimated: boolean,
	scanlines: boolean,
	scanlineSpacing: number,
	vignette: number,
	colorGrade: boolean,
	brightness: number,
}

type Ui = {
	vignette: { UIGradient },
	scanlines: Frame,
	lines: { Frame },
	frame: Frame,
	recDot: Frame,
	timecode: TextLabel,
	labels: { TextLabel },
	colorCorrection: ColorCorrectionEffect,
}

type Edge = { size: UDim2, anchor: Vector2, rotation: number }

local BLINK_SECONDS = 1
local TEXT_COLOR = Color3.fromRGB(235, 235, 235)
local REC_COLOR = Color3.fromRGB(220, 40, 40)

local band = VisualConfig.sampleBand(0)
local options: Options = {
	frame = true,
	frameAnimated = true,
	scanlines = true,
	scanlineSpacing = VisualConfig.Profiles.High.scanlineSpacing,
	vignette = 1,
	colorGrade = true,
	brightness = 0,
}
local ui: Ui? = nil
local lastScanlineOpacity = -1
local lastVignetteOpacity = -1

local function fullScreen(name: string, zIndex: number, parent: Instance): Frame
	return make("Frame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = zIndex,
	}, parent)
end

local function edgeSequence(opacity: number): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - opacity),
		NumberSequenceKeypoint.new(1, 1),
	})
end

local function refresh()
	local u = ui
	if not u then
		return
	end

	local vignetteOpacity = band.vignette * options.vignette
	if math.abs(vignetteOpacity - lastVignetteOpacity) > 0.001 then
		lastVignetteOpacity = vignetteOpacity
		local sequence = edgeSequence(vignetteOpacity)
		for _, gradient in u.vignette do
			gradient.Transparency = sequence
		end
	end

	local scanlineOpacity = if options.scanlines then band.scanlines else 0
	local quantized = math.floor(scanlineOpacity * 100 + 0.5) / 100
	u.scanlines.Visible = quantized > 0
	if quantized ~= lastScanlineOpacity then
		lastScanlineOpacity = quantized
		for _, line in u.lines do
			line.BackgroundTransparency = 1 - quantized
		end
	end

	u.colorCorrection.Saturation = if options.colorGrade then band.saturation else 0
	u.colorCorrection.Brightness = options.brightness * VisualConfig.Brightness.maxLift
	u.frame.Visible = options.frame
end

local function rebuildScanlines(u: Ui)
	for _, line in u.lines do
		line:Destroy()
	end
	table.clear(u.lines)
	lastScanlineOpacity = -1

	local y = 0
	local height = u.scanlines.AbsoluteSize.Y
	while y < height do
		table.insert(
			u.lines,
			make("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.fromOffset(0, y),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, u.scanlines)
		)
		y += options.scanlineSpacing
	end
	refresh()
end

local function applyTextSize(u: Ui)
	local size = math.clamp(math.floor(u.frame.AbsoluteSize.Y * 0.03), 14, 28)
	for _, label in u.labels do
		label.TextSize = size
	end
	u.recDot.Size = UDim2.fromOffset(size * 0.6, size * 0.6)
end

local function column(name: string, anchor: Vector2, parent: Instance): Frame
	local container = make("Frame", {
		Name = name,
		AnchorPoint = anchor,
		Position = UDim2.fromScale(anchor.X, anchor.Y),
		Size = UDim2.new(),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, parent)
	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = if anchor.X == 1
			then Enum.HorizontalAlignment.Right
			else Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 2),
	}, container)
	return container
end

local function build(): Ui
	local gui = make("ScreenGui", {
		Name = "VhsOverlay",
		ResetOnSpawn = false,
		DisplayOrder = 100,
		ScreenInsets = Enum.ScreenInsets.None,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)

	local vignetteRoot = fullScreen("Vignette", 1, gui)
	local gradients: { UIGradient } = {}
	local edges: { Edge } = {
		{ size = UDim2.fromScale(1, 0.3), anchor = Vector2.new(0, 0), rotation = 90 },
		{ size = UDim2.fromScale(1, 0.3), anchor = Vector2.new(0, 1), rotation = 270 },
		{ size = UDim2.fromScale(0.25, 1), anchor = Vector2.new(0, 0), rotation = 0 },
		{ size = UDim2.fromScale(0.25, 1), anchor = Vector2.new(1, 0), rotation = 180 },
	}
	for _, edge in edges do
		local piece = make("Frame", {
			Size = edge.size,
			AnchorPoint = edge.anchor,
			Position = UDim2.fromScale(edge.anchor.X, edge.anchor.Y),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		}, vignetteRoot)
		table.insert(gradients, make("UIGradient", { Rotation = edge.rotation }, piece))
	end

	local scanlines = fullScreen("Scanlines", 2, gui)
	scanlines.ClipsDescendants = true

	local frame = fullScreen("Frame", 3, gui)
	make("UIPadding", {
		PaddingLeft = UDim.new(0.03, 0),
		PaddingRight = UDim.new(0.03, 0),
		PaddingTop = UDim.new(0.04, 0),
		PaddingBottom = UDim.new(0.04, 0),
	}, frame)

	local labels: { TextLabel } = {}
	local function label(text: string, parent: Instance, order: number): TextLabel
		local created = make("TextLabel", {
			Text = text,
			LayoutOrder = order,
			Size = UDim2.new(),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.RobotoMono,
			TextColor3 = TEXT_COLOR,
			TextTransparency = 0.15,
			TextStrokeTransparency = 0.6,
		}, parent)
		table.insert(labels, created)
		return created
	end

	local topLeft = column("TopLeft", Vector2.new(0, 0), frame)
	local recRow = make("Frame", {
		Size = UDim2.new(),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, topLeft)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	}, recRow)
	local recDot = make("Frame", { BackgroundColor3 = REC_COLOR, BorderSizePixel = 0 }, recRow)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, recDot)
	label("REC", recRow, 2)
	label("SP", topLeft, 2)

	local topRight = column("TopRight", Vector2.new(1, 0), frame)
	label("PLAY >", topRight, 1)

	local bottomLeft = column("BottomLeft", Vector2.new(0, 1), frame)
	local timecode = label("00:00:00", bottomLeft, 1)

	local bottomCenter = column("BottomCenter", Vector2.new(0.5, 1), frame)
	label("VCR TAPE", bottomCenter, 1)

	local bottomRight = column("BottomRight", Vector2.new(1, 1), frame)
	label("VOL ||||.", bottomRight, 1)

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local colorCorrection = make("ColorCorrectionEffect", { Name = "VhsColor" }, Lighting)

	return {
		vignette = gradients,
		scanlines = scanlines,
		lines = {},
		frame = frame,
		recDot = recDot,
		timecode = timecode,
		labels = labels,
		colorCorrection = colorCorrection,
	}
end

local VhsOverlay = {}

function VhsOverlay.setBand(value: VisualConfig.Band)
	band = value
	refresh()
end

function VhsOverlay.setOptions(value: Options)
	local spacingChanged = value.scanlineSpacing ~= options.scanlineSpacing
	options = value
	local u = ui
	if u and spacingChanged then
		rebuildScanlines(u)
	else
		refresh()
	end
end

function VhsOverlay.start()
	local u = build()
	ui = u

	local resizePending = false
	local function onResize()
		resizePending = false
		rebuildScanlines(u)
		applyTextSize(u)
	end
	u.scanlines:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if not resizePending then
			resizePending = true
			task.delay(0.25, onResize)
		end
	end)
	onResize()

	local startClock = os.clock()
	local shownSeconds = -1
	local dotOn = true
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local seconds = math.floor(os.clock() - startClock)
		if seconds ~= shownSeconds then
			shownSeconds = seconds
			u.timecode.Text =
				string.format("%02d:%02d:%02d", seconds // 3600, seconds // 60 % 60, seconds % 60)
		end
		local on = not options.frameAnimated or elapsed % BLINK_SECONDS < BLINK_SECONDS / 2
		if on ~= dotOn then
			dotOn = on
			u.recDot.BackgroundTransparency = if on then 0 else 1
		end
	end)
end

return VhsOverlay
