local SYS = {}

function SYS:Init(sequencer, element)
    self.sequencer = sequencer
    self.element = element

    self.element.FileList.OnRowSelected = function(el, rowId, row)
        self.element.FileName:SetValue(row:GetValue(1))
    end
    self.element.Save.DoClick = function()
        self.sequencer:Next(self, "Save", self.element.FileName:GetValue())
    end
    self.element.Delete.DoClick = function()
        self.sequencer:Next(self, "Delete", self.element.FileName:GetValue())
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

SMH.Systems.Register("LoadFrameSystem", SYS)