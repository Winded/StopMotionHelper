local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventTrace(trace)
    if not IsValid(trace.Entity) then
        return
    end

    self.sequencer:Next(self, "SelectEntity", trace.Entity)
end

SMH.Systems.Register("EntitySelectionSystem", SYS)