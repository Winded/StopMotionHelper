local ctr = function()
    return {
        create = function(self, hookName, identifier, callback)
            hook.Add(hookName, identifier, callback)
        end
    }
end

return {ctr}