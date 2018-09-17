local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");
local NetProtocol = SMH.Include("shared/net_protocol.lua");

local function Setup()

    local addKeyframe = RxUtils.fromNetReceiver("SMHAddKeyframeAck"):map(function()
        local id = net.ReadInt(32);
        local data = NetProtocol.ReadKeyframeData();
        data.Id = id;
        return data;
    end);

    local removeKeyframe = RxUtils.fromNetReceiver("SMHRemoveKeyframeAck"):map(function() return net.ReadInt(32) end);

    local reloadKeyframes = RxUtils.fromNetReceiver("SMHReloadKeyframes"):map(function()
        local keyframes = {};
        local numKeyframes = net.ReadInt(32);
        for i = 1, numKeyframes do
            table.insert(keyframes, {
                Id = net.ReadInt(32),
                Position = net.ReadInt(32),
            });
        end
        return keyframes;
    end);

    local frame = Rx.Subject.create();
    frame:subscribe(function(newFrame)
        net.Start("SMHSetFrame");
        net.WriteInt(newFrame, 32);
        net.SendToServer();
    end);

    local entity = Rx.Subject.create();
    entity:subscribe(function(newEntity)
        net.Start("SMHSetEntity");
        net.WriteEntity(newEntity);
        net.SendToServer();
    end);

    local addKeyframe = Rx.Subject.create();
    addKeyframe:subscribe(function(data)
        net.Start("SMHAddKeyframeReq");
        NetProtocol.WriteKeyframeData(data);
        net.SendToServer();
    end);

    local updateKeyframe = Rx.Subject.create();
    updateKeyframe:subscribe(function(data)
        net.Start("SMHUpdateKeyframe");
        net.WriteInt(data.Id, 32);
        NetProtocol.WriteKeyframeData(data);
        net.SendToServer();
    end);

    local removeKeyframe = Rx.Subject.create();
    removeKeyframe:subscribe(function(id)
        net.Start("SMHRemoveKeyframeReq");
        net.WriteInt(id, 32);
        net.SendToServer();
    end);

    return {
        Input = {
            Frame = frame,
            Entity = entity,
            AddKeyframe = addKeyframe,
            UpdateKeyframe = updateKeyframe,
            RemoveKeyframe = removeKeyframe,
        },
        Output = {
            AddKeyframe = addKeyframe,
            RemoveKeyframe = removeKeyframe,
            ReloadKeyframes = reloadKeyframes,
        }
    };

end

return Setup;