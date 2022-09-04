local INT_BITCOUNT = 32
local KFRAMES_PER_MSG = 250

local function SendKeyframes(framecount, IDs, ents, Frame, In, Out, ModCount, Modifiers, loop)
    if not loop then loop = 0 end

    local sendframes = framecount > KFRAMES_PER_MSG and KFRAMES_PER_MSG or framecount

    net.WriteUInt(sendframes, INT_BITCOUNT)
    for i = 1 + KFRAMES_PER_MSG * loop, sendframes + KFRAMES_PER_MSG * loop do
        net.WriteUInt(IDs[i],INT_BITCOUNT)
        net.WriteEntity(ents[i])
        net.WriteUInt(Frame[i], INT_BITCOUNT)
        net.WriteUInt(ModCount[i], INT_BITCOUNT)
        for j = 1, ModCount[i] do
            net.WriteString(Modifiers[i][j])
            net.WriteFloat(In[i][j])
            net.WriteFloat(Out[i][j])
        end
    end
    return framecount - KFRAMES_PER_MSG
end

local function SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.WriteUInt(Timelines, INT_BITCOUNT)
    for i=1, Timelines do
        net.WriteColor(KeyColor[i])
        net.WriteUInt(ModCount[i], INT_BITCOUNT)
        for j=1, ModCount[i] do
            net.WriteString(Modifiers[i][j])
        end
    end
end

local function ReceiveProperties()
    local Timelines = SMH.TableSplit.StartAProperties(net.ReadUInt(INT_BITCOUNT))
    for i=1, Timelines do
        SMH.TableSplit.AProperties(i, nil, net.ReadColor())
        for j=1, net.ReadUInt(INT_BITCOUNT) do
            SMH.TableSplit.AProperties(i, net.ReadString())
        end
    end
    return SMH.TableSplit.GetProperties()
end

local function SendLeftoverKeyframes(player, framecount, IDs, entities, Frame, In, Out, ModCount, Modifiers)
    if framecount < 0 then return end

    for i = 1, math.ceil(framecount / KFRAMES_PER_MSG) do
        if framecount < 0 then break end
        net.Start(SMH.MessageTypes.GetAllKeyframes)
            framecount = SendKeyframes(framecount, IDs, entities, Frame, In, Out, ModCount, Modifiers, i)
        net.Send(player)
    end
end

local function SetFrame(msgLength, player)
    local newFrame = net.ReadUInt(INT_BITCOUNT)
    local settings = net.ReadTable()
    local timeline = net.ReadUInt(INT_BITCOUNT)

    SMH.PlaybackManager.SetFrame(player, newFrame, settings)
    SMH.GhostsManager.UpdateState(player, newFrame, settings, timeline)

    net.Start(SMH.MessageTypes.SetFrameResponse)
    net.WriteUInt(newFrame, INT_BITCOUNT)
    net.Send(player)
end

local function SelectEntity(msgLength, player)
    local entity = net.ReadEntity()
    local entities = {}

    if entity.SMHGhost then
        entity = entity.Entity
    end

    for i = 1, net.ReadUInt(INT_BITCOUNT) do
        entities[i] = net.ReadEntity()
    end

    if player ~= entity then
        SMH.GhostsManager.SelectEntity(player, entities)
    else
        SMH.GhostsManager.SelectEntity(player, {})
    end

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entities)
    local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.SelectEntityResponse)
    framecount = SendKeyframes(framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers)
    net.WriteUInt(#entities, INT_BITCOUNT)
    for _, entity in ipairs(entities) do
        net.WriteEntity(entity)
    end
    net.Send(player)

    SendLeftoverKeyframes(player, framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers)
end

local function CreateKeyframe(msgLength, player)
    local entities = {}
    for i = 1, net.ReadUInt(INT_BITCOUNT) do
        entities[i] = net.ReadEntity()
    end

    local frame = net.ReadUInt(INT_BITCOUNT)
    local timeline = net.ReadUInt(INT_BITCOUNT)

    SMH.PropertiesManager.AddEntity(player, entities)
    local totaltimelines = SMH.PropertiesManager.GetTimelines(player)
    if timeline > totaltimelines then timeline = 1 end

    local keyframes = SMH.KeyframeManager.Create(player, entities, frame, timeline)
    if not next(keyframes) then return end
    local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    SendKeyframes(framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers)
    net.Send(player)
end

local bufferData = {}

local function UpdateKeyframe(msgLength, player)
    bufferData[player] = {Ids = {}, UpdateData = {}, Timeline = 1}

    local count = net.ReadUInt(INT_BITCOUNT)

    for i = 1, count do
        table.insert(bufferData[player].Ids, net.ReadUInt(INT_BITCOUNT))
        local data = net.ReadString()

        if data == "Frame" then
            local temptable = {}
            temptable[data] = net.ReadUInt(INT_BITCOUNT)
            table.insert(bufferData[player].UpdateData, temptable)
        else
            local temptable = {}
            temptable[data] = net.ReadFloat()
            table.insert(bufferData[player].UpdateData, temptable)
        end
    end

    bufferData[player].Timeline = net.ReadUInt(INT_BITCOUNT)
end

local function UpdateKeyframeExecute(msgLength, player)
    local keyframes = SMH.KeyframeManager.Update(player, bufferData[player].Ids, bufferData[player].UpdateData, bufferData[player].Timeline)

    for key, keyframe in ipairs(keyframes) do
        local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes({keyframe})

        net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
        SendKeyframes(framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers)
        net.Send(player)
    end

    bufferData[player] = {}
end

local function CopyKeyframe(msgLength, player)
    bufferData[player] = {Ids = {}, Frames = {}, Timeline = 1}

    local count = net.ReadUInt(INT_BITCOUNT)

    for i = 1, count do
        table.insert(bufferData[player].Ids, net.ReadUInt(INT_BITCOUNT))
        table.insert(bufferData[player].Frames, net.ReadUInt(INT_BITCOUNT))
    end

    bufferData[player].Timeline = net.ReadUInt(INT_BITCOUNT)
end

local function CopyKeyframeExecute(msgLength, player)
    local keyframes = SMH.KeyframeManager.Copy(player, bufferData[player].Ids, bufferData[player].Frames, bufferData[player].Timeline)
    
    for key, keyframe in ipairs(keyframes) do
        local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes({keyframe})

        net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
        SendKeyframes(framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers)
        net.Send(player)
    end

    bufferData[player] = {}
end

local function DeleteKeyframe(msgLength, player)
    local count, timeline = net.ReadUInt(INT_BITCOUNT), net.ReadUInt(INT_BITCOUNT)

    for i = 1, count do 
        local id = net.ReadUInt(INT_BITCOUNT)
        local entity = SMH.KeyframeManager.Delete(player, id, timeline)

        SMH.PropertiesManager.RemoveEntity(player)

        net.Start(SMH.MessageTypes.DeleteKeyframeResponse)
        net.WriteUInt(id, INT_BITCOUNT)
        net.Send(player)
    end
end

local function StartPlayback(msgLength, player)
    local startFrame = net.ReadUInt(INT_BITCOUNT)
    local endFrame = net.ReadUInt(INT_BITCOUNT)
    local playbackRate = net.ReadUInt(INT_BITCOUNT)
    local settings = net.ReadTable()

    SMH.PlaybackManager.StartPlayback(player, startFrame, endFrame, playbackRate, settings)

    net.Start(SMH.MessageTypes.PlaybackResponse)
    net.WriteBool(true)
    net.Send(player)
end

local function StopPlayback(msgLength, player)
    SMH.PlaybackManager.StopPlayback(player)

    net.Start(SMH.MessageTypes.PlaybackResponse)
    net.WriteBool(false)
    net.Send(player)
end

local function UpdateGhostState(msgLength, player)
    local settings = net.ReadTable()

    SMH.GhostsManager.UpdateSettings(player, settings)

    net.Start(SMH.MessageTypes.UpdateGhostStateResponse)
    net.Send(player)
end

local function GetServerSaves(msgLength, player)
    local saves, keys, count = SMH.TableSplit.DTable(SMH.Saves.ListFiles())
    net.Start(SMH.MessageTypes.GetServerSavesResponse)
    net.WriteUInt(count, INT_BITCOUNT)
    for i = 1, count do
        net.WriteString(keys[i])
        net.WriteString(saves[i])
    end
    net.Send(player)
end

local function GetModelList(msgLength, player)
    local path = net.ReadString()

    local modelslist, map = SMH.Saves.ListModels(path)
    local models, keys, count = SMH.TableSplit.DTable(modelslist)
    net.Start(SMH.MessageTypes.GetModelListResponse)
    net.WriteUInt(count, INT_BITCOUNT)
    for i = 1, count do
        net.WriteString(keys[i])
        net.WriteString(models[i])
    end
    net.WriteString(map)
    net.Send(player)
end

local function GetServerEntities(msgLength, player)
    local entities, keys, count = SMH.TableSplit.DTable(SMH.PropertiesManager.GetAllEntitiesNames(player))

    net.Start(SMH.MessageTypes.GetServerEntitiesResponse)
    net.WriteUInt(count, INT_BITCOUNT)
    for i = 1, count do
        net.WriteEntity(keys[i])
        net.WriteString(entities[i].Name)
    end
    net.Send(player)
end

local function Load(msgLength, player)
    local entity = net.ReadEntity()
    local loadFromClient = net.ReadBool()

    local serializedKeyframes, entityProperties, isWorld
    if loadFromClient then
        serializedKeyframes = net.ReadTable()
    else
        local path = net.ReadString()
        local modelName = net.ReadString()
        serializedKeyframes, entityProperties, isWorld = SMH.Saves.LoadForEntity(path, modelName)
    end

    if isWorld then entity = player end

    SMH.PropertiesManager.AddEntity(player, {entity})
    SMH.KeyframeManager.ImportSave(player, entity, serializedKeyframes, entityProperties)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, {entity})
    local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.LoadResponse)
    framecount = SendKeyframes(framecount, IDs, entity, Frame, In, Out, KModCount, KModifiers)
    net.WriteEntity(entity)
    net.Send(player)

    SendLeftoverKeyframes(player, framecount, IDs, entity, Frame, In, Out, KModCount, KModifiers)
end

local function GetModelInfo(msgLength, player)
    local path = net.ReadString()
    local modelName = net.ReadString()

    modelName = SMH.Saves.GetModelName(path, modelName)

    net.Start(SMH.MessageTypes.GetModelInfoResponse)
    net.WriteString(modelName)
    net.Send(player)
end

local function Save(msgLength, player)
    local saveToClient = net.ReadBool()
    local path = net.ReadString()

    local properties = SMH.PropertiesManager.GetAllProperties(player)
    local keyframes = SMH.KeyframeManager.GetAll(player)
    local serializedKeyframes = SMH.Saves.Serialize(keyframes, properties, player)

    if not saveToClient then
        SMH.Saves.Save(path, serializedKeyframes)
    end

    net.Start(SMH.MessageTypes.SaveResponse)
    net.WriteBool(saveToClient)
    net.WriteString(path)
    if saveToClient then
        net.WriteTable(serializedKeyframes)
    end
    net.Send(player)
end

local function DeleteSave(msgLength, player)
    local path = net.ReadString()
    SMH.Saves.Delete(path)

    net.Start(SMH.MessageTypes.DeleteSaveResponse)
    net.WriteString(path)
    net.Send(player)
end

local function SetRendering(msgLength, player)
    local rendering = net.ReadBool()
    SMH.GhostsManager.IsRendering = rendering
end

local function ApplyEntityName(msgLength, player)
    local ent = net.ReadEntity()
    local name = net.ReadString()
    if not IsValid(ent) or not name then return end
    name = SMH.PropertiesManager.SetName(player, ent, name)

    net.Start(SMH.MessageTypes.ApplyEntityNameResponse)
    net.WriteString(name)
    net.Send(player)
end

local function UpdateTimeline(msgLength, player)
    local entities = {}
    for i = 1, net.ReadUInt(INT_BITCOUNT) do
        entities[i] = net.ReadEntity()
    end

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entities)
    local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateTimelineResponse)
    framecount = SendKeyframes(framecount, IDs, entities, Frame, In, Out, KModCount, KModifiers)
    net.Send(player)

    SendLeftoverKeyframes(player, framecount, IDs, entities, Frame, In, Out, KModCount, KModifiers)
end

local function RequestModifiers(msgLength, player)
    local list = {}

    for name, mod in pairs(SMH.Modifiers) do
        list[name] = mod.Name
    end

    net.Start(SMH.MessageTypes.RequestModifiersResponse)
    net.WriteTable(list)
    net.Send(player)
end

local function SetTimeline(msgLength, player)
    local isdefault = net.ReadBool()
    local timeline

    if isdefault then
        timeline = {}
    else
        timeline = ReceiveProperties()
    end

    SMH.PropertiesManager.InitTimelineSetting(player, timeline)

    local timelineinfo = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timelineinfo)

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function RequestTimelineInfo(msgLength, player)
    local name = net.ReadString()
    if name == "" or name == "default" then return end -- just in case

    local timelineinfo = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timelineinfo)

    net.Start(SMH.MessageTypes.RequestTimelineInfoResponse)
    net.WriteString(name)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function AddTimeline(msgLength, player)
    SMH.PropertiesManager.SetTimelines(player, true)

    local timeline = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function RemoveTimeline(msgLength, player)
    SMH.PropertiesManager.SetTimelines(player, false)

    local timeline = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function UpdateModifier(msgLength, player)
    local itimeline = net.ReadUInt(INT_BITCOUNT)
    local name = net.ReadString()
    local state = net.ReadBool()

    local changed = SMH.PropertiesManager.UpdateModifier(player, itimeline, name, state)
    local timeline = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    net.Start(SMH.MessageTypes.UpdateModifierResponse)
    net.WriteString(changed)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function UpdateKeyframeColor(msgLength, player)
    local timeline = net.ReadUInt(INT_BITCOUNT)
    local color = net.ReadColor()

    SMH.PropertiesManager.UpdateKeyframeColor(player, color, timeline)
    local timelineinfo = SMH.PropertiesManager.GetTimelinesInfo(player)
    local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timelineinfo)

    net.Start(SMH.MessageTypes.UpdateKeyframeColorResponse)
    SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function SetPreviewEntity(msgLength, player)
    local path = net.ReadString()
    local model = net.ReadString()
    local settings = net.ReadTable()
    settings.FreezeAll = true

    SMH.Spawner.SetPreviewEntity(path, model, settings, player)
end

local function SetSpawnGhost(msgLength, player)
    local state = net.ReadBool()
    SMH.Spawner.SetGhost(state, player)
end

local function SpawnEntity(msgLength, player)
    local path = net.ReadString()
    local modelName = net.ReadString()
    local settings = net.ReadTable()
    settings.FreezeAll = true

    local entity, offset = SMH.Spawner.Spawn(path, modelName, settings, player)
    if not entity then return end
    local serializedKeyframes, entityProperties

    serializedKeyframes, entityProperties = SMH.Saves.LoadForEntity(path, modelName)

    SMH.PropertiesManager.AddEntity(player, {entity})
    SMH.KeyframeManager.ImportSave(player, entity, serializedKeyframes, entityProperties)

    if offset then
        SMH.Spawner.OffsetKeyframes(player, entity)
    end

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, {entity})
    local framecount, IDs, ents, Frame, In, Out, KModCount, KModifiers = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.LoadResponse)
    framecount = SendKeyframes(framecount, IDs, entity, Frame, In, Out, KModCount, KModifiers)
    net.Send(player)

    SendLeftoverKeyframes(player, framecount, IDs, entity, Frame, In, Out, KModCount, KModifiers)
end

local function SpawnReset(msgLength, player)
    SMH.Spawner.SpawnReset(player)
end

local function SetSpawnOffsetMode(msgLength, player)
    local set = net.ReadBool()
    SMH.Spawner.SetOffsetMode(set, player)
end

local function SetSpawnOrigin(msgLength, player)
    local path = net.ReadString()
    local model = net.ReadString()

    SMH.Spawner.SetOrigin(path, model, player)
end

local function OffsetPos(msgLength, player)
    local Pos = net.ReadVector()
    SMH.Spawner.SetPosOffset(Pos, player)
end

local function OffsetAng(msgLength, player)
    local Ang = net.ReadAngle()
    SMH.Spawner.SetAngleOffset(Ang, player)
end

local function RequestWorldData(msgLength, player)
    local frame = net.ReadUInt(INT_BITCOUNT)
    local console, push, release = SMH.KeyframeManager.GetWorldData(player, frame)

    net.Start(SMH.MessageTypes.RequestWorldDataResponse)
    net.WriteString(console)
    net.WriteString(push)
    net.WriteString(release)
    net.Send(player)
end

local function UpdateWorld(msgLength, player)
    local str = net.ReadString()
    local key = net.ReadString()
    local frame = net.ReadUInt(INT_BITCOUNT)

    SMH.KeyframeManager.UpdateWorldKeyframe(player, frame, str, key)
end

local function StartPhysicsRecord(msgLength, player)
    local framecount = net.ReadUInt(INT_BITCOUNT)
    local interval = net.ReadUInt(INT_BITCOUNT)
    local frame = net.ReadUInt(INT_BITCOUNT)
    local playbackrate = net.ReadUInt(INT_BITCOUNT)
    local totalframes = net.ReadUInt(INT_BITCOUNT)
    local entities, timelines = {}, {}

    for i = 1, net.ReadUInt(INT_BITCOUNT) do
        local entity = net.ReadEntity()
        local timeline = net.ReadUInt(INT_BITCOUNT)

        if not IsValid(entity) then continue end
        entities[i] = entity
        timelines[entity] = timeline
    end

    local settings = net.ReadTable()

    SMH.PhysRecord.RecordStart(player, framecount, interval, frame, playbackrate, totalframes, entities, timelines, settings)
end

local function StopPhysicsRecord(msgLength, player)
    SMH.PhysRecord.RecordStop(player)
end

local MGR = {}

function MGR.StopPhysicsRecordResponse(player)
    net.Start(SMH.MessageTypes.StopPhysicsRecordResponse)
    net.Send(player)
end

SMH.Controller = MGR

for _, message in pairs(SMH.MessageTypes) do
    util.AddNetworkString(message)
end

net.Receive(SMH.MessageTypes.SetFrame, SetFrame)

net.Receive(SMH.MessageTypes.SelectEntity, SelectEntity)

net.Receive(SMH.MessageTypes.CreateKeyframe, CreateKeyframe)
net.Receive(SMH.MessageTypes.UpdateKeyframe, UpdateKeyframe)
net.Receive(SMH.MessageTypes.UpdateKeyframeExecute, UpdateKeyframeExecute)
net.Receive(SMH.MessageTypes.CopyKeyframe, CopyKeyframe)
net.Receive(SMH.MessageTypes.CopyKeyframeExecute, CopyKeyframeExecute)
net.Receive(SMH.MessageTypes.DeleteKeyframe, DeleteKeyframe)

net.Receive(SMH.MessageTypes.StartPlayback, StartPlayback)
net.Receive(SMH.MessageTypes.StopPlayback, StopPlayback)

net.Receive(SMH.MessageTypes.SetRendering, SetRendering)
net.Receive(SMH.MessageTypes.UpdateGhostState, UpdateGhostState)

net.Receive(SMH.MessageTypes.GetServerSaves, GetServerSaves)
net.Receive(SMH.MessageTypes.GetModelList, GetModelList)
net.Receive(SMH.MessageTypes.GetServerEntities, GetServerEntities)
net.Receive(SMH.MessageTypes.Load, Load)
net.Receive(SMH.MessageTypes.GetModelInfo, GetModelInfo)
net.Receive(SMH.MessageTypes.Save, Save)
net.Receive(SMH.MessageTypes.DeleteSave, DeleteSave)

net.Receive(SMH.MessageTypes.ApplyEntityName, ApplyEntityName)
net.Receive(SMH.MessageTypes.UpdateTimeline, UpdateTimeline)
net.Receive(SMH.MessageTypes.RequestModifiers, RequestModifiers)
net.Receive(SMH.MessageTypes.AddTimeline, AddTimeline)
net.Receive(SMH.MessageTypes.RemoveTimeline, RemoveTimeline)
net.Receive(SMH.MessageTypes.UpdateModifier, UpdateModifier)
net.Receive(SMH.MessageTypes.UpdateKeyframeColor, UpdateKeyframeColor)

net.Receive(SMH.MessageTypes.SetPreviewEntity, SetPreviewEntity)
net.Receive(SMH.MessageTypes.SetSpawnGhost, SetSpawnGhost)
net.Receive(SMH.MessageTypes.SpawnEntity, SpawnEntity)
net.Receive(SMH.MessageTypes.SpawnReset, SpawnReset)
net.Receive(SMH.MessageTypes.SetSpawnOffsetMode, SetSpawnOffsetMode)
net.Receive(SMH.MessageTypes.SetSpawnOrigin, SetSpawnOrigin)
net.Receive(SMH.MessageTypes.OffsetPos, OffsetPos)
net.Receive(SMH.MessageTypes.OffsetAng, OffsetAng)

net.Receive(SMH.MessageTypes.SetTimeline, SetTimeline)
net.Receive(SMH.MessageTypes.RequestTimelineInfo, RequestTimelineInfo)

net.Receive(SMH.MessageTypes.RequestWorldData, RequestWorldData)
net.Receive(SMH.MessageTypes.UpdateWorld, UpdateWorld)

net.Receive(SMH.MessageTypes.StartPhysicsRecord, StartPhysicsRecord)
net.Receive(SMH.MessageTypes.StopPhysicsRecord, StopPhysicsRecord)
