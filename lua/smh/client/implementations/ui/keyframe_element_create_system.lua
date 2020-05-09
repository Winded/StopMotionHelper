local SYS = {}

function SYS:Init(sequencer, framePanel)
    self.sequencer = sequencer
    self.framePanel = framePanel
end

function SYS:EventCreateKeyframeElement()
    local element = vgui.Create("SMHFramePointer", self.framePanel)
    element.Color = Color(0, 200, 0)
    -- element.VerticalPosition = self.framePanel:GetTall() / 4 * 2.2
    element.Pointy = false
    element.FramePanel = self.framePanel

    self.sequencer:Next(self, "CreateUIElement", element)
end

function SYS:EventDeleteUIElement(element)
    element.FramePanel = nil
    element:Remove()
end

SMH.Systems.Register("KeyframeElementCreateSystem", SYS)