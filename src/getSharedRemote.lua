local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function getSharedRemote(name: string)
	if RunService:IsServer() then
		local remoteEvent = ReplicatedStorage:FindFirstChild(name) :: RemoteEvent
		if not remoteEvent then
			remoteEvent = Instance.new("RemoteEvent") :: RemoteEvent
			remoteEvent.Name = name
			remoteEvent.Parent = ReplicatedStorage
		end
		return remoteEvent
	else
		local remoteEvent = ReplicatedStorage:WaitForChild(name, 60) :: RemoteEvent
		if not remoteEvent then
			error("NetRemoteEvent infinite yield, please report this to the developer")
		end
		return remoteEvent
	end
end

return getSharedRemote
