local function bind(event, listeners)
    local m = {}
    m.__call = function(self, ...)
        for _, listener in pairs(listeners) do
            listener(...)
        end
    end
    setmetatable(event, m)
end

return function(eventToListenerMappings)
    for event, listeners in pairs(eventToListenerMappings) do
        bind(event, listeners)
    end
end