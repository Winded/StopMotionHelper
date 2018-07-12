
include("shared.lua");

include("server/data.lua");
include("server/easing.lua");
include("server/eyetarget.lua");
include("server/frames.lua");
include("server/ghosts.lua");
include("server/playback.lua");
include("server/positioning.lua");

AddCSLuaFile("shared.lua");
AddCSLuaFile("client.lua");

local path, files, dirs;

path = "smh/shared/";
files, dirs = file.Find(path .. "*.lua", "LUA");
for _, f in pairs(files) do
	AddCSLuaFile(path .. f);
end

path = "smh/client/";
files, dirs = file.Find(path .. "*.lua", "LUA");
for _, f in pairs(files) do
	AddCSLuaFile(path .. f);
end

hook.Add("PlayerInitialSpawn", "SMHSetup", function(player)
	SMH.SetupData(player);
end);

Msg("SMH server initialized.\n");