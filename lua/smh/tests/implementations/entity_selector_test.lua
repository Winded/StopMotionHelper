TestEntitySelector = {
    _ctr = smhInclude("/smh/client/implementations/entity_selector.lua"),

    makeRegistry = function(self)
        local r = makeTestRegistry()
        r:forType("EntitySelector"):use(self._ctr)
        return r
    end,

    test_traceNilEntity = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("EntityValidator"):use({
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertNil(entity)
                return false
            end)
        })
        local c = Ludi.Container.new(r)
        local selector = c:get("EntitySelector")

        selector:selectFromTrace({ Entity = nil })
        
        LU.assertEquals(calls, { isValid = 1 })
    end,

    test_traceValidEntity = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("EntityHighlighter"):use({
            setEntity = trackCalls(calls, "setEntity", function(self, entity)
                LU.assertEquals(entity, 1234)
            end)
        })
        r:forType("ServerCommands"):use({
            selectEntity = trackCalls(calls, "selectEntity", function(self, entity)
                LU.assertEquals(entity, 1234)
            end)
        })
        r:forType("EntityValidator"):use({
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertEquals(entity, 1234)
                return true
            end)
        })
        local c = Ludi.Container.new(r)
        local selector = c:get("EntitySelector")

        selector:selectFromTrace({ Entity = 1234 })
        
        LU.assertEquals(calls, {
            setEntity = 1,
            selectEntity = 1,
            isValid = 1,
        })
    end,
}
