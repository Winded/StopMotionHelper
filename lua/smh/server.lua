
include("shared.lua");

include("server/data.lua");
include("server/easing.lua");
include("server/eyetarget.lua");
include("server/frames.lua");
include("server/modifiers.lua");
include("server/playback.lua");
include("server/positioning.lua");

AddCSLuaFile("shared.lua");

AddCSLuaFile("client.lua");
AddCSLuaFile("client/concommands.lua");
AddCSLuaFile("client/data.lua");
AddCSLuaFile("client/entity_highlight.lua");
AddCSLuaFile("client/entity_selection.lua");
AddCSLuaFile("client/makejpeg.lua");
AddCSLuaFile("client/menu_setup.lua");
AddCSLuaFile("client/derma/frame_panel.lua");
AddCSLuaFile("client/derma/frame_pointer.lua");
AddCSLuaFile("client/derma/load.lua");
AddCSLuaFile("client/derma/save.lua");
AddCSLuaFile("client/derma/settings.lua");
AddCSLuaFile("client/derma/smh_menu.lua");
AddCSLuaFile("client/derma/world_clicker.lua");

hook.Add("PlayerInitialSpawn", "SMHSetup", function(player)
	SMH.SetupData(player);
end);

Msg("SMH server initialized.\n");