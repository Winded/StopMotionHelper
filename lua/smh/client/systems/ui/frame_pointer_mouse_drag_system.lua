local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    self.sequencer:Next(self, "FramePointerDragStart", element)
end

function SYS:EventMouseReleased(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    self.sequencer:Next(self, "FramePointerDragStop", element)
end

SMH.Systems.Register("FramePointerMouseDragSystem", SYS)