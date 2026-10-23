--!strict
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local VIGNETTE_DEPTH = 0.35 -- fraction of the screen each edge gradient covers
local BLINK_HALF_PERIOD = 0.5 -- one full on/off cycle per second, below the 3 flashes per second limit
local MARGIN = 28

local gui = Instance.new("ScreenGui")
gui.Name = "VhsOverlay"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ScreenInsets = Enum.ScreenInsets.None
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function layer(name: string, zIndex: number, class: string): GuiObject
	local object = Instance.new(class) :: GuiObject
	object.Name = name
	object.ZIndex = zIndex
	object.Size = UDim2.fromScale(1, 1)
	object.BackgroundTransparency = 1
	object.BorderSizePixel = 0
	object.Parent = gui
	return object
end

local vignette = layer("Vignette", 1, "Frame")
local scanlines = layer("Scanlines", 2, "CanvasGroup") :: CanvasGroup
local frame = layer("Frame", 3, "Frame")

local edges: { Frame } = {}

local function addEdge(
	name: string,
	size: UDim2,
	position: UDim2,
	anchor: Vector2,
	rotation: number
)
	local edge = Instance.new("Frame")
	edge.Name = name
	edge.Size = size
	edge.Position = position
	edge.AnchorPoint = anchor
	edge.BackgroundColor3 = Color3.new(0, 0, 0)
	edge.BorderSizePixel = 0
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new(0, 1)
	gradient.Rotation = rotation
	gradient.Parent = edge
	edge.Parent = vignette
	table.insert(edges, edge)
end

local horizontal = UDim2.fromScale(1, VIGNETTE_DEPTH)
local vertical = UDim2.fromScale(VIGNETTE_DEPTH, 1)
addEdge("Top", horizontal, UDim2.fromScale(0, 0), Vector2.new(0, 0), 90)
addEdge("Bottom", horizontal, UDim2.fromScale(0, 1), Vector2.new(0, 1), -90)
addEdge("Left", vertical, UDim2.fromScale(0, 0), Vector2.new(0, 0), 0)
addEdge("Right", vertical, UDim2.fromScale(1, 0), Vector2.new(1, 0), 180)

local function buildScanlines(count: number)
	scanlines:ClearAllChildren()
	for i = 0, count - 1 do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 2)
		line.Position = UDim2.fromScale(0, i / count)
		line.BackgroundColor3 = Color3.new(0, 0, 0)
		line.BorderSizePixel = 0
		line.Parent = scanlines
	end
end

local scanlineCount = VisualConfig.QUALITY.high.scanlineCount
buildScanlines(scanlineCount)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, MARGIN)
padding.PaddingBottom = UDim.new(0, MARGIN)
padding.PaddingLeft = UDim.new(0, MARGIN)
padding.PaddingRight = UDim.new(0, MARGIN)
padding.Parent = frame

-- The top labels sit below the Roblox topbar, which would otherwise cover the one at the left.
local function updateTopMargin()
	padding.PaddingTop = UDim.new(0, math.max(MARGIN, GuiService.TopbarInset.Max.Y + 8))
end
updateTopMargin()
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(updateTopMargin)

local function label(name: string, text: string, anchor: Vector2, position: UDim2): TextLabel
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.Text = text
	textLabel.Size = UDim2.new()
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.AnchorPoint = anchor
	textLabel.Position = position
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.RobotoMono
	textLabel.TextSize = 24
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0.6
	textLabel.Parent = frame
	return textLabel
end

local recDot = Instance.new("Frame")
recDot.Name = "RecDot"
recDot.Size = UDim2.fromOffset(14, 14)
recDot.Position = UDim2.fromOffset(0, 6)
recDot.BackgroundColor3 = Color3.fromRGB(230, 40, 40)
recDot.BorderSizePixel = 0
recDot.Parent = frame
local recCorner = Instance.new("UICorner")
recCorner.CornerRadius = UDim.new(1, 0)
recCorner.Parent = recDot

label("Rec", "REC", Vector2.new(0, 0), UDim2.fromOffset(22, 0))
label("Play", "PLAY > SP", Vector2.new(1, 0), UDim2.fromScale(1, 0))
local timecode = label("Timecode", "00:00:00", Vector2.new(0, 1), UDim2.fromScale(0, 1))
label("Volume", "VOL [#####--]", Vector2.new(1, 1), UDim2.new(1, 0, 1, -30))
label("Tape", "VCR TAPE", Vector2.new(1, 1), UDim2.fromScale(1, 1))

gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local blinkEnabled = true

task.spawn(function()
	local startedAt = os.clock()
	local on = true
	while true do
		task.wait(BLINK_HALF_PERIOD)
		on = if blinkEnabled then not on else true
		recDot.BackgroundTransparency = if on then 0 else 1
		local elapsed = math.floor(os.clock() - startedAt)
		timecode.Text =
			string.format("%02d:%02d:%02d", elapsed // 3600, elapsed // 60 % 60, elapsed % 60)
	end
end)

local layers: { [string]: GuiObject } =
	{ frame = frame, scanlines = scanlines, vignette = vignette }

local VhsOverlay = {}

function VhsOverlay.setLayerVisible(name: string, visible: boolean)
	layers[name].Visible = visible
end

function VhsOverlay.setScanlineCount(count: number)
	if count ~= scanlineCount then
		scanlineCount = count
		buildScanlines(count)
	end
end

function VhsOverlay.setBlink(enabled: boolean)
	blinkEnabled = enabled
end

function VhsOverlay.setFear(sample: VisualConfig.FearSample)
	scanlines.GroupTransparency = 1 - sample.scanlines
	for _, edge in edges do
		edge.BackgroundTransparency = 1 - sample.vignette
	end
end

return VhsOverlay
