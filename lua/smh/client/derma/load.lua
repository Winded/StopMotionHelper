local PANEL = {}

function PANEL:Init()

	self:SetTitle("Load")
	self:SetDeleteOnClose(false)

	self.FileList = vgui.Create("DListView", self)
	self.FileList:AddColumn("Saved scenes")
	self.FileList:SetMultiSelect(false)
    self.FileList.OnRowSelected = function(_, rowIndex, row)
       self:OnModelListRequested(row:GetValue(1), false)
    end

	self.EntityList = vgui.Create("DListView", self)
	self.EntityList:AddColumn("Entities")
	self.EntityList:SetMultiSelect(false)

	self.Load = vgui.Create("DButton", self)
	self.Load:SetText("Load")
	self.Load.DoClick = function()
		self:LoadSelected()
	end

end

function PANEL:PerformLayout(width, height)

	self.BaseClass.PerformLayout(self, width, height)

	self:SetSize(250, 210)
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

	self.FileList:SetPos(5, 30)
	self.FileList:SetSize(self:GetWide() / 2 - 5 - 5, 150)

	self.EntityList:SetPos(self:GetWide() / 2 + 5, 30)
	self.EntityList:SetSize(self:GetWide() / 2 - 5 - 5, 150)

	self.Load:SetPos(self:GetWide() - 60 - 5, 182)
	self.Load:SetSize(60, 20)

end

function PANEL:SetSaves(saves)
	self.FileList:UpdateLines(saves)
end

function PANEL:SetEntities(entities)
	self.EntityList:UpdateLines(entities)
end

function PANEL:LoadSelected()
	local _, selectedSave = self.FileList:GetSelectedLine()
	local _, selectedEntity = self.EntityList:GetSelectedLine()

	if not IsValid(selectedSave) or not IsValid(selectedEntity) then
		return
	end

	-- TODO clientside support for loading and saving
	self:OnLoadRequested(selectedSave:GetValue(1), selectedEntity:GetValue(1), false)
end

function PANEL:OnModelListRequested(path, loadFromClient) end
function PANEL:OnLoadRequested(path, modelName, loadFromClient) end

vgui.Register("SMHLoad", PANEL, "DFrame")
