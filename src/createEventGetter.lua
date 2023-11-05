export type Config = {
	shouldCopyData: boolean?,
}

local function copyDeep(tbl)
	local copy = {}

	for key, value in tbl do
		if type(value) == "table" then
			copy[key] = copyDeep(value)
		else
			copy[key] = value
		end
	end

	return copy
end

local function createEventGetter(id: string, config: Config?)
	if config then
		return function(...)
			local event = { id, ... }

			if config then
				if config.shouldCopyData then
					for i = 2, #event do
						if type(event[i]) == "table" then
							event[i] = copyDeep(event[i])
						end
					end
				end
			end

			return event
		end
	else
		return function(...)
			return { id, ... }
		end
	end
end

return createEventGetter
