local function GetExistingKeyframe(player, entity, frame)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
        return nil
    end

    local keyframes = SMH.KeyframeData.Players[player].Entities[entity]
    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame == frame then
            return keyframe
        end
    end

    return nil
end

local function Record(keyframe, player, entity)
	for name, mod in pairs(SMH.Modifiers) do
		keyframe.Modifiers[name] = mod:Save(entity)
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

function MGR.Create(player, entity, frame)
    local keyframe = GetExistingKeyframe(player, entity, frame)

    if keyframe ~= nil then
        Record(keyframe, player, entity)
        return keyframe
    end

    keyframe = SMH.KeyframeData:New(player, entity)
    keyframe.Frame = frame
    Record(keyframe, player, entity)
    return keyframe
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

    return copiedKeyframe
end

function MGR.Delete(player, keyframeId)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[keyframeId] then
        error("Invalid keyframe ID")
    end
    
    SMH.KeyframeData:Delete(player, keyframeId)
end

function MGR.ImportSave(player, entity, serializedKeyframes, entityProperties)
    if SMH.KeyframeData.Players[player] and SMH.KeyframeData.Players[player].Entities[entity] then
		local deletethis = table.Copy(SMH.KeyframeData.Players[player].Entities[entity])
        for _, keyframe in pairs(deletethis) do
            SMH.KeyframeData:Delete(player, keyframe.ID)
        end
    end
    
	SMH.PropertiesManager.SetName(player, entity, entityProperties.Name)
	
    for _, skf in pairs(serializedKeyframes) do
        local keyframe = SMH.KeyframeData:New(player, entity)
        keyframe.Frame = skf.Position
        keyframe.EaseIn = skf.EaseIn
        keyframe.EaseOut = skf.EaseOut
        keyframe.Modifiers = skf.EntityData
    end
end

SMH.KeyframeManager = MGR
