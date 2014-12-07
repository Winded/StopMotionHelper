
MOD.Name = "Pose parameters";

function MOD:Save(entity)

	local data = {};

	local count = entity:GetNumPoseParameters();
	for i = 0, count - 1 do
		local name = entity:GetPoseParameterName(i);
		data[name] = entity:GetPoseParameter(name);
	end

	return data;

end

function MOD:Load(entity, data)

	for name, value in pairs(data) do
		entity:SetPoseParameter(name, value);
	end

end

function MOD:LoadBetween(entity, data1, data2, percentage)
	for name, value1 in pairs(data1) do

		local value2 = data2[name];
		if value1 and value2 then
			entity:SetPoseParameter(name, SMH.LerpLinear(value1, value2, percentage));
		elseif value1 then
			entity:SetPoseParameter(name, value1);
		end

	end
end