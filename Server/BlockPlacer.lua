local ReplicatedStorage = game:GetService("ReplicatedStorage")
local placeP = ReplicatedStorage:WaitForChild("RequestPlacePart")
local Grid = game.Workspace.Grid

placeP.OnServerEvent:Connect(function (player, pos, model, score)
	local somepart = Instance.new("Part", model)
	somepart.Anchored, somepart.Locked, somepart.CanCollide = true, true, true
	somepart.Size = Vector3.new(10, 10, 10)
	somepart.Color = model.HoverPart.Color
	somepart.Transparency = 0
	somepart.TopSurface, somepart.BottomSurface = 0, 0	
	somepart.Name = "DefensePart"	
	somepart.CFrame = CFrame.new(pos)
	
	somepart.CustomPhysicalProperties = PhysicalProperties.new(1, 0, 1, 0, 1)	
	
	if math.abs(pos.Z) == 45 then
		somepart.Material = Enum.Material.Concrete
		somepart.CanCollide = false
		somepart.Transparency = 0.4
	end
	
	local cll = ReplicatedStorage.PlaceSound:Clone()
	cll.Parent = game.Workspace
	cll:Destroy()
	
	Grid[tostring(pos.X)][tostring(pos.Z)].Value = somepart
	local scoreVal = Instance.new("IntValue", somepart)
	scoreVal.Name = "Health"
	scoreVal.Value = score.Value
	
	for i, v in ipairs(game.Players:GetPlayers()) do
		placeP:FireClient(v, somepart, pos, player)
	end
end)