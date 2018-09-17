
local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");

local function Setup()

    local menuVisiblity = RxUtils.fromConcommand("+smh_menu"):map(function() return true end)
        :merge(RxUtils.fromConcommand("-smh_menu"):map(function() return false end));

    local record = RxUtils.fromConcommand("smh_record"):map(function() return nil end);

    local inputFrame = Rx.Subject.create();
    local outputFrame = RxUtils.fromConcommand("smh_next"):map(function() return 1 end)
        :merge(RxUtils.fromConcommand("smh_previous"):map(function() return -1 end))
        :with(inputFrame, playbackLength)
        :map(function(frameDelta, frame, playbackLength)
            local newFrame = frame + frameDelta;
            newFrame = newFrame < playbackLength and newFrame or 0;
            newFrame = newFrame >= 0 and newFrame or playbackLength - 1;
            return newFrame;
        end);

    local playback = RxUtils.fromConcommand("+smh_playback"):map(function() return true end)
        :merge(RxUtils.fromConcommand("-smh_playback"):map(function() return false end));

    local inputOnionSkin = Rx.Subject.create();
    local outputOnionSkin = RxUtils.fromConcommand("smh_onionskin"):map(function() return nil end)
        :with(inputOnionSkin):map(function(_, onionSkin) return not onionSkin end);

    local quickSave = RxUtils.fromConcommand("smh_quicksave"):map(function() return nil end);

    local render = RxUtils.fromConcommand("smh_render"):map(function() return nil end);

    local boolConVarHook = function(convar)
        local cvInputStream, cvOutputStream = RxUtils.fromConVar(convar);
        local input = Rx.Subject.create();
        input:map(function(value) return value and "1" or "0" end):subscribe(cvInputStream);
        local output = cvOutputStream:map(function(value) return value ~= "0" end);
        return input, output;
    end

    local freezeAllInput, freezeAllOutput = boolConVarHook(CreateClientConVar("smh_freezeall", "0"));
    local localizePhysBonesInput, localizePhysBonesOutput = boolConVarHook(CreateClientConVar("smh_localizephysbones", "0"));
    local ignorePhysBonesInput, ignorePhysBonesOutput = boolConVarHook(CreateClientConVar("smh_ignorephysbones", "0"));
    local ghostPrevFrameInput, ghostPrevFrameOutput = boolConVarHook(CreateClientConVar("smh_ghostprevframe", "0"));
    local ghostNextFrameInput, ghostNextFrameOutput = boolConVarHook(CreateClientConVar("smh_ghostnextframe", "0"));
    local ghostAllEntitiesInput, ghostAllEntitiesOutput = boolConVarHook(CreateClientConVar("smh_ghostallentities", "0"));

    local cvGhostTransparencyInput, cvGhostTransparencyOutput = RxUtils.fromConVar(CreateClientConVar("smh_ghosttransparency", "0.5"));
    local ghostTransparencyInput = Rx.Subject.create();
    ghostTransparencyInput:map(function(value) return tostring(value) end):subscribe(cvGhostTransparencyInput);
    local ghostTransparencyOutput = cvGhostTransparencyOutput:map(function(value) return tonumber(value) end);

    return {
        Input = {
            Frame = inputFrame,
            OnionSkin = inputOnionSkin,

            FreezeAll = freezeAllInput,
            LocalizePhysBones = localizePhysBonesInput,
            IgnorePhysBones = ignorePhysBonesInput,
            GhostPrevFrame = ghostPrevFrameInput,
            GhostNextFrame = ghostNextFrameInput,
            GhostAllEntities = ghostAllEntitiesInput,

            GhostTransparency = ghostTransparencyInput,
        },
        Output = {
            MenuVisiblity = menuVisiblity,
            Record = record,
            Frame = outputFrame,
            Playback = playback,
            OnionSkin = outputOnionSkin,
            QuickSave = quickSave,
            Render = render,

            FreezeAll = freezeAllOutput,
            LocalizePhysBones = localizePhysBonesOutput,
            IgnorePhysBones = ignorePhysBonesOutput,
            GhostPrevFrame = ghostPrevFrameOutput,
            GhostNextFrame = ghostNextFrameOutput,
            GhostAllEntities = ghostAllEntitiesOutput,

            GhostTransparency = ghostTransparencyOutput,
        }
    };

end

return Setup;