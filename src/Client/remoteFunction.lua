local Promise = require(script.Parent.Parent.Parent.Promise)

local createEventGetter = require(script.Parent.Parent.createEventGetter)
local getIdentifier = require(script.Parent.Parent.getIdentifier)

local InternalRemote = require(script.Parent)

local callbackIdentifierCount = 0
local function getCallbackIdentifier()
	local id = if callbackIdentifierCount <= 255
		then string.pack("B", callbackIdentifierCount)
		else string.pack("H", callbackIdentifierCount)

	callbackIdentifierCount += 1
	if callbackIdentifierCount == 65536 then
		callbackIdentifierCount = 0
	end

	return id
end

local function remoteFunction(name: string, config: createEventGetter.Config?)
	local id = getIdentifier(name)
	local getEvent = createEventGetter(id, config)

	return {
		callServerAsync = function(...)
			local callbackId = getCallbackIdentifier()

			InternalRemote.send(getEvent(callbackId, ...))

			return Promise.new(function(resolve, _reject, onCancel)
				local disconnect
				disconnect = InternalRemote.receive(id, function(responseCallbackId: string, ...)
					if responseCallbackId == callbackId then
						disconnect()
						resolve(...)
					end
				end)

				onCancel(disconnect)
			end):timeout(10)
		end,
	}
end

return remoteFunction
