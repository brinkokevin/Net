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

local function assertPlayer(player: Player)
	assert(typeof(player) == "Instance", "Expected Player, received " .. typeof(player))
	assert(player:IsA("Player"), "Expected Player, received " .. player.ClassName)
end

local function remoteEvent(name: string, config: createEventGetter.Config?)
	local id = getIdentifier(name)
	local getEvent = createEventGetter(id, config)

	return {
		sendToPlayer = function(player: Player, ...)
			if _G.__DEV__ then
				assertPlayer(player)
			end

			InternalRemote.send(player, getEvent(...))
		end,
		sendToPlayers = function(players: { Player }, ...)
			if _G.__DEV__ then
				assert(type(players) == "table", "Expected { Players }, received " .. typeof(players))

				for _, player in players do
					assertPlayer(player)
				end
			end

			local event = getEvent(...)

			for _, player in players do
				InternalRemote.send(player, event)
			end
		end,
		sendToAllPlayers = function(...)
			local event = getEvent(...)

			for _, player in playerList do
				InternalRemote.send(player, event)
			end
		end,
		sendToAllPlayersExcept = function(excludedPlayer: Player, ...)
			if _G.__DEV__ then
				assertPlayer(excludedPlayer)
			end

			local event = getEvent(...)

			for _, player in playerList do
				if player ~= excludedPlayer then
					InternalRemote.send(player, event)
				end
			end
		end,
		onServerEvent = function(callback)
			return InternalRemote.receive(id, callback)
		end,
	}
end

return remoteEvent
