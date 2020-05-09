local ctr = function()
    return {
        messageHistory = {},

        selectEntity = function(self, entity)
            table.insert(self.messageHistory, {"selectEntity", entity})
        end
    }
end

return {ctr}