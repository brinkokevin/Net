local RunService = game:GetService("RunService")
local RemoteEvent = require(script.Parent.getSharedRemote)("RemoteEvent")

local identifierCount = 0

local function getIdentifier(name: string): string
	local id = RemoteEvent:GetAttribute(name)

	if RunService:IsServer() then
		if not id then
			id = if identifierCount <= 255 then string.pack("B", identifierCount) else string.pack("H", identifierCount)
			RemoteEvent:SetAttribute(name, id)
			identifierCount += 1
		end
	else
		while not id do
			id = RemoteEvent:GetAttribute(name)
			RemoteEvent.AttributeChanged:Wait()
		end
	end

	return id
end

return getIdentifier
