
include("shared.lua");

include("client/data.lua");
include("client/entity_selection.lua");
include("client/render.lua");
include("client/onionskin.lua");

local Rx = include("rxlua/rx.lua");

local MenuSetup = include("client/menu.lua");
local HighlightSetup = include("client/entity_highlight.lua");
local ConCommandsSetup = include("client/concommands.lua");

local function BindData(container, key)
    local input = Rx.Subject.create();
    local output = Rx.Subject.create();
    local changing = false;
    
    container:_Listen(key, function(contianer, _, value)
        if not changing then
            changing = true;
            output(value);
            changing = false;
        end
    end);
    input:subscribe(function(value)
        if not changing then
            changing = true;
            container[key] = value;
            changing = false;
        end
    end);

    return input, output;
end

local function Setup()

    SMH.SetupData();

    local menuStreams = MenuSetup();
    local highlightStreams = HighlightSetup();
    local conCommandStreams = ConCommandsSetup();

    conCommandStreams.Output.MenuVisibility:subscribe(menuStreams.Input.Visibility);

    menuStreams.Output.Visibility:subscribe(highlightStreams.Input.Highlight);

    SMH.Data:_Listen("Entity", function(container, key, value) highlightStreams.Input.Entity(value) end);
    menuStreams.Output.Selector:filter(function(entity) return not entity:GetNWBool("Ghost", false) end)
        :subscribe(function(entity) SMH.Data.Entity = entity end);

    local inputPositionStream = Rx.Subject.create();
    inputPositionStream:distinctUntilChanged():subscribe(menuStreams.Input.Position);
    SMH.Data:_Listen("Position", function(container, key, value) inputPositionStream(value) end);
    menuStreams.Output.Position:subscribe(function(position) SMH.Data.Position = position end);
    
    SMH.Data:_Listen("ActiveFrames", function(container, key, value) menuStreams.Input.ActiveFrames(value) end);
    
    menuStreams.Output.FramePosition:subscribe(function(frame, position)
        frame.NewPosition = position;
        SMH.Data.EditedFrame = frame;
    end);
    
    menuStreams.Output.FrameClone:subscribe(function(frameID, position)
        SMH.Data.CopiedFrame = {
            ID = frameID,
            Position = position
        };
    end);
    
    menuStreams.Output.FrameRemove:subscribe(function(frame)
        frame.Remove = true;
        SMH.Data.EditedFrame = frame;
    end);

    menuStreams.Output.Record:subscribe(function() SMH.Data:_Call("Record") end);

    menuStreams.Output.TimelineLength:subscribe(function(value) SMH.Data.PlaybackLength = value end);

    menuStreams.Output.PlaybackRate:subscribe(function(value) SMH.Data.PlaybackRate = value end);

    SMH.Data:_Listen("ShowEaseOptions", function(container, key, value) menuStreams.Input.ShowEaseOptions(value) end);

    local inputEaseInStream, outputEaseInStream = BindData(SMH.Data, "EaseIn");
    outputEaseInStream:subscribe(menuStreams.Input.EaseIn);
    menuStreams.Output.EaseIn:subscribe(inputEaseInStream);

    local inputEaseOutStream, outputEaseOutStream = BindData(SMH.Data, "EaseOut");
    outputEaseOutStream:subscribe(menuStreams.Input.EaseOut);
    menuStreams.Output.EaseOut:subscribe(inputEaseOutStream);

    menuStreams.Input.PlaybackRate(SMH.DefaultData.PlaybackRate);
    menuStreams.Input.TimelineLength(SMH.DefaultData.PlaybackLength);
    menuStreams.Input.Position(SMH.DefaultData.Position);
    
    local _, outputSaveFiles = BindData(SMH.Data, "SaveFiles");

    local _, outputEntities = BindData(SMH.Data, "LoadFileEntities");
    local inputLoadFile, _ = BindData(SMH.Data, "LoadFileName");
    local inputLoadFileEntity, _ = BindData(SMH.Data, "LoadFileEntity");
    outputSaveFiles:subscribe(menuStreams.Load.Input.FileList);
    outputEntities:subscribe(menuStreams.Load.Input.Entities);
    menuStreams.Load.Output.File:subscribe(inputLoadFile);
    menuStreams.Load.Output.Entity:subscribe(inputLoadFileEntity);
    menuStreams.Load.Output.Load:subscribe(function() SMH.Data:_Call("Load") end);
    menuStreams.Output.Load:subscribe(function() SMH.Data.ShowLoad = true end);
    
    local inputSaveFile, _ = BindData(SMH.Data, "SaveFileName");
    outputSaveFiles:subscribe(menuStreams.Save.Input.FileList);
    menuStreams.Save.Output.File:subscribe(inputSaveFile);
    menuStreams.Save.Output.Save:subscribe(function() SMH.Data:_Call("Save") end);
    menuStreams.Save.Output.Delete:subscribe(function() SMH.Data:_Call("DeleteSave") end);
    menuStreams.Output.Save:subscribe(function() SMH.Data.ShowSave = true end);

    menuStreams.Settings.Output.FreezeAll:subscribe(function(value) SMH.Data.FreezeAll = value end);
    menuStreams.Settings.Output.TweenDisable:subscribe(function(value) SMH.Data.TweenDisable = value end);
    menuStreams.Settings.Output.LocalizePhysBones:subscribe(function(value) SMH.Data.LocalizePhysBones = value end);
    menuStreams.Settings.Output.IgnorePhysBones:subscribe(function(value) SMH.Data.IgnorePhysBones = value end);
    menuStreams.Settings.Output.GhostPrevFrame:subscribe(function(value) SMH.Data.GhostPrevFrame = value end);
    menuStreams.Settings.Output.GhostNextFrame:subscribe(function(value) SMH.Data.GhostNextFrame = value end);
    menuStreams.Settings.Output.GhostAllEntities:subscribe(function(value) SMH.Data.GhostAllEntities = value end);
    menuStreams.Settings.Output.GhostTransparency:subscribe(function(value) SMH.Data.GhostTransparency = value end);
    menuStreams.Settings.Output.ShowHelp:subscribe(function()
        gui.OpenURL("https://github.com/Winded/StopMotionHelper/blob/master/TUTORIAL.md");
    end);

    menuStreams.Settings.Input.FreezeAll(SMH.DefaultData.FreezeAll);
	menuStreams.Settings.Input.TweenDisable(SMH.DefaultData.TweenDisable);
    menuStreams.Settings.Input.LocalizePhysBones(SMH.DefaultData.LocalizePhysBones);
    menuStreams.Settings.Input.IgnorePhysBones(SMH.DefaultData.IgnorePhysBones);
    menuStreams.Settings.Input.GhostPrevFrame(SMH.DefaultData.GhostPrevFrame);
    menuStreams.Settings.Input.GhostNextFrame(SMH.DefaultData.GhostNextFrame);
    menuStreams.Settings.Input.GhostAllEntities(SMH.DefaultData.GhostAllEntities);
    menuStreams.Settings.Input.GhostTransparency(SMH.DefaultData.GhostTransparency);

    Msg("SMH client initialized.\n");

end

hook.Add("InitPostEntity", "SMHSetup", function()
    Setup();
end);
