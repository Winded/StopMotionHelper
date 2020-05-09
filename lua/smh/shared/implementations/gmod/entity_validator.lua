local ctr = function()
    return {
        isValid = function(self, entity)
            return IsValid(entity)
        end
    }
end

return {ctr}