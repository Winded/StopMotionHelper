local ctr = function()
    return {
        frameChangeCalled = false,

        onFrameChange = function(self, frame)
            self.frameChangeCalled = true
        end,
    }
end

return {ctr}