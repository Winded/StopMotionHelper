
include("shared.lua");
include("server/easing.lua");
include("server/eyetarget.lua");
include("server/modifiers.lua");
include("server/playback.lua");

AddCSLuaFile("shared.lua");
AddCSLuaFile("shared/frames.lua");

AddCSLuaFile("client.lua");
AddCSLuaFile("client/entity_selection.lua");
AddCSLuaFile("client/entity_highlight.lua");
AddCSLuaFile("client/frame_panel.lua");
AddCSLuaFile("client/smh_menu.lua");
AddCSLuaFile("client/world_clicker.lua");
AddCSLuaFile("client/menu_setup.lua");

Msg("SMH server initialized.\n");