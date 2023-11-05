local RunService = game:GetService("RunService")

local getSharedRemote = require(script.Parent.getSharedRemote)
local spawn = require(script.Parent.spawn)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (Player, ...any) -> ...any
type EventCalls = { [string]: { { any } } }

local outgoingMap = {} :: { [Player]: EventCalls }
local incomingMap = {} :: { [string]: { [Callback]: true } }

if RunService:IsServer() then
	RemoteEvent.OnServerEvent:Connect(function(player: Player, incomingCalls: EventCalls)
		debug.profilebegin("ServerRemote.Receive")

		for id, calls in incomingCalls do
			local callbacks = incomingMap[id]
			if callbacks then
				for _, args in calls do
					for callback in callbacks do
						spawn(callback, player, table.unpack(args))
					end
				end
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

local function send(player: Player, id: string, args: { any })
	local playerOutgoing = outgoingMap[player]
	if not playerOutgoing then
		outgoingMap[player] = {}
		playerOutgoing = outgoingMap[player]
	end

	local eventOutgoing = playerOutgoing[id]
	if not eventOutgoing then
		playerOutgoing[id] = {}
		eventOutgoing = playerOutgoing[id]
	end

	table.insert(eventOutgoing, args)
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
