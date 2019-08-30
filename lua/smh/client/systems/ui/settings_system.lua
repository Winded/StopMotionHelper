local SYS = {}

function SYS:Init(sequencer, element)
    self.sequencer = sequencer
    self.element = element
    self.changing = false

    self:bind("FreezeAll", element.FreezeAll, "OnChange")
    self:bind("IgnorePhysBones", element.IgnorePhysBones, "OnChange")
    self:bind("GhostPrevFrame", element.GhostPrevFrame, "OnChange")
    self:bind("GhostNextFrame", element.GhostNextFrame, "OnChange")
    self:bind("GhostAllEntities", element.GhostAllEntities, "OnChange")
    self:bind("GhostTransparency", element.GhostTransparency, "OnValueChanged")

    element.ShowHelp.DoClick = function()
        self.sequencer:Next(self, "ShowHelp")
    end
end

function SYS:EventSettingsChanged(changedSettings)
    if self.changing then
        return
    end

    self.changing = true

    self:invokeSet(changedSettings, "FreezeAll", element.FreezeAll)
    self:invokeSet(changedSettings, "IgnorePhysBones", element.IgnorePhysBones)
    self:invokeSet(changedSettings, "GhostPrevFrame", element.GhostPrevFrame)
    self:invokeSet(changedSettings, "GhostNextFrame", element.GhostNextFrame)
    self:invokeSet(changedSettings, "GhostAllEntities", element.GhostAllEntities)
    self:invokeSet(changedSettings, "GhostTransparency", element.GhostTransparency)

    self.changing = false
end

function SYS:bind(settingKey, element, elementChangeFunc)
    element[elementChangeFunc] = function(_, newValue)
        self.changing = true
        self.sequencer:Next(self, "SettingsChanged", { [settingKey] = newValue })
        self.changing = false
    end
end

function SYS:invokeSet(changedSettings, settingKey, element)
    if changedSettings[settingKey] ~= nil then
        element:SetValue(changedSettings[settingKey])
    end
end

SMH.RegisterSystem("SettingsSystem", SYS)