--[[
	VHSFilter (LocalScript) - versão sutil
	Filtro VHS discreto (estilo fita / PSX de terror):
	- Cor levemente dessaturada, contraste suave, bloom mínimo, névoa escura leve
	- Scanlines, ruído, banda de tracking e vinheta muito fracos, glitch raro
	- Indicador "REC" piscando (sem timecode)
	- Engrenagem no canto superior direito + tecla P abrem o menu de configurações
	- Menu: opção para ligar/desligar o filtro VHS (clique ou ENTER)

	O cursor só aparece enquanto o menu estiver aberto (o HorrorCamera lê o atributo
	"SettingsOpen" do jogador). Tudo é local (só o jogador vê). Ajuste no bloco CONFIG.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--------------------------------------------------------------------
-- CONFIGURAÇÃO (ajuste aqui)
--------------------------------------------------------------------
local CONFIG = {
	StartEnabled = true,       -- filtro ligado ao entrar

	-- Cor (bem leve)
	Saturation = -0.07,        -- 0 = normal, negativo = mais cinza
	Contrast = 0.03,
	Brightness = 0,
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
	ScanlineCount = 200,
	ScanlineTransparency = 0.97, -- 1 = invisível, menor = mais escuras
	ScanlineCrawl = 0.3,

	-- Ruído
	NoiseCount = 28,
	NoiseFPS = 10,
	NoiseMinTransparency = 0.93,
	NoiseMaxTransparency = 0.985,

	-- Vinheta (escurecer as bordas)
	VignetteStrength = 0.18,   -- 0 = nenhuma, 1 = bem forte
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
	ShowRec = true,
	TextBarCenter = 0.07,      -- centro vertical das barras (metade do BarHeight do HorrorCamera)

	-- Teclas
	MenuKey = Enum.KeyCode.P,       -- abre/fecha o menu de configurações
	ToggleVHSKey = Enum.KeyCode.Return, -- liga/desliga o VHS com o menu aberto
}

print("[VHSFilter] iniciado")

--------------------------------------------------------------------
-- 1) EFEITOS DE ILUMINAÇÃO
--------------------------------------------------------------------
-- guarda a névoa original para restaurar quando o filtro for desligado
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
cc.Brightness = CONFIG.Brightness
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

local function makeVignette(name, anchor, position, size, rotation)
	local f = newFrame(gui, name, {
		AnchorPoint = anchor,
		Position = position,
		Size = size,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0,
		ZIndex = 1,
	})
	local g = Instance.new("UIGradient")
	g.Rotation = rotation
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - CONFIG.VignetteStrength),
		NumberSequenceKeypoint.new(1, 1),
	})
	g.Parent = f
end

local vs = CONFIG.VignetteSize
makeVignette("VigTop", Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(1, vs), 90)
makeVignette("VigBottom", Vector2.new(0, 1), UDim2.fromScale(0, 1), UDim2.fromScale(1, vs), 270)
makeVignette("VigLeft", Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(vs, 1), 0)
makeVignette("VigRight", Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.fromScale(vs, 1), 180)

local N = CONFIG.ScanlineCount
local scan = newFrame(gui, "Scanlines", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 2,
})
for i = -1, N do
	newFrame(scan, "Line", {
		Position = UDim2.fromScale(0, i / N),
		Size = UDim2.new(1, 0, 0.5 / N, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = CONFIG.ScanlineTransparency,
	})
end

local band = newFrame(gui, "TrackingBand", {
	Size = UDim2.fromScale(1, CONFIG.BandHeight),
	Position = UDim2.fromScale(0, -CONFIG.BandHeight),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	ZIndex = 3,
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
	noise[i] = newFrame(gui, "Noise", {
		Size = UDim2.fromOffset(math.random(4, 14), math.random(1, 2)),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ZIndex = 4,
	})
end

local glitchBand = newFrame(gui, "GlitchBand", {
	Size = UDim2.fromScale(1, 0.03),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.94,
	Visible = false,
	ZIndex = 5,
})

--------------------------------------------------------------------
-- 3) INDICADOR REC (sem timecode) dentro das barras
--------------------------------------------------------------------
local textGui, recDot, recLabel
if CONFIG.ShowRec then
	textGui = Instance.new("ScreenGui")
	textGui.Name = "VHSText"
	textGui.ResetOnSpawn = false
	textGui.IgnoreGuiInset = true
	textGui.DisplayOrder = 110 -- acima do letterbox
	textGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	textGui.Parent = playerGui

	recLabel = Instance.new("TextLabel")
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

	recDot = Instance.new("Frame")
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
end

--------------------------------------------------------------------
-- 4) ENGRENAGEM + MENU DE CONFIGURAÇÕES
--------------------------------------------------------------------
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "VHSToggle"
toggleGui.ResetOnSpawn = false
toggleGui.IgnoreGuiInset = true
toggleGui.DisplayOrder = 120 -- acima de tudo
toggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
toggleGui.Parent = playerGui

local gearButton = Instance.new("TextButton")
gearButton.Name = "Gear"
gearButton.AnchorPoint = Vector2.new(1, 0.5)
gearButton.BackgroundTransparency = 1
gearButton.Text = ""
gearButton.AutoButtonColor = false
gearButton.Parent = toggleGui

local gearParts = {} -- partes brancas da engrenagem

-- dentes: 4 barras cruzadas (formam 8 dentes)
for i = 0, 3 do
	local tooth = Instance.new("Frame")
	tooth.Name = "Tooth"
	tooth.AnchorPoint = Vector2.new(0.5, 0.5)
	tooth.Position = UDim2.fromScale(0.5, 0.5)
	tooth.Size = UDim2.fromScale(0.2, 0.96)
	tooth.Rotation = i * 45
	tooth.BackgroundColor3 = Color3.new(1, 1, 1)
	tooth.BackgroundTransparency = 0.3
	tooth.BorderSizePixel = 0
	tooth.Active = false
	tooth.Parent = gearButton
	table.insert(gearParts, tooth)
end

local gearBody = Instance.new("Frame")
gearBody.Name = "Body"
gearBody.AnchorPoint = Vector2.new(0.5, 0.5)
gearBody.Position = UDim2.fromScale(0.5, 0.5)
gearBody.Size = UDim2.fromScale(0.64, 0.64)
gearBody.BackgroundColor3 = Color3.new(1, 1, 1)
gearBody.BackgroundTransparency = 0.3
gearBody.BorderSizePixel = 0
gearBody.Active = false
gearBody.Parent = gearButton
local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0.5, 0)
bodyCorner.Parent = gearBody
table.insert(gearParts, gearBody)

local gearHole = Instance.new("Frame")
gearHole.Name = "Hole"
gearHole.AnchorPoint = Vector2.new(0.5, 0.5)
gearHole.Position = UDim2.fromScale(0.5, 0.5)
gearHole.Size = UDim2.fromScale(0.26, 0.26)
gearHole.BackgroundColor3 = Color3.new(0, 0, 0)
gearHole.BorderSizePixel = 0
gearHole.Active = false
gearHole.Parent = gearButton
local holeCorner = Instance.new("UICorner")
holeCorner.CornerRadius = UDim.new(0.5, 0)
holeCorner.Parent = gearHole

-- painel do menu (centro da tela, escondido por padrão)
local menu = Instance.new("Frame")
menu.Name = "SettingsMenu"
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.fromScale(0.5, 0.5)
menu.Size = UDim2.fromOffset(300, 132)
menu.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
menu.BackgroundTransparency = 0.12
menu.BorderSizePixel = 0
menu.Active = true -- impede cliques de atravessarem o painel
menu.Visible = false
menu.Parent = toggleGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 6)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(110, 110, 110)
menuStroke.Transparency = 0.5
menuStroke.Thickness = 1
menuStroke.Parent = menu

local function makeMenuLabel(name, text, size, position, anchor, xAlign, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.AnchorPoint = anchor
	l.Position = position
	l.Size = UDim2.fromOffset(268, size + 6)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Code
	l.Text = text
	l.TextSize = size
	l.TextColor3 = color
	l.TextXAlignment = xAlign
	l.Active = false
	l.Parent = menu
	return l
end

makeMenuLabel("Title", "CONFIGURAÇÕES", 18, UDim2.fromOffset(16, 14), Vector2.new(0, 0),
	Enum.TextXAlignment.Left, Color3.fromRGB(230, 230, 230))
makeMenuLabel("VHSRow", "Filtro VHS", 16, UDim2.fromOffset(16, 62), Vector2.new(0, 0.5),
	Enum.TextXAlignment.Left, Color3.fromRGB(205, 205, 205))
makeMenuLabel("Hint", "P: fechar    ENTER: alternar VHS", 12, UDim2.fromOffset(16, 106), Vector2.new(0, 0),
	Enum.TextXAlignment.Left, Color3.fromRGB(125, 125, 125))

local vhsSwitch = Instance.new("TextButton")
vhsSwitch.Name = "VHSSwitch"
vhsSwitch.AnchorPoint = Vector2.new(1, 0.5)
vhsSwitch.Position = UDim2.fromOffset(284, 62)
vhsSwitch.Size = UDim2.fromOffset(72, 30)
vhsSwitch.AutoButtonColor = false
vhsSwitch.BorderSizePixel = 0
vhsSwitch.Font = Enum.Font.Code
vhsSwitch.TextSize = 16
vhsSwitch.Parent = menu
local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(0, 4)
switchCorner.Parent = vhsSwitch

-- posições/tamanhos conforme a tela
local function layout()
	local vy = camera.ViewportSize.Y
	local g = math.clamp(math.floor(vy * 0.04), 24, 44)
	local ts = math.clamp(math.floor(vy * 0.032), 14, 34)
	local margin = 16

	gearButton.Size = UDim2.fromOffset(g, g)
	gearButton.Position = UDim2.new(1, -margin, CONFIG.TextBarCenter, 0)

	if recLabel then
		recLabel.TextSize = ts
		local recRight = margin + g + 16
		recLabel.Position = UDim2.new(1, -recRight, CONFIG.TextBarCenter, 0)
		recDot.Size = UDim2.fromOffset(ts * 0.6, ts * 0.6)
		recDot.Position = UDim2.new(1, -(recRight + ts * 2.4), CONFIG.TextBarCenter, 0)
	end
end
layout()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

--------------------------------------------------------------------
-- 5) LIGAR/DESLIGAR VHS + ABRIR/FECHAR MENU
--------------------------------------------------------------------
local enabled = true
local menuOpen = false

local function applyEnabled(on)
	enabled = on

	cc.Enabled = on
	bloom.Enabled = on
	gui.Enabled = on
	if textGui then
		textGui.Enabled = on
	end

	if CONFIG.Fog then
		if on then
			Lighting.FogColor = CONFIG.FogColor
			Lighting.FogStart = CONFIG.FogStart
			Lighting.FogEnd = CONFIG.FogEnd
		else
			Lighting.FogColor = originalFog.Color
			Lighting.FogStart = originalFog.Start
			Lighting.FogEnd = originalFog.End
		end
	end

	vhsSwitch.Text = on and "ON" or "OFF"
	vhsSwitch.BackgroundColor3 = on and Color3.fromRGB(60, 95, 70) or Color3.fromRGB(55, 55, 58)
	vhsSwitch.TextColor3 = on and Color3.fromRGB(225, 240, 228) or Color3.fromRGB(150, 150, 150)
end

local function setMenuOpen(open)
	menuOpen = open
	menu.Visible = open
	player:SetAttribute("SettingsOpen", open) -- o HorrorCamera libera/trava o cursor com base nisso
	local transparency = open and 0 or 0.3
	for _, part in ipairs(gearParts) do
		part.BackgroundTransparency = transparency
	end
end

gearButton.Activated:Connect(function()
	setMenuOpen(not menuOpen)
end)

vhsSwitch.Activated:Connect(function()
	applyEnabled(not enabled)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == CONFIG.MenuKey then
		setMenuOpen(not menuOpen)
	elseif menuOpen and input.KeyCode == CONFIG.ToggleVHSKey then
		applyEnabled(not enabled)
	end
end)

player:SetAttribute("SettingsOpen", false)
applyEnabled(CONFIG.StartEnabled)

--------------------------------------------------------------------
-- 6) LOOP DE ANIMAÇÃO
--------------------------------------------------------------------
local startTime = os.clock()
local noiseTimer = 0
local glitchUntil = 0
local nextGlitch = os.clock() + CONFIG.GlitchMinGap + math.random() * (CONFIG.GlitchMaxGap - CONFIG.GlitchMinGap)
local bandY = -CONFIG.BandHeight

RunService.RenderStepped:Connect(function(dt)
	camera = workspace.CurrentCamera
	if not enabled then
		return
	end

	local now = os.clock()
	local t = now - startTime

	-- glitch raro e discreto
	local glitching = now < glitchUntil
	if not glitching and now >= nextGlitch then
		glitchUntil = now + CONFIG.GlitchDuration
		nextGlitch = glitchUntil + CONFIG.GlitchMinGap + math.random() * (CONFIG.GlitchMaxGap - CONFIG.GlitchMinGap)
		glitching = true
		glitchBand.Position = UDim2.fromScale(0, math.random() * 0.9)
		glitchBand.Size = UDim2.fromScale(1, 0.015 + math.random() * 0.025)
		glitchBand.BackgroundTransparency = 0.92 + math.random() * 0.05
	end
	glitchBand.Visible = glitching

	-- flicker de brilho (um pouco mais no glitch)
	local flicker = math.noise(t * 9, 0.5) * CONFIG.FlickerAmount
	if glitching then
		cc.Brightness = CONFIG.Brightness + 0.01 + flicker
		cc.Saturation = CONFIG.Saturation - 0.03
	else
		cc.Brightness = CONFIG.Brightness + flicker
		cc.Saturation = CONFIG.Saturation
	end

	-- scanlines andando devagar
	local crawl = (t * CONFIG.ScanlineCrawl) % 1
	scan.Position = UDim2.fromScale(0, crawl / N)

	-- banda de tracking descendo
	bandY = bandY + CONFIG.BandSpeed * dt
	if bandY > 1 then
		bandY = -CONFIG.BandHeight
	end
	band.Position = UDim2.fromScale(0, bandY)

	-- ruído em FPS reduzido
	noiseTimer = noiseTimer + dt
	if noiseTimer >= 1 / CONFIG.NoiseFPS then
		noiseTimer = 0
		local minT = CONFIG.NoiseMinTransparency
		if glitching then
			minT = minT - 0.04
		end
		for i = 1, #noise do
			local n = noise[i]
			if math.random() < 0.5 then
				n.Position = UDim2.fromScale(math.random(), math.random())
				n.BackgroundTransparency = minT + math.random() * (CONFIG.NoiseMaxTransparency - minT)
			else
				n.BackgroundTransparency = 1
			end
		end
	end

	-- REC piscando
	if recDot then
		recDot.Visible = (math.floor(t / 0.8) % 2 == 0)
	end
end)
