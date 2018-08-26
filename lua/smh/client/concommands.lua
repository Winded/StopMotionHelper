
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Setup(inputStreams, outputStreams)

    RxUtils.fromConcommand("+smh_menu"):map(function() return true end):subscribe(outputStreams.MenuVisibility);
    RxUtils.fromConcommand("-smh_menu"):map(function() return false end):subscribe(outputStreams.MenuVisibility);

    RxUtils.fromConcommand("smh_record"):map(function() return nil end):subscribe(outputStreams.Record);

    RxUtils.fromConcommand("smh_next"):map(function() return nil end)
        :with(inputStreams.SetFrame, inputStreams.PlaybackLength)
        :map(function(_, frame, playbackLength) return (frame + 1) < playbackLength and (frame + 1) or 0 end)
        :subscribe(outputStreams.SetFrame);

    RxUtils.fromConcommand("smh_previous"):map(function() return nil end)
        :with(inputStreams.SetFrame, inputStreams.PlaybackLength)
        :map(function(_, frame, playbackLength) return (frame - 1) >= 0 and (frame - 1) or (playbackLength - 1) end)
        :subscribe(outputStreams.SetFrame);

    RxUtils.fromConcommand("+smh_playback"):map(function() return true end):subscribe(outputStreams.Playback);
    RxUtils.fromConcommand("-smh_playback"):map(function() return false end):subscribe(outputStreams.Playback);

    RxUtils.fromConcommand("smh_onionskin"):map(function() return nil end)
        :with(inputStreams.OnionSkin):map(function(_, onionSkin) return not onionSkin end)
        :subscribe(outputStreams.OnionSkin);

    RxUtils.fromConcommand("smh_quicksave"):map(function() return nil end):subscribe(outputStreams.QuickSave);

    RxUtils.fromConcommand("smh_render"):map(function() return nil end):subscribe(outputStreams.Render);

    local boolConVarHook = function(convar, inputStream, outputStream)
        local cvInputStream, cvOutputStream = RxUtils.fromConVar(convar);
        inputStream:map(function(value) return value and "1" or "0" end):subscribe(cvInputStream);
        cvOutputStream:map(function(value) return value ~= "0" end):subscribe(outputStream);
    end

    boolConVarHook(CreateClientConVar("smh_freezeall", "0"), inputStreams.FreezeAll, outputStreams.FreezeAll);
    boolConVarHook(CreateClientConVar("smh_localizephysbones", "0"), inputStreams.LocalizePhysBones, outputStreams.LocalizePhysBones);
    boolConVarHook(CreateClientConVar("smh_ignorephysbones", "0"), inputStreams.IgnorePhysBones, outputStreams.IgnorePhysBones);
    boolConVarHook(CreateClientConVar("smh_ghostprevframe", "0"), inputStreams.GhostPrevFrame, outputStreams.GhostPrevFrame);
    boolConVarHook(CreateClientConVar("smh_ghostnextframe", "0"), inputStreams.GhostNextFrame, outputStreams.GhostNextFrame);
    boolConVarHook(CreateClientConVar("smh_ghostallentities", "0"), inputStreams.GhostAllEntities, outputStreams.GhostAllEntities);

    local cvGhostTransparencyInput, cvGhostTransparencyOutput = RxUtils.fromConVar(CreateClientConVar("smh_ghosttransparency", "0.5"));
    inputStreams.GhostTransparency:map(function(value) return tostring(value) end):subscribe(cvGhostTransparencyInput);
    cvGhostTransparencyOutput:map(function(value) return tonumber(value) end):subscribe(outputStreams.GhostTransparency);

end

return Setup;