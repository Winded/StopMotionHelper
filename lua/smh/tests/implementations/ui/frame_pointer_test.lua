TestFramePointer = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer.lua"),

    test_setFrame = function(self)
        local calls = {}
        local instance = self._ctr({
            GetWide = trackCalls(calls, "GetWide", function() return 8 end),
            GetTall = trackCalls(calls, "GetTall", function() return 15 end),
            SetPos = trackCalls(calls, "SetPos", function(self, x, y)
                LU.assertEquals(x, 10 + 10 - 4)
                LU.assertEquals(y, 5 - 7.5)
            end),
        }, {
            frameArea = {10, 110},
            scrollOffset = 0,
            zoom = 100,
            getTall = trackCalls(calls, "framePanel_getTall", function() return 10 end),
        }, nil, nil, 0.5, nil, nil)

        instance:setFrame(10)
        LU.assertEquals(calls.GetWide, 1)
        LU.assertEquals(calls.GetTall, 1)
        LU.assertEquals(calls.SetPos, 1)
        LU.assertEquals(calls.framePanel_getTall, 1)
    end,

    test_onMousePressed_left = function(self)
        local calls = {}
        local instance = self._ctr({
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                LU.assertEquals(capture, true)
            end)
        }, nil, nil, nil, 0, nil, nil)

        instance:onMousePressed(MOUSE_LEFT)
        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(instance._outlineColor, {255, 255, 255, 255})
        LU.assertEquals(instance._dragging, true)
    end,

    test_onMousePressed_right = function(self)
        local calls = {}
        local instance = self._ctr(nil, nil, nil, {
            onRightClick = trackCalls(calls, "onRightClick", function() end)
        }, 0, nil, nil)

        instance:onMousePressed(MOUSE_RIGHT)
        LU.assertEquals(calls.onRightClick, 1)
    end,

    test_onMousePressed_middle = function(self)
        local calls = {}
        local instance = self._ctr(nil, nil, nil, {
            onMiddleClick = trackCalls(calls, "onMiddleClick", function() end)
        }, 0, nil, nil)

        instance:onMousePressed(MOUSE_MIDDLE)
        LU.assertEquals(calls.onMiddleClick, 1)
    end,

    test_onMouseReleased_notDragging = function(self)
        local calls = {}
        local instance = self._ctr({
            MouseCapture = trackCalls(calls, "MouseCapture", function() end),
        }, nil, nil, nil, 0, nil, nil)

        instance:onMouseReleased(MOUSE_LEFT)
        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_onMouseReleased_otherMousecode = function(self)
        local calls = {}
        local instance = self._ctr({
            MouseCapture = trackCalls(calls, "MouseCapture", function() end),
        }, nil, nil, nil, 0, nil, nil)
        instance._dragging = true

        instance:onMouseReleased(MOUSE_RIGHT)
        LU.assertEquals(calls.MouseCapture or 0, 0)
        instance:onMouseReleased(MOUSE_MIDDLE)
        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_onMouseReleased = function(self)
        local calls = {}
        local instance = self._ctr({
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                LU.assertFalse(capture)
            end),
        }, nil, nil, {
            onRelease = trackCalls(calls, "onRelease", function(self, frame)
                LU.assertEquals(frame, 10)
            end)
        }, 0, nil, nil)
        instance._dragging = true
        instance._outlineColor = {255, 255, 255, 255}
        instance._frame = 10

        instance:onMouseReleased(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(calls.onRelease, 1)
        LU.assertEquals(instance._outlineColor, {0, 0, 0, 255})
        LU.assertEquals(instance._dragging, false)
    end,

    test_onCursorMoved_notDragging = function(self)
        local instance = self._ctr(nil, nil, nil, nil, 0, nil, nil)

        instance:onCursorMoved(0, 0)
    end,

    test_onCursorMoved_frameUnchanged = function(self)
        local instance = self._ctr(nil, {
            scrollOffset = 0,
            zoom = 100,
            frameArea = {10, 110},
            timelineLength = 100,
        }, nil, nil, 0, nil, nil)
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(20, 0)
    end,

    test_onCursorMoved = function(self)
        local instance = self._ctr({
            GetWide = function() return 1 end,
            GetTall = function() return 1 end,
            SetPos = function() end,
        }, {
            scrollOffset = 0,
            zoom = 100,
            frameArea = {10, 110},
            timelineLength = 100,
            getTall = function() return 1 end,
        }, nil, nil, 0, nil, nil)
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(25, 0)
        LU.assertEquals(instance._frame, 15)
    end,

    test_paint_noFramePanel = function(self)
        local instance = self._ctr(nil, nil, nil, nil, 0, nil, nil)

        instance:paint(0, 0)
    end,

    test_paint_notDrawable = function(self)
        local instance = self._ctr(nil, {
            scrollOffset = 10,
            zoom = 100,
        }, nil, nil, 0, nil, nil)
        instance._frame = 1

        instance:paint(0, 0)
    end,

    test_paint_nonPointy = function(self)
        local calls = {}
        local instance = self._ctr(nil, {
            scrollOffset = 0,
            zoom = 100,
        }, {
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        }, nil, 5, {255, 255, 255, 255}, false)
        instance._frame = 1

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,

    test_paint_pointy = function(self)
        local calls = {}
        local instance = self._ctr(nil, {
            scrollOffset = 0,
            zoom = 100,
        }, {
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        }, nil, 5, {255, 255, 255, 255}, true)
        instance._frame = 1

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,
}
