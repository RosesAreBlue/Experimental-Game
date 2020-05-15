local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hpPos = ReplicatedStorage:WaitForChild("HoverPartPositioner")

hpPos.OnServerEvent:Connect(function (player, showHP, model, pos, score, changeTransparency, theTransparency)
	if showHP then
		if changeTransparency then
			--model.HoverPart.Transparency = 0
			if theTransparency ~= nil then
				model.HoverPart.Transparency = theTransparency
			else
				model.HoverPart.Transparency = 0
			end
		end
		model.HoverPart.BillboardGui.Enabled = true
		model.HoverPart.BillboardGui.TextLabel.Text = score.Value
		for i, v in ipairs(game.Players:GetPlayers()) do
			if v ~= player then
				hpPos:FireClient(v, model, pos)
			end
		end
	else
		model.HoverPart.Transparency = 1
		model.HoverPart.BillboardGui.Enabled = false
	end
end)