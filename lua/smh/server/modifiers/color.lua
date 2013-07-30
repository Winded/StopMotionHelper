
MOD.Name = "Color";

function MOD:Save(entity, frame)

	local color = entity:GetColor();
	return { Color = color };

end

function MOD:Load(entity, frame, data)

	entity:SetColor(data.Color);

end