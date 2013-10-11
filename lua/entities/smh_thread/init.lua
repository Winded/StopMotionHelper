include("shared.lua");

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");

function ENT:Initialize()

	self:SharedInitialize();

	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:SetColor(Color(255, 255, 255, 0));
	self:DrawShadow(false);

	self.player.smh = self;

	self.netfuncs.SetPlayer(self.player);

end