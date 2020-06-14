TestEntityHighlighter = {
    _ctr = smhInclude("/smh/client/implementations/entity_highlighter.lua"),

    makeRegistry = function(self)
        local r = makeTestRegistry()
        r:forType("EntityHighlighter"):use(self._ctr)
        return r
    end,

    test_initialize = function(self)
        -- local calls = {}
        local r = self:makeRegistry()
        --[[r:forType("HookCreator"):use({
            create = trackCalls(calls, "create", function(self, hookName, identifier, callback)
                LU.assertEquals(hookName, "PostDrawEffects")
                LU.assertEquals(identifier, "SMHEntityHighlight")
                LU.assertNotNil(callback)
            end)
        })]]
        local c = Ludi.Container.new(r)
        local highlighter = c:get("EntityHighlighter")
        
        -- LU.assertEquals(calls, { create = 1 })
    end,

    test_enabledInvalidEntity = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("HaloRenderer"):use({
            render = trackCalls(calls, "render", function(self, entity)
                LU.assertNotNil(entity)
            end)
        })
        r:forType("EntityValidator"):use({
            isValid = trackCalls(calls, "isValid", function() return false end)
        })
        local c = Ludi.Container.new(r)
        local highlighter = c:get("EntityHighlighter")

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
        local r = self:makeRegistry()
        r:forType("HaloRenderer"):use({
            render = trackCalls(calls, "render", function(self, entity)
                LU.assertNotNil(entity)
            end)
        })
        r:forType("EntityValidator"):use({
            isValid = trackCalls(calls, "isValid", function(self, entity)
                LU.assertEquals(entity, 1234)
                return true
            end)
        })
        local c = Ludi.Container.new(r)
        local highlighter = c:get("EntityHighlighter")

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
