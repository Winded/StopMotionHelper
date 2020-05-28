TestFramePanelFactory = {
    _ctr = smhInclude("/smh/client/implementations/ui/frame_panel_factory.lua"),

    test_create = function(self)
        local element = {}
        local instance = self._ctr(nil, nil)

        instance:create(element)
        
        LU.assertNotNil(element.PerformLayout)
        LU.assertNotNil(element.Paint)
        LU.assertNotNil(element.OnMouseWheeled)
        LU.assertNotNil(element.OnMousePressed)
    end,
}
