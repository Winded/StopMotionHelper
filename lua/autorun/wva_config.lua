
hook.Add("InitPostEntity","wvaConfig",function()
	RunConsoleCommand("jpeg_quality","100")
	RunConsoleCommand("lua_networkvar_bytespertick","1024")
	RunConsoleCommand("lua_networkvar_refreshtime","30")
end)