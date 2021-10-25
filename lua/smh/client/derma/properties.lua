local PANEL = {}
local EntsTable = {}
local Fallback = "none"
local selectedEntity = nil

local function GetModelName(entity)
    local mdl = string.Split(entity:GetModel(), "/");
    mdl = mdl[#mdl];
    return mdl
end

local function FindEntityInfo(entity)
    if EntsTable then
        for kentity, value in pairs(EntsTable) do
            if kentity == entity then
                return value
            end
        end
    end

    return nil
end

local function FindEntity(name)
    if EntsTable then
        for kentity, value in pairs(EntsTable) do
            if value.Name == name then
                return kentity
            end
        end
    end

    return nil
end

local function UpdateName(name)
    if not IsValid(selectedEntity) then return end
    if EntsTable then
        EntsTable[selectedEntity].Name = name
    end
end

function PANEL:Init()

    self:SetTitle("Properties")
    self:SetDeleteOnClose(false)
    self:SetSizable(true)

    self:SetSize(500, 420)
    self:SetMinWidth(500)
    self:SetMinHeight(420)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)

    self.EntitiesPanel = vgui.Create("DPanel", self)
    self.EntitiesPanel:SetBackgroundColor(Color(155, 155, 155, 255))

    self.EntityNameEnter = vgui.Create("DTextEntry", self.EntitiesPanel)
    self.EntityNameEnter:SetSize(236, 20)
    self.EntityNameEnter:SetEditable(false)
    self.EntityNameEnter:SetText("none")
    self.EntityNameEnter.OnLoseFocus = function(sel)
        if sel:GetValue() == "" then
            sel:SetText(Fallback)
        end

        self:ApplyName(selectedEntity, sel:GetValue())
    end
        self.EntityNameEnter.Label = vgui.Create("DLabel", self.EntitiesPanel)
        self.EntityNameEnter.Label:SetText("Selected entity's name:")
        self.EntityNameEnter.Label:SizeToContents()

    self.EntityList = vgui.Create("DListView", self.EntitiesPanel)
    self.EntityList:AddColumn("Recorded Entities")
    self.EntityList:SetMultiSelect(false)
    self.EntityList.OnRowSelected = function(_, rowIndex, row)
        local _, selectedName = self.EntityList:GetSelectedLine()
        if not IsValid(selectedName) then return end
        local selectedEntity = FindEntity(selectedName:GetValue(1))
        if not IsValid(selectedEntity) then return end
        self:SelectEntity(selectedEntity)
    end

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

	self.EntitiesPanel:SetPos(4, 30)
    self.EntitiesPanel:SetSize(240, self:GetTall() - 4 - 30)

    self.EntityNameEnter:SetPos(2, 25)
        self.EntityNameEnter.Label:SetRelativePos(self.EntityNameEnter, 2, -5 - self.EntityNameEnter.Label:GetTall())

    self.EntityList:SetPos(5, 60)
    self.EntityList:SetSize(230, self.EntitiesPanel:GetTall() - 60 - 5)

end

function PANEL:UpdateSelectedEnt(ent)
    selectedEntity = ent
    self:SetEntities(EntsTable)
end

function PANEL:SetName(name)
    self.EntityNameEnter:SetText(name)
    UpdateName(name)
    self:SetEntities(EntsTable)
end

function PANEL:SetEntities(entities)
    local entlist = {}
    EntsTable = table.Copy(entities)

    if not IsValid(selectedEntity) then
        self.EntityNameEnter:SetText("none")
        self.EntityNameEnter:SetEditable(false)
    else
        local entityinfo = FindEntityInfo(selectedEntity)

        if not entityinfo then
            Fallback = GetModelName(selectedEntity)
            self.EntityNameEnter:SetText(Fallback)
            self.EntityNameEnter:SetEditable(false)
        else
            Fallback = entityinfo.Name
            self.EntityNameEnter:SetText(entityinfo.Name)
            self.EntityNameEnter:SetEditable(true)
        end
    end

    for entity, value in pairs(EntsTable) do
        table.insert(entlist, value.Name)
    end

    self.EntityList:UpdateLines(entlist)
end

function PANEL:ApplyName(ent, name) end
function PANEL:SelectEntity(entity) end

vgui.Register("SMHProperties", PANEL, "DFrame")
