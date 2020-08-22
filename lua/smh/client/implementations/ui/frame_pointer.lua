
local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "FramePanel",
    "VguiFactory",
    "SurfaceDrawer",
    "FrameTimelineSettings",
    "FramePointerClickEvent",
    "FramePointerReleaseEvent",
    "FramePointerMoveEvent",
}
CLASS.__lifecycle = Ludi.Lifecycle.Transient

function CLASS.__new(framePanel,
                     vguiFactory,
                     surfaceDrawer,
                     frameTimelineSettings,
                     framePointerClickEvent,
                     framePointerReleaseEvent,
                     framePointerMoveEvent)

    local element = vguiFactory:create("DPanel")

    local pointer = {
        element = element,
        _framePanel = framePanel,
        _surfaceDrawer = surfaceDrawer,
        _frameTimelineSettings = frameTimelineSettings,
        _framePointerClickEvent = framePointerClickEvent,
        _framePointerReleaseEvent = framePointerReleaseEvent,
        _framePointerMoveEvent = framePointerMoveEvent,

        verticalPosition = 0,
        color = {255, 255, 255, 255},
        pointy = false,

        _frame = 0,
        _outlineColor = {0, 0, 0, 255},
        _dragging = false,
    }

    setmetatable(pointer, CLASS)

    element.OnMousePressed = function(self, ...) pointer:onMousePressed(...) end
    element.OnMouseReleased = function(self, ...) pointer:onMouseReleased(...) end
    element.OnCursorMoved = function(self, ...) pointer:onCursorMoved(...) end
    element.Paint = function(self, ...) pointer:paint(...) end
    element:SetParent(framePanel.element)
    element:SetSize(8, 15)

    return pointer

end

function CLASS:getFrame()
    return self._frame
end

function CLASS:setFrame(frame)
    self._frame = frame

    local x = self._framePanel:getLocalPositionFromFrame(frame)
    local height = self._framePanel:getTall() * self.verticalPosition
    self.element:SetPos(x - self.element:GetWide() / 2, height - self.element:GetTall() / 2)
end

function CLASS:setDragging(dragging)
    if dragging then
        self.element:MouseCapture(true)
        self._outlineColor = {255, 255, 255, 255}
    else
        self.element:MouseCapture(false)
        self._outlineColor = {0, 0, 0, 255}
    end

    self._dragging = dragging
end

function CLASS:onMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        self:setDragging(true)
    end

    self._framePointerClickEvent:send(self, mouseCode)
end

function CLASS:onMouseReleased(mouseCode)
    if not self._dragging then
        return
    end

    self:setDragging(false)
    self._framePointerReleaseEvent:send(self, self._frame)
end

function CLASS:onCursorMoved(cursorX)
    if not self._dragging then
        return
    end

    local timelineLength = self._frameTimelineSettings:getTimelineLength()

    local targetFrame = self._framePanel:getFrameFromScreenPosition(cursorX)
    targetFrame = targetFrame < 0 and 0 or (targetFrame > timelineLength and timelineLength - 1 or targetFrame)
    
    if self._frame ~= targetFrame then
        self:setFrame(targetFrame)
        self._framePointerMoveEvent:send(self, targetFrame)
    end
end

function CLASS:paint(width, height)
    local scrollOffset = self._frameTimelineSettings:getScrollOffset()
    local zoom = self._frameTimelineSettings:getZoom()
    if self._frame < scrollOffset or self._frame > (scrollOffset + zoom) then
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

function CLASS:onFrameTimelineSettingsChanged()
    -- Refresh pointer position when timeline settings change
    self:setFrame(self._frame)
end

function CLASS:delete()
    self.element:Delete()
end

return CLASS