local SYS = {}

function SYS:Init(sequencer, framePanel)
    self.sequencer = sequencer
    self.framePanel = framePanel

    self.framePanel.Keyframes = {}
end

function SYS:EventCreateKeyframe(keyframe)
    local element = vgui.Create("SMHFramePointer", self.framePanel)

    element.Color = Color(0, 200, 0)
    element.VerticalPosition = self.framePanel:GetTall() / 4 * 2.2
    element.Pointy = false
    element.KeyframeId = keyframe.Id

    self.framePanel.Keyframes[keyframe.Id] = element

    self.sequencer:Next(self, "CreateUIElement", element)
end

function SYS:EventDeleteKeyframe(keyframeId)
    local element = self.framePanel.Keyframes[keyframeId]
    if element == nil then
        return
    end

    self.sequencer:Next(self, "DeleteUIElement", element)

    self.framePanel.Keyframes[keyframeId] = nil
    element:Remove()
end

SMH.Systems.Register("KeyframeElementSystem", SYS)