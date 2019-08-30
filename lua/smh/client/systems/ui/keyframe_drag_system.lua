local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventFramePointerDragStop(element)
    if element.KeyframeId ~= nil then
        self.sequencer:Next("UpdateKeyframe", element.KeyframeId, { Position = element.FramePosition })
    elseif element.CopiedKeyframeId ~= nil then
        self.sequencer:Next("CopyKeyframe", element.CopiedKeyframeId)
    end
end

SMH.Systems.Register("KeyframeDragSystem", SYS)