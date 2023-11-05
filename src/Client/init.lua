local RunService = game:GetService("RunService")

local getSharedRemote = require(script.Parent.getSharedRemote)
local spawn = require(script.Parent.spawn)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (...any) -> ...any
type EventCalls = { [string]: { { any } } }

local outgoingMap = {} :: EventCalls
local incomingMap = {} :: { [string]: { [Callback]: true } }
local deferedCalls = {} :: {
	receiveTime: number,
	calls: EventCalls,
}

local function getName(id: string)
	for name, remoteId in RemoteEvent:GetAttributes() do
		if remoteId == id then
			return name
		end
	end

	return nil
end

if RunService:IsClient() then
	RemoteEvent.OnClientEvent:Connect(function(incomingCalls: EventCalls)
		debug.profilebegin("ClientRemote.Receive")

		for id, calls in incomingCalls do
			local callbacks = incomingMap[id]
			if callbacks then
				for _, args in calls do
					for callback in callbacks do
						spawn(callback, table.unpack(args))
					end
				end
			else
				if deferedCalls[id] then
					for _, args in calls do
						table.insert(deferedCalls[id].calls, args)
					end
				else
					deferedCalls[id] = {
						receiveTime = os.clock(),
						calls = calls,
					}
				end
			end
		end

		debug.profileend()
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("ClientRemote.Send")

		if next(outgoingMap) then
			RemoteEvent:FireServer(outgoingMap)
			table.clear(outgoingMap)
		end

		for id, defered in deferedCalls do
			local callbacks = incomingMap[id]
			if callbacks then
				for _, args in defered.calls do
					for callback in callbacks do
						spawn(callback, table.unpack(args))
					end
				end

				deferedCalls[id] = nil
			elseif os.clock() - defered.receiveTime > 30 then
				warn("RemoteEvent", getName(id) or id, "has no callback registered and has been dropped")
				deferedCalls[id] = nil
			end
		end

		debug.profileend()
	end)
end

local function send(id: string, args: { any })
	if not outgoingMap[id] then
		outgoingMap[id] = {}
	end

	table.insert(outgoingMap[id], args)
end

local function receive(id: string, callback: Callback)
	if incomingMap[id] then
		if incomingMap[id][callback] then
			error("This callback is already registered")
		end

		incomingMap[id][callback] = true
	else
		incomingMap[id] = { [callback] = true }
	end

	return function()
		incomingMap[id][callback] = nil
		if not next(incomingMap[id]) then
			incomingMap[id] = nil
		end
	end
end

return {
	send = send,
	receive = receive,
}
