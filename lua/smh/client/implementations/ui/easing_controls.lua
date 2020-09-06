local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = {
    "MenuElements",
    "ServerCommands",
    "KeyframesResetEvent",
    "KeyframeCreatedEvent",
    "KeyframeUpdatedEvent",
    "KeyframeDeletedEvent",
    "FrameChangedEvent",
}

function CLASS.__new(menuElements,
                     serverCommands,
                     keyframesResetEvent,
                     keyframeCreatedEvent,
                     keyframeUpdatedEvent,
                     keyframeDeletedEvent,
                     frameChangedEvent)
    local c = {
        _easingContainerElement = menuElements.mainMenu.easing,
        _easeInElement = menuElements.mainMenu.easeIn,
        _easeOutElement = menuElements.mainMenu.easeOut,
        _serverCommands = serverCommands,
        _keyframes = {},
        _currentFrame = nil,
        _currentKeyframeId = nil,
        _updatingValues = false,
    }
    setmetatable(c, CLASS)

    frameChangedEvent:addListener(c, "onFrameChanged")
    keyframesResetEvent:addListener(c, "onKeyframesReset")
    keyframeCreatedEvent:addListener(c, "onKeyframeCreated")
    keyframeUpdatedEvent:addListener(c, "onKeyframeUpdated")
    keyframeDeletedEvent:addListener(c, "onKeyframeDeleted")

    c._easeInElement.OnValueChanged = function(element, value) c:onEaseInValueChanged(value) end
    c._easeOutElement.OnValueChanged = function(element, value) c:onEaseOutValueChanged(value) end

    return c
end

function CLASS:updateElements()
    local keyframe = nil
    for _, keyframe in pairs(self._keyframes) do
        if keyframe.frame == self._currentFrame then
            keyframe = keyframe
            break
        end
    end
    if keyframe == nil then
        self._easingContainerElement:SetVisible(false)
        self._currentKeyframeId = nil
        return
    end
    
    self._updatingValues = true
    self._easingContainerElement:SetVisible(true)
    self._easeInElement:SetValue(keyframe.easeIn)
    self._easeOutElement:SetValue(keyframe.easeOut)
    self._currentKeyframeId = keyframe.id
    self._updatingValues = false
end

function CLASS:onFrameChanged(newFrame)
    self._currentFrame = newFrame
    self:updateElements()
end

function CLASS:onKeyframesReset(keyframes)
    self._keyframes = {}
    for _, keyframe in pairs(keyframes) do
        self._keyframes[keyframe.id] = {
            id = keyframe.id,
            frame = keyframe.frame,
            easeIn = keyframe.easeIn,
            easeOut = keyframe.easeOut,
        }
    end

    self:updateElements()
end

function CLASS:onKeyframeCreated(keyframe)
    self._keyframes[keyframe.id] = {
        id = keyframe.id,
        frame = keyframe.frame,
        easeIn = keyframe.easeIn,
        easeOut = keyframe.easeOut,
    }

    self:updateElements()
end

function CLASS:onKeyframeUpdated(keyframeId, updatedData)
    local keyframe = self._keyframes[keyframeId]
    if keyframe == nil then
        return
    end

    keyframe.frame = updatedData.frame or keyframe.frame
    keyframe.easeIn = updatedData.easeIn or keyframe.easeIn
    keyframe.easeOut = updatedData.easeOut or keyframe.easeOut
    self:updateElements()
end

function CLASS:onKeyframeDeleted(keyframeId)
    self._keyframes[keyframeId] = nil
    self:updateElements()
end

function CLASS:onEaseInValueChanged(value)
    if self._updatingValues then
        return
    end

    self._serverCommands:updateKeyframe(self._currentKeyframeId, { easeIn = value })
end

function CLASS:onEaseOutValueChanged(value)
    if self._updatingValues then
        return
    end

    self._serverCommands:updateKeyframe(self._currentKeyframeId, { easeOut = value })
end
