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

local function Record(keyframe, entity)
    -- TODO
end

local MGR = {}

function MGR:GetAll(player)
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

function MGR:GetAllForEntity(player, entity)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Entities[entity] then
        return {}
    end
    return table.Copy(SMH.KeyframeData.Players[player].Entities[entity])
end

function MGR:Create(player, entity, frame)
    local keyframe = GetExistingKeyframe(player, entity, frame)

    if keyframe ~= nil then
        Record(keyframe, entity)
        return keyframe
    end

    keyframe = SMH.KeyframeData:New(player, entity)
    keyframe.Frame = frame
    Record(keyframe, entity)
    return keyframe
end

function MGR:Update(player, frameId, updateData)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[frameId] then
        error("Invalid keyframe ID")
    end

    local keyframe = SMH.KeyframeData.Players[player].Keyframes[frameId]
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

function MGR:Delete(player, frameId)
    if not SMH.KeyframeData.Players[player] or not SMH.KeyframeData.Players[player].Keyframes[frameId] then
        error("Invalid keyframe ID")
    end
    
    SMH.KeyframeData:Delete(player, frameId)
end

SMH.KeyframeManager = MGR
