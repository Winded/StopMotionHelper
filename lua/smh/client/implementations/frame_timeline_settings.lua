local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "FrameTimelineSettingsChangeEvent",
}

function CLASS.__new(frameTimelineSettingsChangeEvent)
    local c = {
        _scrollOffset = 0,
        _zoom = 100,
        _timelineLength = 100,
        _frameTimelineSettingsChangeEvent = frameTimelineSettingsChangeEvent,
    }
    setmetatable(c, CLASS)
    return c
end

function CLASS:getScrollOffset()
    return self._scrollOffset
end

function CLASS:setScrollOffset(scrollOffset)
    self._scrollOffset = scrollOffset
    self._frameTimelineSettingsChangeEvent:send()
end

function CLASS:getZoom()
    return self._zoom
end

function CLASS:setZoom(zoom)
    self._zoom = zoom
    self._frameTimelineSettingsChangeEvent:send()
end

function CLASS:getTimelineLength()
    return self._timelineLength
end

function CLASS:setTimelineLength(timelineLength)
    self._timelineLength = timelineLength
    self._frameTimelineSettingsChangeEvent:send()
end

return CLASS