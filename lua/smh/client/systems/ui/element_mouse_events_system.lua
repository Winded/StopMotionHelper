local SYS = {}

function SYS:Init(sequencer, elements)
    self.sequencer = sequencer

    if elements == nil then
        return
    end

    for _, element in pairs(elements) do
        self:bind(element)
    end
end

function SYS:bind(element)
    element.OnMousePressed = function(el, mouseCode)
        self.sequencer:Next(self, "MousePressed", el, mouseCode)
    end
    element.OnMouseReleased = function(el, mouseCode)
        self.sequencer:Next(self, "MouseReleased", el, mouseCode)
    end
    element.OnMouseWheeled = function(el, scrollDelta)
        self.sequencer:Next(self, "MouseWheeled", el, scrollDelta)
    end
    element.OnCursorMoved = function(el)
        local cursorX, cursorY = el.FramePanel:CursorPos()
        self.sequencer:Next(self, "CursorMoved", el, cursorX, cursorY)
    end
end

function SYS:unbind(element)
    element.OnMousePressed = function() end
    element.OnMouseReleased = function() end
    element.OnMouseWheeled = function() end
    element.OnCursorMoved = function() end
end

function SYS:EventCreateUIElement(element)
    self:bind(element)
end

function SYS:EventDeleteUIElement(element)
    self:unbind(element)
end

SMH.Systems.Register("ElementMouseEventsSystem", SYS)