include("shared.lua");

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

util.AddNetworkString("smh_thread_setplayer");

function ENT:Initialize()

	self:SharedInitialize();

	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetColor(Color(255, 255, 255, 0));
	self:DrawShadow(false);

	self:_SetPlayer(self.player);

end

-- Should not be called seperately; self.player should be set before spawning.
-- This just set's the player's smh variable and sends a net message to the player.
function ENT:_SetPlayer(player)

	player.smh = self;
	self.player = player;

	net.Start("smh_thread_setplayer");
	net.WriteEntity(self);
	net.Send(player);

end