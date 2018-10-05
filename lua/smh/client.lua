
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
    translateObservable(receivePacketStream, "GetSaveFilesAck", uiStateStream, "UpdateSaveFiles");
    translateObservable(receivePacketStream, "GetSaveFileEntitiesAck", uiStateStream, "UpdateSaveFileEntities");
    
    translateObservable(uiEventStream, "FrameChanged", sendPacketStream, "SetFrame");
    translateObservable(uiEventStream, "KeyframeAdded", sendPacketStream, "AddKeyframeReq");
    translateObservable(uiEventStream, "KeyframeUpdated", sendPacketStream, "UpdateKeyframeReq");
    translateObservable(uiEventStream, "KeyframeCopied", sendPacketStream, "CopyKeyframe");
    translateObservable(uiEventStream, "KeyframeRemoved", sendPacketStream, "RemoveKeyframeReq");
    translateObservable(uiEventStream, "SaveFilesRequested", sendPacketStream, "GetSaveFilesReq");
    translateObservable(uiEventStream, "SaveFileEntitiesRequested", sendPacketStream, "GetSaveFileEntitiesReq");
    translateObservable(uiEventStream, "Save", sendPacketStream, "Save");
    translateObservable(uiEventStream, "Load", sendPacketStream, "Load");
    
    translateObservable(filteredEntityStream, "EntitySelected", highlightEventStream, "SetEntity");
    translateObservable(filteredEntityStream, "EntitySelected", sendPacketStream, "SetEntity");
    
    translateObservable(conCommandStream, "Menu", uiStateStream, "Visible");
    translateObservable(conCommandStream, "Menu", highlightEventStream, "SetHighlight");
    addKeyframeStream:map(function(data) return "AddKeyframeReq", data end):subscribe(sendPacketStream);
    
    frameCommandStream:map(function(data) return "Frame", data end):subscribe(uiStateStream);
    frameCommandStream:map(function(data) return "SetFrame", data end):subscribe(sendPacketStream);

    RxUtils.eventObservable(uiEventStream, "SettingUpdated"):map(function(data) return "UpdateSettings", data end)
        :subscribe(sendPacketStream);

    Msg("SMH client initialized.\n");

end

hook.Add("InitPostEntity", "SMHSetup", function()
    Setup();
end);
