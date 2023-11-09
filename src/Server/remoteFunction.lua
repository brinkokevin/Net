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

			local connection = InternalRemote.receive(id, function(player: Player, callbackId: string, ...)
				local event = { id, callbackId, callback(player, ...) }

				if _G.__DEV__ then
					if type(event[3]) ~= "boolean" then
						error("RemoteFunction " .. name .. " must return boolean for success as first argument")
					end
				end

				InternalRemote.send(player, event)
			end)

			return function()
				registeredCallbacks[name] = nil
				connection:Disconnect()
			end
		end,
	}
end

return remoteFunction
