local PathfindingService = game:GetService("PathfindingService")
local StateClass = require(script.Parent.Parent:WaitForChild("StateClass"))

local PatrolState = setmetatable({}, StateClass)
PatrolState.__index = PatrolState

function PatrolState:Enter()
	self.Nodes = self.Manager.Nodes
	self.CurrentNodeIndex = 1
	self.Active = true
	
	self.ScanConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local target = self.Manager:GetClosestVisiblePlayer()
		if target then
			self.Manager.TargetPlayer = target
			self.Manager:TransitionTo("ChaseState")
		end
	end)

	-- The Patrolling Loop
	self.PatrolThread = task.spawn(function()
		while self.Active do
			local path = PathfindingService:CreatePath()
			local success, _ = pcall(function()
				return path:ComputeAsync(self.RootPart.Position, self.Nodes[self.CurrentNodeIndex].Position)
			end)

			if success and path.Status == Enum.PathStatus.Success then
				for _, waypoint in path:GetWaypoints() do
					if not self.Active then return end 

					self.Humanoid:MoveTo(waypoint.Position)
					self.Humanoid.MoveToFinished:Wait()
				end 

				-- Cycle to next node
				self.CurrentNodeIndex += 1
				if self.CurrentNodeIndex > #self.Nodes then self.CurrentNodeIndex = 1 end 
			else
				task.wait(1) 
			end 
		end
	end)
end

function PatrolState:Exit()
	self.Active = false
	if self.ScanConnection then self.ScanConnection:Disconnect() end
	if self.PatrolThread and coroutine.running() ~= self.PatrolThread then 
		task.cancel(self.PatrolThread) 
	end
end

return PatrolState