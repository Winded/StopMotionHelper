local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventMousePressed(element, mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    local panel = element:GetParent()
    local scrollMax = panel.TimelineLength - panel.Zoom

    panel.ScrollOffset = panel.ScrollOffset + element.ScrollOffsetDelta
    panel.ScrollOffset = panel.ScrollOffset > scrollMax and scrollMax or (panel.ScrollOffset < 0 and 0 or panel.ScrollOffset)
    self.sequencer:Next(self, "RefreshFramePanel", panel)
end

SMH.Systems.Register("ScrollbarButtonSystem", SYS)