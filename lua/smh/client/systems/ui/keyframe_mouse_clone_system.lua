local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_MIDDLE or not (mouseCode == MOUSE_RIGHT and input.IsKeyDown(KEY_LCONTROL)) then
        return
    end

    self.sequencer:Next(self, "CreateCloneKeyframeElement", element.KeyframeId)
end