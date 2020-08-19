
local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "FramePointer",
    "ServerCommands",
}

function CLASS.__new(framePointer, serverCommands)
    local c = {
        _framePointer = framePointer,
        _serverCommands = serverCommands,
    }
    setmetatable(c, CLASS)

    c._framePointer.color = {255, 255, 255, 255}
    c._framePointer.pointy = true
    c._framePointer.verticalPosition = 0.25

    return c
end

function CLASS:onFramePointerMoved(framePointer, frame)
    if self._framePointer ~= framePointer then
        return
    end

    self._serverCommands:setFrame(frame)
end
