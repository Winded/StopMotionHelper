local SYS = {}

function SYS:Init(sequencer, element)
    self.element = element
    self.sequencer = sequencer

    element.OnMousePressed = function(self, mousecode)
        if mousecode ~= MOUSE_RIGHT then
            return
        end

        local trace = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
        self.sequencer:Next(self, "Trace", trace)
    end
end

function SYS:EventSetUIVisibility(visible)
    if not visible then
        RememberCursorPosition()
    end
    self.element:SetVisible(visible)
    if visible then
        RestoreCursorPosition()
    end
end

SMH.Systems.Register("WorldClickerSystem", SYS)