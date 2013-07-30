---
-- SMH Entry point.
---

if SERVER then
	include("smh/server.lua");
else
	include("smh/client.lua");
end