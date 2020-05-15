local ReplicatedStorage = game:GetService("ReplicatedStorage")
local displayBall = ReplicatedStorage:WaitForChild("DisplayBall")
local shootBalls = ReplicatedStorage:WaitForChild("ShootBalls")
local fireBalls = ReplicatedStorage:WaitForChild("FireBalls")
local moveInitialBall = ReplicatedStorage:WaitForChild("MoveInitialBall")
local removeBall = ReplicatedStorage:WaitForChild("RemoveBall")
local Grid = game.Workspace.Grid
local speed, delayBetweenShots = 150, 0.1
local PhysicsService = game:GetService("PhysicsService")

displayBall.OnServerEvent:Connect(function (player, displayIt, model, score)
	if displayIt then
		model.InitialBall.Transparency = 0
	else
		model.InitialBall.Transparency = 0.3
	end
end)

moveInitialBall.OnServerEvent:Connect(function (player, pos, model)
	model.InitialBall.CFrame = CFrame.new(pos)
end)

removeBall.OnServerEvent:Connect(function (player, theBall, model)
	theBall:Destroy()
	local anyBallsLeft = model:FindFirstChild("FiredBall")
	if not anyBallsLeft then
		print("None left!")
		removeBall:FireClient(player)
	end
end)

shootBalls.OnServerEvent:Connect(function (player, pos, noOfBalls, model)
	local allBalls = {}
	for i = 1, noOfBalls do
		local initialBall = model.InitialBall
		local firedBall = initialBall:Clone()
		firedBall.Parent = model
		firedBall.Name = "FiredBall"
		firedBall.CFrame = initialBall.CFrame
		firedBall.Transparency = 1
		firedBall.Material = "Neon"
		firedBall.CustomPhysicalProperties = PhysicalProperties.new(1, 0, 1, 0, 1)
		firedBall.Velocity = (pos - initialBall.CFrame.p).Unit*speed
		firedBall.Velocity = firedBall.Velocity - Vector3.new(0, firedBall.Velocity.y, 0)
		firedBall.Anchored, firedBall.CanCollide = true, false
--		firedBall:SetNetworkOwner(player)
--		PhysicsService:SetPartCollisionGroup(firedBall, "Balls")
--		wait(delayBetweenShots)
		table.insert(allBalls, firedBall) 
	end
	fireBalls:FireClient(player, allBalls)
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= player then
			fireBalls:FireClient(v, allBalls, true)
		end
	end
end)

fireBalls.OnServerEvent:Connect(function (player, allBalls, model)
	for i = 1, #allBalls do
		local firedBall = allBalls[i]
		--firedBall.Parent = model
		firedBall.Transparency = 0
		firedBall.Anchored, firedBall.CanCollide = false, true
		firedBall:SetNetworkOwner(player)
		PhysicsService:SetPartCollisionGroup(firedBall, "Balls")
		wait(delayBetweenShots)
	end
end)