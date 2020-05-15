local ctr = function(framePointerMetatable, surfaceDrawer, frameChangeListener, vguiFactory)
    return {
        _framePointerMetatable = framePointerMetatable,
        _surfaceDrawer = surfaceDrawer,
        _frameChangeListener = frameChangeListener,
        _vguiFactory = vguiFactory,

        initialize = function(self)
            self._vguiFactory:register("SMHFramePointer", self._framePointerMetatable, "DPanel")
        end,

        create = function(self, framePanel, verticalPosition, color, pointy)
            local pointer = self._vguiFactory:create("SMHFramePointer")
            pointer:_initialize(self._surfaceDrawer, self._frameChangeListener, framePanel, verticalPosition, color, pointy)
            pointer:SetParent(framePanel)

            return pointer
        end,
    }
end

return {ctr, "framePointerMetatable", "surfaceDrawer", "frameChangeListener", "vguiFactory"}