
MOD.Name = "Color";

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

    local color = entity:GetColor();
    return { Color = color };

end

function MOD:Load(entity, data)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

    entity:SetColor(data.Color);

end

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity;
    end

    local c1 = data1.Color;
    local c2 = data2.Color;

    local r = SMH.LerpLinear(c1.r, c2.r, percentage);
    local g = SMH.LerpLinear(c1.g, c2.g, percentage);
    local b = SMH.LerpLinear(c1.b, c2.b, percentage);
    local a = SMH.LerpLinear(c1.a, c2.a, percentage);

    entity:SetColor(Color(r, g, b, a));

end
