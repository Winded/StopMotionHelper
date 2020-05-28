local P = {}
P.__index = P

P.SCROLL_PADDING = 18
P.SCROLL_HEIGHT = 12

--[[function P:_initialize(uiDependencies, surfaceDrawer, playbackUpdater)
    
    self._surfaceDrawer = surfaceDrawer
    self._playbackManager = playbackUpdater

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
    local playbackOffset = self._playbackManager:getPlaybackOffset()
    local playbackLength = self._playbackManager:getPlaybackLength()
    local timelineLength = self._playbackManager:getTimelineLength()
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
    self._playbackManager:setPlaybackLength(self._playbackManager:getPlaybackLength() + scrollDelta)
end

function P:onMousePressed(mouseCode)
    if mouseCode ~= MOUSE_LEFT then
        return
    end

    local startX, endX = unpack(self.frameArea)
    local posX, posY = self.element:CursorPos()

    local playbackOffset = self._playbackManager:getPlaybackOffset()
    local playbackLength = self._playbackManager:getPlaybackLength()
    local timelineLength = self._playbackManager:getTimelineLength()

    local targetX = posX - startX
    local width = endX - startX

    local framePosition = math.Round(playbackOffset + (targetX / width) * playbackLength)
    if framePosition < 0 then
        framePosition = 0
    elseif framePosition >= timelineLength then
        framePosition = timelineLength - 1
    end

    self._playbackManager:setFrame(framePosition)
end

return function(element, surfaceDrawer, playbackManager)
    local panel = {
        element = element,
        _surfaceDrawer = surfaceDrawer,
        _playbackManager = playbackManager,

        timelineLength = 100,
        scrollOffset = 0,
        zoom = 100,
        frameArea = {0, 1},
    }

    setmetatable(panel, P)

    return panel
end