
local PANEL = {};

function PANEL:Init()

	self:SetTitle("SMH Settings");
	self:SetDeleteOnClose(false);

	self.FreezeAll = vgui.Create("DCheckBoxLabel", self);
	self.FreezeAll:SetText("Freeze all");
	self.FreezeAll:SizeToContents();
	self.FreezeAll:Bind(SMH.Data, "FreezeAll", "CheckBox");

	self.IgnorePhysBones = vgui.Create("DCheckBoxLabel", self);
	self.IgnorePhysBones:SetText("Don't animate phys bones");
	self.IgnorePhysBones:SizeToContents();
	self.IgnorePhysBones:Bind(SMH.Data, "IgnorePhysBones", "CheckBox");

	self.HelpButton = vgui.Create("DButton", self);
	self.HelpButton:SetText("Help");
	self.HelpButton:Bind(SMH.Data, "ShowHelpMenu", "Button");

end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self:SetSize(130, 105);

	self.FreezeAll:SetPos(5, 25);

	self.IgnorePhysBones:SetPos(5, 45);

	self.HelpButton:SetPos(5, 65);
	self.HelpButton:SetSize(100, 20);

end

vgui.Register("SMHSettings", PANEL, "DFrame");