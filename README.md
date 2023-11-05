# Net

Another net module

```lua
local Net = require(game.ReplicatedStorage.Packages.Net)

local myServerRemote = Net.Server.remoteEvent("MyRemote")

myServerRemote.onServerEvent(function(player, message)
    print(player, message)
end)

myServerRemote.fireAll("Hello World")
myServerRemote.fire(game.Players.brinkokevin, "Hello World")
```

```lua
local Net = require(game.ReplicatedStorage.Packages.Net)

local myClientRemote = Net.Client.remoteEvent("MyRemote")

myClientRemote.onClientEvent(function(message)
    print(message)
end)

myClientRemote.fire("Hello World")
```

## Install

```toml
Net = "brinkokevin/net@^0"
```
