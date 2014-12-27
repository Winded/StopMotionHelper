
local PANEL = {};

function PANEL:Init()

	self:SetTitle("Save");
	self:SetDeleteOnClose(false);

	self.FileName = vgui.Create("DTextEntry", self);
	self.FileName:Bind(SMH.Data, "SaveFileName", "TextEntry");
	self.FileName.Label = vgui.Create("DLabel", self);
	self.FileName.Label:SetText("Name");
	self.FileName.Label:SizeToContents();

	self.FileList = vgui.Create("DListView", self);
	self.FileList:SetMultiSelect(false);
	self.FileList:AddColumn("Saved scenes");
	self.FileList:Bind(SMH.Data, "SaveFiles", "ListView");
	self.FileList:Bind(SMH.Data, "SaveFileName", "ListViewSelect");

	self.Save = vgui.Create("DButton", self);
	self.Save:SetText("Save");
	self.Save:Bind(SMH.Data, "Save", "Button");

end

function PANEL:PerformLayout(w, h)

	self.BaseClass.PerformLayout(self, w, h);

	self:SetSize(250, 250);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);

	self.FileName:SetPos(5, 45);
	self.FileName:SetSize(self:GetWide() - 5 - 5, 20);
	self.FileName.Label:SetPos(5, 30);

	self.FileList:SetPos(5, 67);
	self.FileList:SetSize(self:GetWide() - 5 - 5, 150);

	self.Save:SetPos(self:GetWide() - 60 - 5, 219);
	self.Save:SetSize(60, 20);

end

vgui.Register("SMHSave", PANEL, "DFrame");