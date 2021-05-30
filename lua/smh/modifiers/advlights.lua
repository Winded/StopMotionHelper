
MOD.Name = "Advanced Lights";

local validClasses = {
	projected_light = true,
	projected_light_new = true,
	cheap_light = true,
	expensive_light = true,
	expensive_light_new = true,
	spot_light = true
};

function MOD:IsAdvLight(entity)
	
	local theclass = entity:GetClass();
	
	return validClasses[theclass] or false;
	
end

function MOD:IsProjectedLight(entity)
	
	local theclass = entity:GetClass();
	
	if theclass == "cheap_light" or theclass == "spot_light" then return false; end
	return true;

end

function MOD:Save(player, entity)

	if not self:IsAdvLight(entity) then return nil; end

	local data = {};

	data.Brightness = entity:GetBrightness();
	data.Color = entity:GetLightColor();

	if self:IsProjectedLight(entity) then
		local theclass = entity:GetClass();
		
		if theclass ~= "expensive_light" and theclass ~= "expensive_light_new" then -- expensive lights don't have FoV settings, but they are projected lights
		
			data.FOV = entity:GetLightFOV();
			
		end
		
		data.Nearz = entity:GetNearZ();
		data.Farz = entity:GetFarZ();
		
	elseif entity:GetClass() == "cheap_light" then
	
		data.LightSize = entity:GetLightSize();
		
	else
		
		data.InFOV = entity:GetInnerFOV();
		data.OutFOV = entity:GetOuterFOV();
		data.Radius = entity:GetRadius();
		
	end
	
	return data;

end

function MOD:Load(player, entity, data)

	if not self:IsAdvLight(entity) then return; end -- can never be too sure?

	entity:SetBrightness(data.Brightness);
	entity:SetLightColor(data.Color);
	
	if self:IsProjectedLight(entity) then
		local theclass = entity:GetClass();
		
		if theclass ~= "expensive_light" and theclass ~= "expensive_light_new" then
		
			entity:SetLightFOV(data.FOV);
			
		end
		
		entity:SetNearZ(data.Nearz);
		entity:SetFarZ(data.Farz);
		
	elseif entity:GetClass() == "cheap_light" then
	
		entity:SetLightSize(data.LightSize);
		
	else
		
		entity:SetInnerFOV(data.InFOV);
		entity:SetOuterFOV(data.OutFOV);
		entity:SetRadius(data.Radius);
		
	end

end

function MOD:LoadBetween(player, entity, data1, data2, percentage)
	
	if not self:IsAdvLight(entity) then return; end -- can never be too sure?
	
	entity:SetBrightness(SMH.LerpLinear(data1.Brightness, data2.Brightness, percentage));
	entity:SetLightColor(SMH.LerpLinearVector(data1.Color, data2.Color, percentage));
	
	if self:IsProjectedLight(entity) then
		local theclass = entity:GetClass();
		
		if theclass ~= "expensive_light" and theclass ~= "expensive_light_new" then
		
			entity:SetLightFOV(SMH.LerpLinear(data1.FOV, data2.FOV, percentage));
			
		end
		
		entity:SetNearZ(SMH.LerpLinear(data1.Nearz, data2.Nearz, percentage));
		entity:SetFarZ(SMH.LerpLinear(data1.Farz, data2.Farz, percentage));
		
	elseif entity:GetClass() == "cheap_light" then
		
		entity:SetLightSize(SMH.LerpLinear(data1.LightSize, data2.LightSize, percentage));
		
	else
		
		entity:SetInnerFOV(SMH.LerpLinear(data1.InFOV, data2.InFOV, percentage));
		entity:SetOuterFOV(SMH.LerpLinear(data1.OutFOV, data2.OutFOV, percentage));
		entity:SetRadius(SMH.LerpLinear(data1.Radius, data2.Radius, percentage));
		
	end
	
end