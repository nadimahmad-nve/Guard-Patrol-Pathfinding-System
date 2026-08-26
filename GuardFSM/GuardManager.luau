local Players = game:GetService("Players")
local StatesFolder = script.Parent:WaitForChild("States")

local GuardManager = {}
GuardManager.__index = GuardManager

function GuardManager.new(npc, nodes)
	local self = setmetatable({}, GuardManager)

	self.NPC = npc
	self.Humanoid = npc:WaitForChild("Humanoid")
	self.RootPart = npc:WaitForChild("HumanoidRootPart")
	self.Nodes = nodes

	self.TargetPlayer = nil
	self.CurrentState = nil
	self.States = {}

	-- Load all state modules dynamically
	for _, module in StatesFolder:GetChildren() do
		if module:IsA("ModuleScript") then
			local stateClass = require(module)
			local stateInstance = setmetatable({}, stateClass)
			stateInstance.Manager = self
			stateInstance.NPC = self.NPC
			stateInstance.Humanoid = self.Humanoid
			stateInstance.RootPart = self.RootPart

			self.States[module.Name] = stateInstance
		end
	end

	return self
end

function GuardManager:TransitionTo(stateName)
	local newState = self.States[stateName]
	if not newState then return end

	if self.CurrentState then
		self.CurrentState:Exit()
	end

	self.CurrentState = newState
	self.CurrentState:Enter()
end

function GuardManager:GetClosestVisiblePlayer()
	local MAX_DIST = 40 
	local closestPlayer = nil
	local closestDist = MAX_DIST

	for _, player in Players:GetPlayers() do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid").Health > 0 then
			local dist = (char.HumanoidRootPart.Position - self.RootPart.Position).Magnitude
			if dist < closestDist then
				closestPlayer = char
				closestDist = dist 
			end
		end 
	end 

	if closestPlayer then
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {self.NPC}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local rayDir = (closestPlayer.HumanoidRootPart.Position - self.RootPart.Position).Unit * MAX_DIST
		local result = workspace:Raycast(self.RootPart.Position, rayDir, rayParams)

		if result and result.Instance:IsDescendantOf(closestPlayer) then
			return closestPlayer 
		end
	end

	return nil 
end

return GuardManager