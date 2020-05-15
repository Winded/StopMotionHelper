TestFramePointerFactory = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer_factory.lua")[1],

    test_initialize = function(self)
        local calls = {}
        local metatable = {}
        local instance = self._ctr(metatable, nil, nil, {
            register = trackCalls(calls, "register", function(self, name, mt, type)
                LU.assertEquals(name, "SMHFramePointer")
                LU.assertEquals(metatable, mt)
                LU.assertEquals(type, "DPanel")
            end),
        })

        instance:initialize()
        LU.assertEquals(calls.register, 1)
    end,

    test_create = function(self)
        local calls = {}
        local instance = self._ctr(nil, nil, nil, {
            create = trackCalls(calls, "create", function(self, name)
                LU.assertEquals(name, "SMHFramePointer")
                return {
                    _initialize = trackCalls(calls, "initialize", function(self, ...) end),
                    SetParent = trackCalls(calls, "SetParent", function(self, ...) end),
                }
            end),
        })

        instance:create(nil, nil, nil, nil)
        LU.assertEquals(calls.create, 1)
        LU.assertEquals(calls.initialize, 1)
        LU.assertEquals(calls.SetParent, 1)
    end,
}
