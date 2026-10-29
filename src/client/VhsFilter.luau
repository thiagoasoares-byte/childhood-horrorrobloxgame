--[[
	VhsFilter (módulo do cliente, script original do Nicolas) - versão sutil
	Filtro VHS discreto (estilo fita / PSX de terror):
	- Cor levemente dessaturada, contraste suave, bloom mínimo, névoa escura leve
	- Scanlines, ruído, banda de tracking e vinheta muito fracos, glitch raro
	- Indicador "REC" piscando dentro do letterbox (sem timecode)

	No Medo 0 o visual é o configurado abaixo. O Medo do servidor soma intensidade sobre essa base
	(setFear), e as opções de acessibilidade ligam e desligam cada camada. Tudo é local (só o
	jogador vê). Ajuste no bloco CONFIG.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--------------------------------------------------------------------
-- CONFIGURAÇÃO (ajuste aqui)
--------------------------------------------------------------------
local CONFIG = {
	-- Cor (bem leve)
	Saturation = -0.07, -- 0 = normal, negativo = mais cinza
	Contrast = 0.03,
	Tint = Color3.fromRGB(240, 246, 242), -- tom frio quase imperceptível
	BloomIntensity = 0.08,
	BloomSize = 16,
	BloomThreshold = 0.92,
	FlickerAmount = 0.003,

	-- Névoa suave. Se não gostar: Fog = false
	Fog = true,
	FogColor = Color3.fromRGB(14, 16, 18),
	FogStart = 40,
	FogEnd = 360,

	-- Scanlines
	ScanlineTransparency = 0.97, -- 1 = invisível, menor = mais escuras
	ScanlineCrawl = 0.3,

	-- Ruído
	NoiseCount = 28,
	NoiseMinTransparency = 0.93,
	NoiseMaxTransparency = 0.985,

	-- Vinheta (escurecer as bordas)
	VignetteStrength = 0.18, -- 0 = nenhuma, 1 = bem forte
	VignetteSize = 0.22,

	-- Banda de tracking (faixa clara que desce devagar)
	BandSpeed = 0.08,
	BandHeight = 0.14,
	BandTransparency = 0.985,

	-- Glitch ocasional
	GlitchMinGap = 12,
	GlitchMaxGap = 25,
	GlitchDuration = 0.1,

	-- Indicador REC dentro das barras do letterbox
	TextBarCenter = VisualConfig.LETTERBOX_HEIGHT / 2,
}

--------------------------------------------------------------------
-- 1) EFEITOS DE ILUMINAÇÃO
--------------------------------------------------------------------
-- guarda a névoa original para restaurar quando a cor for desligada
local originalFog = {
	Color = Lighting.FogColor,
	Start = Lighting.FogStart,
	End = Lighting.FogEnd,
}

local function getEffect(className, name)
	local e = Lighting:FindFirstChild(name)
	if not e then
		e = Instance.new(className)
		e.Name = name
		e.Parent = Lighting
	end
	return e
end

local cc = getEffect("ColorCorrectionEffect", "VHSColor")
cc.Saturation = CONFIG.Saturation
cc.Contrast = CONFIG.Contrast
cc.TintColor = CONFIG.Tint

local bloom = getEffect("BloomEffect", "VHSBloom")
bloom.Intensity = CONFIG.BloomIntensity
bloom.Size = CONFIG.BloomSize
bloom.Threshold = CONFIG.BloomThreshold

--------------------------------------------------------------------
-- 2) OVERLAY (scanlines, ruído, vinheta, banda, glitch)
--------------------------------------------------------------------
local function newFrame(parent, name, props)
	local f = Instance.new("Frame")
	f.Name = name
	f.BorderSizePixel = 0
	f.Active = false
	for k, v in pairs(props) do
		f[k] = v
	end
	f.Parent = parent
	return f
end

local gui = Instance.new("ScreenGui")
gui.Name = "VHSOverlay"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 90 -- abaixo do letterbox (100)
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local FULL = UDim2.fromScale(1, 1)

local vignette = newFrame(gui, "Vignette", { BackgroundTransparency = 1, Size = FULL, ZIndex = 1 })
local edges = {}

local function makeVignette(name, anchor, position, size, rotation)
	local f = newFrame(vignette, name, {
		AnchorPoint = anchor,
		Position = position,
		Size = size,
		BackgroundColor3 = Color3.new(0, 0, 0),
	})
	local g = Instance.new("UIGradient")
	g.Rotation = rotation
	g.Transparency = NumberSequence.new(0, 1)
	g.Parent = f
	table.insert(edges, f)
end

local vs = CONFIG.VignetteSize
makeVignette("VigTop", Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(1, vs), 90)
makeVignette("VigBottom", Vector2.new(0, 1), UDim2.fromScale(0, 1), UDim2.fromScale(1, vs), 270)
makeVignette("VigLeft", Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(vs, 1), 0)
makeVignette("VigRight", Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.fromScale(vs, 1), 180)

local scan = newFrame(gui, "Scanlines", { BackgroundTransparency = 1, Size = FULL, ZIndex = 2 })
local scanLines = {}
local scanlineCount = VisualConfig.QUALITY.high.scanlineCount

local function buildScanlines(count)
	scan:ClearAllChildren()
	scanLines = {}
	scanlineCount = count
	for i = -1, count do
		table.insert(
			scanLines,
			newFrame(scan, "Line", {
				Position = UDim2.fromScale(0, i / count),
				Size = UDim2.new(1, 0, 0.5 / count, 0),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = CONFIG.ScanlineTransparency,
			})
		)
	end
end
buildScanlines(scanlineCount)

-- ruído, banda de tracking e glitch ficam juntos para "Reduzir movimento" desligar de uma vez
local motionLayer = newFrame(gui, "Motion", { BackgroundTransparency = 1, Size = FULL, ZIndex = 3 })

local band = newFrame(motionLayer, "TrackingBand", {
	Size = UDim2.fromScale(1, CONFIG.BandHeight),
	Position = UDim2.fromScale(0, -CONFIG.BandHeight),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	ZIndex = 1,
})
local bandGradient = Instance.new("UIGradient")
bandGradient.Rotation = 90
bandGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, CONFIG.BandTransparency),
	NumberSequenceKeypoint.new(1, 1),
})
bandGradient.Parent = band

local noise = {}
for i = 1, CONFIG.NoiseCount do
	noise[i] = newFrame(motionLayer, "Noise", {
		Size = UDim2.fromOffset(math.random(4, 14), math.random(1, 2)),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
	})
end

local glitchBand = newFrame(motionLayer, "GlitchBand", {
	Size = UDim2.fromScale(1, 0.03),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.94,
	Visible = false,
	ZIndex = 3,
})

--------------------------------------------------------------------
-- 3) INDICADOR REC (sem timecode) dentro das barras
--------------------------------------------------------------------
local textGui = Instance.new("ScreenGui")
textGui.Name = "VHSText"
textGui.ResetOnSpawn = false
textGui.IgnoreGuiInset = true
textGui.DisplayOrder = 110 -- acima do letterbox
textGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
textGui.Parent = playerGui

local recLabel = Instance.new("TextLabel")
recLabel.Name = "Rec"
recLabel.AnchorPoint = Vector2.new(1, 0.5)
recLabel.Size = UDim2.fromOffset(120, 40)
recLabel.BackgroundTransparency = 1
recLabel.Font = Enum.Font.Arcade
recLabel.Text = "REC"
recLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
recLabel.TextTransparency = 0.25
recLabel.TextStrokeTransparency = 0.7
recLabel.TextXAlignment = Enum.TextXAlignment.Right
recLabel.Active = false
recLabel.Parent = textGui

local recDot = Instance.new("Frame")
recDot.Name = "RecDot"
recDot.AnchorPoint = Vector2.new(1, 0.5)
recDot.BackgroundColor3 = Color3.fromRGB(200, 35, 35)
recDot.BackgroundTransparency = 0.2
recDot.BorderSizePixel = 0
recDot.Active = false
recDot.Parent = textGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.5, 0)
corner.Parent = recDot

-- posições/tamanhos conforme a tela
local function layout()
	local ts = math.clamp(math.floor(camera.ViewportSize.Y * 0.032), 14, 34)
	local margin = 16
	recLabel.TextSize = ts
	recLabel.Position = UDim2.new(1, -margin, CONFIG.TextBarCenter, 0)
	recDot.Size = UDim2.fromOffset(ts * 0.6, ts * 0.6)
	recDot.Position = UDim2.new(1, -(margin + ts * 2.4), CONFIG.TextBarCenter, 0)
end
layout()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

--------------------------------------------------------------------
-- 4) ESTADO (Medo e opções de acessibilidade)
--------------------------------------------------------------------
local calm = VisualConfig.sampleFear(0)
local fearSaturation = 0 -- o que o Medo soma sobre a base de cada camada
local fearScanlines = 0
local fearVignette = 0
local gradeOn = true
local brightness = 0
local motionOn = true
local noiseFps = VisualConfig.QUALITY.high.noiseFps

local function applyScanlines()
	local transparency = 1 - math.clamp(1 - CONFIG.ScanlineTransparency + fearScanlines, 0, 1)
	for _, line in ipairs(scanLines) do
		line.BackgroundTransparency = transparency
	end
end

local function applyVignette()
	local transparency = 1 - math.clamp(CONFIG.VignetteStrength + fearVignette, 0, 1)
	for _, edge in ipairs(edges) do
		edge.BackgroundTransparency = transparency
	end
end

local function applyColor(flicker, glitching)
	local saturation = CONFIG.Saturation + fearSaturation
	if glitching then
		saturation -= 0.03
	end
	cc.Saturation = if gradeOn then saturation else 0
	cc.Brightness = brightness + (if gradeOn then flicker + (if glitching then 0.01 else 0) else 0)
end

local function applyFog(on)
	if not CONFIG.Fog then
		return
	end
	Lighting.FogColor = if on then CONFIG.FogColor else originalFog.Color
	Lighting.FogStart = if on then CONFIG.FogStart else originalFog.Start
	Lighting.FogEnd = if on then CONFIG.FogEnd else originalFog.End
end

applyFog(true)
applyScanlines()
applyVignette()
applyColor(0, false)

--------------------------------------------------------------------
-- 5) LOOP DE ANIMAÇÃO
--------------------------------------------------------------------
local startTime = os.clock()
local noiseTimer = 0
local glitchUntil = 0
local nextGlitch = os.clock()
	+ CONFIG.GlitchMinGap
	+ math.random() * (CONFIG.GlitchMaxGap - CONFIG.GlitchMinGap)
local bandY = -CONFIG.BandHeight

RunService.RenderStepped:Connect(function(dt)
	camera = workspace.CurrentCamera
	if not motionOn then
		return
	end

	local now = os.clock()
	local t = now - startTime

	-- glitch raro e discreto
	local glitching = now < glitchUntil
	if not glitching and now >= nextGlitch then
		glitchUntil = now + CONFIG.GlitchDuration
		nextGlitch = glitchUntil
			+ CONFIG.GlitchMinGap
			+ math.random() * (CONFIG.GlitchMaxGap - CONFIG.GlitchMinGap)
		glitching = true
		glitchBand.Position = UDim2.fromScale(0, math.random() * 0.9)
		glitchBand.Size = UDim2.fromScale(1, 0.015 + math.random() * 0.025)
		glitchBand.BackgroundTransparency = 0.92 + math.random() * 0.05
	end
	glitchBand.Visible = glitching

	-- flicker de brilho (um pouco mais no glitch)
	applyColor(math.noise(t * 9, 0.5) * CONFIG.FlickerAmount, glitching)

	-- scanlines andando devagar
	scan.Position = UDim2.fromScale(0, ((t * CONFIG.ScanlineCrawl) % 1) / scanlineCount)

	-- banda de tracking descendo
	bandY = bandY + CONFIG.BandSpeed * dt
	if bandY > 1 then
		bandY = -CONFIG.BandHeight
	end
	band.Position = UDim2.fromScale(0, bandY)

	-- ruído em FPS reduzido (zero no perfil Baixo)
	noiseTimer = noiseTimer + dt
	if noiseFps > 0 and noiseTimer >= 1 / noiseFps then
		noiseTimer = 0
		local minT = CONFIG.NoiseMinTransparency
		if glitching then
			minT = minT - 0.04
		end
		for i = 1, #noise do
			local n = noise[i]
			if math.random() < 0.5 then
				n.Position = UDim2.fromScale(math.random(), math.random())
				n.BackgroundTransparency = minT
					+ math.random() * (CONFIG.NoiseMaxTransparency - minT)
			else
				n.BackgroundTransparency = 1
			end
		end
	end

	-- REC piscando
	recDot.Visible = (math.floor(t / 0.8) % 2 == 0)
end)

--------------------------------------------------------------------
-- 6) API
--------------------------------------------------------------------
local VhsFilter = {}

-- Soma ao visual base a diferença entre o nível de Medo atual e a faixa calma (GDD 9.5).
function VhsFilter.setFear(sample)
	fearSaturation = sample.saturation - calm.saturation
	fearScanlines = sample.scanlines - calm.scanlines
	fearVignette = sample.vignette - calm.vignette
	applyScanlines()
	applyVignette()
	applyColor(0, false)
end

-- name: "frame" (REC), "scanlines" ou "vignette"
function VhsFilter.setLayerVisible(name, visible)
	if name == "frame" then
		textGui.Enabled = visible
	elseif name == "scanlines" then
		scan.Visible = visible
	elseif name == "vignette" then
		vignette.Visible = visible
	end
end

-- Cor, bloom e névoa; o brilho extra continua valendo com a cor desligada.
function VhsFilter.setGrade(enabled, extraBrightness)
	gradeOn = enabled
	brightness = extraBrightness
	cc.Contrast = if enabled then CONFIG.Contrast else 0
	cc.TintColor = if enabled then CONFIG.Tint else Color3.new(1, 1, 1)
	bloom.Enabled = enabled
	applyFog(enabled)
	applyColor(0, false)
end

-- Desliga ruído, banda, glitch, flicker, movimento das scanlines e a piscada do REC.
function VhsFilter.setMotion(enabled)
	motionOn = enabled
	motionLayer.Visible = enabled
	if not enabled then
		scan.Position = UDim2.new()
		recDot.Visible = true
		applyColor(0, false)
	end
end

function VhsFilter.setQuality(profile)
	noiseFps = profile.noiseFps
	if noiseFps == 0 then
		for _, n in ipairs(noise) do
			n.BackgroundTransparency = 1
		end
	end
	if profile.scanlineCount ~= scanlineCount then
		buildScanlines(profile.scanlineCount)
		applyScanlines()
	end
end

return VhsFilter
