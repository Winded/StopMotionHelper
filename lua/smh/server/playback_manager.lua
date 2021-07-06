local ActivePlaybacks = {}

local function GetClosestKeyframes(player, entity, keyframes, frame)
    local prevKeyframe = nil
    local nextKeyframe = nil
    for _, keyframe in pairs(keyframes) do
        if keyframe.Frame == frame then
            prevKeyframe = keyframe
            nextKeyframe = keyframe
            break
        end

        if keyframe.Frame < frame and (not prevKeyframe or prevKeyframe.Frame < keyframe.Frame) then
            prevKeyframe = keyframe
        elseif keyframe.Frame > frame and (not nextKeyframe or nextKeyframe.Frame > keyframe.Frame) then
            nextKeyframe = keyframe
        end
    end

    if not prevKeyframe and not nextKeyframe then
        return nil, nil, 0
    elseif not prevKeyframe then
        prevKeyframe = nextKeyframe
    elseif not nextKeyframe then
        nextKeyframe = prevKeyframe
    end

    local lerpMultiplier = 0
    if prevKeyframe.Frame ~= nextKeyframe.Frame then
        lerpMultiplier = (frame - prevKeyframe.Frame) / (nextKeyframe.Frame - prevKeyframe.Frame)
        lerpMultiplier = math.EaseInOut(lerpMultiplier, prevKeyframe.EaseOut, nextKeyframe.EaseIn);
    end

    return prevKeyframe, nextKeyframe, lerpMultiplier
end

local MGR = {}

function MGR.SetFrame(player, newFrame, tween)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        local prevKeyframe, nextKeyframe, lerpMultiplier = GetClosestKeyframes(player, entity, keyframes, newFrame)
        if not prevKeyframe then
            continue
        end

        if lerpMultiplier <= 0 or not tween then
            for name, mod in pairs(SMH.Modifiers) do
                if prevKeyframe.Modifiers[name] then
                    mod:Load(player, entity, prevKeyframe.Modifiers[name]);
                end
            end
        elseif lerpMultiplier >= 1 then
            for name, mod in pairs(SMH.Modifiers) do
                if nextKeyframe.Modifiers[name] then
                    mod:Load(player, entity, nextKeyframe.Modifiers[name]);
                end
            end
        else
            for name, mod in pairs(SMH.Modifiers) do
                if prevKeyframe.Modifiers[name] and nextKeyframe.Modifiers[name] then
                    mod:LoadBetween(player, entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier);
                end
            end
        end
    end
end

function MGR.StartPlayback(player, startFrame, endFrame, playbackRate)
    ActivePlaybacks[player] = {
        StartFrame = startFrame,
        EndFrame = endFrame,
        PlaybackRate = playbackRate,
        CurrentFrame = startFrame,
        Timer = 0,
    }
    MGR.SetFrame(player, startFrame)
end

function MGR.StopPlayback(player)
    ActivePlaybacks[player] = nil
end

hook.Add("Think", "SMHPlaybackManagerThink", function()
    for player, playback in pairs(ActivePlaybacks) do
        playback.Timer = playback.Timer + FrameTime()
        local timePerFrame = 1 / playback.PlaybackRate
        if playback.Timer >= timePerFrame then
            playback.CurrentFrame = playback.CurrentFrame + 1
            if playback.CurrentFrame > playback.EndFrame then
                playback.CurrentFrame = playback.StartFrame
            end
            playback.Timer = 0
            MGR.SetFrame(player, playback.CurrentFrame)
        end
    end
end)

SMH.PlaybackManager = MGR
