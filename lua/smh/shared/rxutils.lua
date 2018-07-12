local RxUtils = {};

local Rx = include("../rxlua/rx.lua");

local function GetOrCreateSubject(table, key, wrapper)
    if table[key] ~= nil then
        return table[key];
    end

    local subject = Rx.Subject.create();
    wrapper(subject);

    table[key] = subject;
    return subject;
end

local commandStreams = {};

function RxUtils.fromConcommand(command)
    return GetOrCreateSubject(commandStreams, command, function(subject)
        concommand.Add(command, function(...) subject(...) end);
    end);
end

local hooks = {};

function RxUtils.fromHook(hookName)
    return GetOrCreateSubject(hooks, hookName, function(subject)
        hook.Add(hookName, "RxUtilsHook_" .. hookName, function(...) subject(...) end);
    end);
end

local receivers = {};

function RxUtils.fromNetReceiver(command)
    return GetOrCreateSubject(receivers, command, function(subject)
        net.Receive(command, function(...) subject(...) end);
    end);
end

if CLIENT then

    function RxUtils.bindDPanel(panel, setFunc, onChangeFunc)
        local input = Rx.Subject.create();
        local output = Rx.Subject.create();
        local changing = false;
        if onChangeFunc ~= nil then
            panel[onChangeFunc] = function(self, ...)
                if not changing then
                    changing = true;
                    output(...);
                    changing = false;
                end
            end
        end
        if setFunc ~= nil then
            input:subscribe(function(...) 
                if not changing then
                    changing = true;
                    panel[setFunc](panel, ...);
                    changing = false;
                end
            end);
        end
        return input, output;
    end

end

return RxUtils;