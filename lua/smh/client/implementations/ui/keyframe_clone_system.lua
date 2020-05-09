local SYS = {}

function SYS:Init(sequencer)
    self.sequencer = sequencer
end

function SYS:EventCreateCloneKeyframeElement(keyframeId)
    self.keyframeId = keyframeId
    self.sequencer:Next(self, "CreateKeyframeElement")
    self.keyframeId = nil
end

function SYS:EventCreateUIElement(element)
    if self.keyframeId == nil then
        return
    end

    element.ClonedKeyframeId = self.keyframeId
end

SMH.Systems.Register("KeyframeCloneSystem", SYS)