
MOD.Name = "Eye target";

function MOD:IsEffect(entity) -- checking if the entity is an effect prop
	if entity:GetClass() == "prop_effect" and IsValid(entity.AttachedEntity) then return true; end
	return false;
end

function MOD:HasEyes(entity)
	
	local Eyes = entity:LookupAttachment("eyes");

	if Eyes == 0 then return false; end
	return true;

end

function MOD:Save(entity)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

	if not self:HasEyes(entity) then return nil; end

	local data = {};

	data.EyeTarget = entity:GetEyeTarget();

	return data;

end

function MOD:Load(entity, data)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

	if not self:HasEyes(entity) then return; end --Shouldn't happen, but meh

	entity:SetEyeTarget(data.EyeTarget);

end

function MOD:LoadBetween(entity, data1, data2, percentage)

	if self:IsEffect(entity) then
		entity = entity.AttachedEntity;
	end

	if not self:HasEyes(entity) then return; end --Shouldn't happen, but meh

	local et = SMH.LerpLinearVector(data1.EyeTarget, data2.EyeTarget, percentage);

	entity:SetEyeTarget(et);

end