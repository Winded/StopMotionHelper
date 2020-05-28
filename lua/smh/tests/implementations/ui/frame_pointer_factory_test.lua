TestFramePointerFactory = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer_factory.lua"),

    test_create = function(self)
        local calls = {}
        local instance = self._ctr(nil, {
            create = trackCalls(calls, "create", function(self, name)
                LU.assertEquals(name, "DPanel")
                return {
                    SetParent = trackCalls(calls, "SetParent", function() end),
                    SetSize = trackCalls(calls, "SetSize", function() end),
                }
            end),
        })

        instance:create({ element = nil }, nil, nil, nil, nil)
        LU.assertEquals(calls.create, 1)
        LU.assertEquals(calls.SetParent, 1)
        LU.assertEquals(calls.SetSize, 1)
    end,
}
