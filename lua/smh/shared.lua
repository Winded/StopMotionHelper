if not SMH then
    SMH = {}
end

SMH.MessageTypes = {
    "SetFrame",
    "SetFrameResponse",

    "SelectEntity",
    "SelectEntityResponse",

    "CreateKeyframe",
    "UpdateKeyframe",
    "CopyKeyframe",
    "UpdateKeyframeResponse",
    "DeleteKeyframe",
    "DeleteKeyframeResponse",

    "StartPlayback",
    "StopPlayback",
    "PlaybackResponse",

	"IsRendering",
    "UpdateGhostState",
    "UpdateGhostStateResponse",

    "GetServerSaves",
    "GetServerSavesResponse",
    "GetModelList",
    "GetModelListResponse",
    "Load",
    "LoadResponse",
    "Save",
    "SaveResponse",
    "DeleteSave",
    "DeleteSaveResponse",
}
for key, val in pairs(SMH.MessageTypes) do
    local prefixVal = "SMH" .. val
    SMH.MessageTypes[val] = prefixVal
end

include("shared/saves.lua")
