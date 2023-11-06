local getIdentifier = require(script.Parent.Parent.getIdentifier)

local InternalRemote = require(script.Parent)

local registeredCallbacks = {}

local function remoteFunction(name: string)
	local id = getIdentifier(name)

	return {
		setServerCallback = function(callback)
			if registeredCallbacks[name] then
				error("RemoteFunction " .. name .. " already has a callback registered")
			end
			registeredCallbacks[name] = true

			local disconnect = InternalRemote.receive(id, function(player: Player, callbackId: string, ...)
				InternalRemote.send(player, { id, callbackId, callback(player, ...) })
			end)

			return function()
				registeredCallbacks[name] = nil
				disconnect()
			end
		end,
	}
end

return remoteFunction
