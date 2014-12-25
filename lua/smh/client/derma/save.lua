
local PANEL = {};

function PANEL:Init()

	self:SetDeleteOnClose(false);

	self.Browser = vgui.Create("DFileBrowser", self);
	self.OnSelect = function(self, value)
		print(value);
	end

end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self:SetSize(200, 300);
	self:Center();

	self.Browser:SetPos(2, 15);
	self.Browser:SetSize(self:GetWide() - 2 - 2, self:GetTall() - 15 - 2);

end

vgui.Register("SMHSave", PANEL, "DFrame");