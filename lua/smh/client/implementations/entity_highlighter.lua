return function(haloRenderer, hookCreator, entityValidator)
    return {
        _haloRenderer = haloRenderer,
        _hookCreator = hookCreator,
        _entityValidator = entityValidator,

        _entity = nil,
        _enabled = false,

        initialize = function(self)
            self._hookCreator:create("PostDrawEffects", "SMHEntityHighlight", function() self:onPostDrawEffects() end)
        end,

        onPostDrawEffects = function(self)
            if not self._enabled or not self._entityValidator:isValid(self._entity) then
                return
            end

            self._haloRenderer:render(self._entity)
        end,

        isEnabled = function(self)
            return self._enabled
        end,
        setEnabled = function(self, enabled)
            self._enabled = enabled
        end,

        getEntity = function(self)
            return self._entity
        end,
        setEntity = function(self, entity)
            self._entity = entity
        end,
    }
end