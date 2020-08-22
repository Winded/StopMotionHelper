local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "__container__"
}

function CLASS.__new(container)
    local c = {
        _container = container,
        _serverCommands = container:get("ServerCommands"),
        _keyframePointerMap = {},
        _pointerKeyframeMap = {},
        _activeClone = nil,
    }
    setmetatable(c, CLASS)

    return c
end

function CLASS:_newPointer()
    local pointer = self._container:get("FramePointer")
    pointer.color = {0, 200, 0, 255}
    pointer.pointy = false
    pointer.verticalPosition = 0.55
    return pointer
end

function CLASS:onKeyframesReset(keyframes)
    for _, pointer in pairs(self._keyframePointerMap) do
        pointer:delete()
    end
    self._keyframePointerMap = {}
    self._pointerKeyframeMap = {}

    for _, keyframe in pairs(keyframes) do
        self:onKeyframeCreated(keyframe)
    end
end

function CLASS:onKeyframeCreated(keyframe)
    local pointer = self._keyframePointerMap[keyframe.id]
    if pointer ~= nil then
        pointer:setFrame(keyframe.frame)
        return
    end

    pointer = self:_newPointer()
    pointer:setFrame(keyframe.frame)

    self._keyframePointerMap[keyframe.id] = pointer
    self._pointerKeyframeMap[pointer] = keyframe.id
end

function CLASS:onKeyframeDeleted(keyframeId)
    local pointer = self._keyframePointerMap[keyframeId]
    if pointer == nil then
        return
    end

    self._keyframePointerMap[keyframeId] = nil
    self._pointerKeyframeMap[pointer] = nil
    pointer:delete()
end

function CLASS:onFramePointerClicked(pointer, mouseCode)
    local keyframeId = self._pointerKeyframeMap[pointer]
    if keyframeId == nil then
        return
    end

    if mouseCode == MOUSE_MIDDLE then
        local clonedPointer = self:_newPointer()
        clonedPointer:setFrame(pointer:getFrame())
        clonedPointer:setDragging(true)
        self._activeClone = {
            keyframeId = keyframeId,
            pointer = clonedPointer,
        }
    elseif mouseCode == MOUSE_RIGHT then
        self._serverCommands:deleteKeyframe(keyframeId)
    end
end

function CLASS:onFramePointerReleased(pointer, frame)
    local keyframeId = self._pointerKeyframeMap[pointer]
    if keyframeId == nil then
        if self._activeClone ~= nil and self._activeClone.pointer == pointer then
            self._serverCommands:cloneKeyframe(self._activeClone.keyframeId, self._activeClone.pointer:getFrame())
            self._activeClone = nil
        end
        return
    end

    self._serverCommands:updateKeyframe(keyframeId, { frame = frame })
end

return CLASS