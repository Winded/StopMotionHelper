local GhostData = {}
local LastFrame = 0
local LastTimeline = 1
local SpawnGhost = {}
local SpawnGhostData = {}
local GhostSettings = {}

local function CreateGhost(player, entity, color, frame)
    for _, ghost in ipairs(GhostData[player].Ghosts) do
        if ghost.Entity == entity and ghost.Frame == frame then return ghost end -- we already have a ghost on this entity for this frame, just return it.
    end

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
    g.Frame = frame
    g.Physbones = false

    return g
end

local function SetGhostFrame(entity, ghost, modifiers)
    for name, mod in pairs(SMH.Modifiers) do
        if modifiers[name] ~= nil then
            mod:LoadGhost(entity, ghost, modifiers[name])
            if name == "physbones" then ghost.Physbones = true end
            break
        end
    end
end

local function SetGhostBetween(entity, ghost, data1, data2, percentage)
    for name, mod in pairs(SMH.Modifiers) do
        if data1[name] ~= nil then
            mod:LoadGhostBetween(entity, ghost, data1[name], data2[name], percentage)
            if name == "physbones" then ghost.Physbones = true end
            break
        end
    end
end

local function ClearNoPhysGhosts(ghosts)
    for _, g in ipairs(ghosts) do
        if g:GetClass() == "prop_ragdoll" and not g.Physbones and IsValid(g) then
            g:Remove()
        end
    end
end

local MGR = {}

MGR.IsRendering = false

function MGR.SelectEntity(player, entity)
    if not GhostData[player] then
        GhostData[player] = {
            Entity = nil,
            Ghosts = {},
        }
    end

    GhostData[player].Entity = entity
end

function MGR.UpdateState(player, frame, settings, settimeline)
    LastFrame = frame
    LastTimeline = settimeline

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

    if not settings.GhostPrevFrame and not settings.GhostNextFrame and not settings.OnionSkin or MGR.IsRendering then
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
        local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
        if next(timeline) == nil then continue end
        local selectedtime  = settimeline
        if selectedtime > timeline.Timelines then
            selectedtime = 1
        end

        local filtermods = {}

        for _, name in ipairs(timeline.TimelineMods[selectedtime]) do
            filtermods[name] = true
        end

        for name, _ in pairs(filtermods) do -- gonna apply used modifiers
            local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, frame, true, name)
            if not prevKeyframe and not nextKeyframe then
                continue
            end

            if lerpMultiplier == 0 then
                if settings.GhostPrevFrame and prevKeyframe.Frame < frame then
                    local g = CreateGhost(player, entity, Color(200, 0, 0, alpha), prevKeyframe.Frame)
                    table.insert(ghosts, g)
                    SetGhostFrame(entity, g, prevKeyframe.Modifiers)
                elseif settings.GhostNextFrame and nextKeyframe.Frame > frame then
                    local g = CreateGhost(player, entity, Color(0, 200, 0, alpha), nextKeyframe.Frame)
                    table.insert(ghosts, g)
                    SetGhostFrame(entity, g, nextKeyframe.Modifiers)
                end
            else
                if settings.GhostPrevFrame then
                    local g = CreateGhost(player, entity, Color(200, 0, 0, alpha), prevKeyframe.Frame)
                    table.insert(ghosts, g)
                    SetGhostFrame(entity, g, prevKeyframe.Modifiers)
                end
                if settings.GhostNextFrame then
                    local g = CreateGhost(player, entity, Color(0, 200, 0, alpha), nextKeyframe.Frame)
                    table.insert(ghosts, g)
                    SetGhostFrame(entity, g, nextKeyframe.Modifiers)
                end
            end

            if settings.OnionSkin then
                for _, keyframe in pairs(keyframes) do
                    if keyframe.Modifier == name then
                        local g = CreateGhost(player, entity, Color(255, 255, 255, alpha), keyframe.Frame)
                        table.insert(ghosts, g)
                        SetGhostFrame(entity, g, keyframe.Modifiers)
                    end
                end
            end
        end

        for _, g in ipairs(ghosts) do
            for name, mod in pairs(SMH.Modifiers) do
                if filtermods[name] then continue end -- we used these modifiers already
                local IsSet = false
                for _, keyframe in pairs(keyframes) do
                    if keyframe.Frame == g.Frame and keyframe.Modifier == name then
                        SetGhostFrame(entity, g, keyframe.Modifiers)
                        IsSet = true
                        break
                    end
                end

                if not IsSet then
                    local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, g.Frame, true, name)
                    if not prevKeyframe then
                        continue
                    end

                    if lerpMultiplier <= 0 or settings.TweenDisable then
                        SetGhostFrame(entity, g, prevKeyframe.Modifiers)
                    elseif lerpMultiplier >= 1 then
                        SetGhostFrame(entity, g, nextKeyframe.Modifiers)
                    else
                        SetGhostBetween(entity, g, prevKeyframe.Modifiers, nextKeyframe.Modifiers, lerpMultiplier)
                    end
                end
            end
        end

        ClearNoPhysGhosts(ghosts) -- need to delete ragdoll ghosts that don't have physbone modifier, or else they'll just keep falling through ground.
    end
end

function MGR.UpdateSettings(player, settings)
    MGR.UpdateState(player, LastFrame, settings, LastTimeline)
end

function MGR.SetSpawnPreview(class, modelpath, data, settings, player)
    if IsValid(SpawnGhost[player]) then
        SpawnGhost[player]:Remove()
    end
    SpawnGhost[player] = nil
    SpawnGhostData[player] = nil

    if class == "prop_ragdoll" and not data["physbones"] then
        player:ChatPrint("Stop Motion Helper: Can't set preview for the ragdoll as the save doesn't have Physical Bones modifier!")
        return
    end
    if not data["physbones"] and not data["position"] then
        player:ChatPrint("Stop Motion Helper: Can't set preview for the entity as the save doesn't have Physical Bones or Position and Rotation modifiers!")
        return
    end

    SpawnGhostData[player] = data
    GhostSettings[player] = settings

    if class == "prop_ragdoll" then
        SpawnGhost[player] = ents.Create("prop_ragdoll")
    else
        SpawnGhost[player] = ents.Create("prop_dynamic")
    end
    local alpha = settings.GhostTransparency * 255

    SpawnGhost[player]:SetModel(modelpath)
    SpawnGhost[player]:SetRenderMode(RENDERMODE_TRANSCOLOR)
    SpawnGhost[player]:SetCollisionGroup(COLLISION_GROUP_NONE)
    SpawnGhost[player]:SetNotSolid(true)
    SpawnGhost[player]:SetColor(Color(255, 255, 255, alpha))
    SpawnGhost[player]:Spawn()

    for name, mod in pairs(SMH.Modifiers) do
        if name == "color" then continue end
        if data[name] then
            mod:Load(SpawnGhost[player], data[name].Modifiers, settings)
        end
    end
end

function MGR.SpawnClear(player)
    if IsValid(SpawnGhost[player]) then
        SpawnGhost[player]:Remove()
        SpawnGhost[player] = nil
    end
end

SMH.GhostsManager = MGR

hook.Add("Think", "SMHGhostSpawnOffsetPreview", function()
    for player, data in pairs(SMH.Spawner.OriginData) do
        if SMH.Spawner.OffsetMode[player] and SpawnGhost[player] then
            for name, mod in pairs(SMH.Modifiers) do
                if name == "color" then continue end
                if SpawnGhostData[player][name] and data[name] and (name == "physbones" or name == "position") then
                    local offsetpos = SMH.Spawner.OffsetPos[player] or Vector(0, 0, 0)
                    local offsetang = SMH.Spawner.OffsetAng[player] or Angle(0, 0, 0)

                    offsetdata = mod:Offset(SpawnGhostData[player][name].Modifiers, data[name].Modifiers, offsetpos, offsetang, player:GetEyeTraceNoCursor().HitPos)
                    mod:Load(SpawnGhost[player], offsetdata, GhostSettings[player])
                end
            end
        end
    end
end)
