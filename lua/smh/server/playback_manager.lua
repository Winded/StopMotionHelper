local ActivePlaybacks = {}

local MGR = {}

function MGR.SetFrame(player, newFrame, settings)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame)
        if not prevKeyframe then
            continue
        end

        if lerpMultiplier <= 0 or settings.TweenDisable then
            for name, mod in pairs(SMH.Modifiers) do
                if prevKeyframe.Modifiers[name] then
                    mod:Load(entity, prevKeyframe.Modifiers[name], settings);
                end
            end
        elseif lerpMultiplier >= 1 then
            for name, mod in pairs(SMH.Modifiers) do
                if nextKeyframe.Modifiers[name] then
                    mod:Load(entity, nextKeyframe.Modifiers[name], settings);
                end
            end
        else
            for name, mod in pairs(SMH.Modifiers) do
                if prevKeyframe.Modifiers[name] and nextKeyframe.Modifiers[name] then
                    mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings);
                end
            end
        end
    end
end

function MGR.StartPlayback(player, startFrame, endFrame, playbackRate, settings)
    ActivePlaybacks[player] = {
        StartFrame = startFrame,
        EndFrame = endFrame,
        PlaybackRate = playbackRate,
        CurrentFrame = startFrame,
        Timer = 0,
        Settings = settings,
    }
    MGR.SetFrame(player, startFrame, settings)
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
            MGR.SetFrame(player, playback.CurrentFrame, playback.Settings)
        end
    end
end)

SMH.PlaybackManager = MGR
