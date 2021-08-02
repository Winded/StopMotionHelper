
MOD.Name = "Skin";

function MOD:Save(entity)
    return entity:GetSkin();
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data);
end

function MOD:Load(entity, data)
    entity:SetSkin(data);
end

function MOD:LoadBetween(entity, data1, data2, percentage)

	self:Load(entity, data1);
	
end