---
-- SMH Entry point.
---

function smhInclude(path)
	return include(path)
end

include("smh/bivalues/bivalues.lua");

if SERVER then
	AddCSLuaFile("smh.lua");
	include("smh/server.lua");
else
	include("smh/client.lua");
end