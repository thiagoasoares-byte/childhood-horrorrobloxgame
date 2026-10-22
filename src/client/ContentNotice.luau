--!strict
local Players = game:GetService("Players")

local SettingsMenu = require(script.Parent.SettingsMenu)

local TARGET = 48 -- px, above the 44 px minimum touch target

local MESSAGE = "Childhood é um jogo de terror. Ele usa escuridão, ruído de vídeo, desfoque e "
	.. "variações de brilho que podem incomodar pessoas sensíveis à luz. Você pode reduzir ou "
	.. "desligar cada efeito em Opções, a qualquer momento (tecla O ou botão na tela)."

local ContentNotice = {}

local function text(parent: Instance, content: string, size: number, order: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Text = content
	label.LayoutOrder = order
	label.Size = UDim2.fromScale(1, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.RobotoMono
	label.TextSize = size
	label.TextWrapped = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = parent
	return label
end

local function button(parent: Instance, content: string, width: UDim): TextButton
	local result = Instance.new("TextButton")
	result.Text = content
	result.Size = UDim2.new(width.Scale, width.Offset, 0, TARGET)
	result.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	result.BorderSizePixel = 0
	result.Font = Enum.Font.RobotoMono
	result.TextSize = 20
	result.TextColor3 = Color3.new(1, 1, 1)
	result.Parent = parent
	return result
end

function ContentNotice.show()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ContentNotice"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 300

	-- Modal so the mouse is free to press the buttons even under first person lock.
	local backdrop = Instance.new("TextButton")
	backdrop.Modal = true
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	backdrop.BorderSizePixel = 0
	backdrop.Parent = gui

	local content = Instance.new("Frame")
	content.AnchorPoint = Vector2.new(0.5, 0.5)
	content.Position = UDim2.fromScale(0.5, 0.5)
	content.Size = UDim2.fromScale(0.9, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.Parent = backdrop

	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(520, math.huge)
	limit.Parent = content

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	text(content, "Aviso de conteúdo", 26, 1)
	text(content, MESSAGE, 20, 2)

	local buttons = Instance.new("Frame")
	buttons.LayoutOrder = 3
	buttons.Size = UDim2.new(1, 0, 0, TARGET)
	buttons.BackgroundTransparency = 1
	buttons.Parent = content

	local row = Instance.new("UIListLayout")
	row.FillDirection = Enum.FillDirection.Horizontal
	row.Padding = UDim.new(0, 8)
	row.Parent = buttons

	local proceed = button(buttons, "Continuar", UDim.new(0.5, -4))
	local settings = button(buttons, "Abrir opções", UDim.new(0.5, -4))

	proceed.Activated:Connect(function()
		gui:Destroy()
	end)
	settings.Activated:Connect(function()
		gui:Destroy()
		SettingsMenu.open()
	end)

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

return ContentNotice
