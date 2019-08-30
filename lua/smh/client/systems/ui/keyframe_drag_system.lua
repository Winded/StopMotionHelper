local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventKeyframeMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    element:MouseCapture(true)
    element.Dragging = true
end

function SYS:EventKeyframeMouseReleased(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT or not element.Dragging then
        return
    end

    element:MouseCapture(false)
    element.Dragging = false

    self.sequencer:Next(self, "UpdateKeyframe", element.KeyframeId, { Position = targetPos })
end

function SYS:EventKeyframeCursorMoved(element, cursorX, cursorY)
    if not element.Dragging then
        return
    end

    local panel = element.FramePanel

    local startX, endX = unpack(panel.FrameArea)
	
    local targetX = cursorX - startX
    local width = endX - startX

    local targetPos = math.Round(panel.ScrollOffset + (targetX / width) * panel.Zoom)
    targetPos = targetPos < 0 and 0 or (targetPos > panel.TotalFrames and panel.TotalFrames - 1 or targetPos)
end