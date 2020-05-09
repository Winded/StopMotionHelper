TestEntitySelector = {
    _cfg = {
        entityValidator = includeMock("/gmod/entity_validator_mock.lua"),
        serverCommands = includeMock("/server_commands_mock.lua"),
        entityHighlighter = includeMock("/entity_highlighter_mock.lua"),
        entitySelector = smhInclude("/smh/client/implementations/entity_selector.lua"),
    },

    test_traceNilEntity = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local selector = c:get("entitySelector")
        selector:selectFromTrace({ Entity = nil })

        local highlighter = c:get("entityHighlighter")
        local commands = c:get("serverCommands")

        LU.assertNil(highlighter:getEntity())
        LU.assertEquals(#commands.messageHistory, 0)
    end,

    test_traceValidEntity = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local selector = c:get("entitySelector")
        selector:selectFromTrace({ Entity = 1234 })

        local highlighter = c:get("entityHighlighter")
        local commands = c:get("serverCommands")

        LU.assertEquals(highlighter:getEntity(), 1234)
        LU.assertEquals(#commands.messageHistory, 1)
        LU.assertEquals(commands.messageHistory[1], {"selectEntity", 1234})
    end,
}
