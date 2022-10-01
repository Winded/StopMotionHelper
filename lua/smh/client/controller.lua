local INT_BITCOUNT = 32
local KFRAMES_PER_MSG = 250

local function ReceiveKeyframes()
    local framecount = net.ReadUInt(INT_BITCOUNT)
    for i = 1, framecount do
        local ID, entity, Frame, ModCount = net.ReadUInt(INT_BITCOUNT), net.ReadEntity(), net.ReadUInt(INT_BITCOUNT), net.ReadUInt(INT_BITCOUNT)
        local Modifiers, In, Out = {}, {}, {}
        for j = 1, ModCount do
            local name = net.ReadString()
            Modifiers[name] = true
            In[name] = net.ReadFloat()
            Out[name] = net.ReadFloat()
        end
        SMH.TableSplit.AKeyframes(ID, entity, Frame, In, Out, Modifiers)
    end
    return SMH.TableSplit.GetKeyframes()
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

local CTRL = {}

function CTRL.SetFrame(frame)
    if SMH.PhysRecord.IsActive() then return end

    net.Start(SMH.MessageTypes.SetFrame)
    net.WriteUInt(frame, INT_BITCOUNT)
    net.WriteTable(SMH.Settings.GetAll())
    net.WriteUInt(SMH.State.Timeline, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.SelectEntity(entity, enttable)
    if SMH.PhysRecord.IsActive() then return end
    local count = 0

    for ent, _ in pairs(enttable) do
        count = count + 1
    end

    net.Start(SMH.MessageTypes.SelectEntity)
    net.WriteEntity(entity)
    net.WriteUInt(count, INT_BITCOUNT)
    for tentity, _ in pairs(enttable) do
        net.WriteEntity(tentity)
    end
    net.SendToServer()
end

function CTRL.Record()
    if not next(SMH.State.Entity) or SMH.State.Frame < 0 or SMH.State.Timeline < 1 or SMH.PhysRecord.IsActive() then
        return
    end
    local count = 0

    for ent, _ in pairs(SMH.State.Entity) do
        count = count + 1
    end

    net.Start(SMH.MessageTypes.CreateKeyframe)
    net.WriteUInt(count, INT_BITCOUNT)
    for entity, _ in pairs(SMH.State.Entity) do
        net.WriteEntity(entity)
    end
    net.WriteUInt(SMH.State.Frame, INT_BITCOUNT)
    net.WriteUInt(SMH.State.Timeline, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.UpdateKeyframe(keyframeId, updateData, singledata)
    local keyframeAmount = #keyframeId

    for i = 1, math.ceil(keyframeAmount / KFRAMES_PER_MSG) do
        local keyframesToSend = keyframeAmount - KFRAMES_PER_MSG * (i - 1) > KFRAMES_PER_MSG and KFRAMES_PER_MSG or keyframeAmount - KFRAMES_PER_MSG * (i - 1)

        net.Start(SMH.MessageTypes.UpdateKeyframe)
        net.WriteUInt(keyframesToSend, INT_BITCOUNT)

        for ids = 1 + KFRAMES_PER_MSG * (i - 1), keyframesToSend + KFRAMES_PER_MSG * (i - 1) do
            net.WriteUInt(keyframeId[ids], INT_BITCOUNT)

            if singledata then
                for data, value in pairs(updateData) do
                    net.WriteString(data)
                    if data == "Frame" then
                        net.WriteUInt(value, INT_BITCOUNT)
                    else
                        net.WriteFloat(value)
                    end
                end
            else
                for data, value in pairs(updateData[ids]) do
                    net.WriteString(data)
                    if data == "Frame" then
                        net.WriteUInt(value, INT_BITCOUNT)
                    else
                        net.WriteFloat(value)
                    end
                end
            end
        end
        net.WriteUInt(SMH.State.Timeline, INT_BITCOUNT)
        net.SendToServer()
    end

    net.Start(SMH.MessageTypes.UpdateKeyframeExecute)
    net.SendToServer()
end

function CTRL.CopyKeyframe(keyframeId, frame)
    local keyframeAmount = #keyframeId

    for i = 1, math.ceil(keyframeAmount / KFRAMES_PER_MSG) do
        local keyframesToSend = keyframeAmount - KFRAMES_PER_MSG * (i - 1) > KFRAMES_PER_MSG and KFRAMES_PER_MSG or keyframeAmount - KFRAMES_PER_MSG * (i - 1)

        net.Start(SMH.MessageTypes.CopyKeyframe)
        net.WriteUInt(keyframesToSend, INT_BITCOUNT)

        for ids = 1 + KFRAMES_PER_MSG * (i - 1), keyframesToSend + KFRAMES_PER_MSG * (i - 1) do
            net.WriteUInt(keyframeId[ids], INT_BITCOUNT)
            net.WriteUInt(frame[ids], INT_BITCOUNT)
        end
        net.WriteUInt(SMH.State.Timeline, INT_BITCOUNT)
        net.SendToServer()
    end

    net.Start(SMH.MessageTypes.CopyKeyframeExecute)
    net.SendToServer()
end

function CTRL.DeleteKeyframe(keyframeId)
    local keyframeAmount = #keyframeId

    for i = 1, math.ceil(keyframeAmount / KFRAMES_PER_MSG) do
        local keyframesToSend = keyframeAmount - KFRAMES_PER_MSG * (i - 1) > KFRAMES_PER_MSG and KFRAMES_PER_MSG or keyframeAmount - KFRAMES_PER_MSG * (i - 1)

        net.Start(SMH.MessageTypes.DeleteKeyframe)
        net.WriteUInt(keyframesToSend, INT_BITCOUNT)
        net.WriteUInt(SMH.State.Timeline, INT_BITCOUNT)

        for ids = 1 + KFRAMES_PER_MSG * (i - 1), keyframesToSend + KFRAMES_PER_MSG * (i - 1) do
            net.WriteUInt(keyframeId[ids], INT_BITCOUNT)
        end

        net.SendToServer()
    end
end

function CTRL.StartPlayback()
    if SMH.PhysRecord.IsActive() then return end

    net.Start(SMH.MessageTypes.StartPlayback)
    net.WriteUInt(SMH.State.Frame, INT_BITCOUNT)
    net.WriteUInt(SMH.State.PlaybackLength - 1, INT_BITCOUNT)
    net.WriteUInt(SMH.State.PlaybackRate, INT_BITCOUNT)
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.StopPlayback()
    net.Start(SMH.MessageTypes.StopPlayback)
    net.SendToServer()
end

function CTRL.GetServerSaves()
    net.Start(SMH.MessageTypes.GetServerSaves)
    net.SendToServer()
end

function CTRL.GetModelList(path, loadFromClient)
    if loadFromClient then
        local models = SMH.Saves.ListModels(path)
        SMH.UI.SetModelList(models)
    else
        net.Start(SMH.MessageTypes.GetModelList)
        net.WriteString(path)
        net.SendToServer()
    end
end

function CTRL.GetServerEntities()
    net.Start(SMH.MessageTypes.GetServerEntities)
    net.SendToServer()
end

function CTRL.Load(path, modelName, loadFromClient)
    if not next(SMH.State.Entity) then
        return
    end
    local entity = next(SMH.State.Entity)

    net.Start(SMH.MessageTypes.Load)

    net.WriteEntity(entity)
    net.WriteBool(loadFromClient)

    if loadFromClient then
        local serializedKeyframes = SMH.Saves.LoadForEntity(path, modelName)
        net.WriteTable(serializedKeyframes)
    else
        net.WriteString(path)
        net.WriteString(modelName)
    end

    net.SendToServer()
end

function CTRL.GetModelInfo(path, modelName, loadFromClient)
    net.Start(SMH.MessageTypes.GetModelInfo)
    net.WriteString(path)
    net.WriteString(modelName)
    net.SendToServer()
end

function CTRL.Save(path, saveToClient)
    net.Start(SMH.MessageTypes.Save)
    net.WriteBool(saveToClient)
    net.WriteString(path)
    net.SendToServer()
end

function CTRL.QuickSave()
    local nick = LocalPlayer():Nick()
    local qs1 = "quicksave_" .. nick
    local qs2 = "quicksave_" .. nick .. "_backup"

    SMH.Saves.CopyIfExists(qs1, qs2)
    CTRL.Save(qs1, false)
end

function CTRL.DeleteSave(path, deleteFromClient)
    if deleteFromClient then
        SMH.Saves.Delete(path)
    else
        net.Start(SMH.MessageTypes.DeleteSave)
        net.WriteString(path)
        net.SendToServer()
    end
end

function CTRL.ShouldHighlight()
    return SMH.UI.IsOpen()
end

function CTRL.ToggleRendering(useScreenshot, StartFrame)
    if SMH.PhysRecord.IsActive() then return end

    if SMH.Renderer.IsRendering() then
        SMH.Renderer.Stop()
    else
        SMH.Renderer.Start(useScreenshot, StartFrame)
    end
end

function CTRL.OpenMenu()
    SMH.UI.Open()
end

function CTRL.CloseMenu()
    SMH.UI.Close()
end

function CTRL.UpdateState(newState)
    local allowedKeys = {
        Frame = true,
        Timeline = true,
        PlaybackRate = true,
        PlaybackLength = true,
    }

    for k, v in pairs(newState) do
        if not allowedKeys[k] then
            error("Key not allowed: " .. k)
        end
        SMH.State[k] = v
    end

    SMH.UI.UpdateState(SMH.State)
end

function CTRL.UpdateSettings(newSettings)
    SMH.Settings.Update(newSettings)
end

function CTRL.OpenHelp()
    gui.OpenURL("https://github.com/Winded/StopMotionHelper/blob/master/TUTORIAL.md")
end

function CTRL.SetRendering(rendering)
    net.Start(SMH.MessageTypes.SetRendering)
    net.WriteBool(rendering)
    net.SendToServer()
end

function CTRL.UpdateGhostState()
    net.Start(SMH.MessageTypes.UpdateGhostState)
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.ApplyEntityName(ent, name)
    net.Start(SMH.MessageTypes.ApplyEntityName)
    net.WriteEntity(ent)
    net.WriteString(name)
    net.SendToServer()
end

function CTRL.UpdateTimeline()
    local count = 0

    for ent, _ in pairs(SMH.State.Entity) do
        count = count + 1
    end

    net.Start(SMH.MessageTypes.UpdateTimeline)
    net.WriteUInt(count, INT_BITCOUNT)
    for entity, _ in pairs(SMH.State.Entity) do
        net.WriteEntity(entity)
    end
    net.SendToServer()
end

function CTRL.RequestModifiers()
    net.Start(SMH.MessageTypes.RequestModifiers)
    net.SendToServer()
end

function CTRL.AddTimeline()
    net.Start(SMH.MessageTypes.AddTimeline)
    net.SendToServer()
end

function CTRL.RemoveTimeline()
    net.Start(SMH.MessageTypes.RemoveTimeline)
    net.SendToServer()
end

function CTRL.UpdateModifier(i, mod, check)
    net.Start(SMH.MessageTypes.UpdateModifier)
    net.WriteUInt(i, INT_BITCOUNT)
    net.WriteString(mod)
    net.WriteBool(check)
    net.SendToServer()
end

function CTRL.UpdateKeyframeColor(color, timeline)
    net.Start(SMH.MessageTypes.UpdateKeyframeColor)
    net.WriteUInt(timeline, INT_BITCOUNT)
    net.WriteColor(color)
    net.SendToServer()
end

function CTRL.SetPreviewEntity(path, model, loadFromClient)
    net.Start(SMH.MessageTypes.SetPreviewEntity)
    net.WriteString(path)
    net.WriteString(model)
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.SetSpawnGhost(state)
    net.Start(SMH.MessageTypes.SetSpawnGhost)
    net.WriteBool(state)
    net.SendToServer()
end

function CTRL.SpawnEntity(path, model, loadFromClient)
    if SMH.PhysRecord.IsActive() then return end

    net.Start(SMH.MessageTypes.SpawnEntity)
    net.WriteString(path)
    net.WriteString(model)
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.SpawnReset()
    net.Start(SMH.MessageTypes.SpawnReset)
    net.SendToServer()
end

function CTRL.SetSpawnOffsetMode(set)
    net.Start(SMH.MessageTypes.SetSpawnOffsetMode)
    net.WriteBool(set)
    net.SendToServer()
end

function CTRL.SetSpawnOrigin(path, model, loadFromClient)
    net.Start(SMH.MessageTypes.SetSpawnOrigin)
    net.WriteString(path)
    net.WriteString(model)
    net.SendToServer()
end

function CTRL.OffsetPos(Pos)
    net.Start(SMH.MessageTypes.OffsetPos)
    net.WriteVector(Pos)
    net.SendToServer()
end

function CTRL.OffsetAng(Ang)
    net.Start(SMH.MessageTypes.OffsetAng)
    net.WriteAngle(Ang)
    net.SendToServer()
end

function CTRL.SetTimeline(settings, presetname)
    net.Start(SMH.MessageTypes.SetTimeline)
    net.WriteBool(presetname == "default")
    if not (presetname == "default") then
        local Timelines, KeyColor, ModCount, Modifiers = SMH.TableSplit.DProperties(settings)
        SendProperties(Timelines, KeyColor, ModCount, Modifiers)
    end
    net.SendToServer()
end

function CTRL.RequestTimelineInfo(name)
    net.Start(SMH.MessageTypes.RequestTimelineInfo)
    net.WriteString(name)
    net.SendToServer()
end

function CTRL.RequestWorldData(frame)
    net.Start(SMH.MessageTypes.RequestWorldData)
    net.WriteUInt(frame, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.UpdateWorld(str, key)
    net.Start(SMH.MessageTypes.UpdateWorld)
    net.WriteString(str)
    net.WriteString(key)
    net.WriteUInt(SMH.State.Frame, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.StartPhysicsRecord(framecount, interval, entities)
    if not next(entities) or SMH.State.Frame < 0 or SMH.State.Timeline < 1 then
        return
    end

    net.Start(SMH.MessageTypes.StartPhysicsRecord)
    net.WriteUInt(framecount, INT_BITCOUNT)
    net.WriteUInt(interval, INT_BITCOUNT)
    net.WriteUInt(SMH.State.Frame, INT_BITCOUNT)
    net.WriteUInt(SMH.State.PlaybackRate, INT_BITCOUNT)
    net.WriteUInt(SMH.State.PlaybackLength, INT_BITCOUNT)
    net.WriteUInt(table.Count(entities), INT_BITCOUNT)
    for entity, timeline in pairs(entities) do
        net.WriteEntity(entity)
        net.WriteUInt(timeline, INT_BITCOUNT)
    end
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.StopPhysicsRecord()
    net.Start(SMH.MessageTypes.StopPhysicsRecord)
    net.SendToServer()
end

SMH.Controller = CTRL

local function SetFrameResponse(msgLength)
    local frame = net.ReadUInt(INT_BITCOUNT)
    SMH.State.Frame = frame
    SMH.UI.SetFrame(frame)
end

local function SelectEntityResponse(msgLength)
    local keyframes = ReceiveKeyframes()
    local entities = {}
    for i = 1, net.ReadUInt(INT_BITCOUNT) do
        entities[net.ReadEntity()] = true
    end

    local entity = next(entities)

    SMH.State.Entity = entities
    SMH.UI.SetSelectedEntity(entities)
    SMH.UI.SetUsingWorld(entity == LocalPlayer())
    SMH.UI.SetKeyframes(keyframes)
end

local function UpdateKeyframeResponse(msgLength)
    local keyframes = ReceiveKeyframes()

    for num, keyframe in ipairs(keyframes) do
        if SMH.State.Entity[keyframe.Entity] then
            SMH.UI.UpdateKeyframe(keyframe)
        end
    end
end

local function DeleteKeyframeResponse(msgLength)
    local keyframeId = net.ReadUInt(INT_BITCOUNT)
    SMH.UI.DeleteKeyframe(keyframeId)
end

local function GetAllKeyframes(msgLength)
    local keyframes = ReceiveKeyframes()

    SMH.UI.SetKeyframes(keyframes, true)
end

local function GetServerSavesResponse(msgLength)
    for i=1, net.ReadUInt(INT_BITCOUNT) do
        SMH.TableSplit.ATable(net.ReadString(), net.ReadString())
    end
    local saves = SMH.TableSplit.GetTable()
    SMH.UI.SetServerSaves(saves)
end

local function GetModelListResponse(msgLength)
    for i=1, net.ReadUInt(INT_BITCOUNT) do
        SMH.TableSplit.ATable(net.ReadString(), net.ReadString())
    end
    local models = SMH.TableSplit.GetTable()
    local map = net.ReadString()
    SMH.UI.SetModelList(models, map)
end

local function GetServerEntitiesResponse(msgLength)
    for i=1, net.ReadUInt(INT_BITCOUNT) do
        SMH.TableSplit.ATable(net.ReadEntity(), {Name = net.ReadString()})
    end
    local entities = SMH.TableSplit.GetTable()
    SMH.UI.SetEntityList(entities)
end

local function LoadResponse(msgLength)
    local keyframes = ReceiveKeyframes()
    local entity = net.ReadEntity()

    if SMH.State.Entity[entity] then
        SMH.UI.SetKeyframes(keyframes)
    end
end

local function GetModelInfoResponse(msgLength)
    local name = net.ReadString()
    SMH.UI.SetModelName(name)
end

local function SaveResponse(msgLength)
    local saveToClient = net.ReadBool()
    local path = net.ReadString()
    if not saveToClient then
        CTRL.GetServerSaves() -- Refresh server saves
        return
    end

    local serializedKeyframes = net.ReadTable()
    SMH.Saves.Save(path, serializedKeyframes)
    SMH.UI.AddSaveFile(path)
end

local function DeleteSaveResponse(msgLength)
    local path = net.ReadString()

    SMH.UI.RemoveSaveFile(path)
end

local function ApplyEntityNameResponse(msgLength)
    local name = net.ReadString()

    SMH.UI.UpdateName(name)
end

local function UpdateTimelineResponse(msgLength)
    local keyframes = ReceiveKeyframes()

    SMH.UI.SetKeyframes(keyframes)
end

local function RequestModifiersResponse(msgLength)
    local list = net.ReadTable()

    SMH.UI.InitModifiers(list)
end

local function UpdateTimelineInfoResponse(msgLength)
    local timeline = ReceiveProperties()

    SMH.UI.SetTimeline(timeline)
end

local function UpdateModifierResponse(msgLength)
    local changed = net.ReadString()
    local timeline = ReceiveProperties()

    SMH.UI.UpdateModifier(timeline, changed)
end

local function UpdateKeyframeColorResponse(msgLength)
    local timelineinfo = ReceiveProperties()

    SMH.UI.UpdateKeyColor(timelineinfo)
end

local function RequestTimelineInfoResponse(msgLength)
    local name = net.ReadString()
    local timeline = ReceiveProperties()

    SMH.Saves.SaveProperties(timeline, name)
    SMH.UI.RefreshTimelineSettings()
end

local function RequestWorldDataResponse(msgLength)
    local console = net.ReadString()
    local push = net.ReadString()
    local release = net.ReadString()

    SMH.UI.SetWorldData(console, push, release)
end

local function StopPhysicsRecordResponse(msgLength)
    SMH.PhysRecord.Stop()
end

local function Setup()
    net.Receive(SMH.MessageTypes.SetFrameResponse, SetFrameResponse)

    net.Receive(SMH.MessageTypes.SelectEntityResponse, SelectEntityResponse)

    net.Receive(SMH.MessageTypes.UpdateKeyframeResponse, UpdateKeyframeResponse)
    net.Receive(SMH.MessageTypes.DeleteKeyframeResponse, DeleteKeyframeResponse)
    net.Receive(SMH.MessageTypes.GetAllKeyframes, GetAllKeyframes)

    net.Receive(SMH.MessageTypes.GetServerSavesResponse, GetServerSavesResponse)
    net.Receive(SMH.MessageTypes.GetModelListResponse, GetModelListResponse)
    net.Receive(SMH.MessageTypes.GetServerEntitiesResponse, GetServerEntitiesResponse)
    net.Receive(SMH.MessageTypes.LoadResponse, LoadResponse)
    net.Receive(SMH.MessageTypes.GetModelInfoResponse, GetModelInfoResponse)
    net.Receive(SMH.MessageTypes.SaveResponse, SaveResponse)
    net.Receive(SMH.MessageTypes.DeleteSaveResponse, DeleteSaveResponse)

    net.Receive(SMH.MessageTypes.ApplyEntityNameResponse, ApplyEntityNameResponse)
    net.Receive(SMH.MessageTypes.UpdateTimelineResponse, UpdateTimelineResponse)
    net.Receive(SMH.MessageTypes.RequestModifiersResponse, RequestModifiersResponse)
    net.Receive(SMH.MessageTypes.UpdateTimelineInfoResponse, UpdateTimelineInfoResponse)
    net.Receive(SMH.MessageTypes.UpdateModifierResponse, UpdateModifierResponse)
    net.Receive(SMH.MessageTypes.UpdateKeyframeColorResponse, UpdateKeyframeColorResponse)

    net.Receive(SMH.MessageTypes.RequestTimelineInfoResponse, RequestTimelineInfoResponse)

    net.Receive(SMH.MessageTypes.RequestWorldDataResponse, RequestWorldDataResponse)

    net.Receive(SMH.MessageTypes.StopPhysicsRecordResponse, StopPhysicsRecordResponse)
end

Setup()
