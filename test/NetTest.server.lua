local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local myServerRemote = Net.Server.remoteEvent("MyRemote")

myServerRemote.onServerEvent(function(player: Player, message)
	print(`{player.DisplayName}: {message}`)
end)

game.Players.PlayerAdded:Connect(function(player)
	myServerRemote.fire(player, "Hello from server!")
end)

task.wait(2)

myServerRemote.sendToAllPlayers("Hello from server to everyone!")
