
if not SMH then
    SMH = {};
end

function SMH.Include(path)
    return include("smh/" .. path);
end

include("shared/modifiers.lua");

SMH.GhostTypes = {
    PrevFrame = 1,
    NextFrame = 2,
    OnionSkin = 3
};

SMH.BiValues = BiValuesV022;

SMH.DefaultData = {

    Entity = nil, -- Our currently selected entity

    Position = 0, -- Our current position in the frame timeline

    PlaybackRate = 30,
    PlaybackLength = 100,

    ActiveFrames = {}, -- Client needs this to populate the frame timeline with frames
    EditedFrame = nil, -- Used when we want to edit a frame

    EaseIn = 0,
    EaseOut = 0,

    ShowEaseOptions = false,
    
    ShowSettings = false,

    FreezeAll = false,
    LocalizePhysBones = false,
    IgnorePhysBones = false,
	
	TweenDisable = false,

    ShowHelp = false,
    ShowSave = false,
    ShowLoad = false,

    GhostPrevFrame = false,
    GhostNextFrame = false,
    GhostAllEntities = false,
    GhostTransparency = 0.5,
    
    OnionSkin = false,

    Rendering = false,
    UseScreenshot = false,

};