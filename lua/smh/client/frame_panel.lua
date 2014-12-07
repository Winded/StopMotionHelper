
local PANEL = {};

function PANEL:Init()

	self:SetBackgroundColor(Color(64, 64, 64, 64));

end

function PANEL:GetFrameArea()

	local padding = 10;

	local startPoint = padding;
	local endPoint = self:GetWide() - padding;
	return startPoint, endPoint;

end

function PANEL:Paint(w, h)

	self.BaseClass.Paint(self, w, h);

	local startX, endX = self:GetFrameArea();

	local frameWidth = (endX - startX) / SMH.PlaybackLength;

	surface.SetDrawColor(255, 255, 255, 255);

	for i = 0, SMH.PlaybackLength do
		local x = startX + frameWidth * i;
		surface.DrawLine(x, 6, x, self:GetTall() - 6);
	end

end

vgui.Register("SMHFramePanel", PANEL, "DPanel");