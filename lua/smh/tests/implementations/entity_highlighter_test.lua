TestEntityHighlighter = {
    _cfg = {
        hookCreator = includeStub("/gmod/hook_creator.lua"),
        haloRenderer = includeStub("/gmod/halo_renderer.lua"),
        entityValidator = includeStub("/gmod/entity_validator.lua"),
        entityHighlighter = smhInclude("/smh/client/implementations/entity_highlighter.lua")
    },

    test_initialize = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local highlighter = c:get("entityHighlighter")
        highlighter:initialize()

        local hookCreator = c:get("hookCreator")

        LU.assertEquals(#hookCreator.hooks, 1)
        LU.assertEquals(hookCreator.hooks[1][1], "PostDrawEffects")
        LU.assertEquals(hookCreator.hooks[1][2], "SMHEntityHighlight")
    end,

    test_enabledInvalidEntity = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local highlighter = c:get("entityHighlighter")
        highlighter:initialize()

        highlighter:setEnabled(true)
        LU.assertTrue(highlighter:isEnabled())
        LU.assertEquals(highlighter:getEntity(), nil)

        local hookCreator = c:get("hookCreator")
        hookCreator.hooks[1][3]()

        local haloRenderer = c:get("haloRenderer")
        LU.assertEquals(#haloRenderer.renderEvents, 0)
    end,

    test_successfulRender = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local highlighter = c:get("entityHighlighter")
        highlighter:initialize()

        highlighter:setEnabled(true)
        highlighter:setEntity(1234) -- fake Entity ID
        LU.assertTrue(highlighter:isEnabled())
        LU.assertEquals(highlighter:getEntity(), 1234)

        local hookCreator = c:get("hookCreator")
        hookCreator.hooks[1][3]()

        local haloRenderer = c:get("haloRenderer")
        LU.assertEquals(#haloRenderer.renderEvents, 1)
        LU.assertEquals(haloRenderer.renderEvents[1], 1234)
    end,
}
