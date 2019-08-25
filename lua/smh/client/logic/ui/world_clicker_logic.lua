return function setup(element, traceEvent)
    element.OnMousePressed = function(self, mousecode)
        if mousecode ~= MOUSE_RIGHT then
            return
        end

        local trace = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
        traceEvent(trace)
    end

    local visibilityChangedEventListener = function(visible)
        if not visible then
            RememberCursorPosition()
        end
        clicker:SetVisible(visible)
        if visible then
            RestoreCursorPosition()
        end
    end

    return visibilityChangedEventListener
end