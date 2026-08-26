local PathfindingService = game:GetService("PathfindingService")
local StateClass = require(script.Parent.Parent:WaitForChild("StateClass"))

local ChaseState = setmetatable({}, StateClass)
ChaseState.__index = ChaseState

function ChaseState:Enter()
	self.Active = true
	self.Target = self.Manager.TargetPlayer

	self.ChaseThread = task.spawn(function()
		while self.Active do
			-- Verify the target is still valid and visible
			local isVisible = self.Manager:GetClosestVisiblePlayer()
			if not isVisible or not self.Target.Parent then
				self.Manager.TargetPlayer = nil
				self.Manager:TransitionTo("PatrolState")
				return
			end

			-- Recalculate path to their current position
			local path = PathfindingService:CreatePath()
			local success, _ = pcall(function()
				return path:ComputeAsync(self.RootPart.Position, self.Target.HumanoidRootPart.Position)
			end)

			if success and path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()

				local targetIndex = math.min(3, #waypoints)

				if targetIndex > 1 then
					self.Humanoid:MoveTo(waypoints[targetIndex].Position)
				end
			end	

			task.wait(0.1)
		end
	end)
end

function ChaseState:Exit()
	self.Active = false
	if self.ChaseThread and coroutine.running() ~= self.ChaseThread then 
		task.cancel(self.ChaseThread) 
	end
end

return ChaseState