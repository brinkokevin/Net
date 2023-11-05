local Players = game:GetService("Players")

local InternalRemote = require(script.Parent)
local getIdentifier = require(script.Parent.Parent.getIdentifier)

-- unnecessary optimization? Let me know if you have any details on this.
local playerList = Players:GetPlayers()
Players.PlayerAdded:Connect(function()
	playerList = Players:GetPlayers()
end)
Players.PlayerRemoving:Connect(function()
	playerList = Players:GetPlayers()
end)

local function remoteEvent(name: string)
	local id = getIdentifier(name)

	return {
		fire = function(player: Player, ...)
			InternalRemote.send(player, id, { ... })
		end,
		fireAll = function(...)
			for _, player in playerList do
				InternalRemote.send(player, id, { ... })
			end
		end,
		onServerEvent = function(callback)
			return InternalRemote.receive(id, callback)
		end,
	}
end

return remoteEvent
