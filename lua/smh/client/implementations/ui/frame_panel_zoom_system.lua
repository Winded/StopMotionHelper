local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMouseWheeled(element, scrollDelta)
    scrollDelta = -scrollDelta
    element.Zoom = element.Zoom + scrollDelta
    element.Zoom = element.Zoom > 500 and 500 or (element.Zoom < 30 and 30 or element.Zoom)
    self.sequencer:Next(self, "UpdateScrollBar", element)
end

SMH.Systems.Register("FramePanelZoomSystem", SYS)