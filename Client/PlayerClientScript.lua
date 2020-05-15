-- n = 1 is min side, n = 2 is max side
local Assets = {995908246, 315912428, 1734937282}
 
for _, asset in ipairs(Assets) do
     game:GetService("ContentProvider"):Preload("rbxassetid://" ..asset)
end

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local requestTurn = ReplicatedStorage:WaitForChild("RequestTurn")
local requestSetup = ReplicatedStorage:WaitForChild("RequestSetup")
local hpPositioner = ReplicatedStorage:WaitForChild("HoverPartPositioner")
local requestPlacePart = ReplicatedStorage:WaitForChild("RequestPlacePart")
local displayBall = ReplicatedStorage:WaitForChild("DisplayBall")
local shootBalls = ReplicatedStorage:WaitForChild("ShootBalls")
local fireBalls = ReplicatedStorage:WaitForChild("FireBalls")
local moveInitialBall = ReplicatedStorage:WaitForChild("MoveInitialBall")
local moveViewPart = ReplicatedStorage:WaitForChild("MoveViewPart")
local removeBall = ReplicatedStorage:WaitForChild("RemoveBall")
local destroyBlocks = ReplicatedStorage:WaitForChild("DestroyBlocks")
local requestReset = ReplicatedStorage:WaitForChild("RequestReset")
local readyToReset = ReplicatedStorage:WaitForChild("ReadyToReset")
local receivedObjValue = requestSetup.OnClientEvent:Wait()
script.PlayerStats.Value = receivedObjValue

local cam = game.Workspace.CurrentCamera
local stats, enemystats = script.PlayerStats.Value
local n = tonumber(stats.Name)
local currentScore = stats.Score
local currentTurn = game.Workspace.Turn
local Mainframe, Display = game.Workspace.Mainframe, game.Workspace.Display
local Grid = game.Workspace.Grid
local TeamColor, TheirTeamColor, ourStuff, theirStuff
local otherN

local mult
local mainGui = ReplicatedStorage.MainGui:Clone()
mainGui.Parent = player.PlayerGui

if n == 1 then --min side
	TeamColor, TheirTeamColor = Display.MinSc.Color, Display.MaxSc.Color
	ourStuff, theirStuff = game.Workspace.MinStuff, game.Workspace.MaxStuff
	otherN = 2
	mult = 1
else --max side
	TeamColor, TheirTeamColor = Display.MaxSc.Color, Display.MinSc.Color
	ourStuff, theirStuff = game.Workspace.MaxStuff, game.Workspace.MinStuff
	otherN = 1
	mult = -1
	
	--flip display signs
	local DisplayChild = Display:GetChildren()
	for i = 1, 3 do
		DisplayChild[i].Orientation = Vector3.new(0, 90, 0)
		DisplayChild[i].CFrame = DisplayChild[i].CFrame*CFrame.Angles(0, math.pi, 0)
	end
end

mainGui.Ours.BackgroundColor3 = TeamColor
mainGui.Theirs.BackgroundColor3 = TheirTeamColor


for i, v in ipairs(game.Workspace.Leaderboard:GetChildren()) do
	if tonumber(v.Name) ~= n then
		enemystats = v
	end
end
cam.CameraType = "Scriptable"
cam.FieldOfView = 20
cam.CFrame = CFrame.new(0, 300, 0)*CFrame.Angles(math.rad(-90), 0, n == 1 and math.rad(180) or 0)

--Setup Display------------------------
local turnGui = Instance.new("SurfaceGui", player.PlayerGui)
turnGui.Adornee = game.Workspace.Display.Turn
turnGui.Face = "Top"
turnGui.AlwaysOnTop = true

local yourScoreGui = turnGui:Clone()
yourScoreGui.Parent = player.PlayerGui
yourScoreGui.Adornee = n == 1 and game.Workspace.Display.MinSc or game.Workspace.Display.MaxSc

local theirScoreGui = turnGui:Clone()
theirScoreGui.Parent = player.PlayerGui
theirScoreGui.Adornee = n == 1 and game.Workspace.Display.MaxSc or game.Workspace.Display.MinSc

local textGui = Instance.new("TextLabel", turnGui)
textGui.Size = UDim2.new(1, 0, 1, 0)
textGui.TextScaled = true
textGui.BorderSizePixel = 0
textGui.BackgroundTransparency = 0
textGui.TextColor3 = Color3.new()

textGui:Clone().Parent = yourScoreGui
textGui:Clone().Parent = theirScoreGui

local displayK = {yourScoreGui, theirScoreGui} 

for i = 1, 2 do
	local hue = Color3.toHSV(displayK[i].Adornee.Color)
	displayK[i].TextLabel.BackgroundColor3 = Color3.fromHSV(hue, 0.5, 1)
end
---------------------------------------

GuiGrid = Grid:Clone()
GuiGrid.Parent = player.PlayerGui

local mouse = player:GetMouse()
local numberOfTurnsTaken = 0
local newRay = Ray.new
local clicks

local somepart = ourStuff.HoverPart --hoverPart
local buildHoverFunctionCon, buildClickFunctionCon
local shootHoverFunctionCon, shootClickFunctionCon
local hasShot = true

local timer1On, timer2On = false, false
local timer1Co, timer2Co

Timer1 = function ()
	if timer1On then
		mainGui.TopLabel.TextColor3 = Color3.new(1, 1, 1)
		for i = 20, 10, -1 do
			if timer1On then
				mainGui.TopLabel.Text = "0:" ..i
				wait(1)
			end
		end
	end
	--wait(1)
	for i = 9, 4, -1 do
		if timer1On then
			mainGui.TopLabel.Text = "0:0" ..i
			wait(1)
		end
	end
	if timer1On then
		mainGui.TopLabel.TextColor3 = Color3.new(1, 0, 0)
	end
	for i = 3, 1, -1 do
		if timer1On then
			mainGui.TopLabel.Text = "0:0" ..i
			wait(1)
		end
	end
	if timer1On then
		mainGui.TopLabel.Text = ""
		
		hasShot = true
		shootHoverFunctionCon:Disconnect()
		game.Workspace.ViewPart.Texture.Transparency = 1
		moveViewPart:FireServer(false)
		
		displayBall:FireServer(false, ourStuff)
		--Placing blocks-- --can place (number of turns taken) number of blocks--
		clicks = 0
		hpPositioner:FireServer(true, ourStuff, Vector3.new(0, 0, 5), currentScore, true)
		buildHoverFunctionCon = mouse.Move:Connect(buildHoverFunction)
		buildClickFunctionCon = mouse.Button1Down:Connect(buildClickFunction)
		timer2On = true
		timer2Co = coroutine.wrap(Timer2)()
		shootClickFunctionCon:Disconnect()
		
		timer1On = false
		timer1Co = nil
	end
end


Timer2 = function ()
	if timer2On then
		mainGui.TopLabel.TextColor3 = Color3.new(1, 1, 1)
		for i = 20, 10, -1 do
			if timer2On then
				mainGui.TopLabel.Text = "0:" ..i
				wait(1)
			end
		end
	end
	--wait(1)
	for i = 9, 4, -1 do
		if timer2On then
			mainGui.TopLabel.Text = "0:0" ..i
			wait(1)
		end
	end
	if timer2On then
		mainGui.TopLabel.TextColor3 = Color3.new(1, 0, 0)
	end
	for i = 3, 1, -1 do
		if timer2On then
			mainGui.TopLabel.Text = "0:0" ..i
			wait(1)
		end
	end
	if timer2On then
		mainGui.TopLabel.Text = ""
		buildClickFunctionCon:Disconnect()
		buildHoverFunctionCon:Disconnect()
		hpPositioner:FireServer(false, ourStuff)
	
		requestTurn:FireServer(player)
		
		timer2On = false
		timer2Co = nil
	end
end

shootClickFunction = function ()
	if not hasShot then		
		hasShot = true
		
		timer1On = false
		timer1Co = nil
		mainGui.TopLabel.Text = ""
		
		shootHoverFunctionCon:Disconnect()
		game.Workspace.ViewPart.Texture.Transparency = 1
		moveViewPart:FireServer(false)
		
		local currentRay = newRay(cam.CFrame.p, mouse.Hit.lookVector*1000)
		local boardHit, pos = game.Workspace:FindPartOnRayWithWhitelist(currentRay, {Mainframe})
		local x, z = pos.X, pos.Z
		--print(x, z)
		local checkVector = Vector3.new(x, 0, z) - ourStuff.InitialBall.Position
		if math.acos(Vector3.new(0, 0, mult*1):Dot(checkVector)/checkVector.magnitude) > math.rad(85) then
			x, z = ourStuff.InitialBall.Position.X + math.sign(x)*checkVector.magnitude*math.sin(math.rad(85)), ourStuff.InitialBall.Position.Z + mult*checkVector.magnitude*math.cos(math.rad(85))
		end
		
		local sentPosition = Vector3.new(x, 0, z)
		shootBalls:FireServer(sentPosition, currentScore.Value + math.floor(numberOfTurnsTaken/2), ourStuff) --5 balls, change the 5(s) to currentScore.Value
		
		removeBall.OnClientEvent:Wait() --wait for all balls to be removed
		print("None left local!")
		displayBall:FireServer(false, ourStuff)
		--Placing blocks-- --can place (number of turns taken) number of blocks--
		clicks = 0
		hpPositioner:FireServer(true, ourStuff, Vector3.new(0, 0, 5), currentScore, true)
		buildHoverFunctionCon = mouse.Move:Connect(buildHoverFunction)
		buildClickFunctionCon = mouse.Button1Down:Connect(buildClickFunction)
		timer2On = true
		timer2Co = coroutine.wrap(Timer2)()
		shootClickFunctionCon:Disconnect()
	end
end

local viewPart, iterC, CF = game.Workspace.ViewPart, 0, CFrame.new()

shootHoverFunction = function ()
	local currentRay = newRay(cam.CFrame.p, mouse.Hit.lookVector*1000)
	local boardHit, pos = game.Workspace:FindPartOnRayWithWhitelist(currentRay, {Mainframe})
	local x, z = pos.X, pos.Z
	
	local checkVector = Vector3.new(x, 0, z) - ourStuff.InitialBall.Position
	if math.acos(Vector3.new(0, 0, mult*1):Dot(checkVector)/checkVector.magnitude) > math.rad(85) then
		x, z = ourStuff.InitialBall.Position.X + math.sign(x)*checkVector.magnitude*math.sin(math.rad(85)), ourStuff.InitialBall.Position.Z + mult*checkVector.magnitude*math.cos(math.rad(85))
	end
	
	local size = Vector3.new(1, 1, (Vector3.new(x, 0, z) - ourStuff.InitialBall.Position).magnitude - 5)
	CF = CFrame.new((ourStuff.InitialBall.Position + Vector3.new(x, 0, z))/2, Vector3.new(x, 0, z))*CFrame.new(0, 0, 2.5)
	game.Workspace.ViewPart.Size = size
	--game.Workspace.ViewPart.CFrame = CF
	game.Workspace.ViewPart.Texture.Transparency = 0
	moveViewPart:FireServer(true, CF, size)
end

requestWin = function (thePlayer)
	timer1On, timer2On = false, false
	timer1Co, timer2Co = false, false
	clicks = 999
	
	if thePlayer == player then
		mainGui.TopLabel.Text = thePlayer.Name .." wins the game! Resetting..."
		mainGui.TopLabel.TextColor3 = TeamColor
		requestReset:FireServer(7)
	else
		mainGui.TopLabel.Text = thePlayer.Name .." beat you! Resetting..."
		mainGui.TopLabel.TextColor3 = TheirTeamColor
	end
end

requestReset.OnClientEvent:Connect(function ()
	turnGui:Destroy()
	theirScoreGui:Destroy()
	yourScoreGui:Destroy()
	mainGui:Destroy()
	GuiGrid:Destroy()
	
	game:GetService("StarterPlayer").StarterPlayerScripts.PlayerScript:Clone().Parent = script.Parent
	readyToReset:FireServer()
	script:Destroy()
end)

buildHoverFunction = function ()
	local currentRay = newRay(cam.CFrame.p, mouse.Hit.lookVector*1000)
	local boardHit, pos = game.Workspace:FindPartOnRayWithWhitelist(currentRay, {Mainframe.Board})
	local x, z = pos.X, pos.Z
	if boardHit ~= nil then
		x = math.floor((x+5)/10)*10
		z = math.floor(z/10)*10 + 5
		if math.abs(x) <= 30 and math.abs(z) <= 45 then
			somepart.CFrame = CFrame.new(Vector3.new(x, 0, z))
			--hpPositioner:FireServer(true, ourStuff, Vector3.new(x, 0, z), currentScore)
			--print(x, z)
		end
	end
	
	local posToSend, isThereABlockAdjacent = somepart.Position, false
		for i = -10, 10, 20 do
			if Grid:FindFirstChild(tostring(posToSend.X + i)) then
				if Grid[tostring(posToSend.X + i)][tostring(posToSend.Z)].Value ~= nil then
					if Grid[tostring(posToSend.X + i)][tostring(posToSend.Z)].Value.Parent == ourStuff then
						isThereABlockAdjacent = true
					end
				end
			end
		end
		for i = -10, 10, 20 do
			if Grid[tostring(posToSend.X)]:FindFirstChild(tostring(posToSend.Z + i)) then
				if Grid[tostring(posToSend.X)][tostring(posToSend.Z + i)].Value ~= nil then
					if Grid[tostring(posToSend.X)][tostring(posToSend.Z + i)].Value.Parent == ourStuff then
						isThereABlockAdjacent = true
					end
				end
			end
		end
	if isThereABlockAdjacent or math.floor(posToSend.Z) == mult*-45 then
		somepart.Transparency = 0
		if math.abs(x) <= 30 and math.abs(z) <= 45 then
			hpPositioner:FireServer(true, ourStuff, Vector3.new(x, 0, z), currentScore, true, 0)
		end
	else
		somepart.Transparency = 0.7
		if math.abs(x) <= 30 and math.abs(z) <= 45 then
			hpPositioner:FireServer(true, ourStuff, Vector3.new(x, 0, z), currentScore, true, 0.7)
		end
	end
end

buildClickFunction = function ()
	local noOfParts = 1 + math.floor(math.log(currentScore.Value)/math.log(2))
	if clicks + 1 <= noOfParts then --numberOfTurnsTaken then --3 clicks; change the 3 here and the 3 below to numberOfTurnsTaken
		local posToSend = somepart.Position
		if Grid[tostring(posToSend.X)][tostring(posToSend.Z)].Value == nil then
			local isThereABlockAdjacent = false
			for i = -10, 10, 20 do
				if Grid:FindFirstChild(tostring(posToSend.X + i)) then
					if Grid[tostring(posToSend.X + i)][tostring(posToSend.Z)].Value ~= nil then
						if Grid[tostring(posToSend.X + i)][tostring(posToSend.Z)].Value.Parent == ourStuff then
							isThereABlockAdjacent = true
						end
					end
				end
			end
			for i = -10, 10, 20 do
				if Grid[tostring(posToSend.X)]:FindFirstChild(tostring(posToSend.Z + i)) then
					if Grid[tostring(posToSend.X)][tostring(posToSend.Z + i)].Value ~= nil then
						if Grid[tostring(posToSend.X)][tostring(posToSend.Z + i)].Value.Parent == ourStuff then
							isThereABlockAdjacent = true
						end
					end
				end
			end
			if isThereABlockAdjacent or math.floor(posToSend.Z) == mult*-45 then
				requestPlacePart:FireServer(posToSend, ourStuff, currentScore) --! click again before part placed issue
				
				if posToSend.Z == mult*45 then
					requestWin(player)
					return
				end
				clicks = clicks + 1
			end
		end
		if clicks + 1 > noOfParts then --pass turn onto opposition
			timer2On = false
			timer2Co = nil
			mainGui.TopLabel.Text = ""
			buildClickFunctionCon:Disconnect()
			buildHoverFunctionCon:Disconnect()
			hpPositioner:FireServer(false, ourStuff)
			
--			displayBall:FireServer(true, ourStuff)
--			shootClickFunctionCon = mouse.Button1Down:Connect(shootClickFunction)
--			shootHoverFunctionCon = mouse.Move:Connect(shootHoverFunction)

			requestTurn:FireServer(player)
		end
	end
end

requestSetup:FireServer() --let server know you're ready

requestTurn.OnClientEvent:Connect(function () --shooting should come first, then building after
	print("My turn!")
	numberOfTurnsTaken = numberOfTurnsTaken + 1
	
--	--Placing blocks-- --can place (number of turns taken) number of blocks--
--	clicks = 0
--	hpPositioner:FireServer(true, ourStuff, Vector3.new(0, 0, 5), currentScore, true)
--	buildHoverFunctionCon = mouse.Move:Connect(buildHoverFunction)
--	buildClickFunctionCon = mouse.Button1Down:Connect(buildClickFunction)

	hasShot = false
	displayBall:FireServer(true, ourStuff)
	shootClickFunctionCon = mouse.Button1Down:Connect(shootClickFunction)
	shootHoverFunctionCon = mouse.Move:Connect(shootHoverFunction)
	
	timer1On = true
	timer1Co = coroutine.wrap(Timer1)()
end)

hpPositioner.OnClientEvent:Connect(function (model, pos)
	model.HoverPart.CFrame = CFrame.new(pos)
end)

requestPlacePart.OnClientEvent:Connect(function (defPart, pos, playerWhoSent)
	--print("Received request to place part.")
	local cloneBb = somepart.BillboardGui:Clone()
	cloneBb.Parent = GuiGrid[tostring(pos.X)][tostring(pos.Z)]
	cloneBb.Adornee = defPart
	cloneBb.Enabled = true
	if pos.Z == mult*-45 and playerWhoSent ~= player then
		requestWin(playerWhoSent)
	elseif pos.Z == mult*45 and playerWhoSent ~= player then
		defPart.CanCollide = true
	end
end)

function GridCell(x, z)
	return Grid[tostring(x)][tostring(z)].Value
end

function A_notIn_B(A, B)
	local bool = true
	for i, v in pairs(B) do
		if v == A then bool = false end
	end
	return bool
end

function ScanAdjacentCells(sourceBlock, removalList, removeBool) --removalList is a potential removal List
	--removalList[#removalList] will be the current block being scanned for adjacency
	--if removeBool is made false once, nothing will be removed and no more needs to be scanned
	local currentlyScanning = removalList[#removalList]
	local x, z = currentlyScanning.Position.X, currentlyScanning.Position.Z
	
	if z == mult*45 then return removalList, false end
	
	for i = -10, 10, 20 do --x adjacency scan
		if removeBool == true then
			if math.abs(x + i) <= 30 then
				local currentlySubscanning = GridCell(x + i, z)
				if currentlySubscanning then
					if currentlySubscanning.Parent == theirStuff then
						if A_notIn_B(currentlySubscanning, removalList) and currentlySubscanning ~= sourceBlock then
							table.insert(removalList, currentlySubscanning)
							removalList, removeBool = ScanAdjacentCells(sourceBlock, removalList, removeBool)
						end
					end
				end
			end
		end
	end
	
	for i = -10, 10, 20 do --z adjacency scan
		if removeBool == true then
			if math.abs(z + i) <= 45 then
				local currentlySubscanning = GridCell(x, z + i)
				if currentlySubscanning then
					if currentlySubscanning.Parent == theirStuff then
						if A_notIn_B(currentlySubscanning, removalList) and currentlySubscanning ~= sourceBlock then
							table.insert(removalList, currentlySubscanning)
							removalList, removeBool = ScanAdjacentCells(sourceBlock, removalList, removeBool)
						end
					end
				end
			end
		end
	end
	
	return removalList, removeBool
end

function TableConcat(t1,t2)
    for i = 1, #t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

rService = game:GetService("RunService")

function DestroyWithEffects(oppSide, blocksToRemove, wrapping, the_currentBlock)
	if wrapping == nil then
		local preventErrorTable = {}
		for i, v in pairs(blocksToRemove) do
			if A_notIn_B(v, preventErrorTable) then
				table.insert(preventErrorTable, v)
				coroutine.wrap(DestroyWithEffects)(oppSide, blocksToRemove, true, v)
				for i = 1, 6 do
					rService.RenderStepped:Wait()
				end
			end
		end
	else
		local cGui = GuiGrid[tostring(the_currentBlock.Position.X)][tostring(the_currentBlock.Position.Z)]
		cGui.BillboardGui.TextLabel.Name = "TLabel" --avoiding renderstep function from changing it
		local pEffect = ReplicatedStorage.ParticleEmitter:Clone()
		pEffect.Color = ColorSequence.new(oppSide == false and TheirTeamColor or TeamColor)
		pEffect.Parent = the_currentBlock
		cGui.BillboardGui.TLabel.TextColor3 = oppSide == false and TeamColor or TheirTeamColor
		cGui.BillboardGui.TLabel.Font = "SourceSansItalic"
		cGui.BillboardGui.TLabel.Text = "+1" --..cGui.BillboardGui.TLabel.Text
		
		local cll = ReplicatedStorage.ExplosionSound:Clone()
		cll.Parent = game.Workspace
		cll:Destroy()		
		
		for i = 1, 3 do
			the_currentBlock.Transparency = i/12
			rService.RenderStepped:Wait()
		end
		pEffect.Enabled = false
		for i = 4, 12 do
			the_currentBlock.Transparency = i/12
			rService.RenderStepped:Wait()
		end
		for i = 1, 102 do
			rService.RenderStepped:Wait()
		end
		if #cGui:GetChildren() > 0 then
			cGui:GetChildren()[1]:Destroy()
		end
		the_currentBlock:Destroy()
	end
end

changeScore = function (block) --block is the source block
	if block.Health.Value > 1 then --remove health points from block
		block.Health.Value = block.Health.Value - 1
		destroyBlocks:FireServer(false, block)
	else --remove block and non-supporting blocks
		block.CanCollide = false
		block.Name = "DefenseP" --prevents specific error
		local blocksToRemove = {block}
		local x, z = block.Position.X, block.Position.Z
		
		------------Determining blocks to remove------------
		for i = -10, 10, 20 do
			if math.abs(x + i) <= 30 then
				local currentlySubscanning = GridCell(x + i, z)
				if currentlySubscanning then
					if currentlySubscanning.Parent == theirStuff then
						local removalList, removeBool = ScanAdjacentCells(block, {currentlySubscanning}, true)
						if removeBool == true then
							blocksToRemove = TableConcat(blocksToRemove, removalList)
						end
					end
				end
			end
		end
		
		for i = -10, 10, 20 do
			if math.abs(z + i) <= 45 then
				local currentlySubscanning = GridCell(x, z + i)
				if currentlySubscanning then
					if currentlySubscanning.Parent == theirStuff then
						local removalList, removeBool = ScanAdjacentCells(block, {currentlySubscanning}, true)
						if removeBool == true then
							blocksToRemove = TableConcat(blocksToRemove, removalList)
						end
					end
				end
			end
		end
		----------------------------------------------------
		
		--Handling of block removal below--
		
		destroyBlocks:FireServer(true, block, blocksToRemove, n)
		
		for i, v in pairs(blocksToRemove) do
			--1. destroy on grid & guiGrid; 2. destroy; 3. award points;
			Grid[tostring(v.Position.X)][tostring(v.Position.Z)].Value = nil
			--GuiGrid[tostring(v.Position.X)][tostring(v.Position.Z)]:ClearAllChildren(); now in destroyWithEffects function
			v.CanCollide = false
		end
		
		local justAvoidingError = {}
		for i, v in pairs(blocksToRemove) do
			if A_notIn_B(v, justAvoidingError) then
				table.insert(justAvoidingError, v)
				currentScore.Value = currentScore.Value + 1 --+ v.Health.Value
			end
		end
		
		DestroyWithEffects(false, blocksToRemove)
		--
	end
end

destroyBlocks.OnClientEvent:Connect(function (blocksToRemove)
	for i, v in pairs(blocksToRemove) do
		Grid[tostring(v.Position.X)][tostring(v.Position.Z)].Value = nil
		v.CanCollide = false
	end
	DestroyWithEffects(true, blocksToRemove)
end)

fireBalls.OnClientEvent:Connect(function (allBalls, oppn)
	if oppn == nil then
	local firstBallHitOurSide = false
	for i = 1, #allBalls do
		allBalls[i].Touched:Connect(
			function (hit)
				if hit.CanCollide == true or (hit.Material == Enum.Material.Concrete and hit.Name == "DefensePart") then
					
					if hit.Name == "Boundary" or hit.Name == "DefensePart" or hit.Name == tostring(otherN) or hit.Name == tostring(n) then
						local cll = ReplicatedStorage.PongSound:Clone()
						cll.Parent = game.Workspace
						cll:Destroy()
					end
					
					if hit.Name == "Boundary" or hit.Name == "DefensePart" or hit.Name == tostring(otherN) then
						--Prevent continuous bouncing--
						allBalls[i].Velocity = (allBalls[i].Velocity - Vector3.new(0, allBalls[i].Velocity.y, mult*1)).Unit*150
						-------------------------------
					elseif hit.Name == tostring(n) then
						if firstBallHitOurSide == false then
							firstBallHitOurSide = true
							ourStuff.InitialBall.CFrame = CFrame.new(Vector3.new(allBalls[i].Position.X, 0, mult*-48))
							moveInitialBall:FireServer(Vector3.new(allBalls[i].Position.X, 0, mult*-48), ourStuff)
						end
						removeBall:FireServer(allBalls[i], ourStuff)
						allBalls[i]:Destroy()
					end
					
					if hit.Name == "DefensePart" and hit.Parent ~= ourStuff then
						coroutine.wrap(changeScore)(hit)
					end
				end
			end
		)
	end
	--ready to fire!
	fireBalls:FireServer(allBalls, ourStuff)
	else
	
	for i = 1, #allBalls do
		allBalls[i].Touched:Connect(function (hit)
			if hit.Name == "Boundary" or hit.Name == "DefensePart" or hit.Name == tostring(otherN) or hit.Name == tostring(n) then
				local cll = ReplicatedStorage.PongSound:Clone()
				cll.Parent = game.Workspace
				cll:Destroy()
			end
		end)
	end
	
	end
end)

moveViewPart.OnClientEvent:Connect(function (Cfr, size)
	game.Workspace.ViewPart.Size = size
	--game.Workspace.ViewPart.CFrame = CF*CFrame.new(0, 0, -iterC)
	CF = Cfr
end)

game:GetService("RunService").RenderStepped:Connect(function ()
	--display--
	turnGui.TextLabel.Text = "Turn: " ..currentTurn.Value
	yourScoreGui.TextLabel.Text = "Your Score: " ..currentScore.Value .."\nBalls: " ..currentScore.Value + math.floor(numberOfTurnsTaken/2)
	theirScoreGui.TextLabel.Text = "Their Score: " ..enemystats.Score.Value .."\nBalls: " ..enemystats.Score.Value + math.floor(numberOfTurnsTaken/2)
	
	local howManyBlocksUs = 1 + math.floor(math.log(currentScore.Value)/math.log(2))
	local howManyBlocksThem = 1 + math.floor(math.log(enemystats.Score.Value)/math.log(2))
	local nextUs, nextThem = 2^howManyBlocksUs, 2^howManyBlocksThem
	
	mainGui.OurLabel.Text, mainGui.TheirLabel.Text = "x" ..howManyBlocksUs .." (Next: " ..nextUs .." pts)", "x" ..howManyBlocksThem .." (Next: " ..nextThem .." pts)"
	
	for x = -30, 30, 10 do
		for z = -45, 45, 10 do
			local currentIndexx = GuiGrid[tostring(x)][tostring(z)]:FindFirstChild("BillboardGui")
			if currentIndexx then
				if currentIndexx.Adornee ~= nil then
					if currentIndexx:FindFirstChild("TextLabel") then
						currentIndexx.TextLabel.Text = tostring(currentIndexx.Adornee.Health.Value)
					end
				end
			end
		end
	end
	
	iterC = iterC + 1
	if iterC < 10 then 
		viewPart.CFrame = CF*CFrame.new(0, 0, -0.5*iterC)
	else
		viewPart.CFrame = CF
		iterC = 0
	end
end)