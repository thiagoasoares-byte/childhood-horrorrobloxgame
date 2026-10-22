--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Settings = require(ReplicatedStorage.Shared.Settings)
local Ui = require(script.Parent.Ui)

type Current = Settings.Settings

type Row = {
	label: string,
	toggle: boolean,
	format: (Current) -> string,
	change: (Current, number) -> Current,
}

local SEND_DELAY_SECONDS = 0.3
local OPEN_KEY = Enum.KeyCode.O
local STEP = 0.25

local QUALITY_LABELS: { [string]: string } = {
	Auto = "Automático",
	High = "Alto",
	Medium = "Médio",
	Low = "Baixo",
}
local BLUR_LABELS: { [string]: string } = {
	Normal = "Normal",
	Reduced = "Reduzido",
	Off = "Desligado",
}

local current: Current = Settings.defaults()
local listeners: { (Current) -> () } = {}
local refreshers: { () -> () } = {}
local sendToken = 0
local panel: TextButton? = nil

local function set(value: Current)
	current = value
	for _, listener in listeners do
		listener(value)
	end
	for _, refresh in refreshers do
		refresh()
	end

	-- a stepper held down must not flood the server, which rate limits anyway
	sendToken += 1
	local token = sendToken
	task.delay(SEND_DELAY_SECONDS, function()
		if token == sendToken then
			Remotes.SettingsChanged:FireServer(current)
		end
	end)
end

local function with(settings: Current, changes: { [string]: any }): Current
	local copy = table.clone(settings)
	for key, value in changes do
		(copy :: any)[key] = value
	end
	return copy
end

local function cycle<T>(list: { T }, value: T, direction: number): T
	local index = table.find(list, value) or 1
	return list[(index - 1 + direction) % #list + 1]
end

local function stepUnit(value: number, direction: number): number
	return math.clamp(math.floor(value / STEP + 0.5) * STEP + direction * STEP, 0, 1)
end

local function percent(value: number): string
	return string.format("%d%%", math.floor(value * 100 + 0.5))
end

local function boolRow(label: string, key: string): Row
	return {
		label = label,
		toggle = true,
		format = function(settings)
			return if (settings :: any)[key] then "Ligado" else "Desligado"
		end,
		change = function(settings)
			return with(settings, { [key] = not (settings :: any)[key] })
		end,
	}
end

local ROWS: { Row } = {
	{
		label = "Qualidade gráfica",
		toggle = false,
		format = function(settings)
			return QUALITY_LABELS[settings.quality]
		end,
		change = function(settings, direction)
			return with(
				settings,
				{ quality = cycle(Settings.QUALITIES, settings.quality, direction) }
			)
		end,
	},
	{
		label = "Desfoque de câmera",
		toggle = false,
		format = function(settings)
			return BLUR_LABELS[settings.blur]
		end,
		change = function(settings, direction)
			return with(settings, { blur = cycle(Settings.BLUR_MODES, settings.blur, direction) })
		end,
	},
	boolRow("Moldura VHS", "frame"),
	boolRow("Linhas de varredura", "scanlines"),
	{
		label = "Vinheta",
		toggle = false,
		format = function(settings)
			return percent(settings.vignette)
		end,
		change = function(settings, direction)
			return with(settings, { vignette = stepUnit(settings.vignette, direction) })
		end,
	},
	boolRow("Cor da fita (dessaturação)", "colorGrade"),
	boolRow("Reduzir movimento (REC fixo)", "reduceMotion"),
	{
		label = "Brilho",
		toggle = false,
		format = function(settings)
			return percent(settings.brightness)
		end,
		change = function(settings, direction)
			return with(settings, { brightness = stepUnit(settings.brightness, direction) })
		end,
	},
}

local function buildRow(row: Row, parent: Instance, order: number)
	local frame = Ui.make("Frame", {
		Size = UDim2.new(1, -8, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = order,
	}, parent)
	Ui.make("TextLabel", {
		Text = row.label,
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
		Font = Ui.FONT,
		TextColor3 = Ui.TEXT_COLOR,
		TextSize = 16,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local value: TextLabel | TextButton
	if row.toggle then
		local button = Ui.button("", frame, {
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
		})
		button.Activated:Connect(function()
			set(row.change(current, 1))
		end)
		value = button
	else
		local previous = Ui.button("<", frame, {
			Size = UDim2.fromOffset(44, 44),
			Position = UDim2.fromScale(0.5, 0),
		})
		local label = Ui.make("TextLabel", {
			Size = UDim2.new(0.5, -88, 1, 0),
			Position = UDim2.new(0.5, 44, 0, 0),
			BackgroundTransparency = 1,
			Font = Ui.FONT,
			TextColor3 = Ui.TEXT_COLOR,
			TextSize = 16,
		}, frame)
		local following = Ui.button(">", frame, {
			Size = UDim2.fromOffset(44, 44),
			Position = UDim2.new(1, -44, 0, 0),
		})
		previous.Activated:Connect(function()
			set(row.change(current, -1))
		end)
		following.Activated:Connect(function()
			set(row.change(current, 1))
		end)
		value = label
	end

	table.insert(refreshers, function()
		value.Text = row.format(current)
	end)
end

local AccessibilitySettings = {}

function AccessibilitySettings.get(): Current
	return current
end

function AccessibilitySettings.onChanged(listener: (Current) -> ())
	table.insert(listeners, listener)
end

function AccessibilitySettings.open()
	if panel then
		panel.Visible = true
	end
end

function AccessibilitySettings.close()
	if panel then
		panel.Visible = false
	end
end

local function toggle()
	if panel then
		panel.Visible = not panel.Visible
	end
end

function AccessibilitySettings.start()
	local gui = Ui.make("ScreenGui", {
		Name = "Options",
		ResetOnSpawn = false,
		DisplayOrder = 400,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)

	-- with the mouse locked in first person, the key is the only way to open it
	local hint = if UserInputService.KeyboardEnabled then " [O]" else ""
	Ui.button("OPÇÕES" .. hint, gui, {
		Name = "OpenButton",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.fromOffset(150, 44),
		BackgroundTransparency = 0.35,
	}).Activated
		:Connect(toggle)

	-- a visible Modal button is what unlocks the mouse in first person
	local backdrop = Ui.make("TextButton", {
		Name = "Panel",
		Text = "",
		AutoButtonColor = false,
		Modal = true,
		Visible = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, gui)
	panel = backdrop

	local card = Ui.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.92),
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel = 0,
	}, backdrop)
	Ui.make("UISizeConstraint", { MaxSize = Vector2.new(480, 560) }, card)
	Ui.make("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
	Ui.make("TextLabel", {
		Text = "Opções",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Font = Ui.FONT,
		TextColor3 = Ui.TEXT_COLOR,
		TextSize = 22,
	}, card)

	local list = Ui.make("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 48),
		Size = UDim2.new(1, -16, 1, -104),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, card)
	Ui.make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, list)
	for index, row in ROWS do
		buildRow(row, list, index)
	end

	Ui.button("Fechar", card, {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1, -16, 0, 44),
	}).Activated
		:Connect(AccessibilitySettings.close)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == OPEN_KEY then
			toggle()
		end
	end)

	for _, refresh in refreshers do
		refresh()
	end
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

return AccessibilitySettings
