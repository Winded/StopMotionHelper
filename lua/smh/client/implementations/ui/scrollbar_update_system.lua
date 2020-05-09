local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventRefreshFramePanel(element)
    local scrollBar = element.ScrollBar

    if element.TimelineLength == element.Zoom then
        scrollBar:SetPos(unpack(element.ScrollBarAreaPosition))
        scrollBar:SetSize(unpack(element.ScrollBarAreaSize))
    end

    local barWidthPerc = element.Zoom / element.TimelineLength
    barWidthPerc = barWidthPerc > 1 and 1 or barWidthPerc

    local barXPerc = element.ScrollOffset / (element.TimelineLength - element.Zoom)
    barXPerc = barXPerc < 0 and 0 or (barXPerc > 1 and 1 or barXPerc)

    local width = element.ScollBarAreaSize[1] * barWidthPerc
    local height = element.ScrollBarAreaSize[2]
    local x = element.ScrollBarAreaPosition[1] + (element.ScollBarAreaSize[1] - width) * barXPerc
    local y = element.ScrollBarAreaPosition[2]

    scrollBar:SetPos(x, y)
    scrollBar:SetSize(width, height)
end

SMH.Systems.Register("ScrollbarUpdateSystem", SYS)