local lb = game.Workspace.Leaderboard
local turn = game.Workspace.Turn
local Mainframe, Display = game.Workspace.Mainframe, game.Workspace.Display
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local requestTurn = ReplicatedStorage:WaitForChild("RequestTurn")
local requestSetup = ReplicatedStorage:WaitForChild("RequestSetup")
local requestReset = ReplicatedStorage:WaitForChild("RequestReset")
local readyToReset = ReplicatedStorage:WaitForChild("ReadyToReset")
local rng = Random.new()
local players = {}
local whoWentFirst
local PhysicsService = game:GetService("PhysicsService")
PhysicsService:CreateCollisionGroup("Balls")
PhysicsService:CollisionGroupSetCollidable("Balls", "Balls", false)

function Begin()
	local colorN = rng:NextNumber()
	local colorNcompliment = (colorN + 1/3) > 1 and (colorN - 1/3) or (colorN + 1/3)
	Mainframe.MinSide.Color = Color3.fromHSV(colorN, 1, 1)
	Display.MinSc.Color = Mainframe.MinSide.Color
	Mainframe.MaxSide.Color = Color3.fromHSV(colorNcompliment, 1, 1)
	Display.MaxSc.Color = Mainframe.MaxSide.Color
	
	local somepart = Instance.new("Part", game.Workspace.MinStuff)
	somepart.Anchored, somepart.Locked, somepart.CanCollide = true, true, false
	somepart.Size = Vector3.new(10, 10, 10)
	somepart.CFrame = CFrame.new(Vector3.new(0, 0, 5))
	somepart.Color = Mainframe.MinSide.Color
	somepart.Transparency = 1
	somepart.TopSurface, somepart.BottomSurface = 0, 0	
	somepart.Name = "HoverPart"	
	
	local surfGui = Instance.new("BillboardGui", somepart)
	surfGui.Size = UDim2.new(0, 50, 0, 50)
	surfGui.AlwaysOnTop = true
	surfGui.Adornee = somepart
	surfGui.Enabled = false
	
	local textGui = Instance.new("TextLabel", surfGui)
	textGui.Size = UDim2.new(1, 0, 1, 0)
	textGui.TextScaled = true
	textGui.BorderSizePixel = 0
	textGui.BackgroundTransparency = 1
	textGui.TextColor3 = Color3.new()
	textGui.TextStrokeColor3 = Color3.new(1,1,1)
	textGui.TextStrokeTransparency = 0
	textGui.Text = ""
	
	local somepart2 = somepart:Clone()
	somepart2.Parent = game.Workspace.MaxStuff
	somepart2.Color = Mainframe.MaxSide.Color
	somepart2.BillboardGui.Adornee = somepart2
	
	local initialBall = Instance.new("Part", game.Workspace.MinStuff)
	initialBall.Anchored, initialBall.Locked, initialBall.CanCollide = true, true, false
	initialBall.Size = Vector3.new(4, 4, 4)
	initialBall.CFrame = CFrame.new(Vector3.new(0, 0, -48))
	initialBall.Color = Color3.fromHSV(colorN, 0.3, 1)
	initialBall.Material = "Glass"
	initialBall.Transparency = 0.3
	initialBall.TopSurface, initialBall.BottomSurface = 0, 0
	initialBall.Name = "InitialBall"
	initialBall.Shape = 0
	
	local initialBall2 = initialBall:Clone()
	initialBall2.Parent = game.Workspace.MaxStuff
	initialBall2.CFrame = CFrame.new(Vector3.new(0, 0, 48))
	initialBall2.Color = Color3.fromHSV(colorNcompliment, 0.3, 1)
	
	
	for i = 1, 2 do
		requestSetup:FireClient(players[i], lb[tostring(i)])
	end
	--print("Done annoying bit.")
	for i = 1, 2 do
		requestSetup.OnServerEvent:Wait()
	end
	if whoWentFirst ~= nil then
		print("1")
		for i,v in pairs(game.Players:GetPlayers()) do
			if v ~= whoWentFirst then
				whoWentFirst = v
				break
			end
		end
	else
		print("2")
		whoWentFirst = players[rng:NextInteger(1, 2)]
	end
	--local whoWentFirst = rng:NextInteger(1, 2)
	requestTurn:FireClient(whoWentFirst)
	turn.Value = 1
	for i = 1, 2 do
		lb[tostring(i)].Score.Value = 1
	end
end

requestTurn.OnServerEvent:Connect(function (player)
	for i, v in ipairs(game.Players:GetPlayers()) do
		if v ~= player then
			requestTurn:FireClient(v)
			turn.Value = turn.Value + 1
		end
	end
end)

resetFunction = function (personWhoSent, howLong)
	if howLong ~= nil then
		wait(howLong); print("Waiting " ..howLong)
	end
	
--	for i, v in ipairs(game.Workspace.Display:GetChildren()) do
--		v.Orientation = Vector3.new(0, 90, 0)
--	end
	
	for i, v in ipairs(game.Players:GetPlayers()) do
		requestReset:FireClient(v)
	end
	
	for i = 1, #game.Players:GetPlayers() do
		readyToReset.OnServerEvent:Wait()
	end
	
	game.Workspace.MinStuff:ClearAllChildren()
	game.Workspace.MaxStuff:ClearAllChildren()
	game.Workspace.Leaderboard:ClearAllChildren()
	
	turn.Value = 0
	
	for x = -30, 30, 10 do
		for z = -45, 45, 10 do
			game.Workspace.Grid[tostring(x)][tostring(z)].Value = nil
		end
	end
	
	players = {}
	--whoWentFirst = nil
	
	for i, player in pairs(game.Players:GetPlayers()) do
		local objValue = Instance.new("ObjectValue", lb)
		local n = #lb:GetChildren()
		objValue.Name = n
		objValue.Value = player
		
		local intValue = Instance.new("IntValue", objValue)
		intValue.Name = "Score"
		intValue.Value = 0
		players[n] = player	
		
		if n == 2 then --change to n == 2
			Begin()
		end
	end
end

requestReset.OnServerEvent:Connect(resetFunction)

game.Players.PlayerAdded:Connect(function (player)
	local objValue = Instance.new("ObjectValue", lb)
	local n = #lb:GetChildren()
	objValue.Name = n
	objValue.Value = player
	
	local intValue = Instance.new("IntValue", objValue)
	intValue.Name = "Score"
	intValue.Value = 0
	players[n] = player	
	
	if n == 2 then --change to n == 2
		Begin()
	end
end)

game.Players.PlayerRemoving:Connect(function (player)
    resetFunction()
end)