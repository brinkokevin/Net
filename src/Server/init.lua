local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Signal)
local getSharedRemote = require(script.Parent.getSharedRemote)

local RemoteEvent = getSharedRemote("RemoteEvent")

type Callback = (Player, ...any) -> ...any
type EventCalls = { { any } }

local outgoingMap = {} :: { [Player]: EventCalls }
local incomingMap = {} :: { [string]: Signal.Signal<Callback> }

if RunService:IsServer() then
	RemoteEvent.OnServerEvent:Connect(function(player: Player, incomingCalls: EventCalls)
		debug.profilebegin("ServerRemote.Receive")

		for _, args in incomingCalls do
			local id = args[1]
			local signal = incomingMap[id]

			if signal then
				signal:Fire(player, table.unpack(args, 2))
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

local function send(player: Player, event: { any })
	if not outgoingMap[player] then
		outgoingMap[player] = {}
	end

	table.insert(outgoingMap[player], event)
end

local function receive(id: string, callback)
	if not incomingMap[id] then
		incomingMap[id] = Signal.new()
	end

	return incomingMap[id]:Connect(callback)
end

return {
	send = send,
	receive = receive,
}
