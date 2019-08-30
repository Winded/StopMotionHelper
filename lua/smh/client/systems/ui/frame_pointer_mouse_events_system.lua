local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventCreateUIElement(element)
    element.OnMousePressed = function(el, mouseCode)
        self.sequencer:Next(self, "FramePointerMousePressed", el, mouseCode)
    end
    element.OnMouseReleased = function(el, mouseCode)
        self.sequencer:Next(self, "FramePointerMouseReleased", el, mouseCode)
    end
    element.OnCursorMoved = function(el)
        local cursorX, cursorY = el.FramePanel:CursorPos()
        self.sequencer:Next(self, "FramePointerCursorMoved", el, cursorX, cursorY)
    end
end

function SYS:EventDeleteUIElement(element)
    element.OnMousePressed = function() end
    element.OnMouseReleased = function() end
    element.OnCursorMoved = function() end
end

SMH.Systems.Register("FramePointerMouseEventsSystem", SYS)