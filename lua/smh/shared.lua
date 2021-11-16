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

    "SetRendering",
    "UpdateGhostState",
    "UpdateGhostStateResponse",

    "GetServerSaves",
    "GetServerSavesResponse",
    "GetModelList",
    "GetModelListResponse",
    "GetModelInfo",
    "GetModelInfoResponse",
    "GetServerEntities",
    "GetServerEntitiesResponse",
    "Load",
    "LoadResponse",
    "Save",
    "SaveResponse",
    "DeleteSave",
    "DeleteSaveResponse",

    "ApplyEntityName",
    "ApplyEntityNameResponse",
    "UpdateTimeline",
    "UpdateTimelineResponse",
    "RequestModifiers",
    "RequestModifiersResponse",
    "AddTimeline",
    "RemoveTimeline",
    "UpdateTimelineInfoResponse",
    "UpdateModifier",
    "UpdateModifierResponse",
    "UpdateKeyframeColor",
    "UpdateKeyframeColorResponse",

    "SetPreviewEntity",
    "SetSpawnGhost",
    "SpawnEntity",
    "SpawnReset",
    "SetSpawnOffsetMode",
    "SetSpawnOrigin",
    "OffsetPos",
    "OffsetAng",

    "SaveProperties",

    "RequestWorldData",
    "RequestWorldDataResponse",
    "UpdateWorld",
}
for key, val in pairs(SMH.MessageTypes) do
    local prefixVal = "SMH" .. val
    SMH.MessageTypes[val] = prefixVal
end

include("shared/saves.lua")
include("shared/tablesplit.lua")
