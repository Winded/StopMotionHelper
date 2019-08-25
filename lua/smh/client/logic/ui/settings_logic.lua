local function bind(settingsChangedEvent, settingKey, element, elementChangeFunc)
    element[elementChangeFunc] = function(self, newValue)
        settingsChangedEvent({ [settingKey] = newValue })
    end
end

local function invokeSet(changedSettings, settingKey, element)
    if changedSettings[settingKey] ~= nil then
        element:SetValue(changedSettings[settingKey])
    end
end

return function(element, settingsChangedEvent, showHelpEvent)
    local changing = false

    bind(settingsChangedEvent, "FreezeAll", element.FreezeAll, "OnChange")
    bind(settingsChangedEvent, "IgnorePhysBones", element.IgnorePhysBones, "OnChange")
    bind(settingsChangedEvent, "GhostPrevFrame", element.GhostPrevFrame, "OnChange")
    bind(settingsChangedEvent, "GhostNextFrame", element.GhostNextFrame, "OnChange")
    bind(settingsChangedEvent, "GhostAllEntities", element.GhostAllEntities, "OnChange")
    bind(settingsChangedEvent, "GhostTransparency", element.GhostTransparency, "OnValueChanged")

    element.ShowHelp.DoClick = function()
        showHelpEvent()
    end

    local settingsChangedEventListener = function(changedSettings)
        if changing then
            return
        end

        changing = true

        invokeSet(changedSettings, "FreezeAll", element.FreezeAll)
        invokeSet(changedSettings, "IgnorePhysBones", element.IgnorePhysBones)
        invokeSet(changedSettings, "GhostPrevFrame", element.GhostPrevFrame)
        invokeSet(changedSettings, "GhostNextFrame", element.GhostNextFrame)
        invokeSet(changedSettings, "GhostAllEntities", element.GhostAllEntities)
        invokeSet(changedSettings, "GhostTransparency", element.GhostTransparency)

        changing = false
    end

    return settingsChangedEventListener
end