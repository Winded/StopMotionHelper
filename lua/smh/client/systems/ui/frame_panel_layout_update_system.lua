local SYS = {}

function SYS:Init(sequencer, element)
    self.element = element
    self.sequencer = sequencer

    local originalPerformLayout = self.element.PerformLayout
    self.element.PerformLayout = function(el, width, height)
        originalPerformLayout(el, width, height)
        self.sequencer:Next(self, "RefreshFramePanel", self.element)
    end
end