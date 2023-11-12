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

local function deepFreeze(tbl: { any })
	table.freeze(tbl)

	for _, value in tbl do
		if type(value) == "table" then
			deepFreeze(value)
		end
	end
end

local function checkDuplicateTables(tbl, seenTables)
	for _, value in tbl do
		if type(value) == "table" then
			if seenTables[value] then
				error(
					"Event contains a duplicate table. Use a deep copy or set 'shouldCopyData' to true in the config."
				)
			end

			seenTables[value] = true
			checkDuplicateTables(value, seenTables)
		end
	end
end

local function createEventGetter(id: string, config: Config?)
	local eventGetter
	if config then
		eventGetter = function(...): { [number]: any }
			local event = { id, ... }

			if config.shouldCopyData then
				for i = 2, #event do
					if type(event[i]) == "table" then
						event[i] = copyDeep(event[i])
					end
				end
			end

			return event
		end
	else
		eventGetter = function(...): { [number]: any }
			return { id, ... }
		end
	end

	if _G.__DEV__ then
		local originalEventGetter = eventGetter
		eventGetter = function(...)
			local event = originalEventGetter(...)

			-- Check for duplicate tables in event to prevent duplicate data sending on accident
			-- If you need to send duplicate data send a deep copy instead or enable shouldCopyData remote in config
			checkDuplicateTables(event, {})

			-- Tables are frozen in dev mode to throw errors on accidental mutation
			-- If you need to mutate a table send a deep copy instead or enable shouldCopyData remote in config
			deepFreeze(event)

			return event
		end
	end

	return eventGetter
end

return createEventGetter
