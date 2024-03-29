local PANEL = {}

function PANEL:Init()

    self:SetTitle("Load")
    self:SetDeleteOnClose(false)
    self:SetSizable(true)

    self:SetSize(250, 210)
    self:SetMinWidth(250)
    self:SetMinHeight(210)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

    self.FileList = vgui.Create("DListView", self)
    self.FileList:AddColumn("Saved scenes")
    self.FileList:SetMultiSelect(false)
    self.FileList.OnRowSelected = function(_, rowIndex, row)
       self:OnModelListRequested(row:GetValue(1), false)
    end

    self.EntityList = vgui.Create("DListView", self)
    self.EntityList:AddColumn("Entities")
    self.EntityList:SetMultiSelect(false)
    self.EntityList.OnRowSelected = function(_, rowIndex, row)
        local _, selectedSave = self.FileList:GetSelectedLine()
        if not IsValid(selectedSave) then return end
        self:OnModelInfoRequested(selectedSave:GetValue(1),row:GetValue(1), false)
    end

    self.Load = vgui.Create("DButton", self)
    self.Load:SetText("Load")
    self.Load.DoClick = function()
        self:LoadSelected()
    end

    self.Spawn = vgui.Create("DButton", self)
    self.Spawn:SetText("Spawn")
    self.Spawn.DoClick = function()
        self:OpenSpawnMenu()
    end

    self.SaveEntity = vgui.Create("DLabel", self)
    self.SaveEntity:SetText("Save's model: " .. "nil")

    self.SaveMap = vgui.Create("DLabel", self)
    self.SaveMap:SetText("Save's map: " .. "nil")

    self.SelectedEnt = vgui.Create("DLabel", self)
    self.SelectedEnt:SetText("Selected model: " .. "nil")

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.FileList:SetPos(5, 30)
    self.FileList:SetSize(self:GetWide() / 2 - 5 - 5, 150 * (self:GetTall() / 210))

    self.EntityList:SetPos(self:GetWide() / 2 + 5, 30)
    self.EntityList:SetSize(self:GetWide() / 2 - 5 - 5, 150 * (self:GetTall() / 210))

    self.SaveEntity:SetPos(5, 30 + self.FileList:GetTall() + 5 )
    self.SaveEntity:SetSize(self:GetWide() - 135, 15)

    self.SaveMap:SetPos(5, 30 + self.FileList:GetTall() + 25 )
    self.SaveMap:SetSize(self:GetWide() - 135, 15)

    self.SelectedEnt:SetPos(5, 30 + self.FileList:GetTall() + 45 )
    self.SelectedEnt:SetSize(self:GetWide() - 135, 15)

    self.Load:SetPos(self:GetWide() - 60 - 5, self:GetTall() - 28)
    self.Load:SetSize(60, 20)

    self.Spawn:SetPos(self:GetWide() - 65 - 5 - 60, self:GetTall() - 28)
    self.Spawn:SetSize(60, 20)

end

function PANEL:UpdateSelectedEnt(ent)
    local SelectedName = ent == LocalPlayer() and "world" or IsValid(ent) and ent:GetModel() or "nil"
    self.SelectedEnt:SetText("Selected model: " .. SelectedName)
end

function PANEL:SetSaves(saves)
    self.FileList:UpdateLines(saves)
end

function PANEL:SetEntities(entities, map)
    self.EntityList:UpdateLines(entities)
    self.SaveMap:SetText("Selected map: " .. map)
end

function PANEL:SetModelName(name)
    self.SaveEntity:SetText("Save's model: " .. name)
end

function PANEL:LoadSelected()
    local _, selectedSave = self.FileList:GetSelectedLine()
    local _, selectedEntity = self.EntityList:GetSelectedLine()

    -- TODO clientside support for loading and saving

    if not IsValid(selectedSave) or not IsValid(selectedEntity) then
        return
    end

    -- TODO clientside support for loading and saving
    self:OnLoadRequested(selectedSave:GetValue(1), selectedEntity:GetValue(1), false)
end

function PANEL:OpenSpawnMenu() end
function PANEL:OnModelListRequested(path, loadFromClient) end
function PANEL:OnLoadRequested(path, modelName, loadFromClient) end
function PANEL:OnModelInfoRequested(path, modelname, loadFromClient) end

vgui.Register("SMHLoad", PANEL, "DFrame")
