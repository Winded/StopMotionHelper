local ActivePlaybacks = {}

local MGR = {}

local function PlaybackSmooth(player, playback, settings)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    playback.Timer = playback.Timer + FrameTime()
    local timePerFrame = 1 / playback.PlaybackRate

    playback.CurrentFrame = playback.Timer / timePerFrame + playback.StartFrame
    if playback.CurrentFrame > playback.EndFrame then
        playback.CurrentFrame = 0
        playback.StartFrame = 0
        playback.Timer = 0
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if entity ~= player then
            for name, mod in pairs(SMH.Modifiers) do
                local prevKeyframe, nextKeyframe, _ = SMH.GetClosestKeyframes(keyframes, playback.CurrentFrame, false, name)

                if not prevKeyframe then continue end

                if prevKeyframe.Frame == nextKeyframe.Frame then
                    if prevKeyframe.Modifiers[name] and nextKeyframe.Modifiers[name] then
                        mod:Load(entity, prevKeyframe.Modifiers[name], settings);
                    end
                else
                    local lerpMultiplier = ((playback.Timer + playback.StartFrame * timePerFrame) - prevKeyframe.Frame * timePerFrame) / ((nextKeyframe.Frame - prevKeyframe.Frame) * timePerFrame)
                    lerpMultiplier = math.EaseInOut(lerpMultiplier, prevKeyframe.EaseOut[name], nextKeyframe.EaseIn[name])

                    if prevKeyframe.Modifiers[name] and nextKeyframe.Modifiers[name] then
                        mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings);
                    end
                end
            end
        else
            if settings.EnableWorld then
                SMH.WorldKeyframesManager.Load(player, math.Round(playback.CurrentFrame), keyframes)
            end
        end
    end
end

function MGR.SetFrame(player, newFrame, settings)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if entity ~= player then
            for name, mod in pairs(SMH.Modifiers) do
                local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame, false, name)
                if not prevKeyframe then
                    continue
                end

                if lerpMultiplier <= 0 or settings.TweenDisable then
                    mod:Load(entity, prevKeyframe.Modifiers[name], settings);
                elseif lerpMultiplier >= 1 then
                    mod:Load(entity, nextKeyframe.Modifiers[name], settings);
                else
                    mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings);
                end
            end
        else
            if settings.EnableWorld then
                SMH.WorldKeyframesManager.Load(player, newFrame, keyframes)
            end
        end
    end
end

function MGR.SetFrameIgnore(player, newFrame, settings, ignored)
    if not SMH.KeyframeData.Players[player] then
        return
    end

    for entity, keyframes in pairs(SMH.KeyframeData.Players[player].Entities) do
        if ignored[entity] then continue end
        for name, mod in pairs(SMH.Modifiers) do
            local prevKeyframe, nextKeyframe, lerpMultiplier = SMH.GetClosestKeyframes(keyframes, newFrame, false, name)
            if not prevKeyframe then
                continue
            end

            if lerpMultiplier <= 0 or settings.TweenDisable then
                mod:Load(entity, prevKeyframe.Modifiers[name], settings);
            elseif lerpMultiplier >= 1 then
                mod:Load(entity, nextKeyframe.Modifiers[name], settings);
            else
                mod:LoadBetween(entity, prevKeyframe.Modifiers[name], nextKeyframe.Modifiers[name], lerpMultiplier, settings);
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
        PrevFrame = startFrame - 1,
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
        if not playback.Settings.SmoothPlayback or playback.Settings.TweenDisable then

            playback.Timer = playback.Timer + FrameTime()
            local timePerFrame = 1 / playback.PlaybackRate

            if playback.Timer >= timePerFrame then

                playback.CurrentFrame = math.floor(playback.Timer / timePerFrame) + playback.StartFrame
                if playback.CurrentFrame > playback.EndFrame then
                    playback.CurrentFrame = 0
                    playback.StartFrame = 0
                    playback.Timer = 0
                end

                if playback.CurrentFrame ~= playback.PrevFrame then
                    playback.PrevFrame = playback.CurrentFrame
                    MGR.SetFrame(player, playback.CurrentFrame, playback.Settings)
                end

            end
        else
            PlaybackSmooth(player, playback, playback.Settings)
        end
    end
end)

SMH.PlaybackManager = MGR
