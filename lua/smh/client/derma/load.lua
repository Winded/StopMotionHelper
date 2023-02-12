local PANEL = {}

function PANEL:Init()

    self:SetTitle("Load")
    self:SetDeleteOnClose(false)
    self:SetSizable(true)

    self:SetSize(250, 250)
    self:SetMinWidth(250)
    self:SetMinHeight(250)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

    self.PathLabel = vgui.Create("DLabel", self)
    self.PathLabel:SetMouseInputEnabled(true)
    self.PathLabel:SetText("smh/")
    self.PathLabel:SetTooltip("smh/")

    self.FileList = vgui.Create("DListView", self)
    self.FileList:AddColumn("Saved scenes")
    self.FileList:SetMultiSelect(false)
    self.FileList.OnRowSelected = function(_, rowIndex, row)
        if row.IsFolder or row:GetValue(1) == ".." then
            return
        end
        self:OnModelListRequested(row:GetValue(1), false)
    end
    self.FileList.DoDoubleClick = function(_, rowIndex, row)
        local path = row:GetValue(1)
        if not (row.IsFolder or path == "..") then return end
        if row.IsFolder then path = string.sub(path, 2) end

        self:DoFolderPath(path)
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

    self.SaveClass = vgui.Create("DLabel", self)
    self.SaveClass:SetText("Save's class: " .. "nil")

    self.SaveMap = vgui.Create("DLabel", self)
    self.SaveMap:SetText("Save's map: " .. "nil")

    self.SelectedEnt = vgui.Create("DLabel", self)
    self.SelectedEnt:SetText("Selected model: " .. "nil")

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.PathLabel:SetPos(5, 30)
    self.PathLabel:SetSize(self:GetWide(), 15)

    self.FileList:SetPos(5, 45)
    self.FileList:SetSize(117 + ( self:GetWide()/2 - 125 ), 120 + ( self:GetTall()*0.9 - 225 ))

    self.EntityList:SetPos(127 + ( self:GetWide()/2 - 125 ), 45)
    self.EntityList:SetSize(117 + ( self:GetWide()/2 - 125 ), 120 + ( self:GetTall()*0.9 - 225 ))

    self.Load:SetPos(self:GetWide() - 65 - ( self:GetWide()*0.2 - 50 ), self:GetTall() - 58 - ( self:GetTall()*0.1 - 25 ))
    self.Load:SetSize(60 + ( self:GetWide()*0.2 - 50 ), 20 + ( self:GetTall()*0.1 - 25 )/2)

    self.Spawn:SetRelativePos(self.Load, 0, 30 + ( self:GetTall()*0.1 - 25 )/2)
    self.Spawn:SetSize(60 + ( self:GetWide()*0.2 - 50 ), 20 + ( self:GetTall()*0.1 - 25 )/2)

    local labelSize, labelY = self.Load:GetX() - 10, self:GetTall()*0.9 - 225

    self.SelectedEnt:SetPos(5, 230 + labelY)
    self.SelectedEnt:SetSize(labelSize, 15)

    self.SaveEntity:SetPos(5, 170 + labelY)
    self.SaveEntity:SetSize(labelSize, 15)

    self.SaveClass:SetPos(5, 190 + labelY)
    self.SaveClass:SetSize(labelSize, 15)

    self.SaveMap:SetPos(5, 210 + labelY)
    self.SaveMap:SetSize(labelSize, 15)

end

function PANEL:DoFolderPath(path)
    if not path or path == "" then
        return
    end

    self.EntityList:Clear()

    self:OnGoToFolderRequested(path)
end

function PANEL:UpdateSelectedEnt(ent)
    local SelectedName = ent == LocalPlayer() and "world" or IsValid(ent) and ent:GetModel() or "nil"
    self.SelectedEnt:SetText("Selected model: " .. SelectedName)
end

function PANEL:SetSaves(folders, saves, path)
    self.FileList:UpdateLines(folders, true)
    self.FileList:UpdateLines(saves)
    self.PathLabel:SetText(path)
    self.PathLabel:SetTooltip(path)

    local kablooey = string.Explode("/", path)
    if #kablooey > 2 then
        local line = self.FileList:AddLine("..")
        self.FileList:SortByColumn(1)
    end
end

function PANEL:SetEntities(entities, map)
    self.EntityList:UpdateLines(entities)
    self.SaveMap:SetText("Selected map: " .. map)
end

function PANEL:SetModelName(name, class)
    self.SaveEntity:SetText("Save's model: " .. name)
    self.SaveClass:SetText("Save's class: " .. class)
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
function PANEL:OnGoToFolderRequested(path, toClient) end
function PANEL:OnLoadRequested(path, modelName, loadFromClient) end
function PANEL:OnModelInfoRequested(path, modelname, loadFromClient) end

vgui.Register("SMHLoad", PANEL, "DFrame")
