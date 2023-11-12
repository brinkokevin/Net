local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function getSharedRemote(name: string): RemoteEvent
	if RunService:IsServer() then
		local remoteEvent = ReplicatedStorage:FindFirstChild(name)
		if not remoteEvent then
			remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = name
			remoteEvent.Parent = ReplicatedStorage
		end
		return remoteEvent
	else
		local remoteEvent = ReplicatedStorage:WaitForChild(name, 60)
		if not remoteEvent then
			error("NetRemoteEvent infinite yield, please report this to the developer")
		end
		return remoteEvent
	end
end

return getSharedRemote
