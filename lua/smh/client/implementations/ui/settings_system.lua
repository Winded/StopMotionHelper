local SYS = {}

function SYS:Init(sequencer, bindings)
    self.sequencer = sequencer
    self.bindings = bindings

    element.ShowHelp.DoClick = function()
        self.sequencer:Next(self, "ShowHelp")
    end
end

function SYS:EventChangeBindingValue(binding, newValue)
    if binding.ShowHelp then
        self.sequencer:Next(self, "ShowHelp")
        return
    end

    self.sequencer:Next(self, "ChangeSettings", { [binding.SettingKey] = newValue })
end

function SYS:EventChangeSettings(changedSettings)
    for _, binding in pairs(self.bindings) do
        if changedSettings[binding.SettingKey] ~= nil then
            self.sequencer:next(self, "ChangeBindingValue", binding, changedSettings[binding.SettingKey])
        end
    end
end

SMH.Systems.Register("SettingsSystem", SYS)