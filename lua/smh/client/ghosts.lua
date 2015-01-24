
SMH.Ghosts = {};
SMH.GhostTypes = {
	PrevFrame = 1,
	NextFrame = 2,
	OnionSkin = 3
};

-- Create a ghost entity for the given entity
function SMH.CreateGhost(entity, type)
	
	local class = entity:GetClass();
	local model = entity:GetModel();

	local g;
	if class == "prop_ragdoll" then
		g = ClientsideRagdoll(model);
		g:SetNoDraw(false);
		g:DrawShadow(true);
	else
		g = ClientsideModel(model);
	end

	g:SetPos(entity:GetPos());
	g:SetAngles(entity:GetAngles());

	g.Entity = entity;
	g.Type = type;

	return g;

end

function SMH.SetGhostFrame(ghost, data)

	local player = LocalPlayer();
	local entity = ghost.Entity;
	if not IsValid(entity) then
		return;
	end

	for name, mod in pairs(SMH.Modifiers) do
		mod:LoadGhost(player, entity, ghost, data[name]);
	end

end

function SMH.RefreshGhosts()
	-- TODO
end