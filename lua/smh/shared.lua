
if not SMH then
	SMH = {};
end

SMH.DefaultData = {

	Entity = nil,

	Position = 0,

	PlaybackRate = 30,
	PlaybackLength = 100,

	ActiveFrames = {},
	EditedFrame = nil,

	EaseIn = 0,
	EaseOut = 0,

	ShowEaseOptions = false,
	
	ShowSettings = false,
	ShowHelp = false,

};

-- Fix bone manipulations.
hook.Add("PlayerSpawnedRagdoll", "SMHRagdollFix", function(pl, model, ragdoll)
	for i = 0, ragdoll:GetBoneCount() - 1 do
		ragdoll:ManipulateBonePosition(i, Vector(0, 0, 0));
		ragdoll:ManipulateBoneAngles(i, Angle(0, 0, 0));
		ragdoll:ManipulateBoneScale(i, Vector(1, 1, 1));
	end
end);