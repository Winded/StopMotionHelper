local PANEL = {}

function PANEL:_initialize(uiDependencies, surfaceDrawer, playbackUpdater)
    
    self._surfaceDrawer = surfaceDrawer
    self._playbackUpdater = playbackUpdater

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

    --self.Playhead = vgui.Create("SMHFramePointer", self)
    --self.Playhead.Color = Color(255, 255, 255)
    --self.Playhead.FramePanel = self

    --self.ScrollBar = vgui.Create("DPanel", self)
    --self.ScrollBar.Paint = function(self, w, h) derma.SkinHook("Paint", "ScrollBarGrip", self, w, h) end

    --self.ScrollBtnLeft = vgui.Create("DButton", self)
    --self.ScrollBtnLeft:SetText("")
    --self.ScrollBtnLeft.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonLeft", self, w, h) end

    --self.ScrollBtnRight = vgui.Create("DButton", self)
    --self.ScrollBtnRight:SetText("")
    --self.ScrollBtnRight.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonRight", self, w, h) end

    --self.TimelineLength = 100
    --self.ScrollOffset = 0
    --self.Zoom = 100
    --self.FrameArea = {0, 1}
    --self.ScrollBarAreaPosition = {0, 0}
    --self.ScrollBarAreaSize = {0, 0}
    
end

function PANEL:PerformLayout(width, height)
    
    local scrollPadding = 18
    local scrollHeight = 12

    local scrollPosY = height - scrollHeight

    self.scrollBarAreaPosition = { scrollPadding, scrollPosY }
    self.scrollBarAreaSize = { width - scrollPadding * 2, scrollHeight }

    self._scrollButtonLeft:SetPos(scrollPadding - 12, scrollPosY)
    self._scrollButtonLeft:SetSize(12, scrollHeight)

    self._scrollButtonRight:SetPos(scrollPadding + self.scrollBarAreaSize[1], scrollPosY)
    self._scrollButtonRight:SetSize(12, scrollHeight)

end

function PANEL:Paint()
	local height = self:GetTall()
	local startX, endX = unpack(self.frameArea)

	local frameWidth = (endX - startX) / self.zoom

	self._surfaceDrawer:setDrawColor(255, 255, 255, 255)

	for i = 0, self.zoom do
		if self.scrollOffset + i < self.timelineLength then
			local x = startX + frameWidth * i
			self._surfaceDrawer:drawLine(x, 6, x, height - 6)
		end
	end
end

function PANEL:OnMouseWheeled(scrollDelta)
    scrollDelta = -scrollDelta
    self:setScrollOffsetAndZoom(self.scrollOffset, self.zoom + scrollDelta)
    self._playbackUpdater:setPlaybackRange(self.scrollOffset, self.zoom)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    local startX, endX = unpack(self.frameArea)
    local posX, posY = self:CursorPos()

    local targetX = posX - startX
    local width = endX - startX
    local framePosition = math.Round(self.scrollOffset + (targetX / width) * self.zoom)
    framePosition = framePosition < 0 and 0 or (framePosition >= self.timelineLength and self.timelineLength - 1 or framePosition)

    self._playehead:setFrame(framePosition)
end

function PANEL:setScrollOffsetAndZoom(scrollOffset, zoom)
    self.scrollOffset = scrollOffset
    self.zoom = zoom
    self.zoom = self.zoom > 500 and 500 or (self.zoom < 30 and 30 or self.zoom)
end

return PANEL