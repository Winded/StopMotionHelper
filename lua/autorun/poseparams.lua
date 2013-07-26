
//Code for overwriting SetPoseParameter and adding GetPoseParams

local meta = FindMetaTable("Entity");

meta.SetPoseParameterOld = meta.SetPoseParameter
function meta:SetPoseParameter(name,val)
	self.SetPoseParameterOld(self,name,val)
	if !self.PoseParams then self.PoseParams = {} end
	if !table.HasValue(self.PoseParams,name) then
		table.insert(self.PoseParams,name)
	end
end

function meta:GetPoseParams()
	if !self.PoseParams then self.PoseParams = {} end
	return self.PoseParams
end