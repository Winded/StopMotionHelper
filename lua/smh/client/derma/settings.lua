
local PANEL = {};

function PANEL:Init()

	self:SetTitle("SMH Settings");
	self:SetDeleteOnClose(false);

	self.FreezeAll = vgui.Create("DCheckBoxLabel", self);
	self.FreezeAll:SetText("Freeze all");
	self.FreezeAll:SizeToContents();
	self.FreezeAll:Bind(SMH.Data, "FreezeAll", "CheckBox");

	self.LocalizePhysBones = vgui.Create("DCheckBoxLabel", self);
	self.LocalizePhysBones:SetText("Localize phys bones");
	self.LocalizePhysBones:SizeToContents();
	self.LocalizePhysBones:Bind(SMH.Data, "LocalizePhysBones", "CheckBox");

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

	self.GhostAllEntities = vgui.Create("DCheckBoxLabel", self);
	self.GhostAllEntities:SetText("Ghost all entities");
	self.GhostAllEntities:SizeToContents();
	self.GhostAllEntities:Bind(SMH.Data, "GhostAllEntities", "CheckBox");

	self.GhostTransparency = vgui.Create("Slider", self);
	self.GhostTransparency:SetMinMax(0, 1);
	self.GhostTransparency:SetDecimals(2);
	self.GhostTransparency:Bind(SMH.Data, "GhostTransparency", "Number");
	self.GhostTransparencyLabel = vgui.Create("DLabel", self);
	self.GhostTransparencyLabel:SetText("Ghost transparency");
	self.GhostTransparencyLabel:SizeToContents();

	self.HelpButton = vgui.Create("DButton", self);
	self.HelpButton:SetText("Help");
	self.HelpButton:Bind(SMH.Data, "ShowHelpMenu", "Button");

	self:SetSize(160, 225);

end

function PANEL:PerformLayout()

	self.BaseClass.PerformLayout(self);

	self.FreezeAll:SetPos(5, 25);

	self.LocalizePhysBones:SetPos(5, 45);

	self.IgnorePhysBones:SetPos(5, 65);

	self.GhostPrevFrame:SetPos(5, 85);
	self.GhostNextFrame:SetPos(5, 105);
	self.GhostAllEntities:SetPos(5, 125);

	local gt = self.GhostTransparency;
	local label = self.GhostTransparencyLabel;
	label:SizeToContents();
	local LW, LH = label:GetSize();
	gt:SetPos(5, 145 + LH - 5);
	gt:SetSize(self:GetWide() - 5 - 5, 25);
	label:SetPos(10, 145);

	self.HelpButton:SetPos(5, 190);
	self.HelpButton:SetSize(150, 20);

end

vgui.Register("SMHSettings", PANEL, "DFrame");