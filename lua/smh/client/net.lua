local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");
local NetProtocol = SMH.Include("shared/net_protocol.lua");

local function Setup(sendPacketStream)

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

    local sendFuncs = {
        SetFrame = function(newFrame)
            net.Start("SMHSetFrame");
            net.WriteInt(newFrame, 32);
            net.SendToServer();
        end,

        SetEntity = function(newEntity)
            net.Start("SMHSetEntity");
            net.WriteEntity(newEntity);
            net.SendToServer();
        end,
        
        AddKeyframeReq = function(data)
            net.Start("SMHAddKeyframeReq");
            NetProtocol.WriteKeyframeData(data);
            net.SendToServer();
        end,
        
        UpdateKeyframe = function(data)
            net.Start("SMHUpdateKeyframe");
            net.WriteInt(data.Id, 32);
            NetProtocol.WriteKeyframeData(data);
            net.SendToServer();
        end,

        CopyKeyframe = function(data)
            net.Start("SMHCopyKeyframe");
            net.WriteInt(data.Id, 32);
            net.WriteInt(data.Position, 32);
            net.SendToServer();
        end,
        
        RemoveKeyframeReq = function(id)
            net.Start("SMHRemoveKeyframeReq");
            net.WriteInt(id, 32);
            net.SendToServer();
        end,
    };

    sendPacketStream:subscribe(function(type, data)
        if sendFuncs[type] ~= nil then
            sendFuncs[type](data);
        end
    end);

    return Rx.Observable.merge(
        addKeyframe:map(function(data) return "AddKeyframeAck", data end),
        removeKeyframe:map(function(data) return "RemoveKeyframeAck", data end),
        reloadKeyframes:map(function(data) return "ReloadKeyframes", data end)
    );

end

return Setup;