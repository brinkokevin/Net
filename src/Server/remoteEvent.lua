local Players = game:GetService("Players")

local InternalRemote = require(script.Parent)
local getIdentifier = require(script.Parent.Parent.getIdentifier)
local createEventGetter = require(script.Parent.Parent.createEventGetter)

-- unnecessary optimization? Let me know if you have any details on this.
local playerList = Players:GetPlayers()
Players.PlayerAdded:Connect(function()
	playerList = Players:GetPlayers()
end)
Players.PlayerRemoving:Connect(function()
	playerList = Players:GetPlayers()
end)

local function remoteEvent(name: string, config: createEventGetter.Config?)
	local id = getIdentifier(name)
	local getEvent = createEventGetter(id, config)

	return {
		fire = function(player: Player, ...)
			if _G.__DEV__ then
				assert(player:IsA("Player"), "Expected Player, received " .. typeof(player))
			end

			InternalRemote.send(player, getEvent(...))
		end,
		fireAll = function(...)
			local event = getEvent(...)

			for _, player in playerList do
				InternalRemote.send(player, event)
			end
		end,
		onServerEvent = function(callback)
			return InternalRemote.receive(id, callback)
		end,
	}
end

return remoteEvent
