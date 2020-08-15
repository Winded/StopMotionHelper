TestFramePanel = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_panel.lua"),

    makeRegistry = function(self)
        local r = makeTestRegistry()
        r:forType("FramePanel"):use(self._ctr)
        return r
    end,

    test_create = function(self)
        local element = {}
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({
            mainMenu = {
                framePanel = element
            }
        })
        local c = Ludi.Container.new(r)
        c:get("FramePanel")

        LU.assertNotNil(element.PerformLayout)
        LU.assertNotNil(element.Paint)
        LU.assertNotNil(element.OnMouseWheeled)
        LU.assertNotNil(element.OnMousePressed)
    end,

    performPaintTest = function(self, playbackOffset, playbackLength, timelineLength, expectedDrawCalls)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({
            mainMenu = {
                framePanel = {
                    GetTall = trackCalls(calls, "GetTall", function() return 10 end),
                }
            }
        })
        r:forType("SurfaceDrawer"):use({
            setDrawColor = function() end,
            drawLine = trackCalls(calls, "drawLine", function() end),
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = trackCalls(calls, "getScrollOffset", function() return playbackOffset end),
            getZoom = trackCalls(calls, "getZoom", function() return playbackLength end),
            getTimelineLength = trackCalls(calls, "getTimelineLength", function() return timelineLength end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePanel")

        instance:paint()

        LU.assertTrue(calls.GetTall > 0)
        LU.assertTrue(calls.getScrollOffset > 0)
        LU.assertTrue(calls.getZoom > 0)
        LU.assertTrue(calls.getTimelineLength > 0)
        LU.assertEquals(calls.drawLine, expectedDrawCalls)
    end,

    test_paint1 = function(self)
        self:performPaintTest(0, 20, 20, 20)
    end,

    test_paint2 = function(self)
        self:performPaintTest(5, 10, 20, 10)
    end,

    test_paint3 = function(self)
        self:performPaintTest(5, 50, 40, 35)
    end,

    test_onMouseWheeled = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({ mainMenu = { framePanel = {} } })
        r:forType("FrameTimelineSettings"):use({
            getZoom = trackCalls(calls, "getZoom", function() return 10 end),
            setZoom = trackCalls(calls, "setZoom", function(self, length) LU.assertEquals(length, 11) end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePanel")

        instance:onMouseWheeled(-1)

        LU.assertEquals(calls.getZoom, 1)
        LU.assertEquals(calls.setZoom, 1)
    end,

    test_onMousePressed_notLeftButton = function(self)
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({ mainMenu = { framePanel = {} } })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePanel")

        instance:onMousePressed(MOUSE_MIDDLE)
        instance:onMousePressed(MOUSE_RIGHT)
    end,

    performMousePressedTest = function(self, playbackOffset, playbackLength, timelineLength, cursorPosX, expectedFramePosition)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({
            mainMenu = {
                framePanel = {
                    CursorPos = trackCalls(calls, "CursorPos", function() return cursorPosX, 0 end),
                }
            }
        })
        r:forType("FramePositionClickEvent"):use({
            send = trackCalls(calls, "framePositionClickEvent", function(self, frame) LU.assertEquals(frame, expectedFramePosition) end),
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = trackCalls(calls, "getScrollOffset", function() return playbackOffset end),
            getZoom = trackCalls(calls, "getZoom", function() return playbackLength end),
            getTimelineLength = trackCalls(calls, "getTimelineLength", function() return timelineLength end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePanel")
        instance.frameArea = {10, 110}

        instance:onMousePressed(MOUSE_LEFT)

        LU.assertTrue(calls.CursorPos > 0)
        LU.assertTrue(calls.getScrollOffset > 0)
        LU.assertTrue(calls.getZoom > 0)
        LU.assertTrue(calls.getTimelineLength > 0)
        LU.assertEquals(calls.framePositionClickEvent, 1)
    end,

    test_onMousePressed1 = function(self)
        self:performMousePressedTest(0, 100, 100, 20, 10)
    end,

    test_onMousePressed2 = function(self)
        self:performMousePressedTest(15, 20, 100, 30, 19)
    end,

    test_onMousePressed3 = function(self)
        self:performMousePressedTest(10, 30, 25, 80, 24)
    end,

    test_getLocalPositionFromFrame = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("MenuElements"):use({ mainMenu = { framePanel = {} } })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = trackCalls(calls, "getScrollOffset", function() return 17 end),
            getZoom = trackCalls(calls, "getZoom", function() return 50 end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePanel")
        c.frameArea = {10, 110}

        local result = instance:getLocalPositionFromFrame(21)

        LU.assertEquals(calls.getScrollOffset, 1)
        LU.assertEquals(calls.getZoom, 1)
        LU.assertEquals(result, 0.08)
    end,
}