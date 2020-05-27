return function(entityHighlighter, serverCommands, entityValidator)
    return {
        _entityHighlighter = entityHighlighter,
        _serverCommands = serverCommands,
        _entityValidator = entityValidator,

        selectFromTrace = function(self, trace)
            if not self._entityValidator:isValid(trace.Entity) then
                return
            end

            self._entityHighlighter:setEntity(trace.Entity)
            self._serverCommands:selectEntity(trace.Entity)
        end,
    }
end