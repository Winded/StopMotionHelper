return function(ctx)
    return {
        _entityHighlighter = ctx:get("EntityHighlighter"),
        _serverCommands = ctx:get("ServerCommands"),
        _entityValidator = ctx:get("EntityValidator"),

        selectFromTrace = function(self, trace)
            if not self._entityValidator:isValid(trace.Entity) then
                return
            end

            self._entityHighlighter:setEntity(trace.Entity)
            self._serverCommands:selectEntity(trace.Entity)
        end,
    }
end