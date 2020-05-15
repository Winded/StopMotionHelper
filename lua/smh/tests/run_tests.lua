function smhInclude(path)
    local rootPath = os.getenv("SMH_PATH")
    if rootPath == nil then
        error("SMH_PATH is undefined")
    end
    return dofile(rootPath .. path)
end

function includeStub(path)
    return smhInclude("/smh/tests/stub" .. path)
end

function trackCalls(target, name, fn)
    return function(...)
        if target[name] == nil then
            target[name] = 1
        else
            target[name] = target[name] + 1
        end
        return fn(...)
    end
end

function wrapMetatables(...)
    local tables = {...}
    local metatable = {
        __index = function(self, key)
            for _, mt in ipairs(tables) do
                if mt[key] ~= nil then
                    return mt[key]
                end
            end
            return nil
        end
    }
    local obj = {}
    setmetatable(obj, metatable)
    return obj
end

inspect = smhInclude("/smh/tests/inspect.lua")

function math.Round(value)
    local fraction = math.abs(value - math.floor(value))
    if fraction >= 0.5 then
        return math.ceil(value)
    else
        return math.floor(value)
    end
end

-- GMOD constants
MOUSE_LEFT = 107
MOUSE_RIGHT = 108
MOUSE_MIDDLE = 109

LU = smhInclude("/smh/tests/luaunit.lua")
Ludi = smhInclude("/smh/submodules/ludi/ludi.lua")

local testFiles = {
    "implementations/ui/frame_pointer_factory_test.lua",
    "implementations/ui/frame_pointer_test.lua",
    "implementations/entity_highlighter_test.lua",
    "implementations/entity_selector_test.lua",
}

for _, f in pairs(testFiles) do
    smhInclude("/smh/tests/" .. f)
end

local runner = LU.LuaUnit.new()
runner:setOutputType("tap")
os.exit(runner:runSuite())