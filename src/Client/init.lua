local RunService = game:GetService("RunService")

local getSharedRemote = require(script.Parent.getSharedRemote)
local Signal = require(script.Parent.Parent.Signal)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (...any) -> ...any
type EventCalls = { { any } }

local outgoingEvents: EventCalls = {}
local incomingCallbacks: { [string]: Signal.Signal<Callback> } = {}

local deferedEvents: {
	[string]: {
		receiveTime: number,
		events: { { any } },
	},
} = {}

local function getName(id: string)
	for name, remoteId in RemoteEvent:GetAttributes() do
		if remoteId == id then
			return name
		end
	end

	return nil
end

if RunService:IsClient() then
	RemoteEvent.OnClientEvent:Connect(function(incomingEvents: EventCalls)
		debug.profilebegin("ClientRemote.Receive")

		for _, event in incomingEvents do
			local id = event[1]
			local callbacks = incomingCallbacks[id]
			if callbacks then
				callbacks:Fire(table.unpack(event, 2))
			else
				if deferedEvents[id] then
					table.insert(deferedEvents[id].events, event)
				else
					deferedEvents[id] = {
						receiveTime = os.clock(),
						events = { event },
					}
				end
			end
		end

		debug.profileend()
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("ClientRemote.Send")

		if next(outgoingEvents) then
			RemoteEvent:FireServer(outgoingEvents)
			table.clear(outgoingEvents)
		end

		for id, defered in deferedEvents do
			if os.clock() - defered.receiveTime > 30 then
				warn("RemoteEvent", getName(id) or id, "has no callback registered and has been dropped")
				deferedEvents[id] = nil
			end
		end

		debug.profileend()
	end)
end

local function send(event)
	table.insert(outgoingEvents, event)
end

local function receive(id: string, callback: Callback)
	if not incomingCallbacks[id] then
		incomingCallbacks[id] = Signal.new()
	end

	local connection = incomingCallbacks[id]:Connect(callback)

	-- "Deferred events" refer to the events that the client receives prior to the registration of a callback.
	-- These events are not immediately invoked but are deferred to ensure that all other potential callbacks
	-- have an opportunity to register before these events are called.
	if deferedEvents[id] then
		local events = deferedEvents[id].events
		deferedEvents[id] = nil

		for _, args in events do
			incomingCallbacks[id]:FireDeferred(table.unpack(args, 2))
		end
	end

	return connection
end

return {
	send = send,
	receive = receive,
}
