local S = {}
S.__index = S

function S:getScrollOffset()
    return self._scrollOffset
end

function S:setScrollOffset(scrollOffset)
    self._scrollOffset = scrollOffset
end

function S:getZoom()
    return self._zoom
end

function S:setZoom(zoom)
    self._zoom = zoom
end

function S:getTimelineLength()
    return self._timelineLength
end

function S:setTimelineLength(timelineLength)
    self._timelineLength = timelineLength
end

return function()
    local s = {
        _scrollOffset = 0,
        _zoom = 100,
        _timelineLength = 100,
    }
    setmetatable(s, S)

    return s
end