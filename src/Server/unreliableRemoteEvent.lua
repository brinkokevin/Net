local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(script.Parent.Parent.Types)

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

local function getUnreliableRemote(name: string): UnreliableRemoteEvent
	local remote = ReplicatedStorage:FindFirstChild(name)
	if remote then
		return remote
	end

	remote = Instance.new("UnreliableRemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

local function unreliableRemoteEvent(name: string, config: Types.ServerConfig?)
	local remote = getUnreliableRemote(name)

	return {
		sendToPlayer = function(player: Player, ...)
			if _G.__DEV__ then
				assertPlayer(player)
			end

			remote:FireClient(player, ...)
		end,
		sendToPlayers = function(players: { Player }, ...)
			if _G.__DEV__ then
				assert(type(players) == "table", "Expected { Players }, received " .. typeof(players))

				for _, player in players do
					assertPlayer(player)
				end
			end

			for _, player in players do
				remote:FireClient(player, ...)
			end
		end,
		sendToAllPlayers = function(...)
			remote:FireAllClients(...)
		end,
		sendToAllPlayersExcept = function(excludedPlayer: Player, ...)
			if _G.__DEV__ then
				assertPlayer(excludedPlayer)
			end

			for _, player in playerList do
				if player ~= excludedPlayer then
					remote:FireClient(player, ...)
				end
			end
		end,
		onServerEvent = function(callback)
			if config and config.typecheck then
				return remote.OnServerEvent:Connect(function(player, ...)
					local success, message = config.typecheck(...)
					if success then
						callback(player, ...)
					elseif _G.__DEV__ then
						error(message)
					end
				end)
			else
				return remote.OnServerEvent:Connect(callback)
			end
		end,
	}
end

return unreliableRemoteEvent
