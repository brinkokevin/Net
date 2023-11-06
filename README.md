# Net

Another net module

## API Reference

This section provides a detailed reference to the Net module's API.

### Remote Event

#### `Net.Server.remoteEvent(name: string, config: ConfigParams?)`

Gets the remote event with optional config.

- `name` (string): The name of the remote event.
- `config` (table, optional): A table with additional configuration options:
  - `shouldCopyData` (boolean, optional): If true, the data will be copied when firing the event.

## Usage

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

## DEV Mode

Enable by setting `_G.__DEV__ = true`.

When enabled, this mode enforces immutability by freezing tables; any attempts to alter them will result in errors. This helps catch and prevent issues related to unintended mutations.

Firing events with nested duplicate refences will throw an error. This can be useful to catch hidden bugs when relying on references. Sending references over the network will duplicate the data, which can lead to unexpected behavior.

If you still want to send duplicate data over the network, you can fire the events with deep copy of the table or enable the `shouldCopyData` config option.
