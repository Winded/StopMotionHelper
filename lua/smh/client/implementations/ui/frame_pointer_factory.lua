local ctr = function(surfaceDrawer, frameChangeListener, vguiFactory)
    local PANEL = smhInclude("/smh/client/implementations/ui/frame_pointer.lua")

    return {
        _surfaceDrawer = surfaceDrawer,
        _frameChangeListener = frameChangeListener,
        _vguiFactory = vguiFactory,

        initialize = function(self)
            self._vguiFactory:register("SMHFramePointer", PANEL, "DPanel")
        end,

        create = function(self, framePanel, color, pointy)
            local pointer = self._vguiFactory:create("SMHFramePointer")
            pointer:_initialize(self._surfaceDrawer, self._frameChangeListener, framePanel, color, pointy)
            pointer:SetParent(framePanel)

            return pointer
        end,
    }
end

return {ctr, "surfaceDrawer", "frameChangeListener", "vguiFactory"}