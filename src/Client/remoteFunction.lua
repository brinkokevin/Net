local InternalRemote = require(script.Parent)
local getIdentifier = require(script.Parent.Parent.getIdentifier)
local Promise = require(script.Parent.Parent.Parent.Promise)

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

local function remoteEvent(name: string)
	local id = getIdentifier(name)

	return {
		invoke = function(...)
			local callbackId = getCallbackIdentifier()
			local args = { callbackId, ... }

			return Promise.new(function(resolve, _reject, onCancel)
				local disconnect
				disconnect = InternalRemote.receive(id, function(responseCallbackId: string, ...)
					if responseCallbackId == callbackId then
						disconnect()
						resolve(...)
					end
				end)

				InternalRemote.send(id, args)

				onCancel(disconnect)
			end):timeout(10)
		end,
	}
end

return remoteEvent
