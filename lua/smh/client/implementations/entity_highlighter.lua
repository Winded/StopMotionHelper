local CLASS = {}
CLASS.__index = CLASS
CLASS.__depends = { "HaloRenderer", "HookCreator", "EntityValidator" }

function CLASS.__new(haloRenderer, hookCreator, entityValidator)
    local c = {
        _haloRenderer = haloRenderer,
        _hookCreator = hookCreator,
        _entityValidator = entityValidator,

        _entity = nil,
        _enabled = false,
    }
    setmetatable(c, CLASS)

    -- c._hookCreator:create("PostDrawEffects", "SMHEntityHighlight", function() c:onPostDrawEffects() end)

    return c
end

function CLASS:onPostDrawEffects()
    if not self._enabled or not self._entityValidator:isValid(self._entity) then
        return
    end

    self._haloRenderer:render(self._entity)
end

function CLASS:isEnabled()
    return self._enabled
end
function CLASS:setEnabled(enabled)
    self._enabled = enabled
end

function CLASS:getEntity()
    return self._entity
end
function CLASS:setEntity(entity)
    self._entity = entity
end

return CLASS