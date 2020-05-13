TestFramePointer = {
    _cfg = {
        surfaceDrawer = includeMock("/gmod/surface_drawer.lua"),
        frameChangeListener = includeMock("/frame_change_listener.lua"),
        vguiFactory = includeMock("/gmod/vgui_factory.lua"),
        framePointerFactory = smhInclude("/smh/client/implementations/ui/frame_pointer_factory.lua"),
    },

    createElement = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local factory = c:get("framePointerFactory")
        factory:initialize()

        local vguiFactory = c:get("vguiFactory")
        local panel =  vguiFactory:create("SMHFramePointer")
        panel.frameArea = {10, 110}
        panel.scrollOffset = 0
        panel.zoom = 100
        panel.timelineLength = 100
        panel:SetSize(120, 10)

        local element = factory:create(panel, 0.5, {255, 255, 255, 255}, false)
        self.c = c
        return element
    end,

    test_initializeFactory = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local factory = c:get("framePointerFactory")
        factory:initialize()

        local vguiFactoryMock = c:get("vguiFactory")
        LU.assertNotNil(vguiFactoryMock.registeredElements["SMHFramePointer"])
        LU.assertEquals(vguiFactoryMock.registeredElements["SMHFramePointer"][2], "DPanel")
    end,

    test_factoryCreate = function(self)
        local element = self:createElement()

        LU.assertNotNil(element._framePanel)
        LU.assertEquals(element.verticalPosition, 0.5)
        LU.assertEquals(element.color, {255, 255, 255, 255})
        LU.assertEquals(element.pointy, false)

        LU.assertEquals(element.vgui_size, {8, 15})
        LU.assertEquals(element.vgui_parent, element._framePanel)

        LU.assertEquals(element:getFrame(), 0)
    end,

    test_setFrame = function(self)
        local element = self:createElement()

        LU.assertEquals(element.vgui_size, {8, 15})

        element:setFrame(10)
        LU.assertEquals(element.vgui_pos, {10 + 10 - 4, 5 - 7.5})
        LU.assertEquals(element:getFrame(), 10)
    end,

    test_OnMousePressed = function(self)
        local element = self:createElement()
        
        element:OnMousePressed(MOUSE_RIGHT)
        LU.assertNil(element.vgui_mouseCaptured)
        LU.assertEquals(element._outlineColor, {0, 0, 0, 255})
        LU.assertFalse(element._dragging)
        
        element:OnMousePressed(MOUSE_LEFT)
        LU.assertTrue(element.vgui_mouseCaptured)
        LU.assertEquals(element._outlineColor, {255, 255, 255, 255})
        LU.assertTrue(element._dragging)
    end,

    test_OnMouseReleased = function(self)
        local element = self:createElement()
        
        element:OnMouseReleased(MOUSE_RIGHT)
        LU.assertNil(element.vgui_mouseCaptured)
        element:OnMouseReleased(MOUSE_LEFT)
        LU.assertNil(element.vgui_mouseCaptured)
        
        element:OnMousePressed(MOUSE_LEFT)
        LU.assertTrue(element.vgui_mouseCaptured)
        LU.assertTrue(element._dragging)

        element:OnMouseReleased(MOUSE_RIGHT)
        LU.assertTrue(element.vgui_mouseCaptured)
        
        element:OnMouseReleased(MOUSE_LEFT)
        LU.assertFalse(element.vgui_mouseCaptured)
        LU.assertEquals(element._outlineColor, {0, 0, 0, 255})
        LU.assertFalse(element._dragging)
    end,

    test_OnCursorMoved = function(self)
        local element = self:createElement()
        local frameChangeListener = self.c:get("frameChangeListener")

        element:OnCursorMoved(50, 0)
        LU.assertEquals(element:getFrame(), 0)

        element:OnMousePressed(MOUSE_LEFT)
        LU.assertTrue(element.vgui_mouseCaptured)

        element:OnCursorMoved(50, 0)
        LU.assertEquals(element:getFrame(), 40)
        LU.assertEquals(frameChangeListener.frameChangeCalledCount, 1)

        element:OnCursorMoved(50, 0)
        LU.assertEquals(element:getFrame(), 40)
        LU.assertEquals(frameChangeListener.frameChangeCalledCount, 1)

        element:OnCursorMoved(49, 0)
        LU.assertEquals(element:getFrame(), 39)
        LU.assertEquals(frameChangeListener.frameChangeCalledCount, 2)

        element:OnCursorMoved(-10, 0)
        LU.assertEquals(element:getFrame(), 0)
        LU.assertEquals(frameChangeListener.frameChangeCalledCount, 3)

        element:OnCursorMoved(200, 0)
        LU.assertEquals(element:getFrame(), 99)
        LU.assertEquals(frameChangeListener.frameChangeCalledCount, 4)
    end,

    test_Paint = function(self)
        local element = self:createElement()
        local surfaceDrawer = self.c:get("surfaceDrawer")

        local paintData = smhInclude("/smh/tests/data/frame_pointer_paint_data.lua")

        element:Paint(element:GetWide(), element:GetTall())
        LU.assertEquals(inspect(surfaceDrawer.drawEvents, { depth = 10, newline = "", indent = "" }), paintData.SQUARE)

        surfaceDrawer.drawEvents = {}

        element.pointy = true
        element:Paint(element:GetWide(), element:GetTall())
        LU.assertEquals(inspect(surfaceDrawer.drawEvents, { depth = 10, newline = "", indent = "" }), paintData.POINTY)

        surfaceDrawer.drawEvents = {}

        element:setFrame(-1)
        element:Paint(element:GetWide(), element:GetTall())
        LU.assertEquals(#surfaceDrawer.drawEvents, 0)
    end,
}
