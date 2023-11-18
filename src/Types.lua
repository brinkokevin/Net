export type Config = {
	shouldCopyData: boolean?,
}

export type ServerConfig = Config & {
	typecheck: (...any) -> (boolean, string?),
}

return {}
