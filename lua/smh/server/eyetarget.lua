
-- New eye target functions to save eye target vector

local meta = FindMetaTable("Entity");

meta.SetEyeTargetOld = meta.SetEyeTarget;

function meta:SetEyeTarget(vec)

	self:SetEyeTargetOld(vec);
	self.EyeVec = vec;
	
end

function meta:GetEyeTarget()

	if not self.EyeVec then
		self.EyeVec = Vector(180, 0, 0);
	end

	return self.EyeVec;

end