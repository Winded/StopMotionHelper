local SYS = {}

function SYS:Init(pointerNormalizedVerticalPosition)
    self.pointerNormalizedVerticalPosition = pointerNormalizedVerticalPosition
end

function SYS:EventSetFramePointerPosition(element, position)
    local startX, endX = unpack(element.FramePanel.FrameArea)
    local height = element.FramePanel:GetTall() * self.pointerNormalizedVerticalPosition

    local frameAreaWidth = endX - startX
    local positionWithOffset = position - scrollOffset
    local x = startX + (positionWithOffset / element.FramePanel.Zoom) * frameAreaWidth

    element:SetPos(x - element:GetWide() / 2, height - element:GetTall() / 2)
end

SMH.Systems.Register("FramePointerPositionSystem", SYS)