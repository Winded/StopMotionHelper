
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

	self.GhostPrevFrame = vgui.Create("DCheckBoxLabel", self);
	self.GhostPrevFrame:SetText("Ghost previous frame");
	self.GhostPrevFrame:SizeToContents();
	self.GhostPrevFrame:Bind(SMH.Data, "GhostPrevFrame", "CheckBox");

	self.GhostNextFrame = vgui.Create("DCheckBoxLabel", self);
	self.GhostNextFrame:SetText("Ghost next frame");
	self.GhostNextFrame:SizeToContents();
	self.GhostNextFrame:Bind(SMH.Data, "GhostNextFrame", "CheckBox");

	self.GhostTransparency = vgui.Create("Slider", self);
	self.GhostTransparency:SetMinMax(0, 1);
	self.GhostTransparency:SetDecimals(2);
	self.GhostTransparency:Bind(SMH.Data, "GhostTransparency", "Number");
	self.GhostTransparency.Label = vgui.Create("DLabel", self.GhostTransparency);
	self.GhostTransparency.Label:SetText("Ghost transparency");
	self.GhostTransparency.Label:SizeToContents();

	self.HelpButton = vgui.Create("DButton", self);
	self.HelpButton:SetText("Help");
	self.HelpButton:Bind(SMH.Data, "ShowHelpMenu", "Button");

	self:SetSize(160, 175);

end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self.FreezeAll:SetPos(5, 25);

	self.IgnorePhysBones:SetPos(5, 45);

	self.GhostPrevFrame:SetPos(5, 65);
	self.GhostNextFrame:SetPos(5, 85);

	local gt = self.GhostTransparency;
	local label = self.GhostTransparency.Label;
	local LW, LH = label:GetSize();
	gt:SetPos(5, 105 + LH + 2);
	gt:SetSize(self:GetWide() - 5 - 5, 25);
	label:SetPos(0, -LH - 2);

	self.HelpButton:SetPos(5, 150);
	self.HelpButton:SetSize(150, 20);

end

vgui.Register("SMHSettings", PANEL, "DFrame");