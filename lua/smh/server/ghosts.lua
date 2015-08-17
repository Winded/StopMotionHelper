
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
		if data[name] ~= nil then
			mod:LoadGhost(player, entity, ghost, data[name]);
		end
	end

end

function SMH.RefreshGhosts(player)

	local data = player.SMHData;

	local ghosts = table.Where(SMH.Ghosts, function(item) return item.Player == player; end);
	for _, ghost in pairs(ghosts) do
		table.RemoveByValue(SMH.Ghosts, ghost);
		if IsValid(ghost) then
			ghost:Remove();
		end
	end

	local position = data.Position;
	local prevFrame = data.GhostPrevFrame;
	local nextFrame = data.GhostNextFrame;
	local onion = data.OnionSkin;
	local rendering = data.Rendering;
	local allEnts = data.GhostAllEntities;
	if rendering or (not prevFrame and not nextFrame and not onion) then
		return;
	end

	local entities = {data.Entity};
	if allEnts then
		entities = SMH.GetEntities(player);
	end

	for _, entity in pairs(entities) do
		
		local frames = table.Where(SMH.Frames, function(item) return item.Player == player and item.Entity == entity; end);
		local pF, nF = SMH.GetPositionFrames(frames, position, true);

		if pF and not nF then
			if prevFrame and pF.Position < position then
				local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.PrevFrame);
				SMH.SetGhostFrame(g, pF.EntityData);
			elseif nextFrame and pF.Position > position then
				local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.NextFrame);
				SMH.SetGhostFrame(g, pF.EntityData);
			end
		else
			if prevFrame and pF then
				local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.PrevFrame);
				SMH.SetGhostFrame(g, pF.EntityData);
			end
			if nextFrame and nF then
				local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.NextFrame);
				SMH.SetGhostFrame(g, nF.EntityData);
			end
		end

		if onion then
			for _, frame in pairs(frames) do
				local g = SMH.CreateGhost(player, entity, SMH.GhostTypes.OnionSkin);
				SMH.SetGhostFrame(g, frame.EntityData);
			end
		end

	end

end