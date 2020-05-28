local CTR = smhInclude("/smh/client/implementations/ui/frame_panel.lua")

return function(surfaceDrawer, playbackManager)
    return {
        create = function(self, element)
            local panel = CTR(element, surfaceDrawer, playbackManager)

            element.PerformLayout = function(self, ...) panel:performLayout(...) end
            element.Paint = function(self, ...) panel:paint(...) end
            element.OnMouseWheeled = function(self, ...) panel:onMouseWheeled(...) end
            element.OnMousePressed = function(self, ...) panel:onMousePressed(...) end

            return panel
        end,
    }
end