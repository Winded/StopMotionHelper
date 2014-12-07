
local PANEL = {};

function PANEL:Init()

	self:SetWorldClicker(true);
	self:SetDrawBackground(false);
	self.m_bStretchToFit = true;

	self:SetPos(0, 0);
	self:SetSize(ScrW(), ScrH());

end

function PANEL:OnMousePressed(mousecode)

	if mousecode != MOUSE_RIGHT then
		return;
	end

	local playerTrace = util.GetPlayerTrace(LocalPlayer());
	local tr = util.TraceLine(playerTrace);
	if IsValid(tr.Entity) then
		SMH.SelectEntity(tr.Entity);
	end

end

vgui.Register("SMHWorldClicker", PANEL, "DPanel");