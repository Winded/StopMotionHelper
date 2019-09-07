local SYS = {}

function SYS:Init(sequencer, framePanel)
    self.sequencer = sequencer
    self.framePanel = framePanel

    self.framePanel.Keyframes = {}
end

function SYS:EventCreateKeyframe(keyframe)
    self.keyframe = keyframe
    self.sequencer:Next(self, "CreateKeyframeElement")
    self.keyframe = nil
end

function SYS:EventCreateUIElement(element)
    if self.keyframe == nil then
        return
    end

    element.KeyframeId = self.keyframe.Id
    element.FramePosition = self.keyframe.Position

    self.framePanel.Keyframes[self.keyframe.Id] = element
end

function SYS:EventDeleteKeyframe(keyframeId)
    local element = self.framePanel.Keyframes[keyframeId]
    if element == nil then
        return
    end

    self.framePanel.Keyframes[keyframeId] = nil
    self.sequencer:Next(self, "DeleteUIElement", element)
end

SMH.Systems.Register("KeyframeElementSystem", SYS)