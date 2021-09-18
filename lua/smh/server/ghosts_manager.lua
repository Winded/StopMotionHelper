local GhostData = {}
local LastFrame = 0

local function CreateGhost(entity, color)
    local class = entity:GetClass()
    local model = entity:GetModel()

    local g
    if class == "prop_ragdoll" then
        g = ents.Create("prop_ragdoll")
    else
        g = ents.Create("prop_dynamic")
		
		if class == "prop_effect" and IsValid(entity.AttachedEntity) then
			model = entity.AttachedEntity:GetModel()
		end
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

local function SetGhostFrame(entity, ghost, modifiers)
    for name, mod in pairs(SMH.Modifiers) do
        if modifiers[name] ~= nil then
            mod:LoadGhost(entity, ghost, modifiers[name]);
        end
    end
end

local MGR = {}

MGR.SetRendering = false

function MGR.SelectEntity(player, entity)
    if not GhostData[player] then
        GhostData[player] = {
            Entity = nil,
            Ghosts = {},
        }
    end

    GhostData[player].Entity = entity
end

function MGR.UpdateState(player, frame, settings)
	LastFrame = frame
	
    if not GhostData[player] then
        return
    end

    local ghosts = GhostData[player].Ghosts

    for _, ghost in pairs(ghosts) do
        if IsValid(ghost) then
            ghost:Remove()
        end
    end
    table.Empty(ghosts)
	
    if not settings.GhostPrevFrame and not settings.GhostNextFrame and not settings.OnionSkin or MGR.SetRendering then
        return
    end

    if not SMH.KeyframeData.Players[player] then
        return
    end

    local entities = SMH.KeyframeData.Players[player].Entities
    if not settings.GhostAllEntities and IsValid(GhostData[player].Entity) and entities[GhostData[player].Entity] then
        entities = {
			[GhostData[player].Entity] = entities[GhostData[player].Entity]
		}
    elseif not settings.GhostAllEntities then
        return
    end

    local alpha = settings.GhostTransparency * 255

    for entity, keyframes in pairs(entities) do
        
        local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, frame, true)
        if not prevKeyframe and not nextKeyframe then
            continue
        end

        if lerpMultiplier == 0 then
            if settings.GhostPrevFrame and prevKeyframe.Frame < frame then
                local g = CreateGhost(entity, Color(200, 0, 0, alpha))
                table.insert(ghosts, g)
                SetGhostFrame(entity, g, prevKeyframe.Modifiers)
            elseif settings.GhostNextFrame and nextKeyframe.Frame > frame then
                local g = CreateGhost(entity, Color(0, 200, 0, alpha))
                table.insert(ghosts, g)
                SetGhostFrame(entity, g, nextKeyframe.Modifiers)
            end
        else
            if settings.GhostPrevFrame then
                local g = CreateGhost(entity, Color(200, 0, 0, alpha))
                table.insert(ghosts, g)
                SetGhostFrame(entity, g, prevKeyframe.Modifiers)
            end
            if settings.GhostNextFrame then
                local g = CreateGhost(entity, Color(0, 200, 0, alpha))
                table.insert(ghosts, g)
                SetGhostFrame(entity, g, nextKeyframe.Modifiers)
            end
        end

        if settings.OnionSkin then
            for _, keyframe in pairs(keyframes) do
                local g = CreateGhost(entity, Color(255, 255, 255, alpha))
                table.insert(ghosts, g)
                SetGhostFrame(entity, g, keyframe.Modifiers)
            end
        end

    end
end

function MGR.UpdateSettings(player, settings)
	MGR.UpdateState(player, LastFrame, settings)
end

SMH.GhostsManager = MGR
