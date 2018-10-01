
include("shared.lua");

include("client/data.lua");
include("client/entity_selection.lua");
include("client/render.lua");
include("client/onionskin.lua");

local Rx = include("rxlua/rx.lua");
local RxUtils = include("shared/rxutils.lua");

local MenuSetup = include("client/menu.lua");
local HighlightSetup = include("client/entity_highlight.lua");
local ConCommandsSetup = include("client/concommands.lua");
local NetSetup = include("client/net.lua");

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

    local sendPacketStream = Rx.Subject.create();
    local receivePacketStream = NetSetup(sendPacketStream);
    
    local highlightEventStream = Rx.Subject.create();
    HighlightSetup(highlightEventStream);
    
    local uiStateStream = Rx.Subject.create();
    local uiEventStream = MenuSetup(uiStateStream);

    local conVarStream = Rx.Subject.create();
    local conCommandStream = ConCommandsSetup(conVarStream);

    local filteredEntityStream = uiEventStream:filter(function(id, data) return id == "EntitySelected" and not data:GetNWBool("Ghost", false) end);

    local frameCommandStream = RxUtils.eventObservable(conCommandStream, "FrameOffset")
        :with(RxUtils.eventObservable(uiEventStream, "FrameChanged"):merge(RxUtils.eventObservable(uiStateStream, "Frame")))
        :map(function(frameOffset, frame) return frame + frameOffset end);

    local addKeyframeStream = RxUtils.eventObservable(conCommandStream, "Record")
        :with(
            RxUtils.eventObservable(uiEventStream, "FrameChanged"):merge(RxUtils.eventObservable(uiStateStream, "Frame")),
            RxUtils.eventObservable(uiEventStream, "EaseInChanged"), RxUtils.eventObservable(uiEventStream, "EaseOutChanged")
        )
        :map(function(_, frame, easeIn, easeOut) return { Position = frame, EaseIn = easeIn, EaseOut = easeOut } end);
        
    RxUtils.eventObservable(uiEventStream, "HelpButtonPressed"):subscribe(function()
        gui.OpenURL("https://github.com/Winded/StopMotionHelper/blob/master/TUTORIAL.md");
    end);

    local function translateObservable(observable, sourceEvent, observer, targetEvent)
        observable:filter(function(id, data) return id == sourceEvent end)
            :map(function(id, data) return targetEvent, data end):subscribe(observer);
    end

    translateObservable(receivePacketStream, "AddKeyframeAck", uiStateStream, "AddKeyframe");
    translateObservable(receivePacketStream, "RemoveKeyframeAck", uiStateStream, "RemoveKeyframe");
    translateObservable(receivePacketStream, "ReloadKeyframes", uiStateStream, "ReloadKeyframes");
    
    translateObservable(uiEventStream, "FrameChanged", sendPacketStream, "SetFrame");
    translateObservable(uiEventStream, "KeyframeAdded", sendPacketStream, "AddKeyframeReq");
    translateObservable(uiEventStream, "KeyframeUpdated", sendPacketStream, "UpdateKeyframeReq");
    translateObservable(uiEventStream, "KeyframeCopied", sendPacketStream, "CopyKeyframe");
    translateObservable(uiEventStream, "KeyframeRemoved", sendPacketStream, "RemoveKeyframeReq");
    
    translateObservable(filteredEntityStream, "EntitySelected", highlightEventStream, "SetEntity");
    translateObservable(filteredEntityStream, "EntitySelected", sendPacketStream, "SetEntity");
    
    translateObservable(conCommandStream, "Menu", uiStateStream, "Visible");
    translateObservable(conCommandStream, "Menu", highlightEventStream, "SetHighlight");
    addKeyframeStream:map(function(data) return "AddKeyframeReq", data end):subscribe(sendPacketStream);
    
    frameCommandStream:map(function(data) return "Frame", data end):subscribe(uiStateStream);
    frameCommandStream:map(function(data) return "SetFrame", data end):subscribe(sendPacketStream);
    
    -- TODO
    uiEventStream.Output.TimelineLength:subscribe(function(value) SMH.Data.PlaybackLength = value end);

    uiEventStream.Output.PlaybackRate:subscribe(function(value) SMH.Data.PlaybackRate = value end);

    SMH.Data:_Listen("ShowEaseOptions", function(container, key, value) uiEventStream.Input.ShowEaseOptions(value) end);

    uiEventStream.Input.PlaybackRate(SMH.DefaultData.PlaybackRate);
    uiEventStream.Input.TimelineLength(SMH.DefaultData.PlaybackLength);
    uiEventStream.Input.Position(SMH.DefaultData.Position);
    
    local _, outputSaveFiles = BindData(SMH.Data, "SaveFiles");

    local _, outputEntities = BindData(SMH.Data, "LoadFileEntities");
    local inputLoadFile, _ = BindData(SMH.Data, "LoadFileName");
    local inputLoadFileEntity, _ = BindData(SMH.Data, "LoadFileEntity");
    outputSaveFiles:subscribe(uiEventStream.Load.Input.FileList);
    outputEntities:subscribe(uiEventStream.Load.Input.Entities);
    uiEventStream.Load.Output.File:subscribe(inputLoadFile);
    uiEventStream.Load.Output.Entity:subscribe(inputLoadFileEntity);
    uiEventStream.Load.Output.Load:subscribe(function() SMH.Data:_Call("Load") end);
    uiEventStream.Output.Load:subscribe(function() SMH.Data.ShowLoad = true end);
    
    local inputSaveFile, _ = BindData(SMH.Data, "SaveFileName");
    outputSaveFiles:subscribe(uiEventStream.Save.Input.FileList);
    uiEventStream.Save.Output.File:subscribe(inputSaveFile);
    uiEventStream.Save.Output.Save:subscribe(function() SMH.Data:_Call("Save") end);
    uiEventStream.Save.Output.Delete:subscribe(function() SMH.Data:_Call("DeleteSave") end);
    uiEventStream.Output.Save:subscribe(function() SMH.Data.ShowSave = true end);

    uiEventStream.Settings.Output.FreezeAll:subscribe(function(value) SMH.Data.FreezeAll = value end);
    uiEventStream.Settings.Output.LocalizePhysBones:subscribe(function(value) SMH.Data.LocalizePhysBones = value end);
    uiEventStream.Settings.Output.IgnorePhysBones:subscribe(function(value) SMH.Data.IgnorePhysBones = value end);
    uiEventStream.Settings.Output.GhostPrevFrame:subscribe(function(value) SMH.Data.GhostPrevFrame = value end);
    uiEventStream.Settings.Output.GhostNextFrame:subscribe(function(value) SMH.Data.GhostNextFrame = value end);
    uiEventStream.Settings.Output.GhostAllEntities:subscribe(function(value) SMH.Data.GhostAllEntities = value end);
    uiEventStream.Settings.Output.GhostTransparency:subscribe(function(value) SMH.Data.GhostTransparency = value end);

    uiEventStream.Settings.Input.FreezeAll(SMH.DefaultData.FreezeAll);
    uiEventStream.Settings.Input.LocalizePhysBones(SMH.DefaultData.LocalizePhysBones);
    uiEventStream.Settings.Input.IgnorePhysBones(SMH.DefaultData.IgnorePhysBones);
    uiEventStream.Settings.Input.GhostPrevFrame(SMH.DefaultData.GhostPrevFrame);
    uiEventStream.Settings.Input.GhostNextFrame(SMH.DefaultData.GhostNextFrame);
    uiEventStream.Settings.Input.GhostAllEntities(SMH.DefaultData.GhostAllEntities);
    uiEventStream.Settings.Input.GhostTransparency(SMH.DefaultData.GhostTransparency);

    Msg("SMH client initialized.\n");

end

hook.Add("InitPostEntity", "SMHSetup", function()
    Setup();
end);
