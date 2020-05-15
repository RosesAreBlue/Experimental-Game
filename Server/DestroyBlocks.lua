local ReplicatedStorage = game:GetService("ReplicatedStorage")
local destroyBlocks = ReplicatedStorage:WaitForChild("DestroyBlocks")
local Grid = game.Workspace.Grid

function A_notIn_B(A, B)
	local bool = true
	for i, v in pairs(B) do
		if v == A then bool = false end
	end
	return bool
end

destroyBlocks.OnServerEvent:Connect(function (player, blockRemoval, block, blocksToRemove, n)
	if not blockRemoval then
		block.Health.Value = block.Health.Value - 1
	else --1. destroy on grid; 2. destroy; 3. award points
		for i, v in pairs(blocksToRemove) do
			Grid[tostring(v.Position.X)][tostring(v.Position.Z)].Value = nil
			v.CanCollide = false
		end
		
		for i, v in ipairs(game.Players:GetPlayers()) do
			if v ~= player then
				destroyBlocks:FireClient(v, blocksToRemove)
			end
		end
		
		local justAvoidingError, currentScore = {}, game.Workspace.Leaderboard[tostring(n)].Score
		for i, v in pairs(blocksToRemove) do
			if A_notIn_B(v, justAvoidingError) then
				table.insert(justAvoidingError, v)
				currentScore.Value = currentScore.Value + 1 --+ v.Health.Value
			end
		end
	end
end)