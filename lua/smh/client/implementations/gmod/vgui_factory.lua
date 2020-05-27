return function()
    return {
        create = function(self, name)
            return vgui.Create(name)
        end,
        register = function(self, name, metatable, type)
            return vgui.Register(name, metatable, type)
        end
    }
end