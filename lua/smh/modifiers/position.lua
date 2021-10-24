
MOD.Name = "Position and Rotation";

function MOD:Save(entity)

	local data = {};
	data.Pos = entity:GetPos();
	data.Ang = entity:GetAngles();
	return data;

end

function MOD:LoadGhost(entity, ghost, data)
	self:Load(ghost, data);
end

function MOD:Load(entity, data)

	entity:SetPos(data.Pos);
	entity:SetAngles(data.Ang);

end

function MOD:LoadBetween(entity, data1, data2, percentage)
	
	local Pos = SMH.LerpLinearVector(data1.Pos, data2.Pos, percentage);
	local Ang = SMH.LerpLinearAngle(data1.Ang, data2.Ang, percentage);

	entity:SetPos(Pos);
	entity:SetAngles(Ang);
	
end