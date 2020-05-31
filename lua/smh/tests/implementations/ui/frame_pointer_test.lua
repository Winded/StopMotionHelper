TestFramePointer = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer.lua"),

    test_create = function(self)
        local calls = {}
        local element = {
            SetSize = trackCalls(calls, "SetSize", function() end),
            SetParent = trackCalls(calls, "SetParent", function() end),
        }
        local instance = self._ctr({
            element = {}
        }, {
            create = trackCalls(calls, "vguiFactoryCreate", function() return element end),
        }, nil, nil, nil, nil, nil)

        LU.assertEquals(calls.vguiFactoryCreate, 1)
        LU.assertEquals(calls.SetSize, 1)
        LU.assertEquals(calls.SetParent, 1)
        LU.assertNotNil(element.OnMousePressed)
        LU.assertNotNil(element.OnMouseReleased)
        LU.assertNotNil(element.OnCursorMoved)
        LU.assertNotNil(element.Paint)
    end,

    test_setFrame = function(self)
        local calls = {}
        local instance = self._ctr({
            frameArea = {10, 110},
            getTall = trackCalls(calls, "framePanel_getTall", function() return 10 end),
        }, {
            create = function()
                return {
                    GetWide = trackCalls(calls, "GetWide", function() return 8 end),
                    GetTall = trackCalls(calls, "GetTall", function() return 15 end),
                    SetPos = trackCalls(calls, "SetPos", function(self, x, y)
                        LU.assertEquals(x, 10 + 10 - 4)
                        LU.assertEquals(y, 5 - 7.5)
                    end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, {
            getScrollOffset = trackCalls(calls, "getScrollOffset", function() return 0 end),
            getZoom = trackCalls(calls, "getZoom", function() return 100 end),
        })
        instance.verticalPosition = 0.5

        instance:setFrame(10)

        LU.assertEquals(calls.GetWide, 1)
        LU.assertEquals(calls.GetTall, 1)
        LU.assertEquals(calls.SetPos, 1)
        LU.assertEquals(calls.framePanel_getTall, 1)
        LU.assertTrue(calls.getScrollOffset > 0)
        LU.assertTrue(calls.getZoom > 0)
    end,

    test_onMousePressed_left = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                        LU.assertEquals(capture, true)
                    end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, {
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_LEFT)
            end),
        }, nil, nil)

        instance:onMousePressed(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(calls.framePointerClickEvent, 1)
        LU.assertEquals(instance._outlineColor, {255, 255, 255, 255})
        LU.assertEquals(instance._dragging, true)
    end,

    test_onMousePressed_right = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, {
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_RIGHT)
            end),
        }, nil, nil)

        instance:onMousePressed(MOUSE_RIGHT)

        LU.assertEquals(calls.framePointerClickEvent, 1)
    end,

    test_onMousePressed_middle = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, {
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_MIDDLE)
            end),
        }, nil, nil)

        instance:onMousePressed(MOUSE_MIDDLE)

        LU.assertEquals(calls.framePointerClickEvent, 1)
    end,

    test_onMouseReleased_notDragging = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function() end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, nil, nil, nil)

        instance:onMouseReleased(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_onMouseReleased_otherMousecode = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function() end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, nil, nil, nil)
        instance._dragging = true

        instance:onMouseReleased(MOUSE_RIGHT)
        LU.assertEquals(calls.MouseCapture or 0, 0)
        instance:onMouseReleased(MOUSE_MIDDLE)
        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_onMouseReleased = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function() end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, nil, {
            send = trackCalls(calls, "framePointerReleaseEvent", function(self, element, frame) LU.assertEquals(frame, 10) end),
        }, nil)
        instance._dragging = true
        instance._outlineColor = {255, 255, 255, 255}
        instance._frame = 10

        instance:onMouseReleased(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(calls.framePointerReleaseEvent, 1)
        LU.assertEquals(instance._outlineColor, {0, 0, 0, 255})
        LU.assertEquals(instance._dragging, false)
    end,

    test_onCursorMoved_notDragging = function(self)
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, nil, nil, nil, nil)

        instance:onCursorMoved(0, 0)
    end,

    test_onCursorMoved_frameUnchanged = function(self)
        local instance = self._ctr({
            frameArea = {10, 110},
        }, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, {
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
            getTimelineLength = function() return 100 end,
        })
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(20, 0)
    end,

    test_onCursorMoved = function(self)
        local calls = {}
        local instance = self._ctr({
            frameArea = {10, 110},
            getTall = function() return 1 end,
        }, {
            create = function()
                return {
                    GetWide = function() return 1 end,
                    GetTall = function() return 1 end,
                    SetPos = function() end,
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, {
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
            getTimelineLength = function() return 100 end,
        }, nil, nil, {
            send = trackCalls(calls, "framePointerMoveEvent", function(self, element, frame) LU.assertEquals(frame, 15) end),
        })
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(25, 0)

        LU.assertEquals(calls.framePointerMoveEvent, 1)
        LU.assertEquals(instance._frame, 15)
    end,

    test_paint_notDrawable = function(self)
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, nil, {
            getScrollOffset = function() return 10 end,
            getZoom = function() return 100 end,
        }, nil, nil, nil)
        instance._frame = 1

        instance:paint(0, 0)
    end,

    test_paint_nonPointy = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, {
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        }, {
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
        }, nil, nil, nil)
        instance._frame = 1

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,

    test_paint_pointy = function(self)
        local calls = {}
        local instance = self._ctr({}, {
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        }, {
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        }, {
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
        }, nil, nil, nil)
        instance._frame = 1
        instance.pointy = true

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,
}
