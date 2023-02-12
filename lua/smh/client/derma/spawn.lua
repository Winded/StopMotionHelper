local SaveFile = nil

local PANEL = {}

function PANEL:Init()

    local function CreateSlider(label, min, max, func)
        local slider = vgui.Create("DNumSlider", self)
        slider:SetMinMax(min, max)
        slider:SetDecimals(1)
        slider:SetDefaultValue(0)
        slider:SetValue(0)
        slider:SetText(label)
        slider.OnValueChanged = func
        return slider
    end

    self:SetTitle("Spawn Menu")
    self:SetDeleteOnClose(false)

    self:SetSize(300, 405)

    self.Origins = vgui.Create("DListView", self)
    self.Origins:AddColumn("Offset Origin")
    self.Origins:SetMultiSelect(false)
    self.Origins.OnRowSelected = function(_, rowIndex, row)
        if not SaveFile then return end
        self:OnOriginRequested(SaveFile,row:GetValue(1), false)
    end

    self.EntityList = vgui.Create("DListView", self)
    self.EntityList:AddColumn("Entities")
    self.EntityList:SetMultiSelect(false)
    self.EntityList.OnRowSelected = function(_, rowIndex, row)
        if not SaveFile then return end
        self:OnModelRequested(SaveFile,row:GetValue(1), false)
    end

    self.PositionLabel = vgui.Create("DLabel", self)
    self.PositionLabel:SetText("Position offset")
    self.PositionLabel:SizeToContents()

    self.XSlide = CreateSlider("X", -1000, 1000, function(_, value)
        local Pos = Vector(value, self.YSlide:GetValue(), self.ZSlide:GetValue())
        SMH.Controller.OffsetPos(Pos)
    end)

    self.YSlide = CreateSlider("Y", -1000, 1000, function(_, value)
        local Pos = Vector(self.XSlide:GetValue(), value, self.ZSlide:GetValue())
        SMH.Controller.OffsetPos(Pos)
    end)

    self.ZSlide = CreateSlider("Z", -1000, 1000, function(_, value)
        local Pos = Vector(self.XSlide:GetValue(), self.YSlide:GetValue(), value)
        SMH.Controller.OffsetPos(Pos)
    end)

    self.AngleLabel = vgui.Create("DLabel", self)
    self.AngleLabel:SetText("Angle offset")
    self.AngleLabel:SizeToContents()

    self.PSlide = CreateSlider("Pitch", -180, 180, function(_, value)
        local Ang = Angle(value, self.YawSlide:GetValue(), self.RSlide:GetValue())
        SMH.Controller.OffsetAng(Ang)
    end)

    self.YawSlide = CreateSlider("Yaw", -180, 180, function(_, value)
        local Ang = Angle(self.PSlide:GetValue(), value, self.RSlide:GetValue())
        SMH.Controller.OffsetAng(Ang)
    end)

    self.RSlide = CreateSlider("Roll", -180, 180, function(_, value)
        local Ang = Angle(self.PSlide:GetValue(), self.YawSlide:GetValue(), value)
        SMH.Controller.OffsetAng(Ang)
    end)

    self.OffsetCheck = vgui.Create("DCheckBoxLabel", self)
    self.OffsetCheck:SetText("Move to where you're looking")
    self.OffsetCheck.OnChange = function(_, value)
        self:SetOffsetMode(value)
    end

    self.Spawn = vgui.Create("DButton", self)
    self.Spawn:SetText("Spawn")
    self.Spawn.DoClick = function()
        self:SpawnSelected()
    end

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.Origins:SetPos(5, 30)
    self.Origins:SetSize(150 - 5 - 5, 150)

    self.EntityList:SetPos(150 + 5, 30)
    self.EntityList:SetSize(150 - 5 - 5, 150)

    self.PositionLabel:SetPos(5, 185)

    self.XSlide:SetPos(5, 200)
    self.XSlide:SetSize(300, 30)

    self.YSlide:SetPos(5, 200 + 15 + 5)
    self.YSlide:SetSize(300, 30)

    self.ZSlide:SetPos(5, 200 + 30 + 10)
    self.ZSlide:SetSize(300, 30)

    self.AngleLabel:SetPos(5, 270)

    self.PSlide:SetPos(5, 285)
    self.PSlide:SetSize(300, 30)

    self.YawSlide:SetPos(5, 285 + 15 + 5)
    self.YawSlide:SetSize(300, 30)

    self.RSlide:SetPos(5, 285 + 30 + 10)
    self.RSlide:SetSize(300, 30)

    self.OffsetCheck:SetPos(5, self:GetTall() - 28 - 15)
    self.OffsetCheck:SizeToContents()

    self.Spawn:SetPos(self:GetWide() - 60 - 5, self:GetTall() - 28)
    self.Spawn:SetSize(60, 20)

end

function PANEL:SetEntities(entities)
    self.Origins:UpdateLines(entities)
    self.EntityList:UpdateLines(entities)
end

function PANEL:SpawnSelected()
    local _, selectedEntity = self.EntityList:GetSelectedLine()
    if not SaveFile or not selectedEntity then return end
    self:OnSpawnRequested(SaveFile, selectedEntity:GetValue(1), false)
end

function PANEL:SetSaveFile(path)
    SaveFile = path
    if not SaveFile then
        self.Origins:Clear()
        self.EntityList:Clear()
    end
end

function PANEL:OnOriginRequested(path, modelname, loadFromClient) end
function PANEL:OnModelRequested(path, modelname, loadFromClient) end
function PANEL:OnSpawnRequested(path, modelName, loadFromClient) end
function PANEL:SetOffsetMode(set) end

vgui.Register("SMHSpawn", PANEL, "DFrame")
