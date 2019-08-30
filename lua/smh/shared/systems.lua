local SYSTEMS = {}

SYSTEMS.registered = {}
SYSTEMS.idCounter = 1

function SYSTEMS.Register(name, metatable)
    if SYSTEMS.registered[name] ~= nil then
        error("System " .. name .. " already registered")
    end

    metatable._Name = name
    SYSTEMS.registered[name] = metatable
end

function SYSTEMS.Create(name, ...)
    local metatable = SYSTEMS.registered[name]
    if metatable == nil then
        error("System " .. name .. " is not registered")
    end

    local system = {}
    setmetatable(system, metatable)
    system._Id = SYSTEMS.idCounter
    SYSTEMS.idCounter = SYSTEMS.idCounter + 1

    system.Init(system, ...)

    return system
end

SMH.Systems = SYSTEMS