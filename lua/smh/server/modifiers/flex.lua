
MOD.Name = "Facial flexes";

function MOD:Save(entity, frame)

	local count = entity:GetFlexNum();
	if count <= 0 then return nil; end

	local data = {};

	data.Scale = entity:GetFlexScale();

	data.Weights = {};

	for i = 0, count - 1 do
		data.Weights[i] = entity:GetFlexWeight(i);
	end

	return data;

end

function MOD:Load(entity, frame, data)

	local count = entity:GetFlexNum();
	if count <= 0 then return; end --Shouldn't happen, but meh

	entity:SetFlexScale(data.Scale);

	for i, f in pairs(data.Weights) do

		local w = entity:GetFlexWeight(i);
		if w ~= f then
			entity:SetFlexWeight(i, f);
		end

	end

end