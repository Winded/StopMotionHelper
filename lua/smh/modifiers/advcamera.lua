
MOD.Name = "Advanced Cameras";

function MOD:IsAdvCamera(entity)

	if entity:GetClass() ~= "hl_camera" then return false; end
	return true;

end

function MOD:Save(player, entity)

	if not self:IsAdvCamera(entity) then return nil; end

	local data = {};

	data.FOV = entity:GetFOV();
	data.Nearz = entity:GetNearZ();
	data.Farz = entity:GetFarZ();
	data.Roll = entity:GetRoll();

	return data;

end

function MOD:Load(player, entity, data)

	if not self:IsAdvCamera(entity) then return; end -- can never be too sure?

	entity:SetFOV(data.FOV);
	entity:SetNearZ(data.Nearz);
	entity:SetFarZ(data.Farz);
	entity:SetRoll(data.Roll);

end

function MOD:LoadBetween(player, entity, data1, data2, percentage)
	
	if not self:IsAdvCamera(entity) then return; end -- can never be too sure?
	
	entity:SetFOV(SMH.LerpLinear(data1.FOV, data2.FOV, percentage));
	entity:SetNearZ(SMH.LerpLinear(data1.Nearz, data2.Nearz, percentage));
	entity:SetFarZ(SMH.LerpLinear(data1.Farz, data2.Farz, percentage));
	entity:SetRoll(SMH.LerpLinear(data1.Roll, data2.Roll, percentage));
	
end