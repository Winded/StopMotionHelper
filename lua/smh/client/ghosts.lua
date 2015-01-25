
SMH.Ghosts = {};

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

	if type == SMH.GhostTypes.PrevFrame then
		g:SetColor(Color(200, 0, 0, 100));
	elseif type == SMH.GhostTypes.NextFrame then
		g:SetColor(Color(0, 200, 0, 100));
	else
		g:SetColor(Color(255, 255, 255, 100));
	end

	g.Entity = entity;
	g.Type = type;

	table.insert(SMH.Ghosts, g);

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

	for _, ghost in pairs(SMH.Ghosts) do
		table.RemoveByValue(SMH.Ghosts, ghost);
		ghost:Remove();
	end

	local data = SMH.Data.GhostData;
	local prevFrame = SMH.Data.GhostPrevFrame;
	local nextFrame = SMH.Data.GhostNextFrame;
	local allEnts = SMH.Data.GhostAllEntities;

	if not data or table.Count(data) == 0 then
		return;
	end

	for _, gdata in pairs(data) do
		
		local entity = gdata.Entity;
		local frameData = gdata.Data;
		local type = gdata.Type;

		local g = SMH.CreateGhost(entity, type);
		SMH.SetGhostFrame(g, frameData);

	end

end