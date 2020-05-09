local SYS = {}

function SYS:Init(sequencer, element)
    self.sequencer = sequencer
    self.element = element

    self.element.FileList.OnRowSelected = function(el, rowId, row)
        self.sequencer:Next(self, "SelectLoadFile", row:GetValue(1))
    end
    self.element.EntityList.OnRowSelected = function(el, rowId, row)
        self.sequencer:Next(self, "SelectLoadEntity", row:GetValue(1))
    end
    self.element.Load.DoClick = function()
        self.sequencer:Next(self, "Load")
    end
end

function SYS:addLines(element, lines)
    element:ClearSelection()
    element:Clear()
    for _, line in pairs(lines) do
        element:AddLine(line)
    end
end

function SYS:EventUpdateSavedFilesList(files)
    self:addLine(self.element.FileList, files)
end

function SYS:EventUpdateSavedFileEntities(entities)
    self:addLine(self.element.EntityList, entities)
end

SMH.Systems.Register("LoadFrameSystem", SYS)