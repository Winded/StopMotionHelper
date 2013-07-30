
MOD.Name = "Eye target";

function MOD:HasEyes(entity)

	local Eyes = entity:LookupAttachment("eyes");

	if Eyes == 0 then return false; end
	return true;

end

function MOD:Save(entity, frame)

	if not self:HasEyes(entity) then return nil; end

	local data = {};

	data.EyeTarget = entity:GetEyeTarget();

	return data;

end

function MOD:Load(entity, frame, data)

	if not self:HasEyes(entity) then return nil; end --Shouldn't happen, but meh

	entity:SetEyeTarget(data.EyeTarget);

end