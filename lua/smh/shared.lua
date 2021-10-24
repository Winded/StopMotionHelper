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
}
for key, val in pairs(SMH.MessageTypes) do
    local prefixVal = "SMH" .. val
    SMH.MessageTypes[val] = prefixVal
end

include("shared/saves.lua")
