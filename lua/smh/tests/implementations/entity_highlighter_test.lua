TestEntityHighlighter = {
    _ctr = smhInclude("/smh/client/implementations/entity_highlighter.lua")[1],

    test_initialize = function(self)
        local calls = {}
        local highlighter = self._ctr(nil, {
            create = trackCalls(calls, "create", function(self, hookName, identifier, callback)
                LU.assertEquals(hookName, "PostDrawEffects")
                LU.assertEquals(identifier, "SMHEntityHighlight")
                LU.assertNotNil(callback)
            end)
        }, nil)
        
        highlighter:initialize()
        LU.assertEquals(calls, { create = 1 })
    end,

    test_enabledInvalidEntity = function(self)
        local calls = {}
        local highlighter = self._ctr({
            render = trackCalls(calls, "render", function(self, entity)
                LU.assertNotNil(entity)
            end)
        }, nil, {
            isValid = trackCalls(calls, "isValid", function(self, entity)
                return false
            end)
        })

        highlighter:setEnabled(true)
        LU.assertTrue(highlighter:isEnabled())
        LU.assertEquals(highlighter:getEntity(), nil)

        highlighter:onPostDrawEffects()
        LU.assertEquals(calls, {
            isValid = 1,
        })
    end,

    test_successfulRender = function(self)
        local calls = {}
        local highlighter = self._ctr({
            render = trackCalls(calls, "render", function(self, entity)
                LU.assertNotNil(entity)
            end)
        }, nil, {
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertEquals(entity, 1234)
                return true
            end)
        })

        highlighter:setEnabled(true)
        highlighter:setEntity(1234)
        LU.assertTrue(highlighter:isEnabled())
        LU.assertEquals(highlighter:getEntity(), 1234)

        highlighter:onPostDrawEffects()
        LU.assertEquals(calls, {
            isValid = 1,
            render = 1,
        })
    end,
}
