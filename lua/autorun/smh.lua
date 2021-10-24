---
-- SMH Entry point.
---

if SERVER then
    AddCSLuaFile("smh.lua")
    include("smh/server.lua")
else
    include("smh/client.lua")
end
