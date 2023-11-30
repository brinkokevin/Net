local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(script.Parent.Parent.Types)

local function getUnreliableRemote(name: string): UnreliableRemoteEvent
	return ReplicatedStorage:WaitForChild(name) :: UnreliableRemoteEvent
end

local function unreliableRemoteEvent(name: string, config: Types.Config?)
	local remote = getUnreliableRemote(name)

	return {
		sendToServer = function(...)
			remote:FireServer(...)
		end,
		onClientEvent = function(callback)
			return remote.OnClientEvent:Connect(callback)
		end,
	}
end

return unreliableRemoteEvent
