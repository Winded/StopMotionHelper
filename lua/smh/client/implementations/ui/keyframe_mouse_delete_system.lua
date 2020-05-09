local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_RIGHT or input.IsKeyDown(KEY_LCONTROL) then
        return
    end

    self.sequencer:Next(self, "DeleteKeyframe", element.KeyframeId)
end

SMH.Systems.Register("KeyframeMouseDeleteSystem", SYS)