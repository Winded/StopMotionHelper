local PANEL = {}

function PANEL:Init()

    local function CreateSlider(label, min, max, default, func)
        local slider = vgui.Create("DNumSlider", self)
        slider:SetMinMax(min, max)
        slider:SetDecimals(0)
        slider:SetDefaultValue(default)
        slider:SetValue(default)
        slider:SetText(label)
        slider.OnValueChanged = func
        return slider
    end

    self:SetTitle("SMH Physics Recorder")
    self:SetDeleteOnClose(false)

    self.FrameAmount = CreateSlider("Record Frame Count", 1, 200, 100, function(_, value)
        if value < 3 then
            value = 3
        end
        SMH.PhysRecord.FrameCount = math.Round(value)
    end)

    self.Interval = CreateSlider("Record Interval", 0, 20, 0, function(_, value)
        if value < 0 then
            value = 0
        end
        SMH.PhysRecord.RecordInterval = math.Round(value + 1)
    end)

    self.Delay = CreateSlider("Delay", 1, 10, 3, function(_, value)
        if value < 0 then
            value = 0
        end
        SMH.PhysRecord.StartDelay = math.Round(value)
    end)

    self.RecordButton = vgui.Create("DButton", self)
    self.RecordButton:SetText("Toggle Record")
    self.RecordButton.DoClick = function()
        SMH.PhysRecord.RecordToggle()
    end

    self:SetSize(250, 150)

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.FrameAmount:SetPos(5, 25)
    self.FrameAmount:SetSize(self:GetWide() - 10, 25)

    self.Interval:SetPos(5, 55)
    self.Interval:SetSize(self:GetWide() - 10, 25)

    self.Delay:SetPos(5, 85)
    self.Delay:SetSize(self:GetWide() - 10, 25)

    self.RecordButton:SetPos(5, 115)
    self.RecordButton:SetSize(self:GetWide() - 10, 20)

end

vgui.Register("SMHPhysRecord", PANEL, "DFrame")
