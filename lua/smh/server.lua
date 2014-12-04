
include("shared.lua");
include("smh/server/easing.lua");
include("smh/server/eyetarget.lua");
include("smh/server/modifiers.lua");

AddCSLuaFile("shared.lua");
AddCSLuaFile("smh/shared/frames.lua");

AddCSLuaFile("client.lua");
AddCSLuaFile("smh/client/entity_selection.lua");
AddCSLuaFile("smh/client/entity_highlight.lua");
AddCSLuaFile("smh/client/frame_panel.lua");
AddCSLuaFile("smh/client/smh_menu.lua");
AddCSLuaFile("smh/client/world_clicker.lua");
AddCSLuaFile("smh/client/menu.lua");

Msg("SMH server initialized.\n");