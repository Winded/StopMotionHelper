local NetProtocol = {};

function NetProtocol.ReadKeyframeData()
    return {
        Position = net.ReadInt(32),
        EaseIn = net.ReadFloat(),
        EaseOut = net.ReadFloat(),
    };
end

function NetProtocol.WriteKeyframeData(data)
    net.WriteInt(data.Position, 32);
    net.WriteFloat(data.EaseIn);
    net.WriteFloat(data.EaseOut);
end

return NetProtocol;