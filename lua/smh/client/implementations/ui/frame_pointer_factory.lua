return function(framePointerMetatable, surfaceDrawer, vguiFactory)
    return {
        _framePointerMetatable = framePointerMetatable,
        _surfaceDrawer = surfaceDrawer,
        _vguiFactory = vguiFactory,

        initialize = function(self)
            self._vguiFactory:register("SMHFramePointer", self._framePointerMetatable, "DPanel")
        end,

        create = function(self, keyframeController, framePanel, verticalPosition, color, pointy)
            local pointer = self._vguiFactory:create("SMHFramePointer")
            pointer:_initialize(self._surfaceDrawer, keyframeController, framePanel, verticalPosition, color, pointy)
            pointer:SetParent(framePanel)

            return pointer
        end,
    }
end