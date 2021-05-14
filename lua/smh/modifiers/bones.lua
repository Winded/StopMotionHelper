
MOD.Name = "Bones";

function MOD:Save(player, entity)

	local count = entity:GetBoneCount();

	local data = {};

	for b = 0, count - 1 do

		local d = {};
		d.Pos = entity:GetManipulateBonePosition(b);
		d.Ang = entity:GetManipulateBoneAngles(b);
		d.Scale = entity:GetManipulateBoneScale(b);

		data[b] = d;

	end

	return data;

end

function MOD:LoadGhost(player, entity, ghost, data)
	self:Load(player, ghost, data);
end

function MOD:Load(player, entity, data)

	local count = entity:GetBoneCount();

	for b = 0, count - 1 do

		local d = data[b];
		entity:ManipulateBonePosition(b, d.Pos);
		entity:ManipulateBoneAngles(b, d.Ang);
		entity:ManipulateBoneScale(b, d.Scale);

	end

end

function MOD:LoadBetween(player, entity, data1, data2, percentage)

	local count = entity:GetBoneCount();

	for b = 0, count - 1 do

		local d1 = data1[b];
		local d2 = data2[b];

		local Pos = SMH.LerpLinearVector(d1.Pos, d2.Pos, percentage);
		local Ang = SMH.LerpLinearAngle(d1.Ang, d2.Ang, percentage);
		local Scale = SMH.LerpLinear(d1.Scale, d2.Scale, percentage);

		entity:ManipulateBonePosition(b, Pos);
		entity:ManipulateBoneAngles(b, Ang);
		entity:ManipulateBoneScale(b, Scale);

	end
end