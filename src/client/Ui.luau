--!strict
local Ui = {}

Ui.FONT = Enum.Font.RobotoMono
Ui.TEXT_COLOR = Color3.fromRGB(235, 235, 235)

function Ui.make(className: string, props: { [string]: any }, parent: Instance?): any
	local instance = Instance.new(className)
	for key, value in props do
		(instance :: any)[key] = value
	end
	instance.Parent = parent
	return instance
end

-- 44 px tall to meet the touch target in GDD 14
function Ui.button(text: string, parent: Instance, props: { [string]: any }): TextButton
	local merged: { [string]: any } = {
		Text = text,
		Size = UDim2.fromOffset(120, 44),
		BackgroundColor3 = Color3.fromRGB(55, 55, 55),
		TextColor3 = Ui.TEXT_COLOR,
		Font = Ui.FONT,
		TextSize = 18,
		BorderSizePixel = 0,
	}
	for key, value in props do
		merged[key] = value
	end
	return Ui.make("TextButton", merged, parent)
end

return Ui
