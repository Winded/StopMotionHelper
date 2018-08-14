local Rx = SMH.Include("rxlua/rx.lua");
local RxUtils = SMH.Include("shared/rxutils.lua");
local NetProtocol = SMH.Include("shared/net_protocol.lua");

local function Setup(inputStreams, outputStreams)

    RxUtils.fromNetReceiver("SMHAddKeyframeAck"):map(function()
        local id = net.ReadInt(32);
        local data = NetProtocol.ReadKeyframeData();
        data.Id = id;
        return data;
    end):subscribe(outputStreams.AddKeyframe);

    RxUtils.fromNetReceiver("SMHRemoveKeyframeAck"):map(function() return net.ReadInt(32) end)
        :subscribe(outputStreams.RemoveKeyframe);

    RxUtils.fromNetReceiver("SMHReloadKeyframes"):map(function()
        local keyframes = {};
        local numKeyframes = net.ReadInt(32);
        for i = 1, numKeyframes do
            table.insert(keyframes, {
                Id = net.ReadInt(32),
                Position = net.ReadInt(32),
            });
        end
        return keyframes;
    end):subscribe(outputStreams.ReloadKeyframes);

    inputStreams.SetFrame:subscribe(function(newFrame)
        net.Start("SMHSetFrame");
        net.WriteInt(newFrame, 32);
        net.SendToServer();
    end);

    inputStreams.SetEntity:subscribe(function(newEntity)
        net.Start("SMHSetEntity");
        net.WriteEntity(newEntity);
        net.SendToServer();
    end);

    inputStreams.AddKeyframe:subscribe(function(data)
        net.Start("SMHAddKeyframeReq");
        NetProtocol.WriteKeyframeData(data);
        net.SendToServer();
    end);

    inputStreams.UpdateKeyframe:subscribe(function(data)
        net.Start("SMHUpdateKeyframe");
        net.WriteInt(data.Id, 32);
        NetProtocol.WriteKeyframeData(data);
        net.SendToServer();
    end);

    inputStreams.RemoveKeyframe:subscribe(function(id)
        net.Start("SMHRemoveKeyframeReq");
        net.WriteInt(id, 32);
        net.SendToServer();
    end);

end

return Setup;