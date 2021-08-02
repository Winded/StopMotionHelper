
MOD.Name = "Bodygroup";

function MOD:Save(entity)
    local data = {};
    local bgs = entity:GetBodyGroups();
    for _, bg in pairs(bgs) do
        data[bg.id] = entity:GetBodygroup(bg.id);
    end
    return data;
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data);
end

function MOD:Load(entity, data)
    for id, value in pairs(data) do
        entity:SetBodygroup(id, value);
    end
end

function MOD:LoadBetween(entity, data1, data2, percentage)

	self:Load(entity, data1);

end