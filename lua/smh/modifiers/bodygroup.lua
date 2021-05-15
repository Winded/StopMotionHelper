
MOD.Name = "Bodygroup";

function MOD:Save(player, entity)
    local data = {};
    local bgs = entity:GetBodyGroups();
    for _, bg in pairs(bgs) do
        data[bg.id] = entity:GetBodygroup(bg.id);
    end
    return data;
end

function MOD:LoadGhost(player, entity, ghost, data)
    self:Load(player, ghost, data);
end

function MOD:Load(player, entity, data)
    for id, value in pairs(data) do
        entity:SetBodygroup(id, value);
    end
end

function MOD:LoadBetween(player, entity, data1, data2, percentage)

	self:Load(player, entity, data1);

end