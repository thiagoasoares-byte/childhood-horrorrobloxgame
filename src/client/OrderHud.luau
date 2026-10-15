local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)

local OrderHud = {}

function OrderHud.start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "SaudadeOrderHud"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 101
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local panel = Instance.new("TextLabel")
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.fromScale(0.5, 0.05)
	panel.Size = UDim2.fromOffset(360, 62)
	panel.BackgroundColor3 = Color3.fromRGB(20, 18, 16)
	panel.BackgroundTransparency = 0.2
	panel.BorderSizePixel = 0
	panel.Font = Enum.Font.Code
	panel.TextSize = 15
	panel.TextColor3 = Color3.fromRGB(236, 226, 195)
	panel.TextWrapped = true
	panel.Text = "AGUARDANDO PEDIDO…"
	panel.Parent = gui

	local orderChanged = Remotes.waitForEvent("OrderUpdated")
	orderChanged.OnClientEvent:Connect(function(data)
		if not data.active then
			panel.Text = data.status
			return
		end
		local nextStep = data.nextStation or "novo pedido"
		panel.Text = string.format("PEDIDO %d: %s\n%s | Próximo: %s | %ds\n%s", data.number, data.name, data.ingredients, nextStep, data.secondsLeft, data.status)
	end)

	local nightSummary = Remotes.waitForEvent("NightSummary")
	nightSummary.OnClientEvent:Connect(function(data)
		panel.Size = UDim2.fromOffset(460, 100)
		panel.TextSize = 18
		panel.Text = string.format("FITA ENCONTRADA — NOITE %d\n%d pedidos concluídos\n%s", data.night, data.completedOrders, data.message)
	end)
end

return OrderHud
