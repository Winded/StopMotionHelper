local function GetExistingKeyframe(player, entity, frame, modname)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
        return nil
    end

    local keyframes = SMH.KeyframeData.Players[player].Entities[entity]
    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame == frame and keyframe.Modifier == modname then
            return keyframe
        end
    end

    return nil
end

local function Record(keyframe, player, entity, modname)
    for name, mod in pairs(SMH.Modifiers) do
        if modname == name then
            keyframe.Modifiers[name] = mod:Save(entity)
            keyframe.Modifier = name
            break
        end
    end
end

hook.Add("EntityRemoved", "SMHKeyframesEntityRemoved", function(entity)

    for _, player in pairs(player.GetAll()) do
        if SMH.KeyframeData.Players[player] and SMH.KeyframeData.Players[player].Entities[entity] then
            local keyframesToDelete = {}
            for _, keyframe in pairs(SMH.KeyframeData.Players[player].Entities[entity]) do
                table.insert(keyframesToDelete, keyframe.ID)
            end
            for _, keyframeId in pairs(keyframesToDelete) do
                SMH.KeyframeData:Delete(player, keyframeId)
            end
        end
    end

end)

local MGR = {}

function MGR.GetAll(player)
    if not SMH.KeyframeData.Players[player] then
        return {}
    end
    local keyframes = SMH.KeyframeData.Players[player].Keyframes

    local result = {}
    for _, keyframe in pairs(keyframes) do
        table.insert(result, table.Copy(keyframe))
    end
    return result
end

function MGR.GetAllForEntity(player, entity)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
        return {}
    end
    return table.Copy(SMH.KeyframeData.Players[player].Entities[entity])
end

function MGR.Create(player, entity, frame, timeline)
    local keyframes = {}

    if player ~= entity then
        for _, name in ipairs(SMH.Properties.Players[player].Entities[entity].TimelineMods[timeline]) do
            local keyframe = GetExistingKeyframe(player, entity, frame, name)

            if keyframe ~= nil then
                Record(keyframe, player, entity, name)
                table.insert(keyframes, keyframe)
                continue
            end

            keyframe = SMH.KeyframeData:New(player, entity)
            keyframe.Frame = frame
            Record(keyframe, player, entity, name)
            table.insert(keyframes, keyframe)
        end
    else
        local keyframe = GetExistingKeyframe(player, entity, frame, "world")

        if keyframe ~= nil then return {keyframe} end

        keyframe = SMH.KeyframeData:New(player, entity)
        keyframe.Frame = frame
        keyframe.Modifiers["world"] = {
            Console = "",
            Push = "",
            Release = "",
        }
        keyframe.Modifier = "world"
        table.insert(keyframes, keyframe)
    end

    return keyframes
end

function MGR.Update(player, keyframeId, updateData)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
        error("Invalid keyframe ID")
    end

    local keyframe = SMH.KeyframeData.Players[player].Keyframes[keyframeId]
    local updateableFields = {
        "Frame",
        "EaseIn",
        "EaseOut",
    }
    for _, field in pairs(updateableFields) do
        if updateData[field] then
            keyframe[field] = updateData[field]
        end
    end

    return keyframe
end

function MGR.Copy(player, keyframeId, frame)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
        error("Invalid keyframe ID")
    end

    local keyframe = SMH.KeyframeData.Players[player].Keyframes[keyframeId]

    local copiedKeyframe = SMH.KeyframeData:New(player, keyframe.Entity)
    copiedKeyframe.Frame = frame
    copiedKeyframe.EaseIn = keyframe.EaseIn
    copiedKeyframe.EaseOut = keyframe.EaseOut
    copiedKeyframe.Modifiers = table.Copy(keyframe.Modifiers)
    copiedKeyframe.Modifier = keyframe.Modifier

    return copiedKeyframe
end

function MGR.Delete(player, keyframeId)
    local entity = SMH.KeyframeData.Players[player].Keyframes[keyframeId].Entity
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
        error("Invalid keyframe ID")
    end

    SMH.KeyframeData:Delete(player, keyframeId)
    return entity
end

function MGR.ImportSave(player, entity, serializedKeyframes, entityProperties)
    if SMH.KeyframeData.Players[player] and SMH.KeyframeData.Players[player].Entities[entity] then
        local deletethis = table.Copy(SMH.KeyframeData.Players[player].Entities[entity])
        for _, keyframe in pairs(deletethis) do
            SMH.KeyframeData:Delete(player, keyframe.ID)
        end
    end

    SMH.PropertiesManager.SetProperties(player, entity, entityProperties)

    if SMH.Properties.Players[player].Entities[entity].Old then -- should make it compatible with older saves
        SMH.Properties.Players[player].Entities[entity].Old = nil
        for _, skf in pairs(serializedKeyframes) do
            for name, mod in pairs(SMH.Modifiers) do
                if skf.EntityData[name] ~= nil then
                    local keyframe = SMH.KeyframeData:New(player, entity)
                    keyframe.Frame = skf.Position
                    keyframe.EaseIn = skf.EaseIn
                    keyframe.EaseOut = skf.EaseOut
                    keyframe.Modifiers[name] = skf.EntityData[name]
                    keyframe.Modifier = name
                end
            end
        end
    else
        for _, skf in pairs(serializedKeyframes) do
            local keyframe = SMH.KeyframeData:New(player, entity)
            keyframe.Frame = skf.Position
            keyframe.EaseIn = skf.EaseIn
            keyframe.EaseOut = skf.EaseOut
            keyframe.Modifiers = skf.EntityData
            keyframe.Modifier = skf.Modifier
        end
    end
end

function MGR.GetWorldData(player, frame)
    local keyframe = GetExistingKeyframe(player, player, frame, "world")
    local modifiers = keyframe.Modifiers["world"]

    return modifiers.Console, modifiers.Push, modifiers.Release
end

function MGR.UpdateWorldKeyframe(player, frame, str, key)
    local keyframe = GetExistingKeyframe(player, player, frame, "world")
    if not keyframe then return end
    keyframe.Modifiers["world"][key] = str
end

SMH.KeyframeManager = MGR
