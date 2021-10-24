
MOD.Name = "Bodygroup";

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

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

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

    for id, value in pairs(data) do
        entity:SetBodygroup(id, value);
    end
end

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

    self:Load(entity, data1);

end
