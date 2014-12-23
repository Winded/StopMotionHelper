
local PANEL = {};

function PANEL:Init()

	self:SetBackgroundColor(Color(64, 64, 64, 64));
	self.Length = 100;

end

function PANEL:GetFrameArea()

	local padding = 10;

	local startPoint = padding;
	local endPoint = self:GetWide() - padding;
	return startPoint, endPoint;

end

function PANEL:SetLength(value)
	if value < 1 then
		value = 1;
	end
	self.Length = value;
end

function PANEL:Paint(w, h)

	self.BaseClass.Paint(self, w, h);

	local startX, endX = self:GetFrameArea();

	local frameWidth = (endX - startX) / self.Length;

	surface.SetDrawColor(255, 255, 255, 255);

	for i = 0, self.Length do
		local x = startX + frameWidth * i;
		surface.DrawLine(x, 6, x, self:GetTall() - 6);
	end

end

vgui.Register("SMHFramePanel", PANEL, "DPanel");

local BIND = setmetatable({}, BiValues.ValueBind);
function BIND:Init()
	self.Settings.ValueFunction = self.Settings.ValueFunction or "SetLength";
end
BiValues.RegisterBindType("FramePanel", BIND);