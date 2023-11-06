local getIdentifier = require(script.Parent.Parent.getIdentifier)
local createEventGetter = require(script.Parent.Parent.createEventGetter)

local InternalRemote = require(script.Parent)

local function remoteEvent(name: string, config: createEventGetter.Config?)
	local id = getIdentifier(name)
	local getEvent = createEventGetter(id, config)

	return {
		sendToServer = function(...)
			InternalRemote.send(getEvent(...))
		end,
		onClientEvent = function(callback)
			return InternalRemote.receive(id, callback)
		end,
	}
end

return remoteEvent
