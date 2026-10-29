--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local AccessibilitySettings = require(script.Parent.AccessibilitySettings)
local Consent = require(script.Parent.Consent)
local HorrorCamera = require(script.Parent.HorrorCamera)

type Option = { value: any, text: string }
type Row = { key: string, title: string, options: { Option } }

local TOGGLE_KEY = Enum.KeyCode.O
local TARGET = 48 -- px, above the 44 px minimum touch target
local PANEL_PADDING = 12
local TITLE_HEIGHT = 40

local ON_OFF: { Option } = {
	{ value = true, text = "Ligado" },
	{ value = false, text = "Desligado" },
}

local ROWS: { Row } = {
	{ key = "vhsFrame", title = "Moldura VHS", options = ON_OFF },
	{ key = "scanlines", title = "Linhas de varredura", options = ON_OFF },
	{ key = "vignette", title = "Vinheta", options = ON_OFF },
	{ key = "colorGrade", title = "Cor dessaturada", options = ON_OFF },
	{
		key = "blur",
		title = "Desfoque de câmera",
		options = {
			{ value = "full", text = "Normal" },
			{ value = "reduced", text = "Reduzido" },
			{ value = "off", text = "Desligado" },
		},
	},
	{ key = "reduceMotion", title = "Reduzir movimento", options = ON_OFF },
	{
		key = "brightness",
		title = "Brilho",
		options = {
			{ value = 0, text = "Padrão" },
			{ value = 0.25, text = "+25%" },
			{ value = 0.5, text = "+50%" },
			{ value = 0.75, text = "+75%" },
			{ value = 1, text = "+100%" },
		},
	},
	{
		key = "quality",
		title = "Qualidade gráfica",
		options = {
			{ value = "auto", text = "Automática" },
			{ value = "high", text = "Alta" },
			{ value = "medium", text = "Média" },
			{ value = "low", text = "Baixa" },
		},
	},
}

local gui = Instance.new("ScreenGui")
gui.Name = "SettingsMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 350 -- above the content notice, so the menu can be opened from it
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function styleButton(button: TextButton, text: string)
	button.Text = text
	button.AutoButtonColor = true
	button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.RobotoMono
	button.TextSize = 20
	button.TextColor3 = Color3.new(1, 1, 1)
end

-- With a keyboard the menu opens only by shortcut; touch devices have no key, so they get a button.
local openButton: TextButton? = nil
if not UserInputService.KeyboardEnabled then
	local button = Instance.new("TextButton")
	button.Name = "Open"
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.new(0.5, 0, 1, -28)
	button.Size = UDim2.fromOffset(160, 44)
	styleButton(button, "OPÇÕES")
	button.BackgroundTransparency = 0.4
	button.Parent = gui
	openButton = button
end

local panel = Instance.new("TextButton")
panel.Name = "Panel"
panel.Visible = false
panel.Text = ""
panel.AutoButtonColor = false
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.9, 0.85)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = gui

local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(440, 620)
limit.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, PANEL_PADDING)
padding.PaddingBottom = UDim.new(0, PANEL_PADDING)
padding.PaddingLeft = UDim.new(0, PANEL_PADDING)
padding.PaddingRight = UDim.new(0, PANEL_PADDING)
padding.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.BackgroundTransparency = 1
title.Font = Enum.Font.RobotoMono
title.TextSize = 24
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "Opções"
title.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Position = UDim2.fromOffset(0, TITLE_HEIGHT + 4)
list.Size = UDim2.new(1, 0, 1, -(TITLE_HEIGHT + TARGET + 12))
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.AnchorPoint = Vector2.new(0, 1)
closeButton.Position = UDim2.fromScale(0, 1)
closeButton.Size = UDim2.new(1, 0, 0, TARGET)
styleButton(closeButton, "Fechar")
closeButton.Parent = panel

local function refresh(row: Row, button: TextButton)
	local current = (AccessibilitySettings.get() :: any)[row.key]
	for _, option in row.options do
		if option.value == current then
			button.Text = `{row.title}: {option.text}`
			return
		end
	end
end

local rowButtons: { TextButton } = {}

for index, row in ROWS do
	local button = Instance.new("TextButton")
	button.Name = row.key
	button.LayoutOrder = index
	button.Size = UDim2.new(1, -8, 0, TARGET)
	styleButton(button, row.title)
	button.Parent = list
	table.insert(rowButtons, button)

	button.Activated:Connect(function()
		local current = (AccessibilitySettings.get() :: any)[row.key]
		local position = 1
		for optionIndex, option in row.options do
			if option.value == current then
				position = optionIndex
			end
		end
		AccessibilitySettings.set(row.key, row.options[position % #row.options + 1].value)
		for i, other in rowButtons do
			refresh(ROWS[i], other)
		end
	end)
end

local consentButton = Instance.new("TextButton")
consentButton.Name = "consent"
consentButton.LayoutOrder = #ROWS + 1
consentButton.Size = UDim2.new(1, -8, 0, TARGET)
styleButton(consentButton, Consent.label())
consentButton.Parent = list
consentButton.Activated:Connect(function()
	Consent.toggle()
	consentButton.Text = Consent.label()
end)

local SettingsMenu = {}

function SettingsMenu.open()
	for i, button in rowButtons do
		refresh(ROWS[i], button)
	end
	panel.Visible = true
	HorrorCamera.setCursorFree("settings", true)
end

function SettingsMenu.close()
	panel.Visible = false
	HorrorCamera.setCursorFree("settings", false)
end

function SettingsMenu.start()
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	if openButton then
		openButton.Activated:Connect(SettingsMenu.open)
	end
	closeButton.Activated:Connect(SettingsMenu.close)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.KeyCode ~= TOGGLE_KEY then
			return
		end
		if panel.Visible then
			SettingsMenu.close()
		else
			SettingsMenu.open()
		end
	end)
end

return SettingsMenu
