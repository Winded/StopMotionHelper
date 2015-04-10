
-- Bone translation functions, so we can change their functionality here in case the original ones fuck up even more

function GetPhysBoneParent(entity, bone)
	local b = PhysBoneToBone(entity, bone);
	local i = 1;
	while true do
		b = entity:GetBoneParent(b);
		local parent = BoneToPhysBone(entity, b);
		if parent >= 0 and parent ~= bone then
			return parent;
		end
		i = i + 1;
		if i > 128 then --We've gone through all possible bones, so we get out.
			break;
		end
	end
	return -1;
end

function PhysBoneToBone(ent, bone)
	return ent:TranslatePhysBoneToBone(bone);
end

function BoneToPhysBone(ent, bone)
	for i = 0, ent:GetPhysicsObjectCount() - 1 do
		local b = ent:TranslatePhysBoneToBone(i);
		if bone == b then
			return i;
		end
	end
	return -1;
end