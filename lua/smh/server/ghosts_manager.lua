local GhostData = {}
local LastFrame = 0
local LastTimeline = 1
local SpawnGhost, SpawnGhostData, GhostSettings = {}, {}, {}
local SpawnOffsetOn, SpawnOriginData, OffsetPos, OffsetAng = {}, {}, {}, {}

local function CreateGhost(player, entity, color, frame, ghostable)
    for _, ghost in ipairs(GhostData[player].Ghosts) do
        if ghost.Entity == entity and ghost.Frame == frame then return ghost end -- we already have a ghost on this entity for this frame, just return it.
    end

    local class = entity:GetClass()
    local model = entity:GetModel()

    local g
    if class == "prop_ragdoll" then
        g = ents.Create("prop_ragdoll")

        local flags = entity:GetSaveTable().spawnflags or 0
        if flags % (2 * 32768) >= 32768 then
            g:SetKeyValue("spawnflags",32768)
            g:SetSaveValue("m_ragdoll.allowStretch", true)
        end
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

    table.insert(ghostable, g)

    return g
end

local function SetGhostFrame(entity, ghost, modifiers, modname)
    if modifiers[modname] ~= nil then
        SMH.Modifiers[modname]:LoadGhost(entity, ghost, modifiers[modname])
        if modname == "physbones" then ghost.Physbones = true end
    end
end

local function SetGhostBetween(entity, ghost, data1, data2, modname, percentage)
    if data1[modname] ~= nil then
        SMH.Modifiers[modname]:LoadGhostBetween(entity, ghost, data1[modname], data2[modname], percentage)
        if modname == "physbones" then ghost.Physbones = true end
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

function MGR.SelectEntity(player, entities)
    if not GhostData[player] then
        GhostData[player] = {
            Entity = {},
            Ghosts = {},
        }
    end

    GhostData[player].Entity = table.Copy(entities)
end

function MGR.UpdateState(player, frame, settings, timeline, settimeline)
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
    local _, gentity = next(GhostData[player].Entity)
    if not settings.GhostAllEntities and IsValid(gentity) and entities[gentity] then
        local oldentities = table.Copy(entities)
        entities = {}
        for _, entity in pairs(GhostData[player].Entity) do
            entities[entity] = oldentities[entity]
        end
    elseif not settings.GhostAllEntities then
        return
    end

    local alpha = settings.GhostTransparency * 255
    local selectedtime  = settimeline
    if selectedtime > timeline.Timelines then -- this shouldn't really happen?
        selectedtime = 1
    end

    local filtermods = {}

    for _, name in ipairs(timeline.TimelineMods[selectedtime]) do
        filtermods[name] = true
    end

    for entity, keyframes in pairs(entities) do

        for name, _ in pairs(filtermods) do -- gonna apply used modifiers
            local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, frame, true, name)
            if not prevKeyframe and not nextKeyframe then
                continue
            end

            if lerpMultiplier == 0 then
                if settings.GhostPrevFrame and prevKeyframe.Frame < frame then
                    local g = CreateGhost(player, entity, Color(200, 0, 0, alpha), prevKeyframe.Frame, ghosts)
                    SetGhostFrame(entity, g, prevKeyframe.Modifiers, name)
                elseif settings.GhostNextFrame and nextKeyframe.Frame > frame then
                    local g = CreateGhost(player, entity, Color(0, 200, 0, alpha), nextKeyframe.Frame, ghosts)
                    SetGhostFrame(entity, g, nextKeyframe.Modifiers, name)
                end
            else
                if settings.GhostPrevFrame then
                    local g = CreateGhost(player, entity, Color(200, 0, 0, alpha), prevKeyframe.Frame, ghosts)
                    SetGhostFrame(entity, g, prevKeyframe.Modifiers, name)
                end
                if settings.GhostNextFrame then
                    local g = CreateGhost(player, entity, Color(0, 200, 0, alpha), nextKeyframe.Frame, ghosts)
                    SetGhostFrame(entity, g, nextKeyframe.Modifiers, name)
                end
            end

            if settings.OnionSkin then
                for _, keyframe in pairs(keyframes) do
                    if keyframe.Modifiers[name] then
                        local g = CreateGhost(player, entity, Color(255, 255, 255, alpha), keyframe.Frame, ghosts)
                        SetGhostFrame(entity, g, keyframe.Modifiers, name)
                    end
                end
            end
        end

        for _, g in ipairs(ghosts) do

            if not (g.Entity == entity) then continue end

            for name, mod in pairs(SMH.Modifiers) do
                if filtermods[name] then continue end -- we used these modifiers already
                local IsSet = false
                for _, keyframe in pairs(keyframes) do
                    if keyframe.Frame == g.Frame and keyframe.Modifiers[name] then
                        SetGhostFrame(entity, g, keyframe.Modifiers, name)
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
                        SetGhostFrame(entity, g, prevKeyframe.Modifiers, name)
                    elseif lerpMultiplier >= 1 then
                        SetGhostFrame(entity, g, nextKeyframe.Modifiers, name)
                    else
                        SetGhostBetween(entity, g, prevKeyframe.Modifiers, nextKeyframe.Modifiers, name, lerpMultiplier)
                    end
                end
            end
        end

        ClearNoPhysGhosts(ghosts) -- need to delete ragdoll ghosts that don't have physbone modifier, or else they'll just keep falling through ground.
    end
end

function MGR.UpdateSettings(player, timeline, settings)
    MGR.UpdateState(player, LastFrame, settings, timeline, LastTimeline)
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
        if name == "physbones" or name == "position" then
            local offsetpos = OffsetPos[player] or Vector(0, 0, 0)
            local offsetang = OffsetAng[player] or Angle(0, 0, 0)

            offsetdata = mod:Offset(data[name].Modifiers, SpawnOriginData[player][name].Modifiers, offsetpos, offsetang, nil)
            mod:Load(SpawnGhost[player], offsetdata, GhostSettings[player])
        elseif data[name] then
            mod:Load(SpawnGhost[player], data[name].Modifiers, settings)
        end
    end
end

function MGR.RefreshSpawnPreview(player, offseton)
    SpawnOffsetOn[player] = offseton
    if not IsValid(SpawnGhost[player]) then return end

    for name, mod in pairs(SMH.Modifiers) do
        if name == "color" then continue end
        if name == "physbones" or name == "position" then
            local offsetpos = OffsetPos[player] or Vector(0, 0, 0)
            local offsetang = OffsetAng[player] or Angle(0, 0, 0)

            offsetdata = mod:Offset(SpawnGhostData[player][name].Modifiers, SpawnOriginData[player][name].Modifiers, offsetpos, offsetang, nil)
            mod:Load(SpawnGhost[player], offsetdata, GhostSettings[player])
        elseif SpawnGhostData[player][name] then
            mod:Load(SpawnGhost[player], SpawnGhostData[player][name].Modifiers, GhostSettings[player])
        end
    end
end

function MGR.SpawnClear(player)
    if IsValid(SpawnGhost[player]) then
        SpawnGhost[player]:Remove()
        SpawnGhost[player] = nil
    end
end

function MGR.SetSpawnOrigin(data, player)
    SpawnOriginData[player] = data
end

function MGR.ClearSpawnOrigin(player)
    SpawnOriginData[player] = nil
end

function MGR.SetPosOffset(pos, player)
    OffsetPos[player] = pos
    MGR.RefreshSpawnPreview(player, SpawnOffsetOn[player])
end

function MGR.SetAngleOffset(ang, player)
    OffsetAng[player] = ang
    MGR.RefreshSpawnPreview(player, SpawnOffsetOn[player])
end

SMH.GhostsManager = MGR

hook.Add("Think", "SMHGhostSpawnOffsetPreview", function()
    for player, data in pairs(SpawnOriginData) do
        if SpawnOffsetOn[player] and IsValid(SpawnGhost[player]) then
            for name, mod in pairs(SMH.Modifiers) do
                if name == "color" then continue end
                if SpawnGhostData[player][name] and data[name] and (name == "physbones" or name == "position") then
                    local offsetpos = OffsetPos[player] or Vector(0, 0, 0)
                    local offsetang = OffsetAng[player] or Angle(0, 0, 0)

                    offsetdata = mod:Offset(SpawnGhostData[player][name].Modifiers, data[name].Modifiers, offsetpos, offsetang, player:GetEyeTraceNoCursor().HitPos)
                    mod:Load(SpawnGhost[player], offsetdata, GhostSettings[player])
                end
            end
        end
    end
end)
