MOD.Name = "Model scale";

function MOD:Save(player, entity)
    return {
        ModelScale = entity:GetModelScale();
    };
end

function MOD:LoadGhost(player, entity, ghost, data)
	self:Load(player, ghost, data);
end

function MOD:Load(player, entity, data)
    entity:SetModelScale(data.ModelScale);
end

function MOD:LoadBetween(player, entity, data1, data2, percentage)
	if not player.SMHData.TweenDisable then
	
		local lerpedModelScale = SMH.LerpLinear(data1.ModelScale, data2.ModelScale, percentage);
		entity:SetModelScale(lerpedModelScale);
	
	end
end