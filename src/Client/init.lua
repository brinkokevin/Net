local RunService = game:GetService("RunService")

local getSharedRemote = require(script.Parent.getSharedRemote)
local spawn = require(script.Parent.spawn)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (...any) -> ...any
type EventCalls = { { any } }

local outgoingEvents: EventCalls = {}
local incomingCallbacks: { [string]: { [Callback]: true } } = {}

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

local function spawnCallbacks(callbacks, _id: string, ...)
	for callback in callbacks do
		spawn(callback, ...)
	end
end

if RunService:IsClient() then
	RemoteEvent.OnClientEvent:Connect(function(incomingEvents: EventCalls)
		debug.profilebegin("ClientRemote.Receive")

		for _, event in incomingEvents do
			local id = event[1]
			local callbacks = incomingCallbacks[id]
			if callbacks then
				spawnCallbacks(callbacks, table.unpack(event))
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

local function deepFreeze(tbl)
	table.freeze(tbl)

	for _, value in tbl do
		if type(value) == "table" then
			deepFreeze(value)
		end
	end
end

local function send(event)
	-- Tables are frozen in dev mode to throw errors on accidental mutation
	-- If you need to mutate a table send a deep copy instead or enable shouldCopyData remote in config
	if _G.__DEV__ then
		for _, value in event do
			if type(value) == "table" then
				deepFreeze(value)
			end
		end
	end

	table.insert(outgoingEvents, event)
end

local function receive(id: string, callback: Callback)
	if incomingCallbacks[id] then
		if incomingCallbacks[id][callback] then
			error("This callback is already registered")
		end

		incomingCallbacks[id][callback] = true
	else
		incomingCallbacks[id] = { [callback] = true }
	end

	-- "Deferred events" refer to the events that the client receives prior to the registration of a callback.
	-- These events are not immediately invoked but are deferred to ensure that all other potential callbacks
	-- have an opportunity to register before these events are called.
	if deferedEvents[id] then
		local events = deferedEvents[id].events
		deferedEvents[id] = nil

		task.defer(function()
			for _, args in events do
				spawnCallbacks(incomingCallbacks[id], table.unpack(args))
			end
		end)
	end

	return function()
		incomingCallbacks[id][callback] = nil
		if not next(incomingCallbacks[id]) then
			incomingCallbacks[id] = nil
		end
	end
end

return {
	send = send,
	receive = receive,
}
