--[[
	HorrorCamera (módulo do cliente, script original do Nicolas)
	- Letterbox preto (cima/baixo) estilo filme
	- Câmera 1ª pessoa PRÓPRIA (velocidade de giro controlada aqui), rebaixada, com balanço suave
	- Sway (inclinação) e motion blur sutil ao girar
	- Mira (bolinha) no centro da tela
	- Oculta a interface padrão do Roblox
	Suporta mouse, toque e controle (analógico direito).
	Menus liberam o cursor com setCursorFree; "Reduzir movimento" e o modo do blur vêm das configurações.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local VisualConfig = require(ReplicatedStorage.Shared.VisualConfig)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local reducedMotion = false
local blurScale = 1
local touchDelta = Vector2.zero
local freeOwners = {}

local HorrorCamera = {}

function HorrorCamera.setReducedMotion(enabled)
	reducedMotion = enabled
end

-- 1 = blur normal, 0 = desligado
function HorrorCamera.setBlurScale(scale)
	blurScale = scale
end

-- Menus e avisos seguram o cursor enquanto abertos; a câmera ignora o giro até todos soltarem.
function HorrorCamera.setCursorFree(owner, free)
	freeOwners[owner] = if free then true else nil
end

--------------------------------------------------------------------
-- CONFIGURAÇÃO (ajuste aqui)
--------------------------------------------------------------------
local CONFIG = {
	-- Letterbox
	BarHeight = VisualConfig.LETTERBOX_HEIGHT, -- fração da altura da tela por barra (0.119 = 11,9%)
	BarIntroTime = 2.5, -- segundos para as barras "fecharem" ao entrar

	-- Mira (bolinha central)
	CrosshairSize = 5, -- diâmetro em pixels
	CrosshairTransparency = 0.15, -- 0 = opaca, 1 = invisível

	-- VELOCIDADE DO GIRO DA CÂMERA  <<< mexa aqui para mais lento / mais rápido
	LookSpeedX = 0.12, -- graus por pixel do mouse na horizontal (padrão do Roblox ˜ 0.36)
	LookSpeedY = 0.09, -- graus por pixel do mouse na vertical   (padrão do Roblox ˜ 0.27)
	LookSmoothing = 18, -- suavização do giro (menor = mais "pesado"/macio; 60 = quase sem suavização)
	GamepadLookSpeed = 70, -- graus/s no analógico direito
	MaxPitch = 80, -- limite de olhar para cima/baixo (graus)

	-- Câmera (valores base para escala 1; são multiplicados pelo tamanho do personagem)
	CameraDrop = 0.75, -- studs que a câmera fica abaixo do padrão
	BobVerticalAmp = 0.07, -- amplitude do balanço vertical (studs)
	BobHorizontalAmp = 0.045, -- amplitude do balanço lateral (studs)
	BobRollAmp = 0.5, -- inclinação (roll) em graus durante a caminhada
	BobStepRate = 0.4, -- passos por stud percorrido (menor = balanço mais lento)
	BreathAmp = 0.012, -- respiração leve quando parado (studs)
	BreathRate = 0.9, -- velocidade da respiração (rad/s)
	BobBlendSpeed = 4, -- suavização ao começar/parar de andar (menor = mais suave)

	-- Motion blur
	BlurMax = 6, -- tamanho máximo do blur (sutil; 0-56)
	BlurThreshold = 35, -- graus/s mínimos de giro para começar a aplicar
	BlurFullAt = 220, -- graus/s em que o blur chega ao máximo
	BlurAttack = 14, -- velocidade com que o blur aparece
	BlurRelease = 7, -- velocidade com que o blur some

	-- Sway ao girar (câmera inclina para dentro da curva e volta devagar)
	SwayRollMax = 5, -- inclinação máxima em graus
	SwayRollPerDegSec = 0.03, -- graus de inclinação por (grau/s de giro)
	SwayAttack = 5, -- velocidade com que a inclinação entra
	SwayRelease = 3.5, -- velocidade com que volta ao normal (menor = mais "flutuante")
}

function HorrorCamera.start()
	print("[HorrorCamera] iniciado (câmera própria)")

	--------------------------------------------------------------------
	-- 1) OCULTAR UI PADRÃO DO ROBLOX
	--------------------------------------------------------------------
	task.spawn(function()
		-- O CoreGui pode não estar pronto de imediato; tenta algumas vezes.
		for _ = 1, 6 do
			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
			end)
			task.wait(1)
		end
	end)

	--------------------------------------------------------------------
	-- 2) LETTERBOX + MIRA
	--------------------------------------------------------------------
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "HorrorLetterbox"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 100
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local function makeBar(name, anchorY)
		local bar = Instance.new("Frame")
		bar.Name = name
		bar.AnchorPoint = Vector2.new(0, anchorY)
		bar.Position = UDim2.fromScale(0, anchorY)
		bar.Size = UDim2.fromScale(1, 0)
		bar.BackgroundColor3 = Color3.new(0, 0, 0)
		bar.BorderSizePixel = 0
		bar.Active = false
		bar.Parent = gui
		return bar
	end

	local topBar = makeBar("TopBar", 0)
	local bottomBar = makeBar("BottomBar", 1)

	local barTween =
		TweenInfo.new(CONFIG.BarIntroTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local barGoal = { Size = UDim2.fromScale(1, CONFIG.BarHeight) }
	TweenService:Create(topBar, barTween, barGoal):Play()
	TweenService:Create(bottomBar, barTween, barGoal):Play()

	local crosshair = Instance.new("Frame")
	crosshair.Name = "Crosshair"
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.fromScale(0.5, 0.5)
	crosshair.Size = UDim2.fromOffset(CONFIG.CrosshairSize, CONFIG.CrosshairSize)
	crosshair.BackgroundColor3 = Color3.new(1, 1, 1)
	crosshair.BackgroundTransparency = CONFIG.CrosshairTransparency
	crosshair.BorderSizePixel = 0
	crosshair.Active = false
	crosshair.ZIndex = 5
	crosshair.Parent = gui

	local crosshairCorner = Instance.new("UICorner")
	crosshairCorner.CornerRadius = UDim.new(0.5, 0)
	crosshairCorner.Parent = crosshair

	local crosshairStroke = Instance.new("UIStroke")
	crosshairStroke.Color = Color3.new(0, 0, 0)
	crosshairStroke.Thickness = 1
	crosshairStroke.Transparency = 0.5
	crosshairStroke.Parent = crosshair

	--------------------------------------------------------------------
	-- 3) PERSONAGEM / ESTADO DA CÂMERA
	--------------------------------------------------------------------
	player.CameraMode = Enum.CameraMode.LockFirstPerson

	local humanoid = nil
	local rootPart = nil
	local head = nil
	local heightScale = nil -- NumberValue "BodyHeightScale" (só existe em R15)
	local hiddenParts = {} -- cabeça e acessórios, escondidos na 1ª pessoa

	local yaw = 0
	local pitch = 0
	local prevYaw = 0
	local prevPitch = 0
	local smoothDelta = Vector2.zero
	local stick = Vector2.zero
	local menuWasOpen = false

	local phase = 0
	local intensity = 0
	local breathT = 0
	local bobRoll = 0
	local swayRoll = 0

	local function getScale()
		if not heightScale or not heightScale.Parent then
			heightScale = humanoid and humanoid:FindFirstChild("BodyHeightScale")
		end
		if heightScale then
			return heightScale.Value
		end
		return 1
	end

	-- Partes escondidas na 1ª pessoa: só cabeça e acessórios.
	-- Torso, braços e pernas continuam visíveis e animam junto com o personagem.
	local HIDE_NAMES = {
		Head = true,
	}

	local function considerPart(d)
		if
			d:IsA("BasePart") and (HIDE_NAMES[d.Name] or d:FindFirstAncestorOfClass("Accessory"))
		then
			table.insert(hiddenParts, d)
		end
	end

	local function onCharacter(char)
		local h = char:WaitForChild("Humanoid")
		local r = char:WaitForChild("HumanoidRootPart")
		local hd = char:WaitForChild("Head")

		h.AutoRotate = false -- o script gira o personagem junto com a câmera
		h.CameraOffset = Vector3.zero

		local look = r.CFrame.LookVector
		yaw = math.atan2(-look.X, -look.Z)
		pitch = 0
		prevYaw, prevPitch = yaw, pitch
		smoothDelta = Vector2.zero

		hiddenParts = {}
		for _, d in ipairs(char:GetDescendants()) do
			considerPart(d)
		end
		char.DescendantAdded:Connect(considerPart)

		heightScale = h:FindFirstChild("BodyHeightScale")
		humanoid, rootPart, head = h, r, hd
	end

	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
	player.CharacterAdded:Connect(onCharacter)

	UserInputService.TouchMoved:Connect(function(touch, processed)
		if not processed then
			touchDelta += Vector2.new(touch.Delta.X, touch.Delta.Y)
		end
	end)

	-- analógico direito do controle
	UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local p = Vector2.new(input.Position.X, input.Position.Y)
			if p.Magnitude < 0.15 then
				p = Vector2.zero
			end
			stick = p
		end
	end)

	--------------------------------------------------------------------
	-- 4) MOTION BLUR (efeito)
	--------------------------------------------------------------------
	local blur = Lighting:FindFirstChild("HorrorMotionBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "HorrorMotionBlur"
		blur.Size = 0
		blur.Parent = Lighting
	end

	--------------------------------------------------------------------
	-- 5) LOOP PRINCIPAL: giro + posição + bobbing + sway + blur
	--------------------------------------------------------------------
	RunService:BindToRenderStep("HorrorCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		dt = math.clamp(dt, 1 / 240, 0.1)
		camera = workspace.CurrentCamera

		if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
			return
		end

		-- Cursor livre só quando o menu do Roblox (Esc) ou o menu de configurações (tecla P) está aberto
		local freeCursor = GuiService.MenuIsOpen or next(freeOwners) ~= nil
		if freeCursor then
			menuWasOpen = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
		end

		if camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end

		-- GIRO (mouse + controle), com velocidade própria
		local raw = Vector2.zero
		if not freeCursor then
			raw = UserInputService:GetMouseDelta() + touchDelta
		end
		touchDelta = Vector2.zero
		if menuWasOpen then
			menuWasOpen = false
			raw = Vector2.zero -- descarta o pulo do mouse ao fechar o menu
		end
		smoothDelta = smoothDelta:Lerp(raw, 1 - math.exp(-dt * CONFIG.LookSmoothing))

		yaw = yaw - math.rad(smoothDelta.X * CONFIG.LookSpeedX)
		pitch = pitch - math.rad(smoothDelta.Y * CONFIG.LookSpeedY)
		yaw = yaw - math.rad(stick.X * CONFIG.GamepadLookSpeed * dt)
		pitch = pitch + math.rad(stick.Y * CONFIG.GamepadLookSpeed * 0.7 * dt)
		local maxPitch = math.rad(CONFIG.MaxPitch)
		pitch = math.clamp(pitch, -maxPitch, maxPitch)

		-- personagem olha para onde a câmera olha
		rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, yaw, 0)
		rootPart.AssemblyAngularVelocity = Vector3.zero

		for _, part in ipairs(hiddenParts) do
			part.LocalTransparencyModifier = 1
		end

		-- BOBBING
		local scale = getScale()
		local vel = rootPart.AssemblyLinearVelocity
		local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
		local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
		local moving = grounded and speed > 0.5

		local targetIntensity = 0
		if moving then
			targetIntensity = math.clamp(speed / math.max(humanoid.WalkSpeed, 1), 0, 1.25)
		end
		intensity = intensity
			+ (targetIntensity - intensity) * (1 - math.exp(-dt * CONFIG.BobBlendSpeed))

		if moving then
			phase = phase + speed * CONFIG.BobStepRate * dt / scale
		end
		breathT = breathT + dt * CONFIG.BreathRate

		local motion = if reducedMotion then 0 else 1
		local breath = math.sin(breathT) * CONFIG.BreathAmp * (1 - math.min(intensity, 1)) * motion
		local vertical = math.sin(phase * 2) * CONFIG.BobVerticalAmp * intensity * motion
		local horizontal = math.cos(phase) * CONFIG.BobHorizontalAmp * intensity * motion
		bobRoll = math.cos(phase) * CONFIG.BobRollAmp * intensity * motion

		local rootCF = CFrame.new(rootPart.Position) * CFrame.Angles(0, yaw, 0)
		local offset =
			Vector3.new(horizontal * scale, (-CONFIG.CameraDrop + vertical + breath) * scale, 0)
		local eye = head.Position + rootCF:VectorToWorldSpace(offset)

		-- SWAY + BLUR (a partir da velocidade de giro real)
		local dYaw = yaw - prevYaw
		local dPitch = pitch - prevPitch
		prevYaw, prevPitch = yaw, pitch

		local yawRate = math.deg(dYaw) / dt -- positivo = girando para a esquerda
		local angularSpeed = math.deg(math.sqrt((dYaw * math.cos(pitch)) ^ 2 + dPitch ^ 2)) / dt

		if angularSpeed > 1500 then -- ignora saltos bruscos (respawn/teleporte)
			angularSpeed = 0
			yawRate = 0
		end

		local targetSway = math.clamp(
			yawRate * CONFIG.SwayRollPerDegSec,
			-CONFIG.SwayRollMax,
			CONFIG.SwayRollMax
		) * motion
		local swayRate = CONFIG.SwayRelease
		if math.abs(targetSway) > math.abs(swayRoll) then
			swayRate = CONFIG.SwayAttack
		end
		swayRoll = swayRoll + (targetSway - swayRoll) * (1 - math.exp(-dt * swayRate))

		local t = (angularSpeed - CONFIG.BlurThreshold) / (CONFIG.BlurFullAt - CONFIG.BlurThreshold)
		local target = math.clamp(t, 0, 1) * CONFIG.BlurMax * blurScale
		local blurRate = CONFIG.BlurRelease
		if target > blur.Size then
			blurRate = CONFIG.BlurAttack
		end
		blur.Size = blur.Size + (target - blur.Size) * (1 - math.exp(-dt * blurRate))
		if blur.Size < 0.05 and target == 0 then
			blur.Size = 0
		end

		-- CÂMERA FINAL
		local base = CFrame.new(eye) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
		camera.CFrame = base * CFrame.Angles(0, 0, math.rad(bobRoll + swayRoll))
		camera.Focus = base * CFrame.new(0, 0, -5)
	end)
end

return HorrorCamera
