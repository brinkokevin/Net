local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local myClientRemote = Net.Client.remoteEvent("MyRemote")

myClientRemote.onClientEvent(function(message)
	print(`Server: {message}`)
end)

myClientRemote.fire("Hello!")
