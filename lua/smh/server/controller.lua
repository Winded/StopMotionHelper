local MessageTypes = {
    "SetFrame",
    "SetFrameResponse",

    "GetKeyframes",
    "GetKeyframesResponse",

    "CreateKeyframe",
    "UpdateKeyframe",
    "UpdateKeyframeResponse",
    "DeleteKeyframe",
    "DeleteKeyframeResponse",

    "StartPlayback",
    "StopPlayback",
    "PlaybackResponse",
}
for key, val in pairs(MessageTypes) do
    local prefixVal = "SMH" .. val
    MessageTypes[val] = prefixVal
end

local INT_BITCOUNT = 32

local function SetFrame(msgLength, player)
    local newFrame = net.ReadUInt(INT_BITCOUNT)

    SMH.PlaybackManager.SetFrame(player, newFrame, true)
    
    net.Start(MessageTypes.SetFrameResponse)
    net.WriteUInt(newFrame, INT_BITCOUNT)
    net.Send(player)
end

local function GetKeyframes(msgLength, player)
    local entity = net.ReadEntity()

    local keyframes
    if IsValid(entity) then
        keyframes = SMH.KeyframeManager.GetAllForEntity(player, entity)
    else
        keyframes = SMH.KeyframeManager.GetAll(player)
    end

    net.Start(MessageTypes.GetKeyframesResponse)
    net.WriteEntity(entity)
    net.WriteTable(keyframes)
    net.Send(player)
end

local function CreateKeyframe(msgLength, player)
    local entity = net.ReadEntity()
    local frame = net.ReadUInt(INT_BITCOUNT)

    local keyframe = SMH.KeyframeManager.Create(player, entity, frame)

    net.Start(MessageTypes.UpdateKeyframeResponse)
    net.WriteUInt(keyframe.ID, INT_BITCOUNT)
    net.WriteTable(keyframe)
    net.Send(player)
end

local function UpdateKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)
    local updateData = net.ReadTable()

    local keyframe = SMH.KeyframeManager.Update(player, id, updateData)

    net.Start(MessageTypes.UpdateKeyframeResponse)
    net.WriteUInt(keyframe.ID, INT_BITCOUNT)
    net.WriteTable(keyframe)
    net.Send(player)
end

local function DeleteKeyframe(msgLength, player)
    local id = net.ReadUInt(INT_BITCOUNT)

    SMH.KeyframeManager.Delete(player, id)

    net.Start(MessageTypes.DeleteKeyframeResponse)
    net.WriteUInt(id, INT_BITCOUNT)
    net.Send(player)
end

local function StartPlayback(msgLength, player)
    local startFrame = net.ReadUInt(INT_BITCOUNT)
    local endFrame = net.ReadUInt(INT_BITCOUNT)
    local playbackRate = net.ReadUInt(INT_BITCOUNT)

    SMH.PlaybackManager.StartPlayback(player, startFrame, endFrame, playbackRate)

    net.Start(MessageTypes.PlaybackResponse)
    net.WriteBool(true)
    net.Send(player)
end

local function StopPlayback(msgLength, player)
    SMH.PlaybackManager.StopPlayback(player)

    net.Start(MessageTypes.PlaybackResponse)
    net.WriteBool(false)
    net.Send(player)
end

local CTRL = {}

function CTRL.Setup()
    for _, message in pairs(MessageTypes) do
        util.AddNetworkString(message)
    end

    net.Receive(MessageTypes.SetFrame, SetFrame)

    net.Receive(MessageTypes.GetKeyframes, GetKeyframes)

    net.Receive(MessageTypes.CreateKeyframe, CreateKeyframe)
    net.Receive(MessageTypes.UpdateKeyframe, UpdateKeyframe)
    net.Receive(MessageTypes.DeleteKeyframe, DeleteKeyframe)

    net.Receive(MessageTypes.StartPlayback, StartPlayback)
    net.Receive(MessageTypes.StopPlayback, StopPlayback)
end

SMH.Controller = CTRL
