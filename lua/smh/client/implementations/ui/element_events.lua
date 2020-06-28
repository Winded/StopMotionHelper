local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = { "__container__" }

CLASS.events = {
    { elementFunction = "Paint", eventToSend = "ElementPaintEvent" },
    { elementFunction = "OnMousePressed", eventToSend = "ElementMousePressedEvent" },
    { elementFunction = "OnMouseReleased", eventToSend = "ElementMouseReleasedEvent" },
    { elementFunction = "OnCursorMoved", eventToSend = "ElementCursorMovedEvent" },
}

function CLASS.__new(container)
    local c = {
        _eventSenders = {},
    }
    setmetatable(c, CLASS)

    for _, event in pairs(CLASS.events) do
        c._eventSenders[event.elementFunction] = container:get(event.eventToSend)
    end

    return c
end

function CLASS:register(element)
    for elementFunction, event in pairs(self._eventSenders) do
        element[elementFunction] = function(element, ...) event:send(element, ...) end
    end
end

return CLASS