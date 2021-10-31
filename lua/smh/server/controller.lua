local INT_BITCOUNT = 32

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
    SMH.GhostsManager.SelectEntity(player, entity)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)

    net.Start(SMH.MessageTypes.SelectEntityResponse)
    net.WriteEntity(entity)
    net.WriteTable(keyframes)
    net.WriteTable(timeline)
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
    local IDs = {}
    for _, kframe in ipairs(keyframes) do
        table.insert(IDs, kframe.ID)
    end

    local clientKeyframes = table.Copy(keyframes)
    for _, kframe in ipairs(clientKeyframes) do
        kframe.ID = nil
        kframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    net.WriteTable(IDs)
    net.WriteTable(clientKeyframes)
    net.WriteBool(isnewent)
    if isnewent then 
        net.WriteTable(SMH.PropertiesManager.GetAllEntityProperties(player, entity))
    end
    net.Send(player)
end

local function UpdateKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)
    local updateData = net.ReadTable()

    local keyframe = SMH.KeyframeManager.Update(player, id, updateData)
    local clientKeyframe = table.Copy(keyframe)
    clientKeyframe.ID = nil
    clientKeyframe.Modifiers = nil

    local IDs = {keyframe.ID}
    local clientKeyframes = {clientKeyframe}

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    net.WriteTable(IDs)
    net.WriteTable(clientKeyframes)
    net.WriteBool(false)
    net.Send(player)
end

local function CopyKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)
    local frame = net.ReadUInt(INT_BITCOUNT)

    local keyframe = SMH.KeyframeManager.Copy(player, id, frame)
    local clientKeyframe = table.Copy(keyframe)
    clientKeyframe.ID = nil
    clientKeyframe.Modifiers = nil

    local IDs = {keyframe.ID}
    local clientKeyframes = {clientKeyframe}

    net.Start(SMH.MessageTypes.UpdateKeyframeResponse)
    net.WriteTable(IDs)
    net.WriteTable(clientKeyframes)
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
    local saves = SMH.Saves.ListFiles()
    net.Start(SMH.MessageTypes.GetServerSavesResponse)
    net.WriteTable(saves)
    net.Send(player)
end

local function GetModelList(msgLength, player)
    local path = net.ReadString()

    local models, map = SMH.Saves.ListModels(path)
    net.Start(SMH.MessageTypes.GetModelListResponse)
    net.WriteTable(models)
    net.WriteString(map)
    net.Send(player)
end

local function GetServerEntities(msgLength, player)
    local entities = SMH.PropertiesManager.GetAllEntitiesNames(player)

    net.Start(SMH.MessageTypes.GetServerEntitiesResponse)
    net.WriteTable(entities)
    net.Send(player)
end

local function Load(msgLength, player)
    local entity = net.ReadEntity()
    local loadFromClient = net.ReadBool()

    local serializedKeyframes, entityProperties
    if loadFromClient then
        serializedKeyframes = net.ReadTable()
    else
        local path = net.ReadString()
        local modelName = net.ReadString()
        serializedKeyframes, entityProperties = SMH.Saves.LoadForEntity(path, modelName)
    end

    SMH.PropertiesManager.AddEntity(player, entity)
    SMH.KeyframeManager.ImportSave(player, entity, serializedKeyframes, entityProperties)
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)

    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.LoadResponse)
    net.WriteEntity(entity)
    net.WriteTable(keyframes)
    net.WriteTable(timeline)
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
    local serializedKeyframes = SMH.Saves.Serialize(keyframes, properties)

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
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.UpdateTimelineResponse)
    net.WriteTable(keyframes)
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
    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    net.WriteTable(timeline)
    net.WriteTable(keyframes)
    net.Send(player)
end

local function RemoveTimeline(msgLength, player)
    local entity = net.ReadEntity()
    SMH.PropertiesManager.SetTimelines(player, entity, false)

    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.UpdateTimelineInfoResponse)
    net.WriteTable(timeline)
    net.WriteTable(keyframes)
    net.Send(player)
end

local function UpdateModifier(msgLength, player)
    local entity = net.ReadEntity()
    local itimeline = net.ReadUInt(INT_BITCOUNT)
    local name = net.ReadString()
    local state = net.ReadBool()

    local changed = SMH.PropertiesManager.UpdateModifier(player, entity, itimeline, name, state)
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)
    local keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    for _, keyframe in pairs(keyframes) do
        keyframe.Modifiers = nil
    end

    net.Start(SMH.MessageTypes.UpdateModifierResponse)
    net.WriteString(changed)
    net.WriteTable(timeline)
    net.WriteTable(keyframes)
    net.Send(player)
end

local function UpdateKeyframeColor(msgLength, player)
    local entity = net.ReadEntity()
    local timeline = net.ReadUInt(INT_BITCOUNT)
    local color = net.ReadColor()

    SMH.PropertiesManager.UpdateKeyframeColor(player, entity, color, timeline)
    local timelineinfo = SMH.PropertiesManager.GetAllEntityProperties(player, entity)

    net.Start(SMH.MessageTypes.UpdateKeyframeColorResponse)
    net.WriteTable(timelineinfo)
    net.Send(player)
end

local function SaveProperties(msgLength, player)
    local entity = net.ReadEntity()
    if not entity then return end
    local timeline = SMH.PropertiesManager.GetAllEntityProperties(player, entity)

    SMH.Saves.SaveProperties(timeline, player)
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

net.Receive(SMH.MessageTypes.SaveProperties, SaveProperties)
