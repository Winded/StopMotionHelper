local ctr = function(surfaceDrawer, vguiFactory, serverCommands, mathUtility)
    local PANEL = smhInclude("/smh/client/implementations/ui/frame_panel.lua")

    return {
        _surfaceDrawer = surfaceDrawer,
        _vguiFactory = vguiFactory,
        _serverCommands = serverCommands,
        _mathUtility = mathUtility,

        initialize = function(self)
            self._vguiFactory:register("SMHFramePanel", PANEL, "DPanel")
        end,

        create = function(self, menu)
            local panel = self._vguiFactory:create("SMHFramePanel")
            panel:_initialize({}, self._surfaceDrawer, self._serverCommands, self._mathUtility)
            panel:SetParent(menu)

            return panel
        end,
    }
end

return {ctr, "surfaceDrawer", "vguiFactory", "serverCommands", "mathUtility"}