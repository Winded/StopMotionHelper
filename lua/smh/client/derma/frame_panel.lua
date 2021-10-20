local PANEL = {}

function PANEL:Init()

    self:SetBackgroundColor(Color(64, 64, 64, 64))

    self.ScrollBar = vgui.Create("DPanel", self)
    self.ScrollBar.Paint = function(self, w, h) derma.SkinHook("Paint", "ScrollBarGrip", self, w, h) end
    self.ScrollBar.OnMousePressed = function(_, mousecode) self:OnScrollBarPressed(mousecode) end
    self.ScrollBar.OnMouseReleased = function(_, mousecode) self:OnScrollBarReleased(mousecode) end
    self.ScrollBar.OnCursorMoved = function(_, x, y) self:OnScrollBarCursorMoved(x, y) end

    self.ScrollButtonLeft = vgui.Create("DButton", self)
    self.ScrollButtonLeft:SetText("")
    self.ScrollButtonLeft.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonLeft", self, w, h) end
    self.ScrollButtonLeft.DoClick = function() self:SetScrollOffset(self.ScrollOffset - 1) end

    self.ScrollButtonRight = vgui.Create("DButton", self)
    self.ScrollButtonRight:SetText("")
    self.ScrollButtonRight.Paint = function(self, w, h) derma.SkinHook("Paint", "ButtonRight", self, w, h) end
    self.ScrollButtonRight.DoClick = function() self:SetScrollOffset(self.ScrollOffset + 1) end

    self.Zoom = 100
    self.TotalFrames = 100
    self.ScrollOffset = 0
    self.FrameArea = {0, 1}
    self._draggingScrollBar = false
    self._scrollCursorOffset = 0
    
    self.FramePointers = {}

end

function PANEL:PerformLayout(width, height)

    local frameAreaPadding = 10
    local scrollPadding = 18
    local scrollHeight = 12
    local scrollPosY = self:GetTall() - scrollHeight

    self.ScrollBarRect = {
        X = scrollPadding,
        Y = scrollPosY,
        Width = self:GetWide() - scrollPadding * 2,
        Height = scrollHeight,
    }

    self.ScrollButtonLeft:SetPos(scrollPadding - 12, scrollPosY)
    self.ScrollButtonLeft:SetSize(12, scrollHeight)

    self.ScrollButtonRight:SetPos(scrollPadding + self.ScrollBarRect.Width, scrollPosY)
    self.ScrollButtonRight:SetSize(12, scrollHeight)

    local startPoint = frameAreaPadding
    local endPoint = self:GetWide() - frameAreaPadding
    self.FrameArea = {startPoint, endPoint}

    self:RefreshScrollBar()
    self:RefreshFrames()

end

function PANEL:Paint(width, height)

    local startX, endX = unpack(self.FrameArea)
    local frameWidth = (endX - startX) / self.Zoom

    surface.SetDrawColor(255, 255, 255, 255)
    for i = 0, self.Zoom do
        if self.ScrollOffset + i < self.TotalFrames then
            local x = startX + frameWidth * i
            surface.DrawLine(x, 6, x, height - 6)
        end
    end

end

function PANEL:UpdateFrameCount(totalframes)
    self.TotalFrames = totalframes

    if not self.ScrollBarRect then return end --check if we actually initialized the panel
    self:RefreshScrollBar()
end

function PANEL:RefreshScrollBar()
    if self.TotalFrames == self.Zoom then
        self.ScrollBar:SetPos(self.ScrollBarRect.X, self.ScrollBarRect.Y)
        self.ScrollBar:SetSize(self.ScrollBarRect.Width, self.ScrollBarRect.Height)
        return
    end

    local barWidthPerc = self.Zoom / self.TotalFrames
    barWidthPerc = barWidthPerc > 1 and 1 or barWidthPerc

    local barXPerc = self.ScrollOffset / (self.TotalFrames - self.Zoom)
    barXPerc = barXPerc < 0 and 0 or (barXPerc > 1 and 1 or barXPerc)

    local width = self.ScrollBarRect.Width * barWidthPerc
    local height = self.ScrollBarRect.Height
    local x = self.ScrollBarRect.X + (self.ScrollBarRect.Width - width) * barXPerc
    local y = self.ScrollBarRect.Y

    self.ScrollBar:SetPos(x, y)
    self.ScrollBar:SetSize(width, height)
end

function PANEL:RefreshFrames()
    for _, pointer in pairs(self.FramePointers) do
        pointer:RefreshFrame()
    end
end

function PANEL:SetScrollOffset(offset)
    if offset < 0 then
        offset = 0
    elseif offset >= self.TotalFrames then
        offset = self.TotalFrames - 1
    end

    self.ScrollOffset = offset
    self:RefreshScrollBar()
    self:RefreshFrames()
end

function PANEL:CreateFramePointer(color, verticalPosition, pointyBottom)
    local pointer = vgui.Create("SMHFramePointer", self)
	pointer.Color = color
	pointer.VerticalPosition = verticalPosition
	pointer.PointyBottom = pointyBottom
    table.insert(self.FramePointers, pointer)

    return pointer
end

function PANEL:DeleteFramePointer(pointer)
    table.RemoveByValue(self.FramePointers, pointer)
    pointer:Remove()
end

function PANEL:OnMousePressed(mousecode)
    if mousecode ~= MOUSE_LEFT then
        return
    end

    local startX, endX = unpack(self.FrameArea)
    local posX, posY = self:CursorPos()

    local targetX = posX - startX
    local width = endX - startX
    local framePosition = math.Round(self.ScrollOffset + (targetX / width) * self.Zoom)
    framePosition = framePosition < 0 and 0 or (framePosition >= self.TotalFrames and self.TotalFrames - 1 or framePosition)

    self:OnFramePressed(framePosition)
end

function PANEL:OnMouseWheeled(scrollDelta)
    scrollDelta = -scrollDelta
    local newZoom = self.Zoom + scrollDelta
    if newZoom > 500  then
        newZoom = 500
    elseif newZoom < 30 then
        newZoom = 30
    end

    self.Zoom = newZoom
    self:RefreshFrames()
    self:RefreshScrollBar()
end

function PANEL:OnScrollBarPressed(mousecode)
    if mousecode ~= MOUSE_LEFT then
        return
    end

    self.ScrollBar:MouseCapture(true)
    self._draggingScrollBar = true
    
    local cursorXOffset, _ = self.ScrollBar:CursorPos()
    self._scrollCursorOffset = cursorXOffset
end

function PANEL:OnScrollBarReleased(mousecode)
    if mousecode ~= MOUSE_LEFT then
        return
    end

    self.ScrollBar:MouseCapture(false)
    self._draggingScrollBar = false
end

function PANEL:OnScrollBarCursorMoved(x, y)
    if not self._draggingScrollBar then
        return
    end

    local cursorX, _ = self:CursorPos()
    local movePos = cursorX - self._scrollCursorOffset - self.ScrollBarRect.X

    local movableWidth = self.ScrollBarRect.Width - self.ScrollBar:GetWide()
    if movableWidth ~= 0 then
        local numSteps = self.TotalFrames - self.Zoom
        local targetScrollOffset = math.Round((movePos / movableWidth) * numSteps)

        if targetScrollOffset >= 0 and targetScrollOffset <= numSteps and targetScrollOffset ~= self.ScrollOffset then
            self:SetScrollOffset(targetScrollOffset)
        end
    elseif self.ScrollOffset ~= 0 then
        self:SetScrollOffset(0)
    end
end

function PANEL:OnFramePressed(frame) end

vgui.Register("SMHFramePanel", PANEL, "DPanel")
