local Active = {}

local function GetPosData(serializedKeyframes, model)
    for i, sEntity in pairs(serializedKeyframes.Entities) do
        local listname
        if not sEntity.Properties then -- in case if we load an old save without properties entities
            return
        else
            listname = sEntity.Properties.Name
        end

        if listname == model then
            if not sEntity.Properties.Class then return end
            local class, modelpath = sEntity.Properties.Class, sEntity.Properties.Model
            local data = {}

            for _, kframe in pairs(serializedKeyframes.Entities[i].Frames) do
                for name, mod in pairs(kframe.EntityData) do
                    if not data[name] or data[name].Frame > kframe.Position then
                        data[name] = {Modifiers = kframe.EntityData[name], Frame = kframe.Position}
                    end
                end
            end

            return class, modelpath, data
        end
    end
end

local MGR = {}

MGR.OffsetPos, MGR.OffsetAng, MGR.OffsetMode = {}, {}, {}

MGR.OriginData = {}

function MGR.SetPreviewEntity(path, model, settings, player)
    if not Active[player] then return end
    local serializedKeyframes = SMH.Saves.Load(path)
    local class, modelpath, data = GetPosData(serializedKeyframes, model)
    if not class then
        player:ChatPrint("Stop Motion Helper: Failed to get entity info. Probably you're trying to use save from older SMH version!")
        return
    end

    SMH.GhostsManager.SetSpawnPreview(class, modelpath, data, settings, player)

    if not MGR.OffsetMode[player] then return end
    if not MGR.OriginData[player] then
        MGR.SetOrigin(path, model, player)
    end
end

function MGR.SetGhost(state, player)
    Active[player] = state
    if not state then
        SMH.GhostsManager.SpawnClear(player)
    end
end

function MGR.Spawn(path, model, settings, player)
    if not Active[player] then return end
    local serializedKeyframes = SMH.Saves.Load(path)
    local class, modelpath, data = GetPosData(serializedKeyframes, model)
    if not class then
        player:ChatPrint("Stop Motion Helper: Failed to get entity info. Probably you're trying to use save from older SMH version!")
        return
    end

    if IsValid(player) and not player:CheckLimit("smhentity") then return end

    if class == "prop_ragdoll" and not data["physbones"] then
        player:ChatPrint("Stop Motion Helper: Can't spawn the ragdoll as the save doesn't have Physical Bones modifier!")
        return
    end
    if not data["physbones"] and not data["position"] then
        player:ChatPrint("Stop Motion Helper: Can't spawn the entity as the save doesn't have Physical Bones or Position and Rotation modifiers!")
        return
    end

    local entity = ents.Create(class)

    entity:SetModel(modelpath)
    entity:Spawn()

    player:AddCount("smhentity", entity)
    player:AddCleanup("smhentity", entity)

    undo.Create("SMH Spawned entity")
        undo.AddEntity(entity)
        undo.SetPlayer(player)
    undo.Finish()

    if not MGR.OffsetMode[player] then
        for name, mod in pairs(SMH.Modifiers) do
            if not data[name] then continue end
            mod:Load(entity, data[name].Modifiers, settings)
        end
    else
        for name, mod in pairs(SMH.Modifiers) do
            if not data[name] then continue end
            if data[name] and MGR.OriginData[player][name] and (name == "physbones" or name == "position") then
                local offsetpos = MGR.OffsetPos[player] or Vector(0, 0, 0)
                local offsetang = MGR.OffsetAng[player] or Angle(0, 0, 0)

                offsetdata = mod:Offset(data[name].Modifiers, MGR.OriginData[player][name].Modifiers, offsetpos, offsetang, player:GetEyeTraceNoCursor().HitPos)
                mod:Load(entity, offsetdata, settings)
            else
                mod:Load(entity, data[name].Modifiers, settings)
            end
        end
    end

    return entity, MGR.OffsetMode[player]
end

function MGR.OffsetKeyframes(player, entity)
    for id, keyframe in pairs(SMH.KeyframeData.Players[player].Entities[entity]) do
        if keyframe.Modifier ~= "physbones" and keyframe.Modifier ~= "position" then continue end
        local name = keyframe.Modifier
        local offsetpos = MGR.OffsetPos[player] or Vector(0, 0, 0)
        local offsetang = MGR.OffsetAng[player] or Angle(0, 0, 0)

        for modname, mod in pairs(SMH.Modifiers) do
            if modname == name then
                keyframe.Modifiers[name] = mod:Offset(keyframe.Modifiers[name], MGR.OriginData[player][name].Modifiers, offsetpos, offsetang, player:GetEyeTraceNoCursor().HitPos)
                break
            end
        end
    end
end

function MGR.SetOrigin(path, model, player)
    if not Active[player] then return end
    local serializedKeyframes = SMH.Saves.Load(path)
    local class, modelpath, data = GetPosData(serializedKeyframes, model)
    if not class then
        player:ChatPrint("Stop Motion Helper: Failed to get entity info. Probably you're trying to use save from older SMH version!")
        return
    end

    MGR.OriginData[player] = data
end

function MGR.SpawnReset(player)
    MGR.OriginData[player] = nil
end

function MGR.SetOffsetMode(set, player)
    MGR.OffsetMode[player] = set
    SMH.GhostsManager.RefreshSpawnPreview(player)
end

function MGR.SetPosOffset(Pos, player)
    MGR.OffsetPos[player] = Pos
end

function MGR.SetAngleOffset(Ang, player)
    MGR.OffsetAng[player] = Ang
end

SMH.Spawner = MGR
