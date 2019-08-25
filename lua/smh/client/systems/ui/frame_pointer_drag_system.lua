local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    element:MouseCapture(true)

    element.Dragging = true
end

function SYS:EventMouseReleased(element, mouseCode)
    if not element.Dragging then
        return
    end

    element:MouseCapture(false)

    element.Dragging = false
end

function SYS:EventCursorMoved(element, cursorX, cursorY)
    if not element.Dragging then
        return
    end

    local panel = element.FramePanel

    local startX, endX = unpack(panel.FrameArea)
	
    local targetX = cursorX - startX
    local width = endX - startX

    local targetPos = math.Round(panel.ScrollOffset + (targetX / width) * panel.Zoom)
    targetPos = targetPos < 0 and 0 or (targetPos > panel.TotalFrames and panel.TotalFrames - 1 or targetPos)

    self.sequencer:Next(self, "UpdateFrame", element.FrameId, { Position = targetPos })
end