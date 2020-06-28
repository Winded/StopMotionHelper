TestElementEvents = {
    _ctr = smhInclude("/smh/client/implementations/ui/element_events.lua"),

    makeRegistry = function(self)
        local r = makeTestRegistry()
        r:forType("ElementEvents"):use(self._ctr)
        return r
    end,

    test_eventSend = function(self)
        local calls = {}
        local element = {}
        local r = self:makeRegistry()
        for _, event in pairs(self._ctr.events) do
            r:forType(event.eventToSend):use({
                send = trackCalls(calls, event.eventToSend, function(self, element, arg)
                    LU.assertEquals(arg, "test")
                end)
            })
        end
        local c = Ludi.Container.new(r)
        local instance = c:get("ElementEvents")

        instance:register(element)

        for _, event in pairs(self._ctr.events) do
            element[event.elementFunction](element, "test")
            LU.assertEquals(calls[event.eventToSend], 1)
        end
    end,
}