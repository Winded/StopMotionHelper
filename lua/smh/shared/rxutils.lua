local RxUtils = {};

local Rx = SMH.Include("rxlua/rx.lua");

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
    return GetOrCreateSubject(commandStreams, command, function(observable)
        concommand.Add(command, function(...) observable:onNext(...) end);
    end);
end

local hooks = {};

function RxUtils.fromHook(hookName)
    return GetOrCreateSubject(hooks, hookName, function(observable)
        hook.Add(hookName, "RxUtilsHook_" .. hookName, function(...) observable:onNext(...) end);
    end);
end

local receivers = {};

function RxUtils.fromNetReceiver(command)
    return GetOrCreateSubject(receivers, command, function(observable)
        net.Receive(command, function(...) observable:onNext(...) end);
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