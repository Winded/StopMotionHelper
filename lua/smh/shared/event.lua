local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {}

function CLASS.__new()
    local c = {
        _listeners = {},
    }
    setmetatable(c, CLASS)

    return c
end

function CLASS:addListener(listener, listenerFunction)
    if self._listeners[listener] ~= nil then
        error("Listener already added")
    end

    self._listeners[listener] = listenerFunction
end

function CLASS:send(...)
    for listener, listenerFunction in pairs(self._listeners) do
        listener[listenerFunction](listener, ...)
    end
end

return CLASS