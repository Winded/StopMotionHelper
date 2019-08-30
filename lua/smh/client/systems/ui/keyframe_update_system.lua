local SYS = {}

function SYS:Init(sequencer, framePanel)
    self.sequencer = sequencer
    self.framePanel = framePanel
end

function SYS:EventUpdateKeyframe(keyframeId, updatedData)
    if updatedData.Position == nil then
        return
    end

    local element = self.framePanel.Keyframes[keyframeId]
    if element == nil then
        error("Element for keyframe " .. keyframeId .. " not found")
    end

    local startX, endX = unpack(self.framePanel.FrameArea)
    local height = element.VerticalPosition

    local frameAreaWidth = endX - startX
    local positionWithOffset = position - scrollOffset
    local x = startX + (positionWithOffset / zoom) * frameAreaWidth

    element:SetPos(x - element:GetWide() / 2, height - element:GetTall() / 2)
end