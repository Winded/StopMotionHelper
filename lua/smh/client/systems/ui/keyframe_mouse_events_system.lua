local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventKeyframeElementCreated(element)
    element.OnMousePressed = function(el, mouseCode)
        self.sequencer:Next(self, "KeyframeMousePressed", el, mouseCode)
    end
    element.OnMouseReleased = function(el, mouseCode)
        self.sequencer:Next(self, "KeyframeMouseReleased", el, mouseCode)
    end
    element.OnCursorMoved = function(el)
        local cursorX, cursorY = el.FramePanel:CursorPos()
        self.sequencer:Next(self, "KeyframeCursorMoved", el, cursorX, cursorY)
    end
end

function SYS:EventFramePointerElementRemoved(element)
    element.OnMousePressed = function() end
    element.OnMouseReleased = function() end
    element.OnMouseWheeled = function() end
    element.OnCursorMoved = function() end
end

SMH.RegisterSystem("FramePointerMouseEventsSystem", SYS)