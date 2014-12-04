---
-- SMH Entry point.
---

function Include(f)
      RunString(file.Read(f, "LUA"));
end

if SERVER then
      include("smh/server.lua");
else
      include("smh/client.lua");
end