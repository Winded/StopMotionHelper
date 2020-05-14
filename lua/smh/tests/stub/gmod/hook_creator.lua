local ctr = function()
    return {
        hooks = {},
        create = function(self, hookName, identifier, callback)
            table.insert(self.hooks, {hookName, identifier, callback})
        end
    }
end

return {ctr}