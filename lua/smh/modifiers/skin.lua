
MOD.Name = "Skin";

function MOD:IsEffect(entity) -- checking if the entity is an effect prop
	if entity:GetClass() == "prop_effect" and IsValid(entity.AttachedEntity) then return true; end
	return false;
end

function MOD:Save(entity)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

    return entity:GetSkin();
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data);
end

function MOD:Load(entity, data)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

    entity:SetSkin(data);
end

function MOD:LoadBetween(entity, data1, data2, percentage)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

	self:Load(entity, data1);
	
end