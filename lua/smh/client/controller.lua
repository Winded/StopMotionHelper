local INT_BITCOUNT = 32

local CTRL = {}

function CTRL.SetFrame(frame)
    net.Start(SMH.MessageTypes.SetFrame)
    net.WriteUInt(frame, INT_BITCOUNT)
    net.WriteTable(SMH.Settings.GetAll())
    net.SendToServer()
end

function CTRL.SelectEntity(entity)
    net.Start(SMH.MessageTypes.SelectEntity)
    net.WriteEntity(entity)
    net.SendToServer()
end

function CTRL.Record()
    if not IsValid(SMH.State.Entity) or SMH.State.Frame < 0 then
        return
    end

    net.Start(SMH.MessageTypes.CreateKeyframe)
    net.WriteEntity(SMH.State.Entity)
    net.WriteUInt(SMH.State.Frame, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.UpdateKeyframe(keyframeId, updateData)
    net.Start(SMH.MessageTypes.UpdateKeyframe)
    net.WriteUInt(keyframeId, INT_BITCOUNT)
    net.WriteTable(updateData)
    net.SendToServer()
end

function CTRL.CopyKeyframe(keyframeId, frame)
    net.Start(SMH.MessageTypes.CopyKeyframe)
    net.WriteUInt(keyframeId, INT_BITCOUNT)
    net.WriteUInt(frame, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.DeleteKeyframe(keyframeId)
    net.Start(SMH.MessageTypes.DeleteKeyframe)
    net.WriteUInt(keyframeId, INT_BITCOUNT)
    net.SendToServer()
end

function CTRL.StartPlayback()
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

function CTRL.Load(path, modelName, loadFromClient)
    if not IsValid(SMH.State.Entity) then
        return
    end

    net.Start(SMH.MessageTypes.Load)

    net.WriteEntity(SMH.State.Entity)
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

function CTRL.Save(path, saveToClient)
    net.Start(SMH.MessageTypes.Save)
    net.WriteBool(saveToClient)
    net.WriteString(path)
    net.SendToServer()
end

function CTRL.QuickSave()
	local nick = container:_GetPlayer():Nick()
    local qs1 = "quicksave_" .. nick
    local qs2 = "quicksave_" .. nick .. "_backup"

    SMH.Saves.CopyIfExists(qs1, qs2)
    CTRL.Save(qs1, true)
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

function CTRL.ToggleRendering(useScreenshot)
    if SMH.Renderer.IsRendering() then
        SMH.Renderer.Stop()
    else
        SMH.Renderer.Start(useScreenshot)
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

function CTRL.IsRendering(rendering)
	net.Start(SMH.MessageTypes.IsRendering)
    net.WriteBool(rendering)
    net.SendToServer()
end

function CTRL.UpdateGhostState()
	net.Start(SMH.MessageTypes.UpdateGhostState)
	net.WriteTable(SMH.Settings.GetAll())
	net.SendToServer()
end

SMH.Controller = CTRL

local function SetFrameResponse(msgLength)
    local frame = net.ReadUInt(INT_BITCOUNT)
    SMH.State.Frame = frame
    SMH.UI.SetFrame(frame)
end

local function SelectEntityResponse(msgLength)
    local entity = net.ReadEntity()
    local keyframes = net.ReadTable()

    SMH.State.Entity = entity
    SMH.UI.SetKeyframes(keyframes)
end

local function UpdateKeyframeResponse(msgLength)
    local keyframeId = net.ReadUInt(INT_BITCOUNT)
    local keyframe = net.ReadTable()

    keyframe.ID = keyframeId

    if keyframe.Entity == SMH.State.Entity then
        SMH.UI.UpdateKeyframe(keyframe)
    end
end

local function DeleteKeyframeResponse(msgLength)
    local keyframeId = net.ReadUInt(INT_BITCOUNT)
    SMH.UI.DeleteKeyframe(keyframeId)
end

local function GetServerSavesResponse(msgLength)
    local saves = net.ReadTable()
    SMH.UI.SetServerSaves(saves)
end

local function GetModelListResponse(msgLength)
    local models = net.ReadTable()
    SMH.UI.SetModelList(models)
end

local function LoadResponse(msgLength)
    local entity = net.ReadEntity()
    local keyframes = net.ReadTable()

    if entity == SMH.State.Entity then
        SMH.UI.SetKeyframes(keyframes)
    end
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

local function Setup()
    net.Receive(SMH.MessageTypes.SetFrameResponse, SetFrameResponse)

    net.Receive(SMH.MessageTypes.SelectEntityResponse, SelectEntityResponse)

    net.Receive(SMH.MessageTypes.UpdateKeyframeResponse, UpdateKeyframeResponse)
    net.Receive(SMH.MessageTypes.DeleteKeyframeResponse, DeleteKeyframeResponse)

    net.Receive(SMH.MessageTypes.GetServerSavesResponse, GetServerSavesResponse)
    net.Receive(SMH.MessageTypes.GetModelListResponse, GetModelListResponse)
    net.Receive(SMH.MessageTypes.LoadResponse, LoadResponse)
    net.Receive(SMH.MessageTypes.SaveResponse, SaveResponse)
    net.Receive(SMH.MessageTypes.DeleteSaveResponse, DeleteSaveResponse)
end

Setup()
