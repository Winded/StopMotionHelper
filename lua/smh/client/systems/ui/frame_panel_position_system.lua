local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    local startX, endX = unpack(element.FrameArea)
    local posX, posY = element:CursorPos()

    local targetX = posX - startX
    local width = endX - startX
    local framePosition = math.Round(element.ScrollOffset + (targetX / width) * element.Zoom)
    framePosition = framePosition < 0 and 0 or (framePosition >= element.TimelineLength and element.TimelineLength - 1 or framePosition)

    local playhead = element.Playhead

    if playhead.FramePosition == nil or playhead.FramePosition ~= framePosition then
        self.sequencer:Next(self, "SetFramePointerPosition", playhead, framePosition)
    end

    playhead.FramePosition = framePosition
end