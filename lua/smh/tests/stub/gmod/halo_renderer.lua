local ctr = function()
    return {
        renderEvents = {},
        initialize = function(self)
        end,
        render = function(self, entity)
            table.insert(self.renderEvents, entity)
        end,
    }
end

return {ctr}