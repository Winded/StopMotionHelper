
MOD.Name = "Position and Rotation";

function MOD:Save(entity, frame)

	local data = {};
	data.Pos = entity:GetPos();
	data.Ang = entity:GetAngles();
	return data;

end

function MOD:Load(entity, frame, data)

	entity:SetPos(data.Pos);
	entity:SetAngles(data.Ang);

end