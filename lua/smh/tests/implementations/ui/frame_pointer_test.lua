TestFramePointer = {
    _cfg = {
        surfaceDrawer = includeMock("/gmod/surface_drawer.lua"),
        frameChangeListener = includeMock("/frame_change_listener.lua"),
        vguiFactory = includeMock("/gmod/vgui_factory.lua"),
        framePointerFactory = smhInclude("/smh/client/implementations/ui/frame_pointer_factory.lua"),
    },

    test_initializeFactory = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local factory = c:get("framePointerFactory")
        factory:initialize()

        local vguiFactoryMock = c:get("vguiFactory")
        LU.assertNotNil(vguiFactoryMock.registeredElements["SMHFramePointer"])
        LU.assertEquals(vguiFactoryMock.registeredElements["SMHFramePointer"][2], "DPanel")
    end,

    test_createElement = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local factory = c:get("framePointerFactory")
        factory:initialize()

        local vguiFactory = c:get("vguiFactory")
        local panel =  vguiFactory:create("SMHFramePointer")

        local element = factory:create(panel, 0, {255, 255, 255, 255}, false)

        LU.assertEquals(element.verticalPosition, 0)
        LU.assertEquals(element.color, {255, 255, 255, 255})
        LU.assertEquals(element.pointy, false)

        LU.assertEquals(element.vgui_size, {8, 15})
        LU.assertEquals(element.vgui_parent, panel)

        LU.assertEquals(element:getFrame(), 0)
    end,

    test_setFrame = function(self)
        local c = Ludi.newContainer()
        c:addConfig(self._cfg)

        local factory = c:get("framePointerFactory")
        factory:initialize()

        local vguiFactory = c:get("vguiFactory")
        local panel =  vguiFactory:create("SMHFramePointer")
        panel.frameArea = {10, 110}
        panel.scrollOffset = 0
        panel.zoom = 100
        panel.vgui_size = {120, 10}

        local element = factory:create(panel, 0.5, {255, 255, 255, 255}, false)
        LU.assertEquals(element.vgui_size, {8, 15})

        element:setFrame(10)
        LU.assertEquals(element.vgui_pos, {10 + 10 - 4, 5 - 7.5})
        LU.assertEquals(element:getFrame(), 10)
    end,
}
