local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moveVP = ReplicatedStorage:WaitForChild("MoveViewPart")
viewPart = game.Workspace.ViewPart

moveVP.OnServerEvent:Connect(function (player, displayIt, CF, size)
	if displayIt == true then
		viewPart.Texture.Transparency = 0
		for i, v in ipairs(game.Players:GetPlayers()) do
			if v ~= player then
				moveVP:FireClient(v, CF, size)
			end
		end
	elseif displayIt == false then
		viewPart.Texture.Transparency = 1
	end
end)