local SYS = {}

function SYS:Init(sequencer, framePanel)
    self.sequencer = sequencer

    local element = vgui.Create("SMHFramePointer", framePanel)
	element.Color = Color(255, 255, 255);
    element.VerticalPosition = framePanel:GetTall() / 4;
    element.Pointy = true

    sequencer:Next(self, "CreateUIElement", element)
end

function SYS:EventSetFramePointerPosition(element, position)
    self.sequencer:Next(self, "SetFrame", position)
end

SMH.Systems.Register("PlayheadSystem", SYS)