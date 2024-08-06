
MOD.Name = "Physical Bones";

function MOD:Save(entity)

    local count = entity:GetPhysicsObjectCount();
    if count <= 0 then return nil; end

    local data = {};

    for i = 0, count - 1 do

        local pb = entity:GetPhysicsObjectNum(i);
        local parent = entity:GetPhysicsObjectNum(GetPhysBoneParent(entity, i));

        local d = {};

        d.Pos = pb:GetPos();
        d.Ang = pb:GetAngles();

        if parent then
            d.LocalPos, d.LocalAng = WorldToLocal(pb:GetPos(), pb:GetAngles(), parent:GetPos(), parent:GetAngles());
        end

        d.Moveable = pb:IsMoveable();

        data[i] = d;

    end

    return data;

end

function MOD:Load(entity, data, settings)

    if settings.IgnorePhysBones then
        return;
    end

    local count = entity:GetPhysicsObjectCount();

    for i = 0, count - 1 do

        local pb = entity:GetPhysicsObjectNum(i);
        local parent = entity:GetPhysicsObjectNum(GetPhysBoneParent(entity, i));

        local d = data[i];

        if parent and settings.LocalizePhysBones and d.LocalPos and d.LocalAng then
            local pos, ang = LocalToWorld(d.LocalPos, d.LocalAng, parent:GetPos(), parent:GetAngles());
            pb:SetPos(pos);
            pb:SetAngles(ang);
        else
            pb:SetPos(d.Pos);
            pb:SetAngles(d.Ang);
        end

        if settings.FreezeAll then
            pb:EnableMotion(false);
        else
            pb:EnableMotion(d.Moveable);
        end

        pb:Wake();

    end

end

function MOD:LoadGhost(entity, ghost, data)

    local count = ghost:GetPhysicsObjectCount();

    for i = 0, count - 1 do

        local pb = ghost:GetPhysicsObjectNum(i);

        pb:EnableMotion(true);
        pb:Wake();

        local d = data[i];
        pb:SetPos(d.Pos);
        pb:SetAngles(d.Ang);

        pb:EnableMotion(false);
        pb:Wake();

    end

end

function MOD:LoadGhostBetween(entity, ghost, data1, data2, percentage)

    local count = ghost:GetPhysicsObjectCount();

    for i = 0, count - 1 do

        local pb = ghost:GetPhysicsObjectNum(i);

        local d1 = data1[i];
        local d2 = data2[i];

        local Pos = SMH.LerpLinearVector(d1.Pos, d2.Pos, percentage);
        local Ang = SMH.LerpLinearAngle(d1.Ang, d2.Ang, percentage);

        pb:EnableMotion(false);
            pb:SetPos(Pos);
        pb:SetAngles(Ang);

        pb:Wake();

    end
end

function MOD:LoadBetween(entity, data1, data2, percentage, settings)

    if settings.IgnorePhysBones then
        return;
    end

    local count = entity:GetPhysicsObjectCount();

    for i = 0, count - 1 do
            local pb = entity:GetPhysicsObjectNum(i);

        local d1 = data1[i];
        local d2 = data2[i];

        local Pos = SMH.LerpLinearVector(d1.Pos, d2.Pos, percentage);
        local Ang = SMH.LerpLinearAngle(d1.Ang, d2.Ang, percentage);

        if settings.FreezeAll then
            pb:EnableMotion(false);
        else
            pb:EnableMotion(d1.Moveable);
        end
        pb:SetPos(Pos);
        pb:SetAngles(Ang);

        pb:Wake();
    end

end

function MOD:Offset(data, origindata, worldvector, worldangle, hitpos)

    if not hitpos then
        hitpos = origindata[0].Pos;
    end

    local newdata = {};

    for id, kdata in pairs(data) do

        local d = {};
        local Pos, Ang = WorldToLocal(kdata.Pos, kdata.Ang, origindata[0].Pos, Angle(0, 0, 0));
        d.Pos, d.Ang = LocalToWorld(Pos, Ang, worldvector, worldangle);
        d.Pos = d.Pos + hitpos;

        if kdata.LocalPos and kdata.LocalAng then -- those shouldn't change
            d.LocalPos, d.LocalAng = kdata.LocalPos, kdata.LocalAng;
        end

        d.Moveable = kdata.Moveable;

        newdata[id] = d;
    end

    return newdata;

end

function MOD:OffsetDupe(entity, data, origindata)

    local pb = entity:GetPhysicsObjectNum(0);
    if not IsValid(pb) then return nil end

    local entPos, entAng = pb:GetPos(), pb:GetAngles();
    local newdata = {};

    for id, kdata in pairs(data) do

        local d = {};
        d.Pos, d.Ang = WorldToLocal(kdata.Pos, kdata.Ang, origindata[0].Pos, origindata[0].Ang);
        d.Pos, d.Ang = LocalToWorld(d.Pos, d.Ang, entPos, entAng);

        if kdata.LocalPos and kdata.LocalAng then -- those shouldn't change
            d.LocalPos, d.LocalAng = kdata.LocalPos, kdata.LocalAng;
        end

        d.Moveable = kdata.Moveable;

        newdata[id] = d;
    end

    return newdata;

end
