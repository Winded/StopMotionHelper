
MOD.Name = "Bones";

function MOD:Save(entity, frame)

	local count = entity:GetBoneCount();
	if count <= 0 then return nil; end

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

function MOD:Load(entity, frame, data)

	local count = entity:GetBoneCount();
	if count <= 0 then return; end --Shouldn't happen, but meh

	for b = 0, count - 1 do

		local d = data[i];
		entity:ManipulateBonePosition(b, d.Pos);
		entity:ManipulateBoneAngles(b, d.Ang);
		entity:ManipulateBoneScale(b, d.Scale);

	end

end