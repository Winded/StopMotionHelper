local GhostData = {}

local function CreateGhost(entity, color)
	local class = entity:GetClass()
	local model = entity:GetModel()

	local g
	if class == "prop_ragdoll" then
		g = ents.Create("prop_ragdoll")
	else
		g = ents.Create("prop_dynamic")
	end

	g:SetModel(model)
	g:SetRenderMode(RENDERMODE_TRANSCOLOR)
	g:SetCollisionGroup(COLLISION_GROUP_NONE)
	g:SetNotSolid(true)
    g:SetColor(color)
	g:Spawn()

	g:SetPos(entity:GetPos())
	g:SetAngles(entity:GetAngles())

	g.SMHGhost = true
	g.Entity = entity

	return g
end

local function SetGhostFrame(player, entity, ghost, modifiers)
	for name, mod in pairs(SMH.Modifiers) do
		if data[name] ~= nil then
			mod:LoadGhost(player, entity, ghost, modifiers[name]);
		end
	end
end

local MGR = {}

function MGR.UpdateSettings(player, settings)
    if not GhostData[player] then
        GhostData[player] = {
            Settings = {},
            Ghosts = {},
        }
    end

    GhostData[player].Settings = settings
    MGR.UpdateState(player)
end

function MGR.UpdateState(player, frame)
    if not GhostData[player] then
        return
    end

    local ghosts = GhostData[player].Ghosts
    local settings = GhostData[player].Settings

	for _, ghost in pairs(ghosts) do
		if IsValid(ghost) then
			ghost:Remove();
		end
	end
    table.Empty(ghosts)

    if not settings.PrevKeyframe and not settings.NextKeyframe and not settings.OnionSkin then
        return
    end

    if not SMH.KeyframeData.Players[player] then
        return
    end

    local entities = SMH.KeyframeData.Players[player].entities
    if not settings.GhostAll and IsValid(settings.TargetEntity) and entities[settings.TargetEntity] then
        entities = {
            settings.TargetEntity = entities[settings.TargetEntity],
        }
    elseif not settings.GhostAll then
        return
    end

    local alpha = settings.Transparency * 255

	for entity, keyframes in pairs(entities) do
		
		local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, frame)
        if not prevKeyframe and not nextKeyframe then
            continue
        end

		if lerpMultiplier == 0 then
			if settings.PrevKeyframe and prevKeyframe.Frame < frame then
				local g = CreateGhost(entity, Color(200, 0, 0, alpha))
                table.insert(ghosts, g)
				SetGhostFrame(player, entity, g, prevKeyframe.Modifiers)
			elseif settings.NextKeyframe and prevKeyframe.Frame > frame then
				local g = CreateGhost(entity, Color(0, 200, 0, alpha))
                table.insert(ghosts, g)
				SetGhostFrame(player, entity, g, prevKeyframe.Modifiers)
			end
		else
			if settings.PrevKeyframe then
				local g = CreateGhost(entity, Color(200, 0, 0, alpha))
                table.insert(ghosts, g)
				SetGhostFrame(player, entity, g, prevKeyframe.Modifiers)
			end
			if settings.NextKeyframe then
				local g = CreateGhost(entity, Color(0, 200, 0, alpha))
                table.insert(ghosts, g)
				SetGhostFrame(player, entity, g, nextKeyframe.Modifiers)
			end
		end

		if settings.OnionSkin then
			for _, keyframe in pairs(keyframes) do
				local g = CreateGhost(entity, Color(255, 255, 255, alpha))
                table.insert(ghosts, g)
				SetGhostFrame(player, entity, g, keyframe.Modifiers)
			end
		end

	end
end

SMH.GhostsManager = MGR
