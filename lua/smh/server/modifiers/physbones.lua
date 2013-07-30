
MOD.Name = "Physical Bones";

function MOD:Save(entity, frame)

	local count = entity:GetPhysicsObjectCount();
	if count <= 0 then return nil; end

	local data = {};

	for i = 0, count - 1 do

		local pb = entity:GetPhysicsObjectNum(i);
		local b = entity:TranslatePhysBoneToBone(i);

		local d = {};
		d.Pos = pb:GetPos();
		d.Ang = pb:GetAngles();
		d.Moveable = pb:IsMoveable();

		data[i] = d;

	end

	return data;

end

function MOD:Load(entity, frame, data)

	local count = entity:GetPhysicsObjectCount();
	if count <= 0 then return; end --Shouldn't happen, but meh

	for i = 0, count - 1 do

		local pb = entity:GetPhysicsObjectNum(i);
		local b = entity:TranslatePhysBoneToBone(i);

		local d = data[i];
		pb:SetPos(d.Pos);
		pb:SetAngles(d.Ang);
		pb:EnableMotion(!d.Moveable);

	end

end