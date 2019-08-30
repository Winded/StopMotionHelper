local SEQ = {}

function SEQ:sequenceHash(fromName, fromId, name)
    return fromName .. "[" .. fromId .. "]:" .. name
end

function SEQ:SetSequence(sequenceTable)
    for _, sequencePart in pairs(sequenceTable) do
        local hash = self:sequenceHash(sequencePart.From._Name, sequencePart.From._Id, sequencePart.Name)

        if self.sequenceTable[hash] ~= nil then
            error("Duplicate sequence " .. hash)
        end

        self.sequenceTable[hash] = sequencePart.To
    end
end

function SEQ:Next(source, sequenceName, ...)
    local hash = self:sequenceHash(source._Name, source._Id, sequenceName)
    if self.sequenceTable[hash] == nil then 
        error("Sequence " .. hash .. " not defined")
    end

    for _, receiver in pairs(self.sequenceTable[hash]) do
        receiver["Event" .. sequenceName](...)
    end
end

local SEQUENCER = {}

function SEQUENCER.Create()
    local sequencer = {}
    setmetatable(sequencer, SEQ)

    sequencer.sequenceTable = {}

    return sequencer
end

SMH.Sequencer = SEQUENCER