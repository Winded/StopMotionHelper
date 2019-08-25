return function(entitySelectedEvent)
    local traceEventListener = function(trace)
        if not IsValid(trace.Entity) then
            return
        end

        entitySelectedEvent(trace.Entity)
    end

    return traceEventListener
end