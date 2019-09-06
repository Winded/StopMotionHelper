local SYS = {}

function SYS:Init(sequencer, sequenceBindings)
    for _, binding in pairs(sequenceBindings) do
        concommand.Add(binding.Command, function()
            sequencer:Next(self, binding.Event, unpack(binding.Args or {}))
        end)
    end
end

SMH.Systems.Register("ConcommandSystem", SYS)