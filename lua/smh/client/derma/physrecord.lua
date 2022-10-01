local PANEL = {}

function PANEL:Init()

    local function CreateSlider(label, min, max, default, func)
        local slider = vgui.Create("DNumSlider", self)

        -- overriding default functions as it used to clamp result between mix and max, and we kinda want to go over the max if need be
        slider.SetValue = function(self, val)

            if ( self:GetValue() == val ) then return end

            self.Scratch:SetValue( val )

            self:ValueChanged( self:GetValue() )

        end

        slider.ValueChanged = function(self, val)

            if ( self.TextArea != vgui.GetKeyboardFocus() ) then
                self.TextArea:SetValue( self.Scratch:GetTextValue() )
            end

            self.Slider:SetSlideX( self.Scratch:GetFraction( val ) )

            self:OnValueChanged( val )

        end

        slider:SetMinMax(min, max)
        slider:SetDecimals(0)
        slider:SetDefaultValue(default)
        slider:SetValue(default)
        slider:SetText(label)
        slider.OnValueChanged = func
        slider:GetTextArea().OnValueChange = func
        return slider
    end

    self:SetTitle("SMH Physics Recorder")
    self:SetDeleteOnClose(false)

    self.FrameAmount = CreateSlider("Record Frame Count", 1, 200, 100, function(_, value)
        value = tonumber(value)
        if not value then return end

        if value < 3 then
            value = 3
        end
        SMH.PhysRecord.FrameCount = math.Round(value)
    end)

    self.Interval = CreateSlider("Record Interval", 0, 20, 0, function(_, value)
        value = tonumber(value)
        if not value then return end

        if value < 0 then
            value = 0
        end
        SMH.PhysRecord.RecordInterval = math.Round(value + 1)
    end)

    self.Delay = CreateSlider("Delay", 1, 10, 3, function(_, value)
        value = tonumber(value)
        if not value then return end

        if value < 0 then
            value = 0
        end
        SMH.PhysRecord.StartDelay = math.Round(value)
    end)

    self.RecordButton = vgui.Create("DButton", self)
    self.RecordButton:SetText("Toggle Record")
    self.RecordButton.DoClick = function()
        SMH.PhysRecord.RecordToggle()
        self.SelectEntity:SetText("Select Entity")

        if not next(SMH.State.Entity) then return end
        for entity, _ in pairs(SMH.State.Entity) do
            SMH.PhysRecord.SelectedEntities[entity] = SMH.State.Timeline
        end
    end

    self.SelectEntity = vgui.Create("DButton", self)
    self.SelectEntity:SetText("Select Entity")
    self.SelectEntity.DoClick = function()
        if not next(SMH.State.Entity) then return end
        local entity = next(SMH.State.Entity)

        if not SMH.PhysRecord.SelectedEntities[entity] then
            SMH.PhysRecord.SelectedEntities[entity] = SMH.State.Timeline
            self.SelectEntity:SetText("Unselect Entity")
        else
            SMH.PhysRecord.SelectedEntities[entity] = nil
            self.SelectEntity:SetText("Select Entity")
        end
    end

    self.RemoveAllSelected = vgui.Create("DButton", self)
    self.RemoveAllSelected:SetText("Clear all selected")
    self.RemoveAllSelected.DoClick = function()
        SMH.PhysRecord.SelectedEntities = {}
        self.SelectEntity:SetText("Select Entity")
    end

    self:SetSize(250, 170)

end

function PANEL:PerformLayout(width, height)

    self.BaseClass.PerformLayout(self, width, height)

    self.FrameAmount:SetPos(5, 25)
    self.FrameAmount:SetSize(self:GetWide() - 10, 25)

    self.Interval:SetPos(5, 55)
    self.Interval:SetSize(self:GetWide() - 10, 25)

    self.Delay:SetPos(5, 85)
    self.Delay:SetSize(self:GetWide() - 10, 25)

    self.SelectEntity:SetPos(5, 115)
    self.SelectEntity:SetSize(self:GetWide() / 2 - 15, 20)

    self.RemoveAllSelected:SetPos(10 + self:GetWide() / 2, 115)
    self.RemoveAllSelected:SetSize(self:GetWide() / 2 - 15, 20)

    self.RecordButton:SetPos(5, 140)
    self.RecordButton:SetSize(self:GetWide() - 10, 20)

end

function PANEL:UpdateSelectedEnt(entity)
    if not IsValid(entity) then 
        self.SelectEntity:SetText("Select Entity")
        return
    end

    if not SMH.PhysRecord.SelectedEntities[entity] then
        self.SelectEntity:SetText("Select Entity")
    else
        self.SelectEntity:SetText("Unselect Entity")
    end
end

vgui.Register("SMHPhysRecord", PANEL, "DFrame")
