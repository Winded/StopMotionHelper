local ctr = function()
    return function(name, callback)
        concommand.Add(name, callback)
    end
end

return {ctr}