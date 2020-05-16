TestFramePointer = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer.lua")[1],

    test_initialize = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            SetSize = trackCalls(calls, "SetSize", function(self, x, y)
                LU.assertEquals(x, 8)
                LU.assertEquals(y, 15)
            end)
        })

        instance:_initialize()
        LU.assertEquals(calls.SetSize, 1)
    end,

    test_setFrame = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            GetWide = trackCalls(calls, "GetWide", function(self) return 8 end),
            GetTall = trackCalls(calls, "GetTall", function(self) return 15 end),
            SetPos = trackCalls(calls, "SetPos", function(self, x, y)
                LU.assertEquals(x, 10 + 10 - 4)
                LU.assertEquals(y, 5 - 7.5)
            end),
            _framePanel = {
                frameArea = {10, 110},
                scrollOffset = 0,
                zoom = 100,
                GetTall = trackCalls(calls, "framePanel_GetTall", function(self) return 10 end),
            },
            verticalPosition = 0.5,
            _frame = 0,
        })

        instance:setFrame(10)
        LU.assertEquals(calls.GetWide, 1)
        LU.assertEquals(calls.GetTall, 1)
        LU.assertEquals(calls.SetPos, 1)
        LU.assertEquals(calls.framePanel_GetTall, 1)
    end,

    test_OnMousePressedLeft = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                LU.assertEquals(capture, true)
            end)
        })

        instance:OnMousePressed(MOUSE_LEFT)
        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(instance._outlineColor, {255, 255, 255, 255})
        LU.assertEquals(instance._dragging, true)
    end,

    test_OnMousePressedRight = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            _keyframeController = {
                delete = trackCalls(calls, "keyframeController_delete", function(self) end)
            }
        })

        instance:OnMousePressed(MOUSE_RIGHT)
        LU.assertEquals(calls.keyframeController_delete, 1)
    end,

    test_OnMousePressedMiddle = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            _keyframeController = {
                copy = trackCalls(calls, "keyframeController_copy", function(self) end)
            }
        })

        instance:OnMousePressed(MOUSE_MIDDLE)
        LU.assertEquals(calls.keyframeController_copy, 1)
    end,

    test_OnMouseReleasedNotDragging = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture) end),
            _dragging = false
        })

        instance:OnMouseReleased(MOUSE_LEFT)
        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_OnMouseReleasedOtherMousecode = function(self)
        local calls = {}
        local instance = wrapMetatables(self._ctr(), {
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture) end),
            _dragging = true
        })

        instance:OnMouseReleased(MOUSE_RIGHT)
        LU.assertEquals(calls.MouseCapture or 0, 0)
        instance:OnMouseReleased(MOUSE_MIDDLE)
        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_OnMouseReleased = function(self)
        local calls = {}
        local instance = wrapMetatables({
            _keyframeController = {
                setFrame = trackCalls(calls, "keyframeController_setFrame", function(self, frame)
                    LU.assertEquals(frame, 10)
                end)
            },
            _dragging = true,
            _outlineColor = {255, 255, 255, 255},
            _frame = 10,
        }, self._ctr(), {
            MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                LU.assertFalse(capture)
            end),
        })

        instance:OnMouseReleased(MOUSE_LEFT)
        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(calls.keyframeController_setFrame, 1)
        LU.assertEquals(instance._outlineColor, {0, 0, 0, 255})
        LU.assertEquals(instance._dragging, false)
    end,

    test_OnCursorMovedNotDragging = function(self)
        local calls = {}
        local instance = wrapMetatables({
            setFrame = trackCalls(calls, "setFrame", function(self) end),
            _dragging = false,
        }, self._ctr())

        instance:OnCursorMoved(0, 0)
        LU.assertEquals(calls.setFrame or 0, 0)
    end,

    test_OnCursorMovedFrameUnchanged = function(self)
        local calls = {}
        local instance = wrapMetatables({
            setFrame = trackCalls(calls, "setFrame", function(self) end),
            _dragging = true,
            _frame = 10,
            _framePanel = {
                scrollOffset = 0,
                zoom = 100,
                frameArea = {10, 110},
                timelineLength = 100,
            },
        }, self._ctr())

        instance:OnCursorMoved(20, 0)
        LU.assertEquals(calls.setFrame or 0, 0)
    end,

    test_OnCursorMoved = function(self)
        local calls = {}
        local instance = wrapMetatables({
            setFrame = trackCalls(calls, "setFrame", function(self) end),
            _dragging = true,
            _frame = 10,
            _framePanel = {
                scrollOffset = 0,
                zoom = 100,
                frameArea = {10, 110},
                timelineLength = 100,
            },
        }, self._ctr())

        instance:OnCursorMoved(25, 0)
        LU.assertEquals(calls.setFrame, 1)
    end,

    test_PaintNoFramePanel = function(self)
        local instance = wrapMetatables({
            _framePanel = nil,
        }, self._ctr())

        instance:Paint(0, 0)
    end,

    test_PaintNonDrawable = function(self)
        local instance = wrapMetatables({
            _framePanel = {
                scrollOffset = 10,
                zoom = 100,
            },
            _frame = 1,
        }, self._ctr())

        instance:Paint(0, 0)
    end,

    test_PaintNonPointy = function(self)
        local calls = {}
        local instance = wrapMetatables({
            _surfaceDrawer = {
                noTexture = trackCalls(calls, "drawEvent", function(self) end),
                setDrawColor = trackCalls(calls, "drawEvent", function(self) end),
                drawRect = trackCalls(calls, "drawEvent", function(self) end),
                drawLine = trackCalls(calls, "drawEvent", function(self) end),
                drawPoly = trackCalls(calls, "drawEvent", function(self) end),
            },
            _framePanel = {
                scrollOffset = 0,
                zoom = 100,
            },
            _frame = 1,
            _outlineColor = {255, 255, 255, 255},
            color = {255, 255, 255, 255},
            pointy = false,
        }, self._ctr())

        instance:Paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,

    test_PaintPointy = function(self)
        local calls = {}
        local instance = wrapMetatables({
            _surfaceDrawer = {
                noTexture = trackCalls(calls, "drawEvent", function(self) end),
                setDrawColor = trackCalls(calls, "drawEvent", function(self) end),
                drawRect = trackCalls(calls, "drawEvent", function(self) end),
                drawLine = trackCalls(calls, "drawEvent", function(self) end),
                drawPoly = trackCalls(calls, "drawEvent", function(self) end),
            },
            _framePanel = {
                scrollOffset = 0,
                zoom = 100,
            },
            _frame = 1,
            _outlineColor = {255, 255, 255, 255},
            color = {255, 255, 255, 255},
            pointy = true,
        }, self._ctr())

        instance:Paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,
}
