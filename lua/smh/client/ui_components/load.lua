local PANEL = {}

function PANEL:Init()

	self:SetTitle("Load")
	self:SetDeleteOnClose(false)

	self.FileList = vgui.Create("DListView", self)
	self.FileList:AddColumn("Saved scenes")
	self.FileList:SetMultiSelect(false)

	self.EntityList = vgui.Create("DListView", self)
	self.EntityList:AddColumn("Entities")
	self.EntityList:SetMultiSelect(false)

	self.Load = vgui.Create("DButton", self)
	self.Load:SetText("Load")

end

function PANEL:PerformLayout(w, h)

	self.BaseClass.PerformLayout(self, w, h)

	self:SetSize(250, 210)
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

	self.FileList:SetPos(5, 30)
	self.FileList:SetSize(self:GetWide() / 2 - 5 - 5, 150)

	self.EntityList:SetPos(self:GetWide() / 2 + 5, 30)
	self.EntityList:SetSize(self:GetWide() / 2 - 5 - 5, 150)

	self.Load:SetPos(self:GetWide() - 60 - 5, 182)
	self.Load:SetSize(60, 20)

end

vgui.Register("SMHLoad", PANEL, "DFrame")