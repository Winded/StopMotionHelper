
MOD.Name = "Eye target";

function MOD:HasEyes(entity)

	local Eyes = entity:LookupAttachment("eyes");

	if Eyes == 0 then return false; end
	return true;

end

function MOD:Save(player, entity)

	if not self:HasEyes(entity) then return nil; end

	local data = {};

	data.EyeTarget = entity:GetEyeTarget();

	return data;

end

function MOD:Load(player, entity, data)

	if not self:HasEyes(entity) then return; end --Shouldn't happen, but meh

	entity:SetEyeTarget(data.EyeTarget);

end

function MOD:LoadBetween(player, entity, data1, data2, percentage)
	if not player.SMHData.TweenDisable then
		if not self:HasEyes(entity) then return; end --Shouldn't happen, but meh

		local et = SMH.LerpLinearVector(data1.EyeTarget, data2.EyeTarget, percentage);

		entity:SetEyeTarget(et);
	end
end