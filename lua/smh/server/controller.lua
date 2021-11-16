local INT_BITCOUNT = 32

local function SendKeyframes(framecount, IDs, ents, Frame, In, Out, Modifier)
    net.WriteEntity(ents)

    net.WriteUInt(framecount, INT_BITCOUNT)
    for i = 1, framecount do
        net.WriteUInt(IDs[i],INT_BITCOUNT)
        net.WriteUInt(Frame[i], INT_BITCOUNT)
        net.WriteFloat(In[i])
        net.WriteFloat(Out[i])
        net.WriteString(Modifier[i])
    end
end

local function SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    net.WriteString(Name)
    net.WriteUInt(Timelines, INT_BITCOUNT)
    for i=1, Timelines do
        net.WriteUInt(i, 4) -- Timelines can't go over 10, unless someone hacky messes it up
        net.WriteColor(KeyColor[i])
        net.WriteUInt(ModCount[i], INT_BITCOUNT)
        for j=1, ModCount[i] do
            net.WriteString(Modifiers[i][j])
        end
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
    if player ~= entity then
        SMH.GhostsManager.SelectEntity(player, entity)
    else
        SMH.GhostsManager.SelectEntity(player, nil)
    end

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)
    local exists = Name and true or false

    net.Start(SMH.MessageTypes.SelectEntityResponse)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)

    net.WriteBool(exists)
    if exists then
        SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    end
    net.Send(player)
end

local function CreateKeyframe(msgLength, player)
    local entity = net.ReadEntity()
    local frame = net.ReadUInt(INT_BITCOUNT)
    local timeline = net.ReadUInt(INT_BITCOUNT)
    local isnewent = SMH.PropertiesManager.CheckEntity(player, entity)

    SMH.PropertiesManager.AddEntity(player, entity)
    local totaltimelines = SMH.PropertiesManager.GetTimelines(player, entity)
    if timeline > totaltimelines then timeline = 1 end

    local keyframes = SMH.KeyframeManager.Create(player, entity, frame, timeline)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    SendKeyframes(framecount, IDs, ents, Frame, In, Out, Modifier)
    net.WriteBool(isnewent)
    if isnewent then
        local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
        local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)
        SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    end
    net.Send(player)
end

local function UpdateKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)
    local updateData = net.ReadTable()

    local keyframe = SMH.KeyframeManager.Update(player, id, updateData)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes({keyframe})

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    SendKeyframes(framecount, IDs, ents, Frame, In, Out, Modifier)
    net.WriteBool(false)
    net.Send(player)
end

local function CopyKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)
    local frame = net.ReadUInt(INT_BITCOUNT)

    local keyframe = SMH.KeyframeManager.Copy(player, id, frame)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes({keyframe})

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    SendKeyframes(framecount, IDs, ents, Frame, In, Out, Modifier)
    net.WriteBool(false)
    net.Send(player)
end

local function DeleteKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)

    local entity = SMH.KeyframeManager.Delete(player, id)

    SMH.PropertiesManager.RemoveEntity(player)
    local isoldent = SMH.PropertiesManager.CheckEntity(player, entity)

    net.Start(SMH.MessageTypes.DeleteKeyframeResponse)
    net.WriteUInt(id, INT_BITCOUNT)
    net.WriteBool(isoldent)
    net.Send(player)
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
    local saves, keys, count = SMH.TableSplit.DList(SMH.Saves.ListFiles())
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
    local models, keys, count = SMH.TableSplit.DList(modelslist)
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
    local entities, keys, count = SMH.TableSplit.DList(SMH.PropertiesManager.GetAllEntitiesNames(player))

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

    SMH.PropertiesManager.AddEntity(player, entity)
    SMH.KeyframeManager.ImportSave(player, entity, serializedKeyframes, entityProperties)
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.LoadResponse)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
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
    local entity = net.ReadEntity()

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateTimelineResponse)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    net.Send(player)
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

local function AddTimeline(msgLength, player)
    local entity = net.ReadEntity()
    SMH.PropertiesManager.SetTimelines(player, entity, true)

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    net.Send(player)
end

local function RemoveTimeline(msgLength, player)
    local entity = net.ReadEntity()
    SMH.PropertiesManager.SetTimelines(player, entity, false)

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    net.Send(player)
end

local function UpdateModifier(msgLength, player)
    local entity = net.ReadEntity()
    local itimeline = net.ReadUInt(INT_BITCOUNT)
    local name = net.ReadString()
    local state = net.ReadBool()

    local changed = SMH.PropertiesManager.UpdateModifier(player, entity, itimeline, name, state)
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.UpdateModifierResponse)
    net.WriteString(changed)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    net.Send(player)
end

local function UpdateKeyframeColor(msgLength, player)
    local entity = net.ReadEntity()
    local timeline = net.ReadUInt(INT_BITCOUNT)
    local color = net.ReadColor()

    SMH.PropertiesManager.UpdateKeyframeColor(player, entity, color, timeline)
    local timelineinfo = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timelineinfo)

    net.Start(SMH.MessageTypes.UpdateKeyframeColorResponse)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
end

local function SaveProperties(msgLength, player)
    local entity = net.ReadEntity()
    if not entity or player == entity then return end
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)

    SMH.Saves.SaveProperties(timeline, player)
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

    SMH.PropertiesManager.AddEntity(player, entity)
    SMH.KeyframeManager.ImportSave(player, entity, serializedKeyframes, entityProperties)

    if offset then
        SMH.Spawner.OffsetKeyframes(player, entity)
    end

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local Name, Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(timeline)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    local framecount, IDs, ents, Frame, In, Out, _, Modifier = SMH.TableSplit.DKeyframes(keyframes)

    net.Start(SMH.MessageTypes.LoadResponse)
    SendKeyframes(framecount, IDs, entity, Frame, In, Out, Modifier)
    SendProperties(Name, Timelines, KeyColor, ModCount, Modifiers)
    net.Send(player)
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

for _, message in pairs(SMH.MessageTypes) do
    util.AddNetworkString(message)
end

net.Receive(SMH.MessageTypes.SetFrame, SetFrame)

net.Receive(SMH.MessageTypes.SelectEntity, SelectEntity)

net.Receive(SMH.MessageTypes.CreateKeyframe, CreateKeyframe)
net.Receive(SMH.MessageTypes.UpdateKeyframe, UpdateKeyframe)
net.Receive(SMH.MessageTypes.CopyKeyframe, CopyKeyframe)
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

net.Receive(SMH.MessageTypes.SaveProperties, SaveProperties)

net.Receive(SMH.MessageTypes.RequestWorldData, RequestWorldData)
net.Receive(SMH.MessageTypes.UpdateWorld, UpdateWorld)
