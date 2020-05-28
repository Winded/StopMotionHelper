TestFramePanel = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_panel.lua"),

    performPaintTest = function(self, playbackOffset, playbackLength, timelineLength, expectedDrawCalls)
        local calls = {}
        local instance = self._ctr({
            GetTall = trackCalls(calls, "GetTall", function() return 10 end),
        }, {
            setDrawColor = function() end,
            drawLine = trackCalls(calls, "drawLine", function() end),
        }, {
            getPlaybackOffset = trackCalls(calls, "getPlaybackOffset", function() return playbackOffset end),
            getPlaybackLength = trackCalls(calls, "getPlaybackLength", function() return playbackLength end),
            getTimelineLength = trackCalls(calls, "getTimelineLength", function() return timelineLength end),
        })

        instance:paint()

        LU.assertTrue(calls.GetTall > 0)
        LU.assertTrue(calls.getPlaybackOffset > 0)
        LU.assertTrue(calls.getPlaybackLength > 0)
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
        local instance = self._ctr(nil, nil, {
            getPlaybackLength = trackCalls(calls, "getPlaybackLength", function() return 10 end),
            setPlaybackLength = trackCalls(calls, "setPlaybackLength", function(self, length) LU.assertEquals(length, 11) end),
        })

        instance:onMouseWheeled(-1)

        LU.assertEquals(calls.getPlaybackLength, 1)
        LU.assertEquals(calls.setPlaybackLength, 1)
    end,

    test_onMousePressed_notLeftButton = function(self)
        local instance = self._ctr(nil, nil, nil)

        instance:onMousePressed(MOUSE_MIDDLE)
        instance:onMousePressed(MOUSE_RIGHT)
    end,

    performMousePressedTest = function(self, playbackOffset, playbackLength, timelineLength, cursorPosX, expectedFramePosition)
        local calls = {}
        local instance = self._ctr({
            CursorPos = trackCalls(calls, "CursorPos", function() return cursorPosX, 0 end),
        }, nil, {
            getPlaybackOffset = trackCalls(calls, "getPlaybackOffset", function() return playbackOffset end),
            getPlaybackLength = trackCalls(calls, "getPlaybackLength", function() return playbackLength end),
            getTimelineLength = trackCalls(calls, "getTimelineLength", function() return timelineLength end),
            setFrame = trackCalls(calls, "setFrame", function(self, frame) LU.assertEquals(frame, expectedFramePosition) end),
        })
        instance.frameArea = {10, 110}

        instance:onMousePressed(MOUSE_LEFT)

        LU.assertTrue(calls.CursorPos > 0)
        LU.assertTrue(calls.getPlaybackOffset > 0)
        LU.assertTrue(calls.getPlaybackLength > 0)
        LU.assertTrue(calls.getTimelineLength > 0)
        LU.assertEquals(calls.setFrame, 1)
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
}