local SYS = {}

function SYS:Init(sequencer, bindings)
    self.sequencer = sequencer
    self.changing = false

    for _, binding in pairs(bindings) do
        self:bind(binding)
    end
end

function SYS:EventChangeBindingValue(binding, newValue)
    self.changing = true
    self:invokeSet(binding, newValue)
    self.changing = false
end

function SYS:bind(binding)
    binding.Element[binding.Callback] = function(_, newValue)
        if self.changing then
            return
        end

        self.sequencer:Next(self, "ChangeBindingValue", binding, newValue)
    end
end

function SYS:invokeSet(binding, value)
    if binding.SetFunc == nil then
        return
    end

    binding.Element[binding.SetFunc](binding.Element, value)
end

SMH.Systems.Register("ElementBindSystem", SYS)