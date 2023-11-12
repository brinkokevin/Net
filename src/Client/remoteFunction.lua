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

			return Promise.new(function(resolve, reject, onCancel)
				local connection
				connection = InternalRemote.receive(id, function(responseCallbackId: string, resolved: boolean, ...)
					if responseCallbackId == callbackId then
						connection:Disconnect()

						if resolved then
							resolve(...)
						else
							reject(...)
						end
					end
				end)

				onCancel(function()
					connection:Disconnect()
				end)
			end):timeout(10)
		end,
	}
end

return remoteFunction
