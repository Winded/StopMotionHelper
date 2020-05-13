local ctr = function()
    return {
        frameChangeCalledCount = 0,
        lastFrame = nil,

        onFrameChange = function(self, frame)
            self.frameChangeCalledCount = self.frameChangeCalledCount + 1
            self.lastFrame = frame
        end,
    }
end

return {ctr}