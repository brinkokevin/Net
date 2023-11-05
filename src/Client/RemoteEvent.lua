local InternalRemote = require(script.Parent)
local getIdentifier = require(script.Parent.Parent.getIdentifier)

local function remoteEvent(name: string)
	local id = getIdentifier(name)

	return {
		fire = function(...)
			InternalRemote.send(id, { ... })
		end,
		onClientEvent = function(callback)
			return InternalRemote.receive(id, callback)
		end,
	}
end

return remoteEvent
