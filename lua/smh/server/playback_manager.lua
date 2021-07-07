local ActivePlaybacks = {}

local MGR = {}

function MGR.SetFrame(player, newFrame, tween)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame)
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
