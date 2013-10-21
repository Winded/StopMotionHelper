include("shared.lua");

function ENT:Initialize()

	self:SharedInitialize();

end

function ENT._SetPlayer(len)

	local self = net.ReadEntity();
	self.player = LocalPlayer();

end
net.Receive("smh_thread_setplayer", ENT._SetPlayer);

function ENT:Draw() return; end

function ENT:DrawTranslucent() return; end