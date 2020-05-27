TestEntitySelector = {
    _ctr = smhInclude("/smh/client/implementations/entity_selector.lua"),

    test_traceNilEntity = function(self)
        local calls = {}
        local selector = self._ctr(nil, nil, {
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertNil(entity)
                return false
            end)
        })
        selector:selectFromTrace({ Entity = nil })
        
        LU.assertEquals(calls, { isValid = 1 })
    end,

    test_traceValidEntity = function(self)
        local calls = {}
        local selector = self._ctr({
            setEntity = trackCalls(calls, "setEntity", function(self, entity)
                LU.assertEquals(entity, 1234)
            end)
        }, {
            selectEntity = trackCalls(calls, "selectEntity", function(self, entity)
                LU.assertEquals(entity, 1234)
            end)
        }, {
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertEquals(entity, 1234)
                return true
            end)
        })
        selector:selectFromTrace({ Entity = 1234 })
        
        LU.assertEquals(calls, {
            setEntity = 1,
            selectEntity = 1,
            isValid = 1,
        })
    end,
}
