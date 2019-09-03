local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    element:MouseCapture(true)
    element.Dragging = true
end

function SYS:EventMouseReleased(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    element:MouseCapture(false)
    element.Dragging = false
end

function SYS:EventCursorMoved(element, cursorXOffset)
    if not element.Dragging then
        return
    end

    local panel = element:GetParent()

    local cursorX, _ = panel:CursorPos();
    local movePos = (cursorX - cursorXOffset) - panel.ScrollBarAreaPosition[1];

    local movableWidth = panel.ScrollBarAreaSize[1] - element:GetWide();
    if movableWidth ~= 0 then
        local numSteps = panel.TimelineLength - panel.Zoom;
        local targetScrollOffset = math.Round((movePos / movableWidth) * numSteps);

        if targetScrollOffset >= 0 and targetScrollOffset <= numSteps and targetScrollOffset ~= panel.ScrollOffset then
            panel.ScrollOffset = targetScrollOffset
        end
    elseif panel.ScrollOffset ~= 0 then
        panel.ScrollOffset = 0
    end

    self.sequencer:Next(self, "RefreshFramePanel", panel)
end

SMH.Systems.Register("ScrollbarDragSystem", SYS)