
local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "FramePointer",
    "ServerCommands",
    "FramePointerMoveEvent",
    "FrameChangedEvent",
}

function CLASS.__new(framePointer, serverCommands, framePointerMoveEvent, frameChangedEvent)
    local c = {
        _framePointer = framePointer,
        _serverCommands = serverCommands,
    }
    setmetatable(c, CLASS)

    c._framePointer.color = {255, 255, 255, 255}
    c._framePointer.pointy = true
    c._framePointer.verticalPosition = 0.25

    framePointerMoveEvent:addListener(c, "onFramePointerMoved")
    frameChangedEvent:addListener(c, "onFrameChanged")

    return c
end

function CLASS:getFrame()
    return self._framePointer:getFrame()
end

function CLASS:onFramePointerMoved(framePointer, frame)
    if self._framePointer ~= framePointer then
        return
    end

    self._serverCommands:setFrame(frame)
end

function CLASS:onFrameChanged(newFrame)
    if newFrame ~= self._framePointer:getFrame() then
        self._framePointer:setFrame(newFrame)
    end
end
