local ctr = function()
    return {
        initialized = false,
        drawEvents = 0,

        _entity = nil,
        _enabled = false,

        initialize = function(self)
            self.initialized = true
        end,

        onPostDrawEffects = function(self)
            self.drawEvents = self.drawEvents + 1
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

return {ctr}