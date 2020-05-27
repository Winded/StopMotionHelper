
local PANEL = {}

function PANEL:_initialize(surfaceDrawer, keyframeController, framePanel, verticalPosition, color, pointy)
    self._surfaceDrawer = surfaceDrawer
    self._keyframeController = keyframeController
    self._framePanel = framePanel

    self:SetSize(8, 15)
    self.color = color
    self.verticalPosition = verticalPosition;
    self.pointy = pointy

    self._frame = 0

    self._outlineColor = {0, 0, 0, 255}
    self._dragging = false
end

function PANEL:getFrame()
    return self._frame
end

function PANEL:setFrame(frame)
    local startX, endX = unpack(self._framePanel.frameArea)
    local height = self._framePanel:GetTall() * self.verticalPosition

    local frameAreaWidth = endX - startX
    local positionWithOffset = frame - self._framePanel.scrollOffset
    local x = startX + (positionWithOffset / self._framePanel.zoom) * frameAreaWidth

    self._frame = frame
    self:SetPos(x - self:GetWide() / 2, height - self:GetTall() / 2)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        self:MouseCapture(true)
        self._outlineColor = {255, 255, 255, 255}
        self._dragging = true
    elseif mouseCode == MOUSE_RIGHT then
        self._keyframeController:delete()
    elseif mouseCode == MOUSE_MIDDLE then
        self._keyframeController:copy()
    end
end

function PANEL:OnMouseReleased(mouseCode)
    if mouseCode ~= MOUSE_LEFT or not self._dragging then
        return
    end

    self:MouseCapture(false)
    self._outlineColor = {0, 0, 0, 255}
    self._dragging = false
    self._keyframeController:setFrame(self._frame)
end

function PANEL:OnCursorMoved(cursorX, cursorY)
    if not self._dragging then
        return
    end

    local startX, endX = unpack(self._framePanel.frameArea)
	
    local targetX = cursorX - startX
    local width = endX - startX

    local targetPos = math.Round(self._framePanel.scrollOffset + (targetX / width) * self._framePanel.zoom)
    targetPos = targetPos < 0 and 0 or (targetPos > self._framePanel.timelineLength and self._framePanel.timelineLength - 1 or targetPos)
    
    if self._frame ~= targetPos then
        self:setFrame(targetPos)
    end
end

function PANEL:Paint(width, height)
    if self._framePanel == nil then
        return
    end
    if self._frame < self._framePanel.scrollOffset or self._frame > (self._framePanel.scrollOffset + self._framePanel.zoom) then
        return
    end

    if self.pointy then
        self._surfaceDrawer:setDrawColor(unpack(self.color))
        self._surfaceDrawer:noTexture()
        self._surfaceDrawer:drawRect(1, 1, width - 1, height - (height * 0.25))
        self._surfaceDrawer:drawPoly({
            { x = 1, y = height - (height * 0.25) },
            { x = width - 1, y = height - (height * 0.25) },
            { x = width / 2, y = height - 1 },
        })

        self._surfaceDrawer:setDrawColor(unpack(self._outlineColor))
        self._surfaceDrawer:drawLine(0, 0, width, 0)
        self._surfaceDrawer:drawLine(width, 0, width, height - (height * 0.25))
        self._surfaceDrawer:drawLine(width, height - (height * 0.25), width / 2, height)
        self._surfaceDrawer:drawLine(width / 2, height, 0, height - (height * 0.25))
        self._surfaceDrawer:drawLine(0, height - (height * 0.25), 0, 0)
    else
        self._surfaceDrawer:setDrawColor(self.color)
        self._surfaceDrawer:drawRect(1, 1, width - 1, height - 1)

        self._surfaceDrawer:setDrawColor(unpack(self._outlineColor))
        self._surfaceDrawer:drawLine(0, 0, width, 0)
        self._surfaceDrawer:drawLine(width, 0, width, height)
        self._surfaceDrawer:drawLine(width, height, 0, height)
        self._surfaceDrawer:drawLine(0, height, 0, 0)
    end
end

return PANEL