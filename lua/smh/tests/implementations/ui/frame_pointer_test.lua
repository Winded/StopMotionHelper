TestFramePointer = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_pointer.lua"),

    makeRegistry = function(self)
        local r = makeTestRegistry()
        r:forType("FramePointer"):use(self._ctr)
        return r
    end,

    test_create = function(self)
        local calls = {}
        local element = {
            SetSize = trackCalls(calls, "SetSize", function() end),
            SetParent = trackCalls(calls, "SetParent", function() end),
        }
        local r = self:makeRegistry()
        r:forType("FramePanel"):use({
            element = {}
        })
        r:forType("VguiFactory"):use({
            create = trackCalls(calls, "vguiFactoryCreate", function() return element end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

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
        local r = self:makeRegistry()
        r:forType("FramePanel"):use({
            getTall = trackCalls(calls, "framePanel_getTall", function() return 10 end),
            getLocalPositionFromFrame = trackCalls(calls, "framePanel_getLocalPositionFromFrame", function() return 20 end),
        })
        r:forType("VguiFactory"):use({
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
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = trackCalls(calls, "getScrollOffset", function() return 0 end),
            getZoom = trackCalls(calls, "getZoom", function() return 100 end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance.verticalPosition = 0.5

        instance:setFrame(10)

        LU.assertEquals(calls.GetWide, 1)
        LU.assertEquals(calls.GetTall, 1)
        LU.assertEquals(calls.SetPos, 1)
        LU.assertEquals(calls.framePanel_getTall, 1)
        LU.assertTrue(calls.framePanel_getLocalPositionFromFrame > 0)
    end,

    test_onMousePressed_left = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function(self, capture)
                        LU.assertEquals(capture, true)
                    end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FramePointerClickEvent"):use({
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_LEFT)
            end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

        instance:onMousePressed(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture, 1)
        LU.assertEquals(calls.framePointerClickEvent, 1)
        LU.assertEquals(instance._outlineColor, {255, 255, 255, 255})
        LU.assertEquals(instance._dragging, true)
    end,

    test_onMousePressed_right = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FramePointerClickEvent"):use({
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_RIGHT)
            end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

        instance:onMousePressed(MOUSE_RIGHT)

        LU.assertEquals(calls.framePointerClickEvent, 1)
    end,

    test_onMousePressed_middle = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FramePointerClickEvent"):use({
            send = trackCalls(calls, "framePointerClickEvent", function(self, element, mouseCode)
                LU.assertEquals(mouseCode, MOUSE_MIDDLE)
            end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

        instance:onMousePressed(MOUSE_MIDDLE)

        LU.assertEquals(calls.framePointerClickEvent, 1)
    end,

    test_onMouseReleased_notDragging = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function() end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

        instance:onMouseReleased(MOUSE_LEFT)

        LU.assertEquals(calls.MouseCapture or 0, 0)
    end,

    test_onMouseReleased = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    MouseCapture = trackCalls(calls, "MouseCapture", function() end),
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FramePointerReleaseEvent"):use({
            send = trackCalls(calls, "framePointerReleaseEvent", function(self, element, frame) LU.assertEquals(frame, 10) end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
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
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")

        instance:onCursorMoved(0, 0)
    end,

    test_onCursorMoved_frameUnchanged = function(self)
        local r = self:makeRegistry()
        r:forType("FramePanel"):use({
            frameArea = {10, 110},
            getFrameFromScreenPosition = function() return 10 end,
        })
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FrameTimelineSettings"):use({
            getTimelineLength = function() return 100 end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(20, 0)
    end,

    test_onCursorMoved = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("FramePanel"):use({
            frameArea = {10, 110},
            getTall = function() return 1 end,
            getFrameFromScreenPosition = function() return 15 end,
            getLocalPositionFromFrame = function() return 0 end,
        })
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    GetWide = function() return 1 end,
                    GetTall = function() return 1 end,
                    SetPos = function() end,
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FrameTimelineSettings"):use({
            getTimelineLength = function() return 100 end,
        })
        r:forType("FramePointerMoveEvent"):use({
            send = trackCalls(calls, "framePointerMoveEvent", function(self, element, frame) LU.assertEquals(frame, 15) end),
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance._dragging = true
        instance._frame = 10

        instance:onCursorMoved(25, 0)

        LU.assertEquals(calls.framePointerMoveEvent, 1)
        LU.assertEquals(instance._frame, 15)
    end,

    test_paint_notDrawable = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = function() return 10 end,
            getZoom = function() return 100 end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance._frame = 1

        instance:paint(0, 0)
    end,

    test_paint_nonPointy = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("SurfaceDrawer"):use({
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance._frame = 1

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,

    test_paint_pointy = function(self)
        local calls = {}
        local r = self:makeRegistry()
        r:forType("VguiFactory"):use({
            create = function()
                return {
                    SetSize = function() end,
                    SetParent = function() end,
                }
            end,
        })
        r:forType("SurfaceDrawer"):use({
            noTexture = trackCalls(calls, "drawEvent", function() end),
            setDrawColor = trackCalls(calls, "drawEvent", function() end),
            drawRect = trackCalls(calls, "drawEvent", function() end),
            drawLine = trackCalls(calls, "drawEvent", function() end),
            drawPoly = trackCalls(calls, "drawEvent", function() end),
        })
        r:forType("FrameTimelineSettings"):use({
            getScrollOffset = function() return 0 end,
            getZoom = function() return 100 end,
        })
        local c = Ludi.Container.new(r)
        local instance = c:get("FramePointer")
        instance._frame = 1
        instance.pointy = true

        instance:paint(8, 15)
        LU.assertTrue(calls.drawEvent > 0)
    end,
}
