return function(surfaceDrawer, vguiFactory, serverCommands)
    local PANEL = smhInclude("/smh/client/implementations/ui/frame_panel.lua")

    return {
        _surfaceDrawer = surfaceDrawer,
        _vguiFactory = vguiFactory,
        _serverCommands = serverCommands,

        initialize = function(self)
            self._vguiFactory:register("SMHFramePanel", PANEL, "DPanel")
        end,

        create = function(self, menu)
            local panel = self._vguiFactory:create("SMHFramePanel")
            panel:_initialize({}, self._surfaceDrawer, self._serverCommands)
            panel:SetParent(menu)

            return panel
        end,
    }
end