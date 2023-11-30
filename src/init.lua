return {
	Client = {
		remoteEvent = require(script.Client.remoteEvent),
		unreliableRemoteEvent = require(script.Client.unreliableRemoteEvent),
		remoteFunction = require(script.Client.remoteFunction),
	},
	Server = {
		remoteEvent = require(script.Server.remoteEvent),
		unreliableRemoteEvent = require(script.Server.unreliableRemoteEvent),
		remoteFunction = require(script.Server.remoteFunction),
	},
}
