local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventFramePointerDragStart(element)
    element:MouseCapture(true)
    element.OutlineColor = Color(255, 255, 255)
    element.Dragging = true
end

function SYS:EventFramePointerDragStop(element)
    if not element.Dragging then
        return
    end

    element:MouseCapture(false)
    element.OutlineColor = Color(0, 0, 0)
    element.Dragging = false
end

function SYS:EventFramePointerCursorMoved(element, cursorX, cursorY)
    if not element.Dragging then
        return
    end

    local panel = element.FramePanel

    local startX, endX = unpack(panel.FrameArea)
	
    local targetX = cursorX - startX
    local width = endX - startX

    local targetPos = math.Round(panel.ScrollOffset + (targetX / width) * panel.Zoom)
    targetPos = targetPos < 0 and 0 or (targetPos > panel.TotalFrames and panel.TotalFrames - 1 or targetPos)

    if element.FramePosition == nil or element.FramePosition ~= targetPos then
        self.sequencer:Next(self, "SetFramePointerPosition", element, targetPos)
    end

    element.FramePosition = targetPos
end

SMH.Systems.Register("FramePointerDragSystem", SYS)