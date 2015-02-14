
SMH.Ghosts = {};

-- Create a ghost entity for the given entity
function SMH.CreateGhost(player, entity, type)
	
	local class = entity:GetClass();
	local model = entity:GetModel();
	local alpha = player.SMHData.GhostTransparency * 255;

	local g;
	if class == "prop_ragdoll" then
		g = ents.Create("prop_ragdoll");
	else
		g = ents.Create("prop_dynamic");
	end

	g:SetModel(model);
	g:SetRenderMode(RENDERMODE_TRANSCOLOR);
	g:SetCollisionGroup(COLLISION_GROUP_NONE);
	g:SetNotSolid(true);
	if type == SMH.GhostTypes.PrevFrame then
		g:SetColor(Color(200, 0, 0, alpha));
	elseif type == SMH.GhostTypes.NextFrame then
		g:SetColor(Color(0, 200, 0, alpha));
	else
		g:SetColor(Color(255, 255, 255, alpha));
	end
	g:Spawn();

	g:SetPos(entity:GetPos());
	g:SetAngles(entity:GetAngles());

	g.SMHGhost = true;
	g.Player = player;
	g.Entity = entity;
	g.Type = type;

	table.insert(SMH.Ghosts, g);

	return g;

end

function SMH.SetGhostFrame(ghost, data)

	local player = ghost.Player;
	local entity = ghost.Entity;
	if not IsValid(entity) then
		return;
	end

	for name, mod in pairs(SMH.Modifiers) do
		mod:LoadGhost(player, entity, ghost, data[name]);
	end

end

function SMH.RefreshGhosts(player)

	local data = player.SMHData;

	local ghosts = table.Where(SMH.Ghosts, function(item) return item.Player == player; end);
	for _, ghost in pairs(ghosts) do
		table.RemoveByValue(SMH.Ghosts, ghost);
		ghost:Remove();
	end

	local position = data.Position;
	local prevFrame = data.GhostPrevFrame;
	local nextFrame = data.GhostNextFrame;
	local rendering = data.Rendering;
	local allEnts = data.GhostAllEntities;
	if rendering or (not prevFrame and not nextFrame) then
		return;
	end

	local entities = {data.Entity};
	if allEnts then
		entities = SMH.GetEntities(player);
	end

	for _, entity in pairs(entities) do
		
		local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
		local pF, nF = SMH.GetPositionFrames(frames, position, true);

		if (prevFrame and pF) or (pF and not nF and pF.Position < position) then
			local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.PrevFrame);
			SMH.SetGhostFrame(g, pF.EntityData);
		end

		if (nextFrame and nF) or (pf and not nF and pF.Position > position) then
			local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.NextFrame);
			SMH.SetGhostFrame(g, nF.EntityData);
		end

	end

end