local P = {}
P.__index = P

P.SCROLL_PADDING = 18
P.SCROLL_HEIGHT = 12

P.MIN_ZOOM = 30
P.MAX_ZOOM = 500

--[[function P:_initialize(uiDependencies, surfaceDrawer, playbackUpdater)
    
    self._surfaceDrawer = surfaceDrawer
    self._frameTimelineSettings = playbackUpdater

    self._playhead = uiDependencies.playhead
    self._scrollBar = uiDependencies.scrollBar
    self._scrollButtonLeft = uiDependencies.scrollButtonLeft
    self._scrollButtonRight = uiDependencies.scrolLButtonRight

    self.timelineLength = 100
    self.scrollOffset = 0
    self.zoom = 100
    self.frameArea = {0, 1}
    self.scrollBarAreaPosition = {0, 0}
    self.scrollBarAreaSize = {0, 0}

    self:SetBackgroundColor({r = 64, g = 64, b = 64, a = 64})

    self.Playhead = vgui.Create("SMHFramePointer", self)
    self.Playhead.Color = Color(255, 255, 255)
    self.Playhead.FramePanel = self

    self.ScrollBar = vgui.Create("DPanel", self)
    self.ScrollBar.Paint = function(self, w, h) derma.SkinHook("Paint", "ScrollBarGrip", self, w, h) end

    self.ScrollBtnLeft = vgui.Create("DButton", self)
    self.ScrollBtnLeft:SetText("")
    self.ScrollBtnLeft.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonLeft", self, w, h) end

    self.ScrollBtnRight = vgui.Create("DButton", self)
    self.ScrollBtnRight:SetText("")
    self.ScrollBtnRight.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonRight", self, w, h) end

    self.TimelineLength = 100
    self.ScrollOffset = 0
    self.Zoom = 100
    self.FrameArea = {0, 1}
    self.ScrollBarAreaPosition = {0, 0}
    self.ScrollBarAreaSize = {0, 0}
    
end]]

--[[function P:performLayout(width, height)

    local scrollPosY = height - self.SCROLL_HEIGHT

    self.scrollBarAreaPosition = { self.SCROLL_PADDING, scrollPosY }
    self.scrollBarAreaSize = { width - self.SCROLL_PADDING * 2, self.SCROLL_HEIGHT }

    self._scrollButtonLeft:SetPos(scrollPadding - 12, scrollPosY)
    self._scrollButtonLeft:SetSize(12, scrollHeight)

    self._scrollButtonRight:SetPos(scrollPadding + self.scrollBarAreaSize[1], scrollPosY)
    self._scrollButtonRight:SetSize(12, scrollHeight)

end]]

function P:paint()
    local height = self.element:GetTall()
    local playbackOffset = self._frameTimelineSettings:getScrollOffset()
    local playbackLength = self._frameTimelineSettings:getZoom()
    local timelineLength = self._frameTimelineSettings:getTimelineLength()
	local startX, endX = unpack(self.frameArea)

	local frameWidth = (endX - startX) / playbackLength

	self._surfaceDrawer:setDrawColor(255, 255, 255, 255)

	for i = 0, playbackLength - 1 do
		if playbackOffset + i < timelineLength then
			local x = startX + frameWidth * i
			self._surfaceDrawer:drawLine(x, 6, x, height - 6)
		end
	end
end

function P:onMouseWheeled(scrollDelta)
    scrollDelta = -scrollDelta
    self._frameTimelineSettings:setZoom(self._frameTimelineSettings:getZoom() + scrollDelta)
end

function P:onMousePressed(mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    local startX, endX = unpack(self.frameArea)
    local posX, _ = self.element:CursorPos()

    local scrollOffset = self._frameTimelineSettings:getScrollOffset()
    local zoom = self._frameTimelineSettings:getZoom()
    local timelineLength = self._frameTimelineSettings:getTimelineLength()

    local targetX = posX - startX
    local width = endX - startX

    local framePosition = math.Round(scrollOffset + (targetX / width) * zoom)
    if framePosition < 0 then
        framePosition = 0
    elseif framePosition >= timelineLength then
        framePosition = timelineLength - 1
    end

    self._framePositionClickEvent:send(framePosition)
end

return function(menuElements, framePositionClickEvent, surfaceDrawer, frameTimelineSettings)
    local element = menuElements.mainMenu.framePanel

    local panel = {
        element = element,
        _framePositionClickEvent = framePositionClickEvent,
        _surfaceDrawer = surfaceDrawer,
        _frameTimelineSettings = frameTimelineSettings,

        scrollOffset = 0,
        zoom = 100,
        frameArea = {0, 1},
    }

    setmetatable(panel, P)

    element.PerformLayout = function(self, ...) panel:performLayout(...) end
    element.Paint = function(self, ...) panel:paint(...) end
    element.OnMouseWheeled = function(self, ...) panel:onMouseWheeled(...) end
    element.OnMousePressed = function(self, ...) panel:onMousePressed(...) end

    return panel
end