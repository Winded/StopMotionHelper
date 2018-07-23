
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

local function FindRecursive(name, path, func)
    local files, dirs = file.Find(name .. "/*", path);
    for _, dir in pairs(dirs) do
        FindRecursive(name .. "/" .. dir, path, func);
    end
    for _, f in pairs(files) do
        func(name .. "/" .. f);
    end
end

local function AddCSPath(path)
    if string.sub(path, -4) == ".lua" then
        AddCSLuaFile(path);
    end
end

FindRecursive("smh/shared", "LUA", AddCSPath);
FindRecursive("smh/client", "LUA", AddCSPath);
FindRecursive("smh/rxlua", "LUA", AddCSPath);
FindRecursive("smh/bivalues", "LUA", AddCSPath);

hook.Add("PlayerInitialSpawn", "SMHSetup", function(player)
    SMH.SetupData(player);
end);

Msg("SMH server initialized.\n");