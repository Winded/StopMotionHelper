function smhInclude(path)
    local rootPath = os.getenv("SMH_PATH")
    if rootPath == nil then
        error("SMH_PATH is undefined")
    end
    return dofile(rootPath .. path)
end

function includeMock(path)
    return smhInclude("/smh/tests/mocks" .. path)
end

LU = smhInclude("/smh/tests/luaunit.lua")
Ludi = smhInclude("/smh/submodules/ludi/ludi.lua")

local testFiles = {
    "implementations/entity_highlighter_test.lua",
    "implementations/entity_selector_test.lua",
}

for _, f in pairs(testFiles) do
    smhInclude("/smh/tests/" .. f)
end

local runner = LU.LuaUnit.new()
runner:setOutputType("tap")
os.exit(runner:runSuite())