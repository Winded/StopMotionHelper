
include("shared.lua");
include("client/entity_selection.lua");
include("client/entity_highlight.lua");
include("client/concommands.lua");

include("client/menu_setup.lua");

hook.Add("InitPostEntity", "SMHSetup", function()
	local player = LocalPlayer();
	SMH.SetupData(player);
	SMH.SetupMenu();
end);

Msg("SMH client initialized.\n")
