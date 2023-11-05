local RunService = game:GetService("RunService")

local getSharedRemote = require(script.Parent.getSharedRemote)
local spawn = require(script.Parent.spawn)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (Player, ...any) -> ...any
type EventCalls = { { any } }

local outgoingMap = {} :: { [Player]: EventCalls }
local incomingMap = {} :: { [string]: { [Callback]: true } }

if RunService:IsServer() then
	local function spawnCallbacks(callbacks, player: Player, _id: string, ...)
		for callback in callbacks do
			spawn(callback, player, ...)
		end
	end

	RemoteEvent.OnServerEvent:Connect(function(player: Player, incomingCalls: EventCalls)
		debug.profilebegin("ServerRemote.Receive")

		for _, args in incomingCalls do
			local id = args[1]
			local callbacks = incomingMap[id]
			if callbacks then
				spawnCallbacks(callbacks, player, table.unpack(args))
			end
		end

		debug.profileend()
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("ServerRemote.Send")

		for player, playerOutgoing in outgoingMap do
			RemoteEvent:FireClient(player, playerOutgoing)
		end
		table.clear(outgoingMap)

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

local function send(player: Player, event: { any })
	if not outgoingMap[player] then
		outgoingMap[player] = {}
	end

	-- Tables are frozen in dev mode to throw errors on accidental mutation
	-- If you need to mutate a table send a deep copy instead or enable shouldCopyData remote in config
	if _G.__DEV__ then
		for _, value in event do
			if type(value) == "table" then
				deepFreeze(value)
			end
		end
	end

	table.insert(outgoingMap[player], event)
end

local function receive(id: string, callback: Callback)
	if incomingMap[id] then
		if incomingMap[id][callback] then
			error("Callback already registered for: " .. id)
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
