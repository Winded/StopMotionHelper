MOD.Name = "Model scale";

function MOD:Save(entity)
    return {
        ModelScale = entity:GetModelScale();
    };
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data);
end

function MOD:Load(entity, data)
    entity:SetModelScale(data.ModelScale);
end

function MOD:LoadBetween(entity, data1, data2, percentage)

    local lerpedModelScale = SMH.LerpLinear(data1.ModelScale, data2.ModelScale, percentage);
    entity:SetModelScale(lerpedModelScale);

end
