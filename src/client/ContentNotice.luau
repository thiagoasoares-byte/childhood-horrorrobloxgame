--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Ui = require(script.Parent.Ui)

local acknowledged = false
local done = Instance.new("BindableEvent")

local ContentNotice = {}

function ContentNotice.isAcknowledged(): boolean
	return acknowledged
end

-- every scene waits on this before it starts
function ContentNotice.waitAcknowledged()
	if not acknowledged then
		done.Event:Wait()
	end
end

function ContentNotice.start(openOptions: () -> ())
	local gui = Ui.make("ScreenGui", {
		Name = "ContentNotice",
		ResetOnSpawn = false,
		DisplayOrder = 300,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, nil)

	-- a visible Modal button is what unlocks the mouse in first person
	local backdrop = Ui.make("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Modal = true,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
	}, gui)

	local card = Ui.make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel = 0,
	}, backdrop)
	Ui.make("UISizeConstraint", { MaxSize = Vector2.new(520, 10000) }, card)
	Ui.make("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
	Ui.make("UIPadding", {
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 16),
		PaddingBottom = UDim.new(0, 16),
	}, card)
	Ui.make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
	}, card)

	local function text(content: string, size: number, order: number)
		Ui.make("TextLabel", {
			Text = content,
			LayoutOrder = order,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Font = Ui.FONT,
			TextColor3 = Ui.TEXT_COLOR,
			TextSize = size,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, card)
	end

	local optionsHint = if UserInputService.KeyboardEnabled
		then "Você pode reduzir ou desligar cada efeito a qualquer momento em Opções (tecla O)."
		else "Você pode reduzir ou desligar cada efeito a qualquer momento em Opções."
	text("Aviso de fotossensibilidade", 22, 1)
	text(
		"Este jogo usa efeitos de fita VHS, escuridão e mudanças de luz que podem incomodar pessoas sensíveis a luzes piscantes ou a movimento. "
			.. optionsHint,
		16,
		2
	)

	Ui.button("Continuar", card, {
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 44),
	}).Activated
		:Connect(function()
			acknowledged = true
			gui:Destroy()
			done:Fire()
		end)
	Ui.button("Abrir opções", card, {
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 44),
	}).Activated
		:Connect(openOptions)

	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

return ContentNotice
