local CTR = smhInclude("/smh/client/implementations/ui/frame_pointer.lua")

return function(surfaceDrawer, vguiFactory)
    return {
        create = function(self, framePanel, frameEventListener, verticalPosition, color, pointy)
            local element = vguiFactory:create("DPanel")
            local pointer = CTR(element, framePanel, surfaceDrawer, frameEventListener, verticalPosition, color, pointy)
            
            element.OnMousePressed = function(self, ...) pointer:onMousePressed(...) end
            element.OnMouseReleased = function(self, ...) pointer:onMouseReleased(...) end
            element.OnCursorMoved = function(self, ...) pointer:onCursorMoved(...) end
            element.Paint = function(self, ...) pointer:paint(...) end
            element:SetParent(framePanel.element)
            element:SetSize(8, 15)

            return pointer
        end,
    }
end