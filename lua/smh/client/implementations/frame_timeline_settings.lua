local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {}

function CLASS.__new()
    local c = {
        _scrollOffset = 0,
        _zoom = 100,
        _timelineLength = 100,
    }
    setmetatable(c, CLASS)
    return c
end

function CLASS:getScrollOffset()
    return self._scrollOffset
end

function CLASS:setScrollOffset(scrollOffset)
    self._scrollOffset = scrollOffset
end

function CLASS:getZoom()
    return self._zoom
end

function CLASS:setZoom(zoom)
    self._zoom = zoom
end

function CLASS:getTimelineLength()
    return self._timelineLength
end

function CLASS:setTimelineLength(timelineLength)
    self._timelineLength = timelineLength
end

return CLASS