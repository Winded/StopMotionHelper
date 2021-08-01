include("shared.lua")

include("server/controller.lua")
include("server/easing.lua")
include("server/eyetarget.lua")
include("server/ghosts_manager.lua")
include("server/keyframe_data.lua")
include("server/keyframe_manager.lua")
include("server/modifiers.lua")
include("server/playback_manager.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("client.lua")

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

FindRecursive("smh/shared", "LUA", AddCSPath)
FindRecursive("smh/client", "LUA", AddCSPath)

Msg("SMH server initialized.\n")
