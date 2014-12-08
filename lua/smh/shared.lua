
if not SMH then
	SMH = {};
end

include("smh/shared/frames.lua");

-- Fix bone manipulations.
hook.Add("PlayerSpawnedRagdoll","smhRagdollFix",
function(pl,mdl,rag)
	for i = 0, rag:GetBoneCount() - 1 do
		rag:ManipulateBonePosition(i, Vector(0, 0, 0));
		rag:ManipulateBoneAngles(i, Angle(0, 0, 0));
		rag:ManipulateBoneScale(i, Vector(1, 1, 1));
	end
end)