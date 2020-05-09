local ctr = function()
    return {
        isValid = function(self, entity)
            return entity ~= nil
        end
    }
end

return {ctr}