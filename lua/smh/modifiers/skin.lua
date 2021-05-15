
MOD.Name = "Skin";

function MOD:Save(player, entity)
    return entity:GetSkin();
end

function MOD:LoadGhost(player, entity, ghost, data)
    self:Load(player, ghost, data);
end

function MOD:Load(player, entity, data)
    entity:SetSkin(data);
end

function MOD:LoadBetween(player, entity, data1, data2, percentage)

	self:Load(player, entity, data1);
	
end